/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00" //The first number represents if the toilet lid is up, the second is if the cistern is open.
	base_icon_state = "toilet"
	density = FALSE
	anchored = TRUE

	/// Boolean if whether the toilet is currently flushing.
	var/flushing = FALSE
	/// Boolean if the toilet seat is up.
	var/cover_open = FALSE
	/// Boolean if the cistern is up, allowing items to be put in/out.
	var/cistern_open = FALSE
	/// The combined weight of all items in the cistern put together.
	var/w_items = 0
	/// Reference to the mob being given a swirlie.
	var/mob/living/swirlie
	/// The type of material used to build the toilet.
	var/buildstacktype = /obj/item/stack/sheet/iron
	/// How much of the buildstacktype is needed to construct the toilet.
	var/buildstackamount = 1
	/// Lazylist of items in the cistern.
	var/list/cistern_items
	/// Lazylist of fish in the toilet, not to be mixed with the items in the cistern. Max of 3
	var/list/fishes
	/// Does the toilet have a water recycler to recollect its water supply?
	var/has_water_reclaimer = TRUE
	/// Units of water to reclaim per second
	var/reclaim_rate = 0.5
	/// What reagent does the toilet flush with
	var/reagent_id = /datum/reagent/water
	/// How much reagent can the cistern contain
	var/reagent_capacity = 200
	/// Item stuck in the basin of the toilet
	var/obj/item/stuck_item = null

/obj/structure/toilet/Initialize(mapload, has_water_reclaimer = null)
	. = ..()
	cover_open = round(rand(0, 1))
	if(!isnull(has_water_reclaimer))
		src.has_water_reclaimer = has_water_reclaimer
	update_appearance(UPDATE_ICON)
	if(mapload && SSmapping.level_trait(z, ZTRAIT_STATION))
		AddComponent(/datum/component/fishing_spot, GLOB.preset_fish_sources[/datum/fish_source/toilet])
	AddElement(/datum/element/fish_safe_storage)
	register_context()
	create_reagents(reagent_capacity)
	if(src.has_water_reclaimer)
		reagents.add_reagent(reagent_id, reagent_capacity)
	AddComponent(/datum/component/plumbing/simple_demand, extend_pipe_to_edge = TRUE)

/obj/structure/toilet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(user.pulling && isliving(user.pulling))
		context[SCREENTIP_CONTEXT_LMB] = "Give Swirlie"
	if(cover_open)
		if(isnull(held_item))
			if(LAZYLEN(fishes))
				context[SCREENTIP_CONTEXT_LMB] = "Grab Fish"
		else if(istype(held_item, /obj/item/fish))
			context[SCREENTIP_CONTEXT_LMB] = "Insert Fish"
		else if(istype(held_item, /obj/item/plunger))
			context[SCREENTIP_CONTEXT_LMB] = "Unclog"
		else if(held_item.w_class <= WEIGHT_CLASS_SMALL)
			context[SCREENTIP_CONTEXT_LMB] = "Insert Item"
	else if(cistern_open)
		if(isnull(held_item))
			context[SCREENTIP_CONTEXT_LMB] = "Check Cistern"
		else if(held_item.tool_behaviour == TOOL_SCREWDRIVER && has_water_reclaimer)
			context[SCREENTIP_CONTEXT_LMB] = "Remove Reclaimer"
		else if(istype(held_item, /obj/item/stock_parts/water_recycler) && !has_water_reclaimer)
			context[SCREENTIP_CONTEXT_LMB] = "Install Reclaimer"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Insert Item"
	context[SCREENTIP_CONTEXT_RMB] = "Flush"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "[cover_open ? "Close" : "Open"] Lid"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/toilet/examine(mob/user)
	. = ..()
	if(cover_open)
		if(LAZYLEN(fishes))
			. += span_notice("You can see fish in the toilet, you can probably take one out.")
		if(stuck_item)
			. += span_notice("There seems to be something small in [src]'s bowl...")
	if(cistern_open && has_water_reclaimer)
		. += span_notice("A water recycler is installed. Its attached by a pair of screws.")
		. += span_notice("Its display states: [reagents.total_volume]/[reagents.maximum_volume] liquids remaining.")

