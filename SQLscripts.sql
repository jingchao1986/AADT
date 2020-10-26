CREATE TABLE Nodes (id serial NOT NULL PRIMARY KEY,
                                               Name VARCHAR(10));


CREATE TABLE EdgeClass (id serial NOT NULL PRIMARY KEY,
                                                   class VARCHAR(100));


CREATE TABLE Edge (id serial NOT NULL PRIMARY KEY,
                                              class int, startPoint int, endPoint int, length int,
                   foreign key (class) references edgeClass(id),
                   foreign key (startPoint) references Nodes(id),
                   foreign key (endPoint) references Nodes(id));

