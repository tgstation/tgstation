# CONTRIBUTING

## Reporting Issues

See [this page](http://tgstation13.org/wiki/Reporting_Issues) for a guide and format to issue reports.

## Introduction

Hello and welcome to /tg/station's contributing page. You are here because you are curious or interested in contributing - thank you! Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below; at /tg/station, we strive to maintain code stability and maintainability, and to do that, we need all pull requests to hold up to those specifications. It's in everyone's best interests - including yours! - if the same bug doesn't have to be fixed twice because of duplicated code.

First things first, we want to make it clear how you can contribute (if you've never contributed before), as well as the kinds of powers the team has over your additions, to avoid any unpleasant surprises if your pull request is closed for a reason you didn't foresee.

## Getting Started

/tg/station doesn't have a list of goals and features to add; we instead allow freedom for contributors to suggest and create their ideas for the game. That doesn't mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game. Here are some useful starting guides, if you want to contribute or if you want to know what challenges you can tackle with zero knowledge about the game's code structure.

If you want to contribute the first thing you'll need to do is [set up Git](http://tgstation13.org/wiki/Setting_up_git) so you can download the source code.

We have a [list of guides on the wiki](http://www.tgstation13.org/wiki/index.php/Guides#Development_and_Contribution_Guides) that will help you get started contributing to /tg/station with Git and Dream Maker. For beginners, it is recommended you work on small projects like bugfixes at first. If you need help learning to program in BYOND, check out this [repository of resources](http://www.byond.com/developer/articles/resources).

There is an open list of approachable issues for [your inspiration here](https://github.com/tgstation/-tg-station/issues?q=is%3Aopen+is%3Aissue+label%3A%22Easy+Fix%22).

You can of course, as always, ask for help at [#coderbus](irc://irc.rizon.net/coderbus) on irc.rizon.net. We're just here to have fun and help out, so please don't expect professional support.

## Meet the Team

**Design Lead**

The Design Lead has the final say on what gameplay changes get into and out of the game. He or she has full veto power on any feature or balance additions, changes, or removals, and establishes a general, personally-preferred direction for the game.

**Headcoder**

The Headcoder is responsible for controlling, adding, and removing maintainers from the project. In addition to filling the role of a normal maintainer, they have sole authority on who becomes a maintainer, as well as who remains a maintainer and who does not.

**Art Director**

The Art Director controls sprites and aesthetic that get into the game. While sprites for brand-new additions are generally accepted regardless of quality, modified current art assets fall to the Art Director, who can decide whether or not a sprite tweak is both merited and a suitable replacement.

They also control the general "perspective" of the game - how sprites should generally look, especially the angle from which they're viewed. An example of this is the [3/4 perspective](http://static.tvtropes.org/pmwiki/pub/images/kakarikovillage.gif), which is a bird's eye view from above the object being viewed.

**Maintainers**

Maintainers are quality control. If a proposed pull request doesn't meet the following specifications, they can request you to change it, or simply just close the pull request. Maintainers are required to give a reason for closing the pull request.

Maintainers can revert your changes if they feel they are not worth maintaining or if they did not live up to the quality specifications.

## Specifications

As mentioned before, you are expected to follow these specifications in order to make everyone's lives easier. It'll save both your time and ours, by making sure you don't have to make any changes and we don't have to ask you to. Thank you for reading this section!

### Object Oriented Code
As BYOND's Dream Maker (henceforth "DM") is an object-oriented language, code must be object-oriented when possible in order to be more flexible when adding content to it. If you don't know what "object-oriented" means, we highly recommend you do some light research to grasp the basics.

### All BYOND paths must contain the full path.
(i.e. absolute pathing)

DM will allow you nest almost any type keyword into a block, such as:

```DM
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
				..()
				code
```

The use of this is not allowed in this project as it makes finding definitions via full text searching next to impossible. The only exception is the variables of an object may be nested to the object, but must not nest further.

The previous code made compliant:

```DM
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
	..()
	code
```

### No overriding type safety checks.
The use of the : operator to override type safety checks is not allowed. You must cast the variable to the proper type.

### Type paths must begin with a /
eg: `/datum/thing`, not `datum/thing`

### Datum type paths must began with "datum"
In DM, this is optional, but omitting it makes finding definitions harder.

### Do not use text/string based type paths
It is rarely allowed to put type paths in a text format, as there are no compile errors if the type path no longer exists. Here is an example:

```DM
//Good
var/path_type = /obj/item/weapon/baseball_bat

//Bad
var/path_type = "/obj/item/weapon/baseball_bat"
```

### Tabs, not spaces
You must use tabs to indent your code, NOT SPACES.

(You may use spaces to align something, but you should tab to the block level first, then add the remaining spaces)

### No hacky code
Hacky code, such as adding specific checks, is highly discouraged and only allowed when there is ***no*** other option. (Protip: 'I couldn't immediately think of a proper way so thus there must be no other option' is not gonna cut it here! If you can't think of anything else, say that outright and admit that you need help with it. Maintainers exist for exactly that reason.)

You can avoid hacky code by using object-oriented methodologies, such as overriding a function (called "procs" in DM) or sectioning code into functions and then overriding them as required.

### No duplicated code
Copying code from one place to another may be suitable for small, short-time projects, but /tg/station is a long-term project and highly discourages this.

Instead you can use object orientation, or simply placing repeated code in a function, to obey this specification easily.

### Startup/Runtime tradeoffs with lists and the "hidden" init proc
First, read the comments in [this BYOND thread](http://www.byond.com/forum/?post=2086980&page=2#comment19776775), starting where the link takes you.

There are two key points here:

1) Defining a list in the variable's definition calls a hidden proc - init. If you have to define a list at startup, do so in New() (or preferably Initialize()) and avoid the overhead of a second call (Init() and then New())

2) It also consumes more memory to the point where the list is actually required, even if the object in question may never use it!

Remember: although this tradeoff makes sense in many cases, it doesn't cover them all. Think carefully about your addition before deciding if you need to use it.

### Prefer `Initialize()` over `New()` for atoms
Our game controller is pretty good at handling long operations and lag, but it can't control what happens when the map is loaded, which calls `New` for all atoms on the map. If you're creating a new atom, use the `Initialize` proc to do what you would normally do in `New`. This cuts down on the number of proc calls needed when the world is loaded. See here for details on `Initialize`: https://github.com/tgstation/tgstation/blob/master/code/game/atoms.dm#L49
While we normally encourage (and in some cases, even require) bringing out of date code up to date when you make unrelated changes near the out of date code, that is not the case for `New` -> `Initialize` conversions. These systems are generally more dependant on parent and children procs so unrelated random conversions of existing things can cause bugs that take months to figure out.

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

### Control statements
(if, while, for, etc)

* All control statements must not contain code on the same line as the statement (`if (blah) return`)
* All control statements comparing a variable to a number should use the formula of `thing` `operator` `number`, not the reverse (eg: `if (count <= 10)` not `if (10 >= count)`)

### Use early return
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

### Develop Secure Code

* Player input must always be escaped safely, we recommend you use stripped_input in all cases where you would use input. Essentially, just always treat input from players as inherently malicious and design with that use case in mind

* Calls to the database must be escaped properly - use sanitizeSQL to escape text based database entries from players or admins, and isnum() for number based database entries from players or admins.

* All calls to topics must be checked for correctness. Topic href calls can be easily faked by clients, so you should ensure that the call is valid for the state the item is in. Do not rely on the UI code to provide only valid topic calls, because it won't.

* Information that players could use to metagame (that is, to identify round information and/or antagonist type via information that would not be available to them in character) should be kept as administrator only.

* It is recommended as well you do not expose information about the players - even something as simple as the number of people who have readied up at the start of the round can and has been used to try to identify the round type.

* Where you have code that can cause large-scale modification and *FUN*, make sure you start it out locked behind one of the default admin roles - use common sense to determine which role fits the level of damage a function could do.

### Files
* Because runtime errors do not give the full path, try to avoid having files with the same name across folders.

* File names should not be mixed case, or contain spaces or any character that would require escaping in a uri.

* Files and path accessed and referenced by code above simply being #included should be strictly lowercase to avoid issues on filesystems where case matters.

### SQL
* Do not use the shorthand sql insert format (where no column names are specified) because it unnecessarily breaks all queries on minor column changes and prevents using these tables for tracking outside related info such as in a connected site/forum.

* All changes to the database's layout(schema) must be specified in the database changelog in SQL, as well as reflected in the schema files

* Queries must never specify the database, be it in code, or in text files in the repo.



### Other Notes
* Code should be modular where possible; if you are working on a new addition, then strongly consider putting it in its own file unless it makes sense to put it with similar ones (i.e. a new tool would go in the "tools.dm" file)

* Bloated code may be necessary to add a certain feature, which means there has to be a judgement over whether the feature is worth having or not. You can help make this decision easier by making sure your code is modular.

* You are expected to help maintain the code that you add, meaning that if there is a problem then you are likely to be approached in order to fix any issues, runtimes, or bugs.

* Do not divide when you can easily convert it to multiplication. (ie `4/2` should be done as `4*0.5`)

#### Enforced not enforced
The following coding styles are not only not enforced at all, but are generally frowned upon to change for little to no reason:

* English/British spelling on var/proc names
	* Color/Colour - both are fine, but keep in mind that BYOND uses `color` as a base variable
* Spaces after control statements
	* `if()` and `if ()` - nobody cares!

### Operators
#### Spacing
(this is not strictly enforced, but more a guideline for readability's sake)

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
	* Should be written as ```bitfield & bitflag``` NEVER ```bitflag & bitfield```, both are valid, but the latter is confusing and nonstandard.
* Associated lists declarations must have their key value quoted if it's a string
	* WRONG: list(a = "b")
	* RIGHT: list("a" = "b")

### Dream Maker Quirks/Tricks
Like all languages, Dream Maker has its quirks, some of them are beneficial to us, like these

#### In-To for-loops
```for(var/i = 1, i <= some_value, i++)``` is a fairly standard way to write an incremental for loop in most languages (especially those in the C family), but DM's ```for(var/i in 1 to some_value)``` syntax is oddly faster than its implementation of the former syntax; where possible, it's advised to use DM's syntax. (Note, the ```to``` keyword is inclusive, so it automatically defaults to replacing ```<=```; if you want ```<``` then you should write it as ```1 to some_value-1```).

HOWEVER, if either ```some_value``` or ```i``` changes within the body of the for (underneath the ```for(...)``` header) or if you are looping over a list AND changing the length of the list then you can NOT use this type of for-loop!


#### Istypeless for loops
A name for a differing syntax for writing for-each style loops in DM. It's NOT DM's standard syntax, hence why this is considered a quirk. Take a look at this:
```DM
var/list/bag_of_items = list(sword, apple, coinpouch, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_items)
	if(!best_sword || S.damage > best_sword.damage)
    		best_sword = S
```
The above is a simple proc for checking all swords in a container and returning the one with the highest damage, and it uses DM's standard syntax for a for-loop by specifying a type in the variable of the for's header that DM interprets as a type to filter by. It performs this filter using ```istype()``` (or some internal-magic similar to ```istype()``` - this is BYOND, after all). This is fine in its current state for ```bag_of_items```, but if ```bag_of_items``` contained ONLY swords, or only SUBTYPES of swords, then the above is inefficient. For example:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_swords)
	if(!best_sword || S.damage > best_sword.damage)
    		best_sword = S
```
specifies a type for DM to filter by. 

With the previous example that's perfectly fine, we only want swords, but here the bag only contains swords? Is DM still going to try to filter because we gave it a type to filter by? YES, and here comes the inefficiency. Wherever a list (or other container, such as an atom (in which case you're technically accessing their special contents list, but that's irrelevant)) contains datums of the same datatype or subtypes of the datatype you require for your loop's body,
you can circumvent DM's filtering and automatic ```istype()``` checks by writing the loop as such:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/s in bag_of_swords)
	var/obj/item/sword/S = s
	if(!best_sword || S.damage > best_sword.damage)
    		best_sword = S
```
Of course, if the list contains data of a mixed type then the above optimisation is DANGEROUS, as it will blindly typecast all data in the list as the specified type, even if it isn't really that type, causing runtime errors.

#### Dot variable
Like other languages in the C family, DM has a ```.``` or "Dot" operator, used for accessing variables/members/functions of an object instance.
eg:
```DM
var/mob/living/carbon/human/H = YOU_THE_READER
H.gib()
```
However, DM also has a dot variable, accessed just as ```.``` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the ```return``` statement) at the end of a proc, provided the proc does not already manually return (```return count``` for example.) Why is this special? 

Well, the ```return``` statement should ideally be free from overhead (functionally free, although of course nothing's free), but DM fails to fulfill this. DM's return statement is actually fairly costly for what it does and for what it's used for.

With ```.``` being everpresent in every proc, can we use it as a temporary variable? Of course we can! However, the ```.``` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the ```.``` operator is compatible with a few operators that look weird but work perfectly fine, such as: ```.++``` for incrementing ```.'s``` value, or ```.[1]``` for accessing the first element of ```.```, provided that it's a list.

## Globals versus static

DM has a var keyword, called global. This var keyword is for vars inside of types. For instance:

```DM
mob
    var
        global
            thing = TRUE
```
This does NOT mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing? 

There is also an undocumented keyword called `static` that has the same behaviour as global but more correctly describes BYOND's behaviour. Therefore, we always use static instead of global where we need it, as it reduces suprise when reading BYOND code.

## Pull Request Process

There is no strict process when it comes to merging pull requests. Pull requests will sometimes take a while before they are looked at by a maintainer; the bigger the change, the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be courteous and respectful. Here are some helpful ways to make it easier for you and for the maintainers when making a pull request.

* Make sure your pull request complies to the requirements outlined in [this guide](http://tgstation13.org/wiki/Getting_Your_Pull_Accepted)

* You are going to be expected to document all your changes in the pull request. Failing to do so will mean delaying it as we will have to question why you made the change. On the other hand, you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data.

* We ask that you use the changelog system to document your change, which prevents our players from being caught unaware by changes - you can find more information about this [on this wiki page](http://tgstation13.org/wiki/Guide_to_Changelogs).

* If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable.

* If your pull request is accepted, the code you add no longer belongs exclusively to you but to everyone; everyone is free to work on it, but you are also free to support or object to any changes being made, which will likely hold more weight, as you're the one who added the feature. It is a shame this has to be explicitly said, but there have been cases where this would've saved some trouble.

* Please explain why you are submitting the pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting the PR.

## Banned content
Do not add any of the following in a Pull Request or risk getting the PR closed:
* National Socialist Party of Germany content, National Socialist Party of Germany related content, or National Socialist Party of Germany references
* Code where one line of code is split across mutiple lines (except for multiple, separate strings and comments; in those cases, existing longer lines must not be split up)

Just becuase something isn't on this list doesn't mean that it's acceptable. Use common sense above all else.

## A word on Git
Yes, we know that the files have a tonne of mixed Windows and Linux line endings. Attempts to fix this have been met with less than stellar success, and as such we have decided to give up caring until there comes a time when it matters.

Therefore, EOF settings of main repo are forbidden territory one must avoid wandering into, at risk of losing body and/or mind to the Git gods.
