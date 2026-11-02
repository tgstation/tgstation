/// Ratwood's sword rack (structures/fireaxe.dm): a case on the wall holding an heirloom blade behind its door. A hand opens and
/// closes the door, takes the blade out of the open case and puts it back; the artificer's linker locks and unlocks the door,
/// and a locked case does not open. While open it takes no harm. Ratwood's base rack shares its path with TG's fire axe
/// cabinet, so the racks here are its /south and /unforgotten branches, which get this as a component.

/obj/structure/fireaxecabinet/south
	/// The blade it holds from the start (Ratwood heirloom), by path text: the port has not brought the heirloom swords yet,
	/// and an empty rack waits for them without a code change.
	var/rockhill_heirloom = "/obj/item/rogueweapon/sword/long/heirloom"

/obj/structure/fireaxecabinet/south/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	AddComponent(/datum/component/rockhill_sword_rack, text2path(rockhill_heirloom), "axe")

/obj/structure/fireaxecabinet/unforgotten
	var/rockhill_heirloom = "/obj/item/rogueweapon/greatsword/bsword/psy/unforgotten"

/obj/structure/fireaxecabinet/unforgotten/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	AddComponent(/datum/component/rockhill_sword_rack, text2path(rockhill_heirloom), "axe_forgotten", TRUE)

/datum/component/rockhill_sword_rack
	/// The blade in the case, if any.
	var/obj/item/heirloom
	/// The only kind of blade the case takes back.
	var/heirloom_type
	/// The state of the blade's overlay on the case.
	var/blade_state
	/// The unforgotten mantle takes on its blade's description.
	var/take_desc = FALSE
	var/open = TRUE
	var/locked = FALSE

/datum/component/rockhill_sword_rack/Initialize(heirloom_type, blade_state, take_desc = FALSE)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	src.heirloom_type = heirloom_type
	src.blade_state = blade_state
	src.take_desc = take_desc
	if(ispath(heirloom_type, /obj/item))
		var/obj/structure/rack = parent
		set_heirloom(new heirloom_type(rack))

/datum/component/rockhill_sword_rack/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(on_take_damage))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	var/atom/rack = parent
	rack.update_appearance(UPDATE_OVERLAYS)

/datum/component/rockhill_sword_rack/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ITEM_INTERACTION, COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ATOM_TAKE_DAMAGE, COMSIG_ATOM_EXITED))

/datum/component/rockhill_sword_rack/Destroy(force)
	heirloom = null
	return ..()

/datum/component/rockhill_sword_rack/proc/set_heirloom(obj/item/blade)
	heirloom = blade
	var/obj/structure/rack = parent
	if(take_desc)
		rack.desc = blade ? blade.desc : initial(rack.desc)
	rack.update_appearance(UPDATE_OVERLAYS)

/// The blade left the case some other way: it is no longer held.
/datum/component/rockhill_sword_rack/proc/on_exited(atom/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(gone == heirloom)
		set_heirloom(null)

/datum/component/rockhill_sword_rack/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	if(heirloom)
		overlays += mutable_appearance(source.icon, blade_state)

/// Ratwood take_damage(): an open case takes no harm.
/datum/component/rockhill_sword_rack/proc/on_take_damage(atom/source)
	SIGNAL_HANDLER
	if(open)
		return COMPONENT_NO_TAKE_DAMAGE

/// Ratwood attack_hand(): the blade comes out of an open case; otherwise the door opens or closes, unless locked.
/datum/component/rockhill_sword_rack/proc/on_attack_hand(atom/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(user))
		return
	if(open && heirloom)
		var/obj/item/blade = heirloom
		set_heirloom(null)
		if(!user.put_in_hands(blade))
			blade.forceMove(source.drop_location())
		to_chat(user, span_notice("I take the sword from the [source.name]."))
		source.add_fingerprint(user)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(locked)
		to_chat(user, span_warning("The [source.name] won't budge!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	open = !open
	source.update_appearance(UPDATE_OVERLAYS)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Ratwood attackby(): the linker sets the lock; into an open case its own blade goes back, anything else closes the door.
/datum/component/rockhill_sword_rack/proc/on_item_interaction(atom/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(tool.tool_behaviour == TOOL_MULTITOOL || istype(tool, /obj/item/contraption/linker))
		INVOKE_ASYNC(src, PROC_REF(toggle_lock), user)
		return ITEM_INTERACT_SUCCESS
	if(!open)
		return NONE
	if(heirloom_type && istype(tool, heirloom_type) && !heirloom)
		if(HAS_TRAIT(tool, TRAIT_WIELDED))
			to_chat(user, span_warning("Unwield the [tool.name] first."))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, source))
			return ITEM_INTERACT_BLOCKING
		set_heirloom(tool)
		to_chat(user, span_notice("I place the [tool.name] back in the [source.name]."))
		return ITEM_INTERACT_SUCCESS
	open = FALSE
	source.update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

/// Ratwood toggle_lock(): a moment's work on the lock.
/datum/component/rockhill_sword_rack/proc/toggle_lock(mob/living/user)
	var/atom/source = parent
	to_chat(user, span_notice("Resetting circuitry..."))
	if(!do_after(user, rogue_value("sword_rack_lock_time"), target = source) || QDELETED(src))
		return
	to_chat(user, span_notice("I [locked ? "disable" : "re-enable"] the locking modules."))
	locked = !locked
	source.update_appearance(UPDATE_OVERLAYS)
