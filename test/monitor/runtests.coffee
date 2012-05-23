FS = require 'fs'
PATH = require 'path'

TRM = require 'treadmill'

LIVE = process.argv[2]

if LIVE
    global.TESTARGV =
        mail_username: process.argv[2]
        mail_password: process.argv[3]
        sms_username: process.argv[4]
        sms_password: process.argv[5]
        sms_sender: process.argv[6]
else
    global.TESTARGV =
        mail_username: 'firechief@fireworksproject.com'
        mail_password: 'foobar'
        sms_username: 'firechief'
        sms_password: 'foobar'
        sms_sender: '5555555555'

checkTestFile = (filename) ->
    if LIVE then return /^live/.test(filename)
    return /^test/.test(filename)

resolvePath = (filename) ->
    return PATH.join(__dirname, filename)

listing = FS.readdirSync(__dirname)
filepaths = listing.filter(checkTestFile).map(resolvePath)

TRM.run filepaths, (err) ->
    if err then process.exit(2)
    process.exit()
