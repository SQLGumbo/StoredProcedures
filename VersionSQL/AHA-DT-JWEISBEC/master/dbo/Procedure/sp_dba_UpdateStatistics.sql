/****** Object:  Procedure [dbo].[sp_dba_UpdateStatistics]    Committed by VersionSQL https://www.versionsql.com ******/


/******************************************************************************
*
*   NAME      : master.dbo.sp_dba_UpdateStatistics
*   TYPE      : Stored Procedure
*   DESC      : Rebuilds statistics for the databases on the server.  This
*               procedure utilizes the sp_updatestats found in the master
*               database.
*   INPUT     : @DBName - '*' for updating All Databases (Default)
*                         'S' for system databases
*                         'U' for user databases
*                         '<database_name>' to update an individual database 
*               @Resample - 'resample' Specifies to use the RESAMPLE option of the 
*                                      UPDATE STATISTICS command 
*                           'NO'       Specifies not to use the RESAMPLE option of 
*                                      the UPDATE STATISTICS command (Default) 
*               @ExcludeDB - A list of databases to excluded for updating stats. 
*                           Comma Delimited List of Databases in Double Quotes 
*                           to be excluded from updating.
*                           CAUTION: Ensure proper syntax (eg '"pubs","Northwind"')
*                            
*   OUTPUT    : None
*
*
*   EXAMPLES  : EXEC sp_dba_UpdateStatistics  '*', 'resample', '"pubs","Northwind"'
*
*   MODIFIED  :  09-jul-2018  jsw  Created
*
******************************************************************************/

CREATE  PROCEDURE  [dbo].[sp_dba_UpdateStatistics] @DBName            SYSNAME         = '*', 
                                          @Resample          VARCHAR(8)      = 'NO',
                                          @ExcludedDB        VARCHAR(2048)   =  NULL
AS
BEGIN
   SET NOCOUNT ON
   DECLARE  @SQLString        VARCHAR(2000)
   DECLARE  @StatusMsgPrefix  CHAR(18)
   DECLARE  @StatusMsg        VARCHAR(1024)
   --
   SET @StatusMsgPrefix =  'sp_dba_UpdateStatistics : ' 
   /******************************************************************************
   *
   *  Check Input Parameters
   *
   ******************************************************************************/
   --Check Access Level
   IF IS_SRVROLEMEMBER ( 'sysadmin') = 0
      BEGIN
         SELECT @StatusMsg = @StatusMsgPrefix + ' Error - Insufficient system access for ' + SUSER_SNAME() 
         RAISERROR(@StatusMsg,16,1)
         RETURN 1 	
      END 
   --Validate @DBName Argument
   IF @DBName NOT IN ('*','S','U')
      BEGIN
         IF NOT EXISTS (SELECT [name] FROM master.dbo.sysdatabases WHERE [name] = @DBName)
            BEGIN
               SELECT @StatusMsg = @StatusMsgPrefix + ' Error - Invalid database selected for @DBName (' + @DBName 
                                                    + ') parameter' 
               RAISERROR(@StatusMsg,16,1)
               RETURN 1 	
            END 	
      END
   /******************************************************************************
   *
   *
   *
   ******************************************************************************/
   CREATE TABLE #tempForExcludeDBs (DatabaseName  SYSNAME)

   SET @SQLString = 'SELECT sd.name               ' + 
                    'FROM sys.databases sd ' +
                    'WHERE sd.name IN (' + REPLACE(@ExcludedDB,'"',char(39)) + ')'
   INSERT #tempForExcludeDBs
   EXECUTE (@sqlstring)
   --
   DECLARE c_database CURSOR FOR
      SELECT RTRIM(sd.name)
      FROM sys.databases sd
      WHERE sd.name NOT IN ('tempdb')
        AND sd.name NOT IN (SELECT DatabaseName FROM #tempForExcludeDBs) 
        AND sd.state_desc = 'ONLINE'
        AND 1 =  CASE
                    WHEN @DBName  = 'S'      THEN SIGN(5 - sd.database_id)
                    WHEN @DBName  = 'U'      THEN SIGN(sd.database_id - 4)
                    WHEN @DBName  = '*'      THEN 1 
                    WHEN @DBName  = sd.name  THEN 1
                 END  
        ORDER BY sd.name
      FOR READ ONLY

   OPEN c_database
   FETCH NEXT FROM c_database INTO @DBName
   WHILE @@FETCH_STATUS = 0
      BEGIN
         PRINT '***** Updating Statistics for Database : ' + @DBName + ' *****'
         SET @SQLString = 'USE [' + @DBName + '] EXEC sp_updatestats @resample = ''' + @Resample  + ''''
         EXECUTE(@SQLString)      
         FETCH NEXT FROM c_database INTO @DBName
      END   --- c_database cursor loop
   CLOSE      c_database
   DEALLOCATE c_database
   DROP TABLE #tempForExcludeDBs
   RETURN 0
END  --Stored Procedure Block
