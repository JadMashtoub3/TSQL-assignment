IF OBJECT_ID('Sale') IS NOT NULL
DROP TABLE SALE;

IF OBJECT_ID('Product') IS NOT NULL
DROP TABLE PRODUCT;

IF OBJECT_ID('Customer') IS NOT NULL
DROP TABLE CUSTOMER;

IF OBJECT_ID('Location') IS NOT NULL
DROP TABLE LOCATION;

GO

CREATE TABLE CUSTOMER (
CUSTID	INT
, CUSTNAME	NVARCHAR(100)
, SALES_YTD	MONEY
, STATUS	NVARCHAR(7)
, PRIMARY KEY	(CUSTID) 
);


CREATE TABLE PRODUCT (
PRODID	INT
, PRODNAME	NVARCHAR(100)
, SELLING_PRICE	MONEY
, SALES_YTD	MONEY
, PRIMARY KEY	(PRODID)
);

CREATE TABLE SALE (
SALEID	BIGINT
, CUSTID	INT
, PRODID	INT
, QTY	INT
, PRICE	MONEY
, SALEDATE	DATE
, PRIMARY KEY 	(SALEID)
, FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
, FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);

CREATE TABLE LOCATION (
  LOCID	NVARCHAR(5)
, MINQTY	INTEGER
, MAXQTY	INTEGER
, PRIMARY KEY 	(LOCID)
, CONSTRAINT CHECK_LOCID_LENGTH CHECK (LEN(LOCID) = 5)
, CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);

IF OBJECT_ID('SALE_SEQ') IS NOT NULL
DROP SEQUENCE SALE_SEQ;
CREATE SEQUENCE SALE_SEQ;

GO

/* ddl above */
/* TASK 1 ADD CUSTOMER*/
IF OBJECT_ID('ADD_CUSTOMER') IS NOT NULL
DROP PROCEDURE ADD_CUSTOMER;

GO

CREATE PROCEDURE ADD_CUSTOMER @PCUSTID INT, @PCUSTNAME NVARCHAR(100) AS

BEGIN
    BEGIN TRY
        IF @PCUSTID < 1 OR @PCUSTID > 499
            THROW 50020, 'Customer ID out of range', 1

        INSERT INTO CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, STATUS) 
        VALUES (@PCUSTID, @PCUSTNAME, 0, 'OK');
    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 2627
            THROW 50010, 'Duplicate customer ID', 1
        ELSE IF ERROR_NUMBER() = 50020
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
--EXEC ADD_CUSTOMER @PCUSTID = 0, @pcustname = 'abc123'

--EXEC ADD_CUSTOMER @PCUSTID = 6, @PCUSTNAME = 'abc123'

--select * from CUSTOMER
GO
/*TASK 2 DELETE ALL CUST */
IF OBJECT_ID('DELETE_ALL_CUSTOMERS') IS NOT NULL
DROP PROCEDURE DELETE_ALL_CUSTOMERS;

GO

CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS

BEGIN 
    BEGIN TRY
        DELETE FROM CUSTOMER;
        RETURN @@ROWCOUNT
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;

GO
--EXEC ADD_CUSTOMER @PCUSTID = 6, @PCUSTNAME = 'abc123'

--EXEC DELETE_ALL_CUSTOMERS

--select * from CUSTOMER
/*TASK 3 ADD PRODUCT*/
IF OBJECT_ID('ADD_PRODUCT') IS NOT NULL
DROP PROCEDURE ADD_PRODUCT;

GO

CREATE PROCEDURE ADD_PRODUCT @PPRODID INT, @PPRODNAME NVARCHAR(100), @PPRICE MONEY AS

