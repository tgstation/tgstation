import { useBackend } from '../backend';
import { Button, DepartmentEntry, DepartmentPane, Icon, Stack } from '../components';
import { Window } from '../layouts';
import { Color } from 'common/color';
import { SFC } from 'inferno';
import { JobToIcon } from './common/JobToIcon';

type BaseVars = {
  name: string;
  open_slots: number;
};

type Job = BaseVars & {
  unavailable_reason: string | null;
  command: boolean;
  used_slots: number;
  icon: string;
  prioritized: boolean;
  job_description: string;
};

type Department = BaseVars & {
  jobs: Job[];
  open_slots: number;
  color: string;
};

type Data = {
  departments: Department[];
  alert_state: string;
  shuttle_status: string;
  disable_jobs_for_non_observers: boolean;
  priority: boolean;
  round_duration: string;
};

// Specifically not typed for flexibility.
export const JobEntry: SFC<{ job; department; act: Function }> = (data) => {
  const job = data.job;
  const department = data.department;
  return (
    <Stack.Item fill>
      <Button
        width="100%"
        style={{
          // Try not to think too hard about this one.
          'background-color': job.unavailable_reason
            ? '#949494'
            : job.prioritized
              ? '#16fc0f'
              : Color.fromHex(department.color)
                .darken(10)
                .toString(),
          'color': job.unavailable_reason
            ? '#616161'
            : Color.fromHex(department.color)
              .darken(90)
              .toString(),
          'font-size': '1.1rem',
          'cursor': job.unavailable_reason ? 'initial' : 'pointer',
        }}
        tooltip={
          job.unavailable_reason || (
            job.prioritized ? (
            <div>
              <b>The HoP wants more people in this job!</b>
              <br /> <br />
              {job.description}
            </div>
          ) : (
            job.description
          )
        }
        onClick={() => {
          !job.unavailable_reason && data.act('SelectedJob', { job: job.name });
        }}
        content={
          <div>
            {(job.icon = job.icon || JobToIcon[job.name] || null) && (
              <Icon name={job.icon} />
            )}
            {job.command ? <b>{job.name}</b> : job.name}
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
  const { departments } = data;

  const anyJobAvailable = departments.filter((department) => (
    department.jobs.some((job) => !job.unavailable_reason)
  ));
  
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
              tooltip="Roll a random job. You can re-roll or cancel your random job if you don't like it."
            />
          }>
          <DepartmentPane
            act={act}
            departments={departments}
            titleSubtextBuilder={(department) => {
              return (
                department['open_slots'] && (
                  <span
                    style={{
                      'float': 'right',
                      'clear': 'left',
                      'color': Color.fromHex(department['color'])
                        .darken(60)
                        .toString(),
                    }}>
                    {department['open_slots'] + ' Slots Available'}
                  </span>
                )
              );
            }}
            jobEntryBuilder={(job, department) => {
              return (
                <JobEntry
                  key={job['name']}
                  job={job}
                  department={department}
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
