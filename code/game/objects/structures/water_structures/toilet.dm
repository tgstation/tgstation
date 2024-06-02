/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00" //The first number represents if the toilet lid is up, the second is if the cistern is open.
	base_icon_state = "toilet"
	density = FALSE
	anchored = TRUE

	///Boolean if whether the toilet is currently flushing.
	var/flushing = FALSE
	///Boolean if the toilet seat is up.
	var/cover_open = FALSE
	///Boolean if the cistern is up, allowing items to be put in/out.
	var/cistern_open = FALSE
	///The combined weight of all items in the cistern put together.
	var/w_items = 0
	///Reference to the mob being given a swirlie.
	var/mob/living/swirlie
	///The type of material used to build the toilet.
	var/buildstacktype = /obj/item/stack/sheet/iron
	///How much of the buildstacktype is needed to construct the toilet.
	var/buildstackamount = 1
	///Lazylist of items in the cistern.
	var/list/cistern_items
	///Lazylist of fish in the toilet, not to be mixed with the items in the cistern. Max of 3
	var/list/fishes
	///Static toilet water overlay given to toilets that are facing a direction we can see the water in.
	var/static/mutable_appearance/toilet_water_overlay

/obj/structure/toilet/Initialize(mapload)
	. = ..()
	if(isnull(toilet_water_overlay))
		toilet_water_overlay = mutable_appearance(icon, "[base_icon_state]-water")
	cover_open = round(rand(0, 1))
	update_appearance(UPDATE_ICON)
	if(mapload && SSmapping.level_trait(z, ZTRAIT_STATION))
		AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/toilet)
	register_context()

/obj/structure/toilet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(user.pulling && isliving(user.pulling))
		context[SCREENTIP_CONTEXT_LMB] = "Give Swirlie"
	else if(cover_open && istype(held_item, /obj/item/fish))
		context[SCREENTIP_CONTEXT_LMB] = "Insert Fish"
	else if(cover_open && LAZYLEN(fishes))
		context[SCREENTIP_CONTEXT_LMB] = "Grab Fish"
	else if(cistern_open)
		if(isnull(held_item))
			context[SCREENTIP_CONTEXT_LMB] = "Check Cistern"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Insert Item"
	context[SCREENTIP_CONTEXT_RMB] = "Flush"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "[cover_open ? "Close" : "Open"] Lid"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/toilet/examine(mob/user)
	. = ..()
	if(cover_open && LAZYLEN(fishes))
		. += span_notice("You can see fish in the toilet, you can probably take one out.")

/obj/structure/toilet/examine_more(mob/user)
	. = ..()
	if(cistern_open && LAZYLEN(cistern_items))
		. += span_notice("You can see [cistern_items.len] items inside of the cistern.")

/obj/structure/toilet/Destroy(force)
	. = ..()
	QDEL_LAZYLIST(fishes)
	QDEL_LAZYLIST(cistern_items)

/obj/structure/toilet/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in cistern_items)
		LAZYREMOVE(cistern_items, gone)
		return
	if(gone in fishes)
		LAZYREMOVE(fishes, gone)
		return

/obj/structure/toilet/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, SFX_SWING_HIT, 25, TRUE)
		swirlie.visible_message(span_danger("[user] slams the toilet seat onto [swirlie]'s head!"), span_userdanger("[user] slams the toilet seat onto your head!"), span_hear("You hear reverberating porcelain."))
		log_combat(user, swirlie, "swirlied (brute)")
		swirlie.adjustBruteLoss(5)
		return

	if(user.pulling && isliving(user.pulling))
		user.changeNext_move(CLICK_CD_MELEE)
		var/mob/living/grabbed_mob = user.pulling
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a tighter grip!"))
			return
		if(grabbed_mob.loc != get_turf(src))
			to_chat(user, span_warning("[grabbed_mob] needs to be on [src]!"))
			return
		if(swirlie)
			return
		if(cover_open)
			grabbed_mob.visible_message(span_danger("[user] starts to give [grabbed_mob] a swirlie!"), span_userdanger("[user] starts to give you a swirlie..."))
			swirlie = grabbed_mob
			var/was_alive = (swirlie.stat != DEAD)
			if(!do_after(user, 3 SECONDS, target = src, timed_action_flags = IGNORE_HELD_ITEM))
				swirlie = null
				return
			grabbed_mob.visible_message(span_danger("[user] gives [grabbed_mob] a swirlie!"), span_userdanger("[user] gives you a swirlie!"), span_hear("You hear a toilet flushing."))
			if(iscarbon(grabbed_mob))
				var/mob/living/carbon/carbon_grabbed = grabbed_mob
				if(!carbon_grabbed.internal)
					log_combat(user, carbon_grabbed, "swirlied (oxy)")
					carbon_grabbed.adjustOxyLoss(5)
			else
				log_combat(user, grabbed_mob, "swirlied (oxy)")
				grabbed_mob.adjustOxyLoss(5)
			if(was_alive && swirlie.stat == DEAD && swirlie.client)
				swirlie.client.give_award(/datum/award/achievement/misc/swirlie, swirlie) // just like space high school all over again!
			swirlie = null
		else
			playsound(src.loc, 'sound/effects/bang.ogg', 25, TRUE)
			grabbed_mob.visible_message(span_danger("[user] slams [grabbed_mob.name] into [src]!"), span_userdanger("[user] slams you into [src]!"))
			log_combat(user, grabbed_mob, "toilet slammed")
			grabbed_mob.adjustBruteLoss(5)
		return

	if(cistern_open && !cover_open && user.CanReach(src))
		if(!LAZYLEN(cistern_items))
			to_chat(user, span_notice("The cistern is empty."))
			return
		var/obj/item/random_cistern_item = pick(cistern_items)
		if(ishuman(user))
			user.put_in_hands(random_cistern_item)
		else
			random_cistern_item.forceMove(drop_location())
		to_chat(user, span_notice("You find [random_cistern_item] in the cistern."))
		w_items -= random_cistern_item.w_class
		return

	if(!flushing && LAZYLEN(fishes) && cover_open)
		var/obj/item/random_fish = pick(fishes)
		if(ishuman(user))
			user.put_in_hands(random_fish)
		else
			random_fish.forceMove(drop_location())
		to_chat(user, span_notice("You take [random_fish] out of the toilet, poor thing."))

