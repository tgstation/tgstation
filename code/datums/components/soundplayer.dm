/datum/component/sound_player
	var/volume =
	var/list/sounds = list('sound/items/bikehorn.ogg')

/datum/component/sound_player/Initialize(custom_volume, custom_sounds, flags)
	volume = custome_volume || volume
	sounds = custom_sounds || sounds
	check_flags(flags)

/datum/component/sound_player/check_flags(flags)
	//TODO REGISTER SHIT
