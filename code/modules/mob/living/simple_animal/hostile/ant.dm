/mob/living/simple_animal/hostile/ant
	name = "giant ant"
	desc = "A writhing mass of ants, glued together to make an adorable pet!"
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "ant"
	icon_living = "ant"
	icon_dead = "ant_dead"
	speak = list("BZZZZT!", "CHTCHTCHT!", "Bzzz", "ChtChtCht")
	speak_emote = list("buzzes", "chitters")
	emote_hear = list("buzzes.", "clacks.")
	emote_see = list("shakes their head.", "twitches their antennae.")
	speak_chance = 1
	turns_per_move = 5
	gender = PLURAL // We are Ven-ant
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	minbodytemp = 200
	maxbodytemp = 400
	harm_intent_damage = 4
	obj_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10 // Higher health than a base carp, so much lower damage.
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	butcher_results = list(/obj/effect/decal/cleanable/ants = 3) //It's just a bunch of ants glued together into a larger ant
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list(FACTION_NEUTRAL)
	can_be_held = FALSE
	footstep_type = FOOTSTEP_MOB_CLAW
	health = 100
	maxHealth = 100
	light_range = 1.5 // Bioluminescence!
	light_color = "#d43229" // The ants that comprise the giant ant still glow red despite the sludge.

/mob/living/simple_animal/hostile/ant/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/pet_bonus, "clacks happily!")
