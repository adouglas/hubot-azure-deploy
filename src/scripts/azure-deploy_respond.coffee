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

gitHubOrgUrl = process.env.GITHUB_ORG_URL
githubUser = process.env.GITHUB_USER
githubAccessToken = process.env.GITHUB_ACCESS_TOKEN

module.exports = (robot) ->
  robot.respond /deploy ([a-z\-]+):([a-z\/\d\-_]+) to qa$/i, (res) ->
    if(!res.match || res.match.length < 3){
      res.reply "I'm afraid I don't understand what you want me to deploy."
      return;
    }

    webSiteSlot = res.match[2].replace('/','-')
    repo = "https://#{gitHubOrgUrl}/#{res.match[1]}"

    azureOpts =
      webSiteSlot: webSiteSlot
    deployOpts =
      repoUrl: repo
      deployBranch: res.match[2]
      deploymentStatusRoom: res.message.user.room
    robot.send {room: deploymentStatusRoom}, "Creating new QA site: " + webSiteSlot + " repo " + repo + " : " + res.match[2]
    azureDeploy = new AzureDeploy robot, process.env
    azureDeploy.deployNewSiteSlot azureOpts, deployOpts, (err, result) ->
      if err?
        robot.logger.error err
        if err.message?
          robot.logger.error err.message
        robot.logger.error 'An undocumented error occurred'
        return
      robot.reply "done"
