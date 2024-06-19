# Atomization (AKA, splitting up pull requests)

Maintainers are volunteers and have limited time to review pull requests. Large pull requests can be hard to review. You can help us help you by splitting your PR up into more manageable chunks.

## Keep it on topic

A pull request for changing the color of airlocks should not also change the damage for guns.

In general, keep balance PRs separate from fix/refactor PRs, unless there is a reasonable explanation for having them in the same pull request. For example, if in your PR for changing airlock colors, you clean up the code to improve variable names in airlock code, that is completely fine to keep in the same pull request. Fixes are something we can merge if the code looks right. Balance changes/new features are something we can only merge once we evaluate design concerns, which is much slower.

## Split it up if it's big

Sometimes a refactor might end up being a lot larger than you expect, and suddenly it is very hard for us to review, even though it's all on topic.

We encourage contributors to, when reasonable, split up huge refactors into several chunks, or to split them off from your features entirely. It is even okay to make a small pull request to add an easy to review API even if the code is unused, just be up front about the changes you are planning to make. These pull requests will be tagged with the "Atomic" label. Every so often, maintainers might look at past PRs with this label and remove the code if it is still unused, or if you have let us know you don't plan on finishing it (though in this case, please remove it yourself). When you should do this isn't written in stone; if adding a consumer of the API is just a matter of a few lines, then you should just do that. On the other hand, if adding this API requires touching a lot of existing code, and would be hard to remove if you don't finish, you may be asked to put it in the PR that adds the consumers.

This does not necessarily apply to features/balance changes. We don't want half of a feature implemented because it leaves you and us uncertain to if the followup pull requests are going to be merged. For example, do not add a new item to the game that goes completely unused until a separate pull request which decides where it's going to go.
