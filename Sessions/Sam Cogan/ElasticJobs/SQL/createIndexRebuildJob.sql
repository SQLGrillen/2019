

--Connect to the job database specified when creating the job agent

--Add job for create table
EXEC jobs.sp_add_job @job_name='RebuildAllIndexes', @description='Rebuild All Indexes'

-- Add job step for create table
EXEC jobs.sp_add_jobstep @job_name='RebuildIndex',
@command=N'ALTER INDEX ALL ON Table_name
REBUILD ;',
@credential_name='myjobcred',
@target_group_name='ServerGroup1'