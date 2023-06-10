/obj/item/clothing/suit/clockwork
	name = "bronze armor"
	desc = "A strong, bronze suit worn by the soldiers of the Ratvarian armies."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_garb.dmi'
	worn_icon = 'monkestation/icons/mob/clock_cult/clockwork_garb_worn.dmi'
	icon_state = "clockwork_cuirass"
	armor_type = /datum/armor/suit_clockwork
	slowdown = 0.6
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(
		/obj/item/clockwork,
		/obj/item/stack/tile/bronze,
		/obj/item/gun/ballistic/bow/clockwork,
	)

/datum/armor/suit_clockwork
	melee = 50
	bullet = 60
	laser = 30
	energy = 80
	bomb = 80
	bio = 100
	fire = 100
	acid = 100


/obj/item/clothing/suit/clockwork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))


/obj/item/clothing/suit/clockwork/speed
	name = "robes of divinity"
	desc = "A shiny suit, glowing with a vibrant energy. The wearer will be able to move quickly across battlefields, but will be able to withstand less damage before falling."
	icon_state = "clockwork_cuirass_speed"
	slowdown = -0.3
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor_type = /datum/armor/clockwork_speed

/datum/armor/clockwork_speed
	melee = 40
	bullet = 30
	laser = 10
	energy = -20
	bomb = 60
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/suit/clockwork/cloak
	name = "shrouding cloak"
	desc = "A faltering cloak that bends light around it, distorting the user's appearance, making it hard to see them with the naked eye. However, it provides very little protection."
	icon_state = "clockwork_cloak"
	armor_type = /datum/armor/clockwork_cloak
	actions_types = list(/datum/action/item_action/toggle/clock)
	slowdown = 0.4
	resistance_flags = FIRE_PROOF | ACID_PROOF
	/// Is the shroud itself active or not
	var/shroud_active = FALSE
	/// Previous alpha value of the user when removing/disabling the jacket
	var/previous_alpha = 255
	/// Weakref to who is wearing this
	var/datum/weakref/wearer

/datum/armor/clockwork_cloak
	melee = 10
	bullet = 60
	laser = 40
	energy = 20
	bomb = 40
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/suit/clockwork/cloak/Destroy()
	wearer = null

	return ..()


/obj/item/clothing/suit/clockwork/cloak/attack_self(mob/user, modifiers)
	. = ..()
	if(shroud_active)
		disable()

	else
		enable()


/obj/item/clothing/suit/clockwork/cloak/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_OCLOTHING || !IS_CLOCK(user))
		return

	wearer = user

	if(shroud_active)
		enable()


/obj/item/clothing/suit/clockwork/cloak/dropped(mob/user)
	. = ..()
	if(shroud_active)
		disable()

	wearer = null


/// Apply the effects to the wearer, making them pretty hard to see
/obj/item/clothing/suit/clockwork/cloak/proc/enable()

	shroud_active = TRUE
	previous_alpha = wearer.alpha
	animate(wearer, alpha = 90, time = 3 SECONDS)
	apply_wibbly_filters(wearer)
	ADD_TRAIT(wearer, TRAIT_UNKNOWN, CLOTHING_TRAIT)


/// Un-apply the effects of the cloak, returning the wearer to normal
/obj/item/clothing/suit/clockwork/cloak/proc/disable()

	shroud_active = FALSE
	do_sparks(3, FALSE, wearer)
	remove_wibbly_filters(wearer)
	animate(wearer, alpha = previous_alpha, time = 3 SECONDS)
	REMOVE_TRAIT(wearer, TRAIT_UNKNOWN, CLOTHING_TRAIT)


/obj/item/clothing/glasses/clockwork
	name = "base clock glasses"
	icon = 'monkestation/icons/obj/clock_cult/clockwork_garb.dmi'
	worn_icon = 'monkestation/icons/mob/clock_cult/clockwork_garb_worn.dmi'
	icon_state = "clockwork_cuirass"
	/// What additional desc to show if the person examining is a clock cultist
	var/clock_desc = ""


/obj/item/clothing/glasses/clockwork/examine(mob/user)
	. = ..()
	AddElement(/datum/element/clockwork_description, clock_desc) //why are these being called here?
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))


