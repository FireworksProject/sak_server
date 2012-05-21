process.title = 'saks-monitor'

TEL = require 'telegram'

CONFPATH = '/etc/saks-monitor'
CONF = require "#{CONFPATH}/conf.json"

server = TEL.createServer()
server.listen CONF.port, CONF.hostname, ->
    addr = server.address()
    console.log "telegram server running at #{addr.address}:#{addr.port}"
    return

server.subscribe 'warning', (message) ->
    console.log 'WARN', message
    return

server.subscribe 'failure', (message) ->
    console.log 'FAIL', message
    return
