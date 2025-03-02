
/// A box which takes in coolant and uses it to preserve organs and body parts
/obj/item/storage/organbox
	name = "organ transport box"
	desc = "An advanced box with a cooling mechanism that uses cryostylane or other cold reagents to keep the organs or bodyparts inside preserved."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "organbox"
	base_icon_state = "organbox"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	custom_premium_price = PAYCHECK_CREW * 4
	storage_type = /datum/storage/organ_box

	/// var to prevent it freezing the same things over and over
	var/cooling = FALSE

/obj/item/storage/organbox/Initialize(mapload)
	. = ..()

	create_reagents(100, TRANSPARENT)

	START_PROCESSING(SSobj, src)

/obj/item/storage/organbox/process(seconds_per_tick)
	///if there is enough coolant var
	var/using_coolant = coolant_to_spend()
	if (isnull(using_coolant))
		if (cooling)
			cooling = FALSE
			update_appearance()
			for(var/obj/stored in contents)
				stored.unfreeze()
		return

	var/amount_used = 0.05 * seconds_per_tick
	if (using_coolant != /datum/reagent/cryostylane)
		amount_used *= 2
	reagents.remove_reagent(using_coolant, amount_used)

	if(cooling)
		return
	cooling = TRUE
	update_appearance()
	for(var/obj/stored in contents)
		stored.freeze()

/// Returns which coolant we are about to use, or null if there isn't any
/obj/item/storage/organbox/proc/coolant_to_spend()
	if (reagents.get_reagent_amount(/datum/reagent/cryostylane))
		return /datum/reagent/cryostylane
	if (reagents.get_reagent_amount(/datum/reagent/consumable/ice))
		return /datum/reagent/consumable/ice
	return null

/obj/item/storage/organbox/update_icon_state()
	icon_state = "[base_icon_state][cooling ? "-working" : null]"
	return ..()

/obj/item/storage/organbox/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(is_reagent_container(tool) && tool.is_open_container())
		var/obj/item/reagent_containers/RC = tool
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this, transferred_by = user)
		if(units)
			balloon_alert(user, "[units]u transferred")
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING
	if(istype(tool, /obj/item/plunger))
		balloon_alert(user, "plunging...")
		if(do_after(user, 1 SECONDS, target = src))
			balloon_alert(user, "plunged")
			reagents.clear_reagents()
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/storage/organbox/suicide_act(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_RESISTCOLD)) //if they're immune to cold, just do the box suicide
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		if(myhead)
			user.visible_message(span_suicide("[user] puts [user.p_their()] head into \the [src] and begins closing it! It looks like [user.p_theyre()] trying to commit suicide!"))
			myhead.dismember()
			myhead.forceMove(src) //force your enemies to kill themselves with your head collection box!
			playsound(user, "desecration-01.ogg", 50, TRUE, -1)
			return BRUTELOSS
		user.visible_message(span_suicide("[user] is beating [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS
	user.visible_message(span_suicide("[user] is putting [user.p_their()] head inside the [src], it looks like [user.p_theyre()] trying to commit suicide!"))
	user.adjust_bodytemperature(-300)
	user.apply_status_effect(/datum/status_effect/freon)
	return FIRELOSS

/// A subtype of organ storage box which starts with a full coolant tank
/obj/item/storage/organbox/preloaded

/obj/item/storage/organbox/preloaded/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/cryostylane, reagents.maximum_volume)

/obj/item/storage/test_tube_rack
	name = "test tube rack"
	desc = "A wooden rack for storing test tubes."
	icon_state = "rack"
	base_icon_state = "rack"
	icon = 'icons/obj/medical/chemical.dmi'
	inhand_icon_state = "contsolid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	storage_type = /datum/storage/test_tube_rack

/obj/item/storage/test_tube_rack/update_icon_state()
	icon_state = "[base_icon_state][contents.len > 0 ? contents.len : null]"
	return ..()

/obj/item/storage/test_tube_rack/full/PopulateContents()
	. = list()
	for(var/i in 1 to 8)
		. += /obj/item/reagent_containers/cup/tube

