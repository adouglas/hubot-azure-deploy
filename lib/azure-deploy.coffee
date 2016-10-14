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
    @robot.send {room: @deploymentStatusRoom}, 'Error: HUBOT_AZURE_DEPLOY_CLIENT_ID is not specified' if not @azureClientId
    @robot.send {room: @deploymentStatusRoom}, 'Error: HUBOT_AZURE_DEPLOY_DOMAIN is not specified' if not @azureDomain
    @robot.send {room: @deploymentStatusRoom}, 'Error: HUBOT_AZURE_DEPLOY_SECRET is not specified' if not @azureSecret
    @robot.send {room: @deploymentStatusRoom}, 'Error: HUBOT_AZURE_DEPLOY_SUBSCRIPTION_ID is not specified' if not @azureSubscriptionId
    return false unless (@azureClientId and @azureDomain and @azureSecret and @azureSubscriptionId)
    true


  deployNewSiteSlot: (azureOpts, deployOpts, cb) ->
    @robot.send {room: @deploymentStatusRoom}, 'Error: azureOpts.resourceGroupName is not specified' if not azureOpts.resourceGroupName
    @robot.send {room: @deploymentStatusRoom}, 'Error: azureOpts.webSiteDeplymentId is not specified' if not azureOpts.webSiteDeplymentId
    @robot.send {room: @deploymentStatusRoom}, 'Error: azureOpts.webSiteName is not specified' if not azureOpts.webSiteName
    @robot.send {room: @deploymentStatusRoom}, 'Error: azureOpts.webSiteSlot is not specified' if not azureOpts.webSiteSlot
    @robot.send {room: @deploymentStatusRoom}, 'Error: deployOpts.repoUrl is not specified' if not deployOpts.repoUrl
    @robot.send {room: @deploymentStatusRoom}, 'Error: deployOpts.branch is not specified' if not deployOpts.branch
    return false unless (azureOpts.resourceGroupName and azureOpts.webSiteDeplymentId and azureOpts.webSiteName and azureOpts.webSiteSlot and deployOpts.repoUrl and deployOpts.branch)
    if @ready() is true
      azureClientId = @azureClientId
      azureSecret = @azureSecret
      azureDomain = @azureDomain
      azureSubscriptionId = @azureSubscriptionId

      azureResourceGroupName = azureOpts.resourceGroupName
      azureWebSiteDeplymentId = azureOpts.webSiteDeplymentId
      azureWebSiteName = azureOpts.webSiteName
      azureWebSiteSlot = azureOpts.webSiteSlot

      deployRepoUrl = deployOpts.repoUrl
      deployBranch = deployOpts.branch
      deployNoop = deployOpts.noop

      siteConfig = {}
      if deployOpts.hasOwnProperty('targetBranch')
        siteConfig.appSettings =
          TARGET_BRANCH: deployOpts.targetBranch
          REQUIRES_GIT_OVERRIDE: true

      @_newSiteSlot azureClientId, azureSecret, azureDomain, azureSubscriptionId, azureResourceGroupName, azureWebSiteDeplymentId, azureWebSiteName, azureWebSiteSlot, deployRepoUrl, deployBranch, deployNoop, siteConfig, cb


  _newSiteSlot: (azureClientId, azureSecret, azureDomain, azureSubscriptionId, azureResourceGroupName, azureWebSiteDeplymentId, azureWebSiteName, azureWebSiteSlot, deployRepoUrl, deployBranch, deployNoop, siteConfig, cb) ->
    @robot.send {room: @deploymentStatusRoom}, 'Logging in to Azure (REST)'
    msRestAzure.loginWithServicePrincipalSecret azureClientId, azureSecret, azureDomain, (err, credentials) =>
      if err?
          @robot.send {room: @deploymentStatusRoom}, 'Error Logging in to Azure (REST)'
          @robot.logger.error 'Error Logging in to Azure (REST)'
          @robot.logger.error err
          cb(err)
          return
      @robot.logger.info 'Logged in to Azure (REST)'
      @robot.send {room: @deploymentStatusRoom}, 'Logged in to Azure (REST)'
      client = new webSiteManagementClient(credentials, @azureSubscriptionId)
      optionsopt = null
      deployopt = {location: 'North Europe'}
      @robot.send {room: @deploymentStatusRoom}, 'Creating new deployment slot'
      client.sites.createDeploymentSlot azureResourceGroupName, azureWebSiteName, azureWebSiteDeplymentId, azureWebSiteSlot, deployopt, optionsopt, (err, result, request, response) =>
        if err?
           cb(err)
           return
        @robot.send {room: @deploymentStatusRoom}, 'New deployment slot created (REST)'
        siteSourceControl =
          repoUrl: deployRepoUrl
          branch: deployBranch
          isManualIntegration: true
          deploymentRollbackEnabled: false
          isMercurial: false
        optionsopt = null
        client.sites.updateSiteSourceControlSlot azureResourceGroupName, azureWebSiteName, siteSourceControl, azureWebSiteSlot, optionsopt, (err, result, request, response) =>
          if err?
            cb(err)
            return
          @robot.send {room: @deploymentStatusRoom}, 'Deployment slot SCM updated'
          if Object.keys(siteConfig).length == 0
            cb err, result
          else
            client.sites.getSiteConfigSlot azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) =>
              @robot.send {room: @deploymentStatusRoom}, 'Deployment slot config retrieved'
              result.appSettings = _.extend(result.appSettings, siteConfig.appSettings)
              client.sites.createOrUpdateSiteConfigSlot azureResourceGroupName, azureWebSiteName, result, azureWebSiteSlot, optionsopt, (err, result, request, response) =>
                if err?
                  cb(err)
                  return
                @robot.send {room: @deploymentStatusRoom}, 'Deployment slot config updated'
                client.sites.restartSiteSlot azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) =>
                  if err?
                    cb(err)
                    return
                  @robot.send {room: @deploymentStatusRoom}, 'Deployment slot restarted'
                  client.sites.syncSiteRepository azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) =>
                    if err?
                      cb(err)
                      return
                    @robot.send {room: @deploymentStatusRoom}, 'Deployment slot repo synced'
                    cb err, result
                    return true

module.exports = AzureDeploy
