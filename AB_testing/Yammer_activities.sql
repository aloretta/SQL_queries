-- 03. Activities that are not completing signup nor logging-in.

SELECT *,
  numerator/denominator AS test_statistics -- ABS(test_stat) here is > 7, so p-value is approximately 0
  FROM(
SELECT *,
  activity_avg - y_bar AS numerator,
  SQRT(activity_var/group_size + y_sigma2/y_size) AS denominator
  FROM(
SELECT *,
  MIN(CASE WHEN experiment_group = 'test_group' THEN group_size ELSE NULL END) OVER () AS y_size,
  MIN(CASE WHEN experiment_group = 'test_group' THEN activity_avg ELSE NULL END) OVER () AS y_bar,
  MIN(CASE WHEN experiment_group = 'test_group' THEN activity_var ELSE NULL END) OVER () AS y_sigma2
  FROM(
SELECT experiment_group,
  COUNT(subtotals.user_id) AS group_size,
  SUM(subtotals.activities) AS total_activity,
  AVG(subtotals.activities) AS activity_avg,
  VARIANCE(subtotals.activities) AS activity_var
  FROM(
  SELECT experiment_group, user_id,
    COUNT(CASE WHEN joined.event_type = 'engagement' THEN joined.user_id ELSE NULL END) AS activities
  FROM(
    SELECT users.user_id, users.company_id, users.state,
      events.event_type, events.event_name, 
      events.occurred_at AS events_occured_at,
      expts.occurred_at AS treatment_occurred_at, 
      expts.experiment, expts.experiment_group, 
      expts.location, expts.device
      FROM tutorial.yammer_experiments AS expts
      JOIN tutorial.yammer_users AS users
      ON users.user_id = expts.user_id
      JOIN tutorial.yammer_events AS events
      ON events.user_id = expts.user_id
      AND events.occurred_at >= expts.occurred_at --consider events that occurred after tx applied
      AND events.occurred_at >= '2014-06-01'
      AND events.occurred_at < '2014-07-01'
      AND events.event_name != 'complete_signup'
      AND events.event_name != 'login'
    )joined
  GROUP BY experiment_group, user_id
  )subtotals
  GROUP BY experiment_group
  )stats
  GROUP BY 1,2,3,4,5
  )y_vals
  )num_den
