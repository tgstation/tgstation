// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/key_down(key, client/user) // Called when a key is pressed down initially
	return
/datum/proc/key_up(key, client/user) // Called when a key is released
	return
/datum/proc/key_loop(client/user) // Called once every frame
	return


// Clients aren't datums so we'll cheat and give them the same procs independently in bindings_client.dm

/client
	var/list/keys_held = list() // A list of any keys held currently.

	var/list/keys_active = list() // A list of any keys held for any length of time this tick
	// Check against this list for added responsiveness. It's very possible to press and release a key within a tick before input is read

/client/New()
	. = ..()
	spawn(-1)
		input_loop()

	for(var/key in all_keys)
		var/escaped = list2params(list("[key]"))
		winset(src, "macro[key]Down", "parent=macro;name=[escaped];command=key-down+[escaped]")
		winset(src, "macro[key]Up", "parent=macro;name=[escaped]+UP;command=key-up+[escaped]")

/client/proc/input_loop()
	while(1)
		key_loop()
		sleep(world.tick_lag)