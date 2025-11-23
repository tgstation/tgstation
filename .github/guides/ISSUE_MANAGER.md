## What is an Issue Manager

Issue Managers proactively manage issues for the repo by providing feedback, performing triage, and troubleshooting problems. They search through the codebase to link relevant code, issues, and PRs that help contributors identify and solve an issue.

## Triage An Issue

New issues should be properly diagnosed by using several methods and tools below:

#### Emergency Issues

When examining new issues you should immediately notify a maintainer if you see the following:

- **Security Exploit** [[1]](https://github.com/tgstation/tgstation/issues/51654) [[2]](https://github.com/tgstation/tgstation/issues/38407) [[3]](https://github.com/tgstation/tgstation/issues/9900) - Something that can be used to bypass bans, give a player admin powers, cheats or hacks
- **Server Crashing** [[1]](https://github.com/tgstation/tgstation/issues/29342) [[2]](https://github.com/tgstation/tgstation/issues/25890) [[3]](https://github.com/tgstation/tgstation/issues/17475) - Something that is causing the server to _consistently_ crash
- **Server Lagging** [[1]](https://github.com/tgstation/tgstation/issues/60193) [[2]](https://github.com/tgstation/tgstation/issues/51927) [[3]](https://github.com/tgstation/tgstation/issues/32762) - Something that is causing a _severe_ amount of lag during the game

#### Runtime Issue Reports

If an issue reports a runtime, it must have the actual runtime call stack provided by round logging or in-game debug menu (https://github.com/tgstation/tgstation/issues/70329#issuecomment-1279853883).

<details>
  <summary>Example runtime call stack</summary>

```
[2022-10-15 16:12:38.902] runtime error: Cannot execute null.add().
- proc name: visibility (/datum/cameranet/proc/visibility)
-   source file: cameranet.dm,88
-   usr: AI (/mob/living/silicon/ai)
-   src: Camera Net (/datum/cameranet)
-   usr.loc: the floor (150,25,4) (/turf/open/floor/circuit)
-   call stack:
- Camera Net (/datum/cameranet): visibility(/list (/list), null, /list (/list), 1)
- AI (/mob/living/silicon/ai): camera visibility(Inactive AI Eye (/mob/eye/camera/ai))
- Inactive AI Eye (/mob/eye/camera/ai): setLoc(the floor (150,25,4) (/turf/open/floor/circuit), 0)
- AI (/mob/living/silicon/ai): create eye()
- AI (/mob/living/silicon/ai): Initialize(0, null, TagGamerGame2 (/mob/dead/new_player))
- Atoms (/datum/controller/subsystem/atoms): InitAtom(AI (/mob/living/silicon/ai), 0, /list (/list))
- AI (/mob/living/silicon/ai): New(0, null, TagGamerGame2 (/mob/dead/new_player))
- AI (/mob/living/silicon/ai): New(the floor (150,25,4) (/turf/open/floor/circuit), null, TagGamerGame2 (/mob/dead/new_player))
- /datum/job/ai (/datum/job/ai): get spawn mob(TagGamerGame2 (/client), AI (/obj/effect/landmark/start/ai))
- TagGamerGame2 (/mob/dead/new_player): create character(AI (/obj/effect/landmark/start/ai))
- Ticker (/datum/controller/subsystem/ticker): create characters()
- Ticker (/datum/controller/subsystem/ticker): setup()
- Ticker (/datum/controller/subsystem/ticker): fire(0)
- Ticker (/datum/controller/subsystem/ticker): ignite(0)
```

</details>

#### Downstream Issues Taken Upstream

If an issue reports a bug encountered at a branch of the codebase or on a downstream server, it **MUST** have a link to the branch or downstream codebase repo or it is eligible for closing (https://github.com/tgstation/tgstation/issues/70875#issuecomment-1295767891). Reproducing the issue on the compiled master of our codebase is also encouraged.

<details>
  <summary>Image macro for your issue marking pleasure</summary>

![image](https://user-images.githubusercontent.com/39163353/198381160-f0aa7fc4-4f2d-486f-8b33-44a1965e2ad1.svg)

`![image](https://user-images.githubusercontent.com/39163353/198381160-f0aa7fc4-4f2d-486f-8b33-44a1965e2ad1.svg)`

</details>

#### Link Code Snippets

To help triangulate bugs, search the GitHub repo to locate relevant code and attach it to an issue. Do this by creating a [link to the code](https://docs.github.com/en/github/writing-on-github/working-with-advanced-formatting/creating-a-permanent-link-to-a-code-snippet). This saves the contributors time from having to identify the problem and will be appreciated.

#### Use Gitblame

GitHub also has a tool called `gitblame` that is useful in [tracking code](https://docs.github.com/en/repositories/working-with-files/using-files/viewing-a-file#viewing-the-line-by-line-revision-history-for-a-file) to determine who and when someone made a change. This is ideally used to help solve old issues when there is uncertainty over which PR might have fixed it. It is also a good tool to use to link PRs that caused the issue.

#### Search For Keywords

When a new issue appears search for any keywords involved with the issue. This is important to prune for duplicates, match several issues to a test merge PR, or if you want to link multiple issues together since there is overlapping problems. (but not duplicate)

## Closing Issues

It is recommended to close issues in the following situations:

- **Feature Requests** [[1]](https://github.com/tgstation/tgstation/issues/55919) [[2]](https://github.com/tgstation/tgstation/issues/53342) [[3]](https://github.com/tgstation/tgstation/issues/45412) - The issue is a suggestion or request for a new feature to be added to the game.
- **Working as Intended** [[1]](https://github.com/tgstation/tgstation/issues/62619) [[2]](https://github.com/tgstation/tgstation/issues/61511) [[3]](https://github.com/tgstation/tgstation/issues/60942) - The issue is detailing a problem that is _specifically intended_ by the code and is not considered a bug.
- **Duplicates** [[1]](https://github.com/tgstation/tgstation/issues/62709) [[2]](https://github.com/tgstation/tgstation/issues/62364) [[3]](https://github.com/tgstation/tgstation/issues/61823) - The issue is detailing an identical problem from another issue. Do not automatically close the most recent issue. Instead compare both and close the one that provides the least information.
- **Removed Features** [[1]](https://github.com/tgstation/tgstation/issues/48255) [[2]](https://github.com/tgstation/tgstation/issues/47194) [[3]](https://github.com/tgstation/tgstation/issues/45653) - The issue is referring to something that was removed from the codebase and no longer exists.
- **Defective Issues** [[1]](https://github.com/tgstation/tgstation/issues/57366) [[2]](https://github.com/tgstation/tgstation/issues/48778) [[3]](https://github.com/tgstation/tgstation/issues/51520) - The issue is badly written and lacking information. Politely ask the person to add more information or rewrite the issue. If there is no response after a sufficient amount of time close the issue.
- **Irreproducible Issues** [[1]](https://github.com/tgstation/tgstation/issues/51493) [[2]](https://github.com/tgstation/tgstation/issues/22796) [[3]](https://github.com/tgstation/tgstation/issues/25610) - The issue is old, cannot be reproduced, and nobody has reported a duplicate issue recently. If you feel _confident_ that the issue has been fixed at some point, list your reasons or link possible PRs that could have fixed it.
- **Impossible to Fix Issues** [[1]](https://github.com/tgstation/tgstation/issues/524) [[2]](https://github.com/tgstation/tgstation/issues/2679) [[3]](https://github.com/tgstation/tgstation/issues/9637) - The issue is not possible to fix due to either vague details or a clearly defined problem.

## Reopening Issues

In special cases a closed issue should be reopened if:

- It has been updated with pertinent information (when before it was lacking info making it defective)
- The initial problem has reappeared (after it was presumably fixed in a PR)
- Someone feels that the issue was closed prematurely during discussion

If there is a dispute on whether an issue should remain closed, ask for a second opinion. Get clarification from another Issue Manager or Maintainer and respect their judgement as the final verdict.
