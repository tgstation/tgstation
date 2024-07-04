#define CLOAK_DODGE_CHANCE 20
/obj/item/clothing/suit/clockwork
	name = "bronze armor"
	desc = "A strong, bronze suit worn by the soldiers of the Ratvarian armies."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_garb.dmi'
	worn_icon = 'monkestation/icons/mob/clock_cult/clockwork_garb_worn.dmi'
	icon_state = "clockwork_cuirass"
	armor_type = /datum/armor/suit_clockwork
	slowdown = 0.2
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(
		/obj/item/clockwork,
		/obj/item/stack/tile/bronze,
		/obj/item/gun/ballistic/bow/clockwork,
	)
	///what is the value of our slowdown while empowered
	var/empowered_slowdown = 0
	///what armor type do we use while empowered
	var/datum/armor/empowered_armor = /datum/armor/suit_clockwork_empowered

/datum/armor/suit_clockwork
	melee = 25
	bullet = 30
	laser = 15
	energy = 30
	bomb = 80
	bio = 100
	fire = 100
	acid = 100

/datum/armor/suit_clockwork_empowered
	melee = 50
	bullet = 50
	laser = 40
	energy = 60
	bomb = 80
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/suit/clockwork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))
	AddComponent(/datum/component/turf_checker, GLOB.clock_turf_types, null, TRUE, PROC_REF(set_empowered_state))

/obj/item/clothing/suit/clockwork/proc/set_empowered_state(datum/component/turf_checker/checker, empowered)
	if(empowered)
		set_armor(empowered_armor)
		slowdown = empowered_slowdown
		return

	set_armor(initial(armor_type))
	slowdown = initial(slowdown)

/obj/item/clothing/suit/clockwork/speed
	name = "robes of divinity"
	desc = "A shiny suit, glowing with a vibrant energy. The wearer will be able to move quickly across battlefields, but will be able to withstand less damage before falling."
	icon_state = "clockwork_cuirass_speed"
	slowdown = -0.2
	armor_type = /datum/armor/clockwork_speed
	empowered_armor = /datum/armor/clockwork_speed_empowered
	empowered_slowdown = -0.6

/datum/armor/clockwork_speed
	melee = 20
	bullet = 0
	laser = 0
	energy = 0
	bomb = 60
	bio = 100
	fire = 100
	acid = 100

/datum/armor/clockwork_speed_empowered
	melee = 30
	bullet = 40
	laser = -20
	energy = -20
	bomb = 60
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/suit/clockwork/cloak
	name = "shrouding cloak"
	desc = "A faltering cloak that bends light around it, distorting the user's appearance, making it hard to see them with the naked eye and be harder to hit. \
			However, it provides very little physical protection."
	icon_state = "clockwork_cloak"
	armor_type = /datum/armor/clockwork_cloak
	actions_types = list(/datum/action/item_action/toggle/clock)
	w_class = WEIGHT_CLASS_NORMAL
	empowered_armor = /datum/armor/clockwork_cloak
	empowered_slowdown = -0.1
	/// Is the shroud itself active or not
	var/shroud_active = FALSE
	/// Previous alpha value of the user when removing/disabling the jacket
	var/previous_alpha = 255
	/// Ref to who is wearing this
	var/mob/living/wearer
	/// Are we currently empowered
	var/is_empowered = FALSE

/datum/armor/clockwork_cloak
	melee = 15
	bullet = 30
	laser = 20
	energy = 15
	bomb = 50
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/suit/clockwork/cloak/set_empowered_state(datum/component/turf_checker/checker, empowered)
	. = ..()
	is_empowered = empowered
	if(shroud_active && !empowered)
		disable()

/obj/item/clothing/suit/clockwork/cloak/Destroy()
	if(shroud_active)
		disable()
	wearer = null
	return ..()

/obj/item/clothing/suit/clockwork/cloak/attack_self(mob/user, modifiers)
	. = ..()
	if(shroud_active)
		disable()
	else if(is_empowered)
		enable()
	else
		balloon_alert(user, "Must be standing on brass!")

/obj/item/clothing/suit/clockwork/cloak/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_OCLOTHING || !IS_CLOCK(user))
		return

	wearer = user
	if(shroud_active && is_empowered)
		enable()

/obj/item/clothing/suit/clockwork/cloak/dropped(mob/user)
	. = ..()
	if(shroud_active)
		disable()
	wearer = null

