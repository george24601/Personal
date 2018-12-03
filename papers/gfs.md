high bandwidth > low latency

client caches chunk server info for a limited time for subsequent ops

how do you fix hot spot file problem?

metadata logs mutation to an operation log and replilcates on a remote machine

ask chunkserver at start up or when it joins the cluster for the chunk location info

Master periodic scanning to implement chuck GC, re-replication, and chunk migrtiono

Why chunk server maintains chunk location information instead of master

respond to a client op only after flushing log record to disk logically and remotely

new checkpoint can be delayed without delaying incoming mutations

failure in checkpointing => incomplete checkpoints, recovering will skip it

-----
File NS mutations are atomic 

A region is defined after a file data mutation if it is consistent and clients will see what the mutation writes in its entirety.

Concurrent successful mutations leave the region undefined but consistent: all clients see the same data, but it may not reflect what any one mutation has written. 

A record append causes data (the “record”) to be appended atomically at least once even in the presence of concurrent mutations, but at an offset of GFS’s choosing

GFS achieves this by (a) applying mutations to a chunk in the same order on all its replicas, and (b) using chunk version
numbers to detect any replica that has become stale because it has missed mutations while its chunkserver was down

Stale replicas gced at earlies oppurtunity

 GFS identifies failed chunkservers by regular handshakes between master and all chunkservers and detects data corruption by checksumming

Checkpoints may also include application-level checksums. Readers verify and process only the file region up to the last checkpoint, which
is known to be in the defined state. 

Each record prepared by the writer contains extra information like checksums so that its validity can be verified. A reader can identify
and discard extra padding and record fragments using the checksums.

If it cannot tolerate the occasional duplicates (e.g., if they would trigger non-idempotent operations), it can filter them out using
unique identifiers in the records, which are often needed anyway to name corresponding application entities such as web documents.

------
The master grants a chunk lease to one of the replicas, which we call the primary. The primary picks a serial order for all mutations to
the chunk. All replicas follow this order when applying mutations. Thus, the global mutation order is defined first by the lease grant order
chosen by the master, and within a lease by the serial numbers assigned by the primary.

Even if the master loses communication with a primary, it can safely grant a new lease to another replica after the old lease expires.

sequence of actions for write

1. client asks master for the location of chuck primary and other replicas
2. client pushes data to all replicas
3. client sends write request to primary
4. primary decides order in which mutation are appended, and apply it locally 
5. primary forward write requests to ALL replicas, the consequence is that only need to read 1 replica to satisfy R + W > N
6. primary gets ack from replicas, and reply to client


In case of errors, the write may have succeeded at the primary and an arbitrary subset of the secondary replicas. (If it had failed at the primary, it would not have been assigned a serial number and forwarded.) The client request is considered to have failed, and the modified region is left in an inconsistent state. Our client code handles such errors by retrying the failed mutation.

GFS does not guarantee that all replicas are bytewise identical. It only guarantees that the data is written at least once as an atomic unit.

for the operation to report success, the data must have been written at the same offset on all replicas of some chunk


---------
After the leases have been revoked or have expired, the master logs the operation to disk. It then applies this log record to its in-memory
state by duplicating the metadata for the source file or directory tree. The newly created snapshot files point to the same chunks as the
source files.

--------
Whenever the master grants a new lease on a chunk, it increases the chunk version number and informs the up-to-date replicas. The master and these replicas all record the new version number in their persistent state.

If the master sees a version number greater than the one in its records, the master assumes that it failed when granting the lease and so takes the higher version to be up-to-date.

--------
Clients use only the canonical name of the master (e.g. gfs-test), which is a DNS alias that can be changed if the master is relocated to
another machine.

In fact, since file content is read from chunkservers, applications do not observe stale file content. What could be stale within short windows is file metadata, like directory contents or access control information.
It depends on the primary master only for replica location updates resulting from the primary’s decisions to create and delete replicas.

Like other metadata, checksums are kept in master's memory and stored persistently with logging, separate from user data. By calculate we can see that metadata can fit into memory completely

shadow master techinique also means that 50% resource usage
