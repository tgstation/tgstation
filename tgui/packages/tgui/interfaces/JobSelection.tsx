import { useBackend } from '../backend';
import { Box, Button, StyleableSection, Icon, Stack, NoticeBox } from '../components';
import { Window } from '../layouts';
import { Color } from 'common/color';
import { SFC } from 'inferno';
import { JOB2ICON } from './common/JobToIcon';
import { deepMerge } from 'common/collections';
import { BooleanLike } from 'common/react';

type Job = {
  unavailable_reason: string | null;
  command: BooleanLike;
  open_slots: number;
  used_slots: number;
  prioritized: BooleanLike;
  description: string;
};

type Department = {
  color: string;
  jobs: Record<string, Job>;
  open_slots: number;
};

type Data = {
  departments_static: Record<string, Department>;
  departments: Record<string, Department>;
  alert_state: string;
  shuttle_status: string;
  disable_jobs_for_non_observers: BooleanLike;
  priority: BooleanLike;
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
  const jobIcon = JOB2ICON[jobName] || null;
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
            <p style={{ 'margin-top': '0px' }}>
              <b>The HoP wants more people in this job!</b>
            </p>
            {job.description}
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
  const departments: Record<string, Department> = deepMerge(
    data.departments,
    data.departments_static
  );

  return (
    <Window
      width={1012}
      height={data.shuttle_status ? 690 : 666 /* Hahahahahaha */}
      onComponentDidMount={() => {
        // Send a heartbeat back to DM to let it know the window is alive and well
        act('ui_mounted_with_no_bluescreen');
      }}>
      <Window.Content scrollable>
        <StyleableSection
          title={
            <>
              {data.shuttle_status && (
                <NoticeBox info>{data.shuttle_status}</NoticeBox>
              )}
              <span style={{ 'color': 'grey' }}>
                It is currently {data.round_duration} into the shift.
              </span>
              <Button
                style={{ 'position': 'absolute', 'right': '1em' }}
                onClick={() => act('select_job', { 'job': 'Random' })}
                content="Random Job!"
                tooltip="Roll target random job. You can re-roll or cancel your random job if you don't like it."
              />
            </>
          }
          titleStyle={{ 'min-height': '3.4em' }}>
          <Box wrap="wrap" style={{ 'columns': '20em' }}>
            {Object.entries(departments).map((departmentEntry) => {
              const departmentName = departmentEntry[0];
              const entry = departmentEntry[1];
              return (
                <Box key={departmentName} minWidth="30%">
                  <StyleableSection
                    title={
                      <>
                        {departmentName}
                        <span
                          style={{
                            'font-size': '1rem',
                            'white-space': 'nowrap',
                            'position': 'absolute',
                            'right': '1em',
                            'color': Color.fromHex(entry.color)
                              .darken(60)
                              .toString(),
                          }}>
                          {entry.open_slots +
                            (entry.open_slots === 1 ? ' slot' : ' slots') +
                            ' available'}
                        </span>
                      </>
                    }
                    style={{
                      'background-color': entry.color,
                      'margin-bottom': '1em',
                      'break-inside': 'avoid-column',
                    }}
                    titleStyle={{
                      'border-bottom-color': Color.fromHex(entry.color)
                        .darken(50)
                        .toString(),
                    }}
                    textStyle={{
                      'color': Color.fromHex(entry.color)
                        .darken(80)
                        .toString(),
                    }}>
                    <Stack vertical>
                      {Object.entries(entry.jobs).map((job) => (
                        <Stack.Item key={job[0]}>
                          <JobEntry
                            key={job[0]}
                            jobName={job[0]}
                            job={job[1]}
                            department={entry}
                            onClick={() => {
                              act('select_job', { job: job[0] });
                            }}
                          />
                        </Stack.Item>
                      ))}
                    </Stack>
                  </StyleableSection>
                </Box>
              );
            })}
          </Box>
        </StyleableSection>
      </Window.Content>
    </Window>
  );
};
