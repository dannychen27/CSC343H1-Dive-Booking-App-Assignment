SET SEARCH_PATH to wetworldschema;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2(
    mID INT,
    Email VARCHAR(30),
    AverageFee NUMERIC(18, 2)
);

-- Remove any views that we need in case they already exist.
DROP VIEW IF EXISTS AverageMonitorRating CASCADE;
DROP VIEW IF EXISTS AverageSiteRating CASCADE;
DROP VIEW IF EXISTS AffiliatedRatings CASCADE;
DROP VIEW IF EXISTS MonLessCool CASCADE;
DROP VIEW IF EXISTS MonMoreCool CASCADE;
DROP VIEW IF EXISTS HigherMonAvg CASCADE;
DROP VIEW IF EXISTS NumDiversAttending CASCADE;
DROP VIEW IF EXISTS PopularMonitorFeeBreakdown CASCADE;
DROP VIEW IF EXISTS SiteAmenityPrices CASCADE;
DROP VIEW IF EXISTS PopularMonitorFees CASCADE;
DROP VIEW IF EXISTS PopularMonitorEmails CASCADE;

-- Here are our views for query 2:

-- The average rating for each dive monitor.
CREATE VIEW AverageMonitorRating(mid, AvgMon) AS
    SELECT mID, ROUND(AVG(Rating), 2) AS averageMonitorRating
    FROM MonitorRating
    GROUP BY mID;

-- The average rating for each dive site.
CREATE VIEW AverageSiteRating(sID, AvgSite) AS
    SELECT sID, ROUND(AVG(Rating), 2) AS averageSiteRating
    FROM SiteRating
    GROUP BY sID;

-- We assume that "sites that the monitor uses" are all dive sites 
-- that the monitor is affiliated with.

-- The average ratings of all sites that each monitor uses.
-- Ignores sites that have no ratings.
CREATE VIEW AffiliatedRatings(mID, sID, AvgMon, AvgSite) AS
    SELECT mID, sID, AvgMon, AvgSite
    FROM
        Affiliated
        NATURAL JOIN AverageMonitorRating 
        NATURAL JOIN AverageSiteRating;

-- The monitors who have an average rating that's lower than the average 
-- rating of some site(s) they use.
CREATE VIEW MonLessCool(mId) AS
    SELECT mID
    FROM AffiliatedRatings
    WHERE AvgMon <= AvgSite;

-- The monitors who have an average rating that's higher than the average
-- rating of some site(s) they use.
CREATE VIEW MonMoreCool(mID) AS
    SELECT mID
    FROM AffiliatedRatings
    WHERE AvgMon > AvgSite;

-- The monitors who have a higher average monitor rating than all of the
-- average site ratings of the sites at which they use.
CREATE VIEW HigherMonAvg(mID) AS
    (SELECT * FROM MonMoreCool)
    EXCEPT
    (SELECT * FROM MonLessCool);

-- The email addresses of monitors who have a higher average monitor rating than 
-- all of the average site ratings of the sites at which they supervise.
CREATE VIEW PopularMonitorEmails(mid, Email) AS
    SELECT mID, Email
    FROM HigherMonAvg NATURAL JOIN Monitor NATURAL JOIN Diver;

-- We interpret "monitor booking fee" as price (from DivingSession) minus 
-- amenities and site fee per booking session.
-- Therefore, "average monitor fee" is the average amount charged across
-- multiple sessions.

-- The monitor fee breakdown for all bookings across all sessions.
CREATE VIEW PopularMonitorFeeBreakdown(session, mID, price, numMasks, 
                                        numFins, numRegulators, numDcomps) AS
    SELECT session, mID, price, numMasks, numFins, numRegulators, numDcomps 
    FROM
        Supervises s
        NATURAL JOIN DivingSession 
        NATURAL JOIN HigherMonAvg;

-- The number of divers attending each session.
CREATE VIEW NumDiversAttending AS
    SELECT session, count(dID) as numDivers 
    FROM Attends
    GROUP BY session;

-- The site fee and amenity prices for each site.
-- If an amenity price is not listed, its price is 0 for this view.
CREATE VIEW SiteAmenityPrices(sID, fee, maskPrice, finsPrice, 
                                regulatorPrice, diveCompPrice) AS
    SELECT
        sID, fee,
        (CASE WHEN mask IS NULL THEN 0 ELSE mask END) AS maskPrice,
        (CASE WHEN fins IS NULL THEN 0 ELSE fins END) AS finsPrice,
        (CASE WHEN regulators IS NULL THEN 0 ELSE regulators END) 
            AS regulatorPrice,
        (CASE WHEN diveComp IS NULL THEN 0 ELSE diveComp END) AS diveCompPrice
    FROM SitePricing NATURAL JOIN PopularMonitorFeeBreakdown;

-- The monitor fees of each monitor per session.
CREATE VIEW PopularMonitorFees(session, mID, MonitorFee) AS
    SELECT
        session, mID,
        price - numDivers * (
            fee 
            - maskPrice * numMasks
            - finsPrice * numFins 
            - regulatorPrice * numRegulators
            - diveCompPrice * numDComps) AS MonitorFee
    FROM 
        PopularMonitorFeeBreakdown
        NATURAL JOIN NumDiversAttending 
        NATURAL JOIN SiteAmenityPrices 
        NATURAL JOIN Holds;

-- Our final query: The average booking fee (across all dive categories they 
-- supervise and across all sessions) and emails of monitors whose average 
-- rating is higher than all dive ratings of the sites they use.
INSERT INTO q2
SELECT mID, Email, ROUND(AVG(MonitorFee), 2) AS AverageFee
FROM PopularMonitorEmails NATURAL JOIN PopularMonitorFees 
GROUP BY mID, Email;
