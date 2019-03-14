Purpose
=======

This is a Terraform/Ansible collaboration project to demo the ease of use to start monitoring your basic web servers with icinga


Usage
-----

To use this demo you will need ansible and Terraform tools installed on your laptop.

The aws.tf file is the terraform tool, you will need to add your AWS cli credentials and the Keypair to the file in order for it to work.
(see the key_name records for  the nodes)

Once you did, you need to run "terraform plan" and then "terraform apply" to build the instances,
 which will bring 3 servers: 1 icinga master and 2 remote nodes, and the related security groups.

In the Hosts file add the icinga master under [monitring_servers] and the nodes under [webservers].

in the site.yml:
in the nrpe_allowed_hosts, add the INTERNAL ip of the icinga master.


playbook execution
------------------
 ansible-playbook -i Hosts  -u centos --private-key= <your ssh key> --ssh-common-args='-oStrictHostKeyChecking=no 
