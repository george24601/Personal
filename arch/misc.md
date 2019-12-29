99.9%: LT 9 hours per year 

reverse proxy layer: nginx keepalived + virtual ip

web server layer: configs web servers behind nginx

write db: mater + shadow master with keepalived + virtual IP


### Time and order in distributed system
Cassandra => asumes clocks are synchronized, uses timestamps to revole conflicts between writes
alternative=> use vector clocks

Spanner: TrueTime: synch time but also estimates worst-case clock drift

Photon: rely on TrueTime heavily to generate id, and define time boundaries

partial order: anti-symmetry, transitivity, and reflexivity, but NOT totality
local clock order: partial order

time are used to determine if it high-latency or network link down: timeout

### Lamport lock and vector lock

lamport lock: provides parital order
1.Whenever process does work, increase counter
2.whenever process sends a message, include the counter
3.when a message is recieved, set the counter to max(local, received) + 1

if counter(a) LT  count(b), either a happens before b, or a, b are not comparable

vector lock: maintains array of N logical clocks. each node increment its own clock by 1 for each internal event
similar to lamport clock, upon recieving a message, update local to max, AND THEN increase its own clock by 1 more

### Time series
(UserId, TimeStamp) - naturally sharded by the UserId

Suppose we have an aggregate query on CompanyId and TS, but no userId, but our raw data has all 3 fields 

(Company, UserId, TimeStamp) - big company hotspot problem

Now we need an index on (CompanyId, TS)

(UserId, Company, TimeStamp, EntryShardId) - an EntryShardId,ie., acts as logical shard


* token-based idempotent API:
 * generate token
 * call buy(token, commodity_id)
 * add requests to MQs to avoid reordering of same token requests

async double write via binlog listening could work too. The main problem is that it does not handle join with tables or in-memory states well

* double write with the help of MQ
  * write to T1 in DB1
  * publish to T1 topic in DB
  * write to T2 in DB2
  * publish to T2 topic in DB2
  * if the online consistency service didn't receive the message within 3s, it will try validating and repairing data consistency.

To use microservice or not - use data-driven approach to measure on metrics

one database per microservice is just a guideline


A change event looks like:

1. PK
2. Op
3. state after the change
4. state before the change
5. metadata about the source: location in log, db, table, transaction id, source timestamp
6. capture timestamp

#yelp
In particular, we’ll look at Elasticpipe, a data infrastructure component we built with Apache Flink to sink any schematized Kafka topic into Elasticsearch. The correctness of Elasticpipe is validated by an auditing system that runs nightly and ensures all upstream records exist in Elasticsearch using an algorithm that requires only O(log(number of records)) queries

The next step was to determine the schema of the denormalized order document that we’d want to store in Elasticsearch. Although it sounds trivial, it required surveying the current clients and thinking of possible future uses cases to determine the subset of fields that would form the denormalized order from over 15 tables that store information pertaining to orders.

One new difficulty that presented itself was how to make sense of many independent Kafka streams of change events, with each table’s changes written to a different Kafka topic. As mentioned above, orders go through multiple intermediary states, with state changes reflected across multiple tables and written out in large database transactions.

As an example: you’re ordering a pizza, but immediately after ordering you decide to add extra toppings and deliver to a friend’s address. In our order processing state machine, credit card transactions are processed asynchronously. An update like this is persisted in MySQL as a new Order row with a “pending” status and foreign key to a new Address row, in addition to a new OrderLine row for the new pizza. In this way, the history of an order is maintained as a linked list, with the tail of the list being the most current order. If the credit card transaction succeeds, yet another Order row will be created in a “completed” state - if it fails, the order will be rolled back by adding a new row which duplicates the order state prior to the attempted update.

The first approach was to run independent processes for inserting events from each table’s data pipeline topic. Given that we wanted a single Elasticsearch index of order documents, a process inserting events from a supporting table (like Address) would need to query to find which orders would be affected by an event and then update those orders. The most concerning challenge with this approach is the need to control the relative order in which events are inserted into Elasticsearch. Taking the example of related address and order events in the above diagram, we would need an order event to be inserted first, so that the address event has a corresponding order to be upserted into.

Another difficulty with this approach is more subtle: resulting records in Elasticsearch may never have existed in MySQL. Consider an incoming update that altered both an order’s address and order lines in one database transaction. Because of the separate processing of each stream, an order in Elasticsearch would reflect those changes in two separate steps. The consequence is that a document read from Elasticsearch after one update has been applied but not the other is one that never existed in MySQL.

Additionally, setting infinite retention on this intermediary topic turns out to be an effective backup in the case of data loss or corruption in Elasticsearch.

So, for our application, we developed the following auditing algorithm which uses binary search to find missing documents:

Get the upstream topic’s low and high watermarks
Get all message keys in the upstream topic between the low and high watermark
De-duplicate and sort the keys into an in-memory array
Sleep for Elasticpipe’s max bulk-write time interval, to allow for documents to be flushed
Query Elasticsearch to find possibly-missing keys, which are those that don’t exist in the index under the restriction that we only query for records whose offset (which is part of the metadata we include with each document) is between the low and high watermarks from step 1. (More on this below)
Without the high watermark offset limit, query to find which of the possibly-missing documents are actually missing. This is the final result.

For example, if the low and high watermarks are L and H, the list of keys has n documents, with the first and last (in lexicographic order) documents having keys k1 and k2, respectively, we can query Elasticsearch for the number of documents between k1 and k2 with an offset between L and H. If the result is equal to n, we’re done. If it’s less than n, we can split the list into a left and right half and binary search recursively until either the number of documents in the range matches what we expected, or all the documents in the range are missing (typically when the range reaches size 1).

The difficulty stems from the lag of 10-20 seconds between a change being committed in a master database and that change being visible in Elasticsearch queries. The lag is primarily driven by the bulk writes to Kafka of the data pipeline MySQL binary log parser. These bulk writes ensure max throughput when processing hundreds of thousands of writes per second, but it means that data pipeline table streams, and therefore the order search pipeline, is always behind the truth of what has been committed in MySQL.

We’ve found two strategies for making a migration. The first is dark-launching, which entails sending requests to both MySQL and Elasticsearch at the same time for a period of a few days to a few weeks and then comparing their output. If we find only a negligible number of requests get differing results, and those differences do not adversely affect users, we can feel confident about making the switch. The second is rewriting clients to be aware that the data they receive might be stale. This strategy requires more work, but is superior because the clients are in the best position to take mitigating actions. One example is the new order history client in Yelp’s iOS and Android apps, which now keeps track of recent orders placed using the app, and sends the id of the most recent order to the backend. The backend queries Elasticsearch and, in the case that the most recent order is not found, will make a supplementary query to MySQL. This way we still get low latency times for the vast majority of queries, while also ensuring that the pipeline latency does not result in users not seeing their most recent order.

Canary instance of MySQLStreamer is subscribed to the same set of MySQL tables as Main instance but is writing to a different set of kafka topic so that it does not affect production usage of our Data Pipeline.