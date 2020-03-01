# webhook-handler-sources

## startupmodule
The startupmodule is only responsible for the startup.
For the webhook handler here there is nothing to do other than preparing and exposing the sci (service communication interface).

## scimodule
Here we set up express to use parse json.

For the preparation function we do 3 things:
```coffeescript
scimodule.prepareAndExpose = ->
    log "scimodule.prepareAndExpose"
    attachSCIFunctions()
    attachTermination()
    listenForRequests()
```

Actually we only to use the webhook-handler as middleware.

For the reason that we want to have a oneshot service we also add a termination function as middleware right after. We assume that the response has already been sent back when the termination function is reached.
(actually for this purpose we had to patch the express-github-webhook that we also send the status 200 back before we process `next()`)

Optimally only one request comes in at a time so systemd will wake up the service as oneshot for that request and the services stops immediatly after being done processing.

At last we listen on request, which will listen on systemd socket if one is provided. Otherwise it will fall back to the port environment variable.
At last it falls back to a defaultPort in the configuration.

## webhookhandlermodule

Here the real stuff happens we use the express-github-webhook package to notice post request from github - it notice the specific uri we have defined in our configuration.

We need to handle any request so we will definately call `next()` and terminate.
Specifically we handle the push events. Here we have to check the configuration to figure out if we have to do any action for the certain repository and branch which has been pushed to.

In our configuration we have a kind of mapping which gives us a command.

Then we write our command into a socket for further processing.
Also the socket has been specified by the configuration.

## Sample configuration:
```javascript
{
    "uri": "/webhook",
    "secret": "shittysecret",
    "socketPath": "/run/executor.sk",
    "port": 65531,
    "branchReactionMap": {
        "repository-1": ["release", "test"]
        ,"repository-2":["master", "deploy"]
        ...
    },
    "commandMap": {
        "repository-1": [1, 2]
        ,"repository-2":[3, 4]
        ...
    }
}```