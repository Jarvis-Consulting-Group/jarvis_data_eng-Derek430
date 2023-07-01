
-- Table Setup (DDL) 

CREATE TABLE cd.members
(
    memid                    INTEGER NOT NULL,
    surname                  VARCHAR(200) NOT NULL,
    firstname                VARCHAR(200) NOT NULL,
    address                  VARCHAR(300) NOT NULL,
    zipcode                  INTEGER NOT NULL,
    telephone                VARCHAR(20) NOT NULL,
    recommendedby            INTEGER,
    joindate                 TIMESTAMP NOT NULL,
    CONSTRAINT members_pk PRIMARY KEY (memid),
    CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
        REFERENCES cd.members(memid) ON DELETE SET NULL
);


CREATE TABLE cd.facilities
(
    facid                     INTEGER NOT NULL,
    name                      VARCHAR(100) NOT NULL,
    membercost                NUMERIC NOT NULL,
    guestcost                 NUMERIC NOT NULL,
    initialoutlay             NUMERIC NOT NULL,
    monthlymaintenance        NUMERIC NOT NULL,
    CONSTRAINT facilities_pk PRIMARY KEY (facid)
);

CREATE TABLE cd.bookings
(
    facid                     INTEGER NOT NULL,
    memid                     INTEGER NOT NULL,
    starttime                 TIMESTAMP NOT NULL,
    slots                     INTEGER NOT NULL,
    CONSTRAINT bookings_pk PRIMARY KEY (facid),
    CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
    CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
);

-- Modifying Data 

-- Question 1: The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values: facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);


-- Questions 2: Let us try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else: Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

INSERT INTO cd.facilities
	(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT (SELECT MAX(facid) FROM cd.facilities )+1, 'Spa', 20, 30, 100000, 800;


-- Questions 3: We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error. 
 
UPDATE cd.facilities
    SET initialoutlay = 10000
    WHERE name = 'Tennis Court 2'; 


-- Questions 4: We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to. 

UPDATE cd.facilities facs
    SET
        membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE name = 'Tennis Court 2'),
        guestcost = (SELECT guestcost * 1.1 FROM cd.facilities WHERE facid = 'Tennis Court 2')
    WHERE facs.facid = 1;   


-- Questions 5: As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this? 

DELETE FROM cd.bookings;  


-- Questions 6: We want to remove member 37, who has never made a booking, from our database. How can we achieve that? 

DELETE FROM cd.members WHERE memid = 37; 


-- Basics 

-- Questions 7: How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question. 

SELECT facid, name, membercost, monthlymaintenance 
	FROM cd.facilities 
	WHERE 
		membercost > 0 AND 
		(membercost < monthlymaintenance/50);  


-- Questions 8: How can you produce a list of all facilities with the word 'Tennis' in their name? */

SELECT *
	FROM cd.facilities 
	WHERE
		name LIKE '%Tennis%';   


-- Questions 9: How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator. 

SELECT *
	FROM cd.facilities 
	WHERE 
		facid IN (1,5);  


-- Questions 10: How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question. 

SELECT memid, surname, firstname, joindate 
	FROM cd.members
	WHERE joindate >= '2012-09-01';  
 

-- Questions 11: You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list! 

SELECT surname 
	FROM cd.members
UNION
SELECT name
	FROM cd.facilities;   


-- JOIN 

-- Questions 12: How can you produce a list of the start times for bookings by members named 'David Farrell'? 

SELECT bks.starttime 
	FROM 
		cd.bookings bks
		JOIN cd.members mems
			ON mems.memid = bks.memid
	WHERE 
		mems.firstname='David' 
		AND mems.surname='Farrell';    


-- Questions 13: How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time. 

SELECT bks.starttime AS starttime, facs.name AS name
	FROM 
		cd.facilities facs
		JOIN cd.bookings bks
			ON facs.facid = bks.facid
	WHERE 
		facs.name LIKE 'Tennis Court%' AND
		bks.starttime >= '2012-09-21' and
		bks.starttime < '2012-09-22'
ORDER BY bks.starttime;   


-- Questions 14: How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname). 