BEGIN
    BEGIN TRY
        IF @PPRODID < 1000 OR @PPRODID > 2500 
        THROW 50040, 'Product ID out of range', 1
        IF @PPRICE < 0 OR @PPRICE > 999.99
        THROW 50050, 'Price out of range', 1

        INSERT INTO PRODUCT (PRODID, PRODNAME, SELLING_PRICE, SALES_YTD)
        VALUES (@PPRODID, @PPRODNAME, @PPRICE, 0)
    END TRY



    BEGIN CATCH
        IF ERROR_NUMBER() = 2627
        THROW 50030, 'Duplicate product ID', 1
        ELSE IF ERROR_NUMBER() = 50040
        THROW
        ELSE IF ERROR_NUMBER() = 50050
        THROW
        ELSE
          BEGIN
              DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
              THROW 50000, @ERRORMESSAGE, 1
          END; 
    END CATCH;
END;
GO
--EXEC ADD_PRODUCT @PPRODID = 500, @PPRODNAME = 'PRODUCT', @PPRICE = 100

--EXEC ADD_PRODUCT @PPRODID = 1000, @PPRODNAME = 'PROD1000', @PPRICE = 2000

--EXEC ADD_PRODUCT @PPRODID = 2000, @PPRODNAME = 'PROD2000', @PPRICE = 100
--EXEC ADD_PRODUCT @PPRODID = 2000, @PPRODNAME = 'PROD2000', @PPRICE = 100

--SELECT * FROM PRODUCT
/* TASK 4 DELETE_ALL_PRODUCTS */
IF OBJECT_ID('DELETE_ALL_PRODUCTS') IS NOT NULL
DROP PROCEDURE DELETE_ALL_PRODUCTS;

GO

CREATE PROCEDURE DELETE_ALL_PRODUCTS AS

BEGIN 
    BEGIN TRY
        DELETE FROM PRODUCT
        RETURN @@ROWCOUNT
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END

GO
-- EXEC DELETE_ALL_PRODUCTS


/* TASK 5 GET_CUSTOMER_STRING */
IF OBJECT_ID('GET_CUSTOMER_STRING') IS NOT NULL
DROP PROCEDURE GET_CUSTOMER_STRING;

GO

CREATE PROCEDURE GET_CUSTOMER_STRING @PCUSTID INT, @pReturnString NVARCHAR(1000) OUTPUT AS

BEGIN
    BEGIN TRY
        DECLARE @CUSTNAME NVARCHAR(100), @STATUS NVARCHAR(7), @SALESYTD MONEY;

        SELECT @CUSTNAME = CUSTNAME, @STATUS = [STATUS], @SALESYTD = SALES_YTD
        FROM CUSTOMER
        WHERE CUSTID = @PCUSTID

        IF @@ROWCOUNT = 0
            THROW 50060, 'Customer ID not found', 1

        SET @pReturnString = CONCAT('Custid: ', @PCUSTID, ' Name: ', @CUSTNAME,  ' Status: ', @STATUS, ' SalesYTD: ', @SALESYTD)
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 50060
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END;
    END CATCH;
END;

GO

/* 
    BEGIN
     DECLARE @OUTPUTVALUE NVARCHAR(1000);
     EXEC GET_CUSTOMER_STRING @PCUSTID = 1, @pReturnString = @OUTPUTVALUE OUTPUT
     PRINT(@OUTPUTVALUE)
*/

/* TASK 6 UPD_CUST_SALESYTD */
IF OBJECT_ID('UPD_CUST_SALESYTD') IS NOT NULL
DROP PROCEDURE UPD_CUST_SALESYTD;
GO

CREATE PROCEDURE UPD_CUST_SALESYTD @PCUSTID INT, @PAMT MONEY AS
BEGIN
BEGIN TRY

    IF @PAMT<-999.99 OR @PAMT>999.99
    THROW 50080, 'Amount out of range', 1

    UPDATE CUSTOMER
    SET SALES_YTD += @PAMT
    WHERE CUSTID = @PCUSTID

    IF @@ROWCOUNT = 0
    THROW 50070, 'Customer ID not found', 1
END TRY

BEGIN CATCH
    if ERROR_NUMBER() in (50070, 50080)
    THROW
    ELSE
    BEGIN
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
    THROW 50000, @ERRORMESSAGE, 1
