using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

using LibGit2Sharp;

using Octokit;

namespace Tgstation.WalleningRevertHelper
{
	internal class Program
	{
		static readonly Identity identity = new Identity("tgstation-ci", "179393467+tgstation-ci[bot]@users.noreply.github.com");
		static async Task<int> Main(string[] args)
		{
			try
			{
				var command = args[0];
				var gitHubToken = args[1];

				var pushOptions = new PushOptions
				{
					CredentialsProvider = (a, b, supportedCredentialTypes) =>
					{
						var supportsUserPass = supportedCredentialTypes.HasFlag(SupportedCredentialTypes.UsernamePassword);
						var supportsAnonymous = supportedCredentialTypes.HasFlag(SupportedCredentialTypes.Default);

						if (supportsUserPass)
							return new UsernamePasswordCredentials
							{
								Username = "tgstation-ci",
								Password = gitHubToken,
							};

						if (supportsAnonymous)
							return new DefaultCredentials();

						Console.WriteLine("Cannot authenticate for push!");
						Environment.Exit(4);
						return null;
					},
				};

				var client = new GitHubClient(new ProductHeaderValue("Tgstation.WalleningRevertHelper"))
				{
					Credentials = new Octokit.Credentials(gitHubToken),
				};

				switch (command.ToLowerInvariant())
				{
					case "init":
						var repo = new LibGit2Sharp.Repository(".");

						const string PreWalleningCommit = "8868a5d1fe6252a6d2e71c75279471da4fc2648b";
						const int WalleningPR = 85491;

						var prsNeedingReplay = new Dictionary<int, string>();
						var succeeded = false;
						var currentCommit = repo.Head.Tip;
						for (int i = 0; i < 600; ++i)
						{
							if (currentCommit.Sha == PreWalleningCommit)
							{
								succeeded = true;
								break;
							}

							if (!(currentCommit.Message.Contains("[WalleningRevertIgnore]", StringComparison.OrdinalIgnoreCase)
								|| currentCommit.Message.StartsWith("Automatic changelog ")))
							{
								var match = Regex.Match(currentCommit.Message, @"\(#([1-9][0-9]+)\)");
								if (!match.Success)
								{
									Console.WriteLine($"I don't understand the source PR of commit {currentCommit.Sha}");
									return 1;
								}

								var revertResult = repo.Revert(currentCommit, new LibGit2Sharp.Signature(identity, DateTimeOffset.Now));
								if (revertResult.Status == RevertStatus.Conflicts)
								{
									Console.WriteLine($"Encountered conflicts while reverting {currentCommit.Sha}");
									return 3;
								}

								var prNumber = Int32.Parse(match.Groups[1].Value);
								if (prNumber != WalleningPR)
									prsNeedingReplay.Add(prNumber, revertResult.Commit.Sha);
							}

							var parents = currentCommit.Parents.ToList();
							if (parents.Count != 1)
							{
								Console.WriteLine($"History of commit {currentCommit.Sha} is not linear! Don't know what to do!");
								return 2;
							}

							currentCommit = parents.First();
						}

						if (!succeeded)
						{
							Console.WriteLine("Failed to find pre-wallening commit after 600 parents!");
							return 7;
						}

						repo.Network.Push(
							repo.Head,
							pushOptions);

						prsNeedingReplay.Reverse();

						var body = @$"This PR is reverting the wallening by reverting everything up to {PreWalleningCommit} and replaying the PRs skipping #{WalleningPR}.

The following PRs need to be replayed (DO NOT EDIT THIS LIST MANUALLY, IT IS USED BY THE BOT TO TRACK PROGRESS):

  - [ ] {String.Join($"{Environment.NewLine}  -", prsNeedingReplay.Select(x => $"#{x.Key} - Reverted in {x.Value}"))}

After that some startup commits on this branch need to be reverted then it can be merged.";

						var pr = await client.PullRequest.Create("tgstation", "tgstation", new NewPullRequest("Wallening Revert", "1989-11-09", "master")
						{
							Body = body,
							Draft = true,
						});

						await NextCore(repo, client, pr, null, pushOptions);

						break;
					case "next":
						var previousPR = Int32.Parse(args[2]);
						var walleningPRNumber = Int32.Parse(args[3]);

						var walleningPR = await client.PullRequest.Get("tgstation", "tgstation", walleningPRNumber);
						await NextCore(new LibGit2Sharp.Repository("."), client, walleningPR, previousPR, pushOptions);
						break;
				}

				return 0;
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.ToString());
				return 11;
			}
		}

