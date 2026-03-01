# Template file for your new component

See \_component.dm for detailed explanations

```dm
/datum/component/mycomponent
	//can_transfer = TRUE                   // Must have PostTransfer
	//dupe_mode = COMPONENT_DUPE_ALLOWED    // code/__DEFINES/dcs/flags.dm
	var/myvar

/datum/component/mycomponent/Initialize(myargone, myargtwo)
	if(myargone)
		myvar = myargone
	if(myargtwo)
		send_to_playing_players(myargtwo)

/datum/component/mycomponent/RegisterWithParent()
	RegisterSignal(parent, COMSIG_NOT_REAL, PROC_REF(signalproc))                                    // RegisterSignal can take a signal name by itself,
	RegisterSignal(parent, list(COMSIG_NOT_REAL_EITHER, COMSIG_ALMOST_REAL), PROC_REF(otherproc))    // or a list of them to assign to the same proc

/datum/component/mycomponent/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_NOT_REAL)          // UnregisterSignal has similar behavior
	UnregisterSignal(parent, list(                     // But you can just include all registered signals in one call
		COMSIG_NOT_REAL,
		COMSIG_NOT_REAL_EITHER,
		COMSIG_ALMOST_REAL,
	))

/datum/component/mycomponent/proc/signalproc(datum/source)
	SIGNAL_HANDLER
	send_to_playing_players("[source] signaled [src]!")

/*
/datum/component/mycomponent/InheritComponent(datum/component/mycomponent/old, i_am_original, list/arguments)
	myvar = old.myvar

	if(i_am_original)
		send_to_playing_players("No parent should have to bury their child")
*/

/*
/datum/component/mycomponent/PreTransfer(datum/new_parent)
	send_to_playing_players("Goodbye [new_parent], I'm getting adopted")

/datum/component/mycomponent/PostTransfer(datum/new_parent)
	send_to_playing_players("Hello my new parent, [parent]! It's nice to meet you!")
*/

/*
/datum/component/mycomponent/CheckDupeComponent(datum/mycomponent/new, myargone, myargtwo)
	if(myargone == myvar)
		return TRUE
*/
```
