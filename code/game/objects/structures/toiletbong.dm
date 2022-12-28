/obj/structure/toiletbong
	name = "toilet bong"
	desc = "A repurposed toilet with re-arranged piping and an attached flamethrower. Why would anyone build this?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toiletbong"
	density = TRUE
	anchored = TRUE
	var/emagged = FALSE
	var/smokeradius = 1
	var/mutable_appearance/weed_overlay

/obj/structure/toiletbong/Initialize(mapload)
	. = ..()
	create_storage()
	atom_storage.attack_hand_interact = FALSE
	atom_storage.set_holdable(list(/obj/item/food/))
	atom_storage.max_total_storage = 100
	atom_storage.max_slots = 12
	weed_overlay = mutable_appearance('icons/obj/watercloset.dmi', "toiletbong_overlay")
	START_PROCESSING(SSobj, src)

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
		var/turf/toiletbong_location = loc
		toiletbong_location.hotspot_expose(1000, 5)
		for (var/obj/item/item in contents)
			if (item.resistance_flags & INDESTRUCTIBLE)
				user.balloon_alert(user, "[item.name] is blocking the pipes!")
				continue
			playsound(src, 'sound/items/modsuit/flamethrower.ogg', 50)
			var/datum/effect_system/fluid_spread/smoke/chem/smoke_machine/puff = new
			puff.set_up(smokeradius, holder = src, location = user, carry = item.reagents, efficiency = 20)
			puff.start()
			if (prob(5) && !emagged)
				if(islizard(user))
					to_chat(user, span_boldnotice("A hidden treat in the pipes!"))
					user.balloon_alert(user, "A hidden treat in the pipes!")
					user.visible_message(span_danger("[user] fishes a mouse out of the pipes."))
				else
					to_chat(user, span_userdanger("There was something disgusting in the pipes!"))
					user.visible_message(span_danger("[user] spits out a mouse."))
					user.adjust_disgust(50)
					user.vomit(10)
				var/mob/living/spawned_mob = new /mob/living/basic/mouse(get_turf(user))
				spawned_mob.faction |= "[REF(user)]"
				if(prob(50))
					for(var/j in 1 to rand(1, 3))
						step(spawned_mob, pick(NORTH,SOUTH,EAST,WEST))
			qdel(item)
			if(!emagged)
				break
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

/obj/structure/toiletbong/crowbar_act(mob/living/user, obj/item/tool)
	if(anchored)
		return FALSE
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You begin taking apart the [src]."))
	if (!do_after(user, 10 SECONDS, target = src))
		return FALSE
	new /obj/item/flamethrower(get_turf(src))
	new /obj/item/stack/sheet/iron(get_turf(src))
	var/obj/item/tank/internals/plasma/ptank = new /obj/item/tank/internals/plasma(get_turf(src))
	ptank.air_contents.gases[/datum/gas/plasma][MOLES] = (0)
	qdel(src)
	return TRUE

/obj/structure/toiletbong/AltClick(mob/living/user)
	if(anchored)
		return ..()
	setDir(turn(dir,90))
	playsound(src, 'sound/items/deconstruct.ogg', 50)
	return

/obj/structure/toiletbong/emag_act(mob/user, obj/item/card/emag/emag_card)
	playsound(src, 'sound/effects/fish_splash.ogg', 50)
	user.balloon_alert(user, "Whoops!")
	if(!emagged)
		emagged = TRUE
		smokeradius = 2
		to_chat(user, span_boldwarning("The [emag_card.name] falls into the toilet. You fish it back out. Looks like you broke the toilet."))

/obj/structure/toiletbong/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/emag))
		return
	. = ..()
