CREATE TABLE Nodes (id serial NOT NULL PRIMARY KEY,
                                               Name VARCHAR(10));


CREATE TABLE EdgeClass (id serial NOT NULL PRIMARY KEY,
                                                   class VARCHAR(100));


CREATE TABLE Edge_value (id serial NOT NULL PRIMARY KEY,
                                                    AADT int);


CREATE TABLE Edge (id serial NOT NULL PRIMARY KEY,
                                              class int, startPoint int, endPoint int, length int,
                   foreign key (class) references edgeClass(id),
                   foreign key (startPoint) references Nodes(id),
                   foreign key (endPoint) references Nodes(id));

COPY Nodes
FROM '/Users/user/Documents/GisticResearch/AADT/Nodes.csv'
DELIMITER ',' CSV HEADER;

COPY Edge
FROM '/Users/user/Documents/GisticResearch/AADT/Edge.csv'
DELIMITER ',' CSV HEADER;

COPY edgeClass
FROM '/Users/user/Documents/GisticResearch/AADT/Edge_class.csv'
DELIMITER ',' CSV HEADER;

COPY edge_value
FROM '/Users/user/Documents/GisticResearch/AADT/Edge_value.csv'
DELIMITER ',' CSV HEADER;