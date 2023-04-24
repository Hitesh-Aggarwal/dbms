-- Crate tables
CREATE TABLE
  student (
    rollno number PRIMARY KEY,
    name varchar(40),
    m_no varchar(10),
    fine number,
    issued_books number CHECK (issued_books <= 10)
  );

CREATE TABLE
  lib (
    isbn number PRIMARY KEY,
    bookname varchar(50),
    author varchar(40),
    publication varchar(20),
    copies number,
    lost_cost number,
    delay_cost number
  );

CREATE TABLE
  book (
    bookid number GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    isbn number,
    availability varchar(1) CHECK (
      (availability = 'A')
      OR (availability = 'O')
    )
  );

CREATE TABLE
  subscription (
    bookid number,
    rollno number,
    issue_date date,
    return_date date,
    actual_return_date date,
    PRIMARY KEY (bookid, rollno)
  );

-- Drop tables
DROP TABLE student;

DROP TABLE subscription;

DROP TABLE lib;

DROP TABLE book;

-- select statements
SELECT * FROM student;

SELECT * FROM subscription;

SELECT * FROM lib;

SELECT * FROM book;

-- Add foreign keys now.
ALTER TABLE book ADD CONSTRAINT book_fk FOREIGN KEY (isbn) REFERENCES lib (isbn);

ALTER TABLE subscription ADD CONSTRAINT subscription_fk_roll FOREIGN KEY (rollno) REFERENCES student (rollno);

ALTER TABLE subscription ADD CONSTRAINT subscription_fk_book FOREIGN KEY (bookid) REFERENCES book (bookid);


-- some insert statements

-- student
INSERT INTO student VALUES (1, 'ALFRED', 623623623, 0, 0);
INSERT INTO student VALUES (2, 'JAMES', 659659659,0, 0);
INSERT INTO student VALUES (3, 'GEORGE', 654654654, 0, 0);
INSERT INTO student VALUES (4, 'TOM', 658658658,0, 0);
INSERT INTO student VALUES (5, 'PETER', 652652652,0, 0);
INSERT INTO student VALUES (6, 'JENNY', 651651651,0, 0);
INSERT INTO student VALUES (7, 'ROSE', 657657657,0, 0);
INSERT INTO student VALUES (8, 'MONICA', 639639639, 0, 0);
INSERT INTO student VALUES (9, 'PHOEBE', 678678678, 0, 0);
INSERT INTO student VALUES (10, 'RACHEL', 687687687,0, 0);


------------------ plsql starts here -----------------------

CREATE OR REPLACE PROCEDURE add_student(roll_no in number, s_name in varchar,
 m_no in varchar)
IS
BEGIN
  INSERT INTO student VALUES(roll_no, s_name, m_no, 0,0);
END;


DECLARE
  roll_no number;
  name varchar(50);
  m_no varchar(10);
BEGIN
  roll_no := &roll_no;
  name := &name;
  m_no := &m_no;
  add_student(roll_no,name,m_no);
END;


CREATE OR REPLACE PROCEDURE add_first_book(
  isbn_no in number,
  bookname in varchar,
  author in varchar,
  publication in varchar,
  lost_cost in number,
  delay_cost in number) IS
BEGIN
  INSERT INTO lib VALUES(isbn_no, bookname,author,publication,1,lost_cost,
    delay_cost);
  INSERT INTO book VALUES(NULL, isbn_no, 'A');
END;


CREATE OR REPLACE PROCEDURE add_more_books(isbn_no in number) IS
BEGIN
  INSERT INTO book VALUES(NULL, isbn_no, 'A');
  UPDATE lib SET copies = copies + 1 WHERE lib.isbn = isbn_no;
END;


DECLARE
  counter number;
  isbn_no number;
  bookname varchar(50);
  author varchar(40);
  publication varchar(20);
  lost_cost number;
  delay_cost number;
BEGIN
  isbn_no := &isbn_no;
  SELECT count(*) INTO counter FROM lib WHERE lib.isbn = isbn_no;
  IF counter > 0 THEN
    add_more_books(isbn_no);
  ELSE
    bookname := &bookname;
    author := &author;
    publication := &publication;
    lost_cost := &lost_cost;
    delay_cost := &delay_cost;
    add_first_book(isbn_no,bookname,author,publication,lost_cost,delay_cost);
  END IF;
END;


CREATE OR REPLACE PROCEDURE return_book(book_id number, roll_no number) IS
i_date date;
r_date date;
ar_date date;
isbn_no number;
d_cost number;
no_of_copies number;
fine_amount number;
BEGIN
  SELECT isbn INTO isbn_no FROM book WHERE bookid = book_id;
  SELECT copies, delay_cost INTO no_of_copies, d_cost FROM lib
  WHERE isbn = isbn_no;
  no_of_copies := no_of_copies + 1;
  UPDATE book SET availability = 'A' WHERE bookid = book_id;
  UPDATE lib SET copies = no_of_copies WHERE isbn = isbn_no;
  SELECT issue_date, return_date, actual_return_date INTO i_date, r_date,
  ar_date FROM subscription WHERE bookid = book_id AND rollno = roll_no;
  IF ar_date > r_date THEN
    fine_amount := (ar_date - r_date) * d_cost;
    UPDATE student SET fine = fine_amount WHERE rollno = roll_no;
    dbms_output.put_line('Fine amount: ' || fine_amount);
  END IF;
  UPDATE student SET issued_books = issued_books - 1 WHERE rollno = roll_no;
  DELETE FROM subscription WHERE bookid = book_id AND rollno = roll_no;
END;

DECLARE
book_id number;
roll_no number;
BEGIN
  book_id := &book_id;
  roll_no := &roll_no;
  return_book(book_id,roll_no);
END;

CREATE OR REPLACE PROCEDURE pay_fine(roll_no number) IS
BEGIN
  UPDATE student SET fine = 0 WHERE rollno = roll_no;
END;

DECLARE
rollno number;
BEGIN
  rollno := &rollno;
  pay_fine(rollno);
END;

CREATE OR REPLACE PROCEDURE similar_author_books(auth in varchar)
AS
temp varchar(300);
cursor c1 is select bookname from lib where author = auth;
rec varchar(300);
BEGIN
for rec in c1 loop
    dbms_output.put_line(rec.bookname);
END LOOP;
END;
