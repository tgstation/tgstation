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
	attacktext = "bites"
	melee_damage_lower = 1
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	ventcrawler = VENTCRAWLER_ALWAYS
	density = 0
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = 2
	obj_damage = 0
	environment_smash = 0
	var/list/edibles = list(/mob/living/simple_animal/butterfly,/mob/living/simple_animal/cockroach) //list of atoms, however turfs won't affect AI, but will affect consumption.

/mob/living/simple_animal/hostile/lizard/CanAttack(atom/the_target)//Can we actually attack a possible target?
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return 0
	if(is_type_in_list(the_target,edibles))
		return 1
	return 0

/mob/living/simple_animal/hostile/lizard/AttackingTarget()
	if(is_type_in_list(target,edibles)) //Makes sure player lizards only consume edibles.
		visible_message("[name] consumes [target] in a single gulp", "<span class='notice'>You consume [target] in a single gulp</span>")
		qdel(target) //Nom
		target = null
		adjustBruteLoss(-2)
		return TRUE
	else
		return ..()
