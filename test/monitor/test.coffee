PROC = require 'proctools'

describe 'executable', ->
    gProcTitle = /saks\-monitor/

    afterRun (done) ->
        kill = (proc) ->
            promise = PROC.kill(proc[0].pid).then ->
                return done()
            return promise

        PROC.findProcess(gProcTitle).then(kill).fail(done)
        return

    it 'should run on command', (done) ->
        @expectCount(4)

        whenRunning = (serverProc) ->
            expect(serverProc.stdoutBuffer).toBe("telegram server running at 127.0.0.1:7272\n")
            expect(serverProc.stderrBuffer).toBe('')

            PROC.findProcess(gProcTitle).then (found) ->
                foundProc = found[0]
                expect(foundProc.pid).toBeA('number')
                expect(serverProc.pid).toBe(foundProc.pid)
                return done()
            return

        opts =
            command: 'saks-monitor'
            args: ['emailaddress', 'emailpassword', 'smsusername', 'smspassword']
            buffer: on

        PROC.runCommand(opts).then(whenRunning).fail(done)

        return

    return


describe 'mock functionality', ->
    TEL = require '../../dist/monitor/node_modules/telegram'
    MAIL = require '../../dist/monitor/node_modules/nodemailer'
    SMS = require '../../dist/monitor/node_modules/q-smsified'
    MON = require '../../dist/monitor/monitor'

    gMailCreateTransport = MAIL.createTransport
    gSMSSession = SMS.Session
    gMonitor = null
    gMailUsername = 'firechief@fireworksproject.com'
    gMailPassword = 'foobar'
    gFromEmail = "SAKS Monitor <#{gMailUsername}>"
    gToEmail = 'foo@example.com, bar@example.com'
    gSMSUser = 'firechief'
    gSMSPass = 'foobar'
    gSMSAddress = '5555555555'

    startMonitor = (callback) ->
        args =
            MAIL_USERNAME: gMailUsername
            MAIL_PASSWORD: gMailPassword
            SMS_USERNAME: gSMSUser
            SMS_PASSWORD: gSMSPass
        gMonitor = MON.monitor args, (err, monitor) ->
            return callback(gMonitor)
        return

    afterEach (done) ->
        MAIL.createTransport = gMailCreateTransport
        SMS.Session = gSMSSession

        if gMonitor is null then return done()
        gMonitor.close ->
            gMonitor = null
            done()
            return
        return


    it 'should create an SMS session', (done) ->
        @expectCount(3)

        SMS.Session = (spec) ->
            expect(spec.username).toBe(gSMSUser)
            expect(spec.password).toBe(gSMSPass)
            expect(spec.address).toBe(gSMSAddress)
            return

        startMonitor (monitor) ->
            return done()
        return


    it 'should create a mail transport', (done) ->
        @expectCount(4)

        MAIL.createTransport = (type, opts) ->
            expect(type).toBe('SMTP')
            expect(opts.service).toBe('Gmail')
            expect(opts.auth.user).toBe(gMailUsername)
            expect(opts.auth.pass).toBe(gMailPassword)

            transport = {}
            transport.close = (callback) ->
                return callback()
            return transport

        startMonitor (monitor) ->
            return done()
        return


    it 'should send out warning emails', (done) ->
        @expectCount(5)
        warningMessage = "This is a warning message"

        MAIL.createTransport = ->
            transport = {}

            transport.close = (callback) ->
                return callback()

            transport.sendMail = (opts, callback) ->
                expect(opts.from).toBe(gFromEmail)
                expect(opts.to).toBe(gToEmail)
                expect(opts.subject).toBe('WARNING from webserver')
                expect(opts.text).toBe(warningMessage)
                callback(null, {message: "sent"})
                return

            return transport

        startMonitor (monitor) ->
            monitor.on 'log', (msg) ->
                if /^Email\sMessage:/.test(msg)
                    expect(msg).toBe("Email Message: sent")
                    return done()
                return

            connection = TEL.connect 7272, 'localhost', ->
                channel = connection.createChannel('warning')
                process.nextTick ->
                    channel.publish(warningMessage)
                    return
                return
            return
        return


    it 'should send out failure emails', (done) ->
        @expectCount(5)
        failureMessage = "This is an error message"

        MAIL.createTransport = ->
            transport = {}

            transport.close = (callback) ->
                return callback()

            transport.sendMail = (opts, callback) ->
                expect(opts.from).toBe(gFromEmail)
                expect(opts.to).toBe(gToEmail)
                expect(opts.subject).toBe('FAILURE from webserver')
                expect(opts.text).toBe(failureMessage)
                callback(null, {message: "sent"})
                return

            return transport

        startMonitor (monitor) ->
            monitor.on 'log', (msg) ->
                if /^Email\sMessage:/.test(msg)
                    expect(msg).toBe("Email Message: sent")
                    return done()
                return

            connection = TEL.connect 7272, 'localhost', ->
                channel = connection.createChannel('failure')
                process.nextTick ->
                    channel.publish(failureMessage)
                    return
                return
            return
        return

    return
