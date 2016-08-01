# Description
#   A hubot script listens for github-repo-event(s) and when it recieves a
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Andrew Douglas <andrew.douglas@trurating.com>

azureDeploy = require('../../azure-deploy')

module.exports = (robot) ->

  @robot.on "github-repo-event", (repo_event) =>
    githubPayload = repo_event.payload
    if(repo_event.eventType ===  "pull_request")
      switch(githubPayload.action)
        when "opened"
          azureDeploy.deployNewSiteSlot msg, azureOpts, deployOpts, (err, result) ->
            robot.send {room: query.room}, message if message
