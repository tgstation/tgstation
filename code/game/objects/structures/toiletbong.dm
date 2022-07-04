/obj/structure/toiletbong
	name = "toilet bong"
	desc = "A repurposed toilet with re-arranged piping and an attached flamethrower. Why would anyone build this?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toiletbong"
	density = TRUE
	anchored = TRUE
	var/mutable_appearance/weed_overlay

/obj/structure/toiletbong/Initialize()
	. = ..()
	weed_overlay = mutable_appearance('icons/obj/watercloset.dmi', "toiletbong_overlay")
	START_PROCESSING(SSobj, src)

/obj/structure/toiletbong/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = AddComponent(/datum/component/storage/concrete)
	STR.attack_hand_interact = FALSE
	STR.set_holdable(list(/obj/item/food/))
	STR.max_w_class = WEIGHT_CLASS_HUGE
	STR.max_combined_w_class = WEIGHT_CLASS_HUGE * 12
	STR.max_items = 12

/obj/structure/toiletbong/update_icon()
	. = ..()
	cut_overlays()
	if (LAZYLEN(contents))
		add_overlay(weed_overlay)

/obj/structure/toiletbong/attack_hand(mob/living/carbon/user)
	. = ..()
	if (!anchored)
		user.balloon_alert(user, "Secure it first!")
		return
	if (!LAZYLEN(contents))
		user.balloon_alert(user, "It's empty!")
		return
	user.visible_message(span_boldnotice("[user] takes a huge drag on the [src]."))
	if (do_after(user, 2 SECONDS, target = src))
		var/obj/item/reagent_containers/item = contents[1]
		playsound(src, 'sound/items/modsuit/flamethrower.ogg', 50)
		var/datum/effect_system/fluid_spread/smoke/chem/smoke_machine/puff = new
		puff.set_up(1, holder = src, location = user, carry = item.reagents, efficiency = 20)
		puff.start()
		if (prob(5))
			if(islizard(user) || isfelinid(user))
				to_chat(user, span_boldnotice("A hidden treat in the pipes!"))
				user.balloon_alert(user, "A hidden treat in the pipes!")
				user.visible_message(span_danger("[user] fishes a mouse out of the pipes."))
			else
				to_chat(user, span_userdanger("There was something disgusting in the pipes!"))
				user.visible_message(span_danger("[user] spits out a mouse."))
				user.adjust_disgust(50)
				user.vomit(10)
			var/mob/living/spawned_mob = new /mob/living/simple_animal/mouse(get_turf(user))
			spawned_mob.faction |= "[REF(user)]"
			if(prob(50))
				for(var/j in 1 to rand(1, 3))
					step(spawned_mob, pick(NORTH,SOUTH,EAST,WEST))
		qdel(item)
		update_icon()

/obj/structure/toiletbong/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	if(anchored)
		to_chat(user, span_notice("You begin unsecuring the [src]."))
		anchored = FALSE
	else
		to_chat(user, span_notice("You secure the [src] to the floor."))
		anchored = TRUE
	return TRUE

/obj/structure/toiletbong/alt_click_secondary(mob/living/user)
	setDir(turn(dir,-90))
	playsound(src, 'sound/items/deconstruct.ogg', 50)
	return
