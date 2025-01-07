#define MAXIMUM_EMP_WIRES 3

/proc/is_wire_tool(obj/item/I)
	if(!I)
		return

	if(I.tool_behaviour == TOOL_WIRECUTTER || I.tool_behaviour == TOOL_MULTITOOL)
		return TRUE
	if(isassembly(I))
		var/obj/item/assembly/A = I
		if(A.attachable)
			return TRUE

/atom/proc/attempt_wire_interaction(mob/user)
	if(!wires)
		return WIRE_INTERACTION_FAIL
	if(!user.CanReach(src))
		return WIRE_INTERACTION_FAIL
	wires.interact(user)
	return WIRE_INTERACTION_BLOCK

/datum/wires
	/// The holder (atom that contains these wires).
	var/atom/holder = null
	/// The holder's typepath (used for sanity checks to make sure the holder is the appropriate type for these wire sets).
	var/holder_type = null
	/// Key that enables wire assignments to be common across different holders. If null, will use the holder_type as a key.
	var/dictionary_key = null
	/// The display name for the wire set shown in station blueprints. Not shown in blueprints if randomize is TRUE or it's an item NT wouldn't know about (Explosives/Nuke). Also used in the hacking interface.
	var/proper_name = "Unknown"

	/// List of all wires.
	var/list/wires = list()
	/// List of cut wires.
	var/list/cut_wires = list() // List of wires that have been cut.
	/// Dictionary of colours to wire.
	var/list/colors = list()
	/// List of attached assemblies.
	var/list/assemblies = list()

	/// If every instance of these wires should be random. Prevents wires from showing up in station blueprints.
	var/randomize = FALSE

	/// Lazy assoc list of refs to mobs to refs to photos they have studied for wires
	var/list/studied_photos

/datum/wires/New(atom/holder)
	..()
	if(!istype(holder, holder_type))
		CRASH("Wire holder is not of the expected type!")

	src.holder = holder

	// If there is a dictionary key set, we'll want to use that. Otherwise, use the holder type.
	var/key = dictionary_key ? dictionary_key : holder_type

	RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(on_holder_qdel))
	if(randomize)
		randomize()
	else
		if(!GLOB.wire_color_directory[key])
			randomize()
			GLOB.wire_color_directory[key] = colors
			GLOB.wire_name_directory[key] = proper_name
		else
			colors = GLOB.wire_color_directory[key]

/datum/wires/Destroy()
	holder = null
	//properly clear refs to avoid harddels & other problems
	for(var/color in assemblies)
		var/obj/item/assembly/assembly = assemblies[color]
		assembly.holder = null
		assembly.connected = null
	LAZYCLEARLIST(assemblies)
	return ..()

/datum/wires/proc/add_duds(duds)
	while(duds)
		var/dud = WIRE_DUD_PREFIX + "[--duds]"
		if(dud in wires)
			continue
		wires += dud

///Called when holder is qdeleted for us to clean ourselves as not to leave any unlawful references.
/datum/wires/proc/on_holder_qdel(atom/source, force)
	SIGNAL_HANDLER

	qdel(src)

/datum/wires/proc/randomize()
	var/static/list/possible_colors = list(
	"blue",
	"brown",
	"crimson",
	"cyan",
	"gold",
	"green",
	"grey",
	"lime",
	"magenta",
	"orange",
	"pink",
	"purple",
	"red",
	"silver",
	"violet",
	"white",
	"yellow",
	)

	var/list/my_possible_colors = possible_colors.Copy()

	for(var/wire in shuffle(wires))
		colors[pick_n_take(my_possible_colors)] = wire

/datum/wires/proc/shuffle_wires()
	colors.Cut()
	randomize()

/datum/wires/proc/repair()
	for(var/wire in cut_wires)
		cut(wire) // I KNOW I KNOW OK

/datum/wires/proc/get_wire(color)
	return colors[color]

/datum/wires/proc/get_color_of_wire(wire_type)
	for(var/color in colors)
		var/other_type = colors[color]
		if(wire_type == other_type)
			return color

/datum/wires/proc/get_attached(color)
	if(assemblies[color])
		return assemblies[color]
	return null

