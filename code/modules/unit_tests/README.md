# Unit Tests

## What is unit testing?

Unit tests are automated code to verify that parts of the game work exactly as they should. For example, [a test to make sure that the amputation surgery actually amputates the limb](https://github.com/tgstation/tgstation/blob/e416283f162b86345a8623125ab866839b1ac40d/code/modules/unit_tests/surgeries.dm#L1-L13). These are ran every time a PR is made, and thus are very helpful for preventing bugs from cropping up in your code that would've otherwise gone unnoticed. For example, would you have thought to check [that beach boys would still work the same after editing pizza](https://github.com/tgstation/tgstation/pull/53641#issuecomment-691384934)? If you value your time, probably not.

On their most basic level, when `UNIT_TESTS` is defined, all subtypes of `/datum/unit_test` will have their `Run` proc executed. From here, if `Fail` is called at any point, then the tests will report as failed.

## How do I write one?
1. Find a relevant file.

All unit test related code is in `code/modules/unit_tests`. If you are adding a new test for a surgery, for example, then you'd open `surgeries.dm`. If a relevant file does not exist, simply create one in this folder, then `#include` it in `_unit_tests.dm`.

2. Create the unit test.

To make a new unit test, you simply need to define a `/datum/unit_test`.

For example, let's suppose that we are creating a test to make sure a proc `square` correctly raises inputs to the power of two. We'd start with first:

```
/datum/unit_test/square/Run()
```

This defines our new unit test, `/datum/unit_test/square`. Inside this function, we're then going to run through whatever we want to check. Tests provide a few assertion functions to make this easy. For now, we're going to use `TEST_ASSERT_EQUAL`.

```
/datum/unit_test/square/Run()
    TEST_ASSERT_EQUAL(square(3), 9, "square(3) did not return 9")
    TEST_ASSERT_EQUAL(square(4), 16, "square(4) did not return 16")
```

As you can hopefully tell, we're simply checking if the output of `square` matches the output we are expecting. If the test fails, it'll report the error message given as well as whatever the actual output was.

3. Run the unit test

Open `code/_compile_options.dm` and uncomment the following line.

```
//#define UNIT_TESTS			//If this is uncommented, we do a single run though of the game setup and tear down process with unit tests in between
```

Then, run tgstation.dmb in Dream Daemon. Don't bother trying to connect, you won't need to. You'll be able to see the outputs of all the tests. You'll get to see which tests failed and for what reason. If they all pass, you're set!

## How to think about tests

Unit tests exist to prevent bugs that would happen in a real game. Thus, they should attempt to emulate the game world wherever possible.  For example, the [quick swap sanity test](https://github.com/tgstation/tgstation/blob/e416283f162b86345a8623125ab866839b1ac40d/code/modules/unit_tests/quick_swap_sanity.dm) emulates a *real* scenario of the bug it fixed occurring by creating a character and giving it real items. The unrecommended alternative would be to create special test-only items. This isn't a hard rule, the [reagent method exposure tests](https://github.com/tgstation/tgstation/blob/e416283f162b86345a8623125ab866839b1ac40d/code/modules/unit_tests/reagent_mod_expose.dm) create a test-only reagent for example, but do keep it in mind.

Unit tests should also be just that--testing *units* of code. For example, instead of having one massive test for reagents, there are instead several smaller tests for testing exposure, metabolization, etc.

## The unit testing API

You can find more information about all of these from their respective doc comments, but for a brief overview:

`/datum/unit_test` - The base for all tests to be ran. Subtypes must override `Run()`. `New()` and `Destroy()` can be used for setup and teardown. To fail, use `TEST_FAIL(reason)`.

`/datum/unit_test/proc/allocate(type, ...)` - Allocates an instance of the provided type with the given arguments. Is automatically destroyed when the test is over. Commonly seen in the form of `var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)`.

`TEST_FAIL(reason)` - Marks a failure at this location, but does not stop the test.

`TEST_ASSERT(assertion, reason)` - Stops the unit test and fails if the assertion is not met. For example: `TEST_ASSERT(powered(), "Machine is not powered")`.

`TEST_ASSERT_NOTNULL(a, message)` - Same as `TEST_ASSERT`, but checks if `!isnull(a)`. For example: `TEST_ASSERT_NOTNULL(myatom, "My atom was never set!")`.

`TEST_ASSERT_NULL(a, message)` - Same as `TEST_ASSERT`, but checks if `isnull(a)`. If not, gives a helpful message showing what `a` was. For example: `TEST_ASSERT_NULL(delme, "Delme was never cleaned up!")`.

`TEST_ASSERT_EQUAL(a, b, message)` - Same as `TEST_ASSERT`, but checks if `a == b`. If not, gives a helpful message showing what both `a` and `b` were. For example: `TEST_ASSERT_EQUAL(2 + 2, 4, "The universe is falling apart before our eyes!")`.

`TEST_ASSERT_NOTEQUAL(a, b, message)` - Same as `TEST_ASSERT_EQUAL`, but reversed.

`TEST_FOCUS(test_path)` - *Only* run the test provided within the parameters. Useful for reducing noise. For example, if we only want to run our example square test, we can add `TEST_FOCUS(/datum/unit_test/square)`. Should *never* be pushed in a pull request--you will be laughed at.

## Final Notes

- Writing tests before you attempt to fix the bug can actually speed up development a lot! It means you don't have to go in game and folllow the same exact steps manually every time. This process is known as "TDD" (test driven development). Write the test first, make sure it fails, *then* start work on the fix/feature, and you'll know you're done when your tests pass. If you do try this, do make sure to confirm in a non-testing environment just to double check.
- Make sure that your tests don't accidentally call RNG functions like `prob`. Since RNG is seeded during tests, you may not realize you have until someone else makes a PR and the tests fail!
- Do your best not to change the behavior of non-testing code during tests. While it may sometimes be necessary in the case of situations such as the above, it is still a slippery slope that can lead to the code you're testing being too different from the production environment to be useful.
