/mob/living/simple_animal/hostile/headcrustation
	name = "Headcrab"
	desc = "It looks confused, and somewhat lost."
	icon_state = "crabby"
	icon_living = "crabby"
	icon_dead = "crabby_rip"
	gender = NEUTER
	health = 25
	maxHealth = 25
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("squeaks")
	ventcrawler = VENTCRAWLER_ALWAYS
	ranged = TRUE
	ranged_message = "Leaps"
	projectiletype = /obj/projectile/crab
	var/datum/mind/origin

/mob/living/simple_animal/hostile/headcrustation/Shoot(atom/targeted_atom)
	. = ..()
	qdel(src)

/mob/living/simple_animal/hostile/headcrustation/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(W.tool_behaviour == TOOL_CROWBAR && user.a_intent != INTENT_HELP)
		adjustHealth(10) //You get it

/obj/item/clothing/head/headcrab
	name = "Headcrab"
	desc = "WIP, god is in pain"
	icon_state = "headcrab"
	item_state = "headcrab"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEHAIR
