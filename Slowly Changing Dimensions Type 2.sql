-- create source table 
CREATE TABLE source_table 
(
    employee_id int PRIMARY KEY,
    employee_name varchar(20) NOT NULL,
    address varchar(20) NOT NULL
);

-- insert data in the source table 
INSERT ALL
  INTO source_table (employee_id, employee_name, address) VALUES (1, 'John Doe', '123 Main St')
  INTO source_table (employee_id, employee_name, address) VALUES (2, 'Jane Smith', '456 Elm St')
  INTO source_table (employee_id, employee_name, address) VALUES (3, 'Alice Johnson', '789 Oak St')
SELECT * FROM dual;

-- create table target table 
CREATE TABLE target_table
(
    employee_id NUMBER NOT NULL,
    employee_name VARCHAR2(20) NOT NULL,
    address VARCHAR2(20) NOT NULL,
    last_modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status NUMBER DEFAULT 1 NOT NULL,
    surrogate_key NUMBER NOT NULL
);

-- create sequence for the surrogate key to generate every time 
CREATE SEQUENCE surrogate_key
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1;

-- this step is for stored procedures with slowly changing dimension type 2 
CREATE OR REPLACE PROCEDURE slowly_changing_dimension_type2
AS
BEGIN
    MERGE INTO target_table t1
    USING source_table s1
    ON (t1.employee_id=s1.employee_id)
    WHEN MATCHED THEN 
    UPDATE SET t1.status = 0 WHERE s1.address <> t1.address ;
     
    MERGE INTO target_table t2
    USING source_table s2
    ON (t2.employee_id=s2.employee_id AND t2.address = s2.address )    
    WHEN MATCHED THEN
        UPDATE SET t2.status = CASE WHEN t2.address <> s2.address THEN 0 ELSE t2.status END
    WHEN NOT MATCHED THEN
    INSERT VALUES(s2.employee_id,s2.employee_name,s2.address,CURRENT_TIMESTAMP,1,surrogate_key.nextval);
END; 

-- Execute the stored procedure
exec slowly_changing_dimension_type2 ;

-- Update in the source table 
UPDATE source_table SET address = '150 tahrer' WHERE employee_id = 5;

-- insert in the source table 
INSERT INTO source_table (employee_id, employee_name, address)
VALUES (6, 'Ahmed talaat', '90 ahmed shawki'); 

-- see the changes in the target table 
SELECT * FROM target_table
ORDER BY employee_id,last_modified_date ;

-- see the original table source 
SELECT * FROM source_table;
