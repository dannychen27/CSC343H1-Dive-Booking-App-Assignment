SET SEARCH_PATH to wetworldschema;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    NumberOfOpenWaterSites INT,
    NumberOfCaveSites INT,
    NumberOfDeepDiveSites INT
);

-- Remove any views that we need in case they already exist.
DROP VIEW IF EXISTS OpenWaterMonitors CASCADE;
DROP VIEW IF EXISTS OpenWaterAffiliates CASCADE;
DROP VIEW IF EXISTS OpenWaterDiveSites CASCADE;
DROP VIEW IF EXISTS OpenWaterSiteWithAffiliates CASCADE;
DROP VIEW IF EXISTS OpenDiveCategoryCount CASCADE;
DROP VIEW IF EXISTS CaveMonitors CASCADE;
DROP VIEW IF EXISTS CaveAffiliates CASCADE;
DROP VIEW IF EXISTS CaveDiveSites CASCADE;
DROP VIEW IF EXISTS CaveSiteWithAffiliates CASCADE;
DROP VIEW IF EXISTS CaveDiveCategoryCount CASCADE;
DROP VIEW IF EXISTS DeepMonitors CASCADE;
DROP VIEW IF EXISTS DeepAffiliates CASCADE;
DROP VIEW IF EXISTS DeepDiveSites CASCADE;
DROP VIEW IF EXISTS DeepSiteWithAffiliates CASCADE;
DROP VIEW IF EXISTS DeepDiveCategoryCount CASCADE;
DROP VIEW IF EXISTS FinalAnswer CASCADE;


-- Here are our views for query 1:

-- Here is the process for finding the number of sites that contain
-- at least one affiliate monitor who supervises a particular dive category.
-- We will repeat this process for all three dive categories:
-- 
-- Step 1: Find dive sites that offer that particular dive category.
-- Step 2: Find dive monitors who supervise that particular dive category.
-- Step 3: Find monitors who are affiliated with each dive site listed in step
-- 2 who supervise that particular dive category.
-- Step 4: Find the number of dive sites with at least one
-- monitor that's affiliated with that site.
-- Step 5: Count up the number of dive sites from step 4.


-- Part 1/3: Open Water Diving.

-- We assume that an open water dive site is offered when
-- it can accomodate at least 1 diver, either during the day 
-- or at night.

-- Step 1: The dive sites that offer open water dives.
CREATE VIEW OpenWaterDiveSites(sID) AS
    SELECT sID
    FROM SiteCapacity
    WHERE (CapDayOpen > 0) OR (CapNightOpen > 0);

-- Step 2: The dive monitors who supervise open water dives.
CREATE VIEW OpenWaterMonitors(mID) AS
    SELECT mID
    FROM MonitorCapacity
    WHERE CapOpen > 0;

-- Step 3: The dive sites that each open water dive monitor is affiliated with.
CREATE VIEW OpenWaterAffiliates(mID, sID) AS
    SELECT mID, sID
    FROM OpenWaterMonitors NATURAL JOIN Affiliated;

-- Step 4: The dive sites for which at least one open water dive monitor is
-- affiliated with (has booking privileges with) that site.
CREATE VIEW OpenWaterSiteWithAffiliates(mID, sID) AS
    SELECT mID, sID
    FROM OpenWaterAffiliates NATURAL JOIN OpenWaterDiveSites;

-- Step 5: The number of dive sites that provide open water dives and have 
-- at least one open water dive monitor has booking privileges with that site.
CREATE VIEW OpenDiveCategoryCount(NumOpenSites) AS
    SELECT COUNT(DISTINCT sID) AS NumOpenSites
    FROM OpenWaterSiteWithAffiliates;


-- Part 2/3: Cave Diving.

-- We assume that a cave dive site is offered when
-- it can accomodate at least 1 diver.

-- Step 1: The dive sites that offer cave dives.
CREATE VIEW CaveDiveSites(sID) AS
    SELECT sID
    FROM SiteCapacity
    WHERE CapCave > 0;

-- Step 2: The dive monitors who supervise cave dives.
CREATE VIEW CaveMonitors(mID) AS
    SELECT mID 
    FROM MonitorCapacity
    WHERE CapCave > 0;

-- Step 3: The dive sites that each cave dive monitor is affiliated with.
CREATE VIEW CaveAffiliates(mID, sID) AS
    SELECT mID, sID
    FROM CaveMonitors NATURAL JOIN Affiliated;

-- Step 4: The dive sites for which at least one cave dive monitor is
-- affiliated with (has booking privileges with) that site.
CREATE VIEW CaveSiteWithAffiliates(mID, sID) AS
    SELECT mID, sID
    FROM CaveAffiliates NATURAL JOIN CaveDiveSites;

-- Step 5: The number of dive sites that provide cave dives and have 
-- at least one cave dive monitor with booking privileges with that site.
CREATE VIEW CaveDiveCategoryCount(NumOfCaveSites) AS
    SELECT COUNT(DISTINCT sID) AS NumCaveSites
    FROM CaveSiteWithAffiliates;


-- Part 3/3: Deep Diving.

-- We assume that a deep dive site is offered when
-- it can accomodate at least 1 diver.

-- Step 1: The dive sites that offer deep dives.
CREATE VIEW DeepDiveSites(sID) AS
    SELECT sID
    FROM SiteCapacity
    WHERE CapDeep > 0;

-- Step 2: The dive monitors who supervise deep dives.
CREATE VIEW DeepMonitors(mID) AS
    SELECT mID 
    FROM MonitorCapacity
    WHERE CapDeep > 0;

-- Step 3: The dive sites that each deep dive monitor is affiliated with.
CREATE VIEW DeepAffiliates(mID, sID) AS
    SELECT mID, sID
    FROM DeepMonitors NATURAL JOIN Affiliated;

-- Step 4: The dive sites for which at least one deep dive monitor is
-- affiliated with (has booking privileges with) that site.
CREATE VIEW DeepSiteWithAffiliates(mID, sID) AS
    SELECT mID, sID
    FROM DeepAffiliates NATURAL JOIN DeepDiveSites;

-- Step 5: The number of dive sites that provide deep dives and have 
-- at least one deep dive monitor with booking privileges with that site.
CREATE VIEW DeepDiveCategoryCount(NumDeepSites) AS
    SELECT COUNT(DISTINCT sID) AS NumDeepSites
    FROM DeepSiteWithAffiliates;

-- Our final query: The number of sites that contain at least one affiliate 
-- monitor who supervises each particular dive category.
INSERT INTO q1
SELECT *
FROM OpenDiveCategoryCount, CaveDiveCategoryCount, DeepDiveCategoryCount;
