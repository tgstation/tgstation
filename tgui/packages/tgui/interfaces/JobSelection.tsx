import { useBackend } from '../backend';
import { Button, DepartmentEntry, DepartmentPane, JobEntry } from '../components';
import { Window } from '../layouts';
import { Color } from 'common/color';

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

export const JobSelection = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { departments } = data;

  let any_job_available = false;

  departments.forEach((department) => {
    department.jobs.forEach((job) => {
      if (!any_job_available && !job.unavailable_reason) {
        any_job_available = true;
      }
    });
  });
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
