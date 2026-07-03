import { sortBy } from 'es-toolkit';
import type { CSSProperties, PropsWithChildren, ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Section, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { JOBS_RU } from '../../../bandastation/ru_jobs'; // BANDASTATION EDIT
import {
  createSetPreference,
  type Job,
  JoblessRole,
  JobPriority,
  type PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';
import { JobSlotDropdown } from './JobSlotDropdown'; // BANDASTATION ADD - Pref Job Slots

function sortJobs(entries: [string, Job][], head?: string) {
  return sortBy(entries, [
    ([key, _]) => (key === head ? -1 : 1),
    ([key, _]) => key,
  ]);
}

type PriorityButtonProps = {
  name: string;
  position: number;
  modifier?: string;
  selected: boolean;
  onClick: () => void;
};

function PriorityButton(props: PriorityButtonProps) {
  const className = `PreferencesMenu__PriorityButton`;
  const positionVariable = {
    '--button-position': props.position,
  } as CSSProperties;

  return (
    <Button
      className={classes([
        className,
        props.modifier,
        props.selected && 'selected',
      ])}
      style={positionVariable}
      onClick={props.onClick}
    >
      {props.name}
    </Button>
  );
}

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

function createCreateSetPriorityFromName(jobName: string): CreateSetPriority {
  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  function createSetPriority(priority: JobPriority | null) {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    function setPriority() {
      const { act } = useBackend<PreferencesMenuData>();

      act('set_job_preference', {
        job: jobName,
        level: priority,
      });
    }

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  }

  createSetPriorityCache[jobName] = createSetPriority;
  return createSetPriority;
}

type PriorityButtonsProps = {
  createSetPriority: CreateSetPriority;
  isOverflow: boolean;
  priority: JobPriority;
};

function PriorityButtons(props: PriorityButtonsProps) {
  const { createSetPriority, isOverflow, priority } = props;

  return (
    <Stack className="PreferencesMenu__Priority">
      {isOverflow ? (
        <>
          <PriorityButton
            name="Откл."
            modifier="off"
            position={1}
            selected={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="Вкл."
            modifier="high"
            position={0}
            selected={!!priority}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      ) : (
        <>
          <PriorityButton
            name="Откл."
            modifier="off"
            position={3}
            selected={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="Низк."
            modifier="low"
            position={2}
            selected={priority === JobPriority.Low}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name="Сред."
            modifier="mid"
            position={1}
            selected={priority === JobPriority.Medium}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name="Выс."
            modifier="high"
            position={0}
            selected={priority === JobPriority.High}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Stack>
  );
}

type JobRowProps = {
  className?: string;
  name: string;
  job: Job;
};

function JobRow(props: JobRowProps) {
  const { data } = useBackend<PreferencesMenuData>();
  const { className, job, name } = props;

  let rightSide: ReactNode;
  const experienceNeeded = data.job_required_experience?.[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack.Item className="restricted">
        <b>{hoursNeeded}ч.</b> как{' '}
        <Tooltip content={experience_type}>
          <span>{experience_type}</span>
        </Tooltip>
      </Stack.Item>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack.Item className="restricted">
        Нужно еще дней: <b>{daysLeft}</b>
      </Stack.Item>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    rightSide = <Stack.Item className="restricted ban">Забанен</Stack.Item>;
  } else {
    const priority = data.job_preferences[name];
    const isOverflow = data.overflow_role === name;
    const createSetPriority = createCreateSetPriorityFromName(name);

    rightSide = (
      <>
        <PriorityButtons
          createSetPriority={createSetPriority}
          isOverflow={isOverflow}
          priority={priority}
        />
        <JobSlotDropdown name={name} />
      </>
    );
  }

  return (
    <Stack.Item className={className}>
      <Stack fill align="center">
        <Tooltip content={job.description} position="bottom-start">
          <Stack.Item grow className="job-name">
            {JOBS_RU[name] || name}
          </Stack.Item>
        </Tooltip>
        <Stack.Item className="options">{rightSide}</Stack.Item>
      </Stack>
    </Stack.Item>
  );
}

type DepartmentProps = {
  department: string;
} & PropsWithChildren;

function Department(props: DepartmentProps) {
  const { department: name } = props;
  const className = `PreferencesMenu__Department`;

  const data = useServerPrefs();
  if (!data) {
    return;
  }

  const { departments, jobs } = data.jobs;
  const department = departments[name];

  // This isn't necessarily a bug, it's like this
  // so that you can remove entire departments without
  // having to edit the UI.
  // This is used in events, for instance.
  if (!department) {
    return null;
  }

  const jobsForDepartment = sortJobs(
    Object.entries(jobs).filter(([_, job]) => job.department === name),
    department.head,
  );

  return (
    <Stack fill vertical g={0}>
      {jobsForDepartment.map(([jobName, job]) => {
        return (
          <JobRow
            key={jobName}
            name={jobName}
            job={job}
            className={classes([
              className,
              `${className}--${name.replace(' ', '')}`,
              jobName === department.head && 'head',
            ])}
          />
        );
      })}
    </Stack>
  );
}

function JoblessRoleDropdown() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const selected = data.character_preferences.misc.joblessrole;
  const options = [
    {
      displayText: `Присоединиться за ${JOBS_RU[data.overflow_role] || data.overflow_role}`,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: `Выбрать случайную должность`,
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: `Вернуться в лобби`,
      value: JoblessRole.ReturnToLobby,
    },
  ];

  const setPreference = createSetPreference(act, 'joblessrole');
  return (
    <Section title="Что делать если не удалось войти?">
      <Stack fill textAlign="center">
        {options.map((option) => (
          <Stack.Item grow key={option.value}>
            <Button
              fluid
              color="transparent"
              selected={selected === option.value}
              onClick={() => setPreference(option.value)}
            >
              {option.displayText}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

export function JobsPage() {
  return (
    <Stack fill vertical g={0}>
      <Stack.Item>
        <JoblessRoleDropdown />
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item grow>
        <Section fill>
          <Stack fill g={1} align="center" className="PreferencesMenu__Jobs">
            <Stack.Item grow minWidth={0}>
              <Stack vertical>
                <Department department="Engineering" />
                <Department department="Science" />
                <Department department="Silicon" />
                <Department department="Assistant" />
              </Stack>
            </Stack.Item>
            <Stack.Item grow minWidth={0}>
              <Stack vertical>
                <Department department="Captain" />
                <Department department="NT Representation" />
                <Department department="Service" />
                <Department department="Cargo" />
              </Stack>
            </Stack.Item>
            <Stack.Item grow minWidth={0}>
              <Stack vertical>
                <Department department="Security" />
                <Department department="Justice" />
                <Department department="Medical" />
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}