/obj/item/clothing/suit/clockwork/cloak/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(is_empowered && shroud_active && prob(CLOAK_DODGE_CHANCE)) //we handle this just a biiiiit too different from parent to make simply using the vars be viable
		owner.visible_message(span_danger("[owner]'s [src] makes them phase out of the way of [attack_text]!"))
		owner.add_filter("clock_cloak", 3, motion_blur_filter(0, 0))
		addtimer(CALLBACK(src, PROC_REF(remove_phase_filter), owner), (0.6 SECONDS) + 1)
		ASYNC
			animate(owner.get_filter("clock_cloak"), 0.3 SECONDS, x = prob(50) ? rand(4, 5) : rand(-4, -5), y = prob(50) ? rand(4, 5) : rand(-4, -5), flags = ANIMATION_PARALLEL)
			animate(time = 0.3 SECONDS, x = 0, y = 0)
		playsound(src, 'sound/weapons/etherealmiss.ogg', BLOCK_SOUND_VOLUME, vary = TRUE, mixer_channel = CHANNEL_SOUND_EFFECTS)
		return TRUE

/obj/item/clothing/suit/clockwork/cloak/proc/remove_phase_filter(mob/living/remove_from)
	if(QDELETED(remove_from))
		return
	remove_from.remove_filter("clock_cloak")

/// Apply the effects to the wearer, making them pretty hard to see
/obj/item/clothing/suit/clockwork/cloak/proc/enable()
	shroud_active = TRUE
	if(!wearer)
		return

	previous_alpha = wearer.alpha
	animate(wearer, alpha = 80, time = 3 SECONDS)
	apply_wibbly_filters(wearer)
	ADD_TRAIT(wearer, TRAIT_UNKNOWN, CLOTHING_TRAIT)

/// Un-apply the effects of the cloak, returning the wearer to normal
/obj/item/clothing/suit/clockwork/cloak/proc/disable()
	shroud_active = FALSE
	if(!wearer)
		return

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

/obj/item/clothing/glasses/clockwork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_description, clock_desc)
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))

#define SECONDS_FOR_EYE_HEAL 60
// Thermal goggles, no protection from eye stuff
/obj/item/clothing/glasses/clockwork/wraith_spectacles
	name = "wraith spectacles"
	desc = "Mystical glasses that glow with a bright energy. Some say they can see things that shouldn't be seen."
	icon_state = "wraith_specs_0"
	base_icon_state = "wraith_specs"
	invis_override = SEE_INVISIBLE_OBSERVER
	flash_protect = FLASH_PROTECTION_SENSITIVE
	vision_flags = SEE_MOBS
	color_cutoffs = list(20, 16, 0)
	glass_colour_type = /datum/client_colour/glass_colour/yellow
	actions_types = list(/datum/action/item_action/toggle/clock)
	clock_desc = "Applies passive eye damage that regenerates after unequipping, grants thermal vision, and lets you see all forms of invisibility."
	/// Who is currently wearing the goggles
	var/mob/living/wearer
	/// Are the glasses enabled (flipped down)
	var/enabled = TRUE
	/// List of mobs we have delt eye damage to as well as how much damage we have delt to them and a counter for how close to healing that damage we are
	var/list/damaged_mobs = list()


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
	color_cutoffs = list(20, 16, 0)
	invis_override = SEE_INVISIBLE_OBSERVER
	vision_flags = SEE_MOBS

	if(wearer)
		on_toggle_eyes()

	update_icon_state()


/// "disable" the spectacles, flipping them up and removing all applied effects
/obj/item/clothing/glasses/clockwork/wraith_spectacles/proc/disable()
	enabled = FALSE
	color_cutoffs = null
	invis_override = null
	vision_flags = NONE

	if(wearer)
		de_toggle_eyes()

	update_icon_state()


/// The start of application of the actual effects like eye damage
/obj/item/clothing/glasses/clockwork/wraith_spectacles/proc/on_toggle_eyes()
	wearer.update_sight()
	to_chat(wearer, span_clockgray("You suddenly see so much more, but your eyes begin to falter."))
	START_PROCESSING(SSobj, src)
	if(!damaged_mobs[wearer])
		damaged_mobs[wearer] = list("damage" = 0, "timer" = 0)
	else
		var/wearer_data = damaged_mobs[wearer]
		wearer_data["timer"] = 0


/// The stopping of effect application, will remove the wearer's eye damage a minute after, eye damage removal is handled by process() to avoid a large amount of timers
/obj/item/clothing/glasses/clockwork/wraith_spectacles/proc/de_toggle_eyes()
	wearer.update_sight()
	to_chat(wearer, span_clockgray("You feel your eyes slowly readjusting."))


