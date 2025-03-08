/datum/action/cooldown/spell/pointed/flash
	name = "Flash"
	desc = "Blinks you a short distance toward the target location."
	button_icon_state = "blink"
	sound = 'sound/effects/magic/blink.ogg'

	school = SCHOOL_TRANSLOCATION
	cooldown_time = 5 SECONDS

	invocation_type = INVOCATION_NONE

	spell_max_level = 1

	cast_range = 5

	var/post_teleport_sound = 'sound/items/weapons/zapbang.ogg'
	var/teleport_channel = TELEPORT_CHANNEL_MAGIC
	var/force_teleport = TRUE

/datum/action/cooldown/spell/pointed/flash/cast(atom/cast_on)
	. = ..()
	var/list/turf/destination = cast_on
	if(!destination)
		CRASH("[type] failed to find a flash destination.")

	do_teleport(owner, destination, asoundout = post_teleport_sound, channel = teleport_channel, forced = force_teleport)