/obj/structure/toilet/examine_more(mob/user)
	. = ..()
	if(cistern_open && LAZYLEN(cistern_items))
		. += span_notice("You can see [cistern_items.len] items inside of the cistern.")

/obj/structure/toilet/Destroy(force)
	. = ..()
	QDEL_LAZYLIST(fishes)
	QDEL_LAZYLIST(cistern_items)
	QDEL_NULL(stuck_item)

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
			if(!reagents.total_volume)
				to_chat(user, span_notice("\The [src] is dry!"))
				return
			grabbed_mob.visible_message(span_danger("[user] starts to give [grabbed_mob] a swirlie!"), span_userdanger("[user] starts to give you a swirlie..."))
			swirlie = grabbed_mob
			var/was_alive = (swirlie.stat != DEAD)
			if(!do_after(user, 3 SECONDS, target = src, timed_action_flags = IGNORE_HELD_ITEM))
				swirlie = null
				return
			if(!reagents.total_volume)
				to_chat(user, span_notice("\The [src] is dry!"))
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

	if(reagents.total_volume <= 50)
		to_chat(user, span_notice("You press the flush lever, but nothing happens."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	flushing = TRUE
	var/something_stuck = !isnull(stuck_item)
	if(!something_stuck && LAZYLEN(fishes))
		for(var/obj/item/fish/fish as anything in fishes)
			if(fish.w_class >= WEIGHT_CLASS_NORMAL)
				something_stuck = TRUE
				break

	if(something_stuck)
		reagents.create_foam(/datum/effect_system/fluid_spread/foam, 10, notification = span_danger("[src] overflows, spilling its cistern's contents everywhere!"), log = TRUE)
	else
		reagents.remove_all(50)

	begin_reclamation()
	playsound(src, 'sound/machines/toilet_flush.ogg', cover_open ? 40 : 20, TRUE)
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
	if(!flushing && cover_open)
		. += "[base_icon_state]-water"

/obj/structure/toilet/atom_deconstruct(dissambled = TRUE)
	for(var/obj/toilet_item in cistern_items)
		toilet_item.forceMove(drop_location())
	if(buildstacktype)
		new buildstacktype(loc,buildstackamount)
	else
		for(var/datum/material/M as anything in custom_materials)
			new M.sheet_type(loc, FLOOR(custom_materials[M] / SHEET_MATERIAL_AMOUNT, 1))
	if(has_water_reclaimer)
		new /obj/item/stock_parts/water_recycler(drop_location())
	if(stuck_item)
		stuck_item.forceMove(drop_location())

/obj/structure/toilet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE

	add_fingerprint(user)
	if(cover_open && istype(tool, /obj/item/fish))
		if(fishes >= 3)
			to_chat(user, span_warning("There's too many fishes, flush them down first."))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("\The [tool] is stuck to your hand!"))
			return ITEM_INTERACT_BLOCKING
		var/obj/item/fish/the_fish = tool
		if(the_fish.status == FISH_DEAD)
			to_chat(user, span_warning("You place [tool] into [src], may it rest in peace."))
		else
			to_chat(user, span_notice("You place [tool] into [src], hopefully no one will miss it!"))
		LAZYADD(fishes, tool)
		return ITEM_INTERACT_SUCCESS

	if(cistern_open)
		if(istype(tool, /obj/item/stock_parts/water_recycler))
			if(has_water_reclaimer)
				to_chat(user, span_warning("[src] already has a water recycler installed."))
				return ITEM_INTERACT_BLOCKING

			playsound(src, 'sound/machines/click.ogg', 20, TRUE)
			qdel(tool)
			has_water_reclaimer = TRUE
			begin_reclamation()
			return ITEM_INTERACT_SUCCESS

		if(tool.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, span_warning("[tool] does not fit!"))
			return ITEM_INTERACT_BLOCKING
		if(w_items + tool.w_class > WEIGHT_CLASS_HUGE)
			to_chat(user, span_warning("The cistern is full!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("\The [tool] is stuck to your hand, you cannot put it in the cistern!"))
			return ITEM_INTERACT_BLOCKING
		LAZYADD(cistern_items, tool)
		w_items += tool.w_class
		to_chat(user, span_notice("You carefully place [tool] into the cistern."))
		return ITEM_INTERACT_SUCCESS

	if(!cover_open)
		return NONE

	if(!is_reagent_container(tool))
		if(tool.w_class > WEIGHT_CLASS_SMALL)
			return NONE

		if(stuck_item)
			to_chat(user, span_warning("There's already something blocking [src]'s drain pipe!"))
			return ITEM_INTERACT_BLOCKING

		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("\The [tool] is stuck to your hand!"))
			return ITEM_INTERACT_BLOCKING

		stuck_item = tool
		to_chat(user, span_notice("You drop [tool] into [src]'s bowl."))
		return ITEM_INTERACT_SUCCESS

	if(reagents.total_volume <= 0)
		to_chat(user, span_notice("\The [src] is dry."))
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/food/monkeycube))
		var/obj/item/food/monkeycube/cube = tool
		cube.Expand()
		return ITEM_INTERACT_SUCCESS

	var/obj/item/reagent_containers/container = tool
	if(!container.is_refillable())
		return NONE

	if(container.reagents.holder_full())
		to_chat(user, span_notice("\The [container] is full."))
		return ITEM_INTERACT_BLOCKING

	reagents.trans_to(container, container.amount_per_transfer_from_this, transferred_by = user)
	begin_reclamation()
	to_chat(user, span_notice("You fill [container] from [src]. Gross."))
	return ITEM_INTERACT_SUCCESS

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

