/**
 * # Slip behaviour component
 *
 * Add this component to an object to make it a slippery object, slippery objects make mobs that cross them fall over.
 * Items with this component that get picked up may give their parent mob the slip behaviour.
 *
 * Here is a simple example of adding the component behaviour to an object.area
 *
 *     AddComponent(/datum/component/slippery, 80, (NO_SLIP_WHEN_WALKING | SLIDE))
 *
 * This adds slippery behaviour to the parent atom, with a 80 decisecond (~8 seconds) knockdown
 * The lube flags control how the slip behaves, in this case, the mob wont slip if it's in walking mode (NO_SLIP_WHEN_WALKING)
 * and if they do slip, they will slide a few tiles (SLIDE)
 *
 *
 * This component has configurable behaviours, see the [Initialize proc for the argument listing][/datum/component/slippery/proc/Initialize].
 */
/datum/component/slippery
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// If the slip forces the crossing mob to drop held items.
	var/force_drop_items = FALSE
	/// How long the slip keeps the crossing mob knocked over (they can still crawl and use weapons) for.
	var/knockdown_time = 0
	/// How long the slip paralyzes (prevents the crossing mob doing anything) for.
	var/paralyze_time = 0
	/// Flags for how slippery the parent is. See [__DEFINES/mobs.dm]
	var/lube_flags
	/// Optional callback allowing you to define custom conditions for slipping
	var/datum/callback/can_slip_callback
	/// Optional call back that is called when a mob slips on this component
	var/datum/callback/on_slip_callback
	/// If parent is an item, this is the person currently holding/wearing the parent (or the parent if no one is holding it)
	var/mob/living/holder
	/// Whitelist of item slots the parent can be equipped in that make the holder slippery. If null or empty, it will always make the holder slippery.
	var/list/slot_whitelist = list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_BELT, ITEM_SLOT_NECK)
	///what we give to connect_loc by default, makes slippable mobs moving over us slip
	var/static/list/default_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(Slip),
	)

	///what we give to connect_loc if we're an item and get equipped by a mob. makes slippable mobs moving over our holder slip
	var/static/list/holder_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(Slip_on_wearer),
	)

	/// The connect_loc_behalf component for the holder_connections list.
	var/datum/weakref/holder_connect_loc_behalf

/**
 * Initialize the slippery component behaviour
 *
 * When applied to any atom in the game this will apply slipping behaviours to that atom
 *
 * Arguments:
 * * knockdown - Length of time the knockdown applies (Deciseconds)
 * * lube_flags - Controls the slip behaviour, they are listed starting [here][SLIDE]
 * * datum/callback/on_slip_callback - Callback to define further custom controls on when slipping is applied
 * * paralyze - length of time to paralyze the crossing mob for (Deciseconds)
 * * force_drop - should the crossing mob drop items in its hands or not
 * * slot_whitelist - flags controlling where on a mob this item can be equipped to make the parent mob slippery full list [here][ITEM_SLOT_OCLOTHING]
 * * datum/callback/on_slip_callback - Callback to add custom behaviours as the crossing mob is slipped
 */
/datum/component/slippery/Initialize(
	knockdown,
	lube_flags = NONE,
	datum/callback/on_slip_callback,
	paralyze,
	force_drop = FALSE,
	slot_whitelist,
	datum/callback/can_slip_callback,
)
	src.knockdown_time = max(knockdown, 0)
	src.paralyze_time = max(paralyze, 0)
	src.force_drop_items = force_drop
	src.lube_flags = lube_flags
	src.can_slip_callback = can_slip_callback
	src.on_slip_callback = on_slip_callback
	if(slot_whitelist)
		src.slot_whitelist = slot_whitelist

	add_connect_loc_behalf_to_parent()
	if(ismovable(parent))
		if(isitem(parent))
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
			RegisterSignal(parent, COMSIG_ITEM_APPLY_FANTASY_BONUSES, PROC_REF(apply_fantasy_bonuses))
			RegisterSignal(parent, COMSIG_ITEM_REMOVE_FANTASY_BONUSES, PROC_REF(remove_fantasy_bonuses))
	else
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(Slip))

/datum/component/slippery/Destroy(force)
	can_slip_callback = null
	on_slip_callback = null
	holder = null
	return ..()

/datum/component/slippery/proc/apply_fantasy_bonuses(obj/item/source, bonus)
	SIGNAL_HANDLER
	knockdown_time = source.modify_fantasy_variable("knockdown_time", knockdown_time, bonus)
	if(bonus >= 5)
		paralyze_time = source.modify_fantasy_variable("paralyze_time", paralyze_time, bonus)
		LAZYSET(source.fantasy_modifications, "lube_flags", lube_flags)
		lube_flags |= SLIDE
	if(bonus >= 10)
		lube_flags |= GALOSHES_DONT_HELP|SLIP_WHEN_CRAWLING

