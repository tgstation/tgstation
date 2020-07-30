/mob/living/simple_animal/hostile/lizard
	name = "Lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	speak_emote = list("hisses")
	health = 5
	maxHealth = 5
	faction = list("Lizard")
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	melee_damage_lower = 1
	melee_damage_upper = 2
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_REPTILE
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	var/static/list/edibles = typecacheof(list(/mob/living/simple_animal/butterfly, /mob/living/simple_animal/hostile/cockroach)) //list of atoms, however turfs won't affect AI, but will affect consumption.

/mob/living/simple_animal/hostile/lizard/CanAttack(atom/the_target)//Can we actually attack a possible target?
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE
	if(is_type_in_typecache(the_target,edibles))
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/lizard/AttackingTarget()
	if(is_type_in_typecache(target,edibles)) //Makes sure player lizards only consume edibles.
		visible_message("<span class='notice'>[name] consumes [target] in a single gulp.</span>", "<span class='notice'>You consume [target] in a single gulp.</span>")
		QDEL_NULL(target) //Nom
		adjustBruteLoss(-2)
		return TRUE
	else
		return ..()

/mob/living/simple_animal/hostile/lizard/space
	name = "Space Lizard"
	desc = "A cute tiny lizard with a tiny space helmet."
	icon_state = "lizard_space"
	icon_living = "lizard_space"
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40

/mob/living/simple_animal/hostile/lizard/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1,M)
		if("harm")
			wuv(-1,M)

/mob/living/simple_animal/hostile/lizard/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD)
				new /obj/effect/temp_visual/heart(loc)
				emote("me", 1, "sticks its tongue out happily!")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("me", 1, "hisses angrily!")
