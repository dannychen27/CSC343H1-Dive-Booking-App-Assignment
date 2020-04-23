SET SEARCH_PATH to wetworldschema;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3(
    AverageFeeLessThanOrEqualHalfFull INT,
    AverageFeeMoreThanHalfFull INT
);

-- Remove any views that we need in case they already exist.
DROP VIEW IF EXISTS SessionFullness CASCADE;
DROP VIEW IF EXISTS PercentFullness CASCADE;
DROP VIEW IF EXISTS SiteAverageFullness CASCADE;
DROP VIEW IF EXISTS AverageMoreThanHalf CASCADE;
DROP VIEW IF EXISTS AverageLessThanHalf CASCADE;
DROP VIEW IF EXISTS SiteAmountsCharged CASCADE;
DROP VIEW IF EXISTS AverageFeesMoreThanHalfFull CASCADE;
DROP VIEW IF EXISTS AverageFeesLessThanOrEqualHalfFull CASCADE;
 
-- Here are our views for query 3:

-- This is a roundabout way to find the percent capacity of each site,
-- but unfortunately SQL won't let me compute the percent fullness directly.
-- SQL complains that aggregation functions cannot exist in a
-- GROUP BY statement. So I need this extra view SessionFullness.
--
-- The number of divers at each site, versus the site's total capacity, 
-- across all sessions.
-- and site.
CREATE VIEW SessionFullness AS
    SELECT
        session, sID,
        count(dID) + 1 AS numDivers,  -- +1 for the supervising monitor
        (capDayOpen + capNightOpen + capCave + capDeep) AS totalCapacity
    FROM Holds NATURAL JOIN Attends NATURAL JOIN SiteCapacity
    GROUP BY session, sID, (capDayOpen + capNightOpen + capCave + capDeep);

-- The percent capacity of each dive site across all sessions.
CREATE VIEW PercentFullness AS
    SELECT session, sID, numDivers / totalCapacity::float AS percentCapacity
    FROM SessionFullness
    GROUP BY session, sID, numDivers / totalCapacity::float;

-- The average capacity of each dive site across all sessions.
CREATE VIEW SiteAverageFullness AS
    SELECT sID, avg(percentCapacity) as averageCapacity
    FROM PercentFullness
    GROUP BY sID;

-- The dive sites with an average capacity of > 50% on average.
CREATE VIEW AverageMoreThanHalf AS
    SELECT sID
    FROM SiteAverageFullness
    WHERE averageCapacity > 0.50;

-- The dive sites with an average capacity of <= 50% on average.
CREATE VIEW AverageLessThanHalf AS
    SELECT sID
    FROM SiteAverageFullness
    WHERE averageCapacity <= 0.50;

-- We assume that the "booking fee" for a dive site is simply the total 
-- found in DivingSession.

-- The amount charged per session at each dive site.
CREATE VIEW SiteAmountsCharged AS
    SELECT session, sID, price AS amountCharged
    FROM Holds NATURAL JOIN SitePricing NATURAL JOIN DivingSession
    GROUP BY session, sID, price;

-- The average amount charged for all sites that are > 50% full on average.
-- If there are no sites that are > 50% full on average, simply return NULL.
CREATE VIEW AverageFeesMoreThanHalfFull AS
    SELECT ROUND(AVG(amountCharged), 2) AS AverageFeeMoreThanHalfFull
    FROM SiteAmountsCharged NATURAL JOIN AverageMoreThanHalf mh;

-- The average amount charged for all sites that are <= 50% full on average.
-- If there are no sites that are <= 50% full on average, simply return NULL.
CREATE VIEW AverageFeesLessThanOrEqualHalfFull AS
    SELECT ROUND(AVG(amountCharged), 2) AS AverageFeeLessThanOrEqualHalfFull
    FROM SiteAmountsCharged NATURAL JOIN AverageLessThanHalf mh;

-- Our final query: The average fee charged for sites that are <= 50% full on
-- average, and the average fee charged for sites that are > 50% full on 
-- average.
INSERT INTO q3
SELECT *
FROM 
    AverageFeesMoreThanHalfFull 
    NATURAL JOIN AverageFeesLessThanOrEqualHalfFull;
