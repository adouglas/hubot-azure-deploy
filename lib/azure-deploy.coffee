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

msRestAzure = require("ms-rest-azure")
webSiteManagementClient = require('azure-arm-website')
_ = require('underscore')
#
# class AzureDeployError extends Error
#
class AzureDeploy

  constructor: (@robot, env) ->
    @env = env
    @azureClientId = env.HUBOT_AZURE_DEPLOY_CLIENT_ID
    @azureDomain = env.HUBOT_AZURE_DEPLOY_DOMAIN
    @azureSecret = env.HUBOT_AZURE_DEPLOY_SECRET
    @azureSubscriptionId = env.HUBOT_AZURE_DEPLOY_SUBSCRIPTION_ID
    @deploymentStatusRoom = env.HUBOT_AZURE_DEPLOY_STATUS_ROOM

    # storageLoaded = =>
    #   @data = @robot.brain.data.phabricator ||= {
    #     projects: { },
    #     aliases: { }
    #   }
    #   @robot.logger.debug 'AzureDeploy Data Loaded: ' + JSON.stringify(@data, null, 2)
    # @robot.brain.on 'loaded', storageLoaded
    # storageLoaded() # just in case storage was loaded before we got here


  ready: () ->
    @robot.logger.error 'Error: HUBOT_AZURE_DEPLOY_CLIENT_ID is not specified' if not @azureClientId
    @robot.logger.error 'Error: HUBOT_AZURE_DEPLOY_DOMAIN is not specified' if not @azureDomain
    @robot.logger.error 'Error: HUBOT_AZURE_DEPLOY_SECRET is not specified' if not @azureSecret
    @robot.logger.error 'Error: HUBOT_AZURE_DEPLOY_SUBSCRIPTION_ID is not specified' if not @azureSubscriptionId
    return false unless (@azureClientId and @azureDomain and @azureSecret and @azureSubscriptionId)
    true


  deployNewSiteSlot: (azureOpts, deployOpts, cb) ->
    @robot.logger.error 'Error: azureOpts.resourceGroupName is not specified' if not azureOpts.resourceGroupName
    @robot.logger.error 'Error: azureOpts.webSiteDeplymentId is not specified' if not azureOpts.webSiteDeplymentId
    @robot.logger.error 'Error: azureOpts.webSiteName is not specified' if not azureOpts.webSiteName
    @robot.logger.error 'Error: azureOpts.webSiteSlot is not specified' if not azureOpts.webSiteSlot
    @robot.logger.error 'Error: azureOpts.webSiteSlotTemplate is not specified' if not azureOpts.webSiteSlotTemplate
    @robot.logger.error 'Error: deployOpts.repoUrl is not specified' if not deployOpts.repoUrl
    @robot.logger.error 'Error: deployOpts.branch is not specified' if not deployOpts.branch
    return false unless (azureOpts.resourceGroupName and azureOpts.webSiteDeplymentId and azureOpts.webSiteName and azureOpts.webSiteSlot and azureOpts.webSiteSlotTemplate and deployOpts.repoUrl and deployOpts.branch)
    if @ready() is true
      azureClientId = @azureClientId
      azureSecret = @azureSecret
      azureDomain = @azureDomain
      azureSubscriptionId = @azureSubscriptionId

      azureResourceGroupName = azureOpts.resourceGroupName
      azureWebSiteName = azureOpts.webSiteName
      azureWebSiteSlot = azureOpts.webSiteSlot
      webSiteSlotTemplate = azureOpts.webSiteSlotTemplate

      deployRepoUrl = deployOpts.repoUrl
      deployBranch = deployOpts.branch
      deployNoop = deployOpts.noop

      siteConfig = {}
      if deployOpts.hasOwnProperty('targetBranch')
        siteConfig.appSettings =
          TARGET_BRANCH: deployOpts.targetBranch
          REQUIRES_GIT_OVERRIDE: true

      @_newSiteSlot azureClientId, azureSecret, azureDomain, azureSubscriptionId, azureResourceGroupName, webSiteSlotTemplate, azureWebSiteName, azureWebSiteSlot, deployRepoUrl, deployBranch, deployNoop, siteConfig, cb


  _newSiteSlot: (azureClientId, azureSecret, azureDomain, azureSubscriptionId, azureResourceGroupName, webSiteSlotTemplate, azureWebSiteName, azureWebSiteSlot, deployRepoUrl, deployBranch, deployNoop, siteConfig, cb) ->
    @robot.logger.info 'Logging in to Azure (REST)'
    msRestAzure.loginWithServicePrincipalSecret azureClientId, azureSecret, azureDomain, (err, credentials) =>
      if err?
          @robot.logger.error 'Error Logging in to Azure (REST)'
          @robot.logger.error err
          cb(err)
          return
      @robot.logger.info 'Logged in to Azure (REST)'
      client = new webSiteManagementClient(credentials, @azureSubscriptionId)
      siteEnvelope =
        location: 'North Europe'
        enabled: true
        # siteName: azureWebSiteSlot
        # cloningInfo:
        #   overwrite: false
        #   cloneCustomHostNames: false
        #   cloneSourceControl: true
        #   sourceWebAppId: "/subscriptions/#{@azureSubscriptionId}/resourceGroups/#{azureResourceGroupName}/providers/Microsoft.Web/sites/#{azureWebSiteName}/slots/#{webSiteSlotTemplate}"

      @robot.logger.info "Creating new deployment slot (#{azureResourceGroupName}, #{azureWebSiteName}, #{azureWebSiteSlot})"
      client.sites.createOrUpdateSiteSlot azureResourceGroupName, azureWebSiteName, siteEnvelope, azureWebSiteSlot, null, (err, result, request, response) =>
        if err?
           cb(err)
           return
        @robot.logger.info 'New deployment slot created (REST)'
        cb err, result
        return true
                # client.sites.restartSiteSlot azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) =>
                #   if err?
                #     cb(err)
                #     return
                #   @robot.logger.info 'Deployment slot restarted'
                #   @robot.logger.info 'Triggering a slot SCM sync'
                #   client.sites.syncSiteRepository azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) =>
                #     if err?
                #       cb(err)
                #       return
                #     @robot.logger.info 'Deployment slot repo synced'
                #     cb err, result
                #     return true

module.exports = AzureDeploy
