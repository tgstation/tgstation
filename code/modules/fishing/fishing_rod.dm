#define FISHING_ROD_REEL_CAST_RANGE 2

/obj/item/fishing_rod
	name = "fishing rod"
	desc = "You can fish with this."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_rod"
	lefthand_file = 'icons/mob/inhands/equipment/fishing_rod_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/fishing_rod_righthand.dmi'
	inhand_icon_state = "rod"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 8
	w_class = WEIGHT_CLASS_HUGE

	/// How far can you cast this
	var/cast_range = 3
	/// Fishing minigame difficulty modifier (additive)
	var/difficulty_modifier = 0
	/// Explaination of rod functionality shown in the ui
	var/ui_description = "A classic fishing rod, with no special qualities."

	var/obj/item/bait
	var/obj/item/fishing_line/line = /obj/item/fishing_line
	var/obj/item/fishing_hook/hook = /obj/item/fishing_hook

	/// Currently hooked item for item reeling
	var/atom/movable/currently_hooked

	/// Fishing line visual for the hooked item
	var/datum/beam/fishing_line/fishing_line

	/// Are we currently casting
	var/casting = FALSE

	/// The default color for the reel overlay if no line is equipped.
	var/default_line_color = "gray"

	///should there be a fishing line?
	var/display_fishing_line = TRUE

	///The name of the icon state of the reel overlay
	var/reel_overlay = "reel_overlay"

	///Prevents spamming the line casting, without affecting the player's click cooldown.
	COOLDOWN_DECLARE(casting_cd)

/obj/item/fishing_rod/Initialize(mapload)
	. = ..()
	register_context()
	register_item_context()

	if(ispath(bait))
		set_slot(new bait(src), ROD_SLOT_BAIT)
	if(ispath(hook))
		set_slot(new hook(src), ROD_SLOT_HOOK)
	if(ispath(line))
		set_slot(new line(src), ROD_SLOT_LINE)

	update_appearance()

/obj/item/fishing_rod/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(src == held_item)
		if(currently_hooked)
			context[SCREENTIP_CONTEXT_LMB] = "Reel in"
		context[SCREENTIP_CONTEXT_RMB] = "Modify"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/item/fishing_rod/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	. = ..()
	if(currently_hooked)
		context[SCREENTIP_CONTEXT_LMB] = "Reel in"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/item/fishing_rod/examine(mob/user)
	. = ..()
	var/list/equipped_stuff = list()
	if(line)
		equipped_stuff += "[icon2html(line, user)] <b>[line.name]</b>"
	if(hook)
		equipped_stuff += "[icon2html(hook, user)] <b>[hook.name]</b>"
	if(bait)
		equipped_stuff += "[icon2html(bait, user)] <b>[bait]</b> as bait."
	if(length(equipped_stuff))
		. += span_notice("It has \a [english_list(equipped_stuff)] equipped.")
	if(!bait)
		. += span_warning("It doesn't have a bait attached to it. Fishing will be more tedious!")

/**
 * Is there a reason why this fishing rod couldn't fish in target_fish_source?
 * If so, return the denial reason as a string, otherwise return `null`.
 *
 * Arguments:
 * * target_fish_source - The /datum/fish_source we're trying to fish in.
 */
/obj/item/fishing_rod/proc/reason_we_cant_fish(datum/fish_source/target_fish_source)
	return hook?.reason_we_cant_fish(target_fish_source)

/obj/item/fishing_rod/proc/consume_bait(atom/movable/reward)
	// catching things that aren't fish or alive mobs doesn't consume baits.
	if(isnull(reward) || isnull(bait))
		return
	if(isliving(reward))
		var/mob/living/caught_mob = reward
		if(caught_mob.stat == DEAD)
			return
	else if(!isfish(reward))
		return
	QDEL_NULL(bait)
	update_icon()

/obj/item/fishing_rod/interact(mob/user)
	if(currently_hooked)
		reel(user)

