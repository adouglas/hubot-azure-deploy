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

AzureDeploy = require('../lib/azure-deploy')
_ = require('underscore')

azureOpts =
  resourceGroupName: process.env.HUBOT_AZURE_DEPLOY_RESOURCEGROUPNAME
  webSiteDeplymentId: process.env.HUBOT_AZURE_DEPLOY_WEBSITE_DEPLYMENT_ID
  webSiteName: process.env.HUBOT_AZURE_DEPLOY_WEBSITE_NAME
  webSiteSlot: process.env.HUBOT_AZURE_DEPLOY_WEBSITE_SLOT

deployOpts =
  repoUrl: process.env.HUBOT_AZURE_DEPLOY_REPO_URL
  branch: process.env.HUBOT_AZURE_DEPLOY_BRANCH
  noop: process.env.HUBOT_AZURE_DEPLOY_NOOP

deployOpts.pagerNoop = false if deployOpts.pagerNoop is "false" or deployOpts.pagerNoop is "off"

module.exports = (robot) ->
#  AzureDeploy = new AzureDeploy robot, process.env

  deployNewSiteSlot: (msg, azureOpts, deployOpts, cb) ->
    azureOpts = _.extend(@azureOpts, azureOpts)
    deployOpts = _.extend(@deployOpts, deployOpts)
#    AzureDeploy.deployNewSiteSlot(msg, azureOpts, deployOpts, cb)
