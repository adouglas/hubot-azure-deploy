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

githubOrgUrl = process.env.GITHUB_ORG_URL
githubUser = process.env.GITHUB_USER
githubAccessToken = process.env.GITHUB_ACCESS_TOKEN

module.exports = (robot) ->
  robot.respond /deploy ([a-z\-\d]+):([a-z\/\d\-_]+) to qa( as [a-z\-\d]+)?$/i, (res) ->
    if !res.match? || res.match.length < 3
      res.reply "I'm afraid I don't understand what you want me to deploy."
      return

    deploymentStatusRoom = res.message.user.room

    if res.match.length < 4
      webSiteSlot = res.match[3].replace('/','-')
    else
      webSiteSlot = res.match[3].replace(' as ','')

    repo = "#{githubOrgUrl}/#{res.match[1]}"
    repoProtocol = 'https'
    branch = res.match[2]

    azureOpts =
      webSiteSlot: webSiteSlot
    deployOpts =
      repoUrl: repo
      repoProtocol: repoProtocol
      deployBranch: branch
      deploymentStatusRoom: deploymentStatusRoom
    robot.send {room: deploymentStatusRoom}, "Creating new QA site: #{webSiteSlot} repo #{repo}:#{branch}"
    azureDeploy = new AzureDeploy robot, process.env
    azureDeploy.deployNewSiteSlot azureOpts, deployOpts, (err, result) ->
      if err?
        robot.logger.error err
        if err.message?
          robot.logger.error err.message
        else
          robot.logger.error 'An undocumented error occurred'
        return
      robot.reply "done"
