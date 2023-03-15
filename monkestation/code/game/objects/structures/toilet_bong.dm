/obj/structure/toilet_bong
	name = "toilet bong"
	desc = "It's a toilet that's been fitted into a bong. It is used for exactly what you think it's for."
	icon = 'monkestation/icons/obj/watercloset.dmi'
	icon_state = "toiletbong"
	density = FALSE
	anchored = TRUE
	var/mutable_appearance/weed_overlay
	var/smoking = FALSE

/obj/structure/toilet_bong/Initialize()
	. = ..()
	weed_overlay = mutable_appearance('monkestation/icons/obj/watercloset.dmi', "weed")
	START_PROCESSING(SSobj, src)

/obj/structure/toilet_bong/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = AddComponent(/datum/component/storage/concrete)
	STR.attack_hand_interact = FALSE
	STR.set_holdable(list(/obj/item/food/grown)) //FUCK YEAH SMOKE ANYTHING AT ALL
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = WEIGHT_CLASS_SMALL * 24
	STR.max_items = 24
	RegisterSignal(STR, COMSIG_STORAGE_INSERTED, /atom/.proc/update_icon)
	RegisterSignal(STR, COMSIG_STORAGE_REMOVED, /atom/.proc/update_icon)

/obj/structure/toilet_bong/update_icon()
	. = ..()
	cut_overlays()
	if (LAZYLEN(contents))
		add_overlay(weed_overlay)

/obj/structure/toilet_bong/attack_hand(mob/user)
	. = ..()
	if(!smoking)
		if (LAZYLEN(contents))
			smoking = !smoking
			spawn(2 SECONDS)
				smoking = !smoking
			if (do_after(user, 2 SECONDS, target = src))
				var/obj/item/reagent_containers/boof = contents[1]
				user.visible_message("<span class='boldwarning'>[user] takes a huge rip from [src]!</span>", "<span class='boldnotice'>You take a huge rip from [src]!</span>")
				var/smoke_spread = 1
				if (prob(15))
					user.visible_message("<span class='danger'>[user] coughs while using [src], filling the area with smoke!", "<span class='userdanger'>You cough while using [src], filling the area with smoke!</span>")
					smoke_spread = 5
				var/turf/location = get_turf(user)
				var/datum/effect_system/smoke_spread/chem/smoke = new
				smoke.attach(location)
				smoke.set_up(boof.reagents, smoke_spread, location, silent = TRUE)
				smoke.start()
				qdel(boof)
				update_icon()
		else
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
	else
		to_chat(user, "<span class='warning'>[src] is being smoked already!</span>")
		return

// It's a bong powered by a **flamethrower**, it's definitely an open flame!!
/obj/structure/toilet_bong/process()
	var/turf/location = get_turf(src)
	location.hotspot_expose(700,2)