/datum/wires/proc/is_attached(color)
	if(assemblies[color])
		return TRUE

/datum/wires/proc/is_cut(wire)
	return (wire in cut_wires)

/datum/wires/proc/is_color_cut(color)
	return is_cut(get_wire(color))

/datum/wires/proc/is_all_cut()
	if(cut_wires.len == wires.len)
		return TRUE

/datum/wires/proc/is_dud(wire)
	return findtext(wire, WIRE_DUD_PREFIX, 1, length(WIRE_DUD_PREFIX) + 1)

/datum/wires/proc/is_dud_color(color)
	return is_dud(get_wire(color))

/datum/wires/proc/cut(wire, source)
	if(is_cut(wire))
		cut_wires -= wire
		SEND_SIGNAL(src, COMSIG_MEND_WIRE(wire), wire)
		on_cut(wire, mend = TRUE, source = source)
	else
		cut_wires += wire
		SEND_SIGNAL(src, COMSIG_CUT_WIRE(wire), wire)
		on_cut(wire, mend = FALSE, source = source)

/datum/wires/proc/cut_color(color, source)
	cut(get_wire(color), source)

/datum/wires/proc/cut_random(source)
	cut(wires[rand(1, wires.len)], source)

/datum/wires/proc/cut_all(source)
	for(var/wire in wires)
		cut(wire, source)

/datum/wires/proc/pulse(wire, user, force=FALSE)
	if(!force && is_cut(wire))
		return
	on_pulse(wire, user)

/datum/wires/proc/pulse_color(color, mob/living/user, force=FALSE)
	pulse(get_wire(color), user, force)

/datum/wires/proc/pulse_assembly(obj/item/assembly/S)
	for(var/color in assemblies)
		if(S == assemblies[color])
			pulse_color(color, force=TRUE)
			return TRUE

/datum/wires/proc/attach_assembly(color, obj/item/assembly/S)
	if(S && istype(S) && S.attachable && !is_attached(color))
		assemblies[color] = S
		S.forceMove(holder)
		S.connected = src
		S.on_attach() // Notify assembly that it is attached
		return S

/datum/wires/proc/detach_assembly(color)
	var/obj/item/assembly/S = get_attached(color)
	if(S && istype(S))
		assemblies -= color
		S.on_detach()		// Notify the assembly.  This should remove the reference to our holder
		return S

/// Called from [/atom/proc/emp_act]
/datum/wires/proc/emp_pulse()
	var/list/possible_wires = shuffle(wires)
	var/remaining_pulses = MAXIMUM_EMP_WIRES

	for(var/wire in possible_wires)
		if(prob(33))
			pulse(wire)
			remaining_pulses--
			if(!remaining_pulses)
				break

