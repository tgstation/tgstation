#define FEAR_DURATION 100

/mob/living/simple_animal/pet/hedgehog
	name = "hedgehog"
	desc = "A spiky hog. Looking at it fills you with a strange feeling of reverence."
	gender = MALE
	icon = 'hippiestation/icons/mob/animal.dmi'
	icon_state = "Hedgehog"
	icon_living = "Hedgehog"
	icon_dead = "Hedgehog_dead"
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)
	minbodytemp = 200
	maxbodytemp = 400
	response_help  = "cautiously pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	turns_per_move = 5
	gold_core_spawnable = FRIENDLY_SPAWN
	var/scared = FALSE
	var/scared_time = 0

/mob/living/simple_animal/pet/hedgehog/Bernie
	name = "Bernie"
	desc = "A spiky hog belonging to the captain. Looking at it fills you with a strange feeling of reverence."
	
/mob/living/simple_animal/pet/hedgehog/Life()
	..()
	if(scared && stat != DEAD)
		if(icon_state != "Hedgehog_ball")
			visible_message("<span class = 'notice'> [src] curls up into a ball. </span>")
			icon_state = "Hedgehog_ball"
			icon_living = "Hedgehog_ball"
			canmove = 0
		if(world.time > scared_time)
			scared = FALSE
			icon_state = "Hedgehog"
			icon_living = "Hedgehog"
			canmove = 1

/mob/living/simple_animal/pet/hedgehog/attacked_by(obj/item/I, mob/living/user)
	..()
	scared = TRUE
	scared_time = world.time + FEAR_DURATION
	

/mob/living/simple_animal/pet/hedgehog/attack_hand(mob/living/user)
	if(..())
		if(scared)
			user.visible_message("<span class = 'warning'> [user] pricks their finger on [src]'s quills!</span>")
			user.adjustBruteLoss(8)
		scared = TRUE
		scared_time = world.time + FEAR_DURATION

#undef FEAR_DURATION
