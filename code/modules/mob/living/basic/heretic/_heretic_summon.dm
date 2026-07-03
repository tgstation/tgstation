/mob/living/basic/heretic_summon
	name = "Eldritch Demon"
	real_name = "Eldritch Demon"
	desc = "Древний ужас из-за пределов этого мира, вызванный плохим кодом."
	icon = 'icons/mob/nonhuman-player/eldritch_mobs.dmi'
	faction = list(FACTION_HERETIC)
	basic_mob_flags = DEL_ON_DEATH
	gender = NEUTER
	mob_biotypes = NONE

	habitable_atmos = null
	status_flags = CANPUSH
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	speed = 0
	melee_attack_cooldown = CLICK_CD_MELEE

	attack_sound = 'sound/items/weapons/punch1.ogg'
	response_help_continuous = "стоит ещё подумать, прежде чем трогать"
	response_help_simple = "лучше подумайте, прежде чем трогать"
	response_disarm_continuous = "цепляется за"
	response_disarm_simple = "цепляется за"
	response_harm_continuous = "разрывает"
	response_harm_simple = "рвёт"
	death_message = "схлопывается в себя."

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	combat_mode = TRUE
	ai_controller = null
	speak_emote = list("screams")
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/heretic_summon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, /obj/effect/gibspawner/generic)
	ADD_TRAIT(src, TRAIT_HERETIC_SUMMON, INNATE_TRAIT)
