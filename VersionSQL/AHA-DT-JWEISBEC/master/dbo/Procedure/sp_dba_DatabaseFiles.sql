/****** Object:  Procedure [dbo].[sp_dba_DatabaseFiles]    Committed by VersionSQL https://www.versionsql.com ******/


CREATE PROCEDURE [dbo].[sp_dba_DatabaseFiles]   @Database   VARCHAR (120) = NULL, 
                                        @Drive      CHAR(1)       = NULL
AS
BEGIN
   SET NOCOUNT ON
   --
   DECLARE @DBName VARCHAR(128)
   DECLARE @SQLString VARCHAR (2000)
   DECLARE c_db CURSOR FOR
       SELECT db.name
       FROM master.dbo.sysdatabases db
       WHERE db.status&512 = 0
         AND db.name   = ISNULL(@Database, db.name)
   -- 
   CREATE TABLE #TempForFileStats([DatabaseName]        VARCHAR(120),
                                  [FileName]            VARCHAR(120),
                                  [GroupName]           VARCHAR(120),
                                  [Type]                VARCHAR (6),
                                  [Size(MB)]            DECIMAL(10,2), 
                                  [SpaceUsed(MB)]       DECIMAL(10,2),
                                  [MaxSize(MB)]         DECIMAL(10,2),
                                  [NextAllocation(MB)]  DECIMAL(10,2), 
                                  [GrowthType]          VARCHAR (12),
                                  [FileId]              SMALLINT,
                                  [GroupId]             SMALLINT,
                                  [PhysicalFile]        VARCHAR (260)) 

   --
   OPEN c_db
   FETCH NEXT FROM c_db INTO @DBName
   WHILE @@FETCH_STATUS = 0
      BEGIN
         SET @SQLString = 'USE ' + rtrim(@dbname)  + ' '                                          + 
                          'SELECT ' + '''' + @DBName + '''' + '    as  ''Database'', '            +  
                          '       f.name                           as  ''FileName'','             +
                          '       ISNULL(g.groupname, ''LOG'')     as  ''GroupName'','            +
                          '       CASE '                                                          +
                          '          WHEN (64 & f.status) = 64 THEN ''Log'' '                     +
                          '          ELSE ''Data'' '                                              + 
                          '       END                              as ''Type'', '                 +
                          '        f.size*8/1024.00                as ''Size(MB)'', '             +
                          '        fileproperty(f.name,''SpaceUsed'')*8/1024.00     as ''SpaceUsed (MB)'', '       +
                          '        CASE f.maxsize '                                               +
                          '           WHEN -1 THEN  -1.00 '                                       +
                          '           WHEN  0 THEN  f.size/1024.00*8  '                           +
                          '           ELSE          f.maxsize/1024.00*8 '                         +
                          '        END                             as ''MaxSize(MB)'', '          +
                          '        CASE '                                                         +
                          '           WHEN (1048576&f.status) = 1048576 THEN (growth/100.00)*(f.size*8/1024.00) ' + 
                          '           WHEN f.growth =0                 THEN -1 '                  +
                          '           ELSE                                   f.growth*8/1024.00 ' +
                          '        END                             as ''NextAllocation(MB)'', ' +
                          '       CASE  '                                                         +
                          '          WHEN (1048576&f.status) = 1048576 THEN ''Percentage'' '      +
                          '          ELSE ''Pages'' '                                             +
                          '       END                              as ''Usage Type'', '           +
                          '       f.fileid, '                                                     +
                          '       f.groupid, '                                                    +
                          '       f.filename '                                                    +
                          ' FROM [' + @DBName + '].dbo.sysfiles      f '                         +
                          ' LEFT OUTER JOIN [' + @DBName + '].dbo.sysfilegroups g  ON f.groupid = g.groupid '
         INSERT #TempForFileStats 
         EXECUTE(@SQLString)
          -------------------------------------------------------------------------
         FETCH NEXT FROM c_db INTO @DBName
      END  -- Cursor fetch loop, c_db
   CLOSE c_db
   DEALLOCATE c_db
   --
   SELECT RTRIM(@@SERVERNAME)         AS [Instance],
          RTRIM(DatabaseName)         AS [Database],
          RTRIM(FileName)             AS [FileName],
          RTRIM(GroupName)            AS [GroupName],
          [Size(MB)]                  AS [SIZE(MB)], 
          [SpaceUsed(MB)]             AS [SpaceUsed(MB)],
          [MaxSize(MB)]               AS [MaxSize(MB)],
          [NextAllocation(MB)]        AS [NextAllocation(MB)], 
          [GrowthType]                AS [GrowthType],
          [FileId]                    AS [FileId],
          [PhysicalFile]              AS [PhysicalFile]
   FROM #TempForFileStats
   WHERE [PhysicalFile] LIKE ISNULL(@Drive,SUBSTRING([PhysicalFile],1,1)) +':%'
   ORDER BY [DatabaseName]
   ------------
   DROP TABLE #TempForFileStats 
END  -- Stored Procedure Block
