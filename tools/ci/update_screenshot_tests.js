// MOTHBLOCKS TODO: Check that the owner made the comment
const updateScreenshotTests = async ({ github, context, exec }) => {
	if (
		!context.payload.comment.body
			.split("\n")
			.some(line => line === ".ssupdate")
	) {
		console.log("Skipping screenshot tests update");
		return;
	}

	const { payload } = context;

	await github.rest.reactions.createForIssueComment({
		comment_id: payload.comment.id,
		content: "+1",
		owner: context.repo.owner,
		repo: context.repo.repo,
	});

	const workflowRuns = await github.graphql(`query($id:ID!) {
		node(id: $id) {
			...on IssueComment {
				pullRequest {
					commits(last: 1) {
						nodes {
							commit {
								checkSuites(first:10) {
									nodes {
										workflowRun {
											runNumber
											workflow {
												name
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}`, {
		id: payload.comment.node_id,
	});

	const ciSuiteWorkflow = workflowRuns
		.node
		.pullRequest
		.commits
		.nodes[0]
		.commit
		.checkSuites
		.nodes
		.find(suite => suite.workflowRun?.workflow?.name === "CI Suite");

	if (!ciSuiteWorkflow) {
		console.log("No CI Suite workflow found");
		return;
	}

	console.log(`Found CI Suite workflow run ${ciSuiteWorkflow.workflowRun.runNumber}`);

	const { data: { artifacts } } = await github.rest.actions.listWorkflowRunArtifacts({
		owner: context.repo.owner,
		repo: context.repo.repo,
		run_id: ciSuiteWorkflow.workflowRun.runNumber,
	});

	const badScreenshots = artifacts.find(({ name }) => name === 'bad-screenshots');
	if (!badScreenshots) {
		console.log("No bad screenshots found");
		return;
	}

	console.log("I didn't think I'd get this far")
};

module.exports = { updateScreenshotTests };
