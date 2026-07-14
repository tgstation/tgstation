import { sortBy } from 'es-toolkit';
import { type PropsWithChildren, type ReactNode, useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Dropdown,
  Floating,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import {
  createSetPreference,
  type Job,
  JoblessRole,
  JobPriority,
  type PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';

function sortJobs(entries: [string, Job][], head?: string) {
  return sortBy(entries, [
    ([key, _]) => (key === head ? -1 : 1),
    ([key, _]) => key,
  ]);
}

const PRIORITY_BUTTON_SIZE = '18px';

type PriorityButtonProps = {
  name: string;
  color: string;
  modifier?: string;
  enabled: boolean;
  onClick: () => void;
};

function PriorityButton(props: PriorityButtonProps) {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    <Stack.Item height={PRIORITY_BUTTON_SIZE} width={PRIORITY_BUTTON_SIZE}>
      <Button
        className={classes([
          className,
          props.modifier && `${className}--${props.modifier}`,
        ])}
        color={props.enabled ? props.color : 'white'}
        circular
        onClick={props.onClick}
        tooltip={props.name}
        tooltipPosition="bottom"
        height="100%"
        width="100%"
      />
    </Stack.Item>
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

function PriorityHeaders() {
  const className = 'PreferencesMenu__Jobs__PriorityHeader';

  return (
    <Stack.Item>
      <Stack>
        <Stack.Item grow />

        <Stack.Item className={className}>Off</Stack.Item>

        <Stack.Item className={className}>Low</Stack.Item>

        <Stack.Item className={className}>Med</Stack.Item>

        <Stack.Item className={className}>High</Stack.Item>
      </Stack>
    </Stack.Item>
  );
}

type PriorityButtonsProps = {
  createSetPriority: CreateSetPriority;
  isOverflow: boolean;
  priority: JobPriority | null;
};

function PriorityButtons(props: PriorityButtonsProps) {
  const { createSetPriority, isOverflow, priority } = props;

  return (
    <Stack
      className="options"
      pl={'0.3em'}
      pt={'0.2em'}
      justify="flex-end"
      height="stretch"
    >
      {isOverflow ? (
        <>
          <PriorityButton
            name="Off"
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="On"
            color="green"
            enabled={!!priority}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      ) : (
        <>
          <PriorityButton
            name="Off"
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="Low"
            color="red"
            enabled={priority === JobPriority.Low}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name="Medium"
            color="yellow"
            enabled={priority === JobPriority.Medium}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name="High"
            color="green"
            enabled={priority === JobPriority.High}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Stack>
  );
}

type JobRowProps = {
  className?: string;
  job: Job;
  isTop: boolean;
  isOnly: boolean;
  name: string;
  dragging: number;
  setDragging: (dragging: number) => void;
  hoveringOver: string;
  setHoveringOver: (hoveringOver: string) => void;
};

function JobRow(props: JobRowProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    className,
    job,
    name,
    isTop,
    isOnly,
    dragging,
    setDragging,
    hoveringOver,
    setHoveringOver,
  } = props;
  const {
    character_profiles,
    overflow_role,
    job_preferences,
    job_required_experience,
    job_days_left,
  } = data;

  const isOverflow = overflow_role === name;
  const job_preference = job_preferences.find((pref) => pref.job === name);
  const priority = job_preference?.priority ?? null;
  const assignedProfileSlot = job_preference?.assigned_profile_slot ?? null;

  const createSetPriority = createCreateSetPriorityFromName(name);

  const experienceNeeded = job_required_experience?.[name];
  const daysLeft = job_days_left ? job_days_left[name] : 0;

  let rightSide: ReactNode;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack pr={1}>
        <Stack.Item grow textAlign="right" height="stretch">
          <b>{hoursNeeded}h</b> as {experience_type}
        </Stack.Item>
      </Stack>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack pr={1}>
        <Stack.Item grow textAlign="right" height="stretch">
          <b>{daysLeft}</b> day{daysLeft === 1 ? '' : 's'} left
        </Stack.Item>
      </Stack>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    rightSide = (
      <Stack pr={1}>
        <Stack.Item grow textAlign="right" height="stretch">
          <b>Banned</b>
        </Stack.Item>
      </Stack>
    );
  } else {
    rightSide = (
      <PriorityButtons
        createSetPriority={createSetPriority}
        isOverflow={isOverflow}
        priority={priority}
      />
    );
  }

  return (
    <Stack.Item
      className={className}
      mt={0}
      style={{
        borderTop: `${isTop ? null : '0px'}`,
      }}
    >
      <Stack align="top" g={0}>
        <Stack.Item grow={1.5}>
          <Stack vertical g={0} fill>
            <Stack.Item
              className={`job-name${hoveringOver === name ? ' hovered' : ''}`}
              pl={'0.3em'}
              pt={'0.2em'}
              pb={isOnly ? '0.2em' : 0}
              grow
              onDragOver={(e) => {
                e.preventDefault();
              }}
              onDragEnter={(e) => {
                setHoveringOver(name);
              }}
              //   onDragLeave={(e) => {
              //     setHoveringOver('');
              //   }}
              onDrop={() => {
                act('set_job_to_profile', {
                  job: name,
                  profile: dragging + 1, // +1 because UI is 0-indexed but DM is 1-indexed
                });
                setDragging(-1);
                setHoveringOver('');
              }}
            >
              <Tooltip content={job.description} position="bottom-start">
                {name}
              </Tooltip>
            </Stack.Item>
            {assignedProfileSlot !== null && (
              <Stack.Item grow>
                <Stack align="center">
                  <Stack.Item
                    ml={1}
                    color="var(--color-secondary)"
                    fontSize="0.95em"
                  >
                    ↳ <i>{character_profiles[assignedProfileSlot - 1]}</i>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="times"
                      color="transparent"
                      onClick={() => {
                        act('set_job_to_profile', {
                          job: name,
                          profile: -1,
                        });
                      }}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
        <Stack.Item grow height="stretch">
          {rightSide}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
}

type DepartmentProps = {
  department: string;
  dragging: number;
  setDragging: (dragging: number) => void;
  hoveringOver: string;
  setHoveringOver: (hoveringOver: string) => void;
} & PropsWithChildren;

function Department(props: DepartmentProps) {
  const { children, department: name, dragging, setDragging } = props;
  const className = `PreferencesMenu__Jobs__departments--${name}`;

  const data = useServerPrefs();
  if (!data) return;

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
    <Stack.Item
      style={{ '--department-color': department.color } as React.CSSProperties}
    >
      <Stack fill vertical g={0}>
        {jobsForDepartment.map(([name, job], index) => {
          return (
            <JobRow
              className={classes([
                'PreferencesMenu__Jobs__departments',
                className,
                name === department.head && 'head',
              ])}
              key={name}
              job={job}
              name={name}
              isTop={index === 0}
              isOnly={jobsForDepartment.length === 1}
              dragging={dragging}
              setDragging={setDragging}
              hoveringOver={props.hoveringOver}
              setHoveringOver={props.setHoveringOver}
            />
          );
        })}
      </Stack>

      {children}
    </Stack.Item>
  );
}

function JoblessRoleDropdown(props) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const selected = data.character_preferences.misc.joblessrole;

  const options = [
    {
      displayText: `Join as ${data.overflow_role} if unavailable`,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: `Join as a random job if unavailable`,
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: `Return to lobby if unavailable`,
      value: JoblessRole.ReturnToLobby,
    },
  ];

  const selection = options?.find(
    (option) => option.value === selected,
  )?.displayText;

  return (
    <Box position="absolute" right={0} width="30%">
      <Dropdown
        width="100%"
        selected={selection}
        onSelected={createSetPreference(act, 'joblessrole')}
        options={options}
      />
    </Box>
  );
}

type CharacterSectionsProps = {
  setDragging: (dragging: number) => void;
  setHoveringOver: (hoveringOver: string) => void;
};

function CharacterSection(props: CharacterSectionsProps) {
  const { setDragging, setHoveringOver } = props;
  const { data } = useBackend<PreferencesMenuData>();
  const { character_profiles } = data;

  const [characterFloating, setCharacterFloating] = useState(false);

  return (
    <Floating
      placement="bottom-end"
      content={
        <Box
          // Dumb way to copy dropdown styling but it works I guess
          style={{
            boxShadow: 'var(--dropdown-menu-blur)',
            backgroundColor: 'var(--dropdown-menu-background)',
            border: 'var(--dropdown-menu-border)',
            borderRadius: 'var(--dropdown-menu-border-radius)',
          }}
          width="75%"
        >
          <Stack vertical p={1}>
            <Stack.Item textAlign="center">
              Drag a character to a job to load that character if you are
              selected for that job.
            </Stack.Item>
            <Stack.Item>
              <Stack wrap>
                {character_profiles.map((profile, index) => {
                  if (!profile) return null;
                  return (
                    <Stack.Item key={index}>
                      <Button
                        draggable
                        color="transparent"
                        onDragStart={() => setDragging(index)}
                        onDragEnd={() => {
                          setDragging(-1);
                          setHoveringOver('');
                        }}
                      >
                        {profile}
                      </Button>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Stack.Item>
          </Stack>
        </Box>
      }
    >
      <Button
        onClick={() => setCharacterFloating(!characterFloating)}
        icon={'angle-down'}
      >
        Show Characters
      </Button>
    </Floating>
  );
}

export function JobsPage() {
  const [dragging, setDragging] = useState(-1);
  const [hoveringOver, setHoveringOver] = useState('');

  return (
    <>
      <Stack>
        <Stack.Item grow>
          <CharacterSection
            setDragging={setDragging}
            setHoveringOver={setHoveringOver}
          />
        </Stack.Item>
        <Stack.Item>
          <JoblessRoleDropdown />
        </Stack.Item>
      </Stack>
      <Stack vertical fill>
        <Stack.Item mt={15}>
          <Stack fill g={1} className="PreferencesMenu__Jobs">
            <Stack.Item>
              <Stack vertical>
                <PriorityHeaders />
                <Department
                  department="Engineering"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
                <Department
                  department="Science"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
                <Department
                  department="Silicon"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
                <Department
                  department="Assistant"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
              </Stack>
            </Stack.Item>
            <Stack.Item mt={-5.9}>
              <Stack vertical>
                <PriorityHeaders />
                <Department
                  department="Captain"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
                <Department
                  department="Service"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
                <Department
                  department="Cargo"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <PriorityHeaders />
                <Department
                  department="Security"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
                <Department
                  department="Medical"
                  dragging={dragging}
                  setDragging={setDragging}
                  hoveringOver={hoveringOver}
                  setHoveringOver={setHoveringOver}
                />
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </>
  );
}
