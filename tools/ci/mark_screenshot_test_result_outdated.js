// Checks comments to see if any screenshot test results are outdated, mark them as outdated if so
export async function markScreenshotTestResultOutdated({ github, context }) {
  // we have to use graphql because it differentiates outdated comments
  const prComments = await github.graphql(
    `query($owner:String!, $repo:String!, $prNumber:Int!) {
            repository(owner: $owner, name: $repo) {
                pullRequest(number: $prNumber) {
                    comments(last: 10) {
                        nodes {
                            id
                            bodyText
                            author {
                                login
                            }
                            isMinimized
                        }
                    }
                }
            }
        }`,
    {
      owner: context.repo.owner,
      repo: context.repo.repo,
      prNumber: context.payload.pull_request.number,
    },
  );
  //   const oudatedCommentIds = prComments.repository.pullRequest.comments.nodes
  //     .filter(shouldMarkAsOutdated)
  //     .map((comment) => comment.id);
  const oudatedCommentIds = [];
  for (const comment of prComments.repository.pullRequest.comments.nodes) {
    if (comment.isMinimized) {
      console.log(`Comment ${comment.id} is already minimized, skipping`);
      continue;
    }
    if (
      comment.author.login !== 'github-actions[bot]' &&
      comment.author.login !== 'github-actions'
    ) {
      console.log(
        `Comment ${comment.id} is authored by ${comment.author.login}, not a bot, skipping`,
      );
      continue;
    }
    if (!comment.bodyText.toLowerCase().includes('screenshot test')) {
      console.log(
        `Comment ${comment.id} does not mention \"screenshot test\", skipping`,
      );
      continue;
    }
    oudatedCommentIds.push(comment.id);
  }

  if (oudatedCommentIds.length === 0) {
    console.log(
      prComments.repository.pullRequest.comments.nodes.length === 0
        ? 'No comments found on PR'
        : 'No outdated screenshot test result comments found',
    );
    return;
  }

  for (const commentId of oudatedCommentIds) {
    await github.graphql(
      `mutation($commentId:ID!) {
            minimizeComment(input:{subjectId:$commentId, classifier:OUTDATED}) {
                minimizedComment {
                    id
                }
            }
        }`,
      {
        commentId,
      },
    );
    console.log(`Marked comment ${commentId} as outdated`);
  }
}
