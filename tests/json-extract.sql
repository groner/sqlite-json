-- Should extract [1,2,3]
SELECT JSON_EXTRACT('{"foo": [1, 2, 3]}', 'foo') AS 'foo';
-- Should extract 2
SELECT JSON_EXTRACT('{"foo": [1, 2, 3]}', 'foo', 1) AS 'foo, 1';
-- Should extract 3
SELECT JSON_EXTRACT('{"foo": [1, 2, 3]}', 'foo', -1) AS 'foo, -1';
-- Should be SQL NULL
SELECT JSON_EXTRACT('{"foo": [1, 2, 3]}', 'bar') AS 'bar';
SELECT JSON_EXTRACT('{"foo": [1, 2, 3]}', 'bar') IS NULL AS 'bar IS NULL';
-- Should be null
SELECT JSON_EXTRACT('{"foo": [1, 2, 3], "bar": null}', 'bar') AS 'bar';
SELECT JSON_EXTRACT('{"foo": [1, 2, 3], "bar": null}', 'bar') IS NOT NULL AS 'bar IS NOT NULL';
