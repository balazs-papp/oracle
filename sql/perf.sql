select 
trunc(s.end_interval_time, 'DD') as day,
min(s.snap_id),
plan_hash_value, 
sum(st.executions_delta) as executions,
sum(st.elapsed_time_delta)/1e6 as elapsed_seconds_total,
sum(st.iowait_delta)/1e6 as iowait_seconds_total,
sum(st.cpu_time_delta)/1e6 as cpu_seconds_total,
sum(st.disk_reads_delta) as disk_reads_total,
sum(st.elapsed_time_delta)/1e6/decode(sum(st.executions_delta), 0, 1, sum(st.executions_delta)) as avg_execution_time,
sum(st.rows_processed_delta)/decode(sum(st.executions_delta), 0, 1, sum(st.executions_delta)) as avg_rows_processed
from dba_hist_snapshot s 
join dba_hist_sqlstat st on (s.snap_id = st.snap_id)
where st.sql_id = 'fjhqska4sfb1t'
group by trunc(s.end_interval_time, 'DD'), plan_hash_value
order by 1;
