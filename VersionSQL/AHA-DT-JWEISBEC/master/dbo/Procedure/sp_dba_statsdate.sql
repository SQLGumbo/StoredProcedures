/****** Object:  Procedure [dbo].[sp_dba_statsdate]    Committed by VersionSQL https://www.versionsql.com ******/


CREATE PROCEDURE  [dbo].[sp_dba_statsdate]   @table   VARCHAR(120) = NULL
AS
BEGIN
   SET NOCOUNT ON
   --
   SELECT (object_name(si.id))   		AS 'Table Name',
           si.name				AS 'Index',
           STATS_DATE(si.id, si.indid)		AS 'Statistics Date'
   FROM sysindexes si
   WHERE OBJECT_NAME(si.id)  =  ISNULL(@table, OBJECT_NAME(si.id))
   ORDER BY 'Table Name'
   --
END