/obj/item/clothing/glasses/clockwork/wraith_spectacles/process(seconds_per_tick)
	if(enabled && wearer)
		var/delt_damage = 0.5 * seconds_per_tick
		wearer.adjustOrganLoss(ORGAN_SLOT_EYES, delt_damage, 70)
		if(damaged_mobs[wearer])
			var/wearer_data = damaged_mobs[wearer]
			wearer_data["damage"] = min(wearer_data["damage"] + delt_damage, 70)

	for(var/mob_entry in damaged_mobs)
		if(enabled && mob_entry == wearer)
			continue
		var/mob_data = damaged_mobs[mob_entry]
		mob_data["timer"] += seconds_per_tick
		if(mob_data["timer"] >= SECONDS_FOR_EYE_HEAL)
			var/mob/living/living_healed = mob_entry
			living_healed.adjustOrganLoss(ORGAN_SLOT_EYES, -mob_data["damage"])
			damaged_mobs -= mob_entry

	if(!damaged_mobs.len)
		STOP_PROCESSING(SSobj, src)


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
#undef SECONDS_FOR_EYE_HEAL


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
	ADD_TRAIT(wearer, TRAIT_MEDICAL_HUD, CLOTHING_TRAIT)
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.show_to(wearer)

	ADD_TRAIT(wearer, TRAIT_SECURITY_HUD, CLOTHING_TRAIT)
	var/datum/atom_hud/sec_hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	sec_hud.show_to(wearer)

	add_traits(list(TRAIT_KNOW_ENGI_WIRES, TRAIT_MADNESS_IMMUNE, TRAIT_MESON_VISION, TRAIT_KNOW_CYBORG_WIRES, TRAIT_NOFLASH), CLOTHING_TRAIT)
	color_cutoffs = list(50, 10, 30)
	wearer.update_sight()

/// Removes the effects to the wearer, removing the flash protection and similar
/obj/item/clothing/glasses/clockwork/judicial_visor/proc/unapply_to_wearer()
	REMOVE_TRAIT(wearer, TRAIT_MEDICAL_HUD, CLOTHING_TRAIT)
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.hide_from(wearer)

	REMOVE_TRAIT(wearer, TRAIT_SECURITY_HUD, CLOTHING_TRAIT)
	var/datum/atom_hud/sec_hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	sec_hud.hide_from(wearer)

	remove_traits(list(TRAIT_KNOW_ENGI_WIRES, TRAIT_MADNESS_IMMUNE, TRAIT_MESON_VISION, TRAIT_KNOW_CYBORG_WIRES, TRAIT_NOFLASH), CLOTHING_TRAIT)
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
	desc = "A strong, brass helmet worn by the soldiers of the Ratvarian armies. Includes an integrated light-dimmer for flash protection, \
			as well as occult-grade muffling for factory based environments."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_garb.dmi'
	worn_icon = 'monkestation/icons/mob/clock_cult/clockwork_garb_worn.dmi'
	icon_state = "clockwork_helmet"
	armor_type = /datum/armor/helmet_clockwork
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	flash_protect = FLASH_PROTECTION_FLASH

/datum/armor/helmet_clockwork
	melee = 25
	bullet = 30
	laser = 15
	energy = 40
	bomb = 80
	bio = 100
	fire = 100
	acid = 100

/datum/armor/helmet_clockwork_empowered
	melee = 50
	bullet = 55
	laser = 35
	energy = 70
	bomb = 80
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/head/helmet/clockwork/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_HEAD))
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))
	AddComponent(/datum/component/turf_checker, GLOB.clock_turf_types, null, TRUE, PROC_REF(set_empowered_state))

/obj/item/clothing/head/helmet/clockwork/proc/set_empowered_state(datum/component/turf_checker/checker, empowered)
	empowered ? set_armor(/datum/armor/helmet_clockwork_empowered) : initial(armor_type)

/obj/item/clothing/shoes/clockwork
	name = "brass treads"
	desc = "A strong pair of brass boots worn by the soldiers of the Ratvarian armies."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_garb.dmi'
	worn_icon = 'monkestation/icons/mob/clock_cult/clockwork_garb_worn.dmi'
	icon_state = "clockwork_treads"
	resistance_flags = FIRE_PROOF | ACID_PROOF

/datum/armor/boots_clockwork
	melee = 0
	bullet = 0
	laser = 0
	energy = 0
	bomb = 0
	bio = 100
	fire = 80
	acid = 100

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
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor_type = /datum/armor/gloves_clockwork

/datum/armor/gloves_clockwork
	melee = 10
	bullet = 0
	laser = 0
	energy = 0
	bomb = 10
	bio = 80
	fire = 80
	acid = 100

/obj/item/clothing/gloves/clockwork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_pickup, ~(ITEM_SLOT_HANDS))

#undef CLOAK_DODGE_CHANCE
