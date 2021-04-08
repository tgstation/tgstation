/// Anything with this component will provide the reagents inside the
/// item to the user when it is equipped.
/datum/component/chewable
	/// A bitfield of valid slots. If this is not provided, then it will
	/// use the `slot_flags` of the item.
	var/slots_to_check

	/// The time left before it's deleted.
	var/lifetime = 6 MINUTES

	/// The interval to give reagents while equipped.
	var/interval = 10 SECONDS

	/// The cooldown between chews (when reagents are processed).
	COOLDOWN_DECLARE(chew_cooldown)

/datum/component/chewable/Initialize(lifetime, interval, slots_to_check)
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent

	if (lifetime)
		src.lifetime = lifetime

	if (interval)
		src.interval = interval

	src.slots_to_check = slots_to_check || item_parent.slot_flags

/datum/component/chewable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equipped)

/datum/component/chewable/UnregisterFromParent()
	STOP_PROCESSING(SSdcs, src)

	UnregisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))

/datum/component/chewable/process(delta_time)
	var/obj/item/item_parent = parent

	var/mob/chewer = item_parent.loc
	if (!istype(chewer))
		return PROCESS_KILL

	if (lifetime <= 0)
		qdel(parent)
		return PROCESS_KILL

	lifetime -= delta_time * 10

	if (!COOLDOWN_FINISHED(src, chew_cooldown))
		return

	if (!item_parent.reagents?.total_volume)
		return

	handle_reagents()
	COOLDOWN_START(src, chew_cooldown, interval)

/datum/component/chewable/proc/handle_reagents()
	var/obj/item/item_parent = parent
	var/datum/reagents/reagents = item_parent.reagents

	if (!reagents.trans_to(item_parent.loc, REAGENTS_METABOLISM, methods = INGEST))
		reagents.remove_any(REAGENTS_METABOLISM)

/datum/component/chewable/proc/on_dropped(datum/source)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSdcs, src)

/datum/component/chewable/proc/on_equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (slot & slots_to_check)
		START_PROCESSING(SSdcs, src)
	else
		STOP_PROCESSING(SSdcs, src)
