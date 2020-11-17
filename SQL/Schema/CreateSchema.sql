CREATE SCHEMA IF NOT EXISTS aadt;
DROP TABLE IF EXISTS edge_values;
DROP TABLE IF EXISTS edge_values_cal;
DROP TABLE IF EXISTS edges;
DROP TABLE IF EXISTS edge_types;
DROP TABLE IF EXISTS nodes;
CREATE TABLE aadt.nodes (
    nod_id SERIAL NOT NULL PRIMARY KEY,
    nod_name varchar(50)
);
CREATE TABLE aadt.edge_types (
    egt_id SERIAL NOT NULL,
    egt_types varchar(100),
    egt_weight int primary key
);
CREATE TABLE aadt.edges (
    edg_id SERIAL NOT NULL PRIMARY KEY,
    edg_egt_weight int,
    edg_nod_id_start int,
    edg_nod_id_end int,
    edg_length int,
    FOREIGN KEY (edg_egt_weight) REFERENCES aadt.edge_types (egt_weight),
    FOREIGN KEY (edg_nod_id_start) REFERENCES aadt.Nodes (nod_id),
    FOREIGN KEY (edg_nod_id_end) REFERENCES aadt.Nodes (nod_id)
);
CREATE TABLE aadt.edge_values (
    egv_id serial not null primary key,
    egv_edg_id int,
    egv_aadt int,
    FOREIGN KEY (egv_edg_id) REFERENCES aadt.edges (edg_id)
);
CREATE TABLE aadt.edge_values_cal(
    evc_id serial not null primary key,
    evc_edg_id_target INT,
    evc_target_start INT,
    evc_target_end INT,
    evc_target_weight INT,
    evc_target_aadt INT,
    evc_edg_id_source INT,
    evc_edg_id_source_start INT,
    evc_edg_id_source_end INT,
    evc_source_aadt INT,
    evc_flag BOOLEAN,
    FOREIGN KEY (evc_edg_id_target) REFERENCES aadt.edges (edg_id),
    FOREIGN KEY (evc_edg_id_source) REFERENCES aadt.edges (edg_id)
);