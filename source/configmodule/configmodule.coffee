configmodule = {name: "configmodule"}

fs = require "fs"

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

externalConfig = null

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
configmodule.initialize = () ->
    log "configmodule.initialize"
    try 
        configString = String(fs.readFileSync("../webhook-config.json"))
        externalConfig = JSON.parse(configString)        
    catch error
        log error
        try 
            configString = String(fs.readFileSync("../testing/webhook-config.json"))
            externalConfig = JSON.parse(configString)
        catch error
            log error
            console.log "We could read no config file... we die. Bye!"
            process.exit(0)
    log "read config:\n" + JSON.stringify(externalConfig)

#region the configuration Object
configmodule.defaultPort = 3003
# configmodule.allowedOrigins = [
#     'http://localhost:3002'
#     'http://localhost:3003'
#   ]
#endregion

export default configmodule