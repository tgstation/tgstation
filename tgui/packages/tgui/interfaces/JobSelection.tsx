import { useBackend } from '../backend';
import { Button, DepartmentEntry, DepartmentPane, Icon, Stack } from '../components';
import { Window } from '../layouts';
import { Color } from 'common/color';
import { merge } from 'common/merge';
import { SFC } from 'inferno';
import { JobToIcon } from './common/JobToIcon';
import { BaseDepartmentInfo, BaseJobInfo } from '../components/DepartmentPane';

class Job implements BaseJobInfo {
  unavailable_reason: string | null;
  command: boolean;
  open_slots: number;
  used_slots: number;
  icon: string;
  prioritized: boolean;
  description: string;
}

class Department implements BaseDepartmentInfo {
  color: string;
  open_slots: number;
  jobs: { [x: string]: Job };
}

type Data = {
  static_data: { departments: { [x: string]: Department } };
  departments: { [x: string]: Department };
  alert_state: string;
  shuttle_status: string;
  disable_jobs_for_non_observers: boolean;
  priority: boolean;
  round_duration: string;
};

export const JobEntry: SFC<{
  jobName: string;
  job: Job;
  department: Department;
  act: Function;
}> = (data) => {
  const jobName = data.jobName;
  const job = data.job;
  const department = data.department;
  const jobIcon = job.icon || JobToIcon[jobName] || null;
  return (
    <Stack.Item fill>
      <Button
        width="100%"
        style={{
          // Try not to think too hard about this one.
          'background-color': job.unavailable_reason
            ? '#949494' // Grey background
            : job.prioritized
              ? '#16fc0f' // Bright green background
              : Color.fromHex(department.color)
                .darken(10)
                .toString(),
          'color': job.unavailable_reason
            ? '#616161' // Dark grey font
            : Color.fromHex(department.color)
              .darken(90)
              .toString(),
          'font-size': '1.1rem',
          'cursor': job.unavailable_reason ? 'initial' : 'pointer',
        }}
        tooltip={
          job.unavailable_reason ||
          (job.prioritized ? (
            <div>
              <b>The HoP wants more people in this job!</b>
              <br /> <br />
              {job.description}
            </div>
          ) : (
            job.description
          ))
        }
        onClick={() => {
          !job.unavailable_reason && data.act('SelectedJob', { job: jobName });
        }}
        content={
          <div>
            {jobIcon && <Icon name={jobIcon} />}
            {job.command ? <b>{jobName}</b> : jobName}
            <span style={{ 'float': 'right' }}>
              {job.used_slots} / {job.open_slots}
            </span>
          </div>
        }
      />
    </Stack.Item>
  );
};

export const JobSelection = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  let departments = JSON.parse(JSON.stringify(data.departments)); // Why the fuck is it so hard to clone objects properly in JS?!
  departments = merge(departments, data.static_data.departments);

  return (
    <Window width={1012} height={716}>
      <Window.Content scrollable>
        <DepartmentEntry
          title="Job Selection"
          titleContents={
            <Button
              style={{ 'float': 'right' }}
              onClick={() => act('SelectedJob', { 'job': 'Random' })}
              content="Random Job!"
              tooltip="Roll target random job. You can re-roll or cancel your random job if you don't like it."
            />
          }>
          <DepartmentPane
            departments={departments}
            titleSubtextBuilder={(department) => {
              const department_data = department as Department;
              return (
                <span
                  style={{
                    'float': 'right',
                    'clear': 'left',
                    'color': Color.fromHex(department_data.color)
                      .darken(60)
                      .toString(),
                  }}>
                  {department_data.open_slots + ' Slots Available'}
                </span>
              );
            }}
            jobEntryBuilder={(jobName, job, department) => {
              return (
                <JobEntry
                  key={jobName}
                  jobName={jobName}
                  job={job as Job}
                  department={department as Department}
                  act={act}
                />
              );
            }}
            entryWidth="30%"
          />
        </DepartmentEntry>
      </Window.Content>
    </Window>
  );
};
