# Required Tests (Continuous Integration)

> ℹ️ This is not the documentation for *writing* a test. You can find that in [the unit tests folder](../../code/modules/unit_tests/README.md).

Every pull request runs through a series of checks and tests to ensure its quality.

![A picture of the automatic checks](https://user-images.githubusercontent.com/35135081/192867761-0edfe4e2-399c-4dc1-824e-ca042f8bbe4b.png)

If after reading this guide you still do not understand why a check suite is failing, either ask on your pull request or ask in the coding channel on the Discord.

## Run Linters

The [linters](https://en.wikipedia.org/wiki/Lint_(software)) check the maps and code for common mistakes. This includes things like:

- Files not being included in the .dme
- Misspelling Nanotrasen as NanoTrasen
- Unformatted map files

Sometimes linters will fail, but you won't see anything in the "Run Linters" tab. If you open up the action, it might look like this:

![Run Linters fails, but Annotate Lints does not](https://user-images.githubusercontent.com/35135081/192870304-f848d576-5bcd-41bf-9514-362e2972a401.png)

Specifically, notice that "Run Linters" has failed, but "Annotate Lints" has not. When this happens, click on Annotate Lints to see your problem.

![A lint error inside Annotate Lints, with Run Linters failing above it](https://user-images.githubusercontent.com/35135081/192870602-96dc6bcb-c24d-4d14-9f8c-6a40c93bcdb1.png)

You can also see the errors on the "Files Changed" tab of your pull request.

!["relatively pathed proc here", found in the Files Changed tab](https://user-images.githubusercontent.com/35135081/192870833-d2020500-3fcb-466f-9586-395df44c4095.png)

Linter failures are usually very easy to fix, and will hopefully be clear from the message alone.

## Compile Maps / Windows Build

These two check nothing more than that your code actually compiles, with slightly different requirements. Compile Maps forces all maps (including space ruins etc) to be compiled in, to make sure all of them are valid, and Windows Build makes sure your code actually compiles on Windows. If these tests pass, but other tests fail, it means your code *compiles* but not necessarily that it *works*.

## Integration Tests

The real meat and potatoes, this will not only compile the game, but also start a round, and run a bunch of premade tests. If anything runtimes (whether or not it's part of a specific test), there is a bug, and this test will fail. We run this for every station in the game to ensure maximum coverage. If all of these tests fail, your code is almost certainly bugged in some way! Read through the error, and try to resolve the issue. As always, ask maintainers if you need help.

Sometimes a test will fail on only one map, and not the others. This means two things. The first is, of course, there is a bug on that specific map. This could happen if you, for instance, do a large mapping change, but mess something up only on DeltaStation. The second option is that a flaky test has failed. Not all tests consistently fail/pass, [this is something we actively try to fix](https://github.com/tgstation/tgstation/issues?q=is%3Aopen%20is%3Aissue%20project%3Atgstation%2Ftgstation%2F19). If you believe this has happened to you, you should wait for a maintainer to re-run the failed test.

## Screenshot Tests

Screenshot tests exist to make sure things look the same before and after your commit. This helps us detect bugs such as humans not properly rendering clothing/limbs.

If your commit *does* change the appearance of something saved in a screenshot test, you will automatically receive a message on your PR showing you the before and after. From here, it will contain instructions for how to resolve the issue, whether it's a bug or intentional.

## Codeowner Reviews

GitHub comes with a handy feature where we can alert relevant contributors if you edit a file that they are knowledgable with. However, this feature only works with members of the organization. This is inadequate for our purposes, where we encourage contributors to keep an eye on stuff they create.

Thus, we created our own system that does what GitHub does, but in a way that supports codeowners outside of the organization.

This isn't a test, but if it fails, it's absolutely not your fault. Contact a maintainer.
