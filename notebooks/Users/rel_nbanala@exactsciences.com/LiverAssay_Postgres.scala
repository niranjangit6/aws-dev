// Databricks notebook source
val PostgresDatabase = "Postgres_test"

//val jdbcHostname = dbutils.secrets.get(scope = "postgres_liverassay", key = "app01-rwc-lb-qa-01-database.cprm5tq1il10.us-west-2.rds.amazonaws.com")
val jdbcDatabase = "sampleminded"
val jdbcUsername = dbutils.secrets.get(scope = "postgres_liverassay", key = "Username")
val jdbcPassword = dbutils.secrets.get(scope = "postgres_liverassay", key = "Password")

val jdbcHostname = "app01-rwc-lb-qa-01-database.cprm5tq1il10.us-west-2.rds.amazonaws.com"
//val jdbcDatabase = "sampleminded"
//val jdbcUsername = "sendapally_read_only"
//val jdbcPassword = "uxf1$mVnZ4M4InRbMeY3"
val table_names = "information_schema.tables"
//val col_names = "information_schema.columns"
// Create the JDBC URL without passing in the user and password parameters.
val jdbcUrl = s"jdbc:postgresql://${jdbcHostname}/${jdbcDatabase}"

spark.sql(s"drop database if exists ${PostgresDatabase} cascade")
spark.sql(s"create database if not exists ${PostgresDatabase}")
spark.sql(s"use ${PostgresDatabase}")

// Create a Properties() object to hold the parameters.
import org.apache.spark.sql.functions.{concat, lit,col}
import java.util.Properties
val connectionProperties = new Properties()

connectionProperties.put("user", s"${jdbcUsername}")
connectionProperties.put("password", s"${jdbcPassword}")


val getting_table_names=spark
      .read
      .format("jdbc")
      .option("url", jdbcUrl)
      .option("driver", "org.postgresql.Driver")
      .option("dbtable", table_names)
      .option("user", jdbcUsername)
      .option("password", jdbcPassword)
      .load().createOrReplaceTempView("table_names_vw")

val getting_data = (spark.read.format("jdbc")
.option("url", jdbcUrl)
.option("user", jdbcUsername)
.option("password", jdbcPassword) 
.option("driver", "org.postgresql.Driver") 
)

//val df=spark.sql("select distinct table_schema, table_name  from table_names_vw where column_name = 'id' and   table_schema like 'public' ")
val df=spark.sql("select table_schema,table_name  from table_names_vw where table_schema like 'public' and table_type like 'BASE TABLE'")
val df1=df.select(concat(col("table_schema"),lit('.'),
    col("table_name")).as("FullName"))


val listValues=df1.select("FullName").map(f=>f.getString(0))
                 .collect.toList
println(listValues)

for(tab_name<-listValues){
  var View_Name = tab_name.substring(tab_name.indexOf(".")+1)
  //println(View_Name)
  getting_data.option("dbtable",tab_name).load().createOrReplaceTempView(View_Name)
  
  spark.sql(s"create or replace table ${View_Name} USING Delta as (select * from ${View_Name})")
  
  //Check if object exists in database
  //      if (spark.catalog.tableExists(tab_name))
  //      {
  //        println("started merging into table"+tab_name)
  //        spark.sql(f"MERGE INTO ${View_Name} as t USING(SELECT * FROM ${View_Name} ) as s ON t.id = s.id WHEN MATCHED THEN UPDATE SET * WHEN NOT MATCHED THEN INSERT *")
  //        spark.sql(f"DELETE from ${View_Name}")
  //        spark.sql(f"INSERT INTO ${View_Name} select * from tab_name")
          
  //      }
  //      else
  //      {
  //        println("started create table "+tab_name)
  //        spark.sql(s"CREATE OR REPLACE TABLE ${View_Name} USING DELTA AS (SELECT * FROM ${View_Name})")
  //        println("created table "+View_Name)
  //      }
}

// COMMAND ----------