SELECT m1.firstname AS MemberFirstname, m1.surname AS MemberSurname, m2.firstname AS RecommendedbyFirstname, m2.surname AS RecommendedbySurname
	FROM 
		cd.members m1
		LEFT JOIN cd.members m2
			ON m1.recommendedby = m2.memid
ORDER BY MemberSurname, MemberFirstname;  


-- Questions 15: How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname). 

SELECT DISTINCT m2.firstname as Firstname, m2.surname as Surname
	FROM 
		cd.members m1
		inner JOIN cd.members m2
			ON m1.recommendedby = m2.memid
ORDER BY surname, firstname;    


-- Questions 16: How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered. 

SELECT DISTINCT
	concat(firstname, ' ',surname) as member,
	(SELECT 
		concat(firstname, ' ',surname) as recommender
	FROM 
		cd.members m2
	WHERE
		m1.recommendedby = m2.memid)
FROM 
	cd.members m1;

-- Aggregation 

-- Questions 17: Produce a count of the number of recommendations each member has made. Order by member ID. */

SELECT 
	recommendedby, COUNT(*)
FROM
	cd.members
WHERE
	recommendedby IS NOT null
GROUP BY
	recommendedby
ORDER BY
	recommendedby; 


-- Questions 18: Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.

SELECT 
	facid, 
	sum(slots)
FROM
	cd.bookings
GROUP BY 
	facid
ORDER BY
	facid;


-- Questions 19: Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.

SELECT 
	facid,
	sum(slots)
FROM
	cd.bookings
WHERE
	starttime >= '2012-09-01' 
	and starttime <'2012-10-01'
GROUP BY 
	facid
ORDER BY
	sum(slots);


-- Questions 20: Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.

SELECT
	facid, 
	extract(month from starttime) AS month,
	sum(slots)
FROM
	cd.bookings
WHERE
	starttime >= '2012-01-01' 
	and starttime < '2013-01-01'
GROUP BY
	facid,
	month
ORDER BY
	facid, 
	month;


-- Questions 21: Find the total number of members (including guests) who have made at least one booking.

SELECT
	COUNT(DISTINCT memid)
FROM
	cd.bookings;


-- Questions 22: Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID. Hint: In a SQL query that uses the GROUP BY clause, all non-aggregated columns that appear in the SELECT clause must also appear in the GROUP BY clause. The purpose of the GROUP BY clause is to specify how the result set should be grouped based on one or more columns. Any columns that are not part of the grouping criteria must be included in an aggregate function in the SELECT clause.

SELECT 
	surname,
	firstname,
	b.memid,
	min(starttime)
FROM
	cd.bookings b
	LEFT JOIN cd.members m
	ON b.memid = m.memid
WHERE
	starttime >= '2012-09-01'
GROUP BY
	b.memid,surname,firstname
ORDER BY
	b.memid;


-- Questions 23: Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.

SELECT
	COUNT(memid) OVER (),
	firstname,
	surname
FROM
	cd.members
ORDER BY
	joindate;


-- Questions 24: Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.

SELECT
	row_number()over(),
	firstname,
FROM
	cd.members
ORDER BY
	joindate;


-- Questions 25: Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.

SELECT
	facid,
	sum
FROM 
	(SELECT
		facid,
		sum(slots) AS sum,
		RANK() over(ORDER BY SUM(slots) DESC) AS rnk
	FROM 
		cd.bookings
	GROUP BY 
		facid) a
WHERE 
	rnk =1;


WITH a AS (
  SELECT facid, SUM(slots) AS sum
  FROM cd.bookings
  GROUP BY facid
)
SELECT facid, sum
FROM a
WHERE sum = (
  SELECT MAX(sum)
  FROM a
);


-- String

-- Questions 26: Output the names of all members, formatted as 'Surname, Firstname'

SELECT
	concat(surname, ', ', firstname)
FROM
	cd.members;


-- Question 27: You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.

SELECT 
    memid, 
    telephone 
FROM
    cd.members 
WHERE
    telephone ~ '[()]';


-- Question 28: You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don't worry about printing out a letter if the count is 0.

SELECT
	substr (mems.surname,1,1) AS letter, 
	COUNT(*) as count 
FROM
	cd.members mems]
GROUP BY
	letter
ORDER BY 
	letter;


