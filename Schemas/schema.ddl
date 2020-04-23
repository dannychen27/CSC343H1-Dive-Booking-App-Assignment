-- Assignment 3 Wet World Dive Booking App Schema


-- Assumptions:

-- NOTE: "DEEP DIVING" is meant to represent the 30+ Metre diving category presented in the Design Context.

-- Monitors:
-- - All monitors are divers.

-- MonitorRating:
-- - Only lead divers can rate monitors.

-- DivingSession:
-- - Assume that total is correctly calculated as follows: total = numdivers * (sitefees + monitorfees + amenities)
--   where numdivers includes the lead diver and other divers, but not the monitor.

-- SiteRating:
-- - Divers can rate a site multiple times across different sessions.

-- Attends:
-- - Divers who attend a dive session include the lead diver and accompanying divers, but excludes the monitor.



-- Constraint Design Decisions:

-- Monitor:
-- - Although we can allow the default values of CapOpen, CapCave, and CapDeep to be 0,
--   we would rather just have a check constraint that checks if it's >= 0.

-- Supervises:
-- - We couldn't enforce the constraint "monitors can only book at most 2 sessions in a 24-hr period" in our schema
--   because this would require some kind of cross table constraint (e.g. a trigger or assert statement),
--   which are not allowed.

-- Attends:
-- - We couldn't enforce the constraint "the total number of divers (includes lead divers, other divers, and the monitor)
--   at a site cannot exceed the maximum capacity" in our schema because this would require some kind of cross
--   table constraint (e.g. a trigger or assert statement), which are not allowed.

-- Supervises:
-- - We couldn't enforce the constraint "a monitor may only supervise one group at a particular date and time"
--   because this would require some kind of cross table constraint (e.g. a trigger or assert statement), which 
--   are not allowed.



DROP SCHEMA IF exists wetworldschema CASCADE;
CREATE SCHEMA wetworldschema;
SET SEARCH_PATH to wetworldschema;



-- A list of recognized dive certifications.
CREATE TYPE certification AS ENUM ('NAUI', 'CMAS', 'PADI');

-- A diver who participates in a diving session.
-- This table includes both lead divers, regular divers, and monitors.
CREATE TABLE Diver(

    -- Diver ID
    dID INT,

    -- The diver's first name.
    FirstName VARCHAR(50) NOT NULL,

    -- The diver's surname.
    Surname VARCHAR(50) NOT NULL,

    -- The diver's email.
    Email VARCHAR(30) NOT NULL,

    -- The diver's date of birth.
    DOB DATE NOT NULL CHECK (age(CURRENT_DATE, DOB) >= '16 years'),

    -- The diver's dive certification.
    Certification certification NOT NULL,

    -- The diver's credit card number.
    CreditCard CHAR(16) NOT NULL,

    PRIMARY KEY (dID)
);



-- A diving site that divers and monitors can visit.
CREATE TABLE Site(

    -- Site ID
    sID INT,

    -- The site's name.
    Name VARCHAR(100) NOT NULL,

    -- The site's location.
    Location VARCHAR(100) NOT NULL,

    -- The dive categories this site offers.           --  TODO: I was thinking of using these attributes to simplify query 1.
    -- OffersOpenWaterDiving BOOLEAN NOT NULL,
    -- OffersCaveDiving BOOLEAN NOT NULL,
    -- OffersDeepDiving BOOLEAN NOT NULL,

    -- Free services this site offers.                 --  TODO: I was thinking of implementing these attributes from the handout.
    -- DiveVideo BOOLEAN NOT NULL,
    -- Snacks BOOLEAN NOT NULL,
    -- HotShowers BOOLEAN NOT NULL,
    -- TowelService BOOLEAN NOT NULL,

    PRIMARY KEY (sID)
);



-- A monitor for a diving session.
CREATE TABLE Monitor(

    -- Monitor ID
    mID INT PRIMARY KEY,

    -- Diver ID
    dID INT NOT NULL,

    FOREIGN KEY (dID) REFERENCES Diver(dID)
);



-- A list of maximum group sizes that each monitor is willing to supervise for each dive category.
CREATE TABLE MonitorCapacity(

    -- Monitor ID
    mID INT PRIMARY KEY,

    -- The monitor's maximum capacity for the following dive categories:
    --     - open water diving, cave diving, deep diving.
    CapOpen INT NOT NULL CHECK (CapOpen >= 0),
    CapCave INT NOT NULL CHECK (CapCave >= 0),
    CapDeep INT NOT NULL CHECK (CapDeep >= 0),

    FOREIGN KEY (mID) REFERENCES Monitor(mID)
);



