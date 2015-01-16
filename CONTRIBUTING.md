#CONTRIBUTING

##Reporting Issues

See [this page](http://tgstation13.org/wiki/Reporting_Issues) for a guide and format to issue reports.

##Introduction

Hello and welcome to /tg/station's contributing page. You are here because you are curious or interested in contributing. Thanks for being interested. Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below, because at /tg/station, we have a goal to increase code maintainability and to do that we are going to need all pull requests to hold up to those specifications. This is in order for all of us to benefit, instead of having to fix the same bug more than once because of duplicated code.

But first we want to make it clear how you can contribute, if contributing is a new experience for you, and what powers the team has over your pull request so you do not get any surprises when submitting pull requests, and it is closed for a reason you did not anticipate.

##Getting Started

At /tg/station we do not have a list of goals and features to add, we instead allow freedom for contributors to suggest and create their ideas for the game. That does not mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game. Here are some useful getting started guides, if you want to contribute or if you want to know what challenges you can tackle with zero knowledge about the game's code structure.

If you want to contribute the first thing you'll need to do is [set up Git](http://tgstation13.org/wiki/Setting_up_git) so you can download the source code.

We have a [list of guides on the wiki](http://www.tgstation13.org/wiki/index.php/Guides#Development_and_Contribution_Guides) which will help you get started contributing to /tg/station with git and Dream Maker. For beginners, it is recommended you work on small projects, at first. If you need help learning to program in BYOND check out this [repository of resources](http://www.byond.com/developer/articles/resources).

There is an open list of approachable issues for [your inspiration here](https://github.com/tgstation/-tg-station/issues?q=is%3Aopen+is%3Aissue+label%3A%22Easy+Fix%22).

You can of course, as always, ask for help at [#coderbus](irc://irc.rizon.net/coderbus) on irc.rizon.net. We are just here to have fun and help so do not expect professional support please.

##Meet the Team

**Project Leads**

Project Leads, which are elected by the maintainers and members of the project, have complete control over what goes through and what is reverted. They are encouraged to take control in what features are added to the game. Project Leads can also act as Project Managers when needed.

**Project Managers**

Project Managers are responsible for recruiting and firing maintainers, enforcing coding standards, and reverting changes that should have not been committed. Project Managers are assigned by Project Leads. On things that Project Managers disagree on they are to refer to the Project Leads for advice. It is encouraged that if you do not want to waste time working on a feature, that might be denied, that you ask a Project Manager first.

**Maintainers**

Maintainers are quality control. If a proposed pull request does not meet the mentioned quality specifications then it can be closed if you fail to satisfy them. Maintainers are required to give a reason for closing the pull request.

Maintainers can revert your changes if they feel they are not worth maintaining or if they did not live up to the quality specifications.

##Specification

As mentioned before, you are expected to follow these specifications in order to make everyone's lives easier, it will also save you and us time, with having to make the changes and us having to tell you what to change. Thank you for reading this section.

* As BYOND's Dream Maker is an object oriented language, code must be object oriented when possible in order to be more flexible when adding content to it. If you are unfamiliar with this concept, it is highly recommended you look it up.

* You must write BYOND code with absolute pathing, like so:

```C++

/obj/item/weapon/baseball_bat
    name = "baseball bat"
    desc = "A baseball bat."
    var/wooden = 1

/obj/item/weapon/baseball_bat/examine()
    if(wooden)
        desc = "A wooden baseball bat."
    else
        desc = "A metal baseball bat."
    ..()

```

* You must not use colons to override safety checks on an object's variable/function, instead of using proper type casting.

* It is rarely allowed to put type paths in a text format, as they is no compile errors if the type path no longer exists. Here is an example:

```C++
//Good
var/path_type = /obj/item/weapon/baseball_bat

//Bad
var/path_type = "/obj/item/weapon/baseball_bat"
```

* You must use tabs to indent your code, NOT SPACES.

* Hacky code, such as adding specific checks, is highly discouraged and only allowed when there is no other option. You can avoid hacky code by using object oriented methodologies, such as overriding a function (called procs in DM) or sectioning code into functions and then overriding them as required.

* Duplicated code is 99% of the time never allowed. Copying code from one place to another maybe suitable for small short time projects but /tg/station focuses on the long term and thus discourages this. Instead you can use object orientation, or simply placing repeated code in a function, to obey this specification easily.

* Code should be modular where possible, if you are working on a new class then it is best if you put it in a new file.

* Bloated code may be necessary to add a certain feature, which means there has to be a judgement over whether the feature is worth having or not. You can help make this decision easier by making sure your code is modular.

* You are expected to help maintain the code that you add, meaning if there is a problem then you are likely to be approached in order to fix any issues, runtimes or bugs.

##Pull Request Process

There is no strict process when it comes to merging pull requests, pull requests will sometimes take a while before they are looked at by a maintainer, the bigger the change the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be nice. Here are some helpful ways to make it easier for you and for the maintainer when making a pull request.

* Make sure your pull request complies to the requirements outlined in [this guide](http://tgstation13.org/wiki/Getting_Your_Pull_Accepted)

* You are going to be expected to document all your changes in the pull request, failing to do so will mean delaying it as we will have to question why you made the change. On the other hand you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data.

* We ask that you use the changelog system to document your change, this prevents our players from being caught unaware by changes - you can find more information about this here http://tgstation13.org/wiki/Guide_to_Changelogs

* If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable.

* If your pull request is accepted, the code you add is no longer exclusively yours but everyones, everyone is free to work on it but you are also free to object to any changes being made, which will be noted by a Project Lead or Project Manager. It is a shame this has to be explicitly told but there have been cases where this would've saved some trouble.

##Developing Secure Code

* Player input must always be escaped safely, we recommend you use stripped_input in all cases where you would use input. Essentially, just always treat input from players as inherently malicious and design with that use case in mind

* Calls to the database must be escaped properly - use sanitizeSQL to escape database entries from players or admins

* All calls to topics must be checked for correctness, topic href calls can be generated maliciously, so you should ensure that the call is valid for the state the item is in. Do not rely on the UI code to provide only valid topic calls

* Information that players could use to metagame (that is to identify the round type and or the antags via information that would not be available to them in character) should be kept as administrator only

* It is recommended as well you do not expose information about the players - even something as simple as the number of people who have readied up at the start of the round can and has been used to try to identify the round type

* Where you have code that can cause large scale modification and *FUN* make sure you start it out locked behind one of the default admin roles - use common sense to determine which role fits the level of damage a function could do

