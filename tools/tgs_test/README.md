# TGS Test Script

This is a simple app that does a few things

- Downloads .tgs.yml information from a specific commit of a given repository.
- Checks that the BYOND version in the .tgs.yml file matches the dependencies.sh version.
- Connects to a TGS instance via command line parameters.
- Uses the .tgs.yml information to automatically set up a TGS instance.
- Runs a TGS deploy/launch and validates that they succeeded.
 
 Look for its invocation in the GitHub workflows
