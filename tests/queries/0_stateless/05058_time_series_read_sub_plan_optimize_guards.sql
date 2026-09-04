-- Tags: no-fasttest
-- Tag no-fasttest: the TimeSeries table engine is experimental and disabled in the fast-test build.

SET allow_experimental_time_series_table = 1;
SET session_timezone = 'UTC';

DROP TABLE IF EXISTS ts_guards;
CREATE TABLE ts_guards ENGINE = TimeSeries;
INSERT INTO ts_guards (metric_name, tags, time_series)
VALUES ('m', map('n', 'a'), [(toDateTime64('2024-01-01 00:00:00', 3), 1.), (toDateTime64('2024-01-01 00:00:15', 3), 2.)]);

-- The read is wrapped in an opaque plan step; these whole-query modes keep working over it.
SELECT count() > 0 FROM (EXPLAIN PLAN SELECT length(time_series) FROM ts_guards SETTINGS make_distributed_plan = 1);
SELECT length(time_series) FROM ts_guards SETTINGS allow_experimental_parallel_reading_from_replicas = 1, max_parallel_replicas = 2;
SELECT length(time_series) FROM ts_guards SETTINGS query_plan_enable_optimizations = 0;

DROP TABLE ts_guards;
