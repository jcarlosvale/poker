drop table if exists log_tbl;
CREATE TABLE public.log_tbl (
    file_name varchar NOT NULL,
    line varchar NOT NULL,
    line_number int NOT NULL,
    message varchar NOT NULL,
    created_at timestamp NOT NULL
);