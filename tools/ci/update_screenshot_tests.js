const fs = require("fs");
const path = require("path");

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

	const graphQlResponse = await github.graphql(`query($id:ID!) {
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

					headRepository {
						owner {
							login
						}

						name
					}

					headRef {
						prefix
						name
					}
				}
			}
		}
	}`, {
		id: payload.comment.node_id,
	});

	const pullRequest = graphQlResponse
		.node
		.pullRequest;

	const commit = pullRequest
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

	fs.writeFileSync("bad-screenshots.zip", Buffer.from(download.data));

	await exec.exec("unzip bad-screenshots.zip -d bad-screenshots");

	const tree = [];

	const prOwner = pullRequest.headRepository.owner.login;
	const prRepo = pullRequest.headRepository.name;

	for (const filename of fs.readdirSync("bad-screenshots")) {
		const { data: blobData } = await github.rest.git.createBlob({
			owner: prOwner,
			repo: prRepo,
			encoding: "base64",
			content: fs.readFileSync(path.join("bad-screenshots", filename, "new.png"), "base64"),
		});

		tree.push({
			path: `code/modules/unit_tests/screenshots/${filename}.png`,
			mode: "100644",
			type: "blob",
			sha: blobData.sha,
		});
	}

	const { data: blobTree } = await github.rest.git.createTree({
		owner: prOwner,
		repo: prRepo,
		tree,
		base_tree: commitSha,
	});

	const { data: newCommit } = await github.rest.git.createCommit({
		owner: prOwner,
		repo: prRepo,
		tree: blobTree.sha,
		parents: [commitSha],
		message: "Update screenshots",
	});

	await github.rest.git.updateRef({
		owner: prOwner,
		repo: prRepo,
		sha: newCommit.sha,
		ref: `${pullRequest.headRef.prefix.replace(/^refs\//, "")}${pullRequest.headRef.name}`,
	});
};

module.exports = { updateScreenshotTests };
