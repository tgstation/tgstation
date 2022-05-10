/// Hallucinates a fake item in our hands, pockets, or belt or whatever.
/// In the future this should probably be changed to generate these items automatically.
/datum/hallucination/fake_item
	/// A weakref to the real fake item we created.
	var/datum/weakref/created_hallucination

/datum/hallucination/fake_item/Destroy()
	QDEL_NULL(created_hallucination)
	return ..()

/datum/hallucination/fake_item/start()
	var/list/slots_free = list()
	for(var/hand in hallucinator.get_empty_held_indexes())
		slots_free += ui_hand_position(hand)

	if(ishuman(hallucinator))
		var/mob/living/carbon/human/human_hallucinator = hallucinator
		if(!human_hallucinator.belt)
			slots_free += ui_belt
		if(!human_hallucinator.l_store)
			slots_free += ui_storage1
		if(!human_hallucinator.r_store)
			slots_free += ui_storage2

	if(!length(slots_free))
		return FALSE

	var/obj/item/hallucinated/hallucinated_item = make_fake_item(pick(slots_free))
	feedback_details += "Item Type: [hallucinated_item.name]"
	created_item = WEAKREF(hallucinated_item)

	hallucinator.client?.screen += hallucinated_item
	QDEL_IN(src, rand(15 SECONDS, 35 SECONDS))

/datum/hallucination/fake_item/proc/make_fake_item(where_to_put_it)
	return new /obj/item/hallucinated(ui_location = where_to_put_it)

/datum/hallucination/fake_item/c4

/datum/hallucination/fake_item/c4/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = "C4"
	hallucinated_item.icon = 'icons/obj/grenade.dmi'
	if(prob(25))
		hallucinated_item.icon_state = "plasticx40"
	else
		shallucinated_item.icon_state = "plastic-explosive0"
	return hallucinated_item

/datum/hallucination/fake_item/revolver

/datum/hallucination/fake_item/revolver/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	halitem.name = "Revolver"
	hallucinated_item.icon = 'icons/obj/guns/ballistic.dmi'
	hallucinated_item.icon_state = "revolver"
	return hallucinated_item

/datum/hallucination/fake_item/esword

/datum/hallucination/fake_item/esword/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = "energy sword"
	hallucinated_item.icon = 'icons/obj/transforming_energy.dmi'
	if(prob(20))
		hallucinated_item.icon_state = "e_sword_on_red"
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/weapons/saberon.ogg', 35, TRUE)
	else
		hallucinated_item.icon_state = "e_sword"

	return hallucinated_item

/datum/hallucination/fake_item/baton

/datum/hallucination/fake_item/baton/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = "stun baton"
	hallucinated_item.icon = 'icons/obj/items_and_weapons.dmi'
	if(prob(20))
		hallucinated_item.icon_state = "stunbaton_active"
		hallucinator.playsound_local(get_turf(hallucinator), SFX_SPARKS, 75, TRUE, -1)
	else
		hallucinated_item.icon_state = "stunbaton"

	return hallucinated_item

/datum/hallucination/fake_item/emag

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

/datum/hallucination/fake_item/flashbang/make_fake_item(where_to_put_it)
	var/obj/item/hallucinated/hallucinated_item = ..()
	hallucinated_item.name = "flashbang"
	hallucinated_item.icon = 'icons/obj/grenade.dmi'
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

/obj/item/hallucinated/Initialize(mapload, ui_location)
	. = ..()
	if(!ui_location) // This really shouldn't be made outside of hallucinations
		return INITIALIZE_HINT_QDEL

	hallucinated_item.screen_loc = ui_location
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)
