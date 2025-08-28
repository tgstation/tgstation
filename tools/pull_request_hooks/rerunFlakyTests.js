const LABEL = "🤖 Flaky Test Report";
const TITLE_BOT_HEADER = "title: ";

// Only check jobs that start with these.
// Helps make sure we don't restart something like screenshot tests or linters, which are not known to be flaky.
const CONSIDERED_JOBS = ["Integration Tests"];

async function getFailedJobsForRun(github, context, workflowRunId, runAttempt) {
  const jobs = await github.paginate(
    github.rest.actions.listJobsForWorkflowRunAttempt,
    {
      owner: context.repo.owner,
      repo: context.repo.repo,
      run_id: workflowRunId,
      attempt_number: runAttempt,
    },
    (response) => {
      return response.data;
    },
  );

  return jobs.filter((job) => job.conclusion === "failure");
}

export async function rerunFlakyTests({ github, context }) {
  const failingJobs = await getFailedJobsForRun(
    github,
    context,
    context.payload.workflow_run.id,
    context.payload.workflow_run.run_attempt,
  );

  const filteredFailingJobs = failingJobs.filter((job) => {
    console.log(`Failing job: ${job.name}`);
    return CONSIDERED_JOBS.some((title) => job.name.startsWith(title));
  });
  if (filteredFailingJobs.length === 0) {
    console.log("Failing jobs are NOT designated flaky. Not rerunning.");
    return;
  }

  console.log(`Rerunning job: ${filteredFailingJobs[0].name}`);

  github.rest.actions.reRunWorkflowFailedJobs({
    owner: context.repo.owner,
    repo: context.repo.repo,
    run_id: context.payload.workflow_run.id,
  });
}

