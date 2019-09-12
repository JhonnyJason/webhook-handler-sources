
scimodule = {name: "scimodule"}

#region node_modules
require('systemd')
express = require('express')
bodyParser = require('body-parser')
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["scimodule"]?  then console.log "[scimodule]: " + arg
    return

#region internal variables
cfg = null
whh = null

app = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
scimodule.initialize = () ->
    log "scimodule.initialize"
    cfg = allModules.configmodule
    whh = allModules.webhookhandlermodule
    
    app = express()
    app.use bodyParser.urlencoded(extended: false)
    app.use bodyParser.json()
    app.use parseErrorCatch

#region internal functions
# for acces control allowing acces to the necessary services - - - - - 
parseErrorCatch = (error, req, res, next) ->
    log "parseErrorCatch"
    log error
    if error then termination(true, req, res)
    # next()

attachSCIFunctions = ->
    log "attachSCIFunctions"
    app.use whh.getHandler()

## SCI handler functions
attachTermination = ->
    log "attachTermination"
    app.use(termination)

termination = (err, req, res) ->
    log "termination"
    if err then res.sendStatus(400)
    process.exit(0)

listenForRequests = ->
    log "listenForRequests"
    if process.env.SOCKETMODE
        app.listen "systemd"
        log "listening on systemd"
    else
        port = process.env.PORT || cfg.defaultPort
        app.listen port
        log "listening on port: " + port

#endregion


#region exposed functions
scimodule.prepareAndExpose = ->
    log "scimodule.prepareAndExpose"
    attachSCIFunctions()
    attachTermination()
    listenForRequests()
    
#endregion exposed functions

export default scimodule