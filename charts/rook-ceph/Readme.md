# Ceph Rook Cheat Sheet

# cluster health and status
` ceph status`

# ceph pool names
` ceph osd pool ls`

# ceph osd ids and health
` ceph osd tree`

# ceph mon health
` ceph mon stat`

# Too many PGs per OSD
## Enable Pool Autoscaling
` ceph osd pool set {pool-name} pg_autoscale_mode (on|off|warn)`