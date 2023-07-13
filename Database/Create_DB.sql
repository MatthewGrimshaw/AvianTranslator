IF NOT EXISTS (SELECT * FROM sys.databases WHERE NAME = 'AvianTranslator')
BEGIN
    CREATE DATABASE [AvianTranslator]
END
GO

USE[AvianTranslator]
GO

IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE name = 'Translation' AND type = 'U')
BEGIN
    CREATE TABLE Translation (        
        DanishName nvarchar(255),
        LatinName nvarchar(255) NOT NULL PRIMARY KEY,
        EnglishName nvarchar(255)
    )
END

BULK
INSERT Translation
-- make sure the text file is UTF-16 BE for the scandinavian letters to display correctly
FROM 'C:\\AvianTranslator.txt'
WITH
(
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n'
)
GO

SELECT * FROM Translation


-- Drop a table called 'TableName' in schema 'dbo'
-- Drop the table if it already exists
-- IF OBJECT_ID('[dbo].[Translation]', 'U') IS NOT NULL
-- DROP TABLE [dbo].[Translation]
-- GO