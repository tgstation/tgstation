import { useBackend } from '../backend';
import { Button, Stack, Box, Icon } from '../components';
import { Window } from '../layouts';
import { JOB2ICON } from './Orbit/constants';
import { COLORS } from '../constants';
import { darkenColor } from 'common/color';

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
const DepartmentSection = (props) => {
  return (
    <Box ClassName="Section" style={props.style}>
      <Box class="Section__title" style={props.titleStyle} minHeight="3.4rem">
        <Box class="Section__titleText" style={props.textStyle}>
          {props.title}
          {props.titleContents}
        </Box>
        {props.openSlots && (
          <span
            style={{
              'float': 'right',
              'clear': 'left',
              'color': props.subColor,
            }}>
            {(props.openSlots < 0 ? 'Infinite' : props.openSlots) +
              ' Slots Available'}
          </span>
        )}
        <br style={{ 'clear': 'both' }} />
      </Box>
      <Box class="Section__rest">
        <Box class="Section__content">{props.children}</Box>
      </Box>
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
        <DepartmentSection
          title="Job Selection"
          titleContents={
            <Button
              style={{ 'float': 'right' }}
              onClick={() => act('SelectedJob', { 'job': 'Random' })}
              content="Random Job!"
              tooltip="Roll a random job. You can re-roll or cancel your random job if you don't like it."
            />
          }>
          <Box wrap="wrap" style={{ 'columns': '20em' }}>
            {departments.map((department) => {
              department.color =
                COLORS.department[department.name.toLowerCase()] ||
                COLORS.department.other;
              return (
                <Box key={department.name} minWidth="30%">
                  <DepartmentSection
                    title={department.name}
                    style={{
                      'background-color': department.color,
                      'margin-bottom': '1em',
                      'break-inside': 'avoid-column',
                    }}
                    titleStyle={{
                      'border-bottom-color': darkenColor(
                        department.color,
                        50
                      ).toString(),
                    }}
                    textStyle={{
                      'color': darkenColor(department.color, 80).toString(),
                    }}
                    subColor={darkenColor(department.color, 60).toString()}
                    openSlots={department.open_slots}>
                    <Stack vertical>
                      {department.jobs.map((job) => {
                        return (
                          <Stack.Item fill key={job.name}>
                            <Button
                              width="100%"
                              style={{
                                // Try not to think too hard about this one.
                                'background-color': job.unavailable_reason
                                  ? 'lightgrey'
                                  : job.prioritized
                                    ? '#308d25'
                                    : darkenColor(department.color, 10),
                                'color': job.unavailable_reason
                                  ? 'dimgrey'
                                  : darkenColor(department.color, 90),
                                'font-size': '1.1rem',
                                'cursor': job.unavailable_reason
                                  ? 'initial'
                                  : 'pointer',
                              }}
                              tooltip={
                                job.unavailable_reason ? (
                                  job.unavailable_reason
                                ) : job.prioritized ? (
                                  <div>
                                    <b>
                                      The HoP wants more people in this job!
                                    </b>
                                    <br /> <br />
                                    {job.job_description}
                                  </div>
                                ) : (
                                  job.job_description
                                )
                              }
                              onClick={() => {
                                !job.unavailable_reason &&
                                  act('SelectedJob', { job: job.name });
                              }}
                              content={
                                <div>
                                  {(job.icon =
                                    job.icon || JOB2ICON[job.name] || null) && (
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
                      })}
                    </Stack>
                  </DepartmentSection>
                </Box>
              );
            })}
          </Box>
        </DepartmentSection>
      </Window.Content>
    </Window>
  );
};