END; 
    END CATCH;
END;

GO
-- EXEC UPD_CUST_SALESYTD @PCUSTID = 0, @PAMT = 100

-- EXEC UPD_CUST_SALESYTD @PCUSTID = 1, @PAMT = 1000




/* TASK 7 GET_PROD_STRING */

IF OBJECT_ID('GET_PROD_STRING') IS NOT NULL
DROP PROCEDURE GET_PROD_STRING;
GO 
CREATE PROCEDURE GET_PROD_STRING @PRODID INT, @pReturnString NVARCHAR(1000) OUTPUT AS

BEGIN
    DECLARE @PRODNAME NVARCHAR(100), @PRICE MONEY, @SALESYTD MONEY;

    BEGIN TRY
    SELECT @PRODNAME = PRODNAME, @PRICE = SELLING_PRICE, @SALESYTD = SALES_YTD
    FROM PRODUCT 
    WHERE PRODID = @PRODID

    IF @@ROWCOUNT = 0 THROW 50090, 'Product ID not found', 1

    SET @pReturnString = CONCAT('Prodid: ', @PRODID, 'Name: ', @PRODNAME, 'Price: ', @PRICE, 'SalesYTD: ', @SALESYTD);

END TRY

BEGIN CATCH
    if ERROR_NUMBER() = 50090
    THROW
    ELSE
    BEGIN
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
    THROW 50000, @ERRORMESSAGE, 1
    END; 
    END CATCH;
END;

GO
/* 
    BEGIN
        DECLARE @OUTPUTVALUE NVARCHAR(1000);
        EXEC GET_PROD_STRING @PPRODID = 2000, @pReturnString = @OUTPUTVALUE OUTPUT
        PRINT(@OUTPUTVALUE)
    END 
*/
/*TASK 8 UPD_PROD_SALESYTD */
IF OBJECT_ID('UPD_PROD_SALESYTD') IS NOT NULL
DROP PROCEDURE UPD_PROD_SALESYTD;
GO

CREATE PROCEDURE UPD_PROD_SALESYTD @pprodid INT, @PAMT MONEY AS
BEGIN
    BEGIN TRY

    IF @PAMT<-999.99 OR @PAMT>999.99
        THROW 50110, 'Amount out of range', 1

    
    UPDATE PRODUCT SET SALES_YTD += @PAMT
    WHERE PRODID = @pprodid

    IF @@ROWCOUNT = 0 THROW 50100, 'Product ID not found', 1 
    END TRY
    BEGIN CATCH
    if ERROR_NUMBER() in (50110, 50100)
    THROW
    ELSE
BEGIN
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
    THROW 50000, @ERRORMESSAGE, 1
END; 
END CATCH;
END;

GO

-- EXEC UPD_PROD_SALESYTD @PPRODID = 2000, @PAMT = 1000

-- EXEC UPD_PROD_SALESYTD @PPRODID = 2003, @PAMT = 100

/*TASK 9 UPD_CUSTOMER_STATUS */
IF OBJECT_ID('UPD_CUSTOMER_STATUS') IS NOT NULL
DROP PROCEDURE UPD_CUSTOMER_STATUS;
GO

CREATE PROCEDURE UPD_CUSTOMER_STATUS @PCUSTID INT, @PSTATUS NVARCHAR(7) AS
BEGIN
    BEGIN TRY
    IF @PSTATUS not in ('OK','SUSPEND')
        THROW 50130, 'Invalid Status value', 1
        

        UPDATE CUSTOMER SET [STATUS] = @PSTATUS WHERE CUSTID = @PCUSTID


        IF @@ROWCOUNT = 0
        THROW 50120, 'Customer ID not found', 1
    END TRY

    
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50120, 50130)
        THROW
        ELSE
        BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
        END;
    END CATCH;
END;

GO

-- EXEC UPD_CUSTOMER_STATUS @PCUSTID = 1, @PSTATUS = "NO"

