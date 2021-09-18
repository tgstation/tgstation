# dmdoc
[DOCUMENTATION]: http://codedocs.tgstation13.org

[BYOND]: https://secure.byond.com/

[DMDOC]: https://github.com/SpaceManiac/SpacemanDMM/tree/master/src/dmdoc

[DMDOC] is a documentation generator for DreamMaker, the scripting language
of the [BYOND] game engine. It produces simple static HTML files based on
documented files, macros, types, procs, and vars.

We use **dmdoc** to generate [DOCUMENTATION] for our code, and that documentation
is automatically generated and built on every new commit to the master branch

This gives new developers a clickable reference [DOCUMENTATION] they can browse to better help
gain understanding of the /tg/station codebase structure and api reference.

## Documenting code on /tg/station
We use block comments to document procs and classes, and we use `///` line comments
when documenting individual variables.

It is required that all new code be covered with DMdoc code, according to the [Requirements](#Required)

We also require that when you touch older code, you must document the functions that you
have touched in the process of updating that code

### Required
A class *must* always be autodocumented, and all public functions *must* be documented

All class level defined variables *must* be documented

Internal functions *should* be documented, but may not be

A public function is any function that a developer might reasonably call while using
or interacting with your object. Internal functions are helper functions that your
public functions rely on to implement logic


### Documenting a proc
When documenting a proc, we give a short one line description (as this is shown
next to the proc definition in the list of all procs for a type or global
namespace), then a longer paragraph which will be shown when the user clicks on
the proc to jump to it's definition
```
/**
 * Short description of the proc
 *
 * Longer detailed paragraph about the proc
 * including any relevant detail
 * Arguments:
 * * arg1 - Relevance of this argument
 * * arg2 - Relevance of this argument
 */
```

### Documenting a class
We first give the name of the class as a header, this can be omitted if the name is
just going to be the typepath of the class, as dmdoc uses that by default

Then we give a short oneline description of the class

Finally we give a longer multi paragraph description of the class and it's details
```
/**
 * # Classname (Can be omitted if it's just going to be the typepath)
 *
 * The short overview
 *
 * A longer
 * paragraph of functionality about the class
 * including any assumptions/special cases
 *
 */
```

### Documenting a variable/define
Give a short explanation of what the variable, in the context of the class, or define is. 
```
/// Type path of item to go in suit slot
var/suit = null
```

## Module level description of code
Modules are the best way to describe the structure/intent of a package of code
where you don't want to be tied to the formal layout of the class structure.

On /tg/station we do this by adding markdown files inside the `code` directory
that will also be rendered and added to the modules tree. The structure for
these is deliberately not defined, so you can be as freeform and as wheeling as
you would like.

[Here is a representative example of what you might write](http://codedocs.tgstation13.org/code/modules/keybindings/readme.html)

## Special variables
You can use certain special template variables in DM DOC comments and they will be expanded
```
    [DEFINE_NAME] - Expands to a link to the define definition if documented
    [/mob] - Expands to a link to the docs for the /mob class
    [/mob/proc/Dizzy] - Expands to a link that will take you to the /mob class and anchor you to the dizzy proc docs
    [/mob/var/stat] - Expands to a link that will take you to the /mob class and anchor you to the stat var docs
```

You can customise the link name by using `[link name][link shorthand].`

eg. `[see more about dizzy here] [/mob/proc/Dizzy]`

This is very useful to quickly link to other parts of the autodoc code to expand
upon a comment made, or reasoning about code
