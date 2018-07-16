/****** Object:  Procedure [dbo].[sp_dba_TableIndexSpace]    Committed by VersionSQL https://www.versionsql.com ******/

/******************************************************************************
*
*  Comments:  To improve the accuracy of the results, update the usage.
*             Execute DBCC UPDATEUSAGE.
*
******************************************************************************/
CREATE PROCEDURE  [dbo].[sp_dba_TableIndexSpace]  @Table  VARCHAR(120) =  NULL
AS
BEGIN
   SELECT OBJECT_NAME(si.id)                                                    AS [Table], 
          --
          CAST(SUM(CASE WHEN si.indid IN (0,1)  THEN si.dpages * 8/1024.00 
                        ELSE 0 
                   END)   AS DECIMAL(10,2))                                     AS [Data (MB)],
          --
          CAST(SUM(CASE WHEN si.indid NOT IN (0,1)  THEN si.dpages * 8/1024.00 
                        ELSE 0 
                   END)   AS DECIMAL(10,2))                                     AS [Index (MB)],
          CAST(SUM (si.dpages * 8/1024.00)  AS DECIMAL(10,2))                   AS [Total (MB)]
   FROM sysindexes si
   WHERE ISNULL(INDEXPROPERTY(si.id, si.name, 'IsStatistics'),0)   = 0
     AND ISNULL(INDEXPROPERTY(si.id, si.name, 'IsHypothetical'),0) = 0
     AND OBJECT_NAME(si.id) = ISNULL(@Table, OBJECT_NAME(si.id))
   GROUP BY si.id
   ORDER BY OBJECT_NAME(si.id)
END
