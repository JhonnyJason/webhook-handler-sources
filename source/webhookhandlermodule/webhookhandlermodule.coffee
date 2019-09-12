
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
    # console.log JSON.stringify(repo, null, 2)
    # console.log JSON.stringify(data, null ,2)

    ref = data.ref
    branch = cfg.branchReactionMap[repo]  
    command = cfg.commandMap[repo]

    log 'Received a push event for ' + repo + ' to ' + ref
    log 'Reaction for branch ' + branch
    log 'Command ' + command
    
    if branch and command and isToReact(ref, branch)
        log 'So we write Command: ' + command
        writeCommand command
    
    # res.sendStatus(200)
    process.exit(0)
    

onError = (err, req, res) ->
    log "onError"
    # log JSON.stringify(req.body, null, 2)
    # console.log err
    # if err then res.sendStatus(400)
    process.exit(0) 

onAnything = (event, repo, data) ->
    log "onAnything"
    log "event: " + event
    if event != "push"
        # res.sendStatus(200)
        process.exit(0)

createHandler = -> 
    log "createHandler"
    argument =
        path: cfg.uri
        secret: cfg.secret
    handler = githubWebhook(argument)
    handler.on("*", onAnything)
    handler.on("push", onPush)
    handler.on("error", onError)
    return handler
#endregion

#region exposed functions
webhookhandlermodule.getHandler = ->
    log "webhookhandlermodule.getHandler"
    return createHandler()

#endregion exposed functions

export default webhookhandlermodule