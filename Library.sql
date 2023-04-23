-- Crate tables
CREATE TABLE
  student (
    ROLLNO number PRIMARY KEY,
    NAME varchar(40),
    total_fine number,
    issued_books number check (issued_books <= 10)
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
    availability varchar(1) check (
      (availability = 'A')
      or (availability = 'O')
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
    primary KEY (bookid)
  );

-- Drop tables
drop table student;
drop table subscription;
drop table lib;
drop table book;

-- select statements
select * from student;
select * from subscription;
select * from lib;
select * from book;

-- Add foreign keys now.
ALTER TABLE book
ADD CONSTRAINT book_fk
FOREIGN KEY (isbn)
REFERENCES lib(isbn);

ALTER TABLE subscription
ADD CONSTRAINT subscription_fk
FOREIGN KEY (rollno)
REFERENCES student(rollno);