/obj/structure/toilet/screwdriver_act(mob/living/user, obj/item/tool)
	if(!cistern_open)
		to_chat(user, span_warning("You need to open [src]'s cistern first!"))
		return ITEM_INTERACT_BLOCKING

	if(!has_water_reclaimer)
		to_chat(user, span_warning("\the [src] doesn't have a water reclaimer installed."))
		return ITEM_INTERACT_BLOCKING

	tool.play_tool_sound(src)
	has_water_reclaimer = FALSE
	new /obj/item/stock_parts/water_recycler(drop_location())
	to_chat(user, span_notice("You remove the water reclaimer from \the [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/toilet/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	deconstruct()
	return ITEM_INTERACT_SUCCESS

/obj/structure/toilet/plunger_act(obj/item/plunger/attacking_plunger, mob/living/user, reinforced)
	user.balloon_alert_to_viewers("furiously plunging...")
	if(!do_after(user, 3 SECONDS, target = src))
		return TRUE
	user.balloon_alert_to_viewers("finished plunging")
	reagents.expose(get_turf(src), TOUCH) //splash on the floor
	reagents.clear_reagents()
	begin_reclamation()
	if(stuck_item)
		stuck_item.forceMove(drop_location())
		stuck_item = null
	return TRUE

///Ends the flushing animation and updates overlays if necessary
/obj/structure/toilet/proc/end_flushing()
	flushing = FALSE
	if(cover_open && (dir & SOUTH))
		update_appearance(UPDATE_OVERLAYS)
	QDEL_LAZYLIST(fishes)

/obj/structure/toilet/proc/begin_reclamation()
	START_PROCESSING(SSplumbing, src)

/obj/structure/toilet/process(seconds_per_tick)
	// Water reclamation complete?
	if(!has_water_reclaimer || reagents.total_volume >= reagents.maximum_volume)
		return PROCESS_KILL
	reagents.add_reagent(reagent_id, reclaim_rate * seconds_per_tick)

/obj/structure/toilet/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	buildstacktype = null
	has_water_reclaimer = FALSE

/obj/structure/toilet/secret
	var/secret_type = null

/obj/structure/toilet/secret/Initialize(mapload)
	. = ..()
	if(secret_type)
		var/obj/item/secret = new secret_type(src)
		secret.desc += " It's a secret!"
		w_items += secret.w_class
		LAZYADD(cistern_items, secret)
