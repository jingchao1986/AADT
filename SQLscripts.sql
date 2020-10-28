DROP TABLE IF EXISTS edge_values;
DROP TABLE IF EXISTS edges;
DROP TABLE if EXISTS nodes;
DROP TABLE IF EXISTS edge_types;

CREATE TABLE nodes (
    nod_id SERIAL NOT NULL PRIMARY KEY,
    nod_name varchar(50)
);

CREATE TABLE edge_types (
    egt_id SERIAL NOT NULL PRIMARY KEY,
    egt_type varchar(100),
    egt_weight int
);

CREATE TABLE edges (
    edg_id SERIAL NOT NULL PRIMARY KEY,
    edg_egt_id int,
    edg_nod_id_start int,
    edg_nod_id_end int,
    edg_length int,
    FOREIGN KEY (edg_egt_id) REFERENCES edge_types (egt_id),
    FOREIGN KEY (edg_nod_id_start) REFERENCES Nodes (nod_id),
    FOREIGN KEY (edg_nod_id_end) REFERENCES Nodes (nod_id)
);

CREATE TABLE edge_values (
    egv_id serial not null primary key,
    egv_edg_id int,
    egv_aadt int,
    FOREIGN KEY (egv_edg_id) REFERENCES edges (edg_id)
);

INSERT INTO nodes (nod_id, nod_name) VALUES
(1,'A'),
(2,'B'),
(3,'C'),
(4,'D'),
(5,'E'),
(6,'F'),
(7,'G'),
(8,'H'),
(9,'I'),
(10,'J'),
(11,'K'),
(12,'L'),
(13,'M'),
(14,'N'),
(15,'i'),
(16,'P'),
(17,'Q'),
(18,'R'),
(19,'S'),
(20,'T'),
(21,'U'),
(22,'V'),
(23,'W'),
(24,'X'),
(25,'Y'),
(26,'Z'),
(27,'aa'),
(28,'ab')
;

INSERT INTO edge_types (egt_id, egt_type, egt_weight) VALUES
(1,'arterial',10),
(2,'collector',1)
;

INSERT INTO edges(edg_id,edg_egt_id,edg_nod_id_start,edg_nod_id_end,edg_length) VALUES	
(1,1,1,2,166),	
(2,2,2,10,166),	
(3,1,10,9,166),	
(4,1,9,15,166),	
(5,1,15,21,166),	
(6,1,21,22,166),	
(7,1,22,26,166),	
(8,1,2,6,166),	
(9,1,6,4,166),	
(10,1,4,5,166),	
(11,1,2,3,166),	
(12,2,11,12,166),	
(13,2,10,11,166),	
(14,2,11,14,166),	
(15,1,13,14,166),	
(16,1,9,14,166),	
(17,2,14,28,166),	
(18,1,8,9,166),	
(19,1,7,8,166),	
(20,1,4,7,166),	
(21,1,7,18,166),	
(22,1,18,19,166),	
(23,2,19,25,166),	
(24,2,6,8,166),	
(25,2,8,16,166),	
(26,2,16,17,166),	
(27,2,17,20,166),	
(28,1,18,17,166),	
(29,1,17,21,166),	
(30,1,21,24,166),	
(31,1,24,27,166),	
(32,2,24,23,166),	
(33,2,22,23,166),	
(34,2,20,22,166),	
(35,2,19,20,166),	
(36,2,16,15,166);	

INSERT INTO edge_values (egv_id, egv_edg_id,egv_aadt) VALUES
(1,2,35000),
(2,6,42000),
(3,18,32000),
(4,21,28000)
;