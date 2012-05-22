EventEmitter = require('events').EventEmitter

TEL = require 'telegram'
MAIL = require 'nodemailer'
SMS = require 'q-smsified'

CONFDIR = '/etc/saks-monitor'

MAIL_USERNAME = process.argv[2]
MAIL_PASSWORD = process.argv[3]
SMS_USERNAME = process.argv[3]
SMS_PASSWORD = process.argv[5]

exports.monitor = (args, aCallback) ->
    self = new EventEmitter
    CONFPATH = "#{CONFDIR}/conf.json"
    mTelegramServer = null
    mMailTransport = null

    if not args.MAIL_USERNAME
        throw new Error("missing mail username argument")

    if not args.MAIL_PASSWORD
        throw new Error("missing mail password argument")

    if not args.SMS_USERNAME
        throw new Error("missing SMS username argument")

    if not args.SMS_PASSWORD
        throw new Error("missing SMS password argument")

    try
        CONF = require CONFPATH
    catch readErr
        msg = "syntax error in config file #{CONFPATH} : #{readErr.message}"
        throw new Error(msg)

    mTelegramServer = TEL.createServer()

    mMailTransport = MAIL.createTransport('SMTP', {
            service: 'Gmail'
            auth: {user: args.MAIL_USERNAME, pass: args.MAIL_PASSWORD}
        })

    mSMSSession = new SMS.Session({
        username: args.SMS_USERNAME
        password: args.SMS_PASSWORD
        address: CONF.sms_address
    })


    mTelegramServer.listen CONF.port, CONF.hostname, ->
        return aCallback(null, {telegramServer: mTelegramServer})


    mTelegramServer.subscribe 'heartbeat', (message) ->
        console.log 'WARN', message
        return


    mTelegramServer.subscribe 'warning', (message) ->
        sendMail('WARNING from webserver', message)
        return


    mTelegramServer.subscribe 'failure', (message) ->
        sendMail('FAILURE from webserver', message)
        return


    sendMail = (aSubject, aBody) ->
        opts =
            from: "SAKS Monitor <#{args.MAIL_USERNAME}>"
            to: CONF.mail_list.join(', ')
            subject: aSubject
            text: aBody

        mMailTransport.sendMail opts, (err, res) ->
            if err
                self.emit 'error', "Error sending email notification:"
                self.emit 'error', (err.stack or err.toString())
                return

            self.emit 'log', "Email Message: #{res.message}"
            return
        return


    self.close = (callback) ->
        mTelegramServer.on('close', callback)
        mMailTransport.close -> mTelegramServer.close()
        return

    return self


if module is require.main
    process.title = 'saks-monitor'
    args =
        MAIL_USERNAME: MAIL_USERNAME
        MAIL_PASSWORD: MAIL_PASSWORD
        SMS_USERNAME: SMS_USERNAME
        SMS_PASSWORD: SMS_PASSWORD

    monitor = exports.monitor args, (err, info) ->
        {address, port} = info.telegramServer.address()
        console.log "telegram server running at #{address}:#{port}"
        return

    monitor.on 'error', (err) -> console.error err
    monitor.on 'log', (msg) -> console.log msg
