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
  const originalBody = (
    await github.rest.pulls.get({
      owner: context.repo.owner,
      repo: context.repo.repo,
      pull_number: context.payload.pull_request.number,
    })
  ).data.body;

  if (!originalBody) {
    console.log("PR body is empty, skipping...");
    return;
  }

  let newBody = originalBody;

  for (const comment of comments) {
    newBody = newBody.replace(
      new RegExp(`^\\s*${escapeRegex(comment)}\\s*`, "gm"),
      "\n",
    );
  }

  if (newBody !== originalBody) {
    await github.rest.pulls.update({
      pull_number: context.payload.pull_request.number,
      repo: context.repo.repo,
      owner: context.repo.owner,
      body: newBody,
    });
  }
}
