import requests,json,smtplib,ssl,yagmail,sys
from intersight_auth import IntersightAuth




def consult_intersight():
    

    api_key= "5eea84d07564612d336c03e2/5eea84d07564612d336c03ef/5f2c83d67564612d32bd6887"

    digest = IntersightAuth("ChavePublica.txt",api_key)

    uri = "https://intersight.com"

    api_path = "/api/v1/cond/Alarms"

    response = requests.get(url=uri+api_path,auth=digest)
    critical_alerts,warning_alerts,info_alerts= 0,0,0   
    if response.ok:
        
        response = response.json()

        resultados = response["Results"]

        quant_alert = len(resultados)

        dict_alerts = {}

        alert_number = 0

        for i in resultados:
            
            alert_number += 1
            
            
         
            dict_alerts["Alert{}".format(alert_number)] = {"Name":i["Name"],"Severity":i["Severity"],"Description":i["Description"]}
        
        
    
    return dict_alerts


def send_email(email_receiver,email_sender):

    dictionary_body = consult_intersight()
    warning_alerts,info_alerts,critical_alerts = 0,0,0
    alerts_singular = ""
    for k,d in dictionary_body.items():
        if d["Severity"] == "Warning":
            warning_alerts += 1
            alerts_singular+= """<h3>{}:</h3>\n
            -Equiment:{},\n
            -Severity:<img src="https://cdn.iconscout.com/icon/free/png-256/warning-notice-sign-symbol-38020.png" width="20" height="20"/> {},\n
            -Description:{}\n""".format(k,d["Name"],d["Severity"],d["Description"])
        elif d["Severity"] == "Info":
            info_alerts =+ 1
            alerts_singular+= """<h3>{}:</h3>\n
            -Equiment:{},\n
            -Severity:<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Info_icon-72a7cf.svg/1200px-Info_icon-72a7cf.svg.png" width="20" height="20"/> {},\n
            -Description:{}\n""".format(k,d["Name"],d["Severity"],d["Description"])
        elif d["Severity"] == "Critical":
            critical_alerts +=1
            alerts_singular+= """<h3>{}:</h3>\n
            -Equiment:{},\n
            -Severity:<img src="https://cdn2.iconfinder.com/data/icons/freecns-cumulus/32/519791-101_Warning-512.png" width="20" height="20"/> {},\n
            -Description:{}\n""".format(k,d["Name"],d["Severity"],d["Description"])
        
    alerts_total = """<h1>You Have:</h1>
    <h2>{} Critical <img src="https://cdn2.iconfinder.com/data/icons/freecns-cumulus/32/519791-101_Warning-512.png" width="20" height="20"/></h2>
    <h2>{} Warnings <img src="https://cdn.iconscout.com/icon/free/png-256/warning-notice-sign-symbol-38020.png" width="20" height="20"/></h2>
    <h2>{} Info <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Info_icon-72a7cf.svg/1200px-Info_icon-72a7cf.svg.png" width="20" height="20"/></h2>\n
    """.format(critical_alerts,warning_alerts,info_alerts)
    
    body = alerts_total+alerts_singular
    receiver = email_receiver

    html = """\
    <html>
    <head></head>
    <body>
        {}
    </body>
    </html>
    """.format(body)

    yag = yagmail.SMTP(user=str(email_sender[0]),password=str(email_sender[1]))
    yag.send(
        to=receiver,
        subject="Alerts Intersight Storage University",
        contents=html
    )

def main():
    email_receiver = sys.argv[3:]
    email_sender = sys.argv[1:3]
    send_email(email_receiver,email_sender)
    
if __name__ == "__main__":
    main()
        
        
    
