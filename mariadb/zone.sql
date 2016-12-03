USE rDNS;

DELETE FROM records WHERE domain_id = '1';
DELETE FROM domains WHERE name = 'tld' OR id = 1;

INSERT INTO domains (id, name, type) VALUES (1, 'tld', 'MASTER');
INSERT INTO records (domain_id, name, content, type, ttl, prio)
  VALUES (1, 'tld', 'ns1.tld hostmaster.ns1.tld 1', 'SOA', 86400, NULL);
