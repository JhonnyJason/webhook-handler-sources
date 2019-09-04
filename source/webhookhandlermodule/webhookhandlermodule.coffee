
webhookhandlermodule = {name: "webhookhandlermodule"}

#region node_modules
http = require('http')
fs = require('fs')
createHandler = require('github-webhook-handler')
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["webhookhandlermodule"]?  then console.log "[webhookhandlermodule]: " + arg
    return

#region internal variables
#endregion


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
webhookhandlermodule.initialize = () ->
    log "webhookhandlermodule.initialize"
    
#region internal functions
writeCommand = (command) ->
    if openSocket
        fs.appendFile openSocket, command, (err) ->
            if err then throw err
            console.log 'write has been successfull'
            return
    else
        console.log 'The File has not been opened yet!'
    return

#endregion

#region exposed functions
#endregion exposed functions

export default webhookhandlermodule



# try
#     config = require('./config')
# catch ex
#     console.log 'caught: ' + ex
#     console.log 'This most likely means that you do not have a real config.js file'
# console.log 'check config before we start: '
# console.log JSON.stringify(config)

# handler = createHandler(
#     path: '/webhook'
#     secret: config.secret)

# socketPath = config.socketPath
# refToActOn = config.refToActOn
# commandMap = config.commandMap
# port = config.port
# openSocket = null

# fs.open socketPath, 'a', (err, fd) ->
#     if err then throw err
#     openSocket = fd
#     return

# http.createServer((req, res) ->
#     #console.log("received request:");
#     #console.log(req);
#     handler req, res, (err) ->
#         if err then throw err
#         res.statusCode = 404
#         res.end 'This is for another purpose'
#         writeCommand '0\n'
#         return
#     return
# ).listen port

# handler.on 'push', (event) ->
#     repo = event.payload.repository.name
#     ref = event.payload.ref
#     command = commandMap[repo]
#     console.log 'Received a push event for ' + repo + ' to ' + ref
#     if ref == refToActOn and command
#         console.log 'So we write Command: ' + command
#         writeCommand command
#     return
