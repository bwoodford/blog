+++
title = "Transaction Isolation Levels"
date = 2023-10-13T06:58:55-05:00
draft = true
description = "Transaction Isolation Levels - explained with SQL Server."
tags = ['Databases', 'SQL Server']
+++

*Imagine* you're at your work computer. You just recieved an urgent email, it's from your boss. They're instructing you to create a TPS report that's due by EOD. Being the great employee that you are you take no time at all, you crack open your terminal, and log on to the local SQL Server database.

As a well seasoned employee, you already know that this report calls for a transaction, so you can group multiple SQL operations into one atomic unit. You start your transaction:

```shell
1> USE CorporateDB;
2> BEGIN TRANSACTION TpsReport;
```

You begin to type the needed queries for your TpsReport, outputting the results to the terminal:

```shell
3> SELECT * FROM Sales;
SaleID      ProductID   SaleDate         CustomerName               Quantity    SaleAmount
----------- ----------- ---------------- -------------------------- ----------- ------------
          1         101       2023-10-01 Philly Joe Jones                     3       150.00
          2         102       2023-10-02 Ahmad Jamal                          2        75.50
          3         103       2023-10-03 Ronnie Foster                        5       250.25
          4         101       2023-10-03 Eric Dolphy                          4       200.00
          5         104       2023-10-04 Elvin Jones                          1        50.75

4> SELECT SUM(SaleAmount) FROM Sales;
----------------------------------------
                                 1226.50

5> SELECT * FROM Sales;
SaleID      ProductID   SaleDate         CustomerName                Quantity    SaleAmount
----------- ----------- ---------------- --------------------------- ----------- ------------
          1         101       2023-10-01 Philly Joe Jones                      3       150.00
          2         102       2023-10-02 Ahmad Jamal                           2        75.50
          3         103       2023-10-03 Ronnie Foster                         5       250.25
          4         101       2023-10-03 Eric Dolphy                           4       200.00
          5         104       2023-10-04 Elvin Jones                           1        50.75
          6         101       2023-10-05 Stevie Wonder                         1       500.00

6> COMMIT TRANSACTION TpsReport;
```

Oh, no - what's this! Your sum from statement 4 shows 1226.50, but your first query from statement 3 only sums to 726.50. How could this be! Your TPS report is ruined. You start analyzing the results further. You begin to notice that the query from statement 5 is showing an extra row, but how could this be? You didn't insert any new data into the table with your transaction. It must have been another fellow employee. But how are you supposed to complete your TPS report when you can see your coworkers changes?

Introducing 🥁... **Transaction Isolation Levels**. By configuring a transaction isolation level on the TpsReport, you can set the absence or presence of *read phenomena*. Read phenoma fall under these three types:

| Name | Summary |
| ---- | ------- |
| Dirty Read | A transaction retrieves a modified row from another transaction, but the modification has not been committed. |
| Non-repeatable Read | A transaction retrieves a row twice, but another transaction commits a change to that row between the first and second retrieval. |
| Phantom Read | A transaction retrieves a set of rows twice, but another transaction commits a new entry between the first and second retrieval. | 

The TpsReport transaction above was displaying an unexepected new row, or a Phantom Read as defined in the table. To fix this, we need to find a transaction isolation level that removes Phantom Reads -- and while we're at it, let's remove Dirty Reads and Non-repeatable Reads too.

Opening up the SQL Server documentation, you notice five different transaction isolation levels [^1]: Read uncommitted, Read committed, Repeatable read, Snapshot and Serializable:

- Read uncommitted: Statements can read rows that have been modified by other transactions but not yet committed.
- Read committed: Statements cannot read data that has been modified but not committed by other transactions.
- Repeatable read: Statements cannot read data that has been modified but not yet committed by other transactions and that no other transactions can modify data that has been read by the current transaction until the current transaction completes.
- Snapshot: Data read by any statement in a transaction will be the transactionally consistent version of the data that existed at the start of the transaction.
- Serializable: Similar functionality to Snapshot, but places range locks on all search conditions within a transaction, requiring the transaction to complete before range locks are released.

The documentation even provides you with this handy table, showing the relationship between read phenomena and transaction isolation level (with X marking each occurrence)[^2]:

| Transaction Isolation Level | Dirty reads | Nonrepeatable reads | Phantoms |
| ---- | ---- | ---- | ---- |
| Read uncommitted | X | X | X |
| Read committed | -- | X | X |
| Repeatable read | -- | -- | X |
| Snapshot | -- | -- | -- |
| Serializable | -- | -- | -- |

You have two choices for your requirements, Snapshot and Serializable, so what's the catch? Digging into the documentation you notice that Serializable offers the highest level of data integrity -- at the cost of performance, while Snapshot eliminates phantom reads with less overhead. For this use case, you decide to add the Snapshot isolation level to your TPS report:

```shell
1> USE CorporateDB;
2> SET TRANSACTION ISOLATION LEVEL SNAPSHOT
3> BEGIN TRANSACTION TpsReport;
4> SELECT * FROM Sales;
SaleID      ProductID   SaleDate         CustomerName               Quantity    SaleAmount
----------- ----------- ---------------- -------------------------- ----------- ------------
          1         101       2023-10-01 Philly Joe Jones                     3       150.00
          2         102       2023-10-02 Ahmad Jamal                          2        75.50
          3         103       2023-10-03 Ronnie Foster                        5       250.25
          4         101       2023-10-03 Eric Dolphy                          4       200.00
          5         104       2023-10-04 Elvin Jones                          1        50.75
          6         101       2023-10-05 Stevie Wonder                        1       500.00


5> SELECT SUM(SaleAmount) FROM Sales;
----------------------------------------
                                 1226.50

6> SELECT * FROM Sales;
SaleID      ProductID   SaleDate         CustomerName                Quantity    SaleAmount
----------- ----------- ---------------- --------------------------- ----------- ------------
          1         101       2023-10-01 Philly Joe Jones                      3       150.00
          2         102       2023-10-02 Ahmad Jamal                           2        75.50
          3         103       2023-10-03 Ronnie Foster                         5       250.25
          4         101       2023-10-03 Eric Dolphy                           4       200.00
          5         104       2023-10-04 Elvin Jones                           1        50.75
          6         101       2023-10-05 Stevie Wonder                         1       500.00

7> COMMIT TRANSACTION TpsReport;
```

Amazing, the TpsReport looks perfect - not an updated, or inserted row in sight.

[^1]: Sourced from [SET TRANSACTION ISOLATION LEVEL (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-ver16)
[^2]: Sourced from [Transaction Isolation Levels (ODBC)](https://learn.microsoft.com/en-us/sql/odbc/reference/develop-app/transaction-isolation-levels?view=sql-server-ver16)