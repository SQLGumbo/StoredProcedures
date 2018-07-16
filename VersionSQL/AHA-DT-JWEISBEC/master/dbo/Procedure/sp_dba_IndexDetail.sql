/****** Object:  Procedure [dbo].[sp_dba_IndexDetail]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_dba_IndexDetail]   
AS
BEGIN
   SET NOCOUNT ON;
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   SET DEADLOCK_PRIORITY LOW;
   ---
   SELECT s.[Schema]          AS [Schema],
          s.[Object Name]     AS [Object Name],
          s.[Object Type]     AS [Object Type],
          s.[Index]           AS [Index],
          s.[Fill Factor]     AS [Fill Factor],
          s.[Index Type]      AS [Index Type],
          s.[Primary Key]     AS [Primary Key],
          s.[Is Unique]       AS [Is Unique],
          ISNULL(s.[1], '')   AS [Column #1],
          ISNULL(s.[2], '')   AS [Column #2],
          ISNULL(s.[3], '')   AS [Column #3],
          ISNULL(s.[4], '')   AS [Column #4],
          ISNULL(s.[5], '')   AS [Column #5],
          ISNULL(s.[6], '')   AS [Column #6],
          ISNULL(s.[7], '')   AS [Column #7],
          ISNULL(s.[8], '')   AS [Column #8],
          ISNULL(s.[9], '')   AS [Column #9],      
          ISNULL(s.[10], '')  AS [Column #10],
          CASE ISNULL(s.[11], 'No more columns')
            WHEN 'No more columns'  THEN ''
            ELSE                         'Yes'
          END                    AS [More columns]  
   FROM (SELECT ss.name                    AS [Schema],
                so.name                    AS [Object Name],
                CASE so.type
                   WHEN 'U'  THEN 'Table'
                   WHEN 'V'  THEN 'View'
                   WHEN 'IT' THEN 'Internal table'
                   WHEN 'TF' THEN 'Table function'
                   ELSE           so.Type
                END                        AS [Object Type] ,  
                ISNULL(si.name, '')        AS [Index],
                ISNULL(sc.name, '') +
                CASE ic.is_included_column
                   WHEN 1   THEN '(inc)'
                   ELSE CASE ic.is_descending_key
                          WHEN 0 THEN '(+)'
                          ELSE        '(-)'
                        END                        
                END                        AS [ColumnName],    
                si.fill_factor             AS [Fill Factor],
                si.type_desc               AS [Index Type],
                CASE si.is_primary_key
                   WHEN 1    THEN 'Yes'
                   ELSE           ''
                END                        AS [Primary Key],
                CASE si.is_unique_constraint
                   WHEN 1    THEN 'Yes'
                   ELSE           ''
                END                        AS [Is Unique],
                ic.index_column_id         AS [IndexPosition]
         FROM sys.objects             so
         INNER JOIN sys.schemas       ss  ON ss.schema_id = so.schema_id
         INNER JOIN sys.indexes       si  ON si.object_id = so.object_id
                                         AND si.is_hypothetical = 0  
         LEFT  JOIN sys.index_columns ic  ON ic.object_id = si.object_id
                                         AND ic.index_id  = si.index_id
         LEFT  JOIN sys.columns       sc  ON sc.column_id = ic.column_id
                                         AND sc.object_id = ic.object_id) idx
   PIVOT (MIN(ColumnName)
          FOR IndexPosition IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]) ) S;  
 
END;
