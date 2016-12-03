DROP DATABASE IF EXISTS rDNS;
CREATE DATABASE rDNS;
GRANT ALL PRIVILEGES ON rDNS.* TO 'rDNS'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON rDNS.* TO 'rDNS'@localhost IDENTIFIED by 'password';
DELETE FROM mysql.user WHERE user ='';
USE rDNS;

CREATE TABLE domains (
  id                    INT NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  master                VARCHAR(128) DEFAULT NULL,
  last_check            INT DEFAULT NULL,
  type                  VARCHAR(6) NOT NULL,
  notified_serial       INT DEFAULT NULL,
  account               VARCHAR(40) DEFAULT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE UNIQUE INDEX name_index ON domains(name);


CREATE TABLE records (
  id                    INT AUTO_INCREMENT,
  domain_id             INT DEFAULT NULL,
  name                  VARCHAR(255) DEFAULT NULL,
  type                  VARCHAR(10) DEFAULT NULL,
  content               VARCHAR(64000) DEFAULT NULL,
  ttl                   INT DEFAULT NULL,
  prio                  INT DEFAULT NULL,
  change_date           INT DEFAULT NULL,
  disabled              TINYINT(1) DEFAULT 0,
  ordername             VARCHAR(255) BINARY DEFAULT NULL,
  auth                  TINYINT(1) DEFAULT 1,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);
CREATE INDEX recordorder ON records (domain_id, ordername);


CREATE TABLE supermasters (
  ip                    VARCHAR(64) NOT NULL,
  nameserver            VARCHAR(255) NOT NULL,
  account               VARCHAR(40) NOT NULL,
  PRIMARY KEY (ip, nameserver)
) Engine=InnoDB;


CREATE TABLE comments (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) NOT NULL,
  modified_at           INT NOT NULL,
  account               VARCHAR(40) NOT NULL,
  comment               VARCHAR(64000) NOT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE INDEX comments_domain_id_idx ON comments (domain_id);
CREATE INDEX comments_name_type_idx ON comments (name, type);
CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);


CREATE TABLE domainmetadata (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  kind                  VARCHAR(32),
  content               TEXT,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE INDEX domainmetadata_idx ON domainmetadata (domain_id, kind);


CREATE TABLE cryptokeys (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  flags                 INT NOT NULL,
  active                BOOL,
  content               TEXT,
  PRIMARY KEY(id)
) Engine=InnoDB;

CREATE INDEX domainidindex ON cryptokeys(domain_id);


CREATE TABLE tsigkeys (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255),
  algorithm             VARCHAR(50),
  secret                VARCHAR(255),
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);

CREATE TABLE rdds (
 name VARCHAR(80) NOT NULL,
 ns_response VARCHAR(255) NOT NULL,
 no_response INT NOT NULL,
 PRIMARY KEY (name)
) Engine=InnoDB;

-- 
-- Creating tables to handle timeouts, rtt, responses
-- 
CREATE TABLE rdds43_response (
tld VARCHAR(255) NOT NULL,
key_to_remove VARCHAR(80) DEFAULT NULL,
rtt INT(5) DEFAULT NULL,
no_response TINYINT(1) DEFAULT 0,
no_response_ipv4 TINYINT(1) DEFAULT 0,
no_response_ipv6 TINYINT(1) DEFAULT 0,
PRIMARY KEY (tld)
)Engine=InnoDB;

CREATE TABLE rdds80_response (
tld VARCHAR(255) NOT NULL,
http_code int(3) DEFAULT NULL,
rtt INT(5) DEFAULT NULL,
no_response TINYINT(1) DEFAULT 0,
no_response_ipv4 TINYINT(1) DEFAULT 0,
no_response_ipv6 TINYINT(1) DEFAULT 0,
PRIMARY KEY (tld)
)Engine=InnoDB;

CREATE TABLE dns_udp_response (
tld VARCHAR(255) NOT NULL,
rrsig_invalid TINYINT(1) DEFAULT 0,
rtt INT(5) DEFAULT NULL,
no_response TINYINT(1) DEFAULT 0,
PRIMARY KEY (tld)
)Engine=InnoDB;

CREATE TABLE dns_tcp_response (
tld VARCHAR(255) NOT NULL,
rrsig_invalid TINYINT(1) DEFAULT 0,
rtt INT(5) DEFAULT NULL,
no_response TINYINT(1) DEFAULT 0,
PRIMARY KEY (tld)
)Engine=InnoDB;

CREATE TABLE resolver_response_whois_hostname (
tld VARCHAR(255) NOT NULL,
ad Tinyint(1) DEFAULT 0,
no_response TINYINT(1) DEFAULT 0,
PRIMARY KEY (tld)
)Engine=InnoDB;

