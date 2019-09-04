
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

app = null

responded = false
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
scimodule.initialize = () ->
    log "scimodule.initialize"
    cfg = allModules.configmodule
    search = allModules.citysearchmodule
    app = express()
    app.use bodyParser.urlencoded(extended: false)
    # app.use privateParser
    app.use bodyParser.json()
    app.use parseErrorCatch

#region internal functions
# for acces control allowing acces to the necessary services - - - - - 
parseErrorCatch = (error, req, res, next) ->
    log "parseErrorCatch"
    log error
    if error then termination(req, res)
    next()

setAllowedOrigins = ->
    log "setAllowedOrigins"
    # app.use (req, res, next) ->
    #     allowedOrigins = cfg.allowedOrigins
    #     # origin = req.headers.origin
    #     # log 'header origin was: ' + origin
    #     # if allowedOrigins.indexOf(origin) > -1
    #     #     res.setHeader 'Access-Control-Allow-Origin', origin
    #     # res.header 'Access-Control-Allow-Methods', 'POST, OPTIONS'
    #     # res.header 'Access-Control-Allow-Headers', 'Content-Type'
    #     next()

attachSCIFunctions = ->
    log "attachSCIFunctions"
    app.post '/webhook', onWebhook

## SCI handler functions
onWebhook = (req, res) ->
    log 'onWebhook'
    try
        log "\n" + JSON.stringify(req.body, null, 2)
        result = "ok"
    catch error then result = "error"
    finally
        res.header 'Connection', 'close'
        res.end result
        responded = true
        termination(req, res)
    return

listenForRequests = ->
    log "listenForRequests"
    if process.env.SOCKETMODE
        app.listen "systemd"
        log "listening on systemd"
    else
        port = process.env.PORT || cfg.defaultPort
        app.listen port
        log "listening on port: " + port

attachTermination = ->
    log "attachTermination"
    app.use(termination)

termination = (req, res, err) ->
    log "termination"
    if !responded or err then res.sendStatus(400)
    process.exit(0)

#endregion


#region exposed functions
scimodule.prepareAndExpose = ->
    log "scimodule.prepareAndExpose"
    setAllowedOrigins()
    attachSCIFunctions()
    attachTermination()
    listenForRequests()
    
#endregion exposed functions

export default scimodule