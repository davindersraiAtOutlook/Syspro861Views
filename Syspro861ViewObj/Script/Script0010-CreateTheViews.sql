DECLARE @TableName NVARCHAR(50)='ArCustomer'
DECLARE @FieldName NVARCHAR(50),  @DataType NVARCHAR(50),  @CharSize INT
DECLARE @v61CharLength INT, @v61LeadingZeroPadding CHAR(50)='''0000000000000000000000000000000000000000000000'''
DECLARE @DecimalPrecision INT, @DecimalScale INT
DECLARE @Sql varchar(MAX) =' '
DECLARE @SqlChar varchar(MAX) =' '
DECLARE @SqlDecimal varchar(MAX) = ' '
DECLARE @SqlDateTime varchar(MAX) =' '
--Handle data type CHAR, DECIMAL,DATETIME




SET @Sql=' CREATE VIEW v61_' + @TableName + ' AS  SELECT '
DECLARE table_Cursor CURSOR FOR SELECT  COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION, NUMERIC_SCALE FROM SysproCompanyEdu1.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@TableName
OPEN table_Cursor
FETCH NEXT FROM table_Cursor INTO @FieldName, @DataType, @CharSize, @DecimalPrecision, @DecimalScale
WHILE @@FETCH_STATUS =0
BEGIN	
	--DETECT IS THIS THE LAST ROW
	--PRINT @DataType + @FieldName
	IF @DataType IN ('char','varchar')
	BEGIN
		--If a field is not found in the old database then use the field size from the new database
		SET @v61CharLength=ISNULL(( SELECT CHARACTER_MAXIMUM_LENGTH FROM MyApp.dbo.v61TableDef WHERE TABLE_NAME=@TableName AND COLUMN_NAME=@FieldName),50)		
		IF @FieldName IN(SELECT KEY_COLUMN FROM MyApp.dbo.TableKeyFields WHERE TABLE_NAME=@TableName AND KEY_COLUMN=@FieldName AND LEADING_ZERO_REQUIRED=1)
		BEGIN
			SET @SqlChar=@SqlChar + '  CAST(RIGHT(' +  @v61LeadingZeroPadding +   '+ ' + @FieldName + ',' + cast(@v61CharLength as char(3))  + ') as CHAR(' + CAST(@v61CharLength as varchar(5)) + ')) AS ' + @FieldName + ', '			
		END 
		ELSE --not leading zeros
		BEGIN
			SET @SqlChar=@SqlChar + ' CAST(' + @FieldName + ' as CHAR(' + CAST(@v61CharLength as varchar(5)) + ')) AS ' + @FieldName + ', '
		END
	END
	IF @DataType IN ('decimal')
	BEGIN		
		( SELECT @DecimalPrecision= NUMERIC_PRECISION, @DecimalScale=NUMERIC_SCALE FROM MyApp.dbo.v61TableDef WHERE TABLE_NAME=@TableName AND COLUMN_NAME=@FieldName)		
		BEGIN
			SET @SqlDecimal=@SqlDecimal + ' CAST(' + @FieldName + ' as DECIMAL(' + CAST(@DecimalPrecision as varchar(5)) + ',' +  + CAST(@DecimalScale as varchar(5)) + + ')) AS ' + @FieldName + ', '			
		END
	END
	IF @DataType IN ('datetime')
	BEGIN		
		BEGIN
			SET @SqlDateTime=@SqlDateTime + '  ' + @FieldName + ', '
		END
	END
	FETCH NEXT FROM table_Cursor INTO @FieldName, @DataType, @CharSize, @DecimalPrecision, @DecimalScale
END
PRINT @SqlChar
PRINT @SqlDecimal
PRINT @SqlDateTime

EXEC sp_executesql @Sql + @SqlChar

CLOSE table_Cursor
DEALLOCATE table_Cursor