-- A list of prices for various sites, including site fee and any extra amenities sites may offer.
CREATE TABLE SitePricing(

    -- Site ID
    sID INT,

    -- The site's flat fee.
    Fee NUMERIC(18, 2) NOT NULL,

    -- The prices of all extra amenities this site offers.
    Mask NUMERIC(18, 2) CHECK (Mask >= 0),
    Fins NUMERIC(18, 2) CHECK (Fins >= 0),
    Regulators NUMERIC(18, 2) CHECK (Regulators >= 0),
    DiveComp NUMERIC(18, 2) CHECK (DiveComp >= 0),
    
    PRIMARY KEY (sID),

    FOREIGN KEY (sID) REFERENCES Site(sID)
);



-- A list of maximum number of divers each site can accommodate for each dive category.
CREATE TABLE SiteCapacity(

    -- Site ID
    sID INT,

    -- The site's capacity for the following dive categories:
    --     - open water diving during the day.
    --     - open Water diving during the night.
    --     - cave diving (day or night).
    --     - deep diving (day or night).
    CapDayOpen INT NOT NULL CHECK (CapDayOpen >= 0),
    CapNightOpen INT NOT NULL CHECK (CapNightOpen >= 0), 
    CapCave INT NOT NULL CHECK (CapCave >= 0),
    CapDeep INT NOT NULL CHECK (CapDeep >= 0),

    -- Check if night, cave, deep capacities are all <= day capacities.
    CHECK (CapNightOpen <= CapDayOpen),
    CHECK (CapCave <= CapDayOpen),
    CHECK (CapDeep <= CapDayOpen),

    PRIMARY KEY (sID),

    FOREIGN KEY (sID) REFERENCES Site(sID)
);


-- Times of day when dive sessions can occur.
CREATE TYPE timeOfDay AS ENUM ('morning', 'afternoon', 'evening');

-- All possible dive categories for a dive session.
CREATE TYPE dive_category AS ENUM ('deep', 'cave', 'open');


-- Relevant information about all dive sessions.
CREATE TABLE DivingSession(

    -- A Identifier for the Session
    Session INT,

    -- This session's lead diver.
    Lead INT NOT NULL,

    -- The session's scheduled date.
    Date DATE NOT NULL,

    -- Which time of day this session occurred.
    TimeOfDay timeOfDay NOT NULL,

    -- This session's dive category.
    Category dive_category NOT NULL,

    -- This session's total price.
    Price NUMERIC(18, 2) CHECK (Price >= 0),

    -- The quantities of each extra amenity requested for this diving session.
    NumMasks INT NOT NULL CHECK (NumMasks >= 0),
    NumFins INT NOT NULL CHECK (NumFins >= 0),
    NumRegulators INT NOT NULL CHECK (NumRegulators >= 0),
    NumDComps INT NOT NULL CHECK (NumDComps >= 0),

    PRIMARY KEY (Session),

    FOREIGN KEY (Lead) REFERENCES Diver(dID)
);


-- A list of prices that each monitor charges at various dive site locations.
-- Since monitors can be affiliated with some sites, their pricing may vary across locations.
CREATE TABLE MonitorPricing(

    -- Monitor ID
    mID INT,

    -- Site ID
    sID INT NOT NULL,

    -- The monitor fees for the following types of dive sessions:
    --    - morning open water, morning cave, morning deep water
    --    - afternoon open water, afternoon cave, afternoon deep water
    --    - evening open water, evening cave, evening deep water
    MOpen NUMERIC(18, 2) CHECK (MOpen >= 0),
    MCave NUMERIC(18, 2) CHECK (MCave >= 0),
    MDeep NUMERIC(18, 2) CHECK (MDeep >= 0),
    AOpen NUMERIC(18, 2) CHECK (AOpen >= 0),
    ACave NUMERIC(18, 2) CHECK (ACave >= 0),
    ADeep NUMERIC(18, 2) CHECK (ADeep >= 0),
    EOpen NUMERIC(18, 2) CHECK (EOpen >= 0),
    ECave NUMERIC(18, 2) CHECK (ECave >= 0),
    EDeep NUMERIC(18, 2) CHECK (EDeep >= 0),

    PRIMARY KEY (mID, sID),

    FOREIGN KEY (mID) REFERENCES Monitor(mID),
    FOREIGN KEY (sID) REFERENCES Site(sID)
);



