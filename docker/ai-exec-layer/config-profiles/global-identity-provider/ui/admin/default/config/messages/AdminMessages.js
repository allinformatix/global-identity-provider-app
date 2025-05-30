"use strict";

/*
 * Copyright 2014-2023 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

define([], function () {

    var obj = {
        "connectorsNotAvailable": {
            msg: "config.messages.ConnectorMessages.connectorsNotAvailable",
            type: "error"
        },
        "connectorSaved": {
            msg: "config.messages.ConnectorMessages.connectorSaved",
            type: "info"
        },
        "newDashboardCreated": {
            msg: "config.messages.dashboardMessages.newDashboardCreated",
            type: "info"
        },
        "dashboardDeleted": {
            msg: "config.messages.dashboardMessages.dashboardDeleted",
            type: "info"
        },
        "dashboardDefaulted": {
            msg: "config.messages.dashboardMessages.dashboardDefaulted",
            type: "info"
        },
        "dashboardDuplicated": {
            msg: "config.messages.dashboardMessages.dashboardDuplicated",
            type: "info"
        },
        "dashboardRenamed": {
            msg: "config.messages.dashboardMessages.dashboardRenamed",
            type: "info"
        },
        "dashboardWidgetAdded": {
            msg: "config.messages.dashboardMessages.dashboardWidgetAdded",
            type: "info"
        },
        "dashboardWidgetsRearranged": {
            msg: "config.messages.dashboardMessages.dashboardWidgetsRearranged",
            type: "info"
        },
        "dashboardWidgetConfigurationSaved": {
            msg: "config.messages.dashboardMessages.dashboardWidgetConfigurationSaved",
            type: "info"
        },
        "objectTypeSaved": {
            msg: "config.messages.ConnectorMessages.objectTypeSaved",
            type: "info"
        },
        "objectTypeAdded": {
            msg: "config.messages.ConnectorMessages.objectTypeAdded",
            type: "info"
        },
        "objectTypeDeleted": {
            msg: "config.messages.ConnectorMessages.objectTypeDeleted",
            type: "info"
        },
        "advancedSaved": {
            msg: "config.messages.ConnectorMessages.advancedSaved",
            type: "info"
        },
        "liveSyncSaved": {
            msg: "config.messages.ConnectorMessages.liveSyncSaved",
            type: "info"
        },
        "connectorSaveFail": {
            msg: "config.messages.ConnectorMessages.connectorSaveFail",
            type: "error"
        },
        "connectorTestPass": {
            msg: "config.messages.ConnectorMessages.connectorTestPass",
            type: "info"
        },
        "connectorTestFailed": {
            msg: "config.messages.ConnectorMessages.connectorTestFailed",
            type: "error"
        },
        "deleteConnectorSuccess": {
            msg: "config.messages.ConnectorMessages.deleteConnectorSuccess",
            type: "info"
        },
        "deleteConnectorFail": {
            msg: "config.messages.ConnectorMessages.deleteConnectorFail",
            type: "error"
        },
        "connectorBadMainVersion": {
            msg: "config.messages.ConnectorMessages.connectorBadMainVersion",
            type: "error"
        },
        "connectorBadMinorVersion": {
            msg: "config.messages.ConnectorMessages.connectorBadMinorVersion",
            type: "error"
        },
        "connectorVersionChange": {
            msg: "config.messages.ConnectorMessages.connectorVersionChange",
            type: "info"
        },
        "deleteManagedSuccess": {
            msg: "config.messages.ManagedObjectMessages.deleteManagedSuccess",
            type: "info"
        },
        "deleteManagedFail": {
            msg: "config.messages.ManagedObjectMessages.deleteManagedFail",
            type: "error"
        },
        "managedObjectSaveSuccess": {
            msg: "config.messages.ManagedObjectMessages.saveSuccessful",
            type: "info"
        },
        "objectTypeLoaded": {
            msg: "config.messages.ObjectTypeMessages.objectSuccessfullyLoaded",
            type: "info"
        },
        "objectTypeFailedToLoad": {
            msg: "config.messages.ObjectTypeMessages.objectFailedToLoad",
            type: "error"
        },
        "authSaveSuccess": {
            msg: "config.messages.AuthenticationMessages.saveSuccessful",
            type: "info"
        },
        "mappingSaveSuccess": {
            msg: "config.messages.MappingMessages.mappingSaveSuccess",
            type: "info"
        },
        "newMappingAdded": {
            msg: "config.messages.MappingMessages.newMappingAdded",
            type: "info"
        },
        "mappingDeleted": {
            msg: "config.messages.MappingMessages.mappingDeleted",
            type: "info"
        },
        "mappingEvalError": {
            msg: "config.messages.MappingMessages.mappingEvalError",
            type: "error"
        },
        "invalidConditionFilter": {
            msg: "config.messages.MappingMessages.invalidConditionFilter",
            type: "error"
        },
        "syncPolicySaveSuccess": {
            msg: "config.messages.SyncMessages.policySaveSuccessful",
            type: "info"
        },
        "auditSaveSuccess": {
            msg: "config.messages.AuditMessages.auditSaveSuccessful",
            type: "info"
        },
        "scheduleCreated": {
            msg: "config.messages.SyncMessages.scheduleCreated",
            type: "info"
        },
        "scheduleSaved": {
            msg: "config.messages.SyncMessages.scheduleSaved",
            type: "info"
        },
        "livesyncSuccess": {
            msg: "config.messages.SyncMessages.livesyncSuccess",
            type: "info"
        },
        "scheduleSaveFailed": {
            msg: "config.messages.SyncMessages.scheduleSaveFailed",
            type: "error"
        },
        "scheduleDeleted": {
            msg: "config.messages.SyncMessages.scheduleDeleted",
            type: "info"
        },
        "scheduleExists": {
            msg: "config.messages.SyncMessages.scheduleExists",
            type: "error"
        },
        "scheduleDeletedFailed": {
            msg: "config.messages.SyncMessages.scheduleDeletedFailed",
            type: "error"
        },
        "syncLiveSyncSaveSuccess": {
            msg: "config.messages.SyncMessages.liveSyncSaved",
            type: "info"
        },
        "correlationQuerySaveSuccess": {
            msg: "config.messages.SyncMessages.correlationQuerySaved",
            type: "info"
        },
        "individualRecordValidationSaveSuccess": {
            msg: "config.messages.SyncMessages.individualRecordValidationSaveSuccess",
            type: "info"
        },
        "reconQueryFilterSaveSuccess": {
            msg: "config.messages.SyncMessages.reconQueryFilterSaveSuccess",
            type: "info"
        },
        "objectFiltersSaveSuccess": {
            msg: "config.messages.SyncMessages.objectFiltersSaved",
            type: "info"
        },
        "triggeredBySituationSaveSuccess": {
            msg: "config.messages.SyncMessages.triggeredBySituationSaved",
            type: "info"
        },
        "triggeredByReconSaveSuccess": {
            msg: "config.messages.SyncMessages.triggeredByReconSaved",
            type: "info"
        },
        "linkQualifierSaveSuccess": {
            msg: "config.messages.SyncMessages.linkQualifierSaveSuccess",
            type: "info"
        },
        "singleRecordReconSuccess": {
            msg: "config.messages.SyncMessages.singleRecordReconSuccess",
            type: "info"
        },
        "cancelActiveProcess": {
            msg: "config.messages.WorkflowMessages.cancelActiveProcess",
            type: "info"
        },
        "selfServiceSaveSuccess": {
            msg: "config.messages.settingMessages.saveSelfServiceSuccess",
            type: "info"
        },
        "consentSaveSuccess": {
            msg: "config.messages.settingMessages.consentSuccess",
            type: "info"
        },
        "workflowSettingsSaveSuccess": {
            msg: "config.messages.settingMessages.workflowSettingsSaveSuccess",
            type: "info"
        },
        "emailConfigSaveSuccess": {
            msg: "config.messages.settingMessages.saveEmailSuccess",
            type: "info"
        },
        "emailTemplateConfigSaveSuccess": {
            msg: "config.messages.email.emailTemplateConfigSaveSuccess",
            type: "info"
        },
        "amAuthWellKnownEndpointFailure": {
            msg: "config.messages.AuthMessages.amAuthWellKnownEndpointFailure",
            type: "error"
        },
        "selfServiceUserRegistrationSave": {
            msg: "config.messages.selfService.userRegistrationSave",
            type: "info"
        },
        "selfServiceUserRegistrationDelete": {
            msg: "config.messages.selfService.userRegistrationDelete",
            type: "error"
        },
        "selfServiceUsernameSave": {
            msg: "config.messages.selfService.usernameSave",
            type: "info"
        },
        "selfServiceUsernameDelete": {
            msg: "config.messages.selfService.usernameDelete",
            type: "error"
        },
        "selfServicePasswordSave": {
            msg: "config.messages.selfService.passwordSave",
            type: "info"
        },
        "selfServicePasswordDelete": {
            msg: "config.messages.selfService.passwordDelete",
            type: "error"
        },
        "assignmentSaveSuccess": {
            msg: "config.messages.assignmentMessages.saveSuccess",
            type: "info"
        },
        "deleteAssignmentSuccess": {
            msg: "config.messages.assignmentMessages.deleteAssignmentSuccess",
            type: "info"
        },
        "deleteAssignmentFail": {
            msg: "config.messages.assignmentMessages.deleteAssignmentFail",
            type: "error"
        },
        "saveSocialProvider": {
            msg: "config.messages.socialProviders.save",
            type: "info"
        },
        "deleteSocialProvider": {
            msg: "config.messages.socialProviders.delete",
            type: "error"
        },
        "progressiveProfileFormSaveSuccess": {
            msg: "config.messages.selfService.progressiveProfileFormSaveSuccess",
            type: "info"
        },
        "progressiveProfileFormRemoved": {
            msg: "config.messages.selfService.progressiveProfileFormRemoved",
            type: "info"
        },
        "progressiveProfileFormOrderChanged": {
            msg: "config.messages.selfService.progressiveProfileFormOrderChanged",
            type: "info"
        },
        "termsAndConditionsSaveSuccess": {
            msg: "config.messages.selfService.termsAndConditionsSaveSuccess",
            type: "info"
        },
        "termsAndConditionsDeleteSuccess": {
            msg: "config.messages.selfService.termsAndConditionsDeleteSuccess",
            type: "error"
        },
        "termsAndConditionsAddFailure": {
            msg: "config.messages.selfService.termsAndConditionsAddFailure",
            type: "error"
        },
        "kbaQuestionsSave": {
            msg: "config.messages.selfService.kbaQuestionsSaveSuccess",
            type: "info"
        },
        "kbaUpdateCreate": {
            msg: "config.messages.selfService.kbaUpdateCreateSuccess",
            type: "info"
        },
        "kbaUpdateSave": {
            msg: "config.messages.selfService.kbaUpdateSaveSuccess",
            type: "info"
        },
        "kbaUpdateDelete": {
            msg: "config.messages.selfService.kbaUpdateDeleteSuccess",
            type: "error"
        },
        "managedConfigInvalidScript": {
            msg: "config.messages.ManagedObjectMessages.invalidScript",
            type: "error"
        },
        "singleResourceCollectionOnly": {
            msg: "config.messages.ManagedObjectMessages.singleResourceCollectionOnly",
            type: "error"
        },
        "noAvailableLdapAttribute": {
            msg: "config.messages.ManagedObjectMessages.noAvailableLdapAttribute",
            type: "error"
        }
    };

    return obj;
});
