-- 01 Check how the treatment groups were assigned

-- After running this, we find that there were no users who 
-- activated their accounts in June for the test_group???

SELECT experiment_group, activation_month,
  COUNT(joined.user_id) AS active_accounts
  FROM(
  SELECT users.user_id, users.company_id, users.state,
    DATE_TRUNC('month', users.activated_at) AS activation_month,
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
  AND events.occurred_at >= expts.occurred_at -- Consider events that occurred after tx applied
  AND events.occurred_at >= '2014-06-01'
  AND events.occurred_at < '2014-07-01'
  )joined
GROUP BY experiment_group, activation_month
ORDER BY activation_month DESC
