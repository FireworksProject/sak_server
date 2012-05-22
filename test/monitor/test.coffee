PROC = require 'proctools'

describe 'monitor', ->
    gProcTitle = /saks\-monitor/
    gServerProc = null

    beforeRun (done) ->
        opts =
            command: 'saks-monitor'
            args: ['emailaddress', 'emailpassword']
            buffer: on

        whenRunning = (proc) ->
            gServerProc = proc
            return done()

        PROC.runCommand(opts).then(whenRunning).fail(done)
        return

    afterRun (done) ->
        kill = (proc) ->
            promise = PROC.kill(proc[0].pid).then ->
                return done()
            return promise

        PROC.findProcess(gProcTitle).then(kill).fail(done)
        return

    it 'should run on command', (done) ->
        @expectCount(4)

        expect(gServerProc.stdoutBuffer).toBe("telegram server running at 127.0.0.1:7272\n")
        expect(gServerProc.stderrBuffer).toBe('')

        PROC.findProcess(gProcTitle).then (found) ->
            foundProc = found[0]
            expect(foundProc.pid).toBeA('number')
            expect(gServerProc.pid).toBe(foundProc.pid)
            return done()

        return

    return