-- EXEC UPD_CUSTOMER_STATUS @PCUSTID = 5, @PSTATUS = "SUSPEND"


/*TASK 10 ADD_SIMPLE_SALE */

IF OBJECT_ID('ADD_SIMPLE_SALE') IS NOT NULL
DROP PROCEDURE ADD_SIMPLE_SALE;
GO

CREATE PROCEDURE ADD_SIMPLE_SALE @pcustid INT, @pprodid INT, @pqty INT AS
BEGIN
    BEGIN TRY

    IF ((SELECT STATUS
    FROM CUSTOMER
    WHERE CUSTID = @pcustid) NOT IN ('OK'))
        THROW 50150, 'Customer status is not OK', 1
    IF @@ROWCOUNT = 0
        THROW 50160, 'Product ID not found', 1

    IF @pqty<1 OR @pqty>999
        THROW 50140, 'Sale Quantity outside valid range', 1

    DECLARE @PRODSELLPRICE MONEY;
    SELECT @PRODSELLPRICE = SELLING_PRICE
    FROM PRODUCT
    WHERE PRODID = @pprodid
    IF @@ROWCOUNT = 0
        THROW 50170, 'Customer ID not found', 1

    DECLARE @UPDATEAMT MONEY
    SET @UPDATEAMT = @PRODSELLPRICE*@PQTY;

    EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @PAMT = @UPDATEAMT
    EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @PAMT = @UPDATEAMT

    END TRY
    BEGIN CATCH
    if ERROR_NUMBER() in (50150, 50160, 50140, 50170)
        THROW
        ELSE
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END; 
    END CATCH;
END;
GO

-- EXEC ADD_SIMPLE_SALE @PCUSTID = 1, @PPRODID = 2000, @PQTY = 1000

-- EXEC ADD_SIMPLE_SALE @PCUSTID = 1, @PPRODID = 2000, @PQTY = 2

-- EXEC ADD_SIMPLE_SALE @PCUSTID = 5, @PPRODID = 2000, @PQTY = 2

-- EXEC ADD_SIMPLE_SALE @PCUSTID = 1, @PPRODID = 2005, @PQTY = 2

/*TASK 11 SUM_CUSTOMER_SALESYTD */
IF OBJECT_ID('SUM_CUSTOMER_SALESYTD') IS NOT NULL
DROP PROCEDURE SUM_CUSTOMER_SALESYTD;
GO

CREATE PROCEDURE SUM_CUSTOMER_SALESYTD AS
BEGIN
 BEGIN TRY
   SELECT SUM(SALES_YTD)
    FROM CUSTOMER
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;

GO
-- EXEC SUM_CUSTOMER_SALESYTD

/* returns values of sum in cust table */
/* TASK 12 SUM_PRODUCT_SALESYTD */


IF OBJECT_ID('SUM_PRODUCT_SALESYTD') IS NOT NULL
DROP PROCEDURE SUM_PRODUCT_SALESYTD;
GO

CREATE PROCEDURE SUM_PRODUCT_SALESYTD AS
BEGIN
BEGIN TRY
 SELECT SUM(SALES_YTD)
    FROM PRODUCT
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    
    END CATCH;

END;
GO

-- EXEC SUM_PRODUCT_SALESYTD


/* TASK 13 GET_ALL_CUSTOMERS ***RETURN ALL CUSTOMER DETAILS*** */
IF OBJECT_ID('GET_ALL_CUSTOMERS') IS NOT NULL
DROP PROCEDURE GET_ALL_CUSTOMERS;
GO

CREATE PROCEDURE GET_ALL_CUSTOMERS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY
        SELECT *
        FROM CUSTOMER 
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO

-- DECLARE @POUTCUR CURSOR
-- DECLARE @CUSTID INT, @CUSTNAME NVARCHAR(100), @SALES_YTD MONEY, @STATUS NVARCHAR(7)
-- EXEC GET_ALL_CUSTOMERS @POUTCUR = @POUTCUR OUTPUT
-- FETCH NEXT FROM @POUTCUR INTO @CUSTID, @CUSTNAME, @SALES_YTD, @STATUS
-- WHILE @@FETCH_STATUS = 0

-- BEGIN
--    PRINT CONCAT('CustID: ', @CUSTID, ' Name: ', @CUSTNAME,' SalesYTD: ', @SALES_YTD, ' Status: ', @STATUS)
--     FETCH NEXT FROM @POUTCUR INTO @CUSTID, @CUSTNAME, @SALES_YTD, @STATUS
-- END

/* TASK 14 GET_ALL_PRODUCTS */
IF OBJECT_ID('GET_ALL_PRODUCTS') IS NOT NULL
DROP PROCEDURE GET_ALL_PRODUCTS;
GO 

CREATE PROCEDURE GET_ALL_PRODUCTS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE @OPRODID INT, @OPRODNAME NVARCHAR(100), @OSELLING_PRICE MONEY, @OSALES_YTD MONEY;
        SET @POUTCUR = CURSOR FOR SELECT PRODID, PRODNAME, SELLING_PRICE, SALES_YTD FROM PRODUCT;
        OPEN @POUTCUR;
    END TRY
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
    END CATCH
END;
GO

--    DECLARE @POUTCUR CURSOR
--    DECLARE @PRODID INT, @PRODNAME NVARCHAR(100), @SELLING_PRICE MONEY, @SALES_YTD MONEY
--    EXEC GET_ALL_PRODUCTS @POUTCUR = @POUTCUR OUTPUT
--    FETCH NEXT FROM @POUTCUR INTO @PRODID, @PRODNAME, @SELLING_PRICE, @SALES_YTD
--    WHILE @@FETCH_STATUS = 0
--    BEGIN
--    PRINT CONCAT('ProdID: ', @PRODID, ' ProdName: ', @PRODNAME,' SellingPrice: ', @SELLING_PRICE, ' SalesYTD: ', @SALES_YTD)
--    FETCH NEXT FROM @POUTCUR INTO @PRODID, @PRODNAME, @SELLING_PRICE, @SALES_YTD
-- END 
/* TASK 15 ADD_LOCATION */
IF OBJECT_ID('ADD_LOCATION') IS NOT NULL
DROP PROCEDURE ADD_LOCATION;
GO

CREATE PROCEDURE ADD_LOCATION @ploccode NVARCHAR, @pminqty INT, @pmaxqty INT AS
BEGIN
BEGIN TRY

IF LEN(@ploccode)!=5
THROW 50190, 'Location Code length invalid', 1       
IF @pminqty < 0 OR @pminqty > 999
THROW 50200, 'Minimum Qty out of range', 1
IF @pmaxqty < 0 OR @pmaxqty > 999
THROW 50210, 'Maximum Qty out of range', 1
IF @pmaxqty < @pminqty
THROW 50220, 'Minimum Qty larger than Maximum Qty', 1

    INSERT INTO LOCATION (LOCID, MINQTY, MAXQTY) 
    VALUES (@ploccode, @pminqty, @pmaxqty);

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 2627
                THROW 50180, 'Duplicate location ID', 1
        if ERROR_NUMBER() in (50190, 50200, 50210, 50220)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO

-- EXEC ADD_LOCATION @PLOCCODE ='3806', @PMINQTY = 1, @PMAXQTY = 2
-- EXEC ADD_LOCATION @PLOCCODE ='38061', @PMINQTY = 1000, @PMAXQTY = 2
-- EXEC ADD_LOCATION @PLOCCODE ='38061', @PMINQTY = 2, @PMAXQTY = 1000
-- EXEC ADD_LOCATION @PLOCCODE ='38061', @PMINQTY = 500, @PMAXQTY = 400
-- EXEC ADD_LOCATION @PLOCCODE ='38061', @PMINQTY = 2, @PMAXQTY = 4000

