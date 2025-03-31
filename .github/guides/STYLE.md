# Style Guide
This is the style you must follow when writing code. It's important to note that large parts of the codebase do not consistently follow these rules, but this does not free you of the requirement to follow them.

1. [General Guidelines](#general-guidelines)
2. [Paths and Inheritence](#paths-and-inheritence)
3. [Variables](#variables)
4. [Procs](#procs)
5. [Macros](#macros)
6. [Things that do not matter](#things-that-do-not-matter)

## General Guidelines

### Tabs, not spaces
You must use tabs to indent your code, NOT SPACES.

Do not use tabs/spaces for indentation in the middle of a code line. Not only is this inconsistent because the size of a tab is undefined, but it means that, should the line you're aligning to change size at all, we have to adjust a ton of other code. Plus, it often time hurts readability.

```dm
// Bad
#define SPECIES_MOTH			"moth"
#define SPECIES_LIZARDMAN		"lizardman"
#define SPECIES_FELINID			"felinid"

// Good
#define SPECIES_MOTH "moth"
#define SPECIES_LIZARDMAN "lizardman"
#define SPECIES_FELINID "felinid"
```

### Control statements
(if, while, for, etc)

* No control statement may contain code on the same line as the statement (`if (blah) return`)
* All control statements comparing a variable to a number should use the formula of `thing` `operator` `number`, not the reverse (eg: `if (count <= 10)` not `if (10 >= count)`)

### Operators
#### Spacing
* Operators that should be separated by spaces
	* Boolean and logic operators like &&, || <, >, ==, etc (but not !)
	* Bitwise AND &
	* Argument separator operators like , (and ; when used in a forloop)
	* Assignment operators like = or += or the like
* Operators that should not be separated by spaces
	* Bitwise OR |
	* Access operators like . and :
	* Parentheses ()
	* logical not !

Math operators like +, -, /, *, etc are up in the air, just choose which version looks more readable.

#### Use
* Bitwise AND - '&'
	* Should be written as `variable & CONSTANT` NEVER `CONSTANT & variable`. Both are valid, but the latter is confusing and nonstandard.
* Associated lists declarations must have their key value quoted if it's a string
	* WRONG: `list(a = "b")`
	* RIGHT: `list("a" = "b")`

### Use static instead of global
DM has a var keyword, called global. This var keyword is for vars inside of types. For instance:

```DM
/mob
	var/global/thing = TRUE
```
This does NOT mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing?

There is also an undocumented keyword called `static` that has the same behaviour as global but more correctly describes BYOND's behaviour. Therefore, we always use static instead of global where we need it, as it reduces suprise when reading BYOND code.

### Use early returns
Do not enclose a proc in an if-block when returning on a condition is more feasible
This is bad:
````DM
/datum/datum1/proc/proc1()
	if (thing1)
		if (!thing2)
			if (thing3 == 30)
				do stuff
````
This is good:
````DM
/datum/datum1/proc/proc1()
	if (!thing1)
		return
	if (thing2)
		return
	if (thing3 != 30)
		return
	do stuff
````
This prevents nesting levels from getting deeper then they need to be.

### No magic numbers or strings
This means stuff like having a "mode" variable for an object set to "1" or "2" with no clear indicator of what that means. Make these #defines with a name that more clearly states what it's for. For instance:
````DM
/datum/proc/do_the_thing(thing_to_do)
	switch(thing_to_do)
		if(1)
			(...)
		if(2)
			(...)
````
There's no indication of what "1" and "2" mean! Instead, you'd do something like this:
````DM
#define DO_THE_THING_REALLY_HARD 1
#define DO_THE_THING_EFFICIENTLY 2
/datum/proc/do_the_thing(thing_to_do)
	switch(thing_to_do)
		if(DO_THE_THING_REALLY_HARD)
			(...)
		if(DO_THE_THING_EFFICIENTLY)
			(...)
````
This is clearer and enhances readability of your code! Get used to doing it!

### Use our time defines

The codebase contains some defines which will automatically multiply a number by the correct amount to get a number in deciseconds. Using these is preffered over using a literal amount in deciseconds.

The defines are as follows:
* SECONDS
* MINUTES
* HOURS

This is bad:
````DM
/datum/datum1/proc/proc1()
	if(do_after(mob, 15))
		mob.dothing()
````

This is good:
````DM
/datum/datum1/proc/proc1()
	if(do_after(mob, 1.5 SECONDS))
		mob.dothing()
````

## Paths and Inheritence
### All BYOND paths must contain the full path
(i.e. absolute pathing)

DM will allow you nest almost any type keyword into a block, such as:

```DM
// Not our style!
datum
	datum1
		var
			varname1 = 1
			varname2
			static
				varname3
				varname4
		proc
			proc1()
				code
			proc2()
				code

		datum2
			varname1 = 0
			proc
				proc3()
					code
			proc2()
				. = ..()
				code
```

The use of this is not allowed in this project as it makes finding definitions via full text searching next to impossible. The only exception is the variables of an object may be nested to the object, but must not nest further.

The previous code made compliant:

```DM
// Matches /tg/station style.
/datum/datum1
	var/varname1
	var/varname2
	var/static/varname3
	var/static/varname4

/datum/datum1/proc/proc1()
	code
/datum/datum1/proc/proc2()
	code
/datum/datum1/datum2
	varname1 = 0
/datum/datum1/datum2/proc/proc3()
	code
/datum/datum1/datum2/proc2()
	. = ..()
	code
```

### Type paths must begin with a `/`
eg: `/datum/thing`, not `datum/thing`

### Type paths must be snake case
eg: `/datum/blue_bird`, not `/datum/BLUEBIRD` or `/datum/BlueBird` or `/datum/Bluebird` or `/datum/blueBird`

### Datum type paths must began with "datum"
In DM, this is optional, but omitting it makes finding definitions harder.

## Variables

### Use `var/name` format when declaring variables
While DM allows other ways of declaring variables, this one should be used for consistency.

### Use descriptive and obvious names
Optimize for readability, not writability. While it is certainly easier to write `M` than `victim`, it will cause issues down the line for other developers to figure out what exactly your code is doing, even if you think the variable's purpose is obvious.

#### Any variable or argument that holds time and uses a unit of time other than decisecond must include the unit of time in the name.
For example, a proc argument named `delta_time` that marks the seconds between fires could confuse somebody who assumes it stores deciseconds. Naming it `delta_time_seconds` makes this clearer, naming it `seconds_per_tick` makes its purpose even clearer.

### Don't use abbreviations
Avoid variables like C, M, and H. Prefer names like "user", "victim", "weapon", etc.

```dm
// What is M? The user? The target?
// What is A? The target? The item?
/proc/use_item(mob/M, atom/A)

// Much better!
/proc/use_item(mob/user, atom/target)
```

Unless it is otherwise obvious, try to avoid just extending variables like "C" to "carbon"--this is slightly more helpful, but does not describe the *context* of the use of the variable.

### Naming things when typecasting
When typecasting, keep your names descriptive:
```dm
var/mob/living/living_target = target
var/mob/living/carbon/carbon_target = living_target
```

Of course, if you have a variable name that better describes the situation when typecasting, feel free to use it.

Note that it's okay, semantically, to use the same variable name as the type, e.g.:
```dm
var/atom/atom
var/client/client
var/mob/mob
```

Your editor may highlight the variable names, but BYOND, and we, accept these as variable names:

```dm
// This functions properly!
var/client/client = CLIENT_FROM_VAR(usr)
// vvv this may be highlighted, but it's fine!
client << browse(...)
```

### Name things as directly as possible
`was_called` is better than `has_been_called`. `notify` is better than `do_notification`.

### Avoid negative variable names
`is_flying` is better than `is_not_flying`. `late` is better than `not_on_time`.
This prevents double-negatives (such as `if (!is_not_flying)` which can make complex checks more difficult to parse.

### Exceptions to variable names

Exceptions can be made in the case of inheriting existing procs, as it makes it so you can use named parameters, but *new* variable names must follow these standards. It is also welcome, and encouraged, to refactor existing procs to use clearer variable names.

Naming numeral iterator variables `i` is also allowed, but do remember to [Avoid unnecessary type checks and obscuring nulls in lists](./STANDARDS.md#avoid-unnecessary-type-checks-and-obscuring-nulls-in-lists), and making more descriptive variables is always encouraged.

```dm
// Bad
for (var/datum/reagent/R as anything in reagents)

// Good
for (var/datum/reagent/deadly_reagent as anything in reagents)

// Allowed, but still has the potential to not be clear. What does `i` refer to?
for (var/i in 1 to 12)

// Better
for (var/month in 1 to 12)

// Bad, only use `i` for numeral loops
for (var/i in reagents)
```

### Don't abuse the increment/decrement operators
`x++` and `++x` both will increment x, but the former will return x *before* it was incremented, while the latter will return x *after* it was incremented. Great if you want to be clever, or if you were a C programmer in the 70s, but it hurts the readability of code to anyone who isn't familiar with this. The convenience is not nearly good enough to justify this burden.

```dm
// Bad
world.log << "You now have [++apples] apples."

// Good
apples++
// apples += 1 - Allowed
world.log << "You now have [apples] apples."

// Bad
world.log << "[apples--] apples left, taking one."

// Good
world.log << "[apples] apples left, taking one."
apples--
```

### initial() versus ::
`::` is a compile time scope operator which we use as an alternative to `initial()`.
It's used within the definition of a datum as opposed to `Initialize` or other procs.

```dm
// Bad
/atom/thing/better
	name = "Thing"

/atom/thing/better/Initialize()
	var/atom/thing/parent = /atom/thing
	desc = inital(parent)

// Good
/atom/thing/better
	name = "Thing"
	desc = /atom/thing::desc
```

Another good use for it easy access of the parent's variables.
```dm
/obj/item/fork/dangerous
	damage = parent_type::damage * 2
```

```dm
/obj/item/fork
	flags_1 = parent_type::flags_1 | FLAG_COOLER
```


It's important to note that `::` does not apply to every application of `initial()`.
Primarily in cases where the type you're using for the initial value is not static.

For example,
```dm
/proc/cmp_subsystem_init(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return initial(b.init_order) - initial(a.init_order)
```
could not use `::` as the provided types are not static.

## Procs

### Getters and setters

* Avoid getter procs. They are useful tools in languages with that properly enforce variable privacy and encapsulation, but DM is not one of them. The upfront cost in proc overhead is met with no benefits, and it may tempt to develop worse code.

This is bad:
```DM
/datum/datum1/proc/simple_getter()
	return gotten_variable
```
Prefer to either access the variable directly or use a macro/define.


* Make usage of variables or traits, set up through condition setters, for a more maintainable alternative to compex and redefined getters.

These are bad:
```DM
/datum/datum1/proc/complex_getter()
	return condition ? VALUE_A : VALUE_B

/datum/datum1/child_datum/complex_getter()
	return condition ? VALUE_C : VALUE_D
```

This is good:
```DM
/datum/datum1
	var/getter_turned_into_variable

/datum/datum1/proc/set_condition(new_value)
	if(condition == new_value)
		return
	condition = new_value
	on_condition_change()

/datum/datum1/proc/on_condition_change()
	getter_turned_into_variable = condition ? VALUE_A : VALUE_B

/datum/datum1/child_datum/on_condition_change()
	getter_turned_into_variable = condition ? VALUE_C : VALUE_D
```

### When passing vars through New() or Initialize()'s arguments, use src.var
Using src.var + naming the arguments the same as the var is the most readable and intuitive way to pass arguments into a new instance's vars. The main benefit is that you do not need to give arguments odd names with prefixes and suffixes that are easily forgotten in `new()` when sending named args.

This is very bad:
```DM
/atom/thing
	var/is_red

/atom/thing/Initialize(mapload, enable_red)
	is_red = enable_red

/proc/make_red_thing()
	new /atom/thing(null, enable_red = TRUE)
```

Future coders using this code will have to remember two differently named variables which are near-synonyms of eachother. One of them is only used in Initialize for one line.

This is bad:
```DM
/atom/thing
	var/is_red

/atom/thing/Initialize(mapload, _is_red)
	is_red = _is_red

/proc/make_red_thing()
	new /atom/thing(null, _is_red = TRUE)
```

`_is_red` is being used to set `is_red` and yet means a random '_' needs to be appended to the front of the arg, same as all other args like this.

This is good:
```DM
/atom/thing
	var/is_red

/atom/thing/Initialize(mapload, is_red)
	src.is_red = is_red

/proc/make_red_thing()
	new /atom/thing(null, is_red = TRUE)
```

Setting `is_red` in args is simple, and directly names the variable the argument sets.

### Prefer named arguments when the meaning is not obvious.

Pop-quiz, what does this do?

```dm
give_pizza(TRUE, 2)
```

Well, obviously the `TRUE` makes the pizza hot, and `2` is the number of toppings. 

Code like this can be very difficult to read, especially since our LSP does not show argument names at this time. Because of this, you should prefer to use named arguments where the meaning is not otherwise obvious.

```dm
give_pizza(hot = TRUE, toppings = 2)
```

What is "obvious" is subjective--for instance, `give_pizza(PIZZA_HOT, toppings = 2)` is completely acceptable.

Other examples:

```dm
deal_damage(10) // Fine! The proc name makes it obvious `10` is the damage...at least it better be.
deal_damage(10, FIRE) // Also fine! `FIRE` makes it obvious the second parameter is damage type.
deal_damage(damage = 10) // Redundant, but not prohibited.

use_energy(30 JOULES) // Use energy in joules.
turn_on(30) // Not fine!
turn_on(power_usage = 30) // Fine!

set_invincible(FALSE) // Fine! Boolean parameters don't always need to be named. In this case, it is obvious what it means.
```

## Multi-lining

Whether it's a very long proc call, a long list people will be adding to, or something else entirely, there may be times where splitting code across multiple lines is the most readable. When you have to is up to maintainer discretion, but if you do, follow this consistent style.

```dm
proc_call_on_one_line(
	arg1, // Only indent once! Remember to not align tabs.
	arg2,
	arg3, // End with a trailing comma
) // The parenthesis should be on the same indentation level as the proc call
```

For example:
```dm
/area/town
	var/list/places_to_visit = list(
		"Coffee Shop",
		"Dance Club",
		"Gift Shop",
	)
```

This is not a strict rule and there may be times where you can place the lines in a more sensible spot. For example:

```dm
act(list(
	// Fine!
))

act(
	list(
		// Fine, though verbose
	)
)

act(x, list(
	// Also fine!
))

act(x, list(

), y) // Getting clunky, might want to split this up!
```

Occasionally, you will need to use backslashes to multiline. This happens when you are calling a macro. This comes up often with `AddComponent`. For example,

```dm
AddComponent( \
	/datum/component/makes_sound, \
	"chirp", \
	volume = 10, \
)
```

Backslashes should only be used when necessary, and they are only necessary for macros.

## Macros

Macros are, in essence, direct copy and pastes into the code. They are one of the few zero cost abstractions we have in DM, and you will see them often. Macros have strange syntax requirements, so if you see lots of backslashes and semicolons and braces that you wouldn't normally see, that is why.

This section will assume you understand the following concepts:

### Language - Hygienic
We say a macro is [**hygienic**](https://en.wikipedia.org/wiki/Hygienic_macro) if, generally, it does not rely on input not given to it directly through the call site, and does not affect the call site outside of it in a way that could not be easily reused somewhere else.

An example of a non-hygienic macro is:

```dm
#define GET_HEALTH(health_percent) ((##health_percent) * max_health)
```

In here, we rely on the external `max_health` value.

Here are two examples of non-hygienic macros, because it affects its call site:

```dm
#define DECLARE_MOTH(name) var/mob/living/moth/moth = new(##name)
#define RETURN_IF(condition) if (condition) { return; }
```

### Language - Side effects/Pure
We say something has [**side effects**](https://en.wikipedia.org/wiki/Side_effect_(computer_science)) if it mutates anything outside of itself. We say something is **pure** if it does not.

For example, this has no side effects, and is pure:
```dm
#define MOTH_MAX_HEALTH 500
```

This, however, performs a side effect of updating the health:
```dm
#define MOTH_SET_HEALTH(moth, new_health) ##moth.set_health(##new_health)
```

Now that you're caught up on the terms, let's get into the guidelines.

### Naming
With little exception, macros should be SCREAMING_SNAKE_CASE.

### Put macro segments inside parentheses where possible.
This will save you from bugs down the line with operator precedence.

For example, the following macro:

```dm
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION T20C + 10
```

...will break when order of operations comes into play:

```dm
var/temperature = MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION * 50

// ...is preprocessed as...
var/temperature = T20C + 10 * 50 // Oh no! T20C + 500!
```

This is [a real bug that tends to come up](https://github.com/tgstation/tgstation/pull/37116), so to prevent it, we defensively wrap macro bodies with parentheses where possible.

```dm
// Phew!
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION (T20C + 10)
```

The same goes for arguments passed to a macro...

```
// Guarantee 
#define CALCULATE_TEMPERATURE(base) (T20C + (##base))
```

### Be hygienic where reasonably possible

Consider the previously mentioned non-hygienic macro:

```dm
#define GET_HEALTH(health_percent) ((##health_percent) * max_health)
```

This relies on "max_health", but it is not obviously clear what the source is. This will also become worse if we *do* want to change where we get the source from. This would be preferential as:

```dm
#define GET_HEALTH(source, health_percent) ((##health_percent) * (##source).max_health)
```

When a macro can't be hygienic, such as in the case where a macro is preferred to do something like define a variable, it should still do its best to rely only on input given to it:

```dm
#define DECLARE_MOTH(name) var/mob/living/moth/moth = new(##name)
```

...would ideally be written as...

```dm
#define DECLARE_MOTH(var_name, name) var/mob/living/moth/##var_name = new(##name)
```

As usual, exceptions exist--for instance, accessing a global like a subsystem within a macro is generally acceptable.

### Preserve hygiene using double underscores (`__`) and `do...while (FALSE)`

Some macros will want to create variables for themselves, and not the consumer. For instance, consider this macro:

```dm
#define HOW_LONG(proc_to_call) \
	var/current_time = world.time; \
	##proc_to_call(); \
	world.log << "That took [world.time - current_time] deciseconds to complete.";
```

There are two problems here.

One is that it is unhygienic. The `current_time` variable is leaking into the call site.

The second is that this will create weird errors if `current_time` is a variable that already exists, for instance:

```dm
var/current_time = world.time

HOW_LONG(make_soup) // This will error!
```

If this seems unlikely to you, then also consider that this:

```dm
HOW_LONG(make_soup)
HOW_LONG(eat_soup)
```

...will also error, since they are both declaring the same variable!

There is a way to solve both of these, and it is through both the `do...while (FALSE)` pattern and by using `__` for variable names.

This code would change to look like:

```dm
#define HOW_LONG(proc_to_call) \
	do { \
		var/__current_time = world.time; \
		##proc_to_call(); \
		world.log << "That took [world.time - current_time] deciseconds to complete."; \
	} while (FALSE)
```

The point of the `do...while (FALSE)` here is to **create another scope**. It is impossible for `__current_time` to be used outside of the define itself. If you haven't seen `do...while` syntax before, it is just saying "do this while the condition is true", and by passing `FALSE`, we ensure it will only run once.

### Keep anything you use more than once in variables

Remember that macros are just pastes. This means that, if you're not thinking, you can end up [creating some really weird macros by reusing variables](https://github.com/tgstation/tgstation/pull/55074).

```dm
#define TEST_ASSERT_EQUAL(a, b) \
 	if ((##a) != (##b)) { \
		return Fail("Expected [##a] to be equal to [##b]."); \
	}
```

This code may look benign, but consider the following code:

```dm
/// Deal damage to the mob, and return their new health
/mob/living/proc/attack_mob(damage)
	health -= damage
	say("Ouch!")
	return health

// Later, in a test, assuming mobs start at 100 health
TEST_ASSERT_EQUAL(victim.attack_mob(20), 60)
```

We're only dealing 20 damage to the mob, so it'll have 80 health left. But the test will fail, and report `Expected 60 to be equal to 60.`

Uh oh! That's because this compiled to:

```dm
if ((victim.attack_mob(20)) != 60)
	return Fail("Expected [victim.attack_mob(20)] to be equal to [60].")
```

It's running the proc twice!

To fix this, we need to make sure the proc only runs once, by creating a variable for it, and using our `do...while (FALSE)` pattern we learned earlier.

```dm
#define TEST_ASSERT_EQUAL(a, b) \
	do { \
		var/__a_value = ##a;
		var/__b_value = ##b;

		if (__a_value != __b_value) { \
			return Fail("Expected [__a_value] to be equal to [__b_value]."); \
		} \
	} while (FALSE)
```

Now our code correctly reports `Expected 80 to be equal to 60`.

### ...but if you must be unhygienic, try to restrict the scope.

This guideline can make some code look extremely noisy if you are writing a large proc, or using the macro a large amount of times.

In this case, if your macro is only used by one proc, define the macro in that proc, ideally after whatever variables it uses.

```dm
/proc/some_complex_proc()
	var/counter = 0

	#define MY_NECESSARY_MACRO counter += 5; do_something(counter);

	// My complex code that uses MY_NECESSARY_MACRO here...

	#undef MY_NECESSARY_MACRO
```

### Don't perform work in an unsuspecting macro

Suppose we have the following macro:

```dm
#define PARTY_LIGHT_COLOR (pick(COLOR_BLUE, COLOR_RED, COLOR_GREEN))
```

When this is used, it'll look like:

```dm
set_color(PARTY_LIGHT_COLOR)
```

Because of how common using defines as constants is, this would seemingly imply the same thing! It does not look like any code should be executing at all. This code would preferably look like:

```dm
set_color(PARTY_LIGHT_COLOR())
```

...which *does* imply some work is happening.

BYOND does not support `#define PARTY_LIGHT_COLOR()`, so instead we would write the define as:

```dm
#define PARTY_LIGHT_COLOR(...) (pick(COLOR_BLUE, COLOR_RED, COLOR_GREEN))
```

### `#undef` any macros you create, unless they are needed elsewhere

We do not want macros to leak outside their file, this will create odd dependencies that are based on the filenames. Thus, you should `#undef` any macro you make.

```dm
// Start of corn.dm
#define CORN_KERNELS 5

// All my brilliant corn code

#undef CORN_KERNELS
```

It is often preferable for your `#define` and `#undef` to surround the code that actually uses them, for instance:

```dm
/obj/item/corn
	name = "yummy corn"

#define CORN_HEALTH_GAIN 5

/obj/item/corn/proc/eat(mob/living/consumer)
	consumer.health += CORN_HEALTH_GAIN // yum

#undef CORN_HEALTH_GAIN

// My other corn code
```

If you want other files to use macros, put them in somewhere such as a file in `__DEFINES`. That way, the files are included in a consistent order:

```dm
#include "__DEFINES/my_defines.dm" // Will always be included first, because of the underscores
#include "game/my_object.dm" // This will be able to consistently use defines put in my_defines.dm
```

### Use `##` to help with ambiguities

Especially with complex macros, it might not be immediately obvious what's part of the macro and what isn't.

```dm
#define CALL_PROC_COMPLEX(source, proc_name) \
	if (source.is_ready()) { \
		source.proc_name(); \
	}
```

`source` and `proc_name` are both going to be directly pasted in, but they look just like any other normal code, and so it makes reading this macro a bit harder.

Consider instead:

```dm
#define CALL_PROC_COMPLEX(source, proc_name) \
	if (##source.is_ready()) { \
		##source.##proc_name(); \
	}
```

`##` will paste in the define parameter directly, and makes it more clear what belongs to the macro.

This is the most subjective of all the guidelines here, as it might just create visual noise in very simple macros, so use your best judgment.

### For impure/unhygienic defines, use procs/normal code when reasonable

Sometimes the best macro is one that doesn't exist at all. Macros can make some code fairly hard to maintain, due to their very weird syntax restrictions, and can be generally fairly mysterious, and hurt readability. Thus, if you don't have a strong reason to use a macro, consider just writing the code out normally or using a proc.

```dm
#define SWORD_HIT(sword, victim) { /* Ugly backslashes! */ \
	##sword.attack(##victim); /* Ugly semicolons! */ \
	##victim.say("Ouch!"); /* Even ugly comments! */ \
}
```

This is a fairly egregious macro, and would be better off just written like:
```dm
/obj/item/sword/proc/hit(mob/victim)
	attack(victim)
	victim.say("Ouch!")
```

## Things that do not matter
The following coding styles are not only not enforced at all, but are generally frowned upon to change for little to no reason:

* English/British spelling on var/proc names
	* Color/Colour - both are fine, but keep in mind that BYOND uses `color` as a base variable
* Spaces after control statements
	* `if()` and `if ()` - nobody cares!
