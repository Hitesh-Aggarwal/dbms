-- Crate tables
CREATE TABLE
  student (
    rollno number PRIMARY KEY,
    name varchar(40),
    total_fine number,
    issued_books number CHECK (issued_books <= 10)
  );

CREATE TABLE
  lib (
    isbn number,
    bookname varchar(50),
    author varchar(40),
    publication varchar(20),
    cost number,
    noofcopies number,
    PRIMARY KEY (isbn)
  );

CREATE TABLE
  book (
    bookid number PRIMARY KEY,
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
    do_sub date,
    do_return date,
    fineamount number,
    status varchar(10),
    PRIMARY KEY (bookid)
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
ALTER TABLE book
ADD CONSTRAINT book_fk
FOREIGN KEY (isbn)
REFERENCES lib(isbn);

ALTER TABLE subscription
ADD CONSTRAINT subscription_fk
FOREIGN KEY (rollno)
REFERENCES student(rollno);