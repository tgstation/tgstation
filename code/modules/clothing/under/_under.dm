/obj/item/clothing/under
	name = "under"
	icon = 'icons/obj/clothing/under/default.dmi'
	worn_icon = 'icons/mob/clothing/under/default.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	slot_flags = ITEM_SLOT_ICLOTHING
	armor_type = /datum/armor/clothing_under
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	limb_integrity = 30
	/// The variable containing the flags for how the woman uniform cropping is supposed to interact with the sprite.
	var/female_sprite_flags = FEMALE_UNIFORM_FULL
	var/has_sensor = HAS_SENSORS // For the crew computer
	var/random_sensor = TRUE
	var/sensor_mode = NO_SENSORS
	var/can_adjust = TRUE
	var/adjusted = NORMAL_STYLE
	var/alt_covers_chest = FALSE // for adjusted/rolled-down jumpsuits, FALSE = exposes chest and arms, TRUE = exposes arms only
	var/obj/item/clothing/accessory/attached_accessory
	var/mutable_appearance/accessory_overlay

/datum/armor/clothing_under
	bio = 10
	wound = 5

/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		sensor_mode = pick(SENSOR_VITALS, SENSOR_VITALS, SENSOR_VITALS, SENSOR_LIVING, SENSOR_LIVING, SENSOR_COORDS, SENSOR_COORDS, SENSOR_OFF)
	register_context()

/obj/item/clothing/under/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	var/screentip_change = FALSE

	if(isnull(held_item) && has_sensor == HAS_SENSORS)
		context[SCREENTIP_CONTEXT_RMB] = "Toggle suit sensors"
		screentip_change = TRUE

	if(istype(held_item, /obj/item/clothing/accessory) && !attached_accessory)
		var/obj/item/clothing/accessory/accessory = held_item
		if(accessory.can_attach_accessory(src, user))
			context[SCREENTIP_CONTEXT_LMB] = "Attach accessory"
			screentip_change = TRUE

	if(istype(held_item, /obj/item/stack/cable_coil) && has_sensor == BROKEN_SENSORS)
		context[SCREENTIP_CONTEXT_LMB] = "Repair suit sensors"
		screentip_change = TRUE

	if(attached_accessory)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove accessory"
		screentip_change = TRUE
	else if(can_adjust)
		context[SCREENTIP_CONTEXT_ALT_LMB] = adjusted == ALT_STYLE ? "Wear normally" : "Wear casually"
		screentip_change = TRUE

	return screentip_change ? CONTEXTUAL_SCREENTIP_SET : NONE

