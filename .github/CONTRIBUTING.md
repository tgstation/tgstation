# CONTRIBUTING

1. [Reporting Issues](#reporting-issues)
2. [Introduction](#introduction)
3. [Getting Started](#getting-started)
4. [Meet the Team](#meet-the-team)
	1. [Headcoder](#headcoder)
	2. [Maintainers](#maintainers)
	3. [Issue Managers](#issue-managers)
5. [Development Guides](#development-guides)
6. [Pull Request Process](#pull-request-process)
7. [Good Boy Points](#good-boy-points)
8. [Porting features/sprites/sounds/tools from other codebases](#porting-featuresspritessoundstools-from-other-codebases)
9. [Banned content](#banned-content)
10. [A word on Git](#a-word-on-git)

## Reporting Issues

If you ever encounter a bug in-game, the best way to let a coder know about it is with our GitHub Issue Tracker. Please make sure you use the supplied issue template, and include the round ID for the server.

(If you don't have an account, making a new one takes only one minute.)

If you have difficulty, ask for help in the #coding-general channel on our discord.

## Introduction

Hello and welcome to /tg/station's contributing page. You are here because you are curious or interested in contributing - thank you! Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below; at /tg/station, we strive to maintain code stability and maintainability, and to do that, we need all pull requests to hold up to those specifications. It's in everyone's best interests - including yours! - if the same bug doesn't have to be fixed twice because of duplicated code.

First things first, we want to make it clear how you can contribute (if you've never contributed before), as well as the kinds of powers the team has over your additions, to avoid any unpleasant surprises if your pull request is closed for a reason you didn't foresee.

## Getting Started

/tg/station doesn't have a list of goals and features to add; we instead allow freedom for contributors to suggest and create their ideas for the game. That doesn't mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game. Here are some useful starting guides, if you want to contribute or if you want to know what challenges you can tackle with zero knowledge about the game's code structure.

If you want to contribute the first thing you'll need to do is [set up Git](http://tgstation13.org/wiki/Setting_up_git) so you can download the source code.
After setting it up, optionally navigate your git commandline to the project folder and run the command: `git config blame.ignoreRevsFile .git-blame-ignore-revs`.

We have a [list of guides on the wiki](http://www.tgstation13.org/wiki/Guides#Development_and_Contribution_Guides) that will help you get started contributing to /tg/station with Git and Dream Maker. For beginners, it is recommended you work on small projects like bugfixes at first. If you need help learning to program in BYOND, check out this [repository of resources](http://www.byond.com/developer/articles/resources).

There is an open list of approachable issues for [your inspiration here](https://github.com/tgstation/tgstation/issues?q=is%3Aopen+is%3Aissue+label%3A%22Good+First+Issue%22).

You can of course, as always, ask for help on the Discord channels or the forums. We're just here to have fun and help out, so please don't expect professional support.

## Meet the Team

### Headcoder

The Headcoder is responsible for controlling, adding, and removing maintainers from the project. In addition to filling the role of a normal maintainer, they have sole authority on who becomes a maintainer, as well as who remains a maintainer and who does not.

### Maintainers

Maintainers are quality control. If a proposed pull request doesn't meet the following specifications, they can request you to change it, or simply just close the pull request. Maintainers are required to give a reason for closing the pull request.

Maintainers can revert your changes if they feel they are not worth maintaining or if they did not live up to the quality specifications.

<details>
<summary>Maintainer Guidelines</summary>

These are the few directives we have for project maintainers.

- Do not merge PRs you create.
- Do not merge PRs until 24 hours have passed since it was opened. Exceptions include:
  - Emergency fixes.
    - Try to get secondary maintainer approval before merging if you are able to.
  - PRs with empty commits intended to generate a changelog.
- Do not merge PRs that contain content from the [banned content list](./CONTRIBUTING.md#banned-content).

These are not steadfast rules as maintainers are expected to use their best judgement when operating.

Our team is entirely voluntary, as such we extend our thanks to maintainers, issue managers, and contributors alike for helping keep the project alive.

</details>

### Issue Managers

Issue Managers help out the project by labelling bug reports and PRs and closing bug reports which are duplicates or are no longer applicable.

<details>
<summary>What You Can and Can't Do as an Issue Manager</summary>

This should help you understand what you can and can't do with your newfound github permissions.

Things you **CAN** do:
* Label issues appropriately
* Close issues when appropriate
* Label PRs when appropriate

Things you **CAN'T** do:
* [Close PRs](https://imgur.com/w2RqpX8.png): Only maintainers are allowed to close PRs. Do not hit that button.

</details>

## Development Guides

#### Writing readable code 
[Style guide](./guides/STYLE.md)

#### Writing sane code 
[Code standards](./guides/STANDARDS.md)

#### Writing understandable code 
[Autodocumenting code](./guides/AUTODOC.md)

#### Misc

[Policy configuration system](./guides/POLICYCONFIG.md)

[Hard deletes](./guides/HARDDELETES.md)

[UI Development](../tgui/README.md)

[AI Datums](../code/datums/ai/making_your_ai.md)

[MC Tab Guide](./guides/MC_tab.md)

## Pull Request Process

There is no strict process when it comes to merging pull requests. Pull requests will sometimes take a while before they are looked at by a maintainer; the bigger the change, the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be courteous and respectful. Here are some helpful ways to make it easier for you and for the maintainers when making a pull request.

* Make sure your pull request complies to the requirements outlined here

* You are expected to have tested your pull requests if it is anything that would warrant testing. Text only changes, single number balance changes, and similar generally don't need testing, but anything else does. This means by extension web edits are disallowed for larger changes.

* You are going to be expected to document all your changes in the pull request. Failing to do so will mean delaying it as we will have to question why you made the change. On the other hand, you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data. Should you be optimizing a routine you must provide proof by way of profiling that your changes are faster.

* We ask that you use the changelog system to document your player facing changes, which prevents our players from being caught unaware by said changes - you can find more information about this [on this wiki page](http://tgstation13.org/wiki/Guide_to_Changelogs).

* If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable.

* If your pull request is accepted, the code you add no longer belongs exclusively to you but to everyone; everyone is free to work on it, but you are also free to support or object to any changes being made, which will likely hold more weight, as you're the one who added the feature. It is a shame this has to be explicitly said, but there have been cases where this would've saved some trouble.

* Please explain why you are submitting the pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting the PR.

* If your pull request is not finished, you may open it as a draft for potential review. If you open it as a full-fledged PR make sure it is at least testable in a live environment. Pull requests that do not at least meet this requirement will be closed. You may request a maintainer reopen the pull request when you're ready, or make a new one.

* While we have no issue helping contributors (and especially new contributors) bring reasonably sized contributions up to standards via the pull request review process, larger contributions are expected to pass a higher bar of completeness and code quality *before* you open a pull request. Maintainers may close such pull requests that are deemed to be substantially flawed. You should take some time to discuss with maintainers or other contributors on how to improve the changes.

* After leaving reviews on an open pull request, maintainers may convert it to a draft. Once you have addressed all their comments to the best of your ability, feel free to mark the pull as `Ready for Review` again.

## Good Boy Points

Each GitHub account has a score known as Good Boy Points, or GBP. This is a system we use to ensure that the codebase stays maintained and that contributors fix bugs as well as add features.

The GBP gain or loss for a PR depends on the type of changes the PR makes, represented by the tags assigned to the PR by the tgstation github bot or maintainers. Generally speaking, fixing bugs, updating sprites, or improving maps increases your GBP score, while adding mechanics, or rebalancing things will cost you GBP.

You are not allowed to gain GBP from anything you were involved in, ie. if there's a bug with your feature, you don't get GBP for fixing it.

The GBP change of a PR is the sum of greatest positive and lowest negative values it has. For example, a PR that has tags worth +10, +4, -1, -7, will net 3 GBP (10 - 7).

Negative GBP increases the likelihood of a maintainer closing your PR. With that chance being higher the lower your GBP is. Be sure to use the proper tags in the changelog to prevent unnecessary GBP loss. Maintainers reserve the right to change tags as they deem appropriate.

There is no benefit to having a higher positive GBP score, since GBP only comes into consideration when it is negative.

You can see each tag and their GBP values [Here](https://github.com/tgstation/tgstation/blob/master/.github/gbp.toml). 

## Porting features/sprites/sounds/tools from other codebases

If you are porting features/tools from other codebases, you must give them credit where it's due. Typically, crediting them in your pull request and the changelog is the recommended way of doing it. Take note of what license they use though, porting stuff from AGPLv3 and GPLv3 codebases are allowed.

Regarding sprites & sounds, you must credit the artist and possibly the codebase. All /tg/station assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated. However if you are porting assets from GoonStation or usually any assets under the [Creative Commons 3.0 BY-NC-SA license](https://creativecommons.org/licenses/by-nc-sa/3.0/) are to go into the 'goon' folder of the /tg/station codebase.

## Banned content
Do not add any of the following in a Pull Request or risk getting the PR closed:
* National Socialist Party of Germany content, National Socialist Party of Germany related content, or National Socialist Party of Germany references
* Code adding, removing, or updating the availability of alien races/species/human mutants without prior approval. Pull requests attempting to add or remove features from said races/species/mutants require prior approval as well.
* Code which violates GitHub's [terms of service](https://github.com/site/terms).

Just because something isn't on this list doesn't mean that it's acceptable. Use common sense above all else.

## A word on Git
This repository uses `LF` line endings for all code as specified in the **.gitattributes** and **.editorconfig** files.

Unless overridden or a non standard git binary is used the line ending settings should be applied to your clone automatically.

Note: VSC requires an [extension](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) to take advantage of editorconfig.

Github actions that require additional configuration are disabled on the repository until ACTION_ENABLER secret is created with non-empty value.
