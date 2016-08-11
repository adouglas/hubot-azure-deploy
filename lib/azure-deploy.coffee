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
# _ = require('underscore')
#
# class AzureDeployError extends Error
#
# class AzureDeploy
#
#   constructor: (@robot, env) ->
#     @env = env
#     @azureClientId = env.HUBOT_AZURE_DEPLOY_CLIENT_ID
#     @azureDomain = env.HUBOT_AZURE_DEPLOY_DOMAIN
#     @azureSecret = env.HUBOT_AZURE_DEPLOY_SECRET
#     @azureSubscriptionId = env.HUBOT_AZURE_DEPLOY_SUBSCRIPTION_ID
#     # storageLoaded = =>
#     #   @data = @robot.brain.data.phabricator ||= {
#     #     projects: { },
#     #     aliases: { }
#     #   }
#     #   @robot.logger.debug 'AzureDeploy Data Loaded: ' + JSON.stringify(@data, null, 2)
#     # @robot.brain.on 'loaded', storageLoaded
#     # storageLoaded() # just in case storage was loaded before we got here
#
#
#   ready: (msg) ->
#     msg.send 'Error: HUBOT_AZURE_DEPLOY_CLIENT_ID is not specified' if not @azureClientId
#     msg.send 'Error: HUBOT_AZURE_DEPLOY_DOMAIN is not specified' if not @azureDomain
#     msg.send 'Error: HUBOT_AZURE_DEPLOY_SECRET is not specified' if not @azureSecret
#     msg.send 'Error: HUBOT_AZURE_DEPLOY_SUBSCRIPTION_ID is not specified' if not @azureSubscriptionId
#     return false unless (@azureClientId and @azureDomain and @azureSecret and @azureSubscriptionId)
#     true
#
#
#   deployNewSiteSlot: (msg, azureOpts, deployOpts, cb) ->
#     msg.send 'Error: azureOpts.resourceGroupName is not specified' if not azureOpts.resourceGroupName
#     msg.send 'Error: azureOpts.webSiteDeplymentId is not specified' if not azureOpts.webSiteDeplymentId
#     msg.send 'Error: azureOpts.webSiteName is not specified' if not azureOpts.webSiteName
#     msg.send 'Error: azureOpts.webSiteSlot is not specified' if not azureOpts.webSiteSlot
#     msg.send 'Error: deployOpts.repoUrl is not specified' if not deployOpts.repoUrl
#     msg.send 'Error: deployOpts.branch is not specified' if not deployOpts.branch
#     return false unless (azureOpts.resourceGroupName and azureOpts.webSiteDeplymentId and azureOpts.webSiteName and azureOpts.webSiteSlot and deployOpts.repoUrl and deployOpts.branch)
#     if @ready(msg) is true
#       azureClientId = @azureClientId
#       azureSecret = @azureSecret
#       azureDomain = @azureDomain
#
#       azureResourceGroupName = azureOpts.resourceGroupName
#       azureWebSiteDeplymentId = azureOpts.webSiteDeplymentId
#       azureWebSiteName = azureOpts.webSiteName
#       azureWebSiteSlot = azureOpts.webSiteSlot
#
#       deployRepoUrl = deployOpts.repoUrl
#       deployBranch = deployOpts.branch
#       deployNoop = deployOpts.noop
#
#       siteConfig = {}
#       if deployOpts.hasOwnProperty('targetBranch')
#         siteConfig.appSettings =
#           TARGET_BRANCH: deployOpts.targetBranch
#           REQUIRES_GIT_OVERRIDE: true
#
#       @_newSiteSlot msg, azureClientId, azureSecret, azureDomain, azureResourceGroupName, azureWebSiteDeplymentId, azureWebSiteName, azureWebSiteSlot, deployRepoUrl, deployBranch, deployNoop, siteConfig, cb
#
#
#   _newSiteSlot: (msg, azureClientId, azureSecret, azureDomain, azureResourceGroupName, azureWebSiteDeplymentId, azureWebSiteName, azureWebSiteSlot, deployRepoUrl, deployBranch, deployNoop, siteConfig, cb) ->
#     msRestAzure.loginWithServicePrincipalSecret azureClientId, azureSecret, azureDomain, (err, credentials) ->
#       if err?
#           cb(err)
#           return
#       client = new webSiteManagementClient(credentials, azureSubscriptionId)
#       optionsopt = null
#       deployopt = null
#       client.sites.createDeploymentSlot azureResourceGroupName, azureWebSiteName, azureWebSiteDeplymentId, azureWebSiteSlot, deployopt, optionsopt, (err, result, request, response) ->
#         if err?
#           cb(err)
#           return
#         siteSourceControl =
#           repoUrl: deployRepoUrl
#           branch: deployBranch
#           isManualIntegration: true
#           deploymentRollbackEnabled: false
#           isMercurial: false
#         optionsopt = null
#         client.sites.updateSiteSourceControlSlot azureResourceGroupName, azureWebSiteName, siteSourceControl, azureWebSiteSlot, optionsopt, (err, result, request, response) ->
#           if err?
#             cb(err)
#             return
#           if Object.keys(siteConfig).length == 0
#             cb err, result
#           else
#             client.sites.getSiteConfigSlot azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) ->
#               result.appSettings = _.extend(result.appSettings, siteConfig.appSettings)
#               client.sites.createOrUpdateSiteConfigSlot azureResourceGroupName, azureWebSiteName, result, azureWebSiteSlot, optionsopt, (err, result, request, response) ->
#                 if err?
#                   cb(err)
#                   return
#                 client.sites.restartSiteSlot azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) ->
#                   if err?
#                     cb(err)
#                     return
#                   client.sites.syncSiteRepository azureResourceGroupName, azureWebSiteName, azureWebSiteSlot, (err, result, request, response) ->
#                     if err?
#                       cb(err)
#                       return
#                     cb err, result
#                     return true
#
# module.exports = AzureDeploy
