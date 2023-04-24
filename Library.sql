-- Crate tables
CREATE TABLE
  student (
    ROLLNO number PRIMARY KEY,
    NAME varchar(40),
    M_no varchar(10),
    fine number,
    issued_books number check (issued_books <= 10)
  );

CREATE TABLE
  lib (
    isbn number PRIMARY KEY,
    bookname varchar(50),
    author varchar(40),
    publication varchar(20),
    cost number,
    copies number,
    lost_cost number,
    delay_cost number
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
    issue_date date,
    return_date date,
    actual_return_date date,
    primary KEY (bookid, rollno)
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
ALTER TABLE book ADD CONSTRAINT book_fk FOREIGN KEY (isbn) REFERENCES lib (isbn);

ALTER TABLE subscription ADD CONSTRAINT subscription_fk_roll FOREIGN KEY (rollno) REFERENCES student (rollno);

ALTER TABLE subscription ADD CONSTRAINT subscription_fk_book FOREIGN KEY (bookid) REFERENCES book (bookid);
