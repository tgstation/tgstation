function shouldMarkAsOutdated(comment) {
  return (
    !comment.isMinimized &&
    comment.author.login === 'github-actions[bot]' &&
    comment.bodyText.toLowerCase().includes('screenshot test')
  );
}
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
      pull_number: context.payload.pull_request.number,
    },
  );
  const oudatedCommentIds = prComments.repository.pullRequest.comments.nodes
    .filter(shouldMarkAsOutdated)
    .map((comment) => comment.id);

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
