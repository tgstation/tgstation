
# Template file for your new component

See _component.dm for detailed explanations

```dm
/datum/component/mycomponent
	//can_transfer = TRUE                   // Must have post_transfer
	//dupe_mode = COMPONENT_DUPE_ALLOWED    // code/__DEFINES/dcs/flags.dm
	var/myvar

/datum/component/mycomponent/Initialize(myargone, myargtwo)
	if(myargone)
		myvar = myargone
	if(myargtwo)
		send_to_playing_players(myargtwo)

/datum/component/mycomponent/register_with_parent()
	register_signal(parent, COMSIG_NOT_REAL, ./proc/signalproc)                                    // register_signal can take a signal name by itself,
	register_signal(parent, list(COMSIG_NOT_REAL_EITHER, COMSIG_ALMOST_REAL), ./proc/otherproc)    // or a list of them to assign to the same proc

/datum/component/mycomponent/unregister_from_parent()
	unregister_signal(parent, COMSIG_NOT_REAL)          // unregister_signal has similar behavior
	unregister_signal(parent, list(                     // But you can just include all registered signals in one call
		COMSIG_NOT_REAL,
		COMSIG_NOT_REAL_EITHER,
		COMSIG_ALMOST_REAL,
	))

/datum/component/mycomponent/proc/signalproc(datum/source)
	SIGNAL_HANDLER
	send_to_playing_players("[source] signaled [src]!")

/*
/datum/component/mycomponent/inherit_component(datum/component/mycomponent/old, i_am_original, list/arguments)
	myvar = old.myvar

	if(i_am_original)
		send_to_playing_players("No parent should have to bury their child")
*/

/*
/datum/component/mycomponent/pre_transfer()
	send_to_playing_players("Goodbye [parent], I'm getting adopted")

/datum/component/mycomponent/post_transfer()
	send_to_playing_players("Hello my new parent, [parent]! It's nice to meet you!")
*/

/*
/datum/component/mycomponent/check_dupe_component(datum/mycomponent/new, myargone, myargtwo)
	if(myargone == myvar)
		return TRUE
*/
```
