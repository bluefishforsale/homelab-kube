
# Ceph replace Disk / OSD

- determine failed OSDs
- determine which hosts those OSDs are on
- get lsblk listing for those hosts to capture LVM name
- get yaml from OSD showing LVM name (match with lsblk out)
- match osd -> lvm -> /dev/sd?
- ceph cluster CR: remove the bad disks
- toolbox: `ceph osd out osd.N`  (for each bad OSD)
- toolbox: `ceph osd purge osd.N --yes-i-really-mean-it`
- do this slowly and let data re-position
- toolbox: `ceph osd tree` (wait for all bad OSDs to be down or missing)
- replace physical disk, or use teardown / zap script to reset lvm and disk partitions
- toolbox: `ceph auth del osd.N` (for each osd being replaced)
- cluster CR: add disks back
- kube: restart deployment:  ceph-operator, ceph-mgr
- toolbox: `watch -n 10 "ceph osd tree"`

# ceph benchmarking procedure
## list pools already createed
ceph osd pool ls
## create benchmark pool
ceph osd pool create benchmark 128 128
###  create benchmark file (and benchmark write speeds)
rados bench -p benchmark 300 write --no-cleanup
### sequential read
rados bench -p benchmark 300 seq


#########################
Total time run:       91.841
Total reads made:     15810
Read size:            4194304
Object size:          4194304
Bandwidth (MB/sec):   688.581
Average IOPS:         172
Stddev IOPS:          22.932
Max IOPS:             208
Min IOPS:             57
Average Latency(s):   0.0916575
Max latency(s):       3.29196
Min latency(s):       0.0180587


(11 GB, 10 GiB) copied, 5.49271 s, 2.0 GB/s
real	0m5.518s
user	0m0.004s
sys	0m5.311s

(91 GB, 84 GiB) copied, 213.552 s, 424 MB/s
real	3m35.394s
user	0m0.137s
sys	1m8.268s


fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/movies/random_read_write.fio --bs=4k --iodepth=256 --readwrite=randrw --rwmixread=80 -runtime=300 --numjobs=4 --time_based --group_reporting --name=iops-test-job   --size=500GB  --eta-newline=1 --runtime=300

fio --filename=/movies/random_read_write.fio --size=500GB --direct=1 --rw=randrw --bs=4k --ioengine=libaio --iodepth=256 --runtime=120 --numjobs=4 --time_based --group_reporting --name=iops-test-job --eta-newline=1


### ceph speed up OSD recovery
ceph tell 'osd.*' injectargs --osd-max-backfills=3 --osd-recovery-max-active=9

#### default setttings
ceph tell 'osd.*' injectargs --osd-max-backfills=1 --osd-recovery-max-active=0