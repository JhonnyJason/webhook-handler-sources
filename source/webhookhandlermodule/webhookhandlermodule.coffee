
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

isToReact = (ref, branches, commands) ->
    log "isToReact?"
    log "ref: " + ref
    log "branches: " + branches

    # for backwards compatibility only one possible branch
    if typeof branches == "string"
        if isBranchInRef(ref, branches) 
            if typeof commands == "string" 
                return commands
        return 0
    
    for branch,i in branches
        if isBranchInRef(ref, branch)
            return "" + commands[i] + "\n"

    return 0


isBranchInRef = (ref, branch) ->
    log "isBranchInRef"
    lb = branch.length
    lr = ref.length
    i = ref.lastIndexOf(branch)
    
    if i < 0 then return false
    if i == (lr - lb) then return true
    return false


onPush = (repo, data) ->
    log "onPush"
    # console.log JSON.stringify(repo, null, 2)
    # console.log JSON.stringify(data, null ,2)

    ref = data.ref
    branches = cfg.branchReactionMap[repo]  
    commands = cfg.commandMap[repo]

    log 'Received a push event for ' + repo + ' to ' + ref
    log 'Reaction for branch ' + branches
    log 'Command ' + commands
    
    if branches and commands
        command = isToReact(ref, branches, commands)
        if command != 0 
            writeCommand "0\n"
            writeCommand command
            writeCommand "-1\n"

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