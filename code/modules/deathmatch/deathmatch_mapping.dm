/area/deathmatch
	name = "Deathmatch Arena"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED

/area/deathmatch/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/obj/effect/landmark/deathmatch_player_spawn
	name = "Deathmatch Player Spawner"

/datum/action/cooldown/spell/chuuni_invocations/deathmatch
	name = "Unrestricted Chuuni Invocations"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_MIND

/datum/action/cooldown/spell/rod_form/deathmatch
	name = "Unrestricted Rod Form"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/conjure/the_traps/deathmatch
	name = "Unrestricted The Traps"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
