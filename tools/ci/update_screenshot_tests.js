const fs = require("fs");

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

	console.log(JSON.stringify(context.payload, null, 2));

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
								oid

								checkSuites(first:10) {
									nodes {
										workflowRun {
											databaseId
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

	const commit = workflowRuns
		.node
		.pullRequest
		.commits
		.nodes[0]
		.commit;

	const commitSha = commit.oid;

	const ciSuiteWorkflow = commit
		.checkSuites
		.nodes
		.find(suite => suite.workflowRun?.workflow?.name === "CI Suite");

	if (!ciSuiteWorkflow) {
		console.log("No CI Suite workflow found");
		return;
	}

	console.log(`Found CI Suite workflow run ${ciSuiteWorkflow.workflowRun.databaseId}`);

	const { data: { artifacts } } = await github.rest.actions.listWorkflowRunArtifacts({
		owner: context.repo.owner,
		repo: context.repo.repo,
		run_id: ciSuiteWorkflow.workflowRun.databaseId,
	});

	const badScreenshots = artifacts.find(({ name }) => name === 'bad-screenshots');
	if (!badScreenshots) {
		console.log("No bad screenshots found");
		return;
	}

	const download = await github.rest.actions.downloadArtifact({
		owner: context.repo.owner,
		repo: context.repo.repo,
		artifact_id: badScreenshots.id,
		archive_format: "zip",
	});

	// fs.writeFileSync("bad-screenshots.zip", Buffer.from(download.data));

	// await exec.exec("unzip bad-screenshots.zip -d bad-screenshots");

	// const tree = [];

	// for (const filename of fs.readdirSync("bad-screenshots")) {
	// 	const { data: blobData } = await octokit.rest.git.createBlob({
	// 		owner: context.repo.owner,
	// 		repo: context.repo.repo,
	// 		encoding: "base64",
	// 		content: fs.readFileSync(`bad-screenshots/${filename}`, "base64"),
	// 	});

	// 	tree.push({
	// 		path: `code/modules/unit_tests/screenshots/${filename}.png`,
	// 		mode: "100644",
	// 		type: "blob",
	// 		sha: blobData.sha,
	// 	});
	// }

	// const { owner: prOwner, repo: prRepo } = payload.issue.pull_request;

	// const { data: blobTree } = await octokit.rest.git.createTree({
	// 	owner: context.repo.owner,
	// 	repo: context.repo.repo,
	// 	tree,
	// 	base_tree: commitSha,
	// });

	// const { data: commit } = await octokit.rest.git.createCommit({
	// 	owner: context.repo.owner,
	// 	repo: context.repo.repo,
	// 	tree: blobTree.sha,
	// 	parents: [commitSha],
	// 	message: "Update screenshots",
	// });

	// await octokit.rest.git.updateRef({
	// 	owner: context.repo.owner,
	// 	repo: context.repo.repo,
	// 	sha: commit.sha,
	// 	ref: context.ref,
	// });
};

module.exports = { updateScreenshotTests };
