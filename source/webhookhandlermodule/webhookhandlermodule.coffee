
webhookhandlermodule = {name: "webhookhandlermodule"}

#region node_modules
fs = require('fs')
githubWebhook = require('express-github-webhook')
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["webhookhandlermodule"]?  then console.log "[webhookhandlermodule]: " + arg
    return
print = (arg) -> console.log arg

#region internal variables
cfg = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
webhookhandlermodule.initialize = () ->
    log "webhookhandlermodule.initialize"
    cfg = allModules.configmodule

#region internal functions
writeCommand = (command) ->
    log "writeCommand"
    log command
    try
        openSocket = fs.openSync cfg.socketPath, 'a'
        fs.appendFileSync openSocket, command
    catch err
        print 'Command could not be written to socket!'
    return

isToReact = (ref, branchToReact) ->
    log "isToReact?"
    log "ref: " + ref
    log "branchToReact: " + branchToReact
    branchReactionMap = "/" + branchToReact
    ##check if the /branchToReact string is the last part of the ref
    lb = branchToReact.length
    lr = ref.length
    i = ref.lastIndexOf(branchToReact)
    
    if i < 0 then return false
    if i == (lr - lb) then return true
    return false

onPush = (repo, data) ->
    log "onPush"
    console.log JSON.stringify(repo, null, 2)
    console.log JSON.stringify(data, null ,2)

    ## TODO: implement reasonably^^
    # repo = event.payload.repository.name
    # ref = event.payload.ref
    # branchToReact = cfg.branchReactionMap[repo]  
    # command = cfg.commandMap[repo]
    # log 'Received a push event for ' + repo + ' to ' + ref
    # if command and isToReact(ref, branchToReact)
    #     log 'So we write Command: ' + command
    #     writeCommand command
    # return

onError = (err, req, res) ->
    log "onError"
    # log JSON.stringify(req.body, null, 2)
    # console.log err
    # if err then res.sendStatus(400)
    process.exit(0) 

onPing = (err, req, res) ->
    log "onPing"

onAnything = (err, req, res) ->
    log "onAnything"

createHandler = -> 
    log "createHandler"
    argument =
        path: cfg.uri
        secret: cfg.secret
    handler = githubWebhook(argument)
    handler.on("push", onPush)
    handler.on("ping", onPing)
    handler.on("*", onAnything)
    handler.on("error", onError)
    return handler
#endregion

#region exposed functions
webhookhandlermodule.getHandler = ->
    log "webhookhandlermodule.getHandler"
    return createHandler()

#endregion exposed functions

export default webhookhandlermodule