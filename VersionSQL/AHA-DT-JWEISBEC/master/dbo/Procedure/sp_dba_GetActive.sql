/****** Object:  Procedure [dbo].[sp_dba_GetActive]    Committed by VersionSQL https://www.versionsql.com ******/


CREATE PROCEDURE [dbo].[sp_dba_GetActive]
AS
BEGIN
   SELECT sp.spid                          AS [Spid], 
          CAST(sp.loginame AS VARCHAR(15)) AS [Login],
          sp.blocked                       AS [Blocker], 
          sp.open_tran                     AS [Open],
          sp.stmt_end                      AS [StmtEnd],
          CAST(sp.status AS VARCHAR(10))   AS [Status],
          sp.waittime                      AS [WaitTime],
          sp.lastwaittype                  AS [WaitType],
          db_name(dbid)                    AS [Database],
          sp.cpu                           AS [CPU],
          sp.physical_io                   AS [Physical I/O],
          sp.program_name                  AS [Program],
          sp.cmd                           AS [Command],
          sp.hostname                      AS [Host Name],
          sp.loginame                      AS [Login Name], 
          sp.net_library                   AS [Library],
          sp.last_batch                    AS [Last Batch],
          GETDATE()                        AS [Now]
   FROM master..sysprocesses sp
   WHERE  net_library != '' 
     AND  sp.spid     != @@SPID
     AND (sp.waittime    > 0  OR  
          sp.blocked     > 0  OR
          sp.open_tran   > 0  OR  
          --sp.stmt_end   != 0  OR
          sp.status     != 'sleeping'  OR  
          sp.spid IN (SELECT sp2.blocked
                      FROM master..sysprocesses sp2
                      WHERE sp2.blocked != 0))
END  -- Stored Procedure
