////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = list()
	volume = 50	//Sets the default container amount for all food items.
	container_type = INJECTABLE
	resistance_flags = FLAMMABLE
	var/foodtype = NONE
	var/last_check_time

/obj/item/weapon/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(!mapload)
		pixel_x = rand(-5, 5)
		pixel_y = rand(-5, 5)

/obj/item/weapon/reagent_containers/food/proc/checkLiked(var/fraction, mob/M)
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(foodtype & H.dna.species.toxic_food)
				to_chat(H,"<span class='warning'>What the hell was that thing?!</span>")
				H.adjust_disgust(25 + 30 * fraction)
			else if(foodtype & H.dna.species.disliked_food)
				to_chat(H,"<span class='notice'>That didn't taste very good...</span>")
				H.adjust_disgust(11 + 15 * fraction)
			else if(foodtype & H.dna.species.liked_food)
				to_chat(H,"<span class='notice'>I love this taste!</span>")
				H.adjust_disgust(-5 + -2.5 * fraction)
			last_check_time = world.time
