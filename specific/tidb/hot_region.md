Use split region to pre-split hot regions, otherwise,even though the id is evenly distributed, the newly split region leaders will most likely stay on the same store

conversely, need to turn on region merge if deletion is common

### To split region
1. Leader peer sends request to PD
2. PD creates new region ID and peer ID, and return to leader peer
3. leader peer writes the split action into a raft log, and execute it at apply
4. Tikv tells PD, PD updates cache and persist it to etcd

for non-int PK will use the auto-incr rowid, use `SHARD_ROW_ID_BITS`

check Scheduler, balance-hot-region-scheduler, its value means hot region balancing is happening

