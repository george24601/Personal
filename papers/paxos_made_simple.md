Examples of applications of consensus include whether to commit a transaction to a database, agreeing on the identity of a leader, state machine replication, and atomic broadcasts.

Consensus protocols can be broadly classified into two categories: leader-based and leaderless. Paxos and Raft are the two most commonly used leader-based consensus protocols where the task of data updates and replication is handled by a “leader”. S

 Application of leaderless protocols can be found in blockchain distributed ledgers.

At the heart of Paxos is a three-phase commit protocol that allows participants to give up on other stalled participants after some amount of time. It describes the actions of the participants by their roles in the protocol: client, acceptor, proposer, learner, and leader (aka a distinguished proposer). Many participants may believe they are leaders, but the protocol only guarantees progress if one of them is chosen. This essentially becomes the first phase of the protocol as shown in the figure below.

### old notes
proposer, acceptor, learner

when a majority of acceptors accept the value, it is chosen. 

Acceptor must be allowed to accept more than 1 proposal. why?

if a proposal with value v is chosen, then every higher-numbered proposal that is chosen has value v
any higher numbered proposal must have value v as well from proposer

a proposer that wants to issue a proposal numbered n must learn the highest # proposal with # less than n

A proposer askes the acceptor to promise
1.never accept any # less than n
2.value in proposals highest, < n
and then it issues request only after receives response from a majority of acceptors

an acceptor can accept a proposal n <=> hasn't accepted a prepare request with # > n

----------
learning chosen value
1. naive:each acceptor to respond to each learner
2. let a distinguished learner know, and other learners learn from that, or use a set of distinguished learners

use a distinguished proposer(the only one to issue proposals) to guarantee progress=> election must use liveness or real-time

need to ensure no 2 proposals with same #, so each propoer needs to pick from disjointed #s, and it needs to remember in stable storage what
has been the highets proposals

-------

use a collection of servers, each one indepedently implement the state machine. A single server is elected leader/distinguished
proposer/learner

if the set of servers can change, then there must be ways to determine what servers implement what instances of the consensus algo. The
current set of serveers can be made part of the state and can be changed with state change command as well


