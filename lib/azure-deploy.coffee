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
    @robot.logger.error 'Error: deployOpts.repoUrl is not specified' if not deployOpts.repoUrl
    @robot.logger.error 'Error: deployOpts.branch is not specified' if not deployOpts.branch
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
    @robot.logger.info 'Logging in to Azure (REST)'
    msRestAzure.loginWithServicePrincipalSecret azureClientId, azureSecret, azureDomain, (err, credentials) =>
      if err?
          @robot.logger.error 'Error Logging in to Azure (REST)'
          @robot.logger.error err
          cb(err)
          return
      @robot.logger.info 'Logged in to Azure (REST)'
      client = new webSiteManagementClient(credentials, @azureSubscriptionId)
      optionsopt = null
      deployopt = {location: 'North Europe'}
      @robot.logger.info "Creating new deployment slot (#{azureResourceGroupName}, #{azureWebSiteName}, #{azureWebSiteDeplymentId}, #{azureWebSiteSlot})"
      client.sites.createDeploymentSlot azureResourceGroupName, azureWebSiteName, azureWebSiteDeplymentId, azureWebSiteSlot, deployopt, optionsopt, (err, result, request, response) =>
        if err?
           cb(err)
           return
        @robot.logger.info 'New deployment slot created (REST)'
        siteSourceControl =
          repoUrl: deployRepoUrl
          branch: deployBranch
          isManualIntegration: true
          deploymentRollbackEnabled: false
          isMercurial: false
        optionsopt = null
        @robot.logger.info "Updating slot SCM (#{azureResourceGroupName}, #{azureWebSiteName}, #{siteSourceControl}, #{azureWebSiteSlot.repoUrl}, #{azureWebSiteSlot.branch})"
        client.sites.updateSiteSourceControlSlot azureResourceGroupName, azureWebSiteName, siteSourceControl, azureWebSiteSlot, optionsopt, (err, result, request, response) =>
          if err?
            cb(err)
            return
          @robot.logger.info 'Deployment slot SCM updated'
          if Object.keys(siteConfig).length == 0
            cb err, result
          else
            @robot.logger.info "Retrieving slot config (#{azureResourceGroupName}, #{azureWebSiteName}, #{azureWebSiteSlot})"
            client.sites.getSiteConfigSlot azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) =>
              @robot.logger.info 'Deployment slot config retrieved'
              result.appSettings = _.extend(result.appSettings, siteConfig.appSettings)
              @robot.logger.info 'Updating slot settings'
              client.sites.createOrUpdateSiteConfigSlot azureResourceGroupName, azureWebSiteName, result, azureWebSiteSlot, optionsopt, (err, result, request, response) =>
                if err?
                  cb(err)
                  return
                @robot.logger.info 'Deployment slot config updated'
                @robot.logger.info 'Restarting slot'
                client.sites.restartSiteSlot azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) =>
                  if err?
                    cb(err)
                    return
                  @robot.logger.info 'Deployment slot restarted'
                  @robot.logger.info 'Triggering a slot SCM sync'
                  client.sites.syncSiteRepository azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) =>
                    if err?
                      cb(err)
                      return
                    @robot.logger.info 'Deployment slot repo synced'
                    cb err, result
                    return true

module.exports = AzureDeploy
