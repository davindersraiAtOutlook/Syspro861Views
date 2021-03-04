DECLARE @CurrentTableName NVARCHAR(250)
DECLARE @ViewPrefix NVARCHAR(10)='v61_'
DECLARE @CurrentViewName NVARCHAR(250)
DECLARE @SqlDropView NVARCHAR(MAX)
DECLARE table_Cursor CURSOR FOR SELECT [TABLE_NAME] FROM MyApp.dbo.v61Tables--WHERE TABLE_NAME IN('ArCustomer','ArInovice','SorMaster','SorMasterRep') 
OPEN table_Cursor
FETCH NEXT FROM table_Cursor INTO @CurrentTableName
WHILE @@FETCH_STATUS =0
BEGIN
	PRINT 'Processing Table: ' + @CurrentTableName
	SET @CurrentViewName=@ViewPrefix + @CurrentTableName
	--Did we previously create the view 
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@CurrentViewName) AND type in (N'V'))
	BEGIN
	--DROP TABLE [dbo].[AdmAppStore]
		PRINT 'Dropping view ' + @CurrentViewName
		SET @SqlDropView=' DROP VIEW ' + @CurrentViewName 
		EXEC sp_executesql @SqlDropView
	END
	--If so lets DROP it first


		DECLARE @FieldName NVARCHAR(50),  @DataType NVARCHAR(50),  @CharSize INT
		DECLARE @v61CharLength INT, @v61LeadingZeroPadding CHAR(50)='''0000000000000000000000000000000000000000000000'''
		DECLARE @DecimalPrecision INT, @DecimalScale INT
		DECLARE @CountColumns INT =( SELECT COUNT(*) FROM SysproCompanyEdu1.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@CurrentTableName AND DATA_TYPE <>'timestamp')
		DECLARE @CurrentColumnCount INT=0, @Comma AS VARCHAR(5)=', '
		DECLARE @Sql nvarchar(MAX) =' '
		--Handle data type CHAR, DECIMAL,DATETIME
		PRINT @CountColumns
		SET @Sql=' CREATE VIEW ' + @CurrentViewName + ' AS  SELECT '
		DECLARE currentTableCursor CURSOR FOR SELECT  COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION, NUMERIC_SCALE FROM SysproCompanyEdu1.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@CurrentTableName AND DATA_TYPE<>'timestamp'
		OPEN currentTableCursor
		FETCH NEXT FROM currentTableCursor INTO @FieldName, @DataType, @CharSize, @DecimalPrecision, @DecimalScale
		WHILE @@FETCH_STATUS =0
		BEGIN	
			--DETECT IS THIS THE LAST ROW
			--PRINT @DataType + @FieldName
			IF @CurrentColumnCount=(@CountColumns-1)
			BEGIN
				SET @Comma=' '
			END
			IF @DataType IN ('char','varchar')
			BEGIN
				--If a field is not found in the old database then use the field size from the new database
				SET @v61CharLength=ISNULL(( SELECT CHARACTER_MAXIMUM_LENGTH FROM MyApp.dbo.v61TableDef WHERE TABLE_NAME=@CurrentTableName AND COLUMN_NAME=@FieldName),50)		
				IF @FieldName IN(SELECT KEY_COLUMN FROM MyApp.dbo.TableKeyFields WHERE TABLE_NAME=@CurrentTableName AND KEY_COLUMN=@FieldName AND LEADING_ZERO_REQUIRED=1)
				BEGIN
					SET @Sql=@Sql + '  CAST(RIGHT(' +  @v61LeadingZeroPadding +   '+ ' + @FieldName + ',' + cast(@v61CharLength as char(3))  + ') as CHAR(' + CAST(@v61CharLength as varchar(5)) + ')) AS ' + @FieldName + @Comma			
				END 
				ELSE --not leading zeros
				BEGIN
					SET @Sql=@Sql + ' CAST(' + @FieldName + ' as CHAR(' + CAST(@v61CharLength as varchar(5)) + ')) AS ' + @FieldName + @Comma
				END
			END
			IF @DataType IN ('decimal')
			BEGIN		
				( SELECT @DecimalPrecision= NUMERIC_PRECISION, @DecimalScale=NUMERIC_SCALE FROM MyApp.dbo.v61TableDef WHERE TABLE_NAME=@CurrentTableName AND COLUMN_NAME=@FieldName)		
				BEGIN
					SET @Sql=@Sql + ' CAST(' + @FieldName + ' as DECIMAL(' + CAST(@DecimalPrecision as varchar(5)) + ',' +  + CAST(@DecimalScale as varchar(5)) + + ')) AS ' + @FieldName + @Comma			
				END
			END
			IF @DataType IN ('datetime')
			BEGIN		
				BEGIN
					SET @Sql=@Sql + '  ' + @FieldName + @Comma
				END
			END
			SET @CurrentColumnCount=@CurrentColumnCount+1
			FETCH NEXT FROM currentTableCursor INTO @FieldName, @DataType, @CharSize, @DecimalPrecision, @DecimalScale
		END
		CLOSE currentTableCursor
		DEALLOCATE currentTableCursor

		SET @Sql=@Sql + ' FROM ' + @CurrentTableName
		PRINT @Sql
		EXEC sp_executesql @Sql

FETCH NEXT FROM table_Cursor INTO @CurrentTableName
END
CLOSE table_Cursor
DEALLOCATE table_Cursor