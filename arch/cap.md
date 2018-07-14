Note that CAP in the theorem means very specific things, not the intuitive defintion!

C: as if exeuting on a single node

A: every request to ANY NON-FAILED node must return a response: so node failure is outside the scope of CAP! 

P: network is allowed to lose any messages from one node to another. Note this does not mean packet loss, in the proof they use a TCP-ish protocol already. However, from a node's perspective you can not distinguish between a failed node and partitioned node

trivial CP system: ignore all requests, return "no result" => Not being available at all is enough to be CP

trivial AP system: return v0 to all requests

Atomic in CAP means atomic consistency, and is not same in ACID: it doesn't mean all-or-nothing, just order of operations

If we want to implement any consistency, the only option is to kill paritioned nodes

A pure asych system uses no local clock, and can not declare timeout

Note in the CAP proof, msgs are resent if not acked within time limit, i.e., the TCP model,  we can guarantee the initial request will be sent and received

with EC, it is possible it is none of CP, AP, or CA!

Heuristic decision in 2PC
=> CP? not consistent
=> AP? not available, because we can not do any multi-node action
=> not even CA in this sense(what if master failed? the view is not consistent!), but without HD, it becomes CP (CA doesn't work because when master failed and prepared, all slaves are locked)

Paxos
=> AP, no when the link to the leader is cut
=> CA, no, because it is async model, so liveness can not be guaranteed 
=> CP
--------
network partitions are too likely to happen, so CA is useless in practice

consistency that is both instanneous and global is impossible

If a system chooses to provide Consistency over Availability in the presence of partitions (again, read: failures), it will preserve the
guarantees of its atomic reads and writes by refusing to respond to some requests. It may decide to shut down entirely (like the clients of
a single-node data store), refuse writes (like Two-Phase Commit), or only respond to reads and writes for pieces of data whose “master” node
is inside the partition component (like Membase).

is the fact that most real distributed systems do not require atomic consistency or perfect availability and will never be called upon to
perform on a network suffering from arbitrary message loss. 

We assume that clients make queries to servers, in which case there are at least two metrics for correct behavior: yield, which is the
probability of completing a request, and harvest, which measures the fraction of the data reflected in the response, i.e. the completeness
of the answer to the query.

Despite your best efforts, your system will experience enough faults that it will have to make a choice between reducing yield (i.e., stop
answering requests) and reducing harvest (i.e., giving answers based on incomplete data). This decision should be based on business
requirements.

As is obvious in the real world, it is possible to achieve both C and A in this failure mode. You simply failover to a replica in a
transactionally consistent way. Notably, at least Tandem and Vertica have been doing exactly this for years. Therefore, considering a node
failure as a partition results in an obviously inappropriate CAP theorem conclusion.

a dead (or wholly partitioned) node can receive no requests, and so the other nodes can easily compensate without compromising consistency
or availability here. 


---------

CAP against 2PC, Paxos, and Gossip

CA: e.g. full strict quorum protocl. Does not distinguish node failures and network failures.
CP: e.g., majority quorum protocols. Preents divergence by forcing asynmmetric behavior on the two sides of the partitiona.
Have to give up avaialblility during network partition(i.e., both sides of the partition still accept writes)

AP, e.g., protocols with conflict resolution

--------
EC with probalistic guarantees: Dynamo

EC with strong guarantees: CRDT, although data types that can be implemented as CRDT are limited

CALM:  something is logically monotonic, then it is also safe to run without coordination


For single-copy consistency: network parition tolerance requires during such partiions, only 1 partition of the system remains active, since
it is impossible to prevent divergence


