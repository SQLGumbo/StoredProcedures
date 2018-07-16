/****** Object:  Procedure [dbo].[sp_dba_RowCounts]    Committed by VersionSQL https://www.versionsql.com ******/


/******************************************************************************
*
*  Author     :  jsw 
*  Name       :  sp_dba_RowCounts
*  Description:  Obtains approximate row counts for the tables in the current
*                database.   
*
*  Input      : @OrderBy -  The column to order the results by.  Valid values
*                           are 'Name' and 'Rows.'  Default is 'Name'
*               @Table   -  Name of the table to obtain row counts for.
*                           Default is NULL which will return results for
*                           all tables.
*  Comments   : To improve the accuracy of the results, update the usage.
*               Execute DBCC UPDATEUSAGE.
*
******************************************************************************/
CREATE  PROCEDURE [dbo].[sp_dba_RowCounts] @OrderBy VARCHAR(10) = 'Name',
                                  @Table   VARCHAR(60) = NULL
AS
BEGIN
   SET NOCOUNT ON
   --
   DECLARE  @StatusMsgPrefix  CHAR(18)
   DECLARE  @StatusMsg        VARCHAR(1024)
   --
   SET @StatusMsgPrefix =  'sp_dba_RowCounts : ' 
  /******************************************************************************
   *
   *  Check Input Parameters
   *
   ******************************************************************************/
   IF @OrderBy NOT IN ('Name','Rows')
      BEGIN
         SET @StatusMsg = @StatusMsgPrefix + ' Error - Invalid @OrderBy parameter' 
         RAISERROR(@StatusMsg,16,1)
         RETURN 1 	
      END  -- Invalid @OrderBy parameter
   /******************************************************************************
   *
   *  Return Result Set
   *
   ******************************************************************************/
   IF @OrderBy = 'Name'
      SELECT so.name                                AS [Table Name],
             si.rows                                AS [Rows]
      FROM dbo.sysindexes  si,
           dbo.sysobjects  so
      WHERE so.id    = si.id
        AND so.xtype = 'U'
        AND si.indid IN (0,1) -- root index for cluster or heap.
      ORDER BY [Table Name]  ASC
   ELSE
      SELECT so.name                                AS [Table Name],
             si.rows                                AS [Rows]
      FROM dbo.sysindexes  si,
           dbo.sysobjects  so
      WHERE so.id    = si.id
        AND so.xtype = 'U'
        AND si.indid IN (0,1) -- root index for cluster or heap.
      ORDER BY [Rows]  DESC
   --
   RETURN 0
END