// Tries its best to extract a useful error title and message for the given log
export function extractDetails(log) {
  // Strip off timestamp
  const lines = log.split(/^[0-9.:T\-]*?Z /gm);

  const failureRegex = /^\t?FAILURE #(?<number>[0-9]+): (?<headline>.+)/;
  const groupRegex = /^##\[group\](?<group>.+)/;

  const failures = [];
  let lastGroup = "root";
  let loggingFailure;

  const newFailure = (failureMatch) => {
    const { headline } = failureMatch.groups;

    loggingFailure = {
      headline,
      group: lastGroup.replace("/datum/unit_test/", ""),
      details: [],
    };
  };

  for (const line of lines) {
    const groupMatch = line.match(groupRegex);
    if (groupMatch) {
      lastGroup = groupMatch.groups.group.trim();
      continue;
    }

    const failureMatch = line.match(failureRegex);

    if (loggingFailure === undefined) {
      if (!failureMatch) {
        continue;
      }

      newFailure(failureMatch);
    } else if (failureMatch || line.startsWith("##")) {
      failures.push(loggingFailure);
      loggingFailure = undefined;

      if (failureMatch) {
        newFailure(failureMatch);
      }
    } else {
      loggingFailure.details.push(line.trim());
    }
  }

  // We had no logged failures, there's not really anything we can do here
  if (failures.length === 0) {
    return {
      title: "Flaky test failure with no obvious source",
      failures,
    };
  }

  // We *could* create multiple failures for multiple groups.
  // This would be important if we had multiple flaky tests at the same time.
  // I'm choosing not to because it complicates this logic a bit, has the ability to go terribly wrong,
  // and also because there's something funny to me about that increasing the urgency of fixing
  // flaky tests. If it becomes a serious issue though, I would not mind this being fixed.
  const uniqueGroups = new Set(failures.map((failure) => failure.group));

  if (uniqueGroups.size > 1) {
    return {
      title: `Multiple flaky test failures in ${Array.from(uniqueGroups)
        .sort()
        .join(", ")}`,
      failures,
    };
  }

  const failGroup = failures[0].group;

  if (failures.length > 1) {
    return {
      title: `Multiple errors in flaky test ${failGroup}`,
      failures,
    };
  }

  const failure = failures[0];

  // Common patterns where we can always get a detailed title
  const runtimeMatch = failure.headline.match(/Runtime in .+?: (?<error>.+)/);
  if (runtimeMatch) {
    const runtime = runtimeMatch.groups.error.trim();

    const invalidTimerMatch = runtime.match(
      /^Invalid timer:.+object:(?<object>[^[]+).*delegate:(?<proc>.+?), source:/,
    );
    if (invalidTimerMatch) {
      return {
        title: `Flaky test ${failGroup}: Invalid timer: ${invalidTimerMatch.groups.proc.trim()} on ${invalidTimerMatch.groups.object.trim()}`,
        failures,
      };
    }

    return {
      title: `Flaky test ${failGroup}: ${runtime}`,
      failures,
    };
  }

  const hardDelMatch = failure.headline.match(
    /^(?<object>\/[\w/]+) hard deleted .* times out of a total del count of/,
  );
  if (hardDelMatch) {
    return {
      title: `Flaky hard delete: ${hardDelMatch.groups.object}`,
      failures,
    };
  }

  // Try to normalize the title and remove anything that might be variable
  const normalizedError = failure.headline.replace(/\s*at .+?:[0-9]+.*/g, ""); // "<message> at code.dm:123"

  return {
    title: `Flaky test ${failGroup}: ${normalizedError}`,
    failures,
  };
}

async function getExistingIssueId(graphql, context, title) {
  // Hope you never have more than 100 of these open!
  const {
    repository: {
      issues: { nodes: openFlakyTestIssues },
    },
  } = await graphql(
    `
      query ($owner: String!, $repo: String!, $label: String!) {
        repository(owner: $owner, name: $repo) {
          issues(
            labels: [$label]
            first: 100
            orderBy: { field: CREATED_AT, direction: DESC }
            states: [OPEN]
          ) {
            nodes {
              number
              title
              body
            }
          }
        }
      }
    `,
    {
      owner: context.repo.owner,
      repo: context.repo.repo,
      label: LABEL,
    },
  );

  const exactTitle = openFlakyTestIssues.find((issue) => issue.title === title);
  if (exactTitle !== undefined) {
    return exactTitle.number;
  }

  const foundInBody = openFlakyTestIssues.find((issue) =>
    issue.body.includes(`<!-- ${TITLE_BOT_HEADER}${exactTitle} -->`),
  );
  if (foundInBody !== undefined) {
    return foundInBody.number;
  }

  return undefined;
}

function createBody({ title, failures }, runUrl) {
  return `
	<!-- This issue can be renamed, but do not change the next comment! -->
	<!-- title: ${title} -->

	Flaky tests were detected in [this test run](${runUrl}). This means that there was a failure that was cleared when the tests were simply restarted.

	Failures:
	\`\`\`
	${failures
    .map(
      (failure) =>
        `${failure.group}: ${failure.headline}\n\t${failure.details.join("\n")}`,
    )
    .join("\n")}
	\`\`\`
	`.replace(/^\s*/gm, "");
}

export async function reportFlakyTests({ github, context }) {
  const failedJobsFromLastRun = await getFailedJobsForRun(
    github,
    context,
    context.payload.workflow_run.id,
    context.payload.workflow_run.run_attempt - 1,
  );

  const filteredFailingJobs = failedJobsFromLastRun.filter((job) => {
    console.log(`Failing job: ${job.name}`);
    return CONSIDERED_JOBS.some((title) => job.name.startsWith(title));
  });

  // This could one day be relaxed if we face serious enough flaky test problems, so we're going to loop anyway
  if (filteredFailingJobs.length !== 1) {
    console.log(
      "Multiple jobs failing after retry, assuming maintainer rerun.",
    );

    return;
  }

  for (const job of filteredFailingJobs) {
    const { data: log } =
      await github.rest.actions.downloadJobLogsForWorkflowRun({
        owner: context.repo.owner,
        repo: context.repo.repo,
        job_id: job.id,
      });

    const details = extractDetails(log);

    const existingIssueId = await getExistingIssueId(
      github.graphql,
      context,
      details.title,
    );

    if (existingIssueId !== undefined) {
      // Maybe in the future, if it's helpful, update the existing issue with new links
      console.log(`Existing issue found: #${existingIssueId}`);
      return;
    }

    await github.rest.issues.create({
      owner: context.repo.owner,
      repo: context.repo.repo,
      title: details.title,
      labels: [LABEL],
      body: createBody(
        details,
        `https://github.com/${context.repo.owner}/${
          context.repo.repo
        }/actions/runs/${context.payload.workflow_run.id}/attempts/${
          context.payload.workflow_run.run_attempt - 1
        }`,
      ),
    });
  }
}
