#CONTRIBUTING
Everyone is free to contribute to this project as long as they follow these simple guidelines and specifications.

**Introduction**

As a goal to increase code maintainability we are going to be requiring all pull requests to hold up to the standards mentioned below. This is in order for all of us to benefit, instead of having to fix the same bug more than once because of duplicated code.

But first we want to make it clear over what powers the maintainers have over your pull request, so you do not get any surprises when submitting pull requests and it is closed for a reason you did not suspect.

**Project Leads**

Project Leads, which are elected by the maintainers and members of the project, have complete control over what goes through and what is reverted. They are encouraged to take control in what features are added to the game. Project Leads can also act as Project Managers when needed.

**Project Managers**

Project Managers are responsible for recruiting and firing maintainers, enforcing coding standards, and reverting changes that should have not been committed. Project Managers are assigned by Project Leads. On things that Project Managers disagree on they are to refer to the Project Leads for advice. It is encouraged that if you do not want to waste time working on a feature, that might be denied, that you ask a Project Manager first.

**Maintainers**

Maintainers are quality control. If a proposed pull request does not meet the mentioned quality specifications then it can be closed if you fail to satisfy them. Maintainers are required to give a reason for closing the pull request.

Maintainers can revert your changes if they feel they are not worth maintaining or if they did not live up to the quality specifications.

**Specification**

As BYOND's Dream Maker is an object oriented language, code must be object oriented when possible in order to be more flexible when adding content to it.

You must write BYOND code with absolute pathing, like so:

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

You must not use colons to override safety checks on an object's variable/function, instead of using proper type casting.

It is rarely allowed to put type paths in a text format, as they is no compile errors if the type path no longer exists.

You must use tabs to indent your code.

Hacky code, such as adding specific checks, is highly discouraged and only allowed when there is no other option. You can avoid hacky code by using object oriented methodologies, such as overriding a function (called procs in DM) or sectioning code into functions and then overriding them as required.

Duplicated code is 99% of the time never allowed. Copying code from one place to another maybe suitable for small short time projects but /tg/station focuses on the long term and thus discourages this. Instead you can use object orientation, or simply placing repeated code in a function, to obey this specification easily.

Code should be modular where possible, if you are working on a new class then it is best if you put it in a new file.

Bloated code may be necessary to add a certain feature, which means there has to be a judgement over whether the feature is worth having or not. You can help make this decision easier by making sure your code is modular.

You are expected to help maintain the code that you add, meaning if there is a problem then you are likely to be approached in order to fix any issues, runtimes or bugs.

**Other Requirements/Information**

Pull requests will sometimes take a while before they are looked at by a maintainer, the bigger the change the more time it will take before they are accepted into the code.

You are expected to document all your changes in the pull request, failing to do so will risk delaying it. On the other hand you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data.

If you are proposing multiple changes, which change many different aspects of the code, you are to section them off into different pull requests in order to easily review them and to deny/accept the changes that are deemed acceptable.

If your pull request is accepted, the code you add is no longer yours but everyones, everyone is free to work on it but you are also free to object to any changes being made, which will be noted by a Project Lead.

**Getting Started**

We have a [list of guides on the wiki](http://www.tgstation13.org/wiki/index.php/Guides#Development_and_Contribution_Guides) which will help you get started contributing to /tg/station with git and Dream Maker.

For beginners, it is recommended you work on small projects, at first. There is an easy list of issues which are [contributor friendly, here](https://github.com/tgstation/-tg-station/issues?labels=Contributor+Friendly&page=1&state=open).