-- A list of ratings monitors have received from divers across various diving sessions.
CREATE TABLE MonitorRating(

    -- The session when the monitor supervised this diver.
    Session INT,

    -- The monitor being rated.
    mID INT,

    -- The lead diver who rates the monitor.
    dID INT,

    -- The rating the lead diver gave this monitor.
    Rating NUMERIC(2, 0) NOT NULL CHECK (Rating >= 0 AND Rating <= 5),

    PRIMARY KEY (mID, dID, Session),

    FOREIGN KEY (mID) REFERENCES Monitor(mID),
    FOREIGN KEY (dID) REFERENCES Diver(dID),
    FOREIGN KEY (Session) REFERENCES DivingSession(Session)
);


-- A list of ratings sites have received from divers across various diving sessions.
CREATE TABLE SiteRating(

    -- The session when the diver visited this site. 
    Session INT,

    -- The site being rated.
    sID INT,

    -- The diver who rates the site.
    dID INT,

    -- The rating this diver gave this site.
    Rating NUMERIC(2, 0) NOT NULL CHECK (Rating >= 0 AND Rating <= 5),

    PRIMARY KEY (sID, dID, Session),

    FOREIGN KEY (sID) REFERENCES Site(sID),
    FOREIGN KEY (dID) REFERENCES Diver(dID),
    FOREIGN KEY (Session) REFERENCES DivingSession(Session)
);


-- A list of all monitors who supervised each diving session.
CREATE TABLE Supervises(

    -- Diving session ID.
    Session INT,

    -- The monitor who supervised that session.
    mID INT,

    PRIMARY KEY (mID, Session),
    
    FOREIGN KEY (mID) REFERENCES Monitor(mID),
    FOREIGN KEY (Session) REFERENCES DivingSession(Session)
);


-- A list of all sites where each diving session is held.
CREATE TABLE Holds(

    -- Diving session ID.
    Session INT,

    -- The site where a diving session is held.
    sID INT,

    PRIMARY KEY (sID, Session),

    FOREIGN KEY (sID) REFERENCES Site(sID),
    FOREIGN KEY (Session) REFERENCES DivingSession(Session)
);


-- A list of all divers who attend each diving session.
CREATE TABLE Attends(

    -- The diving session ID.
    Session INT,

    -- The diver who attended this diving session.
    dID INT,

    PRIMARY KEY (dID, Session),

    FOREIGN KEY (dID) REFERENCES Diver(dID),
    FOREIGN KEY (Session) REFERENCES DivingSession(Session)
);


-- A list of all sites each monitor is affiliated with.
CREATE TABLE Affiliated(

    -- The monitor ID.
    mID INT,

    -- The site this monitor is affiliated with.
    sID INT,

    PRIMARY KEY (mID, sID),

    FOREIGN KEY (mID) REFERENCES Monitor(mID),
    FOREIGN KEY (sID) REFERENCES Site(sID)
);


-- Data copied from CSV files.
-- \COPY diver FROM 'diver.csv' DELIMITER ',' CSV header;
-- \COPY site FROM 'site.csv' DELIMITER ',' CSV header;
-- \COPY monitor FROM 'monitor.csv' DELIMITER ',' CSV header;

-- \COPY monitorCapacity FROM 'monitor_capacity.csv' DELIMITER ',' CSV header;
-- \COPY sitePricing FROM 'site_pricing.csv' DELIMITER ',' CSV header;
-- \COPY siteCapacity FROM 'site_capacity.csv' DELIMITER ',' CSV header;
-- \COPY divingSession FROM 'diving_session.csv' DELIMITER ',' CSV header;

-- \COPY monitorPricing FROM 'monitor_pricing.csv' DELIMITER ',' CSV header;
-- \COPY monitorRating FROM 'monitor_rating.csv' DELIMITER ',' CSV header;
-- \COPY siteRating FROM 'site_rating.csv' DELIMITER ',' CSV header;
-- \COPY supervises FROM 'supervises.csv' DELIMITER ',' CSV header;
-- \COPY holds FROM 'holds.csv' DELIMITER ',' CSV header;
-- \COPY attends FROM 'attends.csv' DELIMITER ',' CSV header;
-- \COPY affiliated FROM 'affiliated.csv' DELIMITER ',' CSV header;