/datum/component/slippery/proc/remove_fantasy_bonuses(obj/item/source, bonus)
	SIGNAL_HANDLER
	knockdown_time = source.reset_fantasy_variable("knockdown_time", knockdown_time)
	paralyze_time = source.reset_fantasy_variable("paralyze_time", paralyze_time)
	var/previous_lube_flags = LAZYACCESS(source.fantasy_modifications, "lube_flags")
	LAZYREMOVE(source.fantasy_modifications, "lube_flags")
	if(!isnull(previous_lube_flags))
		lube_flags = previous_lube_flags

/datum/component/slippery/proc/add_connect_loc_behalf_to_parent()
	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, default_connections)

/datum/component/slippery/InheritComponent(
	datum/component/slippery/component,
	i_am_original,
	knockdown,
	lube_flags = NONE,
	datum/callback/on_slip_callback,
	paralyze,
	force_drop = FALSE,
	slot_whitelist,
	datum/callback/can_slip_callback,
)
	if(component)
		knockdown = component.knockdown_time
		lube_flags = component.lube_flags
		on_slip_callback = component.on_slip_callback
		can_slip_callback = component.on_slip_callback
		paralyze = component.paralyze_time
		force_drop = component.force_drop_items
		slot_whitelist = component.slot_whitelist

	src.knockdown_time = max(knockdown, 0)
	src.paralyze_time = max(paralyze, 0)
	src.force_drop_items = force_drop
	src.lube_flags = lube_flags
	src.on_slip_callback = on_slip_callback
	src.can_slip_callback = can_slip_callback
	if(slot_whitelist)
		src.slot_whitelist = slot_whitelist
/**
 * The proc that does the sliping. Invokes the slip callback we have set.
 *
 * Arguments
 * * source - the source of the signal
 * * arrived - the atom/movable that is being slipped.
 */
/datum/component/slippery/proc/Slip(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!isliving(arrived))
		return
	if(lube_flags & SLIPPERY_TURF)
		var/turf/turf = get_turf(source)
		if(HAS_TRAIT(turf, TRAIT_TURF_IGNORE_SLIPPERY))
			return
	var/mob/living/victim = arrived
	if(victim.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return
	if(can_slip_callback && !can_slip_callback.Invoke(holder, victim))
		return
	if(victim.slip(knockdown_time, parent, lube_flags, paralyze_time, force_drop_items))
		on_slip_callback?.Invoke(victim)

/**
 * Gets called when COMSIG_ITEM_EQUIPPED is sent to parent.
 * This proc register slip signals to the equipper.
 * If we have a slot whitelist, we only register the signals if the slot is valid (ex: clown PDA only slips in ID or belt slot).
 *
 * Arguments
 * * source - the source of the signal
 * * equipper - the mob we're equipping the slippery thing to
 * * slot - the slot we're equipping the slippery thing to on the equipper.
 */
/datum/component/slippery/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if((!LAZYLEN(slot_whitelist) || (slot in slot_whitelist)) && isliving(equipper))
		holder = equipper
		qdel(GetComponent(/datum/component/connect_loc_behalf))
		AddComponent(/datum/component/connect_loc_behalf, holder, holder_connections)
		RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(holder_deleted))

/**
 * Detects if the holder mob is deleted.
 * If our holder mob is the holder set in this component, we null it.
 *
 * Arguments:
 * * source - the source of the signal
 * * possible_holder - the mob being deleted.
 */
/datum/component/slippery/proc/holder_deleted(datum/source, datum/possible_holder)
	SIGNAL_HANDLER

	if(possible_holder == holder)
		holder = null

/**
 * Gets called when COMSIG_ITEM_DROPPED is sent to parent.
 * Makes our holder mob un-slippery.
 *
 * Arguments:
 * * source - the source of the signal
 * * user - the mob that was formerly wearing our slippery item.
 */
/datum/component/slippery/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_QDELETING)

	qdel(GetComponent(/datum/component/connect_loc_behalf))
	add_connect_loc_behalf_to_parent()

	holder = null

/**
 * The slip proc, but for equipped items.
 * Slips the person who crossed us if we're lying down and unbuckled.
 *
 * Arguments:
 * * source - the source of the signal
 * * arrived - the atom/movable that slipped on us.
 */
/datum/component/slippery/proc/Slip_on_wearer(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(holder.body_position == LYING_DOWN && !holder.buckled)
		Slip(source, arrived)

/datum/component/slippery/UnregisterFromParent()
	. = ..()
	qdel(GetComponent(/datum/component/connect_loc_behalf))
