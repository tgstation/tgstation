/mob/living/basic/heretic_summon
	name = "Eldritch Demon"
	real_name = "Eldritch Demon"
	desc = "A horror from beyond this realm."
	icon = 'icons/mob/nonhuman-player/eldritch_mobs.dmi'
	faction = list(FACTION_HERETIC)
	basic_mob_flags = DEL_ON_DEATH
	gender = NEUTER
	mob_biotypes = NONE

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	speed = 0

	attack_sound = 'sound/weapons/punch1.ogg'
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "reaps"
	response_harm_simple = "tears"
	death_message = "implodes into itself."

	combat_mode = TRUE
	ai_controller = null
	speak_emote = list("screams")
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/heretic_summon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, string_list(list(/obj/effect/gibspawner/generic)))
