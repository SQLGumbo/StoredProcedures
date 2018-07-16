/****** Object:  Procedure [dbo].[sp_dba_MirrorState]    Committed by VersionSQL https://www.versionsql.com ******/

/******************************************************************************
*
*  Mirroring State Detail
*
*
******************************************************************************/
CREATE PROCEDURE [dbo].[sp_dba_MirrorState]
AS 
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION iSOLATION LEVEL READ UNCOMMITTED;
    SET DEADLOCK_PRIORITY LOW;
    --
    SELECT db.name, 
           dm.mirroring_role, 
           dm.mirroring_role_desc,
           dm.mirroring_state_desc,
           dm.mirroring_safety_level_desc,
           dm.mirroring_partner_name,
           dm.mirroring_partner_instance,
           dm.mirroring_witness_name,
           dm.mirroring_witness_state_desc,
           dm.mirroring_connection_timeout,
           dm.mirroring_redo_queue,
           dm.mirroring_redo_queue_type,
           dm.mirroring_end_of_log_lsn,
           dm.mirroring_replication_lsn
    FROM sys.database_mirroring dm
    INNER JOIN sys.databases    db ON dm.database_id = db.database_id
    WHERE dm.mirroring_role IS NOT NULL;
END;