// Overridable Procs
/datum/wires/proc/interactable(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if((SEND_SIGNAL(user, COMSIG_TRY_WIRES_INTERACT, holder) & COMPONENT_CANT_INTERACT_WIRES))
		return FALSE
	return TRUE

/datum/wires/proc/get_status()
	return list()

/datum/wires/proc/on_cut(wire, mend = FALSE, source = null)
	return

/datum/wires/proc/on_pulse(wire, user)
	return
// End Overridable Procs

/datum/wires/proc/interact(mob/user)
	if(!interactable(user))
		return
	ui_interact(user)
	for(var/A in assemblies)
		var/obj/item/I = assemblies[A]
		if(istype(I) && I.on_found(user))
			return

/**
 * Checks whether wire assignments should be revealed.
 *
 * Returns TRUE if the wires should be revealed, FALSE otherwise.
 * Currently checks for admin ghost AI, abductor multitool and blueprints.
 * Arguments:
 * * user - The mob to check when deciding whether to reveal wires.
 */
/datum/wires/proc/can_reveal_wires(mob/user)
	// Admin ghost can see a purpose of each wire.
	if(isAdminGhostAI(user))
		return TRUE

	// Same for anyone with an abductor multitool.
	if(user.is_holding_item_of_type(/obj/item/multitool/abductor))
		return TRUE

	// Station blueprints do that too, but only if the wires are not randomized.
	if(!randomize)
		if(user.is_holding_item_of_type(/obj/item/blueprints))
			return TRUE
		if(!isnull(user.mind))
			for(var/obj/item/photo/photo in user.held_items)
				if(LAZYACCESS(studied_photos, REF(user.mind)) == REF(photo))
					return TRUE

	return FALSE

/**
 * Whether the given wire should always be revealed.
 *
 * Intended to be overridden. Allows for forcing a wire's assignmenmt to always be revealed
 * in the hacking interface.
 * Arguments:
 * * color - Color string of the wire to check.
 */
/datum/wires/proc/always_reveal_wire(color)
	return FALSE

#define STUDY_INTERACTION_KEY "studying_photo"

/**
 * Attempts to study a photo for blueprints.
 */
/datum/wires/proc/try_study_photo(mob/user)
	if(randomize)
		return
	if(isnull(user.mind))
		return
	if(DOING_INTERACTION(user, STUDY_INTERACTION_KEY))
		return
	if(LAZYACCESS(studied_photos, REF(user.mind)))
		return
	for(var/obj/item/photo/photo in user.held_items)
		if(!photo.picture?.has_blueprints)
			continue

		var/study_length = 1 SECONDS * floor(min(photo.picture.psize_x, photo.picture.psize_y) / 32)
		if(study_length >= 4 SECONDS)
			to_chat(user, span_notice("<i>You squint [photo]... Hey, there's blueprints in the frame! Really wish the photo was zoomed in, though. \
				It's rather difficult to make out the wires.</i>"))
		else
			to_chat(user, span_notice("<i>You glance at [photo], looking for wires in the pictured blueprints.</i>"))

		if(do_after(user, study_length, holder, interaction_key = STUDY_INTERACTION_KEY, hidden = TRUE))
			LAZYSET(studied_photos, REF(user.mind), REF(photo))
		return

#undef STUDY_INTERACTION_KEY

/datum/wires/ui_host()
	return holder

/datum/wires/ui_status(mob/user, datum/ui_state/state)
	if(interactable(user))
		return ..()
	return UI_CLOSE

/datum/wires/ui_state(mob/user)
	return GLOB.physical_state

/datum/wires/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Wires", "[holder.name] Wires")
		ui.open()
	try_study_photo(user)

/datum/wires/ui_data(mob/user)
	var/list/data = list()
	var/list/payload = list()
	var/reveal_wires = can_reveal_wires(user)

	for(var/color in colors)
		payload.Add(list(list(
			"color" = color,
			"wire" = (((reveal_wires || always_reveal_wire(color)) && !is_dud_color(color)) ? get_wire(color) : null),
			"cut" = is_color_cut(color),
			"attached" = is_attached(color)
		)))
	data["wires"] = payload
	data["status"] = get_status()
	data["proper_name"] = (proper_name != "Unknown") ? proper_name : null
	return data

/datum/wires/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !interactable(usr))
		return
	var/target_wire = params["wire"]
	var/mob/living/L = usr
	var/obj/item/I
	switch(action)
		if("cut")
			I = L.is_holding_tool_quality(TOOL_WIRECUTTER)
			if(I || isAdminGhostAI(usr))
				if(I && holder)
					I.play_tool_sound(holder, 20)
				cut_color(target_wire, source = L)
				. = TRUE
			else
				to_chat(L, span_warning("You need wirecutters!"))
		if("pulse")
			I = L.is_holding_tool_quality(TOOL_MULTITOOL)
			if(I || isAdminGhostAI(usr))
				if(I && holder)
					I.play_tool_sound(holder, 20)
				pulse_color(target_wire, L)
				. = TRUE
			else
				to_chat(L, span_warning("You need a multitool!"))
		if("attach")
			if(is_attached(target_wire))
				I = detach_assembly(target_wire)
				if(I)
					L.put_in_hands(I)
					. = TRUE
			else
				I = L.get_active_held_item()
				if(isassembly(I))
					var/obj/item/assembly/A = I
					if(A.attachable)
						if(!L.temporarilyRemoveItemFromInventory(A))
							return
						if(!attach_assembly(target_wire, A))
							A.forceMove(L.drop_location())
						. = TRUE
					else
						to_chat(L, span_warning("You need an attachable assembly!"))

#undef MAXIMUM_EMP_WIRES
