/datum/action/cooldown/spell/aoe/knock
	name = "Knock"
	desc = "This spell opens nearby doors and closets."
	button_icon_state = "knock"

	sound = 'sound/magic/knock.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 2 SECONDS

	invocation = "AULIE OXIN FIERA"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	aoe_radius = 3

/datum/action/cooldown/spell/aoe/knock/get_things_to_cast_on(atom/center)
	return RANGE_TURFS(aoe_radius, center)

/datum/action/cooldown/spell/aoe/knock/cast_on_thing_in_aoe(turf/victim, atom/caster)
	SEND_SIGNAL(victim, COMSIG_ATOM_MAGICALLY_UNLOCKED, src, caster)
