import { useBackend } from '../backend';
import { Button, Stack, Box, Icon } from '../components';
import { Window } from '../layouts';
import { JOB2ICON } from './Orbit/constants';
import { Color } from 'common/color';
import { SFC } from 'inferno';

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

// The cost of prettiness.
const DepartmentEntry = (props) => {
  return (
    <Box ClassName="Section" style={props.style}>
      <Box class="Section__title" style={props.titleStyle} minHeight="3.4rem">
        <Box class="Section__titleText" style={props.textStyle}>
          {props.title}
          {props.titleContents}
        </Box>
        {props.titleSubtext}
        <br style={{ 'clear': 'both' }} />
      </Box>
      <Box class="Section__rest">
        <Box class="Section__content">{props.children}</Box>
      </Box>
    </Box>
  );
};

// Specifically not typed for flexibility.
const JobEntry: SFC<{ job; department; act: Function }> = (data) => {
  const job = data.job;
  const department = data.department;
  return (
    <Stack.Item fill>
      <Button
        width="100%"
        style={{
          // Try not to think too hard about this one.
          'background-color': job.unavailable_reason
            ? 'lightgrey'
            : job.prioritized
              ? '#308d25'
              : Color.fromHex(department.color)
                .darken(10)
                .toString(),
          'color': job.unavailable_reason
            ? 'dimgrey'
            : Color.fromHex(department.color)
              .darken(90)
              .toString(),
          'font-size': '1.1rem',
          'cursor': job.unavailable_reason ? 'initial' : 'pointer',
        }}
        tooltip={
          job.unavailable_reason ? (
            job.unavailable_reason
          ) : job.prioritized ? (
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
            {(job.icon = job.icon || JOB2ICON[job.name] || null) && (
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

export const TriColumnDepartmentPane: SFC<{
  act;
  departments: object[];
  jobEntryBuilder: (job: object, department: object) => object;
  titleSubtextBuilder: (department: object) => object;
}> = (data) => {
  return (
    <Box wrap="wrap" style={{ 'columns': '20em' }}>
      {data.departments.map((department) => {
        return (
          <Box key={department['name']} minWidth="30%">
            <DepartmentEntry
              title={department['name']}
              style={{
                'background-color': department['color'],
                'margin-bottom': '1em',
                'break-inside': 'avoid-column',
              }}
              titleStyle={{
                'border-bottom-color': Color.fromHex(department['color'])
                  .darken(50)
                  .toString(),
              }}
              textStyle={{
                'color': Color.fromHex(department['color'])
                  .darken(80)
                  .toString(),
              }}
              titleSubtext={data.titleSubtextBuilder(department)}>
              <Stack vertical>
                {department['jobs'].map((job) =>
                  data.jobEntryBuilder(job, department)
                )}
              </Stack>
            </DepartmentEntry>
          </Box>
        );
      })}
    </Box>
  );
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
          <TriColumnDepartmentPane
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
          />
        </DepartmentEntry>
      </Window.Content>
    </Window>
  );
};
