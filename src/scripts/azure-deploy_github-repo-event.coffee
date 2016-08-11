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

#azureDeploy = require('../azure-deploy')

deploymentStatusRoom = process.env.HUBOT_AZURE_DEPLOY_STATUS_ROOM

module.exports = (robot) ->
  robot.logger.error "here!!!"
  robot.on "github-repo-event", (repo_event) =>
    robot.logger.error "event!!!"
    githubPayload = repo_event.payload
    robot.send {room: deploymentStatusRoom}, 'github-repo-event'
    if repo_event.eventType is "pull_request"
      switch githubPayload.action
        when "opened"
          robot.logger.info "opened!!!"
          #azureDeploy.deployNewSiteSlot msg, azureOpts, deployOpts, (err, result) ->
          #  robot.send {room: query.room}, message if message
