/****** Object:  Procedure [dbo].[sp_dba_JobSchedules]    Committed by VersionSQL https://www.versionsql.com ******/


CREATE PROCEDURE [dbo].[sp_dba_JobSchedules]
AS
BEGIN
   SET NOCOUNT ON
   --
   SELECT 
          SUBSTRING(sj.name,1,120)                AS [Job Name], 
          SUBSTRING(ss.name,1,120)                AS [Schedule Name],
          --
          CASE sj.enabled
               WHEN 1  THEN 'Y'
               ELSE         'N'
          END                                     AS [Job Enabled],
          --
          CASE ss.enabled
               WHEN 1  THEN 'Y'
               ELSE         'N'
          END                                     AS [Schedule Enabled],
          --
          CAST(REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
               REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
               REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0') AS CHAR(8)) AS [Start Time],
          --
          CAST(REPLACE(SUBSTRING(STR(ss.active_end_time,6,0),1,2),' ','0') + ':' +
               REPLACE(SUBSTRING(STR(ss.active_end_time,6,0),3,2),' ','0') + ':' +
               REPLACE(SUBSTRING(STR(ss.active_end_time,6,0),5,2),' ','0')   AS CHAR(8)) AS [End Time],
          --
          CAST(CASE ss.freq_type
               WHEN 8   THEN  CASE ss.freq_interval&1
                                 WHEN  1 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0') 
                                    ELSE         ' '
                                 END
               WHEN 4   THEN  CASE ss.freq_subday_type
                                 WHEN  1 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 WHEN  4 THEN STR(ss.freq_subday_interval,4,0) + ' Min'
                                 WHEN  8 THEN STR(ss.freq_subday_interval,4,0) + ' Hrs' 
                                 ELSE         ' '
                              END
               ELSE     ' '
          END   AS CHAR(8))                                       AS [Sun],
          --
          CAST(CASE ss.freq_type 
               WHEN 8   THEN  CASE ss.freq_interval&2
                                 WHEN 2 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                             REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                             REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 ELSE        ' '
                              END
               WHEN 4   THEN  CASE ss.freq_subday_type
                                 WHEN  1 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 WHEN  4 THEN STR(ss.freq_subday_interval,4,0) + ' Min'
                                 WHEN  8 THEN STR(ss.freq_subday_interval,4,0) + ' Hrs' 
                                 ELSE         ' '
                              END
               ELSE     ' '
          END   AS CHAR(8))                                    AS [Mon],
          --
          CAST(CASE ss.freq_type 
               WHEN 8   THEN  CASE ss.freq_interval&4
                                 WHEN 4 THEN  REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 ELSE        ' ' 
                              END
               WHEN 4   THEN  CASE ss.freq_subday_type
                                 WHEN  1 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 WHEN  4 THEN STR(ss.freq_subday_interval,4,0) + ' Min'
                                 WHEN  8 THEN STR(ss.freq_subday_interval,4,0) + ' Hrs' 
                                 ELSE         ' '
                              END
               ELSE     ' '
          END AS CHAR(8))                                        AS [Tue],
          --
          CAST(CASE ss.freq_type 
               WHEN 8   THEN  CASE ss.freq_interval&8
                                 WHEN 8 THEN  REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 ELSE        ' '
                              END
               WHEN 4   THEN  CASE ss.freq_subday_type
                                 WHEN  1 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 WHEN  4 THEN STR(ss.freq_subday_interval,4,0) + ' Min'
                                 WHEN  8 THEN STR(ss.freq_subday_interval,4,0) + ' Hrs' 
                                 ELSE         ' '
                              END
               ELSE     ' '
          END  AS CHAR(8))                                      AS [Wed],
          --
          CAST(CASE ss.freq_type 
               WHEN 8   THEN  CASE ss.freq_interval&16
                                 WHEN 16 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                             REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                             REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 ELSE         ' '
                              END
               WHEN 4   THEN  CASE ss.freq_subday_type
                                 WHEN  1 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 WHEN  4 THEN STR(ss.freq_subday_interval,4,0) + ' Min'
                                 WHEN  8 THEN STR(ss.freq_subday_interval,4,0) + ' Hrs' 
                                 ELSE         ' '
                              END
               ELSE     ' '
          END AS CHAR(8))                                       AS [Thu],
          --
          CAST(CASE ss.freq_type 
               WHEN 8   THEN  CASE ss.freq_interval&32
                                 WHEN 32 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                             REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                             REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 ELSE         ' '
                              END
               WHEN 4   THEN  CASE ss.freq_subday_type
                                 WHEN  1 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 WHEN  4 THEN STR(ss.freq_subday_interval,4,0) + ' Min'
                                 WHEN  8 THEN STR(ss.freq_subday_interval,4,0) + ' Hrs' 
                                 ELSE         ' '
                              END
               ELSE     ' '
          END AS CHAR(8))                                       AS [Fri],
          --
          CAST(CASE ss.freq_type 
               WHEN 8   THEN  CASE ss.freq_interval&64
                                 WHEN 64 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                             REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                             REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 ELSE         ''
                              END
               WHEN 4   THEN  CASE ss.freq_subday_type
                                 WHEN  1 THEN REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),1,2),' ','0') + ':' +
                                                   REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),3,2),' ','0') + ':' +
                                              REPLACE(SUBSTRING(STR(ss.active_start_time,6,0),5,2),' ','0')
                                 WHEN  4 THEN STR(ss.freq_subday_interval,4,0) + ' Min'
                                 WHEN  8 THEN STR(ss.freq_subday_interval,4,0) + ' Hrs' 
                                 ELSE         ' '
                              END
               ELSE     ' '
            END AS CHAR(8))                                       AS [Sat]
   FROM msdb..sysjobs           sj
   INNER JOIN msdb..sysjobschedules  sjs
   ON sj.job_id = sjs.job_id
   INNER JOIN msdb..sysschedules ss
   ON sjs.schedule_id = ss.schedule_id
   ORDER BY [Job Name], [Schedule Name]

END
