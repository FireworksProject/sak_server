process.title = 'saks-monitor'

TEL = require 'telegram'
MAIL = require 'nodemailer'

CONFPATH = '/etc/saks-monitor'

MAIL_USERNAME = process.argv[2]
MAIL_PASSWORD = process.argv[3]

if not MAIL_USERNAME
    throw new Error("missing mail username argument")

if not MAIL_PASSWORD
    throw new Error("missing mail password argument")

CONF = require "#{CONFPATH}/conf.json"

gTelegramServer = TEL.createServer()

gMailTransport = MAIL.createTransport('SMTP', {
        service: 'Gmail'
        auth: {user: MAIL_USERNAME, pass: MAIL_PASSWORD}
    })

gTelegramServer.listen CONF.port, CONF.hostname, ->
    addr = gTelegramServer.address()
    console.log "telegram server running at #{addr.address}:#{addr.port}"
    return

gTelegramServer.subscribe 'heartbeat', (message) ->
    console.log 'WARN', message
    return

gTelegramServer.subscribe 'warning', (message) ->
    console.log 'WARN', message
    return

gTelegramServer.subscribe 'failure', (message) ->
    console.log 'FAIL', message
    return

sendMail = (aSubject, aBody) ->
    opts =
        from: "SAKS Monitor <#{MAIL_USERNAME}>"
        to: CONF.mail_list.join(', ')
        subject: aSubject
        text: aBody

    gMailTransport.sendMail opts, (err, res) ->
        if err
            console.error "Error sending email notification:"
            console.error(err.stack or err.toString())
            return

        console.log "Email Message: #{res.message}"
        return
    return
