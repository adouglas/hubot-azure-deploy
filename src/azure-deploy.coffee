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


class HubotAzureDeploy

  constructor: (@robot, env) ->
    @azureOpts =
      resourceGroupName: process.env.HUBOT_AZURE_DEPLOY_RESOURCEGROUPNAME # rg-analytics
      webSiteDeplymentId: process.env.HUBOT_AZURE_DEPLOY_WEBSITE_DEPLYMENT_ID # /subscriptions/84cf6300-fc86-45aa-9bcb-f090602b7f5f/resourceGroups/rg-analytics/providers/Microsoft.Web/sites/tru-analytics-qa
      webSiteName: process.env.HUBOT_AZURE_DEPLOY_WEBSITE_NAME # tru-qa-analytics
      webSiteSlot: process.env.HUBOT_AZURE_DEPLOY_WEBSITE_SLOT

    @deployOpts =
      repoUrl: process.env.HUBOT_AZURE_DEPLOY_REPO_URL
      branch: process.env.HUBOT_AZURE_DEPLOY_BRANCH
      noop: process.env.HUBOT_AZURE_DEPLOY_NOOP

    @deployOpts.pagerNoop = false if @deployOpts.pagerNoop is "false" or @deployOpts.pagerNoop is "off"

    @azureDeploy = new AzureDeploy @robot, process.env


  deployNewSiteSlot: (azureOpts, deployOpts, cb) ->
    azureOpts = _.extend(@azureOpts, azureOpts)
    deployOpts = _.extend(@deployOpts, deployOpts)

    @azureDeploy.deployNewSiteSlot(azureOpts, deployOpts, cb)


module.exports = HubotAzureDeploy
