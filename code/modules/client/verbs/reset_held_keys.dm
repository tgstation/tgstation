/**
  * Manually clears any held keys, in case due to lag or other undefined behavior a key gets stuck.
  *
  * Hardcoded to the ESC key.
  */
/client/verb/reset_held_keys()
	set name = "Reset Held Keys"
	set hidden = TRUE

	for(var/key in keys_held)
		keyUp(key)

	//In case one got stuck and the previous loop didn't clean it, somehow.
	for(var/key in key_combos_held)
		keyUp(key_combos_held[key])
