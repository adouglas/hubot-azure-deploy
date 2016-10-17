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

AzureDeploy = require('../azure-deploy')

deploymentStatusRoom = process.env.HUBOT_AZURE_DEPLOY_STATUS_ROOM

module.exports = (robot) ->
  robot.on "github-repo-event", (repo_event) =>
    robot.logger.error "event!!!"
    githubPayload = repo_event.payload
    robot.send {room: deploymentStatusRoom}, 'github-repo-event'
    if repo_event.eventType is "pull_request"
      switch githubPayload.action
        when "opened"
          robot.logger.info "opened!!!"
          azureOpts =
            webSiteSlot: 'pull+' + githubPayload.number
            webSiteDeplymentId: 'pull+' + githubPayload.number
          deployOpts =
            repoUrl: githubPayload.pull_request.head.repo.git_url
            branch: 'master'
            targetBranch: 'refs/pull/' + githubPayload.number + '/merge'
            deploymentStatusRoom: deploymentStatusRoom
          robot.send {room: deploymentStatusRoom}, "Creating new QA site: " + azureOpts.webSiteSlot + " repo " + githubPayload.pull_request.head.repo.git_url + " : " + 'refs/pull/' + githubPayload.number + '/merge'
          azureDeploy = new AzureDeploy robot, process.env
          azureDeploy.deployNewSiteSlot azureOpts, deployOpts, (err, result) ->
            if err?
              robot.logger.error err
              if err.message?
                robot.logger.error err.message
              robot.logger.error 'An undocumented error occurred'
              return
            robot.send {room: deploymentStatusRoom}, "done"
