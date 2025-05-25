/*
 * Copyright 2020 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 */
package org.forgerock.openicf.connectors.realms

import static org.identityconnectors.framework.common.objects.AttributeInfo.Flags.*
import org.forgerock.openicf.connectors.groovy.ICFObjectBuilder
import org.forgerock.openicf.connectors.groovy.OperationType
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration
import org.identityconnectors.common.logging.Log

def operation = operation as OperationType
def configuration = configuration as ScriptedRESTConfiguration
def log = log as Log
def builder = builder as ICFObjectBuilder

log.info("REALMS SchemaScript, operation = ${operation.toString()}")

builder.schema({
    objectClass {
        type 'realms'
        attributes {
            _id String.class, NOT_UPDATEABLE
            _rev String.class, NOT_UPDATEABLE
            name String.class, REQUIRED, NOT_UPDATEABLE
            parentPath String.class, NOT_UPDATEABLE
            active Boolean.class
            aliases String.class, MULTIVALUED
            description String.class
            owner String.class
            status String.class
            created String.class, NOT_CREATABLE, NOT_UPDATEABLE
            lastModified String.class, NOT_CREATABLE, NOT_UPDATEABLE
        }
    }
})