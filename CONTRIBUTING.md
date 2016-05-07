CONTRIBUTING TO VGSTATION
=========================

# General rules

* **Pull requests must be atomic.**  Change one set of related things at a time.  Bundling sucks for everyone.
 * This means, primarily, that you shouldn't fix bugs **and** add content in the same PR. When we mean 'bundling', we mean making one PR for multiple, unrelated changes.
* **Test your changes.**  PRs that do not compile will not be accepted.
 * Testing your changes locally is incredibly important. If you break the serb we will be very upset with you.
* **Large changes require discussion.**  If you're doing a large, game-changing modification, or a new layout for something, discussion with the community is required as of 26/6/2014.  Map and sprite changes require pictures of before and after.  **MAINTAINERS ARE NOT IMMUNE TO THIS.  GET YOUR ASS IN IRC.**
* Merging your own PRs is considered bad practice, as it generally means you bypass peer review, which is a core part of how we develop.

It is also suggested that you hop into irc.rizon.net #vgstation to discuss your changes, or if you need help.

# Other considerations

* If you're working with PNG and/or DMI files, you might want to check out and install the `pre-commit` git hook found [here](tools/git-hooks). This will automatically run `optipng` (if you have it) on your added/modified files, shaving off some bytes here and there.
