ProcessScheduler
================
A Goonstation release, maintained by Volundr

##SUMMARY

This is a mostly self-contained, fairly well-documented implementation of the main loop process architecture in use in Goonstation.

##LICENSE

This work is released under the following licenses.

[![Creative Commons License](https://licensebuttons.net/l/by-nc/4.0/80x15.png)](http://creativecommons.org/licenses/by-nc/4.0/)

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License. The complete text of this license is included in the file LICENSE-CC-BY-NC.


[![Affero GPL Version 3](http://www.gnu.org/graphics/agplv3-88x31.png)](http://www.gnu.org/licenses/agpl-3.0.html)

This work is licensed under the Affero General Public License 3.0. The complete text of the license is included in the file LICENSE-AGPL.

##INSTALLATION

To integrate the process scheduler to your codebase, you will not need anything except the contents of the core/ folder. The rest of the project is simply for testing and to provide an example for the process scheduler code.

### Test project setup
To compile and run the test project, you will require:

- node.js
- BYOND

Clone the repository to a path of your choosing, then change directory to it and execute:

```
npm install -g
bower install -g
``` 

Then you can either compile with DM or open the DM environment in DreamMaker and compile/run from there.

##USAGE

###BASICS
To use the process scheduler in your SS13 codebase, you'll need:

- core/_defines.dm
- core/_stubs.dm
- core/process.dm
- core/processScheduler.dm
- core/processScheduler.js
- core/updateQueue.dm
- core/updateQueueWorker.dm

To integrate, you can copy the contents of _defines.dm into your global defines file. Most ss13 codebases already have the code from _stubs.dm. 

The processScheduler is intended as a replacement for the old master_controller from r4407 and other fork codebases. To implement it, you need only to add the source files to your DM environment, and add the following code into world.New, above where the old master_controller is initialized.

```
processScheduler = new
processScheduler.setup()
processScheduler.start()
```

The processScheduler will automatically find all subtypes of process, and begin processing them.

The interface code in test/processSchedulerView.dm is simply an example frontend, and can easily be rebuilt to use other styles, and/or render simple html without using javascript for refreshing the panel and killing processes.

###DETAILS

To implement a process, you have two options:

1. Implement a raw loop-style processor
2. Implement an updateQueue processor

There are clear examples of both of these paradigms in the code provided. Both styles are valid, but for processes that are just a loop calling an update proc on a bunch of objects, you should use the updateQueue.

The updateQueue works by spawn(0)'ing your specified update proc, but it only puts one instance in the scheduler at a time. Examine the code for more details. The overall effect of this is that it doesn't block, and it lets update loops work concurrently. It enables a much smoother user experience.

##Contributing

I welcome pull requests and issue reports, and will try to merge/fix them as I have time.

### Licensing for code submitted via PR:

By submitting a pull request, you agree to release all original code submitted in the pull request under the [MIT License](http://opensource.org/licenses/MIT). You also agree that any code submitted is either your own work, or is public domain or under a equally or less restrictive license than the MIT license, or that you have the express written permission of the authors of the submitted code to submit the pull request.

