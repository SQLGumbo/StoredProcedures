/****** Object:  Procedure [dbo].[sp_dba_GetBlockerInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_dba_GetBlockerInfo]
AS
BEGIN
   DECLARE  @spid      INT
   DECLARE  @Login     VARCHAR(15)
   DECLARE  @Database  VARCHAR(200)
   DECLARE  @Now       DATETIME
   --
   CREATE TABLE #tempinputbuffer (EventType    NVARCHAR(30),
                                  Parameters   INT,
                                  EventInfo    NVARCHAR(255))
   DECLARE c_blockers  CURSOR FOR
      SELECT sp.spid                            AS [Spid], 
             CAST(sp.loginame AS VARCHAR(15))   AS [Login],
             DB_NAME(dbid)                      AS [Database]
      FROM master..sysprocesses sp
      WHERE sp.blocked = 0
        AND sp.spid IN (SELECT sp2.blocked
                        FROM master..sysprocesses sp2
                        WHERE sp2.blocked   != 0)
      FOR READ ONLY
   ---
   SET @Now = GETDATE()
   ---
   OPEN c_blockers
   FETCH NEXT FROM c_blockers INTO @Spid, @Login, @Database
   WHILE @@FETCH_STATUS = 0
     BEGIN
        INSERT #tempinputbuffer
        EXEC('DBCC INPUTBUFFER('  + @spid + ')')
        INSERT INTO Admin.dbo.Blockers
                  SELECT @Spid, 
                         @Login, 
                         @Database, 
                         EventType, 
                         Parameters, 
                         EventInfo,
                         @Now
                  FROM #tempinputbuffer
        --
        INSERT INTO Admin.dbo.BlockersLocks    
                 SELECT CONVERT(SMALLINT, sli.req_spid)     AS [Spid],
                         DB_NAME(sli.rsc_dbid)              AS [Database],
                         sli.rsc_objid                      AS [Object ID],
                         sli.rsc_indid                      AS [IndId],
                         SUBSTRING(sv1.name, 1, 4)          AS [Type],
                         SUBSTRING(sv3.name, 1, 8)          AS [Mode],
                         SUBSTRING(sv2.name, 1, 5)          AS [Status],
                         COUNT(*)                           AS [Total],
                         @Now   
                  FROM   master.dbo.syslockinfo     sli,
                         master.dbo.spt_values      sv1,
                         master.dbo.spt_values      sv2,
                         master.dbo.spt_values      sv3
                  WHERE sli.rsc_type     = sv1.number
                    AND sv1.type         = 'LR'
                    AND sv1.name        != 'DB'
                    AND sli.req_status   = sv2.number
                    AND sv2.type         = 'LS'
                    AND sli.req_mode + 1 = sv3.number
                    AND sv3.type         = 'L'
                    AND @Spid            = sli.req_spid
                  GROUP BY CONVERT(SMALLINT, sli.req_spid),
                           DB_NAME(sli.rsc_dbid),
                           sli.rsc_objid,
                           sli.rsc_indid,
                           SUBSTRING(sv1.name, 1, 4),
                           SUBSTRING(sv3.name, 1, 8),
                           SUBSTRING(sv2.name, 1, 5)
        --
        TRUNCATE TABLE #tempinputbuffer
        --
        FETCH NEXT FROM c_blockers INTO @Spid, @Login, @Database
     END 
   CLOSE c_blockers
   DEALLOCATE c_blockers
   DROP TABLE  #tempinputbuffer
END
