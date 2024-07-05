/datum/brain_trauma/voided
	name = "Voided"
	desc = "They've seen the secrets of the cosmis, in exchange for a curse that keeps them chained."
	scan_desc = "cosmic neural pattern"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	random_gain = FALSE
	/// Type for the bodypart texture we add
	var/bodypart_overlay_type = /datum/bodypart_overlay/texture/spacey
	///traits we give on gain
	var/list/traits_to_apply = list(TRAIT_MUTE, TRAIT_PACIFISM)
	/// Do we ban the person from entering space?
	var/ban_from_space = TRUE

/datum/brain_trauma/voided/on_gain()
	. = ..()

	owner.add_traits(traits_to_apply, TRAUMA_TRAIT)
	if(ban_from_space)
		owner.AddComponent(/datum/component/banned_from_space)
	RegisterSignal(owner, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(texture_limb))
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(untexture_limb))

	for(var/obj/item/bodypart as anything in owner.bodyparts)
		texture_limb(owner, bodypart)

	//your underwear is belong to us
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner //CARBON WILL NEVER BE REAL!!!!!
		human.underwear = "Nude"
		human.undershirt = "Nude"
		human.socks = "Nude"

	owner.update_body()

/datum/brain_trauma/voided/on_lose()
	. = ..()

	owner.remove_traits(traits_to_apply, TRAUMA_TRAIT)
	UnregisterSignal(owner, list(COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))
	if(ban_from_space)
		qdel(owner.GetComponent(/datum/component/banned_from_space))

	for(var/obj/item/bodypart/bodypart as anything in owner.bodyparts)
		untexture_limb(owner, bodypart)

/datum/brain_trauma/voided/proc/texture_limb(atom/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	limb.add_bodypart_overlay(new bodypart_overlay_type)
	if(istype(limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = limb
		head.head_flags &= ~HEAD_EYESPRITES

/datum/brain_trauma/voided/proc/untexture_limb(atom/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	var/overlay = locate(bodypart_overlay_type) in limb.bodypart_overlays
	if(overlay)
		limb.remove_bodypart_overlay(overlay)

	if(istype(limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = limb
		head.head_flags = initial(head.head_flags)

/datum/brain_trauma/voided/stable
	scan_desc = "stable cosmic neural pattern"
	traits_to_apply = list(TRAIT_MUTE, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD)
	ban_from_space = FALSE

/datum/brain_trauma/voided/stable/on_gain()
	. = ..()

	owner.apply_status_effect(/datum/status_effect/glass_passer/delayed)

/datum/brain_trauma/voided/stable/on_lose()
	. = ..()

	owner.remove_status_effect(/datum/status_effect/glass_passer/delayed)

/datum/component/banned_from_space
	/// List of recent tiles we walked on that aren't space
	var/list/tiles = list()
	/// The max amount of tiles we store
	var/max_tile_list_size = 4

/datum/component/banned_from_space/Initialize(...)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(check_if_space))

/datum/component/banned_from_space/proc/check_if_space(atom/source, atom/new_location)
	SIGNAL_HANDLER

	if(!isturf(new_location))
		return

	if(isspaceturf(new_location))
		send_back(parent)

	else
		tiles.Add(new_location)
		if(tiles.len > max_tile_list_size)
			tiles.Cut(1, 2)

/datum/component/banned_from_space/proc/send_back(atom/movable/parent)
	var/new_turf

	if(tiles.len)
		new_turf = tiles[1]
		new /obj/effect/temp_visual/portal_animation(parent.loc, new_turf, parent)
	else
		new_turf = get_random_station_turf()

	parent.forceMove(new_turf)
