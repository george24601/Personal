### Old notes

multi-version,sync-replicated, externally-consistent distributed transactions

shard data across set of Paxos state machines. auto failover, auto resharding/rebalancing

BigTable can't handle complex/evoling schemas well, or consistency across datacenters=> people are even willing to tolerate poor write
throughput

data is schematized and semi-relational, versioned with commit time

externally consistent read and write. Globally consistent read at a timestamp

each transaction has a globally meaningful TS. the order of time satisfies linearizability,i.e., if T1 commits before T2, then t1 < t2

=> relies on the truetime API, spanner has to wait until it passed uncertainty (< 10 ms)

-----
3 deployments
test playground / dev-production/ prod only

zone: unit of deployment and physical isolation

each zone has 1 zone master with hundreds to thousands spanserver, zonemaster assigns data, spanserver serves data to client
per-zone location proxies used by clients to locate spanserver

singleton: universe master and placement master (not discussed in paper)

---
each spanserver manages 100-1000 tablets, which is a bag of <k:string, ts:Long> -> string.

Unlike Bigtable, Spanner assigns timestamps to data, which is an important way in which Spanner is more like a multi-version database than a key-value store.

the tablet state is stored on a B-tree like files and WAL, backed by successor to GFS

Each spanserver implements a single Paxos state machine on top of each tablet.
Each state machine stores its metadata and log in its corresponding tablet.

Leader is handles by lease which defaults to 10s. Writes are applied by Paxos in order

each leader's spanserver implements a lock table for concurrency control

leader's span server handles 2PC for transcations involves multiple Paxos groups

 Writes must initiate the Paxos protocol at the leader; reads access state directly from the underlying tablet at any replica that is sufficiently up-to-date. The set of replicas is collectively a Paxos group.

At every replica that is a leader, each spanserver also implements a transaction manager to support distributed transactions. The transaction manager is used to imple- ment a participant leader; the other replicas in the group will be referred to as participant slaves. If a transac- tion involves only one Paxos group (as is the case for most transactions), it can bypass the transaction manager, since the lock table and Paxos together provide transac- tionality. If a transaction involves more than one Paxos group, those groups’ leaders coordinate to perform two- phase commit. One of the participant groups is chosen as the coordinator: the participant leader of that group will be referred to as the coordinator leader, and the slaves of that group as coordinator slaves. The state of each trans- action manager is stored in the underlying Paxos group

-----

directionry/bucket: continous key sharing same prefix => unit of data movement. 
Each tablet encapsulates a few (not one as in BigTable) continous row groups.

Movedir

seprate data replication config responsibility

-------
lack of cross-row transaction in BigTable. 
rather not always code-around lack of transaction
support proto buff type

each row in the directory table with all descendant table start with K in lexi order forms a directory => naturally formed locality

-----
TrueTime API: GPS and atomic cross-referencing
...

-----
Bigtable only supports eventually-consistent replication across data- centers.

We believe it is better to have application programmers deal with per- formance problems due to overuse of transactions as bot- tlenecks arise, rather than always coding around the lack of transactions. Running two-phase commit over Paxos mitigates the availability problems.

 every table is re- quired to have an ordered set of one or more primary-key columns. This requirement is where Spanner still looks like a key-value store: the primary keys form the name for a row, and each table defines a mapping from the primary-key columns to the non-primary-key columns.
-----
Reads in a read-only transcation executes at a system-chosen timestamp without locking, so incoming writes are not blocked => it can run on
any replica that is sufficiently up-to-date

snapshot read: read in the past

leader leases and lease votes
for each paxos group, the lease intervals is disjoint for every other leader's
abdiction

-------
RW transaction
between when all locks acquired, and before any are released => use the ts of paxos write that represents commit
within each paxos group, assign monotonitcally increasing ts on writes, evne across writes
=> recall that disjoint ts interval requirement between leaders

writes in a tranx buffered in client, so the read in tran does not see the write effect
use woundwait to avoid deadlock

client inits and handles 2PC when it finishes all reads and buffers up all writes
....

-------
RO transaction

read at timestamp => t(Safe) = min(t(paxos, safe) , t(TM, safe))
RO: assign s(read), and then do a snapshot read at s(read) => what is the problem
Need to worry about scope: single and multiple Paxos group case

--------
Schema change op
BigTable supports schema change in one DC, but it is blocking
1. assign a future ts
2. block all tranx with ts >= t

4.2.4 skipped








