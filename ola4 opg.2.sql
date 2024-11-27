# opg 2.1

CREATE TABLE Cars (
  carid int NOT NULL,
  reg_date VARCHAR(20) NOT NULL,
  driven int NOT NULL,
  retail_id int NOT NULL,
  mrange int NOT NULL,
  make VARCHAR(4) NOT NULL,
  model VARCHAR(50) NOT NULL,
  doors smallint NOT NULL,
  PRIMARY KEY (carid)
);

CREATE TABLE Car_retailer (
  retailer VARCHAR(100) NOT NULL,
  retail_id int NOT NULL,
  street VARCHAR(100) NOT NULL,
  street_n VARCHAR(100) NOT NULL,
  zipcode int NOT NULL,
  city VARCHAR(100) NOT NULL,
  cvr int NOT NULL
);

CREATE TABLE Details(
  carid int NOT NULL,
  price int NOT NULL,
  scrapedate date NOT NULL,
  SOLD SMALLINT NOT NULL,
  linkid int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (linkid)
);

INSERT INTO Cars (carid, reg_date, driven, retail_id, mrange, make, model, doors)
SELECT carid, reg_date, driven, id, mrange, make, model, doors 
FROM nyebiler;

INSERT INTO Car_retailer (retailer, retail_id, street, street_n, zipcode, city, cvr)
SELECT forhandler, id, for_street, for_street_nr, for_postcode, for_city, cvr
FROM nyebiler;

INSERT INTO Details (carid, price, scrapedate, SOLD)
SELECT carid, price, scrape_date, solgt
FROM nyebiler;


# a) Nye records 
SELECT s.carid
FROM sim_df s
LEFT JOIN merged_df m ON s.carid = m.carid
WHERE m.carid IS NULL;

# b) Ændrede priser 
SELECT s.carid, s.price AS new_price, m.price AS old_price
FROM sim_df s
INNER JOIN merged_df m ON s.carid = m.carid
WHERE s.price != m.price;

# c) solgte 
SELECT m.*
FROM merged_df m
LEFT JOIN sim_df s ON m.carid = s.carid
WHERE s.carid IS NULL;