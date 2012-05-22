TEL = require 'telegram'
MAIL = require 'nodemailer'

CONFPATH = '/etc/saks-monitor'

MAIL_USERNAME = process.argv[2]
MAIL_PASSWORD = process.argv[3]

exports.monitor = ->
    self = {}
    mTelegramServer = null
    mMailTransport = null

    if not MAIL_USERNAME
        throw new Error("missing mail username argument")

    if not MAIL_PASSWORD
        throw new Error("missing mail password argument")

    CONF = require "#{CONFPATH}/conf.json"

    mTelegramServer = TEL.createServer()

    mMailTransport = MAIL.createTransport('SMTP', {
            service: 'Gmail'
            auth: {user: MAIL_USERNAME, pass: MAIL_PASSWORD}
        })


    mTelegramServer.listen CONF.port, CONF.hostname, ->
        addr = mTelegramServer.address()
        console.log "telegram server running at #{addr.address}:#{addr.port}"
        return


    mTelegramServer.subscribe 'heartbeat', (message) ->
        console.log 'WARN', message
        return


    mTelegramServer.subscribe 'warning', (message) ->
        console.log 'WARN', message
        return


    mTelegramServer.subscribe 'failure', (message) ->
        console.log 'FAIL', message
        return


    sendMail = (aSubject, aBody) ->
        opts =
            from: "SAKS Monitor <#{MAIL_USERNAME}>"
            to: CONF.mail_list.join(', ')
            subject: aSubject
            text: aBody

        mMailTransport.sendMail opts, (err, res) ->
            if err
                console.error "Error sending email notification:"
                console.error(err.stack or err.toString())
                return

            console.log "Email Message: #{res.message}"
            return
        return


    self.close = (callback) ->
        mTelegramServer.on('close', callback)
        mMailTransport.close -> mTelegramServer.close()
        return

    return self


if module is require.main
    process.title = 'saks-monitor'
    exports.monitor()
