import fs from "fs";

const REGEX_COMMENT = /<!--.+?-->/g;

// Make sure we only remove default comments
const comments = [];

for (const match of fs
	.readFileSync(".github/PULL_REQUEST_TEMPLATE.md", { encoding: "utf8" })
	.matchAll(REGEX_COMMENT)) {
	comments.push(match[0]);
}

function escapeRegex(string) {
	return string.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&");
}

export async function removeGuideComments({ github, context }) {
	let newBody = context.payload.pull_request.body;

	for (const comment of comments) {
		newBody = newBody.replace(
			new RegExp(`^\\s*${escapeRegex(comment)}\\s*`)
		);
	}

	if (newBody !== context.payload.pull_request.body) {
		await github.pulls.update({
			...context.repo,
			pull_number: context.payload.pull_request.number,
			body: newBody,
		});
	}
}
