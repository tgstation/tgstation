import { useBackend } from '../backend';
import { Button, DepartmentEntry, DepartmentPane, Icon } from '../components';
import { Window } from '../layouts';
import { Color } from 'common/color';
import { SFC } from 'inferno';
import { JobToIcon } from './common/JobToIcon';
import { BaseDepartment } from '../components/DepartmentPane';
import { deepMerge } from 'common/collections';

type Job = {
  unavailable_reason: string | null;
  command: boolean;
  open_slots: number;
  used_slots: number;
  icon: string;
  prioritized: boolean;
  description: string;
};

type Department = BaseDepartment<Job> & {
  open_slots: number;
};

type Data = {
  departments_static: Record<string, Department>;
  departments: Record<string, Department>;
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
  onClick: () => void;
}> = (data) => {
  const jobName = data.jobName;
  const job = data.job;
  const department = data.department;
  const jobIcon = job.icon || JobToIcon[jobName] || null;
  return (
    <Button
      fluid
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
          <>
            <p>
              <b>The HoP wants more people in this job!</b>
            </p>
            <p>{job.description}</p>
          </>
        ) : (
          job.description
        ))
      }
      onClick={() => {
        !job.unavailable_reason && data.onClick();
      }}>
      <>
        {jobIcon && <Icon name={jobIcon} />}
        {job.command ? <b>{jobName}</b> : jobName}
        <span
          style={{
            'white-space': 'nowrap',
            'position': 'absolute',
            'right': '0.5em',
          }}>
          {job.used_slots} / {job.open_slots}
        </span>
      </>
    </Button>
  );
};

export const JobSelection = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  if (!data?.departments_static) {
    return null; // Stop TGUI whitescreens with TGUI-dev!
  }
  const departments = deepMerge(data.departments, data.departments_static); // Why the fuck is it so hard to clone objects properly in JS?!

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
            renderTitleSubtext={(department: Department) => {
              const department_data = department;
              return (
                <span
                  style={{
                    'white-space': 'nowrap',
                    'position': 'absolute',
                    'right': '0px',
                    'clear': 'left',
                    'color': Color.fromHex(department_data.color)
                      .darken(60)
                      .toString(),
                  }}>
                  {department_data.open_slots +
                    (department_data.open_slots === 1 ? ' Slot' : ' Slots') +
                    ' Available'}
                </span>
              );
            }}
            renderJobEntry={(jobName, job, department: Department) => {
              return (
                <JobEntry
                  key={jobName}
                  jobName={jobName}
                  job={job}
                  department={department}
                  onClick={() => {
                    act('SelectedJob', { job: jobName });
                  }}
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
