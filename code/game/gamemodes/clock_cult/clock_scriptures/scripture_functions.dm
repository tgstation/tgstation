///////////////
// FUNCTIONS //
///////////////
//These are tier 3 scriptures.

//Fellowship Armory: Arms the invoker and nearby servants with Ratvarian armor.
/datum/clockwork_scripture/fellowship_armory
	descname = "Area Servant Armor"
	name = "Fellowship Armory"
	desc = "Equips the invoker and all visible Servants with Ratvarian armor. This armor provides high melee resistance but a weakness to lasers. \
	It grows faster to invoke with more adjacent Servants."
	invocations = list("Shield us...", "...with the...", "... fragments of Engine!")
	channel_time = 100
	potential_cost = 1
	wisdom_cost = 1
	usage_tip = "This scripture will replace all weaker armor worn by affected Servants."
	tier = SCRIPTURE_FUNCTION
	multiple_invokers_used = TRUE
	multiple_invokers_optional = TRUE
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Attempts to armor all nearby Servants with powerful Ratvarian armor."
	var/static/list/ratvarian_armor_typecache = typecacheof(list(
	/obj/item/clothing/suit/armor/clockwork,
	/obj/item/clothing/head/helmet/clockwork,
	/obj/item/clothing/gloves/clockwork,
	/obj/item/clothing/shoes/clockwork)) //don't replace this ever
	var/static/list/better_armor_typecache = typecacheof(list(
	/obj/item/clothing/suit/space,
	/obj/item/clothing/head/helmet/space,
	/obj/item/clothing/shoes/magboots)) //replace this only if ratvar is up

/datum/clockwork_scripture/fellowship_armory/run_scripture()
	for(var/mob/living/L in orange(1, invoker))
		if(can_recite_scripture(L))
			channel_time = max(channel_time - 10, 0)
	return ..()

/datum/clockwork_scripture/fellowship_armory/scripture_effects()
	var/affected = 0
	for(var/mob/living/L in view(7, get_turf(invoker)))
		if(L.stat == DEAD || !is_servant_of_ratvar(L))
			continue
		var/do_message = 0
		var/obj/item/I = L.get_item_by_slot(slot_wear_suit)
		if(remove_item_if_better(I, L))
			do_message += L.equip_to_slot_or_del(new/obj/item/clothing/suit/armor/clockwork(null), slot_wear_suit)
		I = L.get_item_by_slot(slot_head)
		if(remove_item_if_better(I, L))
			do_message += L.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/clockwork(null), slot_head)
		I = L.get_item_by_slot(slot_gloves)
		if(remove_item_if_better(I, L))
			do_message += L.equip_to_slot_or_del(new/obj/item/clothing/gloves/clockwork(null), slot_gloves)
		I = L.get_item_by_slot(slot_shoes)
		if(remove_item_if_better(I, L))
			do_message += L.equip_to_slot_or_del(new/obj/item/clothing/shoes/clockwork(null), slot_shoes)
		if(do_message)
			L.visible_message("<span class='warning'>Strange armor appears on [L]!</span>", "<span class='heavy_brass'>A bright shimmer runs down your body, equipping you with Ratvarian armor.</span>")
			playsound(L, 'sound/magic/clockwork/fellowship_armory.ogg', 15*do_message, 1) //get sound loudness based on how much we equipped
			affected++
	return affected

/datum/clockwork_scripture/fellowship_armory/proc/remove_item_if_better(obj/item/I, mob/user)
	if(!I)
		return TRUE
	if(is_type_in_typecache(I, ratvarian_armor_typecache))
		return FALSE
	if(!GLOB.ratvar_awakens && is_type_in_typecache(I, better_armor_typecache))
		return FALSE
	return user.dropItemToGround(I)
