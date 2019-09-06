
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
handler = null
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
webhookhandlermodule.middleware = (res, req, final) ->
    log "webhookhandlermodule.middleware"
    cb = (err) ->
        if err then throw err
        #make a bad request out of it
        res.statusCode = 404
        res.end 'This is for another purpose'
        writeCommand '0\n'
        return
    handler req, res, cb


webhookhandlermodule.prepare = ->
    log "webhookhandlermodule.prepare"
    handler = createHandler(
        path: '/webhook'
        secret: config.secret
    )
    fs.open socketPath, 'a', (err, fd) ->
        if err then throw err
        openSocket = fd
        return
# handler.on 'push', (event) ->
#     repo = event.payload.repository.name
#     ref = event.payload.ref
#     command = commandMap[repo]
#     console.log 'Received a push event for ' + repo + ' to ' + ref
#     if ref == refToActOn and command
#         console.log 'So we write Command: ' + command
#         writeCommand command
#     return

#endregion exposed functions

export default webhookhandlermodule

# socketPath = config.socketPath
# refToActOn = config.refToActOn
# commandMap = config.commandMap
# port = config.port
# openSocket = null
