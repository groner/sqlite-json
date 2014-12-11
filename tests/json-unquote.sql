-- Should be SQL NULL
SELECT JSON_UNQUOTE('null') AS 'null';
SELECT JSON_UNQUOTE('null') IS NULL AS 'null IS NULL';
-- Should be null
SELECT JSON_UNQUOTE('"null"') AS 'null';
SELECT JSON_UNQUOTE('"null"') IS NOT NULL AS 'null IS NOT NULL';
-- Should be foo
SELECT JSON_UNQUOTE('"foo"') AS 'foo';
-- Should be 123
SELECT JSON_UNQUOTE('123') AS '123';
-- Should reject with an error
SELECT JSON_UNQUOTE('[1,2,3]') AS '???';
