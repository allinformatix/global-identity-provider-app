-- Erstelle die Datenbank nur, wenn sie noch nicht existiert
CREATE DATABASE ai_exec_layer;

CREATE USER ai_exec_layer_repo_user WITH PASSWORD 'changeme';
-- Optional Rechte zuweisen:
GRANT ALL PRIVILEGES ON DATABASE ai_exec_layer TO ai_exec_layer_repo_user;

-- Verbinde dich zur Datenbank
\connect ai_exec_layer

DROP SCHEMA IF EXISTS ai_exec_layer CASCADE;
CREATE SCHEMA ai_exec_layer AUTHORIZATION ai_exec_layer_repo_user;

-- -----------------------------------------------------
-- Table ai_exec_layer.objecttypes
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.objecttypes (
  id BIGSERIAL NOT NULL,
  objecttype VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT idx_objecttypes_objecttype UNIQUE (objecttype)
);



-- -----------------------------------------------------
-- Table ai_exec_layer.genericobjects
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.genericobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_genericobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_genericobjects_object UNIQUE (objecttypes_id, objectid)
);
CREATE INDEX idx_genericobjects_reconid on ai_exec_layer.genericobjects (jsonb_extract_path_text(fullobject, 'reconId'), objecttypes_id);


-- -----------------------------------------------------
-- Table ai_exec_layer.managedobjects
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.managedobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_managedobjects_objectypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_managedobjects_object ON ai_exec_layer.managedobjects (objecttypes_id,objectid);
CREATE INDEX idx_managedobjects_objecttypes ON ai_exec_layer.managedobjects (objecttypes_id);
-- Note that the next two indices apply only to role objects, as only role objects have a condition or temporalConstraints
CREATE INDEX idx_json_managedobjects_roleCondition ON ai_exec_layer.managedobjects
    ( jsonb_extract_path_text(fullobject, 'condition') );
CREATE INDEX idx_json_managedobjects_roleTemporalConstraints ON ai_exec_layer.managedobjects
    ( jsonb_extract_path_text(fullobject, 'temporalConstraints') );


-- -----------------------------------------------------
-- Table ai_exec_layer.configobjects
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.configobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_configobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_configobjects_object ON ai_exec_layer.configobjects (objecttypes_id,objectid);
CREATE INDEX fk_configobjects_objecttypes ON ai_exec_layer.configobjects (objecttypes_id);


-- -----------------------------------------------------
-- Table ai_exec_layer.notificationobjects
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.notificationobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_notificationobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_notificationobjects_object ON ai_exec_layer.notificationobjects (objecttypes_id,objectid);
CREATE INDEX fk_notificationobjects_objecttypes ON ai_exec_layer.notificationobjects (objecttypes_id);


-- -----------------------------------------------------
-- Table ai_exec_layer.relationships
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.relationships (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  firstresourcecollection VARCHAR(255),
  firstresourceid VARCHAR(56),
  firstpropertyname VARCHAR(100),
  secondresourcecollection VARCHAR(255),
  secondresourceid VARCHAR(56),
  secondpropertyname VARCHAR(100),
  PRIMARY KEY (id),
  CONSTRAINT fk_relationships_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_relationships_object UNIQUE (objectid)
);
CREATE INDEX idx_relationships_first_object ON ai_exec_layer.relationships ( firstresourcecollection, firstresourceid, firstpropertyname );
CREATE INDEX idx_relationships_second_object ON ai_exec_layer.relationships ( secondresourcecollection, secondresourceid, secondpropertyname );
CREATE INDEX idx_relationships_originfirst ON ai_exec_layer.relationships (firstresourceid , firstresourcecollection , firstpropertyname , secondresourceid , secondresourcecollection );
CREATE INDEX idx_relationships_originsecond ON ai_exec_layer.relationships (secondresourceid , secondresourcecollection , secondpropertyname , firstresourceid , firstresourcecollection );

-- -----------------------------------------------------
-- Table ai_exec_layer.links
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.links (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  linktype VARCHAR(255) NOT NULL,
  linkqualifier VARCHAR(50) NOT NULL,
  firstid VARCHAR(255) NOT NULL,
  secondid VARCHAR(255) NOT NULL,
  PRIMARY KEY (objectid)
);

CREATE UNIQUE INDEX idx_links_first ON ai_exec_layer.links (linktype, linkqualifier, firstid);
CREATE UNIQUE INDEX idx_links_second ON ai_exec_layer.links (linktype, linkqualifier, secondid);
CREATE INDEX idx_links_firstid ON ai_exec_layer.links (firstid);
CREATE INDEX idx_links_secondid ON ai_exec_layer.links (secondid);

-- -----------------------------------------------------
-- Table ai_exec_layer.internaluser
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.internaluser (
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  pwd VARCHAR(510) DEFAULT NULL,
  PRIMARY KEY (objectid)
);


