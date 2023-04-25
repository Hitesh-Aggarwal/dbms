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

insert into lib values(1234,'Lord Of Chaos', 'Robert Jordan', 'MacMillan', 10, 100, 1);
insert into lib values(1235,'Fires Of Heaven', 'Robert Jordan', 'MacMillan', 11, 100, 1);

insert into book values(NULL, 1234, 'A');
insert into book values(NULL, 1235, 'A');

insert into subscription values(1,1, to_date('01-02-2023','dd-mm-yyyy'), to_date('27-02-2023','dd-mm-yyyy'), to_date('01-03-2023','dd-mm-yyyy'));
insert into subscription values(1,2, to_date('01-02-2023','dd-mm-yyyy'), to_date('27-02-2023','dd-mm-yyyy'), to_date('25-02-2023','dd-mm-yyyy'));


------------------ plsql starts here -----------------------

create or replace procedure add_student(roll_no in number, s_name in varchar,
 M_no in varchar)
is
begin
  insert into student values(roll_no, s_name, M_no, 0,0);
end;


declare
  roll_no number;
  name varchar(50);
  M_no varchar(10);
begin
  roll_no := &roll_no;
  name := &name;
  M_no := &M_no;
  add_student(roll_no,name,M_no);
end;


create or replace procedure add_first_book(
  isbn_no in number,
  bookname in varchar,
  author in varchar,
  publication in varchar,
  lost_cost in number,
  delay_cost in number) is
begin
  insert into lib values(isbn_no, bookname,author,publication,1,lost_cost,
    delay_cost);
  insert into book values(NULL, isbn_no, 'A');
end;


create or replace procedure add_more_books(isbn_no in number) is
begin
  insert into book values(NULL, isbn_no, 'A');
  update lib set copies = copies + 1 where lib.isbn = isbn_no;
end;


declare
  counter number;
  isbn_no number;
  bookname varchar(50);
  author varchar(40);
  publication varchar(20);
  lost_cost number;
  delay_cost number;
begin
  isbn_no := &isbn_no;
  select count(*) into counter from lib where lib.isbn = isbn_no;
  if counter > 0 then
    add_more_books(isbn_no);
  else
    bookname := &bookname;
    author := &author;
    publication := &publication;
    lost_cost := &lost_cost;
    delay_cost := &delay_cost;
    add_first_book(isbn_no,bookname,author,publication,lost_cost,delay_cost);
  end if;
end;


create or replace procedure return_book(book_id number, roll_no number) is
i_date date;
r_date date;
ar_date date;
isbn_no number;
d_cost number;
no_of_copies number;
fine_amount number;
begin
  select isbn into isbn_no from book where bookid = book_id;
  select copies, delay_cost into no_of_copies, d_cost from lib
  where isbn = isbn_no;
  no_of_copies := no_of_copies + 1;
  update book set availability = 'A' where bookid = book_id;
  update lib set copies = no_of_copies where isbn = isbn_no;
  select issue_date, return_date, actual_return_date into i_date, r_date,
  ar_date from subscription where bookid = book_id and rollno = roll_no;
  if ar_date > r_date then
    fine_amount := (ar_date - r_date) * d_cost;
    update student set fine = fine_amount where rollno = roll_no;
    dbms_output.put_line('Fine amount: ' || fine_amount);
  end if;
  update student set issued_books = issued_books - 1 where rollno = roll_no;
  delete from subscription where bookid = book_id and rollno = roll_no;
end;

declare
book_id number;
roll_no number;
r_date varchar(15);
ret_date date;
begin
  book_id := &book_id;
  roll_no := &roll_no;
  r_date := &r_date;
  ret_date := to_date(r_date, 'yyyy-mm-dd');
  update subscription set actual_return_date = ret_date where rollno = roll_no and book_id = bookid;
  return_book(book_id,roll_no);
end;

create or replace procedure pay_fine(roll_no number) is
begin
  update student set fine = 0 where rollno = roll_no;
end;