/obj/item/fishing_rod/proc/reel(mob/user)
	if(DOING_INTERACTION_WITH_TARGET(user, currently_hooked))
		return
	playsound(src, SFX_REEL, 50, vary = FALSE)
	if(!do_after(user, 0.8 SECONDS, currently_hooked, timed_action_flags = IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(fishing_line_check))))
		return
	if(currently_hooked.anchored || currently_hooked.move_resist >= MOVE_FORCE_STRONG)
		balloon_alert(user, "[currently_hooked.p_they()] won't budge!")
		return
	//Try to move it 'till it's under the user's feet, then try to pick it up
	if(isitem(currently_hooked))
		step_towards(currently_hooked, get_turf(src))
		if(currently_hooked.loc == user.loc)
			user.put_in_inactive_hand(currently_hooked)
			QDEL_NULL(fishing_line)
	//Not an item, so just delete the line if it's adjacent to the user.
	else if(get_dist(currently_hooked,get_turf(src)) > 1)
		step_towards(currently_hooked, get_turf(src))
		if(get_dist(currently_hooked,get_turf(src)) <= 1)
			QDEL_NULL(fishing_line)
	else
		QDEL_NULL(fishing_line)

/obj/item/fishing_rod/proc/fishing_line_check()
	return !QDELETED(fishing_line)

/obj/item/fishing_rod/attack_self_secondary(mob/user, modifiers)
	. = ..()
	ui_interact(user)

/// Generates the fishing line visual from the current user to the target and updates inhands
/obj/item/fishing_rod/proc/create_fishing_line(atom/movable/target, target_py = null)
	if(!display_fishing_line)
		return null
	var/mob/user = loc
	if(!istype(user))
		return null
	if(fishing_line)
		QDEL_NULL(fishing_line)
	var/beam_color = line?.line_color || default_line_color
	fishing_line = new(user, target, icon_state = "fishing_line", beam_color = beam_color,  emissive = FALSE, override_target_pixel_y = target_py)
	fishing_line.lefthand = user.get_held_index_of_item(src) % 2 == 1
	RegisterSignal(fishing_line, COMSIG_BEAM_BEFORE_DRAW, PROC_REF(check_los))
	RegisterSignal(fishing_line, COMSIG_QDELETING, PROC_REF(clear_line))
	INVOKE_ASYNC(fishing_line, TYPE_PROC_REF(/datum/beam/, Start))
	user.update_held_items()
	return fishing_line

/obj/item/fishing_rod/proc/clear_line(datum/source)
	SIGNAL_HANDLER
	if(ismob(loc))
		var/mob/user = loc
		user.update_held_items()
	fishing_line = null
	currently_hooked = null

/obj/item/fishing_rod/dropped(mob/user, silent)
	. = ..()
	QDEL_NULL(fishing_line)

/// Hooks the item
/obj/item/fishing_rod/proc/hook_item(mob/user, atom/target_atom)
	if(currently_hooked)
		return
	if(!hook.can_be_hooked(target_atom))
		return
	currently_hooked = target_atom
	create_fishing_line(target_atom)
	hook.hook_attached(target_atom, src)
	SEND_SIGNAL(src, COMSIG_FISHING_ROD_HOOKED_ITEM, target_atom, user)

// Checks fishing line for interruptions and range
/obj/item/fishing_rod/proc/check_los(datum/beam/source)
	SIGNAL_HANDLER
	. = NONE

	if(!CheckToolReach(src, source.target, cast_range))
		qdel(source)
		return BEAM_CANCEL_DRAW

