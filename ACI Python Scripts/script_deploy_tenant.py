import requests
import json
requests.packages.urllib3.disable_warnings()
###Pergunta informações basicas para as chamadas da API###
ip = str(input("Digite o IP da Controladora: ")).upper()
url = "https://{}/api/aaaLogin.json".format(ip)
name= str(input("Digite o usúario: "))
pwd= str(input("Digite a senha: "))
tenant= str(input("Digite o nome do Tenant que deseja criar: "))
json={    "aaaUser": {
        "attributes": {
            "name": "{}".format(name),
            "pwd": "{}".format(pwd)
        }
    }
}
### Captura o Token do usuario###
catch_token = requests.post(url=url,json=json,verify=False)

data = catch_token.json()

token = data["imdata"][0]["aaaLogin"]["attributes"].get("token")

###Cria Tenant###
url= "https://{}/api/node/mo/uni/tn-{}.json".format(ip,tenant)

json={"fvTenant":{"attributes":{"dn":"uni/tn-{}".format(tenant),"name":"{}".format(tenant),"rn":"tn-{}".format(tenant),"status":"created"},"children":[]}}

headers = {
    'Content-Type': "text/plain",

    'Accept': "*/*",
    'Cache-Control': "no-cache",
    'Host': "10.97.39.125",
    'Accept-Encoding': "gzip, deflate",
    'Content-Length': "24",
    'Cookie': "APIC-cookie={}".format(token),
    'Connection': "keep-alive",
    'cache-control': "no-cache"
    }

criar_tenant = requests.post(url=url, json=json,headers=headers,verify=False,)
###Cria um ANP###
pergunta = "SIM"
while pergunta == "SIM":
    anp = str(input("Digite o nome do ANP a ser criado dentro deste Tenant: "))
    url= "https://{}/api/node/mo/uni/tn-{}/ap-{}.json".format(ip,tenant,anp)
    json = {"fvAp":{"attributes":{"dn":"uni/tn-{}/ap-{}".format(tenant,anp),"name":"{}".format(anp),"rn":"ap-{}".format(anp),"status":"created"},"children":[]}}

    headers = {
        'Content-Type': "text/plain",

        'Accept': "*/*",
        'Cache-Control': "no-cache",
        'Host': "10.97.39.125",
        'Accept-Encoding': "gzip, deflate",
        'Content-Length': "24",
        'Cookie': "APIC-cookie={}".format(token),
        'Connection': "keep-alive",
        'cache-control': "no-cache"
        }
    criar_anp = requests.post(url=url,json=json,headers=headers,verify = False)
    pergunta = str(input("Criar outro ANP?\n(s/n):")).upper()

