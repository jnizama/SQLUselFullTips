
/**********WORKING WITH SCHEMAS******************
Keywords
 CREATE SCHEMA 
 AUTHORIZATION
*************************************************/

--Create an user in current database
CREATE SCHEMA SCHDemo Authorization jnizama   
--Create tables in a Schema
CREATE TABLE SCHDemo.Tbl1 (col1 int primary key, col2 nvarchar(200)) 
CREATE TABLE SCHDemo.Tbl2 (col1 int primary key, col2 nvarchar(200)) 
CREATE TABLE SCHDemo.Tbl3 (col1 int primary key, col2 nvarchar(200)) 

CREATE TABLE SCHDemo2.Tbl4 (col1 int primary key, col2 nvarchar(200)) 
CREATE TABLE SCHDemo2.Tbl5 (col1 int primary key, col2 nvarchar(200)) 

--Moving Objects between schema (move Tbl2 From SCHDemo to SCHDemo2)
ALTER SCHEMA  SCHDemo2 TRANSFER SCHDemo.Tbl2

