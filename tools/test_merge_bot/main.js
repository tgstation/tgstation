import fetch from "node-fetch";

const TEST_MERGE_COMMENT_HEADER = "<!-- test_merge_bot:";

const { GET_TEST_MERGES_URL } = process.env;

if (!GET_TEST_MERGES_URL) {
	console.error("GET_TEST_MERGES_URL was not set.");
	process.exit(1);
}

export async function processTestMerges({ github, context }) {
	const rounds = await fetch(GET_TEST_MERGES_URL)
		.then(async (response) => {
			if (response.status !== 200) {
				return Promise.reject(
					`Failed to fetch test merges: ${
						response.status
					} ${await response.text()}`
				);
			}

			return response;
		})
		.then((response) => response.json())
		.catch((error) => {
			console.error(error);
			process.exit(1);
		});

	// PR # -> server name -> test merge struct
	const testMergesPerPr = {};

	for (const round of rounds) {
		const { server, test_merges } = round;

		for (const testMerge of test_merges) {
			if (!testMergesPerPr[testMerge]) {
				testMergesPerPr[testMerge] = {};
			}

			if (!testMergesPerPr[testMerge][server]) {
				testMergesPerPr[testMerge][server] = [];
			}

			testMergesPerPr[testMerge][server].push(round);
		}
	}

	for (const [prNumber, servers] of Object.entries(testMergesPerPr)) {
		const comments = await github.graphql(
			`
		query($owner:String!, $repo:String!, $prNumber:Int!) {
			repository(owner: $owner, name: $repo) {
				pullRequest(number: $prNumber) {
					comments(last: 100) {
						nodes {
							body
							databaseId
							author {
								login
							}
						}
					}
				}
			}
		}`,
			{
				owner: context.repo.owner,
				repo: context.repo.repo,
				prNumber: parseInt(prNumber, 10),
			}
		);

		const existingComment =
			comments.repository.pullRequest.comments.nodes.find(
				(comment) =>
					comment.author.login === "github-actions" &&
					comment.body.startsWith(TEST_MERGE_COMMENT_HEADER)
			);

		const roundIds = Object.values(servers)
			.flat()
			.map(({ round_id }) => round_id)
			.sort()
			.join(", ");

		const newHeader = `<!-- test_merge_bot: ${roundIds} -->`;

		if (existingComment && existingComment.body.startsWith(newHeader)) {
			console.log(`Comment is up to date for #${prNumber}`);
			continue;
		}

		let totalRounds = 0;
		let listOfRounds = "";

		for (const [server, rounds] of Object.entries(servers).sort(
			([a], [b]) => b - a
		)) {
			totalRounds += rounds.length;

			listOfRounds += `${"\n"}### ${server}`;

			for (const { datetime, round_id, url } of rounds.sort(
				(a, b) => b.round_id - a.round_id
			)) {
				listOfRounds += `${"\n"}- [${round_id} @ ${datetime}](${url})`;
			}

			listOfRounds += "\n";
		}

		const newBody =
			newHeader +
			`\nThis pull request was test merged in ${totalRounds} round(s).` +
			"\n" +
			"<details><summary>Round list</summary>\n\n" +
			listOfRounds +
			"\n</details>\n";

		if (existingComment === undefined) {
			await github.rest.issues.createComment({
				owner: context.repo.owner,
				repo: context.repo.repo,
				issue_number: prNumber,
				body: newBody,
			});
		} else {
			await github.rest.issues.updateComment({
				owner: context.repo.owner,
				repo: context.repo.repo,
				comment_id: existingComment.databaseId,
				body: newBody,
			});
		}
	}
}
