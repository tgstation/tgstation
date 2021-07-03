/datum/component/rust
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/atom/parent_atom
	var/mutable_appearance/rust_overlay
	var/static/list/typecache_of_valid_types = list(
		/turf/closed/wall,
		/turf/closed/wall/r_wall,
		/turf/open/floor/plating,
	)

/turf/closed/wall/rust/New()
	var/atom/T = new /turf/closed/wall(src)
	T._AddComponent(list(/datum/component/rust))

/turf/closed/wall/r_wall/rust/New()
	var/atom/T = new /turf/closed/wall/r_wall(src)
	T._AddComponent(list(/datum/component/rust))

/turf/open/floor/plating/rust/New()
	var/atom/T = new /turf/open/floor/plating(src)
	T._AddComponent(list(/datum/component/rust))

/datum/component/rust/Initialize(...)
	. = ..()
	if(!(parent.type in typecache_of_valid_types) || !isatom(parent))
		return COMPONENT_INCOMPATIBLE
	parent_atom = parent
	if(!("rust" in icon_states(parent_atom.icon)) || parent_atom.GetExactComponent(/datum/component/rust))
		return COMPONENT_INCOMPATIBLE

	rust_overlay = mutable_appearance(parent_atom.icon, "rust")
	RegisterSignal(parent_atom, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/apply_rust_overlay)
	RegisterSignal(parent_atom, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), .proc/secondary_tool_act)
	RegisterSignal(parent_atom, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_RUSTSCRAPER), .proc/secondary_tool_act)
	RegisterSignal(parent_atom, COMSIG_PARENT_PREQDELETED, .proc/parent_del)
	RegisterSignal(parent_atom, COMSIG_PARENT_EXAMINE, .proc/handle_examine)

/datum/component/rust/proc/handle_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += "It's very rusty... Maybe you could <b><u>burn or scrape</u></b> it clean?"

/datum/component/rust/proc/apply_rust_overlay(atom/parent_atom, list/ret)
	SIGNAL_HANDLER
	ret |= rust_overlay

/datum/component/rust/proc/parent_del()
	qdel(src)

/datum/component/rust/Destroy()
	if(parent_atom)
		UnregisterSignal(parent_atom, COMSIG_ATOM_UPDATE_OVERLAYS)
		UnregisterSignal(parent_atom, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER))
		UnregisterSignal(parent_atom, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_RUSTSCRAPER))
		UnregisterSignal(parent_atom, COMSIG_PARENT_PREQDELETED)
		parent_atom.update_icon(UPDATE_OVERLAYS)
		rust_overlay = null
		parent_atom = null
	return ..()

/datum/component/rust/proc/handle_tool_use(atom/source, mob/user, obj/item/item)
	if(item.tool_behaviour == TOOL_WELDER)
		var/obj/item/weldingtool/WT = item
		if(WT.isOn() && WT.use(5))
			to_chat(user, span_notice("You begin to burn off the rust of [parent_atom]."))
			if(!do_after(user, 5 SECONDS * item.toolspeed, parent_atom))
				to_chat(user, span_notice("You change your mind."))
				return
			to_chat(user, span_notice("You burn off the rust of [parent_atom]."))
			qdel(src)
			return
	if(item.tool_behaviour == TOOL_RUSTSCRAPER)
		to_chat(user, span_notice("You begin to scrape the rust off of [parent_atom]."))
		if(!do_after(user, 2 SECONDS * item.toolspeed, parent_atom))
			to_chat(user, span_notice("You change your mind."))
			return
		to_chat(user, span_notice("You scrape the rust off of [parent_atom]."))
		qdel(src)
		return

/datum/component/rust/proc/secondary_tool_act(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/handle_tool_use, source, user, item)
	return COMPONENT_BLOCK_TOOL_ATTACK