-- -----------------------------------------------------
-- Table ai_exec_layer.internalrole
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.internalrole (
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  name VARCHAR(64) DEFAULT NULL,
  description VARCHAR(510) DEFAULT NULL,
  temporalConstraints VARCHAR(1024) DEFAULT NULL,
  condition VARCHAR(1024) DEFAULT NULL,
  privs TEXT DEFAULT NULL,
  PRIMARY KEY (objectid)
);


-- -----------------------------------------------------
-- Table ai_exec_layer.schedulerobjects
-- -----------------------------------------------------
CREATE TABLE ai_exec_layer.schedulerobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_schedulerobjects_objectypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_schedulerobjects_object ON ai_exec_layer.schedulerobjects (objecttypes_id,objectid);
CREATE INDEX fk_schedulerobjects_objectypes ON ai_exec_layer.schedulerobjects (objecttypes_id);


-- -----------------------------------------------------
-- Table ai_exec_layer.uinotification
-- -----------------------------------------------------
CREATE TABLE ai_exec_layer.uinotification (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  notificationType VARCHAR(255) NOT NULL,
  createDate VARCHAR(38) NOT NULL,
  message TEXT NOT NULL,
  requester VARCHAR(255) NULL,
  receiverId VARCHAR(255) NOT NULL,
  requesterId VARCHAR(255) NULL,
  notificationSubtype VARCHAR(255) NULL,
  PRIMARY KEY (objectid)
);
CREATE INDEX idx_uinotification_receiverId ON ai_exec_layer.uinotification (receiverId);


-- -----------------------------------------------------
-- Table ai_exec_layer.clusterobjects
-- -----------------------------------------------------
CREATE TABLE ai_exec_layer.clusterobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_clusterobjects_objectypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_clusterobjects_object ON ai_exec_layer.clusterobjects (objecttypes_id,objectid);
CREATE INDEX fk_clusterobjects_objectypes ON ai_exec_layer.clusterobjects (objecttypes_id);

CREATE INDEX idx_jsonb_clusterobjects_timestamp ON ai_exec_layer.clusterobjects ( jsonb_extract_path_text(fullobject, 'timestamp') );
CREATE INDEX idx_jsonb_clusterobjects_state ON ai_exec_layer.clusterobjects ( jsonb_extract_path_text(fullobject, 'state') );
CREATE INDEX idx_jsonb_clusterobjects_event_instanceid ON ai_exec_layer.clusterobjects ( jsonb_extract_path_text(fullobject, 'type'), jsonb_extract_path_text(fullobject, 'instanceId') );

-- -----------------------------------------------------
-- Table ai_exec_layer.clusteredrecontargetids
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.clusteredrecontargetids (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  reconid VARCHAR(255) NOT NULL,
  targetids JSONB NOT NULL,
  PRIMARY KEY (objectid)
);

CREATE INDEX idx_clusteredrecontargetids_reconid ON ai_exec_layer.clusteredrecontargetids (reconid);

-- -----------------------------------------------------
-- Table ai_exec_layer.updateobjects
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.updateobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_updateobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_updateobjects_object UNIQUE (objecttypes_id, objectid)
);


-- -----------------------------------------------------
-- Table ai_exec_layer.importobjects
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.importobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_importobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_importobjects_object UNIQUE (objecttypes_id, objectid)
);


-- -----------------------------------------------------
-- Table ai_exec_layer.syncqueue
-- -----------------------------------------------------
CREATE TABLE ai_exec_layer.syncqueue (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  syncAction VARCHAR(38) NOT NULL,
  resourceCollection VARCHAR(38) NOT NULL,
  resourceId VARCHAR(255) NOT NULL,
  mapping VARCHAR(255) NOT NULL,
  objectRev VARCHAR(38) DEFAULT NULL,
  oldObject JSONB,
  newObject JSONB,
  context JSONB,
  state VARCHAR(38) NOT NULL,
  nodeId VARCHAR(255) DEFAULT NULL,
  createDate VARCHAR(255) NOT NULL,
  PRIMARY KEY (objectid)
);
CREATE INDEX indx_syncqueue_mapping_state_createdate ON ai_exec_layer.syncqueue (mapping, state, createDate);


-- -----------------------------------------------------
-- Table ai_exec_layer.locks
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.locks (
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  nodeid VARCHAR(255),
  PRIMARY KEY (objectid)
);

CREATE INDEX idx_locks_nodeid ON ai_exec_layer.locks (nodeid);


-- -----------------------------------------------------
-- Table ai_exec_layer.files
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.files (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  content TEXT,
  PRIMARY KEY (objectid)
);


