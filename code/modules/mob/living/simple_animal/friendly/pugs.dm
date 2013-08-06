/mob/living/simple_animal/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	meat_amount = 3
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5


/mob/living/simple_animal/pug/attack_hand(mob/living/carbon/human/M as mob)
	M.visible_message(\
	"The [name] suddenly bursts due to its bad genetics!",\
	"As you feel its soft fur, the [name] suddenly bursts due to its bad genetics!",\
	"You felt that blast from here, only a [name] could cause such an event.")
	src.gib()
	return

/mob/living/simple_animal/pug/attack_animal(mob/living/simple_animal/M as mob)
	attack_hand(M)
	return

/mob/living/simple_animal/pug/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	attack_hand(M)
	return

/mob/living/simple_animal/pug/attack_slime(mob/living/carbon/slime/M as mob)
	attack_hand(M)
	return

/mob/living/simple_animal/pug/attackby(var/obj/item/O as obj, var/mob/user as mob)
	attack_hand(user)
	return

/mob/living/simple_animal/pug/Die()
	src.gib()
	return

/mob/living/simple_animal/pug/gib()
	for(var/mob/living/carbon/human/Covered in range(3,src))
		if(Covered.wear_mask)
			Covered.wear_mask.add_blood(Covered)
		if(Covered.l_hand)
			Covered.l_hand.add_blood(Covered)
		if(Covered.r_hand)
			Covered.r_hand.add_blood(Covered)
		if(Covered.back)
			Covered.back.add_blood(Covered)
		if(Covered.wear_suit)
			Covered.wear_suit.add_blood(Covered)
		if(Covered.gloves)
			Covered.gloves.add_blood(Covered)
		if(Covered.shoes)
			Covered.shoes.add_blood(Covered)
		if(Covered.belt)
			Covered.belt.add_blood(Covered)
		if(Covered.glasses)
			Covered.glasses.add_blood(Covered)
		if(Covered.head)
			Covered.head.add_blood(Covered)
		if(Covered.ears)
			Covered.ears.add_blood(Covered)
		if(Covered.w_uniform)
			Covered.w_uniform.add_blood(Covered)
		if(Covered.wear_id)
			Covered.wear_id.add_blood(Covered)
		if(Covered.l_store)
			Covered.l_store.add_blood(Covered)
		if(Covered.r_store)
			Covered.r_store.add_blood(Covered)
		if(Covered.s_store)
			Covered.s_store.add_blood(Covered)
	for(var/turf/simulated/bloodfloor in range(3,src))
		new /obj/effect/decal/cleanable/blood(bloodfloor)
	..()
	return
