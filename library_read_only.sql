CREATE TABLE
  student (rollno number PRIMARY KEY, name varchar(40));

CREATE TABLE
  lib (
    bookname varchar(50),
    author varchar(40),
    publication varchar(20),
    noofcopies number,
    PRIMARY KEY (bookname, author)
  );

CREATE TABLE
  books (
    bookno number PRIMARY KEY,
    bookname varchar(15),
    available varchar(10),
    subscribed_to number
  );

CREATE TABLE
  subscription (
    bookno number,
    rollno number,
    do_sub date,
    do_return date,
    fineamount number,
    status varchar(10),
    PRIMARY KEY (bookno, rollno)
  );
