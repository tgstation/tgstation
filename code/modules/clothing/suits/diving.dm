/obj/item/clothing/head/helmet/diving
	name = "heavy diving helmet"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	worn_icon = 'icons/mob/clothing/head/spacehelm.dmi'
	icon_state = "diving"
	inhand_icon_state = null
	desc = "A waterproof helmet with UV shielding to protect your eyes from nearby lightning strikes."
	clothing_flags = THICKMATERIAL | SNUG_FIT | STACKABLE_HELMET_EXEMPT | HEADINTERNALS
	armor_type = /datum/armor/helmet_space
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	interaction_flags_click = NEED_DEXTERITY
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	strip_delay = 50
	equip_delay_other = 50
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE
	dog_fashion = null
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'
	///Icon state applied when we get spraypainted/peppersprayed. If null, does not add the dirt component
	var/visor_dirt = "helm_dirt"

/obj/item/clothing/head/helmet/diving/Initialize(mapload)
	. = ..()
	if(visor_dirt)
		AddComponent(/datum/component/clothing_dirt, visor_dirt)
	add_stabilizer()

/obj/item/clothing/head/helmet/diving/proc/add_stabilizer(loose_hat = TRUE)
	AddComponent(/datum/component/hat_stabilizer, loose_hat = loose_hat)

/obj/item/clothing/suit/diving
	name = "heavy diving suit"
	desc = "A waterproof suit that allows the user to navigate depths efficiently."
	icon_state = "diving"
	icon = 'icons/obj/clothing/suits/spacesuit.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	worn_icon = 'icons/mob/clothing/suits/spacesuit.dmi'
	inhand_icon_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack/oxygen/captain,
		)
	slowdown = 0.5
	armor_type = /datum/armor/suit_space
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	equip_delay_other = 80
	resistance_flags = NONE

/obj/item/clothing/suit/diving/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diving_gear)

/datum/element/diving_gear

/datum/element/diving_gear/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	var/obj/item/item_target = target
	if(ismob(item_target.loc))
		var/mob/wearer = item_target.loc
		if(!item_target.slot_flags || wearer.get_item_by_slot(item_target.slot_flags) == item_target)
			ADD_TRAIT(wearer, TRAIT_SWIMMER, ELEMENT_TRAIT(target))
			wearer.remove_movespeed_modifier(/datum/movespeed_modifier/swimming_deep)

/datum/element/diving_gear/Detach(obj/item/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ATOM_EXAMINE))

	if(isliving(source.loc))
		REMOVE_TRAIT(source.loc, TRAIT_SWIMMER, ELEMENT_TRAIT(source))
		var/mob/wearer = source.loc
		if (!HAS_TRAIT(wearer, TRAIT_SWIMMER) && istype(wearer.loc, /turf/open/water) && !HAS_TRAIT(wearer.loc, TRAIT_IMMERSE_STOPPED))
			wearer.add_movespeed_modifier(/datum/movespeed_modifier/swimming_deep)

/datum/element/diving_gear/proc/on_equip(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(source.slot_flags && !(source.slot_flags & slot))
		return
	ADD_TRAIT(user, TRAIT_SWIMMER, ELEMENT_TRAIT(source))
	user.remove_movespeed_modifier(/datum/movespeed_modifier/swimming_deep)

/datum/element/diving_gear/proc/on_drop(obj/item/source, mob/user)
	SIGNAL_HANDLER
	REMOVE_TRAIT(user, TRAIT_SWIMMER, ELEMENT_TRAIT(source))
	if (!HAS_TRAIT(user, TRAIT_SWIMMER) && istype(user.loc, /turf/open/water) && !HAS_TRAIT(user.loc, TRAIT_IMMERSE_STOPPED))
		user.add_movespeed_modifier(/datum/movespeed_modifier/swimming_deep)

/datum/element/diving_gear/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_green("This clothing will allow you to swim in deep water without drowning.")