/obj/item/fishing_rod/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/fishing_rod/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!hook)
		balloon_alert(user, "install a hook first!")
		return ITEM_INTERACT_BLOCKING

	// Reel in if able
	if(currently_hooked)
		reel(user)
		return ITEM_INTERACT_BLOCKING

	SEND_SIGNAL(interacting_with, COMSIG_PRE_FISHING)
	cast_line(interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/// If the line to whatever that is is clear and we're not already busy, try fishing in it
/obj/item/fishing_rod/proc/cast_line(atom/target, mob/user)
	if(casting || currently_hooked)
		return
	if(!hook)
		balloon_alert(user, "install a hook first!")
		return
	if(!CheckToolReach(user, target, cast_range))
		balloon_alert(user, "cannot reach there!")
		return
	if(!COOLDOWN_FINISHED(src, casting_cd))
		return
	casting = TRUE
	var/obj/projectile/fishing_cast/cast_projectile = new(get_turf(src))
	cast_projectile.range = cast_range
	cast_projectile.owner = src
	cast_projectile.original = target
	cast_projectile.fired_from = src
	cast_projectile.firer = user
	cast_projectile.impacted = list(WEAKREF(user) = TRUE)
	cast_projectile.preparePixelProjectile(target, user)
	cast_projectile.fire()
	COOLDOWN_START(src, casting_cd, 1 SECONDS)

/// Called by hook projectile when hitting things
/obj/item/fishing_rod/proc/hook_hit(atom/atom_hit_by_hook_projectile)
	var/mob/user = loc
	if(!hook || !istype(user))
		return
	if(SEND_SIGNAL(atom_hit_by_hook_projectile, COMSIG_FISHING_ROD_CAST, src, user) & FISHING_ROD_CAST_HANDLED)
		return
	/// If you can't fish in it, try hooking it
	hook_item(user, atom_hit_by_hook_projectile)

/obj/item/fishing_rod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FishingRod", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/fishing_rod/update_overlays()
	. = ..()
	. += get_fishing_overlays()

/obj/item/fishing_rod/proc/get_fishing_overlays()
	. = list()
	var/line_color = line?.line_color || default_line_color
	/// Line part by the rod, always visible
	var/mutable_appearance/reel_appearance = mutable_appearance(icon, reel_overlay)
	reel_appearance.color = line_color
	. += reel_appearance

	// Line & hook is also visible when only bait is equipped but it uses default appearances then
	if(hook || bait)
		var/mutable_appearance/line_overlay = mutable_appearance(icon, "line_overlay")
		line_overlay.color = line_color
		. += line_overlay
		. += hook?.rod_overlay_icon_state || "hook_overlay"

	if(bait)
		var/bait_state = "worm_overlay" //default to worm overlay for anything without specific one
		if(istype(bait, /obj/item/food/bait))
			var/obj/item/food/bait/real_bait = bait
			bait_state = real_bait.rod_overlay_icon_state
		. += bait_state

/obj/item/fishing_rod/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	. += get_fishing_worn_overlays(standing, isinhands, icon_file)

/obj/item/fishing_rod/proc/get_fishing_worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = list()
	var/line_color = line?.line_color || default_line_color
	var/mutable_appearance/reel_overlay = mutable_appearance(icon_file, "reel_overlay")
	reel_overlay.appearance_flags |= RESET_COLOR
	reel_overlay.color = line_color
	. += reel_overlay
	/// if we don't have anything hooked show the dangling hook & line
	if(isinhands && !fishing_line)
		var/mutable_appearance/line_overlay = mutable_appearance(icon_file, "line_overlay")
		line_overlay.appearance_flags |= RESET_COLOR
		line_overlay.color = line_color
		. += line_overlay
		. += mutable_appearance(icon_file, "hook_overlay")

/obj/item/fishing_rod/attackby(obj/item/attacking_item, mob/user, params)
	if(slot_check(attacking_item,ROD_SLOT_LINE))
		use_slot(ROD_SLOT_LINE, user, attacking_item)
		SStgui.update_uis(src)
		return TRUE
	else if(slot_check(attacking_item,ROD_SLOT_HOOK))
		use_slot(ROD_SLOT_HOOK, user, attacking_item)
		SStgui.update_uis(src)
		return TRUE
	else if(slot_check(attacking_item,ROD_SLOT_BAIT))
		use_slot(ROD_SLOT_BAIT, user, attacking_item)
		SStgui.update_uis(src)
		return TRUE
	else if(istype(attacking_item, /obj/item/bait_can)) //Quicker filling from bait can
		var/obj/item/bait_can/can = attacking_item
		var/bait = can.retrieve_bait(user)
		if(bait)
			use_slot(ROD_SLOT_BAIT, user, bait)
			SStgui.update_uis(src)
		return TRUE
	. = ..()

/obj/item/fishing_rod/ui_data(mob/user)
	. = ..()
	var/list/data = list()

	data["bait_name"] = format_text(bait?.name)
	data["bait_icon"] = bait != null ? icon2base64(icon(bait.icon, bait.icon_state)) : null

	data["line_name"] = format_text(line?.name)
	data["line_icon"] = line != null ? icon2base64(icon(line.icon, line.icon_state)) : null

	data["hook_name"] = format_text(hook?.name)
	data["hook_icon"] = hook != null ? icon2base64(icon(hook.icon, hook.icon_state)) : null

	data["busy"] = fishing_line

	data["description"] = ui_description

	return data

/// Checks if the item fits the slot
/obj/item/fishing_rod/proc/slot_check(obj/item/item,slot)
	if(!istype(item))
		return FALSE
	switch(slot)
		if(ROD_SLOT_HOOK)
			if(!istype(item,/obj/item/fishing_hook))
				return FALSE
		if(ROD_SLOT_LINE)
			if(!istype(item,/obj/item/fishing_line))
				return FALSE
		if(ROD_SLOT_BAIT)
			if(!HAS_TRAIT(item, TRAIT_FISHING_BAIT))
				return FALSE
	return TRUE

/obj/item/fishing_rod/ui_act(action, list/params)
	. = ..()
	if(.)
		return .
	var/mob/user = usr
	switch(action)
		if("slot_action")
			// Simple click with empty hand to remove, click with item to insert/switch
			var/obj/item/held_item = user.get_active_held_item()
			use_slot(params["slot"], user, held_item == src ? null : held_item)
			return TRUE

/// Ideally this will be replaced with generic slotted storage datum + display
/obj/item/fishing_rod/proc/use_slot(slot, mob/user, obj/item/new_item)
	var/obj/item/current_item
	switch(slot)
		if(ROD_SLOT_BAIT)
			current_item = bait
		if(ROD_SLOT_HOOK)
			current_item = hook
		if(ROD_SLOT_LINE)
			current_item = line
	if(!new_item && !current_item)
		return
	// Trying to remove the item
	if(!new_item && current_item)
		user.put_in_hands(current_item)
		balloon_alert(user, "[slot] removed")
	// Trying to insert item into empty slot
	else if(new_item && !current_item)
		if(!slot_check(new_item, slot))
			return
		if(user.transferItemToLoc(new_item,src))
			set_slot(new_item, slot)
			balloon_alert(user, "[slot] installed")
	/// Trying to swap item
	else if(new_item && current_item)
		if(!slot_check(new_item,slot))
			return
		if(user.transferItemToLoc(new_item,src))
			switch(slot)
				if(ROD_SLOT_BAIT)
					bait = new_item
				if(ROD_SLOT_HOOK)
					hook = new_item
				if(ROD_SLOT_LINE)
					line = new_item
		user.put_in_hands(current_item)
		balloon_alert(user, "[slot] swapped")

	if(new_item)
		SEND_SIGNAL(new_item, COMSIG_FISHING_EQUIPMENT_SLOTTED, src)

	update_icon()
	playsound(src, 'sound/items/click.ogg', 50, TRUE)

///assign an item to the given slot and its standard effects, while Exited() should handle unsetting the slot.
/obj/item/fishing_rod/proc/set_slot(obj/item/equipment, slot)
	switch(slot)
		if(ROD_SLOT_BAIT)
			bait = equipment
		if(ROD_SLOT_HOOK)
			hook = equipment
		if(ROD_SLOT_LINE)
			line = equipment
			cast_range += FISHING_ROD_REEL_CAST_RANGE

/obj/item/fishing_rod/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == bait)
		bait = null
	if(gone == line)
		cast_range -= FISHING_ROD_REEL_CAST_RANGE
		line = null
	if(gone == hook)
		QDEL_NULL(fishing_line)
		hook = null

