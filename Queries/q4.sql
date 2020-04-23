SET SEARCH_PATH to wetworldschema;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4(
    sID INT,
    HighestFee NUMERIC(18, 2),
    LowestFee NUMERIC(18, 2),
    AverageFee NUMERIC(18, 2)
);

-- Remove any views that we need in case they already exist.
DROP VIEW IF EXISTS SessionAmountAllBookedSites CASCADE;
DROP VIEW IF EXISTS SiteChargedStats CASCADE;

-- Here are our views for query 4:

-- For this query we assume that "fee charged per dive" corresponds to the total 
-- fee that was charged during that dive session. 
-- Furthermore, when looking for the highest, lowest, and average prices
-- we consider sites where divers have booked as found in the DivingSession 
-- table.


-- The amount each site that has been booked before charges across all sessions.
CREATE VIEW SessionAmountAllBookedSites(sID, Session, Price) AS
    SELECT sID, Session, Price
    FROM Site NATURAL JOIN Holds NATURAL JOIN DivingSession;

-- The highest, lowest and average price each site charges per session.
CREATE VIEW SiteChargedStats(sID, HighestFee, LowestFee, AverageFee) AS
    SELECT
        sID, 
        MAX(Price) AS HighestFee,
        MIN(Price) AS LowestFee,
        ROUND(AVG(Price), 2) AS AverageFee
    FROM SessionAmountAllBookedSites
    GROUP BY sID;

-- Our final query: the highest, lowest, and average fee charged per dive 
-- session for all dive sites.
--
-- We must include all dive sites, including ones where no sessions have
-- ever booked there (they will be null when natural right joined).
INSERT INTO q4
SELECT sID, HighestFee, LowestFee, AverageFee
FROM Site NATURAL RIGHT JOIN SiteChargedStats;
