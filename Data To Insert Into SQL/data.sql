-- Diver
insert into Diver values (1, 'Michael', 'Dawson', 'michael@dm.org', '1967-03-15', 'PADI', '111-222-333-4444');
insert into Diver values (2, 'Dwight', 'Schmidt', 'dwight@dm.org', '1967-03-16', 'NAUI', '111-222-333-4445');
insert into Diver values (3, 'Jim', 'Halpert', 'jim@dm.org', '1967-03-17', 'NAUI', '111-222-333-4446');
insert into Diver values (4, 'Pam', 'Beesly', 'pam@dm.org', '1967-03-18', 'NAUI', '111-222-333-4447');
insert into Diver values (5, 'Andy', 'Bernard', 'andy@dm.org', '1973-10-10', 'PADI', '111-222-333-4448');
insert into Diver values (6, 'Phyllis', 'Henderson', 'phyllis@dm.org', '1973-10-11', 'CMAS', '111-222-333-4449');
insert into Diver values (7, 'Oscar', 'Maslow', 'oscar@dm.org', '1973-10-12', 'CMAS', '111-222-333-4450');
insert into Diver values (8, 'Maria', 'Sanders', 'maria@dm.org', '1973-10-13', 'CMAS', '111-222-333-4451');
insert into Diver values (9, 'John', 'Eaton', 'john@dm.org', '1973-10-14', 'CMAS', '111-222-333-4452');
insert into Diver values (10, 'Ben', 'Chocolate', 'ben@dm.org', '1973-10-15', 'CMAS', '111-222-333-4453');


-- Site
insert into Site values (1, 'Bloody Bay Marine Park', 'Little Cayman');
insert into Site values (2, 'Widow Maker''s', 'Cave Montego Bay');
insert into Site values (3, 'Crystal Bay', 'Crystal Bay');
insert into Site values (4, 'Batu Bolong', 'Batu Bolong');


-- Monitor
insert into Monitor values (1, 8);
insert into Monitor values (2, 9);
insert into Monitor values (3, 10);


-- MonitorCapacity
insert into MonitorCapacity values (1, 10, 5, 5);
insert into MonitorCapacity values (2, 15, 15, 15);
insert into MonitorCapacity values (3, 15, 5, 5);


-- SitePricing
insert into SitePricing values (1, 10, 5, 10, NULL, NULL);
insert into SitePricing values (2, 20, 3, 5, NULL, NULL);
insert into SitePricing values (3, 15, NULL, 5, NULL, 20);
insert into SitePricing values (4, 15, 10, NULL, NULL, 30);


-- SiteCapacity
insert into SiteCapacity values (1, 0, 0, 10, 0);
insert into SiteCapacity values (2, 15, 5, 10, 0);
insert into SiteCapacity values (3, 10, 5, 5, 0);
insert into SiteCapacity values (4, 10, 5, 5, 5);


-- DivingSession
insert into DivingSession values (101, 1, '2019-07-20', 'morning', 'open', 150, 0, 0,	0, 0);
insert into DivingSession values (102, 1, '2019-07-21', 'morning', 'cave', 120, 0, 0, 0, 0);
insert into DivingSession values (103, 1, '2019-07-22', 'morning', 'cave', 60, 0, 0, 0, 0);
insert into DivingSession values (104, 1, '2019-07-22', 'evening', 'cave', 35, 0, 0, 0, 0);
insert into DivingSession values (105, 5, '2019-07-22', 'afternoon', 'open', 245, 0, 0, 0, 0);
insert into DivingSession values (106, 5, '2019-07-23', 'morning', 'cave', 40, 0, 0, 0, 0);
insert into DivingSession values (107, 5, '2019-07-24', 'morning', 'cave', 40, 0, 0, 0, 0);


-- MonitorPricing
insert into MonitorPricing values (1, 1, null, null, null, null, null, 25, null);	
insert into MonitorPricing values (1, 2, 10, 20, null, null, null, null, null);							
insert into MonitorPricing values (1, 3, null, null, 15, null, null, null, null, null, null);					
insert into MonitorPricing values (1, 4, null, 30, null, null, null, null, null, null, null);							
insert into MonitorPricing values (2, 1, null, 15, null, null, null, null, null, null, null);							
insert into MonitorPricing values (2, 2, null, 20, null, null, null, null, null, null, null);	


-- MonitorRating
insert into MonitorRating values (101, 1, 1, 2);
insert into MonitorRating values (102, 1, 1, 0);
insert into MonitorRating values (103, 2, 1, 5);
insert into MonitorRating values (105, 1, 5, 1);
insert into MonitorRating values (106, 3, 5, 0);
insert into MonitorRating values (107, 3, 5, 2);


-- SiteRating
insert into SiteRating values (101, 1, 3, 3);
insert into SiteRating values (101, 2, 2, 0);
insert into SiteRating values (101, 2, 4, 1);
insert into SiteRating values (102, 2, 3, 2);
insert into SiteRating values (102, 3, 5, 4);
insert into SiteRating values (103, 3, 4, 5);
insert into SiteRating values (103, 3, 1, 2);
insert into SiteRating values (103, 3, 7, 3);


-- Supervises
insert into Supervises values (101, 1);
insert into Supervises values (102, 1);
insert into Supervises values (103, 2);
insert into Supervises values (104, 1);
insert into Supervises values (105, 1);
insert into Supervises values (106, 3);
insert into Supervises values (107, 3);


-- Holds
insert into Holds values (101, 2);
insert into Holds values (102, 2);
insert into Holds values (103, 1);
insert into Holds values (104, 1);
insert into Holds values (105, 2);
insert into Holds values (106, 2);
insert into Holds values (107, 2);


-- Attends
insert into Attends values (101, 1);
insert into Attends values (101, 2);
insert into Attends values (101, 3);
insert into Attends values (101, 4);
insert into Attends values (101, 5);
insert into Attends values (102, 1);
insert into Attends values (102, 2);
insert into Attends values (102, 3);
insert into Attends values (103, 1);
insert into Attends values (103, 3);
insert into Attends values (104, 1);
insert into Attends values (105, 5);
insert into Attends values (105, 2);
insert into Attends values (105, 3);
insert into Attends values (105, 4);
insert into Attends values (105, 1);
insert into Attends values (105, 6);
insert into Attends values (105, 7);
insert into Attends values (106, 5);
insert into Attends values (107, 5);


-- Affiliated
insert into Affiliated values (1, 1);
insert into Affiliated values (1, 2);
insert into Affiliated values (1, 3);
insert into Affiliated values (1, 4);
insert into Affiliated values (2, 1);
insert into Affiliated values (2, 3);
insert into Affiliated values (3, 2);
