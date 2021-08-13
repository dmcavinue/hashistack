## Hashistack playground
A simple hashistack deployment (consul/vault/nomad) on AWS

```
# make sure to set up AWS vars and tailscale auth key
cp .env.example .env # update accordingly

# provision AWS infrastructure (3x t2.micro nodes and 1x t2.nano for the tailscale relay)
task terraform:apply

# set up our nodes as a hashistack (consul/vault/nomad)
task ansible:install

# initialize vault and unseal it
task vault:init
task vault:unseal

# deploy our test nomad job  and show us the status (currently grafana)
task nomad:start-jobs
task nomad:status
```

##### Cleanup
```
task terraform:destroy
```
