/****** Object:  Procedure [dbo].[sp_dba_LockInfo]    Committed by VersionSQL https://www.versionsql.com ******/

/********************************************************
*
*
*********************************************************/
CREATE PROCEDURE [dbo].[sp_dba_LockInfo]
AS
BEGIN
   SET NOCOUNT ON
   --
   DECLARE @Spid    INT
   DECLARE @DBName  SYSNAME
   --
   SET @Spid    = NULL
   SET @DBName  = NULL
   -- 
   SELECT CONVERT(SMALLINT, sli.req_spid)    AS [Spid],
          DB_NAME(sli.rsc_dbid)              AS [Database],
          CASE sli.rsc_dbid
              WHEN  DB_ID()  THEN ISNULL(OBJECT_NAME(sli.rsc_objid),'')
              ELSE                       ''
          END                                AS [Object],
          sli.rsc_objid                      AS [Object ID],
          sli.rsc_indid                      AS [IndId],
          SUBSTRING(sv1.name, 1, 4)          AS [Type],
          SUBSTRING(sv3.name, 1, 8)          AS [Mode],
          SUBSTRING(sv2.name, 1, 5)          AS [Status],
          COUNT(*)                           AS [Total]
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
     AND ISNULL(@Spid, sli.req_spid) = sli.req_spid
     AND sli.rsc_dbid     = ISNULL(DB_ID(@DBName),sli.rsc_dbid )
   GROUP BY CONVERT(SMALLINT, sli.req_spid),
            DB_NAME(sli.rsc_dbid),
            CASE sli.rsc_dbid
                WHEN  DB_ID()  THEN ISNULL(OBJECT_NAME(sli.rsc_objid),'')
                ELSE                       ''
            END,
            sli.rsc_objid,
            sli.rsc_indid,
            SUBSTRING(sv1.name, 1, 4),
            SUBSTRING(sv3.name, 1, 8),
            SUBSTRING(sv2.name, 1, 5)
   ORDER BY [Database],
            [Spid]
END
