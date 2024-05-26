/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	base_icon_state = "toilet"
	density = FALSE
	anchored = TRUE

	///Boolean if whether the toilet is currently flushing.
	var/flushing = FALSE
	///Boolean if the toilet seat is up.
	var/open = FALSE
	///Boolean if the cistern is up, allowing items to be put in/out.
	var/cistern
	///Amount of fish currently in the toilet, not to be mixed with the items in the cistern.
	var/fishes = 0
	///The combined weight of all items in the cistern put together.
	var/w_items = 0
	///Reference to the mob being given a swirlie.
	var/mob/living/swirlie
	///The type of material used to build the toilet.
	var/buildstacktype = /obj/item/stack/sheet/iron
	///How much of the buildstacktype is needed to construct the toilet.
	var/buildstackamount = 1
	///Static toilet water overlay given to toilets that are facing a direction we can see the water in.
	var/static/mutable_appearance/toilet_water

/obj/structure/toilet/Initialize(mapload)
	. = ..()
	if(isnull(toilet_water))
		toilet_water = mutable_appearance(icon, "[base_icon_state]-water")
	open = round(rand(0, 1))
	update_appearance(UPDATE_ICON)
	if(mapload && SSmapping.level_trait(z, ZTRAIT_STATION))
		AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/toilet)

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
		if(open)
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

	if(cistern && !open && user.CanReach(src))
		if(!contents.len)
			to_chat(user, span_notice("The cistern is empty."))
			return
		var/obj/item/I = pick(contents)
		if(ishuman(user))
			user.put_in_hands(I)
		else
			I.forceMove(drop_location())
		to_chat(user, span_notice("You find [I] in the cistern."))
		w_items -= I.w_class
		return

	else if(!flushing)
		open = !open
		update_appearance(UPDATE_ICON)

/obj/structure/toilet/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(flushing)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	flushing = TRUE
	playsound(src, "sound/machines/toilet_flush.ogg", open ? 40 : 20, TRUE)
	if(open && (dir & SOUTH))
		update_appearance(UPDATE_OVERLAYS)
		flick_overlay_view(mutable_appearance(icon, "[base_icon_state]-water-flick"), 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_flushing)), 4 SECONDS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/toilet/update_icon_state()
	icon_state = "[base_icon_state][open][cistern]"
	return ..()

/obj/structure/toilet/update_overlays()
	. = ..()
	if(!flushing && open && (dir & SOUTH))
		. += toilet_water

/obj/structure/toilet/atom_deconstruct(dissambled = TRUE)
	for(var/obj/toilet_item in contents)
		toilet_item.forceMove(drop_location())
	if(buildstacktype)
		new buildstacktype(loc,buildstackamount)
	else
		for(var/i in custom_materials)
			var/datum/material/M = i
			new M.sheet_type(loc, FLOOR(custom_materials[M] / SHEET_MATERIAL_AMOUNT, 1))

/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	add_fingerprint(user)
	if(I.tool_behaviour == TOOL_CROWBAR)
		to_chat(user, span_notice("You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]..."))
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, TRUE)
		if(I.use_tool(src, user, 30))
			user.visible_message(span_notice("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!"), span_notice("You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!"), span_hear("You hear grinding porcelain."))
			cistern = !cistern
			update_appearance()
		return COMPONENT_CANCEL_ATTACK_CHAIN
	else if(I.tool_behaviour == TOOL_WRENCH)
		I.play_tool_sound(src)
		deconstruct()
		return TRUE
	else if(cistern && !user.combat_mode)
		if(I.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, span_warning("[I] does not fit!"))
			return
		if(w_items + I.w_class > WEIGHT_CLASS_HUGE)
			to_chat(user, span_warning("The cistern is full!"))
			return
		if(!user.transferItemToLoc(I, src))
			to_chat(user, span_warning("\The [I] is stuck to your hand, you cannot put it in the cistern!"))
			return
		w_items += I.w_class
		to_chat(user, span_notice("You carefully place [I] into the cistern."))
		return

	if(is_reagent_container(I) && !user.combat_mode)
		if (!open)
			return
		if(istype(I, /obj/item/food/monkeycube))
			var/obj/item/food/monkeycube/cube = I
			cube.Expand()
			return
		var/obj/item/reagent_containers/RG = I
		RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		to_chat(user, span_notice("You fill [RG] from [src]. Gross."))
	return ..()

///Ends the flushing animation and updates overlays if necessary
/obj/structure/toilet/proc/end_flushing()
	flushing = FALSE
	if(open && (dir & SOUTH))
		update_appearance(UPDATE_OVERLAYS)

/obj/structure/toilet/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	buildstacktype = null
