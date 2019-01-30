## Bolt vs Ansible Overview
This section contains notes about general setup of `bolt` and `ansible`. 
## Installation
### Ansible
```
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible
```
```
casadilla@casadilla:~$ ansible --version
ansible 2.7.5
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/casadilla/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.15rc1 (default, Nov 12 2018, 14:31:15) [GCC 7.3.0]
```
### Bolt
To do (currently running from source)
```
casadilla@casadilla:~$ bolt --version
1.7.0
```
## Target system
Start up identical docker ubuntu-sshd containers with docker compose
```
casadilla@casadilla:~/workingdir/bolt_hack$ docker-compose up -d
Creating network "bolt_hack_default" with the default driver
Creating bolt_target ... done
Creating ansible_target ... done
casadilla@casadilla:~/workingdir/bolt_hack$ docker ps
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS                   NAMES
cf35a5135426        ubuntu-sshd         "/usr/sbin/sshd -D"   4 seconds ago       Up 2 seconds        0.0.0.0:20023->22/tcp   ansible_target
52d626eb9b2d        ubuntu-sshd         "/usr/sbin/sshd -D"   5 seconds ago       Up 3 seconds        0.0.0.0:20022->22/tcp   bolt_target
casadilla@casadilla:~/workingdir/bolt_hack$ 

```
## Bolt setup
Add connection info to `bolt_control/Boltdir/inventory.yaml`
```
---
nodes:
  - name: localhost
    alias: bolt_target
    config:
      transport: ssh
      ssh:
        user: root
        private-key: /home/casadilla/workingdir/bolt_hack/ssh/id_rsa
        port: 20022
```

## Ansible setup
Note that the target does not have the default python interpreter at `/usr/bin/python` that vanilla ansible expects. Workaround is setting `ansible_python_interpreter`.

```
---
all:
  hosts:
    ansible_target:
      ansible_port: 20023
      ansible_host: localhost
      ansible_user: root
      ansible_ssh_private_key_file: /home/casadilla/workingdir/bolt_hack/ssh/id_rsa
      ansible_connection: ssh
      ansible_python_interpreter: /usr/bin/python3
```
# ad-hoc commands
## Bolt command

```
casadilla@casadilla:~/workingdir/bolt_hack/bolt_control$ bolt command run whoami -n bolt_target
Started on localhost...
Finished on localhost:
  STDOUT:
    root
Successful on 1 node: localhost
Ran on 1 node in 0.19 seconds
```
## Ansible command

```
casadilla@casadilla:~/workingdir/bolt_hack/ansible_control$ ansible ansible_target -a "whoami" -i ./Config/inventory.yaml 
ansible_target | CHANGED | rc=0 >>
root

```

# ad-hoc scripts

### test script
`shared/example_script.py`

```python
#!/usr/bin/python3

import json
import sys

data = { 'args': sys.argv }
print(json.dumps(data))
```
## Bolt script
```
casadilla@casadilla:~/workingdir/bolt_hack/bolt_control$ bolt script run ../shared/example_script.py arg -n bolt_target 
Started on localhost...
Finished on localhost:
  STDOUT:
    {"args": ["/tmp/68298127-f23b-4a30-a5c9-a29b57940de5/example_script.py", "arg"]}
Successful on 1 node: localhost
Ran on 1 node in 0.47 seconds
```
## Ansible script
```
casadilla@casadilla:~/workingdir/bolt_hack/ansible_control$ ansible ansible_target -m script -a "../shared/example_script.py arg" -i ./Config/inventory.yaml
target | CHANGED => {
    "changed": true, 
    "rc": 0, 
    "stderr": "Shared connection to localhost closed.\r\n", 
    "stderr_lines": [
        "Shared connection to localhost closed."
    ], 
    "stdout": "{\"args\": [\"/root/.ansible/tmp/ansible-tmp-1545934626.19-13646823542587/example_script.py\", \"arg\"]}\r\n", 
    "stdout_lines": [
        "{\"args\": [\"/root/.ansible/tmp/ansible-tmp-1545934626.19-13646823542587/example_script.py\", \"arg\"]}"
    ]
}

```