-- -----------------------------------------------------
-- Table ai_exec_layer.metaobjects
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.metaobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_metaobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES ai_exec_layer.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_metaobjects_object UNIQUE (objecttypes_id, objectid)
);
CREATE INDEX idx_metaobjects_reconid on ai_exec_layer.metaobjects (jsonb_extract_path_text(fullobject, 'reconId'), objecttypes_id);

-- -----------------------------------------------------
-- Table ai_exec_layer.reconassoc
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.reconassoc (
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  mapping VARCHAR(255) NOT NULL,
  sourceResourceCollection VARCHAR(255) NOT NULL,
  targetResourceCollection VARCHAR(255) NOT NULL,
  isAnalysis VARCHAR(5) NOT NULL,
  finishTime VARCHAR(38) NULL,
  PRIMARY KEY (objectid)
);
CREATE INDEX idx_reconassoc_mapping ON ai_exec_layer.reconassoc (mapping);
CREATE INDEX idx_reconassoc_reconId ON ai_exec_layer.reconassoc (objectid);

-- -----------------------------------------------------
-- Table ai_exec_layer.reconassocentry
-- -----------------------------------------------------

CREATE TABLE ai_exec_layer.reconassocentry (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  reconId VARCHAR(255) NOT NULL,
  situation VARCHAR(38) NULL,
  action VARCHAR(38) NULL,
  phase VARCHAR(38) NULL,
  linkQualifier VARCHAR(38) NOT NULL,
  sourceObjectId VARCHAR(255) NULL,
  targetObjectId VARCHAR(255) NULL,
  status VARCHAR(38) NOT NULL,
  exception TEXT NULL,
  message TEXT NULL,
  messagedetail TEXT NULL,
  ambiguousTargetObjectIds TEXT NULL,
  PRIMARY KEY (objectid),
  CONSTRAINT fk_reconassocentry_reconassoc_id FOREIGN KEY (reconId) REFERENCES ai_exec_layer.reconassoc (objectid) ON DELETE CASCADE ON UPDATE NO ACTION
);
CREATE INDEX idx_reconassocentry_situation ON ai_exec_layer.reconassocentry (situation);

-- -----------------------------------------------------
-- View ai_exec_layer.reconassocentryview
-- -----------------------------------------------------
CREATE VIEW ai_exec_layer.reconassocentryview AS
  SELECT
    assoc.objectid as reconId,
    assoc.mapping as mapping,
    assoc.sourceResourceCollection as sourceResourceCollection,
    assoc.targetResourceCollection as targetResourceCollection,
    entry.objectid AS objectid,
    entry.rev AS rev,
    entry.action AS action,
    entry.situation AS situation,
    entry.linkQualifier as linkQualifier,
    entry.sourceObjectId as sourceObjectId,
    entry.targetObjectId as targetObjectId,
    entry.status as status,
    entry.exception as exception,
    entry.message as message,
    entry.messagedetail as messagedetail,
    entry.ambiguousTargetObjectIds as ambiguousTargetObjectIds
  FROM ai_exec_layer.reconassocentry entry, ai_exec_layer.reconassoc assoc
  WHERE assoc.objectid = entry.reconid;

-- -----------------------------------------------------
-- Table ai_exec_layer.relationshipresources
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ai_exec_layer.relationshipresources (
  id VARCHAR(255) NOT NULL,
  originresourcecollection VARCHAR(255) NOT NULL,
  originproperty VARCHAR(100) NOT NULL,
  refresourcecollection VARCHAR(255) NOT NULL,
  originfirst BOOL NOT NULL,
  reverseproperty VARCHAR(100),
  PRIMARY KEY ( originresourcecollection, originproperty, refresourcecollection, originfirst ));

-- -----------------------------------------------------
-- Set permissions
-- -----------------------------------------------------

DO $$
DECLARE
    tbl RECORD;
BEGIN
    FOR tbl IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'ai_exec_layer'
    LOOP
        EXECUTE format(
            'ALTER TABLE ai_exec_layer.%I OWNER TO ai_exec_layer_repo_user;',
            tbl.tablename
        );
    END LOOP;
END $$;

DO $$
DECLARE
    seq RECORD;
BEGIN
    FOR seq IN
        SELECT sequencename
        FROM pg_sequences
        WHERE schemaname = 'ai_exec_layer'
    LOOP
        EXECUTE format(
            'ALTER SEQUENCE ai_exec_layer.%I OWNER TO ai_exec_layer_repo_user;',
            seq.sequencename
        );
    END LOOP;
END $$;

DO $$
DECLARE
    v RECORD;
BEGIN
    FOR v IN
        SELECT table_name
        FROM information_schema.views
        WHERE table_schema = 'ai_exec_layer'
    LOOP
        EXECUTE format(
            'ALTER VIEW ai_exec_layer.%I OWNER TO ai_exec_layer_repo_user;',
            v.table_name
        );
    END LOOP;
END $$;
