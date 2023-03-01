/mob/living/simple_animal/hostile/syndimouse
	name = "Syndicate Mousepretive"
	desc = "A mouse in a Syndicate combat MODsuit, built for mice!"
	icon = 'icons/mob/simple/syndimouse.dmi'
	icon_state = "mouse_operative"
	icon_living = "mouse_operative"
	icon_dead = "mouse_operative_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	emote_taunt = list("aggressively squeaks")
	taunt_chance = 30
	speed = 0
	maxHealth = 30
	health = 30
	harm_intent_damage = 5
	obj_damage = 25
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "bosses"
	attack_verb_simple = "boss"
	attack_sound = 'sound/weapons/cqchit2.ogg'
	speak_emote = list("squeaks")
	emote_see = list("squeaks.", "practices CQC.", "cocks the bolt of a tiny CR20.", "plots to steal DAT DISK!", "fiddles with a tiny radio.")
	speak_chance = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list(ROLE_SYNDICATE)
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/syndimouse/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)