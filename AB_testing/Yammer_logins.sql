-- 02. How many people are logging into Yammer?

-- LEGEND: X, control_group; Y: test_group
-- Note that we get a z_score that is not on the table, so the p-value will be approximated as 0

SELECT *,
  numerator/denominator AS test_statistic
  FROM (
SELECT *, -- Calculate the test statistic for t-test (Note: max z-score is 6 on the provided table.)
  login_avg - y_bar AS numerator,
  SQRT(login_var/group_size + y_sigma2/y_size) AS denominator
  FROM (
SELECT *, -- Set values for arithmetic
  SUM(group_size) OVER () AS total_N,
  MIN(CASE WHEN experiment_group = 'test_group' THEN group_size ELSE NULL END) OVER () AS y_size,
  MIN(CASE WHEN experiment_group = 'test_group' THEN login_avg ELSE NULL END) OVER () AS y_bar,
  MIN(CASE WHEN experiment_group = 'test_group' THEN login_var ELSE NULL END) OVER () AS y_sigma2
  FROM(
SELECT experiment_group,
  COUNT(subtotals.user_id) AS group_size,
  SUM(subtotals.logins) AS login_total,
  AVG(subtotals.logins) AS login_avg,
  STDDEV(subtotals.logins) AS login_sd,
  VARIANCE(subtotals.logins) AS login_var
  FROM(
SELECT experiment_group, experiment,
  joined.user_id,
  COUNT(CASE WHEN event_name = 'login' THEN joined.user_id ELSE NULL END) AS logins
  FROM( -- Table 0: gather the important pieces from each of three tables and join them
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
  ) joined
  WHERE event_type = 'engagement'  -- only want people who were active
  GROUP BY experiment_group, experiment, user_id
)subtotals
GROUP BY experiment_group
) stats
)y_samples
)num_den
