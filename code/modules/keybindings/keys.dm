/datum/keyinfo
	var/action
	var/key


/datum/keybindings
	var/list/keys
	var/list/old_keys = list()
	var/list/keys_held = list()
	var/list/movement_keys = list()

/datum/keybindings/New()
	from_list(GLOB.keybinding_default)

/datum/keybindings/proc/key_setbinding(_key, _action, _dir = 0)
	unbind_old_keys(_key)
	keys[_action] = _key
	if(_dir)
		key_setmovement(_key, _dir)

/datum/keybindings/proc/key_setmovement(_key, _dir)
	var/old_key = get_movement_key(_dir)
	movement_keys -= old_key
	movement_keys[_key] = _dir

/datum/keybindings/proc/unbind_movement()
	movement_keys = list()

	old_keys = keys.Copy()
	keys = GLOB.keybinding_default

/datum/keybindings/proc/bind_movement()
	movement_keys = list()

	movement_keys[get_action_key(ACTION_MOVENORTH)] = NORTH
	movement_keys[get_action_key(ACTION_MOVEWEST)] = WEST
	movement_keys[get_action_key(ACTION_MOVESOUTH)] = SOUTH
	movement_keys[get_action_key(ACTION_MOVEEAST)] = EAST

	if(old_keys.len)
		keys = old_keys.Copy()
		old_keys = list()

/datum/keybindings/proc/unbind_old_keys(_key)
	movement_keys -= _key
	for(var/A in keys)
		var/K = keys[A]
		if(K == _key)
			keys[A] = "Unbound"

/datum/keybindings/proc/set_key_down(_key)
	keys_held[_key] = world.time

/datum/keybindings/proc/set_key_up(_key)
	keys_held -= _key

/datum/keybindings/proc/get_key_action(_key)
	for(var/A in keys)
		var/K = keys[A]
		if(K == _key)
			return A

/datum/keybindings/proc/get_action_key(_action)
	return keys[_action]

/datum/keybindings/proc/get_movement_dir(_key)
	return movement_keys[_key]

/datum/keybindings/proc/get_movement_key(_dir)
	for(var/K in movement_keys)
		var/D = movement_keys[K]
		if(D == _dir)
			return K

/datum/keybindings/proc/isheld_key(_key)
	return keys_held[_key]

/datum/keybindings/proc/to_keyinfo(_key, _action)
	var/datum/keyinfo/I = new
	I.key = _key
	I.action = _action
	return I

/datum/keybindings/proc/from_list(list/_list)
	keys = _list.Copy()
	bind_movement()

/datum/keybindings/proc/to_list()
	return keys
