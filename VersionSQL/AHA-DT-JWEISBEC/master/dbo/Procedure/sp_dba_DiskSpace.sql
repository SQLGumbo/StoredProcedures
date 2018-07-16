/****** Object:  Procedure [dbo].[sp_dba_DiskSpace]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE  [dbo].[sp_dba_DiskSpace]
AS
BEGIN
   SET NOCOUNT ON
   --
   DECLARE @hr           INT
   DECLARE @fso          INT
   DECLARE @DriveLetter  CHAR(1)
   DECLARE @odrive       INT
   DECLARE @TotalSize    VARCHAR(20)

   CREATE TABLE #tempForDriveSpace (DriveLetter CHAR(1),
                                    FreeSpace   INT         NULL,
                                    TotalSize   BIGINT      NULL)
   --
   INSERT #tempForDriveSpace(DriveLetter,FreeSpace)
   EXEC master.dbo.xp_fixeddrives
   --
   DECLARE c_DriveLetter CURSOR LOCAL FAST_FORWARD FOR 
       SELECT DriveLetter 
       FROM  #tempForDriveSpace
       ORDER by DriveLetter
   --
   EXEC @hr=sp_OACreate 'Scripting.FileSystemObject',@fso OUT
   IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
   --
   OPEN c_DriveLetter
   FETCH NEXT FROM c_DriveLetter INTO @DriveLetter
   WHILE @@FETCH_STATUS=0
      BEGIN
         EXEC @hr = sp_OAMethod @fso,'GetDrive', @odrive OUT, @DriveLetter
         IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
         EXEC @hr = sp_OAGetProperty @odrive,'TotalSize', @TotalSize OUT
         IF @hr <> 0 EXEC sp_OAGetErrorInfo @odrive

         UPDATE #tempForDriveSpace
         SET TotalSize  =  CAST(@TotalSize AS BIGINT)/1048576
         WHERE DriveLetter = @DriveLetter
         --
         FETCH NEXT FROM c_DriveLetter INTO @DriveLetter
      END
   CLOSE c_DriveLetter
   DEALLOCATE c_DriveLetter
   EXEC @hr=sp_OADestroy @fso
   IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
   --
   SELECT DriveLetter                                    AS [Drive],
          TotalSize                                      AS [Total(MB)],
          TotalSize - Freespace                          AS [Used (MB)],
          FreeSpace                                      AS [Free(MB)],
          CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) AS [Free(%)]
--         GETDATE()                AS [DateChecked],
--         '@@@@@'                  AS [Cookie]
   FROM #tempForDriveSpace
   ORDER BY DriveLetter
   --
   DROP TABLE #tempForDriveSpace
END
