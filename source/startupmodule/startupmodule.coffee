
startupmodule = {name: "startupmodule"}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return

#region internal variables
sci = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
startupmodule.initialize = () ->
    log "startupmodule.initialize"
    sci = allModules.scimodule

#region exposed functions
startupmodule.serviceStartup = ->
    log "startupmodule.serviceStartup"
    sci.prepareAndExpose()

#endregion exposed functions

export default startupmodule