/obj/item/clothing/under/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform")
	if(GET_ATOM_BLOOD_DNA_LENGTH(src))
		. += mutable_appearance('icons/effects/blood.dmi', "uniformblood")
	if(accessory_overlay)
		. += accessory_overlay

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if((has_sensor == BROKEN_SENSORS) && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		C.use(1)
		has_sensor = HAS_SENSORS
		to_chat(user,span_notice("You repair the suit sensors on [src] with [C]."))
		return TRUE
	if(!attach_accessory(I, user))
		return ..()

/obj/item/clothing/under/attack_hand_secondary(mob/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	toggle()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/under/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_undersuit()
	if(damaged_state == CLOTHING_SHREDDED && has_sensor > NO_SENSORS)
		has_sensor = BROKEN_SENSORS
	else if(damaged_state == CLOTHING_PRISTINE && has_sensor == BROKEN_SENSORS)
		has_sensor = HAS_SENSORS

/obj/item/clothing/under/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(has_sensor > NO_SENSORS)
		if(severity <= EMP_HEAVY)
			has_sensor = BROKEN_SENSORS
			if(ismob(loc))
				var/mob/M = loc
				to_chat(M,span_warning("[src]'s sensors short out!"))
		else
			sensor_mode = pick(SENSOR_OFF, SENSOR_OFF, SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS)
			if(ismob(loc))
				var/mob/M = loc
				to_chat(M,span_warning("The sensors on the [src] change rapidly!"))
		if(ishuman(loc))
			var/mob/living/carbon/human/ooman = loc
			if(ooman.w_uniform == src)
				ooman.update_suit_sensors()

/obj/item/clothing/under/visual_equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = NORMAL_STYLE
		female_sprite_flags = initial(female_sprite_flags)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST

	if((supports_variations_flags & CLOTHING_DIGITIGRADE_VARIATION) && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.species.bodytype & BODYTYPE_DIGITIGRADE)
			adjusted = DIGITIGRADE_STYLE
		H.update_worn_undersuit()

	if(attached_accessory && !(slot & ITEM_SLOT_HANDS) && ishuman(user))
		var/mob/living/carbon/human/H = user
		attached_accessory.on_uniform_equip(src, user)
		H.fan_hud_set_fandom()
		if(attached_accessory.above_suit)
			H.update_worn_oversuit()

/obj/item/clothing/under/dropped(mob/user)
	if(attached_accessory)
		attached_accessory.on_uniform_dropped(src, user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.fan_hud_set_fandom()
			if(attached_accessory.above_suit)
				H.update_worn_oversuit()
	..()

/mob/living/carbon/human/update_suit_sensors()
	. = ..()
	update_sensor_list()

/mob/living/carbon/human/proc/update_sensor_list()
	var/obj/item/clothing/under/U = w_uniform
	if(istype(U) && U.has_sensor > NO_SENSORS && U.sensor_mode)
		GLOB.suit_sensors_list |= src
	else
		GLOB.suit_sensors_list -= src

/mob/living/carbon/human/dummy/update_sensor_list()
	return

/obj/item/clothing/under/proc/attach_accessory(obj/item/tool, mob/user, notifyAttach = 1)
	. = FALSE
	if(!istype(tool, /obj/item/clothing/accessory))
		return
	var/obj/item/clothing/accessory/accessory = tool
	if(attached_accessory)
		if(user)
			to_chat(user, span_warning("[src] already has an accessory."))
		return

	if(!accessory.can_attach_accessory(src, user)) //Make sure the suit has a place to put the accessory.
		return
	if(user && !user.temporarilyRemoveItemFromInventory(accessory))
		return
	if(!accessory.attach(src, user))
		return

	. = TRUE
	if(user && notifyAttach)
		to_chat(user, span_notice("You attach [accessory] to [src]."))

	var/accessory_color = attached_accessory.icon_state
	accessory_overlay = mutable_appearance(attached_accessory.worn_icon, "[accessory_color]")
	accessory_overlay.alpha = attached_accessory.alpha
	accessory_overlay.color = attached_accessory.color

	update_appearance()
	if(!ishuman(loc))
		return

	var/mob/living/carbon/human/holder = loc
	holder.update_worn_undersuit()
	holder.update_worn_oversuit()
	holder.fan_hud_set_fandom()

/obj/item/clothing/under/proc/remove_accessory(mob/user)
	. = FALSE
	if(!isliving(user))
		return
	if(!can_use(user))
		return

	if(!attached_accessory)
		return

	. = TRUE
	var/obj/item/clothing/accessory/accessory = attached_accessory
	attached_accessory.detach(src, user)
	if(user.put_in_hands(accessory))
		to_chat(user, span_notice("You detach [accessory] from [src]."))
	else
		to_chat(user, span_notice("You detach [accessory] from [src] and it falls on the floor."))

	update_appearance()
	if(!ishuman(loc))
		return

	var/mob/living/carbon/human/holder = loc
	holder.update_worn_undersuit()
	holder.update_worn_oversuit()
	holder.fan_hud_set_fandom()


/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(can_adjust)
		if(adjusted == ALT_STYLE)
			. += "Alt-click on [src] to wear it normally."
		else
			. += "Alt-click on [src] to wear it casually."
	if (has_sensor == BROKEN_SENSORS)
		. += "Its sensors appear to be shorted out."
	else if(has_sensor > NO_SENSORS)
		switch(sensor_mode)
			if(SENSOR_OFF)
				. += "Its sensors appear to be disabled."
			if(SENSOR_LIVING)
				. += "Its binary life sensors appear to be enabled."
			if(SENSOR_VITALS)
				. += "Its vital tracker appears to be enabled."
			if(SENSOR_COORDS)
				. += "Its vital tracker and tracking beacon appear to be enabled."
	if(attached_accessory)
		. += "\A [attached_accessory] is attached to it."

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	var/mob/user_mob = usr
	if (isdead(user_mob))
		return
	if (!can_use(user_mob))
		return
	if(has_sensor == LOCKED_SENSORS)
		to_chat(user_mob, "The controls are locked.")
		return
	if(has_sensor == BROKEN_SENSORS)
		to_chat(user_mob, "The sensors have shorted out!")
		return
	if(has_sensor <= NO_SENSORS)
		to_chat(user_mob, "This suit does not have any sensors.")
		return

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = tgui_input_list(user_mob, "Select a sensor mode", "Suit Sensors", modes, modes[sensor_mode + 1])
	if(isnull(switchMode))
		return

	if (!can_use(user_mob)) //make sure they didn't hold the window open.
		return
	if(get_dist(user_mob, src) > 1)
		to_chat(user_mob, span_warning("You have moved too far away!"))
		return

	if(has_sensor == LOCKED_SENSORS)
		to_chat(user_mob, "The controls are locked.")
		return
	if(has_sensor == BROKEN_SENSORS)
		to_chat(user_mob, "The sensors have shorted out!")
		return
	if(has_sensor <= NO_SENSORS)
		to_chat(user_mob, "This suit does not have any sensors.")
		return
	sensor_mode = modes.Find(switchMode) - 1
	if (loc == user_mob)
		switch(sensor_mode)
			if(SENSOR_OFF)
				to_chat(user_mob, span_notice("You disable your suit's remote sensing equipment."))
			if(SENSOR_LIVING)
				to_chat(user_mob, span_notice("Your suit will now only report whether you are alive or dead."))
			if(SENSOR_VITALS)
				to_chat(user_mob, span_notice("Your suit will now only report your exact vital lifesigns."))
			if(SENSOR_COORDS)
				to_chat(user_mob, span_notice("Your suit will now report your exact vital lifesigns as well as your coordinate position."))

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.w_uniform == src)
			H.update_suit_sensors()

/obj/item/clothing/under/AltClick(mob/user)
	. = ..()
	if(.)
		return

	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return
	if(attached_accessory)
		remove_accessory(user)
	else
		rolldown()

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(!can_use(usr))
		return
	if(!can_adjust)
		to_chat(usr, span_warning("You cannot wear this suit any differently!"))
		return
	if(toggle_jumpsuit_adjust())
		to_chat(usr, span_notice("You adjust the suit to wear it more casually."))
	else
		to_chat(usr, span_notice("You adjust the suit back to normal."))
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_worn_undersuit()
		H.update_body()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	if(adjusted == DIGITIGRADE_STYLE)
		return
	adjusted = !adjusted
	if(adjusted)
		if(!(female_sprite_flags & FEMALE_UNIFORM_TOP_ONLY))
			female_sprite_flags = NO_FEMALE_UNIFORM
		if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted (and also the arms, realistically)
			body_parts_covered &= ~CHEST
			body_parts_covered &= ~ARMS
	else
		female_sprite_flags = initial(female_sprite_flags)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST
			body_parts_covered |= ARMS
			if(!LAZYLEN(damage_by_parts))
				return adjusted
			for(var/zone in list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)) // ugly check to make sure we don't reenable protection on a disabled part
				if(damage_by_parts[zone] > limb_integrity)
					body_parts_covered &= body_zone2cover_flags(zone)
	return adjusted

/obj/item/clothing/under/rank
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/proc/dump_attachment()
	if(!attached_accessory)
		return
	var/atom/drop_location = drop_location()
	attached_accessory.transform *= 2
	attached_accessory.pixel_x -= 8
	attached_accessory.pixel_y += 8
	if(drop_location)
		attached_accessory.forceMove(drop_location)
	cut_overlays()
	attached_accessory = null
	accessory_overlay = null
	update_appearance()

/obj/item/clothing/under/rank/atom_destruction(damage_flag)
	dump_attachment()
	return ..()
