import { GET_TEST_MERGES_URL } from "./config";

const TEST_MERGE_COMMENT_HEADER = "<!-- test_merge_bot:";

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

	// PR # -> server name -> test merges
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

			testMergesPerPr[testMerge][server].push(testMerge);
		}
	}

	for (const [prNumber, servers] of Object.entries(testMergesPerPr)) {
		const comments = await github.graphql(
			`query($owner:String!, $repo:String!, $prNumber:Int!) {
			repository(owner: $owner, name: $repo) {
				pullRequest(number: $prNumber) {
					comments(last: 100) {
						nodes {
							body
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
				prNumber,
			}
		);

		const existingComment =
			comments.repository.pullRequest.comments.nodes.find(
				(comment) =>
					comment.author.login === "github-actions[bot]" &&
					comment.body.startsWith(TEST_MERGE_COMMENT_HEADER)
			);

		const roundIds = Object.values(servers)
			.flat()
			.map(({ round_id }) => round_id)
			.sort()
			.join(", ");

		const newHeader = `<!-- test_merge_bot: ${roundIds} -->`;

		if (existingComment && existingComment.body.startsWith(newHeader)) {
			continue;
		}

		let totalRounds = 0;
		let listOfRounds = "";

		for (const [server, rounds] of Object.entries(servers).sort(
			([a], [b]) => b - a
		)) {
			totalRounds += rounds.length;

			listOfRounds += `${"\n"}### ${server}`;

			for (const { datetime, round_id, url } of rounds) {
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

		await github.rest.issues.createComment({
			owner: context.repo.owner,
			repo: context.repo.repo,
			issue_number: prNumber,
			body: newBody,
		});
	}
}
