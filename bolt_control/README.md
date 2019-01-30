## Bolt Management

## init_config.pp
The fail2ban plan will manage the fail2ban service which scans log files to monitor for suspicious activities such as brute force ssh login attempts and block malicious IPs. This service depends on the rsyslog service to generate logs in the expected locations. The bolt plan will also ensure that the rsyslog service is configured and started using hiera data. 

example:
```
casadilla@casadilla:~/workingdir/bolt_hack/bolt_control$ bolt plan run profiles::init_config -n bolt_target --run_as root
Starting: plan profiles::init_config
Starting: install puppet and gather facts on localhost
Finished: install puppet and gather facts with 0 failures in 20.01 sec
Starting: apply catalog on localhost
Finished: apply catalog with 0 failures in 15.62 sec
Finished: plan profiles::init_config in 35.63 sec
Plan completed successfully with no result
```