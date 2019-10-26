# AuStation Custom Directory
This directory exists to house custom code changes that can be properly seperated from the codebase and placed here. All files that can be placed here should. The includes.dm file should be used to tick new code files to avoid messing up the dme. Any code changes outside this folder should be made with this comment for one line changes `// austation -- <reason>` and `//austation begin -- <reason>` & `//austation end` for multiline changes. Both of these are *shamelessly* stolen from HippieStation.

# Code Changes
When making changes, add a brief descriptor of the changes to the changes.txt file in this directory with the format `<name>:<brief description>`
This format makes the file easy to parse with a regex, and helps with moving changes between repos by showing what needs to be moved or added.
