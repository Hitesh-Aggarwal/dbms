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
    noofcopies number,
    PRIMARY KEY (isbn)
  );

create table
  issue (
    bookid number,
    rollno number,
    issue_date number,
    return_date number,
    fine number,
    primary key (bookid)
  )
CREATE TABLE
  book (
    bookid number PRIMARY KEY,
    isbn number,
    availability varchar(1) check (
      (availability = 'A')
      or (availability = 'O')
    ) cost number,
  );

CREATE TABLE
  subscription (
    bookno number,
    rollno number,
    do_sub date,
    do_return date,
    fineamount number,
    status varchar(10),
    primary KEY (BOOKNO, ROLLNO)
  );
