/datum/action/cooldown/spell/pointed/flash
	name = "Flash"
	desc = "Blinks you a short distance toward the target location."
	button_icon_state = "flash"
	sound = 'sound/effects/magic/flash.ogg'

	school = SCHOOL_TRANSLOCATION
	cooldown_time = 300 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_MIND

	spell_max_level = 1

	cast_range = 5

	var/teleport_channel = TELEPORT_CHANNEL_MAGIC
	var/force_teleport = TRUE
	var/post_teleport_sound = NONE

/datum/action/cooldown/spell/pointed/flash/cast(atom/cast_on)
	. = ..()
	var/list/turf/destination = cast_on
	if(!destination)
		CRASH("[type] failed to find a flash destination.")

	do_teleport(owner, destination, asoundout = post_teleport_sound, channel = teleport_channel, forced = force_teleport)
