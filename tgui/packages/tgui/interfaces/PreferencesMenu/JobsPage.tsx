import { Color } from 'common/color';
import { classes } from 'common/react';
import { InfernoNode } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Button, Dropdown, Icon, Stack, Tooltip } from '../../components';
import { TriColumnDepartmentPane } from '../JobSelection';
import { JOB2ICON } from '../Orbit/constants';
import { createSetPreference, Department, Job, JoblessRole, JobPriority, PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const PRIORITY_BUTTON_SIZE = '18px';

const PriorityButton = (props: {
  name: string;
  color: string;
  modifier?: string;
  enabled: boolean;
  onClick: () => void;
}) => {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    <Stack.Item height={PRIORITY_BUTTON_SIZE}>
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
        height={PRIORITY_BUTTON_SIZE}
        width={PRIORITY_BUTTON_SIZE}
      />
    </Stack.Item>
  );
};

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

const createCreateSetPriorityFromName = (
  context,
  jobName: string
): CreateSetPriority => {
  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  const createSetPriority = (priority: JobPriority | null) => {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    const setPriority = () => {
      const { act } = useBackend<PreferencesMenuData>(context);

      act('set_job_preference', {
        job: jobName,
        level: priority,
      });
    };

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  };

  createSetPriorityCache[jobName] = createSetPriority;

  return createSetPriority;
};

const PriorityHeaders = (props: { department: Department }) => {
  const className = 'PreferencesMenu__Jobs__PriorityHeader';

  return (
    <Stack
      style={{
        'float': 'right',
        'clear': 'left',
        'color': Color.fromHex(props.department.color)
          .darken(70)
          .toString(),
      }}
      pt="10px">
      <Stack.Item grow />
      <Stack.Item className={className}>Off</Stack.Item>
      <Stack.Item className={className}>Low</Stack.Item>
      <Stack.Item className={className}>Med</Stack.Item>
      <Stack.Item className={className}>High</Stack.Item>
    </Stack>
  );
};

const PriorityButtons = (props: {
  createSetPriority: CreateSetPriority;
  isOverflow: boolean;
  priority: JobPriority;
}) => {
  const { createSetPriority, isOverflow, priority } = props;

  return (
    <Stack
      style={{
        'align-items': 'center',
        'height': '100%',
        'justify-content': 'flex-end',
        'padding-left': '0.3em',
      }}>
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
};

const JobRow = (
  props: {
    job: Job;
    name: string;
    department: Department;
  },
  context
) => {
  const { data } = useBackend<PreferencesMenuData>(context);
  const { job, name, department } = props;

  const isOverflow = data.overflow_role === name;
  const priority = data.job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(context, name);

  const experienceNeeded =
    data.job_required_experience && data.job_required_experience[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;

  let rightSide: InfernoNode;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{hoursNeeded}h</b> as {experience_type}
        </Stack.Item>
      </Stack>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{daysLeft}</b> day{daysLeft === 1 ? '' : 's'} left
        </Stack.Item>
      </Stack>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
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
    <Stack.Item mt="2px">
      <Stack fill align="center">
        <Tooltip content={job.description} position="bottom-start">
          <Stack.Item
            className="job-name"
            width="50%"
            style={{
              'padding-left': '0.3em',
            }}
            color={Color.fromHex(department.color)
              .darken(80)
              .toString()}>
            {
              <div>
                {(job.icon = job.icon || JOB2ICON[job.name] || null) && (
                  <Icon name={job.icon} width="16px" />
                )}
                {job.command ? <b>{job.name}</b> : job.name}
              </div>
            }
          </Stack.Item>
        </Tooltip>

        <Stack.Item grow className="options">
          {rightSide}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const JoblessRoleDropdown = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
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

  return (
    <Box position="absolute" right={0} width="30%" mr="6px">
      <Dropdown
        width="100%"
        selected={selected}
        onSelected={createSetPreference(act, 'joblessrole')}
        options={options}
        displayText={
          <Box pr={1}>
            {options.find((option) => option.value === selected)!.displayText}
          </Box>
        }
      />
    </Box>
  );
};

export const JobsPage = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Stack vertical>
      <Stack.Item height="2em">
        <JoblessRoleDropdown />
      </Stack.Item>

      <Stack.Item>
        <ServerPreferencesFetcher
          render={(data) => {
            if (!data) {
              return <h1>Oh no, your prefs didn&#39;t load into TGUI!!!</h1>;
            }

            return (
              <TriColumnDepartmentPane
                className="PreferencesMenu__Jobs"
                act={act}
                departments={data.jobs.departments}
                titleSubtextBuilder={(department: Department) => (
                  <PriorityHeaders department={department} />
                )}
                jobEntryBuilder={(job: Job, department: Department) => (
                  <JobRow
                    key={job.name}
                    job={job}
                    name={job.name}
                    department={department}
                  />
                )}
              />
            );
          }}
        />
      </Stack.Item>
    </Stack>
  );
};
