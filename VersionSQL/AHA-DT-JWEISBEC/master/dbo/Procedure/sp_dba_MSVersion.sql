/****** Object:  Procedure [dbo].[sp_dba_MSVersion]    Committed by VersionSQL https://www.versionsql.com ******/



CREATE PROCEDURE [dbo].[sp_dba_MSVersion]  
AS
BEGIN
   SET NOCOUNT ON
   --
   DECLARE  @MSVersion TABLE  ([Index]            SMALLINT,
                                Name              VARCHAR(60),
                                InternalValue     INT,
                                CharacterValue    VARCHAR(120))
   INSERT @MSVersion
   EXEC master..xp_msver;
   --
   SELECT CAST(@@SERVERNAME AS VARCHAR(60))                                              AS [Instance],
          MAX(CASE v.Name WHEN 'ProductName'         THEN v.CharacterValue ELSE '' END)  AS [ProductName],
          MAX(CASE v.Name WHEN 'ProductVersion'      THEN v.CharacterValue ELSE '' END)  AS [ProductVersion],
          MAX(CASE v.Name WHEN 'Language'            THEN v.CharacterValue ELSE '' END)  AS [Language],
          MAX(CASE v.Name WHEN 'Platform'            THEN v.CharacterValue ELSE '' END)  AS [Platform],
          MAX(CASE v.Name WHEN 'Comments'            THEN v.CharacterValue ELSE '' END)  AS [Comments],
          MAX(CASE v.Name WHEN 'CompanyName'         THEN v.CharacterValue ELSE '' END)  AS [CompanyName],
          MAX(CASE v.Name WHEN 'FileDescription'     THEN v.CharacterValue ELSE '' END)  AS [FileDescription],
          MAX(CASE v.Name WHEN 'FileVersion'         THEN v.CharacterValue ELSE '' END)  AS [FileVersion],
          MAX(CASE v.Name WHEN 'InternalName'        THEN v.CharacterValue ELSE '' END)  AS [InternalName],
          MAX(CASE v.Name WHEN 'LegalCopyright'      THEN v.CharacterValue ELSE '' END)  AS [LegalCopyright],
          MAX(CASE v.Name WHEN 'LegalTrademarks'     THEN v.CharacterValue ELSE '' END)  AS [LegalTrademarks],
          MAX(CASE v.Name WHEN 'OriginalFilename'    THEN v.CharacterValue ELSE '' END)  AS [OriginalFilename],
          MAX(CASE v.Name WHEN 'PrivateBuild'        THEN v.CharacterValue ELSE '' END)  AS [PrivateBuild],
          MAX(CASE v.Name WHEN 'SpecialBuild'        THEN v.CharacterValue ELSE '' END)  AS [SpecialBuild],
          MAX(CASE v.Name WHEN 'WindowsVersion'      THEN v.CharacterValue ELSE '' END)  AS [WindowsVersion],
          MAX(CASE v.Name WHEN 'ProcessorCount'      THEN v.CharacterValue ELSE '' END)  AS [ProcessorCount],
          MAX(CASE v.Name WHEN 'ProcessorActiveMask' THEN v.CharacterValue ELSE '' END)  AS [ProcessorActiveMask],
          MAX(CASE v.Name WHEN 'ProcessorType'       THEN v.CharacterValue ELSE '' END)  AS [ProcessorType],
          MAX(CASE v.Name WHEN 'PhysicalMemory'      THEN v.CharacterValue ELSE '' END)  AS [PhysicalMemory],
          MAX(CASE v.Name WHEN 'Product ID'          THEN v.CharacterValue ELSE '' END)  AS [Product ID]
   FROM @MSVersion v;
END;

