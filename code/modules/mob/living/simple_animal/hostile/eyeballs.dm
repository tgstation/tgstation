/mob/living/simple_animal/hostile/eyeball
	name = "eyeball"
	desc = "An odd looking creature, it won't stop staring..."
	icon = 'icons/mob/simple/carp.dmi'
	icon_state = "eyeball"
	icon_living = "eyeball"
	icon_gib = ""
	maxHealth = 30
	health = 30
	harm_intent_damage = 15
	obj_damage = 10
	melee_damage_lower = 8
	melee_damage_upper = 12
	speed = 0
	gender = NEUTER
	mob_biotypes = MOB_ORGANIC
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	emote_taunt = list("glares")
	taunt_chance = 25
	speak_emote = list("telepathically cries")
	turns_per_move = 5
	attack_verb_continuous = "blinks at"
	attack_verb_simple = "blink at"
	attack_sound = 'sound/weapons/pierce.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("spooky")
	del_on_death = 1
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

/mob/living/simple_animal/hostile/eyeball/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