/obj/structure/toilet/click_alt(mob/living/user)
	if(flushing)
		return CLICK_ACTION_BLOCKING
	cover_open = !cover_open
	update_appearance(UPDATE_ICON)
	return CLICK_ACTION_SUCCESS

/obj/structure/toilet/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(flushing)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	flushing = TRUE
	playsound(src, "sound/machines/toilet_flush.ogg", cover_open ? 40 : 20, TRUE)
	if(cover_open && (dir & SOUTH))
		update_appearance(UPDATE_OVERLAYS)
		flick_overlay_view(mutable_appearance(icon, "[base_icon_state]-water-flick"), 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_flushing)), 4 SECONDS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/toilet/update_icon_state()
	icon_state = "[base_icon_state][cover_open][cistern_open]"
	return ..()

/obj/structure/toilet/update_overlays()
	. = ..()
	if(!flushing && cover_open && (dir & SOUTH))
		. += toilet_water_overlay

/obj/structure/toilet/atom_deconstruct(dissambled = TRUE)
	for(var/obj/toilet_item in cistern_items)
		toilet_item.forceMove(drop_location())
	if(buildstacktype)
		new buildstacktype(loc,buildstackamount)
	else
		for(var/datum/material/M as anything in custom_materials)
			new M.sheet_type(loc, FLOOR(custom_materials[M] / SHEET_MATERIAL_AMOUNT, 1))

/obj/structure/toilet/attackby(obj/item/attacking_item, mob/living/user, params)
	add_fingerprint(user)
	if(cover_open && istype(attacking_item, /obj/item/fish))
		if(fishes >= 3)
			to_chat(user, span_warning("There's too many fishes, flush them down first."))
			return
		if(!user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_warning("\The [attacking_item] is stuck to your hand!"))
			return
		var/obj/item/fish/the_fish = attacking_item
		if(the_fish.status == FISH_DEAD)
			to_chat(user, span_warning("You place [attacking_item] into [src], may it rest in peace."))
		else
			to_chat(user, span_notice("You place [attacking_item] into [src], hopefully no one will miss it!"))
		LAZYADD(fishes, attacking_item)
		return

	if(cistern_open && !user.combat_mode)
		if(attacking_item.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, span_warning("[attacking_item] does not fit!"))
			return
		if(w_items + attacking_item.w_class > WEIGHT_CLASS_HUGE)
			to_chat(user, span_warning("The cistern is full!"))
			return
		if(!user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_warning("\The [attacking_item] is stuck to your hand, you cannot put it in the cistern!"))
			return
		LAZYADD(cistern_items, attacking_item)
		w_items += attacking_item.w_class
		to_chat(user, span_notice("You carefully place [attacking_item] into the cistern."))
		return

	if(is_reagent_container(attacking_item) && !user.combat_mode)
		if (!cover_open)
			return
		if(istype(attacking_item, /obj/item/food/monkeycube))
			var/obj/item/food/monkeycube/cube = attacking_item
			cube.Expand()
			return
		var/obj/item/reagent_containers/RG = attacking_item
		RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		to_chat(user, span_notice("You fill [RG] from [src]. Gross."))
	return ..()

/obj/structure/toilet/crowbar_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You start to [cistern_open ? "replace the lid on" : "lift the lid off"] the cistern..."))
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, TRUE)
	if(tool.use_tool(src, user, 30))
		user.visible_message(
			span_notice("[user] [cistern_open ? "replaces the lid on" : "lifts the lid off"] the cistern!"),
			span_notice("You [cistern_open ? "replace the lid on" : "lift the lid off"] the cistern!"),
			span_hear("You hear grinding porcelain."))
		cistern_open = !cistern_open
		update_appearance(UPDATE_ICON_STATE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/toilet/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	deconstruct()
	return ITEM_INTERACT_SUCCESS

///Ends the flushing animation and updates overlays if necessary
/obj/structure/toilet/proc/end_flushing()
	flushing = FALSE
	if(cover_open && (dir & SOUTH))
		update_appearance(UPDATE_OVERLAYS)
	QDEL_LAZYLIST(fishes)

/obj/structure/toilet/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	buildstacktype = null

/obj/structure/toilet/secret
	var/secret_type = null

/obj/structure/toilet/secret/Initialize(mapload)
	. = ..()
	if(secret_type)
		var/obj/item/secret = new secret_type(src)
		secret.desc += " It's a secret!"
		w_items += secret.w_class
		LAZYADD(cistern_items, secret)
