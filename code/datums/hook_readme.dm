//////////////////////////////////////////////////////////////////////////////////////////////////
// COMPREHENSIVE LIST OF HOOKNAMES CURRENTLY USED, THE FILEPATH ITS USED IN, AND PARAMS, IF ANY //
//////////////////////////////////////////////////////////////////////////////////////////////////

// you can search through this file using Ctrl+F -> this file only ->
// '$ "parametername" $'
// '# "hookname" #',
// "trigger"
// Depending on whether you want to limit the search to parameters, or hooks, with the query.
// Because of the nature of Hook() and triggers, logging existing hooks and parameters makes it a lot easier to find stuff, and know what stuff does.
// When adding new parameters, feel free to make them as long or obfuscated as you like, as they are only used for a millisecond before being thrown away anyways.


// To call it: THING.Hook("hookname", list("argument" = value, "argument" = value)). Parameters are optional.
// To use it, use a switch(trigger) statement, perform safetychecks on the parameters if requried. Then call a proc native to the type using the specific parameters.

/*
	as an example:

Hook(trigger, list/params)
	switch(trigger)
		if(X)
			if("required_parameter" in params)
				src.dosomething(arglst(params["required_parameter"]))
		if(Y)
			if("required_parameter" in params)
				..()
				src.dosomething(arglst(params["required_parameter"]))
				return
		if(Z)
			if("required_parameter" in params)
				src.dosomething(arglst(params["required_parameter"]))
	..()
*/

#################
# "examplehook" #
#################

# Used in datums/hook_readme.dm to show an example of how you should update hooks, when added \
# to the readme file. Add some information as to what it's intended to be used for, and what it IS \
# being used for. Otherwise there's an off chance that your shitty communication will result in someone \
# using the trigger name and causing a conflict. Similarly to that, it's probably a very good idea to \
# check through this readme for any triggers that might already be used for similar stuff, or to avoid conflicts \
# when using a new one. Note: You DONT Have to add a new triggername for every unique hook. Only for hooks \
# that would potentially conflict with eachother otherwise. \

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

$$$$$$$$$$$$$$$$$$
$ "exampleparam" $
$$$$$$$$$$$$$$$$$$

$ "Parameters are typically going to be much more strict in regards to conflict errors. If you're calling a hook using
$ "a parameter that was designed for a different triggerword, you could get mistyped or erronous data, resulting in a fuckup.
$ "so be safe. If you add a new parameter. Log it. Log where its used, with what trigger, and why. If you're adding a new
$ "parameter, check to see if it already exists, and that it wont conflict with anything when used.
$ "misuse of these dumb hook stuffs will make me, and probably everyone else coding, rather annoyed. So don't do it.
$ "If you don't understand how the hooks work, or you're unsure about whether or not it'll cause an issue, don't use it, or ask for help.
$ "Most of this is intended to be used by me anyways in order to code species independent organs, genomes, materials, reagents,
$ "medical effects, network commands, etc. etc.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Add Stuff Below Here ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
