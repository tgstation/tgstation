/mob/living/carbon/monkey
	var/list/relationships = list()

/mob/living/carbon/monkey/proc/adjust_relation(target, amount)
	var/R = relationships[target]
	if(isnull(R))
		relationships[target] = min(1 + amount, 0)
		return
	relationships[target] = min(relationships[target] + amount, 0)

/mob/living/carbon/monkey/proc/get_relation(target)
	return relationships[target]

/mob/living/carbon/monkey/proc/set_relation(target, amount)
	relationships[target] = amount

/mob/living/carbon/monkey/proc/sit_on_shoulder(mob/living/carbon/human/H)
	set name = "Sit on Shoulder"
	set category = "Monkey"
	set desc = "Sit on a nice comfy human being!"
	if(!H)
		return
	if(buckled)
		get_off_shoulder(H)
		return
	loc = get_turf(H)
	if(H.buckle_mob(src, force=1))
		pixel_y = 9
		layer = H.layer - 0.01
		pixel_x = pick(-8,8) //pick left or right shoulder
		visible_message("<span class='notice'>[src] climbs onto [H]'s shoulder!</span>", "<span class='notice'>You climb onto [H]'s shoulder.</span>")

/mob/living/carbon/monkey/proc/get_off_shoulder(mob/living/carbon/human/H)
	mode = MONKEY_IDLE
	target = null
	if(buckled)
		visible_message("<span class='notice'>[src] climbs off [H]'s shoulder!</span>", "<span class='notice'>You climb off [H]'s shoulder.</span>")
		buckled.unbuckle_mob(src,force=1)
	buckled = null
	layer = initial(layer)
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

/mob/living/carbon/monkey/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/food = W
		if(food.foodtype & disliked_food)
			visible_message("<span class='danger'>[src] looks at [W], but pushes it away.</span>", "<span class='danger'>We reject the gross-looking [W]!</span>")
			return
		else if(food.foodtype & liked_food)
			visible_message("<span class='danger'>[src] grabs [W] and gobbles it down!</span>", "<span class='danger'>We chow down on [W]!</span>")
			adjust_relation(user, 0.5)
			playsound(src, "sound/items/eatfood.ogg", 52, 1)
			food.reagents.trans_to(src)
			new /obj/effect/temp_visual/heart(loc)
			qdel(W)
			return
		else
			visible_message("<span class='danger'>[src] eats [W].</span>", "<span class='danger'>We eat [W].</span>")
			adjust_relation(user, 0.2)
			playsound(src, "sound/items/eatfood.ogg", 5, 1)
			new /obj/effect/temp_visual/heart(loc)
			food.reagents.trans_to(src, multiplier=0.9)
			qdel(W)
			return
	. = ..()
/mob/living/carbon/monkey/proc/handle_friendly()
	var/list/around = view(src, MONKEY_ENEMY_VISION)
	for(var/mob/living/carbon/human/L in around)
		var/R = get_relation(L)
		if(!buckled && mode != MONKEY_CLIMB && prob(10) && (!isnull(R) && R > MONKEY_RELATION_OK))
			mode = MONKEY_CLIMB
			target = L
			break

	switch(mode)
		if(MONKEY_CLIMB)
			if(buckled)
				if(buckled && get_relation(buckled) < MONKEY_RELATION_BITE)
					to_chat(buckled, "<span class='userdanger'>[src] bites you in the face!</span>")
					visible_message("<span class='danger'>[src] bites [buckled] in the face!</span>")
					a_intent = INTENT_HARM
					attack_paw(buckled)
					a_intent = INTENT_HELP
					get_off_shoulder(buckled)
				if(buckled && prob(1))
					get_off_shoulder(buckled)
				return FALSE
			if(target != null && !Adjacent(target))
				INVOKE_ASYNC(src, .proc/walk2derpless, target)
			if(target == null)
				back_to_idle()
				return
			if(target && target.stat == CONSCIOUS)
				if(Adjacent(target) && isturf(target.loc))
					sit_on_shoulder(target)
					return TRUE
	return FALSE

/mob/living/carbon/monkey/proc/should_worry(mob/T)
	var/R = get_relation(T)
	if(isnull(R))
		relationships[T] = MONKEY_RELATION_OK
		return FALSE
	return R >= MONKEY_RELATION_LOVE || (R >= MONKEY_RELATION_LIKE && prob(50)) || (R > MONKEY_RELATION_OK && prob(25))