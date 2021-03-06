
\c postgres test

drop table if exists advise_index;
drop view if exists advise_index;

/* create the advise_index same as provided in the contrib module */;
create table advise_index( reloid oid, attrs integer[], benefit real,
							index_size integer, backend_pid integer,
							timestamp timestamptz);

/* set the client to see the log messages generated by the Adviser */;
set client_min_messages to log;

/* As expected, the EXPLAIN will work */;
explain select * from t where a = 100;

select * from advise_index;

/* Now lets drop the advise_index and see what ERROR it throws */;
drop table if exists advise_index;
drop view if exists advise_index;

explain select * from t where a = 100;

/* create another object by the same name (in the same namespace) */;
create index advise_index on t1(a);

/* advise_index does exist, but its not a table or view! */;
explain select * from t where a = 100;

/* now create a table named advise_index, but with a different signature! */;
drop index advise_index;

create table advise_index(a int);

/* This ERROR comes from the executor, but we still see our DETAIL and HINT */;
explain select * from t where a = 100;

/* create a table with same signature but different name */;
drop table if exists advise_index;
drop view if exists advise_index;

drop table if exists advise_index_data cascade;

create table advise_index_data( reloid oid, attrs integer[], benefit real,
								index_size integer, backend_pid integer,
								timestamp timestamptz);

/* and a view on that table */;
create view advise_index as select * from advise_index_data;

/* now try to insert into the view, and notice the ERROR, DETAIL and HINT from executor */;
explain select * from t where a = 100;

/* now create a RULE on the view that redirects the INSERTs into the table */;
create or replace rule advise_index_insert as
ON INSERT to advise_index
do instead
INSERT into advise_index_data values (new.reloid, new.attrs, new.benefit,
										new.index_size, new.backend_pid,
										new.timestamp) ;

/* and voila, (internal) INSERT into the view succeeds! */;
explain select * from t where a = 100;

/* Now, lets try what happens under a read-only transaction */;
begin;

set transaction_read_only=t;

show transaction_read_only;

explain select * from t where a = 100;

end;

select * from advise_index;

select * from advise_index_data;
