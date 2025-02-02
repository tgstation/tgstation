/// Curse brain trauma that makes someone space textured, mute, pacifist and forbids them from entering space
/datum/brain_trauma/voided
	name = "Voided"
	desc = "They've seen the secrets of the cosmos, in exchange for a curse that keeps them chained."
	scan_desc = "cosmic neural pattern"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	random_gain = FALSE
	/// Type for the bodypart texture we add
	var/bodypart_overlay_type = /datum/bodypart_overlay/texture/spacey
	/// Color in which we paint the space texture
	var/space_color = COLOR_WHITE
	///traits we give on gain
	var/list/traits_to_apply = list(TRAIT_MUTE, TRAIT_PACIFISM)
	/// Do we ban the person from entering space?
	var/ban_from_space = TRUE
	/// Statis list of all possible space colors
	var/static/list/space_colors = list("#ffffff", "#00ccff","#b12bff","#ff7f3a","#ff1c55","#ff7597","#28ff94","#0fcfff","#ff8b4c","#ffc425","#2dff96","#1770ff","#ff3f31","#ffba3b")

/datum/brain_trauma/voided/on_gain()
	. = ..()
	space_color = pick(space_colors)
	owner.add_traits(traits_to_apply, REF(src))
	if(ban_from_space)
		owner.AddComponent(/datum/component/banned_from_space)
	owner.AddComponent(/datum/component/planet_allergy)
	RegisterSignal(owner, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(texture_limb)) //also catch new limbs being attached
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(untexture_limb)) //and remove it from limbs if they go away

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

	owner.remove_traits(traits_to_apply, REF(src))
	UnregisterSignal(owner, list(COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))
	if(ban_from_space)
		qdel(owner.GetComponent(/datum/component/banned_from_space))
	qdel(owner.GetComponent(/datum/component/planet_allergy))

	for(var/obj/item/bodypart/bodypart as anything in owner.bodyparts)
		untexture_limb(owner, bodypart)

/// Apply the space texture
/datum/brain_trauma/voided/proc/texture_limb(atom/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	limb.add_bodypart_overlay(new bodypart_overlay_type)
	limb.add_color_override(space_color, LIMB_COLOR_VOIDWALKER_CURSE)
	if(istype(limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = limb
		head.head_flags &= ~HEAD_EYESPRITES

/datum/brain_trauma/voided/proc/untexture_limb(atom/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	var/overlay = locate(bodypart_overlay_type) in limb.bodypart_overlays
	if(overlay)
		limb.remove_bodypart_overlay(overlay)
		limb.remove_color_override(LIMB_COLOR_VOIDWALKER_CURSE)

	if(istype(limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = limb
		head.head_flags = initial(head.head_flags)

/datum/brain_trauma/voided/on_death()
	. = ..()

	if(is_on_a_planet(owner))
		qdel(src)

/// Positive version of the previous. Get space immunity and the ability to slowly move through glass (but you still get muted)
/datum/brain_trauma/voided/stable
	scan_desc = "stable cosmic neural pattern"
	traits_to_apply = list(TRAIT_MUTE, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD)
	ban_from_space = FALSE

/datum/brain_trauma/voided/stable/on_gain()
	. = ..()

	owner.AddComponent(/datum/component/glass_passer, 2 SECONDS)

/datum/brain_trauma/voided/stable/on_lose()
	. = ..()

	qdel(owner.GetComponent(/datum/component/glass_passer))
