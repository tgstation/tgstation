/// Hallucinates a fake item in our hands, pockets, or belt or whatever.
/datum/hallucination/fake_item
	abstract_hallucination_parent = /datum/hallucination/fake_item
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_COMMON

	/// A flag of slots this fake item can appear in.
	var/valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_BELT|ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET
	/// What item should we use as a template, grabbing its icon and icon state and name?
	var/obj/item/template_item_type

/datum/hallucination/fake_item/start()
	var/list/slots_free = list()
	if(valid_slots & ITEM_SLOT_HANDS)
		for(var/hand in hallucinator.get_empty_held_indexes())
			slots_free[ui_hand_position(hand)] = ITEM_SLOT_HANDS

	// These slots are human only, + they have to have a uniform
	var/mob/living/carbon/human/human_hallucinator = hallucinator
	if(istype(human_hallucinator) && human_hallucinator.w_uniform)
		if((valid_slots & ITEM_SLOT_BELT) && !human_hallucinator.belt)
			slots_free[ui_belt] = ITEM_SLOT_BELT
		if((valid_slots & ITEM_SLOT_LPOCKET) && !human_hallucinator.l_store)
			slots_free[ui_storage1] = ITEM_SLOT_LPOCKET
		if((valid_slots & ITEM_SLOT_RPOCKET) && !human_hallucinator.r_store)
			slots_free[ui_storage2] = ITEM_SLOT_RPOCKET

	if(!length(slots_free))
		return FALSE

	var/picked_space = pick(slots_free)
	var/obj/item/hallucinated/hallucinated_item = make_fake_item(picked_space, slots_free[picked_space])
	feedback_details += "Item Type: [hallucinated_item.name]"

	hallucinator.client?.screen += hallucinated_item
	QDEL_IN(src, rand(15 SECONDS, 35 SECONDS))
	return TRUE

/datum/hallucination/fake_item/proc/make_fake_item(where_to_put_it, equip_flags)
	var/obj/item/hallucinated/hallucinated_item = new(hallucinator, src)
	hallucinated_item.screen_loc = where_to_put_it

	hallucinated_item.name = initial(template_item_type.name)
	hallucinated_item.desc = initial(template_item_type.desc)
	hallucinated_item.icon = initial(template_item_type.icon)
	hallucinated_item.icon_state = initial(template_item_type.icon_state)
	hallucinated_item.update_weight_class(initial(template_item_type.w_class)) // Not strictly necessary, but keen eyed people will notice

	return hallucinated_item

/datum/hallucination/fake_item/c4
	template_item_type = /obj/item/grenade/c4

/datum/hallucination/fake_item/c4/make_fake_item(where_to_put_it, equip_flags)
	if(prob(50))
		template_item_type = /obj/item/grenade/c4/x4
	return ..()

/datum/hallucination/fake_item/revolver
	template_item_type = /obj/item/gun/ballistic/revolver
	valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_BELT

/datum/hallucination/fake_item/esword
	template_item_type = /obj/item/melee/energy/sword/saber
	valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET

/datum/hallucination/fake_item/esword/make_fake_item(where_to_put_it, equip_flags)
	// Make the item via parent call
	var/obj/item/hallucinated/hallucinated_item = ..()

	// If we were placed in our mob's hands there's a 40% chance to make it appear active
	if((equip_flags & ITEM_SLOT_HANDS) && prob(40))
		var/obj/item/melee/energy/sword/saber/sabre_color = pick(subtypesof(/obj/item/melee/energy/sword/saber))
		// Yes this can break if someone changes esword icon stuff
		hallucinated_item.icon_state = "[hallucinated_item.icon_state]_on_[initial(sabre_color.sword_color_icon)]"
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/items/weapons/saberon.ogg', 35, TRUE)

	return hallucinated_item

/datum/hallucination/fake_item/baton
	template_item_type = /obj/item/melee/baton/security/loaded
	valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_BELT

/datum/hallucination/fake_item/baton/make_fake_item(where_to_put_it, equip_flags)
	var/obj/item/hallucinated/hallucinated_item = ..()

	// If we were placed in our mob's hands there's a 30% chance to make it appear active
	if((equip_flags & ITEM_SLOT_HANDS) && prob(30))
		// Yes this can break if someone changes baton icon stuff
		hallucinated_item.icon_state = "[hallucinated_item.icon_state]_active"
		hallucinator.playsound_local(get_turf(hallucinator), SFX_SPARKS, 75, TRUE, -1)

	return hallucinated_item

/datum/hallucination/fake_item/emag
	template_item_type = /obj/item/card/emag
	valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET

/datum/hallucination/fake_item/emag/make_fake_item(where_to_put_it, equip_flags)
	if(prob(50))
		template_item_type  = /obj/item/card/emag/doorjack
	return ..()

/datum/hallucination/fake_item/flashbang
	template_item_type  = /obj/item/grenade/flashbang
	valid_slots = ITEM_SLOT_HANDS

/datum/hallucination/fake_item/flashbang/make_fake_item(where_to_put_it, equip_flags)
	var/obj/item/hallucinated/hallucinated_item = ..()
	if(prob(15))
		// Yes this can break if someone changse grenade icon stuff
		hallucinated_item.icon_state = "[hallucinated_item.icon_state]_active"
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/items/weapons/armbomb.ogg', 60, TRUE)
		to_chat(hallucinator, span_warning("You prime [hallucinated_item]! 5 seconds!"))

	return hallucinated_item

/datum/hallucination/fake_item/summon_guns
	hallucination_tier = HALLUCINATION_TIER_RARE
	valid_slots = ITEM_SLOT_HANDS

/datum/hallucination/fake_item/summon_guns/make_fake_item(where_to_put_it, equip_flags)
	template_item_type = pick(GLOB.summoned_guns)
	. = ..()
	hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/magic/summon_guns.ogg', 50, TRUE)

/datum/hallucination/fake_item/summon_magic
	hallucination_tier = HALLUCINATION_TIER_RARE
	valid_slots = ITEM_SLOT_HANDS

/datum/hallucination/fake_item/summon_magic/make_fake_item(where_to_put_it, equip_flags)
	template_item_type = pick(GLOB.summoned_magic + GLOB.summoned_special_magic)
	. = ..()
	hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/magic/summon_magic.ogg', 50, TRUE)

/obj/item/hallucinated
	name = "mirage"
	plane = ABOVE_HUD_PLANE
	interaction_flags_item = NONE
	item_flags = ABSTRACT | DROPDEL | HAND_ITEM | NOBLUDGEON // Most of these flags don't matter, but better safe than sorry
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The hallucination that created us.
	var/datum/hallucination/parent

/obj/item/hallucinated/Initialize(mapload, datum/hallucination/parent)
	. = ..()
	if(!parent)
		stack_trace("[type] was created without a parent hallucination.")
		return INITIALIZE_HINT_QDEL

	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(parent_deleting))
	src.parent = parent

	add_traits(list(TRAIT_NODROP, TRAIT_EXAMINE_SKIP), INNATE_TRAIT)

/obj/item/hallucinated/Destroy(force)
	UnregisterSignal(parent, COMSIG_QDELETING)
	parent = null
	return ..()

/// Signal proc for [COMSIG_QDELETING], if our associated hallucination deletes, we should too
/obj/item/hallucinated/proc/parent_deleting(datum/source)
	SIGNAL_HANDLER

	qdel(src)
