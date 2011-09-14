-- seed data for integration tests

DROP TABLE IF EXISTS numeric_types_basics;
CREATE TABLE numeric_types_basics (
  id int,
	f_tinyint TINYINT,
	f_tinyint_u TINYINT UNSIGNED,
	f_smallint SMALLINT,
	f_smallint_u SMALLINT UNSIGNED,
	f_mediumint MEDIUMINT,
	f_mediumint_u MEDIUMINT UNSIGNED,
	f_int INT,
	f_int_u INT UNSIGNED,
	f_integer INTEGER,
	f_integer_u INTEGER UNSIGNED,
	f_bigint BIGINT,
	f_bigint_u BIGINT UNSIGNED,
	f_real REAL,
	f_double DOUBLE,
	f_float FLOAT,
	f_float_u FLOAT UNSIGNED,
	f_decimal DECIMAL,
	f_numeric NUMERIC
);

INSERT INTO numeric_types_basics VALUES
( 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19),
( 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
( 3,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23),
( 4, -128,   0,-32768,     0,-8388608,        0,-2147483648,          0,-2147483648,          0,-9223372036854775808,                    0, 1, 1, 1, 1, 1, 1),
( 5,  127, 255, 32767, 65535, 8388607, 16777215, 2147483647, 4294967295, 2147483647, 4294967295, 9223372036854775807, 18446744073709551615, 1, 1, 1, 1, 1, 1);



DROP TABLE IF EXISTS basic_autoincrement;
CREATE TABLE basic_autoincrement (
  auto_id INT(11) NOT NULL AUTO_INCREMENT,
	auto_dummy INT,
	PRIMARY KEY (auto_id)
);

INSERT INTO basic_autoincrement(auto_dummy) VALUES
(1),(2),(23);

-- see GH#22 float conversion error
DROP TABLE IF EXISTS numeric_type_floats;
CREATE TABLE numeric_type_floats (
 latitude FLOAT,
 longitude FLOAT
);

INSERT INTO numeric_type_floats(latitude,longitude) VALUES
(1.1,2.2);

-- see GH#18 smallint error
DROP TABLE IF EXISTS gh18_smallint;
CREATE TABLE gh18_smallint (
 s_smallint SMALLINT,
 u_smallint SMALLINT UNSIGNED
);

INSERT INTO gh18_smallint(s_smallint,u_smallint) VALUES
(-32768,32767),
(-1,0),
(32767,65535);

-- see https://github.com/maxlapshin/mysql2postgres/issues/27
DROP TABLE IF EXISTS test_boolean_conversion;
CREATE TABLE test_boolean_conversion (
  test_name VARCHAR(25),
  bit_1 BIT(1),
  tinyint_1 TINYINT(1),
  bit_1_default_0 BIT(1) DEFAULT 0,
  bit_1_default_1 BIT(1) DEFAULT 1,
  tinyint_1_default_0 TINYINT(1) DEFAULT 0,
  tinyint_1_default_1 TINYINT(1) DEFAULT 1,
  tinyint_1_default_2 TINYINT(1) DEFAULT 2 -- Test the fact that 1 byte isn't limited to [0,1]
);

INSERT INTO test_boolean_conversion (test_name, bit_1, tinyint_1)
VALUES ('test-null', NULL, NULL),
       ('test-false', 0, 0),
       ('test-true', 1, 1);
INSERT INTO test_boolean_conversion (test_name, tinyint_1) VALUES ('test-true-nonzero', 2);

CREATE OR REPLACE VIEW test_view AS
SELECT b.test_name
FROM test_boolean_conversion b;

DROP TABLE IF EXISTS test_null_conversion;
CREATE TABLE test_null_conversion (column_a VARCHAR(10));
INSERT INTO test_null_conversion (column_a) VALUES (NULL);

DROP TABLE IF EXISTS test_datetime_conversion;
CREATE TABLE test_datetime_conversion (column_a DATETIME);
INSERT INTO test_datetime_conversion (column_a) VALUES ('0000-00-00 00:00');

DROP TABLE IF EXISTS test_index_conversion;
CREATE TABLE test_index_conversion (column_a VARCHAR(10));
CREATE UNIQUE INDEX test_index_conversion ON test_index_conversion (column_a);

DROP TABLE IF EXISTS test_foreign_keys_child;
DROP TABLE IF EXISTS test_foreign_keys_parent;
CREATE TABLE test_foreign_keys_parent (id INT NOT NULL, PRIMARY KEY (id)) ENGINE=INNODB;
CREATE TABLE test_foreign_keys_child (id INT, test_foreign_keys_parent_id INT,
	INDEX par_ind (test_foreign_keys_parent_id),
	FOREIGN KEY (test_foreign_keys_parent_id) REFERENCES test_foreign_keys_parent(id) ON DELETE CASCADE
) ENGINE=INNODB;
