Q = require 'q'
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
    gFromEmail = "SAKS Monitor <#{TESTARGV.mail_username}>"
    gToEmail = 'foo@example.com, bar@example.com'

    startMonitor = (callback) ->
        args =
            MAIL_USERNAME: TESTARGV.mail_username
            MAIL_PASSWORD: TESTARGV.mail_password
            SMS_USERNAME: TESTARGV.sms_username
            SMS_PASSWORD: TESTARGV.sms_password
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
            expect(spec.username).toBe(TESTARGV.sms_username)
            expect(spec.password).toBe(TESTARGV.sms_password)
            expect(spec.address).toBe(TESTARGV.sms_sender)
            return

        startMonitor (monitor) ->
            return done()
        return


    it 'should create a mail transport', (done) ->
        @expectCount(4)

        MAIL.createTransport = (type, opts) ->
            expect(type).toBe('SMTP')
            expect(opts.service).toBe('Gmail')
            expect(opts.auth.user).toBe(TESTARGV.mail_username)
            expect(opts.auth.pass).toBe(TESTARGV.mail_password)

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
                    channel.publish(JSON.stringify({stack: warningMessage}))
                    return
                return
            return
        return


    it 'should send out failure email and SMS', (done) ->
        @expectCount(11)
        failureStack = "This is an error stack trace"
        failureMessage = "This is an error message"

        SMS.Session = (spec) ->
            sendCounter = 0

            session = {}
            session.send = (target, message) ->
                sendCounter += 1
                expect(target).toBe('5555555555')
                expect(message).toBe(failureMessage)

                deferred = Q.defer()
                deferred.resolve({data: {resourceURL: "http://foo"}})
                return deferred.promise
            return session

        MAIL.createTransport = ->
            transport = {}

            transport.close = (callback) ->
                return callback()

            transport.sendMail = (opts, callback) ->
                expect(opts.from).toBe(gFromEmail)
                expect(opts.to).toBe(gToEmail)
                expect(opts.subject).toBe('FAILURE from webserver')
                expect(opts.text).toBe(failureStack)
                callback(null, {message: "sent"})
                return

            return transport

        startMonitor (monitor) ->
            smscount = 0
            monitor.on 'log', (msg) ->
                if /^Email\sMessage:/.test(msg)
                    expect(msg).toBe("Email Message: sent")
                if /^SMS\sMessage:/.test(msg)
                    expect(msg).toBe("SMS Message: http://foo")
                    smscount += 1
                    if smscount is 2 then return done()
                return

            connection = TEL.connect 7272, 'localhost', ->
                channel = connection.createChannel('failure')
                process.nextTick ->
                    msg = {stack: failureStack, message: failureMessage}
                    channel.publish(JSON.stringify(msg))
                    return
                return
            return
        return


    it 'should send heartbeat timeout email and SMS', (done) ->
        @expectCount(11)
        failureMessage = 'heartbeat timeout'

        SMS.Session = (spec) ->
            sendCounter = 0

            session = {}
            session.send = (target, message) ->
                sendCounter += 1
                expect(target).toBe('5555555555')
                expect(message).toBe(failureMessage)

                deferred = Q.defer()
                deferred.resolve({data: {resourceURL: "http://foo"}})
                return deferred.promise
            return session

        MAIL.createTransport = ->
            transport = {}

            transport.close = (callback) ->
                return callback()

            transport.sendMail = (opts, callback) ->
                expect(opts.from).toBe(gFromEmail)
                expect(opts.to).toBe(gToEmail)
                expect(opts.subject).toBe('TIMEOUT from webserver')
                expect(opts.text).toBe(failureMessage)
                callback(null, {message: "sent"})
                return

            return transport

        startMonitor (monitor) ->
            smscount = 0

            monitor.on 'log', (msg) ->
                if /^Email\sMessage:/.test(msg)
                    expect(msg).toBe("Email Message: sent")
                if /^SMS\sMessage:/.test(msg)
                    smscount += 1
                    expect(msg).toBe("SMS Message: http://foo")
                    if smscount is 2 then return done()
                    return
                return

            connection = TEL.connect 7272, 'localhost', ->
                channel = connection.createChannel('heartbeat')
                process.nextTick ->
                    channel.publish('ok')
                    return
                return
            return
        return

    return

describe 'init errors', ->
    MON = require '../../dist/monitor/monitor'

    it 'should throw an error for missing MAIL_USERNAME', (done) ->
        @expectCount(1)

        args =
            MAIL_USERNAME: null
            MAIL_PASSWORD: 'anystring'
            SMS_USERNAME: 'anystring'
            SMS_PASSWORD: 'anystring'

        try
            MON.monitor(args)
        catch err
            expect(err.message).toBe('missing mail username argument')

        return done()


    it 'should throw an error for missing MAIL_PASSWORD', (done) ->
        @expectCount(1)

        args =
            MAIL_USERNAME: 'anystring'
            MAIL_PASSWORD: null
            SMS_USERNAME: 'anystring'
            SMS_PASSWORD: 'anystring'

        try
            MON.monitor(args)
        catch err
            expect(err.message).toBe('missing mail password argument')

        return done()


    it 'should throw an error for missing SMS_USERNAME', (done) ->
        @expectCount(1)

        args =
            MAIL_USERNAME: 'anystring'
            MAIL_PASSWORD: 'anystring'
            SMS_USERNAME: null
            SMS_PASSWORD: 'anystring'

        try
            MON.monitor(args)
        catch err
            expect(err.message).toBe('missing SMS username argument')

        return done()


    it 'should throw an error for missing SMS_PASSWORD', (done) ->
        @expectCount(1)

        args =
            MAIL_USERNAME: 'anystring'
            MAIL_PASSWORD: 'anystring'
            SMS_USERNAME: 'anystring'
            SMS_PASSWORD: null

        try
            MON.monitor(args)
        catch err
            expect(err.message).toBe('missing SMS password argument')

        return done()

    return
