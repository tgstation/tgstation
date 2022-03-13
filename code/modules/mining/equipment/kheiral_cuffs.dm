/**********************Kheiral Cuffs**********************/
/// Acts as a GPS beacon & distress signaller when clamped to one's wrist off-station.
/obj/item/kheiral_cuffs
	name = "\improper Kheiral cuffs"
	desc = "A prototype wrist communicator powered by Kheiral Matter. When both ends are clamped to one wrist, can send a distress signal upon your death off-station.\nA small engraving on the inside reads, \"NOT HANDCUFFS\""
	icon = 'icons/obj/mining.dmi'
	icon_state = "strand"
	worn_icon_state = "strandcuff"
	slot_flags = ITEM_SLOT_GLOVES
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	gender = PLURAL
	throw_speed = 3
	throw_range = 5
	/// If we're in the glove slot
	var/on_wrist = FALSE
	/// If the GPS is already on
	var/gps_enabled = FALSE
	/// If we're off the station's Z-level
	var/far_from_home = FALSE
	/// Used to broadcast user's death through the radio
	var/obj/item/radio/internal_radio
	/// The GPS component used by the cuffs. Extremely unoptimal.
	var/datum/component/gps/gps

/obj/item/kheiral_cuffs/Initialize()
	. = ..()
	update_icon(UPDATE_OVERLAYS)
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, .proc/check_z)

	internal_radio = new/obj/item/radio(src)
	internal_radio.subspace_transmission = TRUE
	internal_radio.canhear_range = 0
	internal_radio.should_be_listening = FALSE
	internal_radio.keyslot = new /obj/item/encryptionkey/strandcuffs
	internal_radio.set_listening(FALSE)
	internal_radio.recalculateChannels()

	AddComponent(/datum/component/gps, "Kheiral Link", FALSE)
	gps = GetComponent(/datum/component/gps)

/obj/item/kheiral_cuffs/examine(mob/user)
	. = ..()
	if(gps_enabled)
		. += span_notice("The cuff's GPS signal is on.")

/obj/item/kheiral_cuffs/item_action_slot_check(slot)
	return slot == ITEM_SLOT_GLOVES

/obj/item/kheiral_cuffs/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_GLOVES)
		return
	on_wrist = TRUE
	playsound(loc, 'sound/weapons/handcuffs.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	connect_kheiral_network(user)

/obj/item/kheiral_cuffs/dropped(mob/user, silent)
	. = ..()
	if(on_wrist)
		playsound(loc, 'sound/weapons/handcuffs.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	on_wrist = FALSE
	remove_kheiral_network(user)

/// Enables the GPS & registers the statchange signal
/obj/item/kheiral_cuffs/proc/connect_kheiral_network(mob/user)
	if(gps_enabled)
		return
	if(!on_wrist || !far_from_home)
		return
	gps.gpstag = "*[user.name]'s Kheiral Link"
	gps.tracking = TRUE
	balloon_alert(user, "GPS activated")
	RegisterSignal(user, COMSIG_MOB_STATCHANGE, .proc/on_user_statchange)
	gps_enabled = TRUE

/// Disables the GPS and unregisters the statchange signal
/obj/item/kheiral_cuffs/proc/remove_kheiral_network(mob/user)
	if(!gps_enabled)
		return
	if(on_wrist && far_from_home)
		return
	gps.tracking = FALSE
	balloon_alert(user, "GPS de-activated")
	UnregisterSignal(user, COMSIG_MOB_STATCHANGE)
	gps_enabled = FALSE

/obj/item/kheiral_cuffs/Destroy(force)
	gps = null
	if(internal_radio)
		QDEL_NULL(internal_radio)
	. = ..()

/// If we're off the Z-level, set far_from_home = TRUE. If being worn, trigger kheiral_network proc
/obj/item/kheiral_cuffs/proc/check_z(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER

	if(!isturf(new_turf))
		return

	var/mob/living/bridges = loc
	if(is_station_level(new_turf.z))
		far_from_home = FALSE
		if(bridges)
			remove_kheiral_network(bridges)
	else
		far_from_home = TRUE
		if(bridges)
			connect_kheiral_network(bridges)

/// If we die, scream over the radio for help.
/obj/item/kheiral_cuffs/proc/on_user_statchange(mob/living/owner, new_stat)
	SIGNAL_HANDLER

	if(new_stat != DEAD)
		return
	var/death_message = "Warning! [owner] has perished off-station!"
	if(internal_radio)
		internal_radio.talk_into(src, death_message, RADIO_CHANNEL_MEDICAL)
		internal_radio.talk_into(src, death_message, RADIO_CHANNEL_SUPPLY)


/obj/item/kheiral_cuffs/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "strandcuff_emissive", alpha = src.alpha)

/obj/item/kheiral_cuffs/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "strand_light", alpha = src.alpha)
