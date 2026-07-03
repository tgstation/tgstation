/proc/get_holders_with_rights(rights)
	var/list/valid_holders = list()
	for(var/client/holder as anything in GLOB.admins)
		if(check_rights_for(holder, rights))
			valid_holders += holder

	return valid_holders

/proc/prepare_admin_sound(new_volume, sound/sound_file)
	var/sound/admin_sound = new (
		file = sound_file,
		channel = CHANNEL_ADMIN,
		wait = TRUE,
		volume = new_volume
	)
	admin_sound.status = SOUND_STREAM
	admin_sound.priority = 250
	return admin_sound

