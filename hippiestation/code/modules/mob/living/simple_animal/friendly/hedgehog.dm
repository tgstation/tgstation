/mob/living/simple_animal/pet/hedgehog
	name = "hedgehog"
	desc = "A spiky hog. Looking at it fills you with a strange feeling of reverence."
	gender = MALE
	icon = 'hippiestation/icons/mob/animal.dmi'
	icon_state = "Spike"
	icon_living = "Spike"
	icon_dead = "Spike_dead"
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

/mob/living/simple_animal/pet/hedgehog/Spike
	name = "Bernie"
	desc = "A spiky hog belonging to the captain. Looking at it fills you with a strange feeling of reverence."

/mob/living/simple_animal/pet/hedgehog/attacked_by(obj/item/I, mob/living/user)
	..()
	if(icon_state != "Spike_ball")
		visible_message("<span class = 'notice'> [src] curls up into a ball. </span>")
	icon_state = "Spike_ball"
	icon_living = "Spike_ball"
	update_canmove()
	sleep(5 SECONDS)
	icon_state = "Spike"
	icon_living = "Spike"
	update_canmove()

/mob/living/simple_animal/pet/hedgehog/attack_hand(mob/living/user)
	..()
	if(icon_state != "Spike_ball")
		visible_message("<span class = 'notice'> [src] curls up into a ball. </span>")
	icon_state = "Spike_ball"
	icon_living = "Spike_ball"
	user.adjustBruteLoss(5)
	user.visible_message("<span class = 'warning'> [user] pricks their finger on [src]'s quills!</span>")
	update_canmove()
	sleep(5 SECONDS)
	icon_state = "Spike"
	icon_living = "Spike"
	update_canmove()



/mob/living/simple_animal/pet/hedgehog/update_canmove()
	if(icon_state == "Spike_ball")
		canmove = 0
	else
		canmove = 1