/* TASK 16 ADD_COMPLEX_SALE */
IF OBJECT_ID('ADD_COMPLEX_SALE') IS NOT NULL
DROP PROCEDURE ADD_COMPLEX_SALE;
GO

CREATE PROCEDURE ADD_COMPLEX_SALE @pcustid INT, @pprodid INT, @pqty INT, @pdate NVARCHAR(8) AS
BEGIN
    BEGIN TRY

        DECLARE @custstatus NVARCHAR(7);

        SELECT @custstatus = STATUS
        FROM CUSTOMER
        WHERE CUSTID = @pcustid
        IF @@ROWCOUNT = 0
            THROW 50260, 'Customer ID not found', 1

        IF (@custstatus NOT IN ('OK'))
            THROW 50240, 'Customer status is not OK', 1

        IF @pqty<1 OR @pqty>999
            THROW 50230, 'Sale Quantity outside valid range', 1

        DECLARE @PRODSELLPRICE MONEY;
        SELECT @PRODSELLPRICE = SELLING_PRICE
        FROM PRODUCT
        WHERE PRODID = @pprodid
        IF @@ROWCOUNT = 0
            THROW 50270, 'Product ID not found', 1
        
        IF (ISDATE(@pdate) = 0)
            THROW 50250, 'Date not valid', 1

        DECLARE @SALEIDFROMSEQ BIGINT;
        SELECT @SALEIDFROMSEQ = NEXT VALUE FOR SALE_SEQ;

        INSERT INTO SALE(SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) 
        VALUES (@SALEIDFROMSEQ, @pcustid, @pprodid, @pqty, @PRODSELLPRICE, CONVERT(DATE, @pdate, 112));

        DECLARE @UPDATEAMT MONEY
        SET @UPDATEAMT = @PRODSELLPRICE*@PQTY;

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @PAMT = @UPDATEAMT
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @PAMT = @UPDATEAMT

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() in (50240, 50260, 50230, 50270, 50250)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO

-- EXEC ADD_COMPLEX_SALE @PCUSTID = 1, @PPRODID = 2000, @PQTY = 1000, @pdate = '20210822'

-- EXEC ADD_COMPLEX_SALE @PCUSTID = 1, @PPRODID = 2000, @PQTY = 10, @pdate = '2021082022'

-- EXEC ADD_COMPLEX_SALE @PCUSTID = 2, @PPRODID = 2000, @PQTY = 10, @pdate = '9999999'

-- EXEC ADD_COMPLEX_SALE @PCUSTID = 10, @PPRODID = 2000, @PQTY = 10, @pdate = '20210918'

-- EXEC ADD_COMPLEX_SALE @PCUSTID = 2, @PPRODID = 1000, @PQTY = 10, @pdate = '20210918'

-- EXEC ADD_COMPLEX_SALE @PCUSTID = 2, @PPRODID = 2000, @PQTY = 1, @pdate = '20210918'

/* TASK 17 GET_ALLSALES */
IF OBJECT_ID('GET_ALLSALES') IS NOT NULL
DROP PROCEDURE GET_ALLSALES;
GO 

CREATE PROCEDURE GET_ALLSALES @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY

        SET @POUTCUR = CURSOR FOR
            SELECT *
            FROM SALE

        OPEN @POUTCUR;

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO

/*TASK 18 COUNT_PRODUCT_SALES */
IF OBJECT_ID('COUNT_PRODUCT_SALES') IS NOT NULL
DROP PROCEDURE COUNT_PRODUCT_SALES;
GO

CREATE PROCEDURE COUNT_PRODUCT_SALES @pdays INT, @pcount INT OUTPUT AS
BEGIN
    BEGIN TRY

    SELECT COUNT(SALEID) FROM SALE
    WHERE SALEDATE>=(GETDATE()-@pdays)

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO


/*TASK 19 DELETE_SALE */
IF OBJECT_ID('DELETE_SALE') IS NOT NULL
DROP PROCEDURE DELETE_SALE;
GO

