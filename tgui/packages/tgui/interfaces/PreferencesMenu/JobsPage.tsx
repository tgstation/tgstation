import { binaryInsertWith } from "common/collections";
import { classes } from "common/react";
import { useBackend } from "../../backend";
import { Box, Button, Icon, Stack, Tooltip } from "../../components";
import { logger } from "../../logging";
import { createSetPreference, JobPriority, PreferencesMenuData } from "./data";
import { Job } from "./jobs/base";
import * as Departments from "./jobs/departments";

const requireJob = require.context("./jobs/jobs", false, /.ts$/);
const jobsByDepartment = new Map<Departments.Department, {
  jobs: Job[],
  head?: Job,
}>();

const binaryInsertJob = binaryInsertWith((job: Job) => {
  return job.name;
});

const PRIORITY_BUTTON_SIZE = "18px";

for (const jobKey of requireJob.keys()) {
  const job = requireJob<{
    default?: Job,
  }>(jobKey).default;

  if (!job) {
    continue;
  }


  let departmentInfo = jobsByDepartment.get(job.department);
  if (departmentInfo === undefined) {
    departmentInfo = {
      jobs: [],
      head: undefined,
    };

    jobsByDepartment.set(job.department, departmentInfo);
  }

  if (job.department.head === job.name) {
    departmentInfo.head = job;
  } else {
    departmentInfo.jobs = binaryInsertJob(departmentInfo.jobs, job);
  }
}

const PriorityButton = (props: {
  name: string,
  color: string,
  modifier?: string,
  enabled: boolean,
  onClick: () => void,
}) => {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    <Stack.Item height={PRIORITY_BUTTON_SIZE}>
      <Button
        className={classes([
          className,
          props.modifier && `${className}--${props.modifier}`,
        ])}
        color={props.enabled ? props.color : "white"}
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

type CreateSetPriority = (priority: JobPriority) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

const createCreateSetPriorityFromName
  = (context, jobName: string): CreateSetPriority => {
    if (createSetPriorityCache[jobName] !== undefined) {
      return createSetPriorityCache[jobName];
    }

    const perPriorityCache = [];

    const createSetPriority = (priority: JobPriority) => {
      if (perPriorityCache[priority] !== undefined) {
        return perPriorityCache[priority];
      }

      const setPriority = () => {
        const { act } = useBackend<PreferencesMenuData>(context);

        act("set_job_preference", {
          job: jobName,
          level: priority,
        });
      };

      perPriorityCache[priority] = setPriority;
      return setPriority;
    };

    createSetPriorityCache[jobName] = createSetPriority;

    return createSetPriority;
  };

const JobRow = (props: {
  className?: string,
  job: Job,
}, context) => {
  const { data } = useBackend<PreferencesMenuData>(context);
  const { job } = props;

  const isOverflow = data.overflow_role === job.name;
  const priority = data.job_preferences[job.name];

  const createSetPriority = createCreateSetPriorityFromName(context, job.name);

  return (
    <Stack.Item className={props.className} height="100%" style={{
      "margin-top": 0,
    }}>
      <Stack fill align="center">
        <Tooltip
          content={job.description}
          position="bottom-start"
        >
          <Stack.Item className="job-name" width="60%" style={{
            "padding-left": "0.3em",
          }}>

            {props.job.name}
          </Stack.Item>
        </Tooltip>

        <Stack.Item grow className="options">
          <Stack
            style={{
              "align-items": "center",
              "height": "100%",
              "justify-content": !isOverflow && "center",
              "padding-left": "0.3em",
            }}
          >
            {
              isOverflow && (
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
              ) || (
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
              )
            }
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const Department = (props: {
  department: Departments.Department,
  name: string,
}) => {
  const { department, name } = props;
  const jobs = jobsByDepartment.get(department);
  const className = `PreferencesMenu__Jobs__departments--${name}`;

  return (
    <Stack.Item>
      <Stack
        vertical
        fill>
        {jobs.head
          && <JobRow className={`${className} head`} job={jobs.head} />}
        {jobs.jobs.map((job) => {
          if (job === jobs.head) {
            return null;
          }

          return <JobRow className={className} key={job.name} job={job} />;
        })}
      </Stack>
    </Stack.Item>
  );
};

// *Please* find a better way to do this, this is RIDICULOUS.
// All I want is for a gap to pretend to be an empty space.
// But in order for everything to align, I also need to add the 0.2em padding.
// But also, we can't be aligned with names that break into multiple lines!
export const Gap = (props: {
  amount: number,
}) => {
  // 0.2em comes from the padding-bottom in the department listing
  return <Stack.Item height={`calc(${props.amount}px + 0.2em)`} />;
};

export const JobsPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack fill className="PreferencesMenu__Jobs">
          <Stack.Item>
            <Stack vertical fill>
              <Gap amount={66} />

              <Department
                department={Departments.Engineering}
                name="Engineering" />

              <Gap amount={6} />

              <Department
                department={Departments.Science}
                name="Science" />

              <Gap amount={6} />

              <Department
                department={Departments.Silicon}
                name="Silicon" />

              <Gap amount={12} />

              <Department
                department={Departments.Assistant}
                name="Assistant" />
            </Stack>
          </Stack.Item>

          <Stack.Item>
            <Stack vertical fill>
              <Department department={Departments.Captain} name="Captain" />
              <Department department={Departments.Service} name="Service" />
              <Gap amount={6} />
              <Department department={Departments.Cargo} name="Supply" />
            </Stack>
          </Stack.Item>

          <Stack.Item>
            <Stack vertical fill>
              <Gap amount={66} />

              <Department
                department={Departments.Security}
                name="Security" />

              <Gap amount={6} />

              <Department
                department={Departments.Medical}
                name="Medical" />
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
