import { Octokit } from '@octokit/rest';
import { parseChangelog } from "./changelogParser.js";
import { changelogToYml } from "./autoChangelog.js";
import { writeFileSync } from "node:fs";

const octokit = new Octokit({
	userAgent: 'changelog catchup thingymajig v1',
	auth: process.env.GITHUB_TOKEN,
});

// Replace these values with your GitHub repository owner, repo name, and the PR number you're interested in
if (process.argv.length !== 5) {
	console.error('Expected three arguments!');
	process.exit(1);
}

const owner = process.argv[2];
const repo = process.argv[3];
const initial_pr_number = parseInt(process.argv[4]);

async function get_merged_after() {
	try {
		// Get the details of the initial PR
		const initialPR = await octokit.pulls.get({
			owner,
			repo,
			pull_number: initial_pr_number,
		});

		// Get all the PRs merged after the initial PR's merge date
		const mergedPRs = await octokit.pulls.list({
			owner,
			repo,
			state: 'closed',
			sort: 'updated',
			direction: 'desc',
		});

		const initialPRMergeDate = new Date(initialPR.data.merged_at);

		// Filter the PRs that were merged after the initial PR
		const mergedAfterInitialPR = mergedPRs.data.filter(pr => {
			const prMergeDate = new Date(pr.merged_at);
			return prMergeDate > initialPRMergeDate;
		});

		// Print the details of PRs merged after the initial PR
		mergedAfterInitialPR.forEach(pr => {
			try {
				const changelog = parseChangelog(pr.body);
				if (!changelog || changelog.changes.length === 0) {
					console.log(`no changelog found for PR #${pr.number}`);
					return;
				}
				const yml = changelogToYml(
					changelog,
					pr.user.login
				);
				console.log(`writing changelog for PR #${pr.number} to ../../html/changelogs/AutoChangeLog-pr-${pr.number}.yml`)
				writeFileSync(`../../html/changelogs/AutoChangeLog-pr-${pr.number}.yml`, yml);
			} catch (error) {
				console.error(`Error processing PR #${pr.number}:`, error);
			}
		});
	} catch (error) {
		console.error('Error:', error.message);
	}
}

get_merged_after();