		private static async Task NextCore(LibGit2Sharp.Repository repo, GitHubClient client, PullRequest walleningPR, int? closedPRNumber, PushOptions pushOptions)
		{
			if (closedPRNumber.HasValue)
			{
				var previousPR = await client.PullRequest.Get("tgstation", "tgstation", closedPRNumber.Value);
				var newBody = Regex.Replace(
					walleningPR.Body,
					@$"  - \[ \] #{closedPRNumber.Value} - Reverted in ([0-9a-f])+",
					previousPR.Merged
						? $"  - [x] #{closedPRNumber.Value} - Reverted in $1"
						: $"  - ~~[ ] #{closedPRNumber.Value} - Reverted in $1~~ (SKIPPED)");

				await client.PullRequest.Update("tgstation", "tgstation", walleningPR.Number, new PullRequestUpdate
				{
					Body = newBody,
				});

				if (!previousPR.Merged)
				{
					await client.Issue.Labels.AddToIssue("tgstation", "tgstation", closedPRNumber.Value, new string[] { "Lost to Wallening Revert" });
				}
			}

			var matches = Regex.Matches(walleningPR.Body, @"  - \[ \] #([1-9][0-9]+) - Reverted in ([0-9a-f]+)");

			if (matches.Count == 0)
			{
				await client.Issue.Comment.Create("tgstation", "tgstation", walleningPR.Number, "Holy shit, looks like we're done! All PRs have been replayed.\n\nRevert the un-wallening changes on this branch and un-draft the PR.");
				return;
			}

			var match = matches.First();
			var nextPr = Int32.Parse(match.Groups[1].Value);

			var revertSha = match.Groups[2].Value;

			var currentHead = repo.Head.Tip.Sha;
			var branchName = $"wallening-replay-pr-{nextPr}";
			var branch = repo.CreateBranch(branchName, revertSha);
			Commands.Checkout(repo, branch);

			var revertResult = repo.Revert(repo.Lookup(revertSha).Peel<LibGit2Sharp.Commit>(), new LibGit2Sharp.Signature(identity, DateTimeOffset.Now));
			if (revertResult.Status == RevertStatus.Conflicts)
			{
				// yeah, i should code in some retry mechanic in the workflow for this but fuck that noise
				Console.WriteLine($"Encountered conflicts while reverting our revert {revertSha}. HOW THE FUCK?!?!?");
				Environment.Exit(27);
			}

			var preMergeSha = repo.Head.Tip.Sha;

			// make a halfway attempt to merge in the main branch
			var result = repo.Merge(currentHead, new LibGit2Sharp.Signature(identity, DateTimeOffset.Now), new MergeOptions
			{
				CommitOnSuccess = true,
				FailOnConflict = true,
				FastForwardStrategy = FastForwardStrategy.NoFastForward,
				SkipReuc = true,
			});

			bool conflicted = result.Status == MergeStatus.Conflicts;
			if (conflicted)
			{
				repo.Reset(ResetMode.Hard, preMergeSha);
			}

			var body = $"This pull request replays #{nextPr} onto the wallening revert branch.";
			if (conflicted)
			{
				var originalPR = await client.PullRequest.Get("tgstation", "tgstation", nextPr);
				body += $"\n\nThis PR appears to be conflicting. Please push a resolution and merge it. Pinging original author @{originalPR.User.Login} for assistance.";
			}

			var remote = repo.Network.Remotes.First();
			var forcePushString = String.Format(CultureInfo.InvariantCulture, "+{0}:{0}", branch.CanonicalName);
			repo.Network.Push(remote, forcePushString, pushOptions);

			var pr = await client.PullRequest.Create("tgstation", "tgstation", new NewPullRequest($"Post Wallening Replay PR #{nextPr}", branchName, "1989-11-09")
			{
				Draft = conflicted,
				Body = body,
			});

			Console.WriteLine($"::set-output nextpr={pr.Number}");

			await client.Issue.Comment.Create("tgstation", "tgstation", walleningPR.Number, $"{(closedPRNumber.HasValue ? "Previous PR resolved. " : String.Empty)}Created next PR: #{pr.Number}{(conflicted ? " (CONFLICTS)" : String.Empty)}");

			// https://github.com/octokit/octokit.net/issues/2542#issuecomment-1238639643
			// auto-merge enabled in action
			Console.WriteLine($"::set-output conflicted={conflicted.ToString().ToLowerInvariant()}");
		}
	}
}
