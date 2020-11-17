--liquibase formatted sql

--changeset Zhoujc:20201117-1
--preconditions onFail:CONTINUE onError:HALT
--Create tables and insert initial values.
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

INSERT INTO aadt.nodes (nod_id, nod_name)
VALUES (1, 'A'),
    (2, 'B'),
    (3, 'C'),
    (4, 'D'),
    (5, 'E'),
    (6, 'F'),
    (7, 'G'),
    (8, 'H'),
    (9, 'I'),
    (10, 'J'),
    (11, 'K'),
    (12, 'L'),
    (13, 'M'),
    (14, 'N'),
    (15, 'O'),
    (16, 'P'),
    (17, 'Q'),
    (18, 'R'),
    (19, 'S'),
    (20, 'T'),
    (21, 'U'),
    (22, 'V'),
    (23, 'W'),
    (24, 'X'),
    (25, 'Y'),
    (26, 'Z'),
    (27, 'aa'),
    (28, 'ab');
INSERT INTO aadt.edge_types (egt_id, egt_types, egt_weight)
VALUES (1, 'arterial', 10),
    (2, 'collector', 1);
INSERT INTO aadt.edges(
        edg_id,
        edg_egt_weight,
        edg_nod_id_start,
        edg_nod_id_end,
        edg_length
    )
VALUES (1, 10, 1, 2, 166),
    (
        2,
        10,
        2,
        10,
        166
    ),
    (
        3,
        10,
        10,
        9,
        166
    ),
    (
        4,
        10,
        9,
        15,
        166
    ),
    (
        5,
        10,
        15,
        21,
        166
    ),
    (
        6,
        10,
        21,
        22,
        166
    ),
    (
        7,
        10,
        22,
        26,
        166
    ),
    (
        8,
        10,
        2,
        6,
        166
    ),
    (
        9,
        10,
        6,
        4,
        166
    ),
    (
        10,
        10,
        4,
        5,
        166
    ),
    (
        11,
        10,
        2,
        3,
        166
    ),
    (
        12,
        1,
        11,
        12,
        166
    ),
    (
        13,
        1,
        10,
        11,
        166
    ),
    (
        14,
        1,
        11,
        14,
        166
    ),
    (
        15,
        10,
        13,
        14,
        166
    ),
    (
        16,
        10,
        9,
        14,
        166
    ),
    (
        17,
        1,
        14,
        28,
        166
    ),
    (
        18,
        10,
        8,
        9,
        166
    ),
    (
        19,
        10,
        7,
        8,
        166
    ),
    (
        20,
        10,
        4,
        7,
        166
    ),
    (
        21,
        10,
        7,
        18,
        166
    ),
    (
        22,
        10,
        18,
        19,
        166
    ),
    (
        23,
        1,
        19,
        25,
        166
    ),
    (
        24,
        1,
        6,
        8,
        166
    ),
    (
        25,
        1,
        8,
        16,
        166
    ),
    (
        26,
        1,
        16,
        17,
        166
    ),
    (
        27,
        1,
        17,
        20,
        166
    ),
    (
        28,
        10,
        18,
        17,
        166
    ),
    (
        29,
        10,
        17,
        21,
        166
    ),
    (
        30,
        10,
        21,
        24,
        166
    ),
    (
        31,
        10,
        24,
        27,
        166
    ),
    (
        32,
        1,
        24,
        23,
        166
    ),
    (
        33,
        1,
        22,
        23,
        166
    ),
    (
        34,
        1,
        20,
        22,
        166
    ),
    (
        35,
        1,
        19,
        20,
        166
    ),
    (
        36,
        1,
        16,
        15,
        166
    );
INSERT INTO aadt.edge_values (egv_id, egv_edg_id, egv_aadt)
VALUES (1, 2, 35000),
    (2, 6, 42000),
    (3, 18, 32000),
    (4, 21, 28000);