// Thermal goggles, no protection from eye stuff
/obj/item/clothing/glasses/clockwork/wraith_spectacles
	name = "wraith spectacles"
	desc = "Mystical glasses that glow with a bright energy. Some say they can see things that shouldn't be seen."
	icon_state = "wraith_specs_0"
	base_icon_state = "wraith_specs"
	invis_view = SEE_INVISIBLE_OBSERVER
	invis_override = null
	flash_protect = FLASH_PROTECTION_SENSITIVE
	vision_flags = SEE_MOBS
	color_cutoffs = list(5, 15, 5)
	glass_colour_type = /datum/client_colour/glass_colour/yellow
	actions_types = list(/datum/action/item_action/toggle/clock)
	clock_desc = "Applies passive eye damage that regenerates after unequipping, grants thermal vision, and lets you see all forms of invisibility."
	/// Who is currently wearing the goggles
	var/mob/living/wearer
	/// Are the glasses enabled (flipped down)
	var/enabled = TRUE


/obj/item/clothing/glasses/clockwork/wraith_spectacles/Initialize(mapload)
	. = ..()
	update_icon_state()


/obj/item/clothing/glasses/clockwork/wraith_spectacles/Destroy()
	STOP_PROCESSING(SSobj, src)
	wearer = null
	return ..()


/obj/item/clothing/glasses/clockwork/wraith_spectacles/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[!enabled]"
	worn_icon_state = "[base_icon_state]_[!enabled]"


/obj/item/clothing/glasses/clockwork/wraith_spectacles/attack_self(mob/user, modifiers)
	. = ..()
	if(enabled)
		disable()
	else
		enable()

	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.head_update(src, forced = TRUE)


/// "enable" the spectacles, flipping them down and applying their effects, calling on_toggle_eyes() if someone is wearing them
/obj/item/clothing/glasses/clockwork/wraith_spectacles/proc/enable()
	enabled = TRUE
	color_cutoffs = list(15, 12, 0)
	visor_toggling()

	if(wearer)
		on_toggle_eyes()

	update_icon_state()
	wearer.update_sight()


/// "disable" the spectacles, flipping them up and removing all applied effects
/obj/item/clothing/glasses/clockwork/wraith_spectacles/proc/disable()
	enabled = FALSE
	color_cutoffs = null
	visor_toggling() //this doesn't remove everything, check later

	if(wearer)
		de_toggle_eyes()

	update_icon_state()
	wearer.update_sight()


/// The start of application of the actual effects, including eye damage
/obj/item/clothing/glasses/clockwork/wraith_spectacles/proc/on_toggle_eyes()
	wearer.update_sight()
	to_chat(wearer, span_clockgray("You suddenly see so much more."))


/// The stopping of effect application, will remove the wearer's eye damage a minute after
/obj/item/clothing/glasses/clockwork/wraith_spectacles/proc/de_toggle_eyes()
	wearer.update_sight()
	to_chat(wearer, span_clockgray("You feel your eyes slowly readjusting."))


/obj/item/clothing/glasses/clockwork/wraith_spectacles/equipped(mob/living/user, slot)
	. = ..()
	if(!isliving(user))
		return

	if((slot == ITEM_SLOT_EYES) && enabled)
		wearer = user
		on_toggle_eyes()


/obj/item/clothing/glasses/clockwork/wraith_spectacles/dropped(mob/user)
	. = ..()
	if(wearer && (IS_CLOCK(user)) && enabled)
		de_toggle_eyes()

	wearer = null


// Flash protected and generally info-granting with huds
/obj/item/clothing/glasses/clockwork/judicial_visor
	name = "judicial visor"
	desc = "A purple visor gilt with Ratvarian runes, allowing a user to see, unfettered by others. The cogs on the sides look pretty tight..."
	icon_state = "judicial_visor_0"
	base_icon_state = "judicial_visor"
	flash_protect = FLASH_PROTECTION_WELDER
	strip_delay = 10 SECONDS
	glass_colour_type = /datum/client_colour/glass_colour/purple
	actions_types = list(/datum/action/item_action/toggle/clock)
	clock_desc = "Grants large sight and informational benefits to servants while active."
	/// Is this enabled
	var/enabled = TRUE
	/// Ref to the wearer of the visor
	var/mob/living/wearer


/obj/item/clothing/glasses/clockwork/judicial_visor/Initialize(mapload)
	. = ..()
	update_icon_state()


/obj/item/clothing/glasses/clockwork/judicial_visor/Destroy()
	wearer = null
	return ..()


/obj/item/clothing/glasses/clockwork/judicial_visor/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[enabled]"
	worn_icon_state = "[base_icon_state]_[enabled]"


/obj/item/clothing/glasses/clockwork/judicial_visor/attack_self(mob/user, modifiers)
	. = ..()
	if(enabled)
		disable()
	else
		enable()

	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.head_update(src, forced = TRUE)