declare
rollno number;
begin
  rollno := &rollno;
  pay_fine(rollno);
end;

-- procedure 6 --
-- BOOK INFO --
declare
  i_sbn number;
  c_opies lib.copies%type;
  d_elay_cost lib.delay_cost%type;
  b_ook_name lib.bookname%type;
  l_ost_cost lib.lost_cost%type;
  p_ublisher lib.publication%type;
  a_uthor lib.author%type;
  procedure book_info(i_sbn in number) is
  begin
    select copies,delay_cost,bookname,lost_cost,publication,author into c_opies,d_elay_cost,b_ook_name,l_ost_cost,p_ublisher,a_uthor from lib where lib.isbn=i_sbn;
    dbms_output.put_line('Copies : '||c_opies);
    dbms_output.put_line('delay_cost : '||d_elay_cost);
    dbms_output.put_line('book_name : '||b_ook_name);
    dbms_output.put_line('lost_cost : '||l_ost_cost);
    dbms_output.put_line('publisher : '||p_ublisher);
    dbms_output.put_line('author : '||a_uthor);
  end;
begin
  dbms_output.put_line('Enter the book number');
  i_sbn:=&i_sbn;
  book_info(i_sbn);
end;

-- Get the total fine of a student
create or replace procedure retreive_pending_fine(roll in number, fine in out number) as
  del_cost number;
  isb_no number;
  days number;
  cursor c is select * from subscription where rollno=roll;
begin
  for rec in c loop
    dbms_output.put_line(to_char(rec.return_date));
    dbms_output.put_line(to_char(rec.actual_return_date));
    if rec.actual_return_date > rec.return_date then
      select isbn into isb_no from book where bookid=rec.bookid;
      select delay_cost into del_cost from lib where isbn=isb_no;
      days := rec.actual_return_date - rec.return_date;
      fine := fine + days*del_cost;
    end if;
  end loop;
  -- dbms_output.put_line('Done with procedure');
end;

declare
  roll number;
  fine number;
begin
  roll = &roll;
  fine = 0;
  retreive_pending_fine(roll,fine);
  dbms_output.put_line('Fine = ' || fine);
end;


-- similar_author_books
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

-- procedure 8 --
-- Get student details from book id
declare
book_id subscription.bookid%type;
roll_no subscription.rollno%type;
n_ame student.name%type;
mobile_num student.M_no%type;
f_ine student.fine%type;
books_issued student.issued_books%type;
procedure student_details(book_id in number) is
begin
select subscription.rollno into roll_no from subscription where bookid=book_id;
select student.name,student.M_no,student.fine,student.issued_books into n_ame,mobile_num,f_ine,books_issued from student where student.rollno=roll_no;
dbms_output.put_line('Name : '||n_ame);
dbms_output.put_line('Mobile Number : '||mobile_num);
dbms_output.put_line('fine : '||f_ine);
dbms_output.put_line('Number of books issued : '||books_issued);
end;
begin
dbms_output.put_line('Enter the book id of the book');
book_id:=&book_id;
student_details(book_id);
end;

-- Exec similar_author_books('BookName')
declare
author varchar(40);
begin
  author := &author;
  similar_author_books(author);
end;


-- Issue a book (procedure 1)
create or replace procedure issue_book(roll_no in number, book_id in number, issue_date in date) is
isbn_no number;
begin
  update student set issued_books = issued_books+1 where rollno = roll_no;
  select isbn into isbn_no from book where bookid = book_id;
  update lib set copies = copies - 1 where isbn = isbn_no;
  update book set availability = 'O' where bookid = book_id;
  insert into subscription values (book_id,roll_no,issue_date,issue_date + 30,NULL);
end;

declare
roll_no number;
book_id number;
i_date varchar(15);
issue_date date;
begin
  roll_no := &roll_no;
  book_id := &book_id;
  i_date := &i_date;
  issue_date := to_date(i_date, 'yyyy-mm-dd');
  issue_book(roll_no,book_id,issue_date);
end;