CREATE PROCEDURE DELETE_SALE @saleid BIGINT OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE @salepcustid INT, @salepprodid INT, @UPDATEAMT INT;

        SELECT @saleid = MIN(SALEID) FROM SALE
        IF @saleid IS NULL
            THROW 50280, 'No Sale Rows Found', 1
        
        SELECT @salepcustid = CUSTID FROM SALE
        WHERE SALEID = @saleid;
        SELECT @salepprodid = PRODID FROM SALE
        WHERE SALEID = @saleid;
        SELECT @UPDATEAMT = QTY*PRICE FROM SALE
        WHERE SALEID = @saleid;
        
        EXEC UPD_CUST_SALESYTD @pcustid = @salepcustid, @PAMT = @UPDATEAMT
        EXEC UPD_PROD_SALESYTD @pprodid = @salepprodid, @PAMT = @UPDATEAMT

        DELETE FROM SALE
        WHERE SALEID = @saleid;

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() in (50280)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO

--ADD TO SALE BEFORE EXECUTING BELOW------
--BEGIN
--   DECLARE @OUTPUTVALUE BIGINT;
--    EXEC DELETE_SALE @saleid = @OUTPUTVALUE OUTPUT;
--    PRINT (@OUTPUTVALUE);
--END
-- GO
/* TASK 20 DELETE_ALL_SALES */

IF OBJECT_ID('DELETE_ALL_SALES') IS NOT NULL
DROP PROCEDURE DELETE_ALL_SALES;
GO

CREATE PROCEDURE DELETE_ALL_SALES AS
BEGIN
    BEGIN TRY

        DELETE FROM SALE

        UPDATE CUSTOMER
        SET SALES_YTD=0;
        UPDATE PRODUCT
        SET SALES_YTD=0;        

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO
--ADD TO SALE BEFORE EXECUTING BELOW------

-- EXEC DELETE_ALL_SALES

/* TASK 21 DELETE_CUSTOMER */
IF OBJECT_ID('DELETE_CUSTOMER') IS NOT NULL
DROP PROCEDURE DELETE_CUSTOMER;
GO

CREATE PROCEDURE DELETE_CUSTOMER @pCustid INT AS
BEGIN
    BEGIN TRY

        DELETE FROM CUSTOMER
        WHERE CUSTID = @pCustid
        IF @@ROWCOUNT = 0
            THROW 50290, 'Customer ID not found', 1

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 547
            THROW 50300, 'Customer cannot be deleted as sales exist', 1
        ELSE if ERROR_NUMBER() in (50290)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO
-- EXEC DELETE_CUSTOMER @PCUSTID = 1

/* TASK 22 DELETE_PRODUCT */

IF OBJECT_ID('DELETE_PRODUCT') IS NOT NULL
DROP PROCEDURE DELETE_PRODUCT;
GO

CREATE PROCEDURE DELETE_PRODUCT @pProdid INT AS
BEGIN
    BEGIN TRY

        DELETE FROM PRODUCT
        WHERE PRODID = @pProdid
        IF @@ROWCOUNT = 0
            THROW 50310, 'Product ID not found', 1

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 547
            THROW 50320, 'Product cannot be deleted as sales exist', 1
        ELSE if ERROR_NUMBER() in (50310)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO
-- EXEC DELETE_PRODUCT @PPRODID = xxxx

-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'JadMashtoub';
-- SELECT *
-- FROM CUSTOMER

--testing 

-- EXEC DELETE_PRODUCT @PPRODID = xxxx
-- SELECT *
-- FROM PRODUCT


 SELECT *
 FROM CUSTOMER
 SELECT *
 FROM SALE
 SELECT *
 FROM PRODUCT
 SELECT *
 FROM [LOCATION]

SELECT table_catalog [database], table_schema [schema], table_name name, table_type type
FROM INFORMATION_SCHEMA.TABLES
GO