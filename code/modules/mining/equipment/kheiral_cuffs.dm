/**********************Kheiral Cuffs**********************/
/// Acts as a GPS beacon & connects to station crew monitors from lavaland
/obj/item/kheiral_cuffs
	name = "\improper Kheiral cuffs"
	desc = "A prototype wrist communicator powered by Kheiral Matter. When both ends are clamped to one wrist, acts as a signal range booster for your suit sensors.\n<i>A small engraving on the inside reads, \"NOT HANDCUFFS\"</i>"
	icon = 'icons/obj/mining.dmi'
	icon_state = "strand"
	worn_icon_state = "strandcuff"
	slot_flags = ITEM_SLOT_GLOVES
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	gender = PLURAL
	throw_speed = 3
	throw_range = 5
	attack_verb_continuous = list("connects")
	attack_verb_simple = list("connect")
	resistance_flags = FIRE_PROOF
	/// If we're in the glove slot
	var/on_wrist = FALSE
	/// If the GPS is already on
	var/gps_enabled = FALSE
	/// If we're off the station's Z-level
	var/far_from_home = FALSE

/obj/item/kheiral_cuffs/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(check_z))

	check_z(new_turf = loc)

/obj/item/kheiral_cuffs/examine(mob/user)
	. = ..()
	if(gps_enabled)
		. += span_notice("The cuff's GPS signal is on.")

/obj/item/kheiral_cuffs/item_action_slot_check(slot)
	return (slot & ITEM_SLOT_GLOVES)

/obj/item/kheiral_cuffs/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & ITEM_SLOT_GLOVES))
		return
	on_wrist = TRUE
	playsound(loc, 'sound/items/weapons/handcuffs.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	connect_kheiral_network(user)

/obj/item/kheiral_cuffs/dropped(mob/user, silent)
	. = ..()
	if(on_wrist)
		playsound(loc, 'sound/items/weapons/handcuffs.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	on_wrist = FALSE
	remove_kheiral_network(user)

/// Enables the GPS and adds the multiz trait
/obj/item/kheiral_cuffs/proc/connect_kheiral_network(mob/living/user)
	if(gps_enabled)
		return
	if(!on_wrist || !far_from_home)
		return
	var/gps_name = "Unknown"
	var/obj/item/card/id/id_card = user.get_idcard(hand_first = FALSE)
	if(id_card)
		gps_name = id_card.registered_name
	AddComponent(/datum/component/gps/kheiral_cuffs, "*[gps_name]'s Kheiral Link")
	balloon_alert(user, "gps activated")
	ADD_TRAIT(user, TRAIT_MULTIZ_SUIT_SENSORS, REF(src))
	gps_enabled = TRUE

/// Disables the GPS and removes the multiz trait
/obj/item/kheiral_cuffs/proc/remove_kheiral_network(mob/user)
	if(!gps_enabled)
		return
	if(on_wrist && far_from_home)
		return
	balloon_alert(user, "gps de-activated")
	REMOVE_TRAIT(user, TRAIT_MULTIZ_SUIT_SENSORS, REF(src))
	gps_enabled = FALSE

/// If we're off the Z-level, set far_from_home = TRUE. If being worn, trigger kheiral_network proc
/obj/item/kheiral_cuffs/proc/check_z(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER

	if(!isturf(new_turf))
		return

	if(is_station_level(new_turf.z))
		far_from_home = FALSE
		if(isliving(loc))
			remove_kheiral_network(loc)
	else
		far_from_home = TRUE
		if(isliving(loc))
			connect_kheiral_network(loc)

/obj/item/kheiral_cuffs/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "strandcuff_emissive", src, alpha = src.alpha)

/obj/item/kheiral_cuffs/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "strand_light", src, alpha = src.alpha)

/obj/item/kheiral_cuffs/suicide_act(mob/living/carbon/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/victim = user
	victim.visible_message(span_suicide("[user] locks [src] around their neck, wrinkles forming across their face. It looks like [user.p_theyre()] trying to commit suicide!"))
	for(var/mult in 1 to 5) // Rapidly age
		if(!do_after(victim, 0.5 SECONDS)) // just to space out the aging, either way you still dust.
			break
		var/before_age = victim.age
		victim.age = round((victim.age * 1.5),1)
		to_chat(victim, span_danger("You age [(victim.age - before_age)] years!"))

	to_chat(victim, span_danger("At the ripe age of [victim.age], your cells fail their cycle of mitosis, allowing the sands of time to wash over you."))
	victim.dust(TRUE, TRUE, TRUE)
	return MANUAL_SUICIDE
