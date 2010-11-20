-- seed data for integration tests

DROP TABLE IF EXISTS numeric_types_basics;
CREATE TABLE numeric_types_basics (
  id int,
	f_tinyint TINYINT,
	f_smallint SMALLINT,
	f_mediumint MEDIUMINT,
	f_int INT,
	f_integer INTEGER,
	f_bigint BIGINT,
	f_real REAL,
	f_double DOUBLE,
	f_float FLOAT,
	f_ufloat FLOAT UNSIGNED,
	f_decimal DECIMAL,
	f_numeric NUMERIC
);

INSERT INTO numeric_types_basics VALUES
(1,1,1,1,1,1,1,1,1,1,1,1,1),
(2,2,2,2,2,2,2,2,2,2,2,2,2),
(23,23,23,23,23,23,23,23,23,23,23,23,23);


DROP TABLE IF EXISTS basic_autoincrement;
CREATE TABLE basic_autoincrement (
  auto_id INT(11) NOT NULL AUTO_INCREMENT,
	auto_dummy INT,
	PRIMARY KEY (auto_id)
);

INSERT INTO basic_autoincrement(auto_dummy) VALUES
(1),(2),(23);

DROP TABLE IF EXISTS numeric_type_floats;
CREATE TABLE numeric_type_floats (
 latitude FLOAT,
 longitude FLOAT
);

INSERT INTO numeric_type_floats(latitude,longitude) VALUES
(1.1,2.2);