/// Turn on the visor, calling apply_to_wearer() and changing the icon state
/obj/item/clothing/glasses/clockwork/judicial_visor/proc/enable()
	enabled = TRUE
	if(wearer)
		apply_to_wearer()

	update_icon_state()


/// Turn off the visor, calling unapply_to_wearer() and changing the icon state
/obj/item/clothing/glasses/clockwork/judicial_visor/proc/disable()
	enabled = FALSE
	if(wearer)
		unapply_to_wearer()

	update_icon_state()

//THIS IS MOST LIKELY BREAKING
/// Applies the actual effects to the wearer, giving them flash protection and a variety of sight/info bonuses
/obj/item/clothing/glasses/clockwork/judicial_visor/proc/apply_to_wearer()
	ADD_TRAIT(wearer, TRAIT_NOFLASH, CLOTHING_TRAIT)

	ADD_TRAIT(wearer, TRAIT_MEDICAL_HUD, CLOTHING_TRAIT)
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.show_to(wearer)

	ADD_TRAIT(wearer, TRAIT_SECURITY_HUD, CLOTHING_TRAIT)
	var/datum/atom_hud/sec_hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	sec_hud.show_to(wearer)

	ADD_TRAIT(wearer, TRAIT_MADNESS_IMMUNE, CLOTHING_TRAIT)
	ADD_TRAIT(wearer, TRAIT_KNOW_CYBORG_WIRES, CLOTHING_TRAIT)
	color_cutoffs = list(50, 10, 30)
	wearer.update_sight()

/// Removes the effects to the wearer, removing the flash protection and similar
/obj/item/clothing/glasses/clockwork/judicial_visor/proc/unapply_to_wearer()
	REMOVE_TRAIT(wearer, TRAIT_NOFLASH, CLOTHING_TRAIT)

	REMOVE_TRAIT(wearer, TRAIT_MEDICAL_HUD, CLOTHING_TRAIT)
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.hide_from(wearer)

	REMOVE_TRAIT(wearer, TRAIT_SECURITY_HUD, CLOTHING_TRAIT)
	var/datum/atom_hud/sec_hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	sec_hud.hide_from(wearer)

	REMOVE_TRAIT(wearer, TRAIT_MADNESS_IMMUNE, CLOTHING_TRAIT)
	REMOVE_TRAIT(wearer, TRAIT_KNOW_CYBORG_WIRES, CLOTHING_TRAIT)
	color_cutoffs = null
	wearer.update_sight()


/obj/item/clothing/glasses/clockwork/judicial_visor/equipped(mob/living/user, slot)
	. = ..()
	if(!isliving(user))
		return

	if(slot == ITEM_SLOT_EYES)
		wearer = user
		if(enabled)
			apply_to_wearer()

/obj/item/clothing/glasses/clockwork/judicial_visor/dropped(mob/user)
	..()
	if(wearer)
		unapply_to_wearer()
		wearer = null

/obj/item/clothing/head/helmet/clockwork
	name = "brass helmet"
	desc = "A strong, brass helmet worn by the soldiers of the Ratvarian armies. Includes an integrated light-dimmer for flash protection, as well as occult-grade muffling for factory based environments."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_garb.dmi'
	worn_icon = 'monkestation/icons/mob/clock_cult/clockwork_garb_worn.dmi'
	icon_state = "clockwork_helmet"
	armor_type = /datum/armor/helmet_clockwork
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	flash_protect = FLASH_PROTECTION_FLASH

/datum/armor/helmet_clockwork
	melee = 50
	bullet = 60
	laser = 30
	energy = 80
	bomb = 80
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/head/helmet/clockwork/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_HEAD))
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))


/obj/item/clothing/shoes/clockwork
	name = "brass treads"
	desc = "A strong pair of brass boots worn by the soldiers of the Ratvarian armies."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_garb.dmi'
	worn_icon = 'monkestation/icons/mob/clock_cult/clockwork_garb_worn.dmi'
	icon_state = "clockwork_treads"

/obj/item/clothing/shoes/clockwork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))


/obj/item/clothing/gloves/clockwork
	name = "brass gauntlets"
	desc = "A strong pair of brass gloves worn by the soldiers of the Ratvarian armies."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_garb.dmi'
	worn_icon = 'monkestation/icons/mob/clock_cult/clockwork_garb_worn.dmi'
	icon_state = "clockwork_gauntlets"
	siemens_coefficient = 0
	strip_delay = 8 SECONDS
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_clockwork

/datum/armor/gloves_clockwork
	melee = 10
	bullet = 0
	laser = 0
	energy = 0
	bomb = 10
	bio = 80
	fire = 80
	acid = 50

/obj/item/clothing/gloves/clockwork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))