///Found in the fishing toolbox (the hook and line are separate items)
/obj/item/fishing_rod/unslotted
	hook = null
	line = null

/obj/item/fishing_rod/bone
	name = "bone fishing rod"
	desc = "A humble rod, made with whatever happened to be on hand."
	icon_state = "fishing_rod_bone"
	reel_overlay = "reel_bone"
	default_line_color = "red"
	line = null //sinew line (usable to fish in lava) not included
	hook = /obj/item/fishing_hook/bone

/obj/item/fishing_rod/telescopic
	name = "telescopic fishing rod"
	icon_state = "fishing_rod_telescopic"
	desc = "A lightweight, ergonomic, easy to store telescopic fishing rod. "
	inhand_icon_state = null
	force = 0
	w_class = WEIGHT_CLASS_NORMAL
	ui_description = "A collapsible fishing rod that can fit within a backpack."
	reel_overlay = "reel_telescopic"
	///The force of the item when extended.
	var/active_force = 8

/obj/item/fishing_rod/telescopic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, force_on = 8, hitsound_on = hitsound, w_class_on = WEIGHT_CLASS_HUGE, clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_PRE_TRANSFORM, PROC_REF(pre_transform))
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/fishing_rod/telescopic/reason_we_cant_fish(datum/fish_source/target_fish_source)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return "You need to extend your fishing rod before you can cast the line."
	return ..()

