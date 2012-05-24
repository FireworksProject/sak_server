FS = require 'fs'

PROC = require 'proctools'

CONFPATH = '/etc/saks-monitor/conf.json'

describe 'live services', ->
    TEL = require '../../dist/monitor/node_modules/telegram'

    gProcTitle = /saks\-monitor/
    gConf = null
    {mail_sender, mail_password, sms_user, sms_password} = TESTARGV

    beforeRun (done) ->
        FS.readFile CONFPATH, 'utf8', (err, text) ->
            if err then return done(err)
            gConf = text

            try
                defaultConf = JSON.parse(text)
            catch jsonError
                msg = "JSON parsing error in #{CONFPATH}"
                return done(new Error(msg))

            tempConf = extendDefaults(defaultConf, TESTCONF)
            FS.writeFile CONFPATH, JSON.stringify(tempConf), 'utf8', (err) ->
                if err then return done(err)
                return done()
            return
        return


    afterRun (done) ->
        FS.writeFile CONFPATH, gConf, 'utf8', (err) ->
            if err then return done(err)
            return done()
        return


    afterEach (done) ->
        kill = (proc) ->
            promise = PROC.kill(proc[0].pid).then ->
                return done()
            return promise

        PROC.findProcess(gProcTitle).then(kill).fail(done)
        return


    it 'should run on command', (done) ->
        @expectCount(4)

        whenRunning = (serverProc) ->
            line = JSON.parse(serverProc.stdoutBuffer)
            expect(line.msg).toBe("telegram server running at 127.0.0.1:7272")
            expect(serverProc.stderrBuffer).toBe('')

            PROC.findProcess(gProcTitle).then (found) ->
                foundProc = found[0]
                expect(foundProc.pid).toBeA('number')
                expect(serverProc.pid).toBe(foundProc.pid)
                return done()
            return

        opts =
            command: 'saks-monitor'
            args: [mail_sender, mail_password, sms_user, sms_password]
            buffer: on

        PROC.runCommand(opts).then(whenRunning).fail(done)
        return


    it 'should log errors for invalid service credentials', (done) ->
        @expectCount(4)

        whenRunning = (serverProc) ->
            gotSMSLog = no
            gotMailLog = no

            serverProc.stderr.on 'data', (line) ->
                err = JSON.parse(line).err
                msg = err.message

                if /SMS\sservice$/.test(msg)
                    if gotSMSLog then return
                    gotSMSLog = yes
                    expect(err.message).toBe('Unexpected response from SMS service')
                    expect(err.stack).toBeA('object')

                if /email\snotification/.test(msg)
                    if gotMailLog then return
                    gotMailLog = yes
                    expect(err.message.slice(0, 33)).toBe('Error sending email notification:')
                    expect(err.name).toBe('AuthError')

                if gotSMSLog and gotMailLog then return done()
                return

            connection = TEL.connect TESTCONF.port, TESTCONF.hostname, ->
                channel = connection.createChannel('heartbeat')
                channel.publish('ok')
                return
            return

        opts =
            command: 'saks-monitor'
            args: ['foobar', mail_password, sms_user, 'foobar']
            buffer: on

        PROC.runCommand(opts).then(whenRunning).fail(done)
        return


    it 'should log SMS and Email notifications', (done) ->
        @expectCount(4)
        start = 0

        whenRunning = (serverProc) ->
            gotSMSLog = 0
            gotMailLog = 0

            serverProc.stdout.on 'data', (line) ->
                line = JSON.parse(line)

                if /^SMS\sMessage/.test(line.msg)
                    gotSMSLog += 1
                    if gotSMSLog <= 2
                        expect(line.msg.slice(0, 11)).toBe('SMS Message')

                if /^Email\sMessage/.test(line.msg)
                    gotMailLog += 1
                    if gotMailLog <= 1
                        expect(line.msg.slice(0, 13)).toBe('Email Message')

                if gotSMSLog is 2 and gotMailLog is 1
                    timediff = new Date().getTime() - start
                    expect(timediff > 18000).toBe(true)
                    return done()
                return

            connection = TEL.connect TESTCONF.port, TESTCONF.hostname, ->
                channel = connection.createChannel('heartbeat')
                channel.publish('ok')
                start = new Date().getTime()
                setTimeout(->
                    channel.publish('ok')
                , 7000)
                return
            return

        opts =
            command: 'saks-monitor'
            args: [mail_sender, mail_password, sms_user, sms_password]
            buffer: on

        PROC.runCommand(opts).then(whenRunning).fail(done)
        return

    return


extendDefaults = (a, b) ->
    rv = {}
    copyA = JSON.parse(JSON.stringify(a))
    copyB = JSON.parse(JSON.stringify(b))
    for own p, v of copyA
        rv[p] = copyB[p] or v
    return rv
