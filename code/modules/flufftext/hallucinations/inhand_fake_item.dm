/// Hallucinates a fake item in our hands, pockets, or belt or whatever.
/// In the future this should probably be changed to generate these items automatically.
/datum/hallucination/fake_item
	abstract_hallucination_parent = /datum/hallucination/fake_item
	random_hallucination_weight = 1

	/// A flag of slots this fake item can appear in.
	var/valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_BELT|ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET

/datum/hallucination/fake_item/start()
	var/list/slots_free = list()
	if(valid_slots & ITEM_SLOT_HANDS)
		for(var/hand in hallucinator.get_empty_held_indexes())
			slots_free += ui_hand_position(hand)

	if(ishuman(hallucinator))
		var/mob/living/carbon/human/human_hallucinator = hallucinator
		if((valid_slots & ITEM_SLOT_BELT) && !human_hallucinator.belt)
			slots_free += ui_belt
		if((valid_slots & ITEM_SLOT_LPOCKET) && !human_hallucinator.l_store)
			slots_free += ui_storage1
		if((valid_slots & ITEM_SLOT_RPOCKET) && !human_hallucinator.r_store)
			slots_free += ui_storage2

	if(!length(slots_free))
		return FALSE

	var/obj/item/hallucinated/hallucinated_item = make_fake_item(pick(slots_free))
	feedback_details += "Item Type: [hallucinated_item.name]"

	hallucinator.client?.screen += hallucinated_item
	QDEL_IN(src, rand(15 SECONDS, 35 SECONDS))
	return TRUE

/datum/hallucination/fake_item/proc/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = new(hallucinator, src)
	hallucinated_item.screen_loc = where_to_put_it
	return hallucinated_item

/datum/hallucination/fake_item/c4

/datum/hallucination/fake_item/c4/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = "C-4 charge"
	hallucinated_item.icon = 'icons/obj/grenade.dmi'
	hallucinated_item.w_class = WEIGHT_CLASS_SMALL
	if(prob(25))
		hallucinated_item.icon_state = "plasticx40"
	else
		hallucinated_item.icon_state = "plastic-explosive0"
	return hallucinated_item

/datum/hallucination/fake_item/revolver
	valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_BELT

/datum/hallucination/fake_item/revolver/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = ".357 revolver"
	hallucinated_item.icon = 'icons/obj/weapons/guns/ballistic.dmi'
	hallucinated_item.icon_state = "revolver"
	return hallucinated_item

/datum/hallucination/fake_item/esword
	valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET

/datum/hallucination/fake_item/esword/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = "energy sword"
	hallucinated_item.icon = 'icons/obj/weapons/transforming_energy.dmi'
	if(where_to_put_it != ui_storage1 && where_to_put_it != ui_storage2 && prob(40)) // meh
		hallucinated_item.icon_state = "e_sword_on_red"
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/weapons/saberon.ogg', 35, TRUE)
	else
		hallucinated_item.icon_state = "e_sword"

	return hallucinated_item

/datum/hallucination/fake_item/baton
	valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_BELT

/datum/hallucination/fake_item/baton/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = "stun baton"
	hallucinated_item.icon = 'icons/obj/weapons/items_and_weapons.dmi'
	if(where_to_put_it != ui_belt && prob(30))
		hallucinated_item.icon_state = "stunbaton_active"
		hallucinator.playsound_local(get_turf(hallucinator), SFX_SPARKS, 75, TRUE, -1)
	else
		hallucinated_item.icon_state = "stunbaton"

	return hallucinated_item

/datum/hallucination/fake_item/emag
	valid_slots = ITEM_SLOT_HANDS|ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET

/datum/hallucination/fake_item/emag/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.icon = 'icons/obj/card.dmi'
	if(prob(50))
		hallucinated_item.name = "cryptographic sequencer"
		hallucinated_item.icon_state = "emag"
	else
		hallucinated_item.name = "airlock authentication override card"
		hallucinated_item.icon_state = "doorjack"

	return hallucinated_item

/datum/hallucination/fake_item/flashbang
	valid_slots = ITEM_SLOT_HANDS

/datum/hallucination/fake_item/flashbang/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = "flashbang"
	hallucinated_item.icon = 'icons/obj/weapons/grenade.dmi'
	if(prob(15))
		hallucinated_item.icon_state = "flashbang_active"
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/weapons/armbomb.ogg', 60, TRUE)
		to_chat(hallucinator, span_warning("You prime [hallucinated_item]! 5 seconds!"))
	else
		hallucinated_item.icon_state = "flashbang"

	return hallucinated_item

/obj/item/hallucinated
	name = "mirage"
	plane = ABOVE_HUD_PLANE
	interaction_flags_item = NONE
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The hallucination that created us.
	var/datum/hallucination/parent

/obj/item/hallucinated/Initialize(mapload, datum/hallucination/parent)
	. = ..()
	if(!parent)
		stack_trace("[type] was created without a parent hallucination.")
		return INITIALIZE_HINT_QDEL

	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/parent_deleting)
	src.parent = parent

	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/hallucinated/Destroy(force)
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	parent = null
	return ..()

/// Signal proc for [COMSIG_PARENT_QDELETING], if our associated hallucination deletes, we should too
/obj/item/hallucinated/proc/parent_deleting(datum/source)
	SIGNAL_HANDLER

	qdel(src)