/obj/item/fishing_rod/telescopic/cast_line(atom/target, mob/user, proximity_flag)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		if(!proximity_flag)
			balloon_alert(user, "extend the rod first!")
		return
	return ..()

/obj/item/fishing_rod/telescopic/get_fishing_overlays()
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return list()
	return ..()

/obj/item/fishing_rod/telescopic/get_fishing_worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return list()
	return ..()

///Stops the fishing rod from being collapsed while fishing.
/obj/item/fishing_rod/telescopic/proc/pre_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	if(HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return
	//the fishing minigame uses the attack_self signal to let the user end it early without having to drop the rod.
	if(HAS_TRAIT(user, TRAIT_GONE_FISHING))
		return COMPONENT_BLOCK_TRANSFORM

///Gives feedback to the user, makes it show up inhand, toggles whether it can be used for fishing.
/obj/item/fishing_rod/telescopic/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	inhand_icon_state = active ? "rod" : null // When inactive, there is no inhand icon_state.
	if(user)
		balloon_alert(user, active ? "extended" : "collapsed")
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
	update_appearance(UPDATE_OVERLAYS)
	QDEL_NULL(fishing_line)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/fishing_rod/telescopic/master
	name = "master fishing rod"
	desc = "The mythical rod of a lost fisher king. Said to be imbued with un-paralleled fishing power. There's writing on the back of the pole. \"中国航天制造\""
	difficulty_modifier = -10
	ui_description = "This rod makes fishing easy even for an absolute beginner."
	icon_state = "fishing_rod_master"
	reel_overlay = "reel_master"
	active_force = 13 //It's that sturdy
	cast_range = 5
	line = /obj/item/fishing_line/bouncy
	hook = /obj/item/fishing_hook/weighted

/obj/item/fishing_rod/tech
	name = "advanced fishing rod"
	desc = "An embedded universal constructor along with micro-fusion generator makes this marvel of technology never run out of bait. Interstellar treaties prevent using it outside of recreational fishing. And you can fish with this. "
	ui_description = "This rod has an infinite supply of synth-bait. Also doubles as an Experi-Scanner for fish."
	icon_state = "fishing_rod_science"
	reel_overlay = "reel_science"
	bait = /obj/item/food/bait/doughball/synthetic

/obj/item/fishing_rod/tech/Initialize(mapload)
	. = ..()

	var/static/list/fishing_signals = list(
		COMSIG_FISHING_ROD_HOOKED_ITEM = TYPE_PROC_REF(/datum/component/experiment_handler, try_run_handheld_experiment),
		COMSIG_FISHING_ROD_CAUGHT_FISH = TYPE_PROC_REF(/datum/component/experiment_handler, try_run_handheld_experiment),
		COMSIG_ITEM_PRE_ATTACK = TYPE_PROC_REF(/datum/component/experiment_handler, try_run_handheld_experiment),
		COMSIG_ITEM_AFTERATTACK = TYPE_PROC_REF(/datum/component/experiment_handler, ignored_handheld_experiment_attempt),
	)
	AddComponent(/datum/component/experiment_handler, \
		config_mode = EXPERIMENT_CONFIG_ALTCLICK, \
		allowed_experiments = list(/datum/experiment/scanning/fish), \
		config_flags = EXPERIMENT_CONFIG_SILENT_FAIL|EXPERIMENT_CONFIG_IMMEDIATE_ACTION, \
		experiment_signals = fishing_signals, \
	)

/obj/item/fishing_rod/tech/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-Click</b> to access the Experiment Configuration UI")

/obj/item/fishing_rod/tech/consume_bait(atom/movable/reward)
	return

/obj/item/fishing_rod/tech/use_slot(slot, mob/user, obj/item/new_item)
	if(slot == ROD_SLOT_BAIT)
		return
	return ..()

#undef ROD_SLOT_BAIT
#undef ROD_SLOT_LINE
#undef ROD_SLOT_HOOK

/obj/projectile/fishing_cast
	name = "fishing hook"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "hook_projectile"
	damage = 0
	range = 5
	suppressed =  SUPPRESSED_VERY
	can_hit_turfs = TRUE

	var/obj/item/fishing_rod/owner
	var/datum/beam/our_line

/obj/projectile/fishing_cast/fire(angle, atom/direct_target)
	if(owner.hook)
		icon_state = owner.hook.icon_state
		transform = transform.Scale(1, -1)
	return ..()

/obj/projectile/fishing_cast/Impact(atom/hit_atom)
	. = ..()
	owner.hook_hit(hit_atom)
	qdel(src)

/obj/projectile/fishing_cast/fire(angle, atom/direct_target)
	. = ..()
	our_line = owner.create_fishing_line(src)

/obj/projectile/fishing_cast/Destroy()
	. = ..()
	QDEL_NULL(our_line)
	owner?.casting = FALSE



/datum/beam/fishing_line
	// Is the fishing rod held in left side hand
	var/lefthand = FALSE

	// Make these inline with final sprites
	var/righthand_s_px = 13
	var/righthand_s_py = 16

	var/righthand_e_px = 18
	var/righthand_e_py = 16

	var/righthand_w_px = -20
	var/righthand_w_py = 18

	var/righthand_n_px = -14
	var/righthand_n_py = 16

	var/lefthand_s_px = -13
	var/lefthand_s_py = 15

	var/lefthand_e_px = 24
	var/lefthand_e_py = 18

	var/lefthand_w_px = -17
	var/lefthand_w_py = 16

	var/lefthand_n_px = 13
	var/lefthand_n_py = 15

/datum/beam/fishing_line/Start()
	update_offsets(origin.dir)
	. = ..()
	RegisterSignal(origin, COMSIG_ATOM_DIR_CHANGE, PROC_REF(handle_dir_change))

/datum/beam/fishing_line/Destroy()
	UnregisterSignal(origin, COMSIG_ATOM_DIR_CHANGE)
	. = ..()

/datum/beam/fishing_line/proc/handle_dir_change(atom/movable/source, olddir, newdir)
	SIGNAL_HANDLER
	update_offsets(newdir)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/beam/, redrawing))

/datum/beam/fishing_line/proc/update_offsets(user_dir)
	switch(user_dir)
		if(SOUTH)
			override_origin_pixel_x = lefthand ? lefthand_s_px : righthand_s_px
			override_origin_pixel_y = lefthand ? lefthand_s_py : righthand_s_py
		if(EAST)
			override_origin_pixel_x = lefthand ? lefthand_e_px : righthand_e_px
			override_origin_pixel_y = lefthand ? lefthand_e_py : righthand_e_py
		if(WEST)
			override_origin_pixel_x = lefthand ? lefthand_w_px : righthand_w_px
			override_origin_pixel_y = lefthand ? lefthand_w_py : righthand_w_py
		if(NORTH)
			override_origin_pixel_x = lefthand ? lefthand_n_px : righthand_n_px
			override_origin_pixel_y = lefthand ? lefthand_n_py : righthand_n_py

#undef FISHING_ROD_REEL_CAST_RANGE
