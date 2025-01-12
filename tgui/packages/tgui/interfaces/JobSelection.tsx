import { deepMerge } from 'common/collections';
import { Color } from 'tgui-core/color';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  NoticeBox,
  Section,
  Stack,
  StyleableSection,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { HUD_ICON } from '../constants/icons';
import { Window } from '../layouts';

type Job = {
  command: BooleanLike;
  description: string;
  icon: string;
  open_slots: number;
  prioritized: BooleanLike;
  unavailable_reason: string | null;
  used_slots: number;
};

type Department = {
  color: string;
  jobs: Record<string, Job>;
  open_slots: number;
};

type Data = {
  alert_state: string;
  departments_static: Record<string, Department>;
  departments: Record<string, Department>;
  disable_jobs_for_non_observers: BooleanLike;
  priority: BooleanLike;
  round_duration: string;
  shuttle_status: string;
};

type JobEntryProps = {
  department: Department;
  job: Job;
  name: string;
  onClick: () => void;
};

function JobEntry(props: JobEntryProps) {
  const { name, job, department } = props;
  const { icon } = job;

  let usedIcon;
  let topMargin = '';
  if (icon && icon !== 'borg') {
    topMargin = '1px';
    usedIcon = (
      <DmIcon
        icon={HUD_ICON.dmi}
        icon_state={icon}
        style={{
          transform: HUD_ICON.transform,
          filter: (job.unavailable_reason && 'grayscale(100%)') || undefined,
        }}
      />
    );
  } else if (icon === 'borg') {
    topMargin = '-2px';
    let borgRole = name === 'AI' ? 'eye' : 'robot';
    usedIcon = <Icon name={borgRole} ml={0.3} />;
  }

  return (
    <Button
      fluid
      style={{
        // Try not to think too hard about this one.
        backgroundColor: job.unavailable_reason
          ? '#949494' // Grey background
          : job.prioritized
            ? '#16fc0f' // Bright green background
            : Color.fromHex(department.color).darken(10).toString(),
        color: job.unavailable_reason
          ? '#616161' // Dark grey font
          : Color.fromHex(department.color).darken(90).toString(),
        fontSize: '1.1rem',
        cursor: job.unavailable_reason ? 'initial' : 'pointer',
      }}
      tooltip={
        job.unavailable_reason ||
        (job.prioritized ? (
          <>
            <p style={{ marginTop: '0px' }}>
              <b>The HoP wants more people in this job!</b>
            </p>
            {job.description}
          </>
        ) : (
          job.description
        ))
      }
      tooltipPosition="bottom"
      onClick={() => {
        !job.unavailable_reason && props.onClick();
      }}
    >
      <Stack fill>
        <Stack.Item>
          <div
            className="JobIcon"
            style={{ background: 'none', marginTop: topMargin }}
          >
            {usedIcon}
          </div>
        </Stack.Item>
        <Stack.Item grow>{job.command ? <b>{name}</b> : name}</Stack.Item>
        <Stack.Item>
          <span
            style={{
              whiteSpace: 'nowrap',
            }}
          >
            {job.used_slots} / {job.open_slots}
          </span>
        </Stack.Item>
      </Stack>
    </Button>
  );
}

type DepartmentEntryProps = {
  name: string;
  entry: Department;
};

function DepartmentEntry(props: DepartmentEntryProps) {
  const { name, entry } = props;
  const { act } = useBackend<Data>();

  return (
    <Box minWidth="30%">
      <StyleableSection
        title={
          <>
            {name}
            <span
              style={{
                fontSize: '1rem',
                whiteSpace: 'nowrap',
                position: 'absolute',
                right: '1em',
                color: Color.fromHex(entry.color).darken(60).toString(),
              }}
            >
              {entry.open_slots +
                (entry.open_slots === 1 ? ' slot' : ' slots') +
                ' available'}
            </span>
          </>
        }
        style={{
          backgroundColor: entry.color,
          marginBottom: '1em',
          breakInside: 'avoid-column',
        }}
        titleStyle={{
          'border-bottom-color': Color.fromHex(entry.color)
            .darken(50)
            .toString(),
        }}
        textStyle={{
          color: Color.fromHex(entry.color).darken(80).toString(),
        }}
      >
        <Stack vertical>
          {Object.entries(entry.jobs).map(([name, job]) => (
            <Stack.Item key={name}>
              <JobEntry
                key={name}
                name={name}
                job={job}
                department={entry}
                onClick={() => {
                  act('select_job', { job: name });
                }}
              />
            </Stack.Item>
          ))}
        </Stack>
      </StyleableSection>
    </Box>
  );
}

export function JobSelection(props) {
  const { act, data } = useBackend<Data>();

  if (!data?.departments_static) {
    return null; // Stop TGUI whitescreens with TGUI-dev!
  }

  const { round_duration, shuttle_status } = data;
  const departments: Record<string, Department> = deepMerge(
    data.departments,
    data.departments_static,
  );

  return (
    <Window width={1012} height={shuttle_status ? 690 : 666 /* Hahahahahaha */}>
      <Window.Content>
        <Section
          fill
          scrollable
          title={
            <Box mb={1}>
              {shuttle_status && <NoticeBox info>{shuttle_status}</NoticeBox>}
              <Box as="span" color="label">
                It is currently {round_duration} into the shift.
              </Box>
              <Button
                style={{ position: 'absolute', right: '1em' }}
                onClick={() => act('select_job', { job: 'Random' })}
                tooltip="Roll target random job. You can re-roll or cancel your random job if you don't like it."
              >
                Random Job!
              </Button>
            </Box>
          }
        >
          <Box style={{ columns: '20em' }}>
            {Object.entries(departments).map(([name, entry]) => (
              <DepartmentEntry key={name} name={name} entry={entry} />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
}
