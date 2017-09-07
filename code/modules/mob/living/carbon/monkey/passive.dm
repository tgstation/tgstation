/mob/living/carbon/monkey/proc/adjust_relation(target, amount)
	relations[target] = min(relations[target] + amount, 0)

/mob/living/carbon/monkey/proc/sit_on_shoulder(mob/living/carbon/human/H)
	if(!H)
		return
	loc = get_turf(H)
	on_shoulder = TRUE
	H.buckle_mob(src, force=1)
	pixel_y = 9
	pixel_x = pick(-8,8) //pick left or right shoulder
	visible_message("<span class='notice'>[src] climbs onto [H]'s shoulder!</span>", "<span class='notice'>You climb onto [H]'s shoulder.</span>")

/mob/living/carbon/monkey/proc/get_off_shoulder(mob/living/carbon/human/H)
		mode = MONKEY_IDLE
		on_shoulder = FALSE
		target = null
		if(buckled)
			visible_message("<span class='notice'>[src] climbs off [H]'s shoulder!</span>", "<span class='notice'>You climb off [H]'s shoulder.</span>")
			buckled.unbuckle_mob(src,force=1)
		buckled = null
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)

/mob/living/carbon/monkey/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/food = W
		if(W.foodtype & disliked_food)
			visible_message("<span class='danger'>[src] looks at [W], but pushes it away.</span>, <span class='danger'>We reject the gross-looking [W]!</span>")
			return
		else if(W.foodtype & liked_food)
			visible_message("<span class='danger'>[src] grabs [W] and gobbles it down!</span>, <span class='danger'>We chow down on [W]!</span>")
			adjust_relation(user, 0.3)
			playsound(src, "sound/items/eatfood.ogg", 52, 1)
			W.trans_to(src)
			qdel(W)
		else
			visible_message("<span class='danger'>[src] eats [W].</span>, <span class='danger'>We eat [W].</span>")
			adjust_relation(user, 0.2)
			playsound(src, "sound/items/eatfood.ogg", 5, 1)
			W.trans_to(src, multiplier=0.9)
			qdel(W)

/mob/living/carbon/monkey/proc/handle_friendly()
	var/list/around = view(src, MONKEY_ENEMY_VISION)
	for(var/mob/living/carbon/human/L in around)
		if(mode != MONKEY_CLIMB && prob(10) && (relations[L] && relations[L] >= MONKEY_RELATION_OK))
			mode = MONKEY_CLIMB
			target = L
			break

	switch(mode)
		if(MONKEY_CLIMB)
			if(on_shoulder)
				if(on_shoulder && prob(5))
					get_off_shoulder(target)
				return FALSE
			if(target != null)
				INVOKE_ASYNC(src, .proc/walk2derpless, target)
			else
				back_to_idle()
				return
			if(target && target.stat == CONSCIOUS)
				if(Adjacent(target) && isturf(target.loc))
					sit_on_shoulder(target)
					return TRUE
	return FALSE