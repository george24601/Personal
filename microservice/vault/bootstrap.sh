sudo yum install wget vim nc unzip screen jq

wget https://releases.hashicorp.com/vault/0.9.3/vault_0.9.3_linux_amd64.zip && unzip vault_0.9.3_linux_amd64.zip 

vault -autocomplete-install

#delete all old vault states
curl --request DELETE \
	0.0.0.0:8500/v1/kv/vault

###start vault, note we use http here in script and hcl. Don't use it in prod!!!
#export VAULT_ADDR='http://127.0.0.1:8200'
source env.sh
#still need sudo to init it - uses mlock to prevent memory being swapped to disk
sudo ./vault server -config=vault.hcl

#clear vault related entries before we init
consul kv delete -recurse vault/

#once per cluster, will give unseal keys and the root token
vault operator init

vault operator unseal

#check what is the auth method
vault auth list
#provide your root token acquired during inti
vault login
#Unlike the kv backend, the consul backend is not mounted by default.
#should display "Enabled the consul secrets engine at: consul/"
vault secrets enable consul

#docker mode, debatable if it is an idea we should persue
docker run -d --restart=always -p 8200:8200 \
	-v /vault/logs:/vault/logs \
	-v /vault/file:/vault/file \
	--name vault-consul 433726475936.dkr.ecr.us-west-2.amazonaws.com/vault-consul \ 
	agent -server


sudo /etc/init.d/dnsmasq restart
