/obj/item/clothing
	name = "clothing"
	abstract_type = /obj/item/clothing
	resistance_flags = FLAMMABLE
	max_integrity = 200
	integrity_failure = 0.4
	var/damaged_clothes = CLOTHING_PRISTINE //similar to machine's BROKEN stat and structure's broken var

	///What level of bright light protection item has.
	var/flash_protect = FLASH_PROTECTION_NONE
	var/tint = 0 //Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = FALSE //but separated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = NONE //flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = NONE //same as visor_flags, but for flags_inv
	var/visor_flags_cover = NONE //same as above, but for flags_cover
	///What to toggle when toggled with adjust_visor()
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_VISIONFLAGS | VISOR_INVISVIEW
	///Sound this item makes when its visor is flipped down
	var/visor_toggle_down_sound = null
	///Sound this item makes when its visor is flipped up
	var/visor_toggle_up_sound = null
	///chat message when the visor is toggled down.
	var/toggle_message
	///chat message when the visor is toggled up.
	var/alt_toggle_message

	var/clothing_flags = NONE
	///List of items that can be equipped in the suit storage slot while we're worn.
	var/list/allowed

	var/can_be_bloody = TRUE

	///Prevents the article of clothing from gaining the mood boost from washing. Used for the tacticool turtleneck.
	var/stubborn_stains = FALSE

	/// What items can be consumed to repair this clothing (must by an /obj/item/stack)
	var/repairable_by = /obj/item/stack/sheet/cloth

	//Var modification - PLEASE be careful with this I know who you are and where you live
	var/list/user_vars_to_edit //VARNAME = VARVALUE eg: "name" = "butts"
	var/list/user_vars_remembered //Auto built by the above + dropped() + equipped()

	/// Trait modification, lazylist of traits to add/take away, on equipment/drop in the correct slot
	var/list/clothing_traits

	/// How much clothing damage has been dealt to each of the limbs of the clothing, assuming it covers more than one limb
	var/list/damage_by_parts
	/// How much integrity is in a specific limb before that limb is disabled (for use in [/obj/item/clothing/proc/take_damage_zone], and only if we cover multiple zones.) Set to 0 to disable shredding.
	var/limb_integrity = 0
	/// How many zones (body parts, not precise) we have disabled so far, for naming purposes
	var/zones_disabled

	/// A lazily initiated "food" version of the clothing for moths.
	// This intentionally does not use the edible component, for a few reasons.
	// 1. Effectively everything that wants something edible, from now and into the future,
	// does not want to receive clothing, simply because moths *can* eat it.
	// 2. Creating this component for all clothing has a non-negligible impact on init times and memory.
	// 3. Creating the component contextually to solve #2 will make #1 much more confusing,
	// and frankly not be a better solution than what we are doing now.
	// The first issue could be solved if "edible" checks were more granular,
	// such that you never actually cared about checking if something is *edible*.
	var/obj/item/food/clothing/moth_snack

/obj/item/clothing/Initialize(mapload)
	if(clothing_flags & VOICEBOX_TOGGLABLE)
		actions_types += list(/datum/action/item_action/toggle_voice_box)
	. = ..()
	AddElement(/datum/element/venue_price, FOOD_PRICE_CHEAP)
	if(can_be_bloody && ((body_parts_covered & FEET) || (flags_inv & HIDESHOES)))
		LoadComponent(/datum/component/bloodysoles)
	AddElement(/datum/element/attack_equip)
	if(!icon_state)
		item_flags |= ABSTRACT

/obj/item/clothing/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	var/mob/M = user

	if(ismecha(M.loc)) // stops inventory actions in a mech
		return

	if(loc == M && istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
			add_fingerprint(user)

/obj/item/food/clothing
	name = "temporary moth clothing snack item"
	desc = "If you're reading this it means I messed up. This is related to moths eating clothes and I didn't know a better way to do it than making a new food object. <--- stinky idiot wrote this"
	spawn_blacklisted = TRUE
	bite_consumption = 1
	// sigh, ok, so it's not ACTUALLY infinite nutrition. this is so you can eat clothes more than...once.
	// bite_consumption limits how much you actually get, and the take_damage in after eat makes sure you can't abuse this.
	// ...maybe this was a mistake after all.
	food_reagents = list(/datum/reagent/consumable/nutriment/cloth_fibers = INFINITY)
	tastes = list("dust" = 1, "lint" = 1)
	foodtypes = CLOTH

	/// A weak reference to the clothing that created us
	var/datum/weakref/clothing

/obj/item/food/clothing/make_edible()
	. = ..()
	AddComponentFrom(SOURCE_EDIBLE_INNATE, /datum/component/edible, after_eat = CALLBACK(src, PROC_REF(after_eat)))

/obj/item/food/clothing/proc/after_eat(mob/eater)
	var/obj/item/clothing/resolved_clothing = clothing.resolve()
	if (resolved_clothing)
		resolved_clothing.take_damage(MOTH_EATING_CLOTHING_DAMAGE, sound_effect = FALSE, damage_flag = CONSUME)
	else
		qdel(src)

/obj/item/clothing/attack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.combat_mode || !ismoth(target) || ispickedupmob(src))
		return ..()
	if((clothing_flags & INEDIBLE_CLOTHING) || (resistance_flags & INDESTRUCTIBLE))
		return ..()
	if(isnull(moth_snack))
		create_moth_snack()
	moth_snack.attack(target, user, modifiers)

/// Creates a food object in null space which we can eat and imagine we're eating this pair of shoes
/obj/item/clothing/proc/create_moth_snack()
	moth_snack = new
	moth_snack.name = name
	moth_snack.clothing = WEAKREF(src)

/obj/item/clothing/item_interaction(mob/living/user, obj/item/weapon, list/modifiers)
	. = NONE
	if(!istype(weapon, repairable_by))
		return

	switch(damaged_clothes)
		if(CLOTHING_PRISTINE)
			return

		if(CLOTHING_DAMAGED)
			var/obj/item/stack/cloth_repair = weapon
			cloth_repair.use(1)
			repair(user)
			return ITEM_INTERACT_SUCCESS

		if(CLOTHING_SHREDDED)
			var/obj/item/stack/cloth_repair = weapon
			if(cloth_repair.amount < 3)
				to_chat(user, span_warning("You require 3 [cloth_repair.name] to repair [src]."))
				return ITEM_INTERACT_BLOCKING
			to_chat(user, span_notice("You begin fixing the damage to [src] with [cloth_repair]..."))
			if(!do_after(user, 6 SECONDS, src) || !cloth_repair.use(3))
				return ITEM_INTERACT_BLOCKING
			repair(user)
			return ITEM_INTERACT_SUCCESS

/// Set the clothing's integrity back to 100%, remove all damage to bodyparts, and generally fix it up
/obj/item/clothing/proc/repair(mob/user)
	update_clothes_damaged_state(CLOTHING_PRISTINE)
	atom_integrity = max_integrity
	name = initial(name) // remove "tattered" or "shredded" if there's a prefix
	body_parts_covered = initial(body_parts_covered)
	slot_flags = initial(slot_flags)
	damage_by_parts = null
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		to_chat(user, span_notice("You fix the damage on [src]."))
	update_appearance()

/**
 * take_damage_zone() is used for dealing damage to specific bodyparts on a worn piece of clothing, meant to be called from [/obj/item/bodypart/proc/check_woundings_mods]
 *
 * This proc only matters when a bodypart that this clothing is covering is harmed by a direct attack (being on fire or in space need not apply), and only if this clothing covers
 * more than one bodypart to begin with. No point in tracking damage by zone for a hat, and I'm not cruel enough to let you fully break them in a few shots.
 * Also if limb_integrity is 0, then this clothing doesn't have bodypart damage enabled so skip it.
 *
 * Arguments:
 * * def_zone: The bodypart zone in question
 * * damage_amount: Incoming damage
 * * damage_type: BRUTE or BURN
 * * armour_penetration: If the attack had armour_penetration
 */
/obj/item/clothing/proc/take_damage_zone(def_zone, damage_amount, damage_type, armour_penetration)
	if(!def_zone || !limb_integrity || (initial(body_parts_covered) in GLOB.bitflags)) // the second check sees if we only cover one bodypart anyway and don't need to bother with this
		return
	var/list/covered_limbs = cover_flags2body_zones(body_parts_covered) // what do we actually cover?
	if(!(def_zone in covered_limbs))
		return

	var/damage_dealt = take_damage(damage_amount * 0.1, damage_type, armour_penetration, FALSE) * 10 // only deal 10% of the damage to the general integrity damage, then multiply it by 10 so we know how much to deal to limb
	LAZYINITLIST(damage_by_parts)
	damage_by_parts[def_zone] += damage_dealt
	if(damage_by_parts[def_zone] > limb_integrity)
		disable_zone(def_zone, damage_type)

/**
 * disable_zone() is used to disable a given bodypart's protection on our clothing item, mainly from [/obj/item/clothing/proc/take_damage_zone]
 *
 * This proc disables all protection on the specified bodypart for this piece of clothing: it'll be as if it doesn't cover it at all anymore (because it won't!)
 * If every possible bodypart has been disabled on the clothing, we put it out of commission entirely and mark it as shredded, whereby it will have to be repaired in
 * order to equip it again. Also note we only consider it damaged if there's more than one bodypart disabled.
 *
 * Arguments:
 * * def_zone: The bodypart zone we're disabling
 * * damage_type: Only really relevant for the verb for describing the breaking, and maybe atom_destruction()
 */
/obj/item/clothing/proc/disable_zone(def_zone, damage_type)
	var/list/covered_limbs = cover_flags2body_zones(body_parts_covered)
	if(!(def_zone in covered_limbs))
		return

	var/zone_name
	var/break_verb = ((damage_type == BRUTE) ? "torn" : "burned")

	if(iscarbon(loc))
		var/mob/living/carbon/carbon_loc = loc
		zone_name = carbon_loc.parse_zone_with_bodypart(def_zone)
		carbon_loc.visible_message(span_danger("The [zone_name] on [carbon_loc]'s [src.name] is [break_verb] away!"), span_userdanger("The [zone_name] on your [src.name] is [break_verb] away!"), vision_distance = COMBAT_MESSAGE_RANGE)
		RegisterSignal(carbon_loc, COMSIG_MOVABLE_MOVED, PROC_REF(bristle), override = TRUE)
	else
		zone_name = parse_zone(def_zone)

	zones_disabled++
	body_parts_covered &= ~body_zone2cover_flags(def_zone)

	if(body_parts_covered == NONE) // if there are no more parts to break then the whole thing is kaput
		atom_destruction((damage_type == BRUTE ? MELEE : LASER)) // melee/laser is good enough since this only procs from direct attacks anyway and not from fire/bombs
		return

	switch(zones_disabled)
		if(1)
			name = "damaged [initial(name)]"
		if(2)
			name = "mangy [initial(name)]"
		if(3 to INFINITY) // take better care of your shit, dude
			name = "tattered [initial(name)]"

	update_clothes_damaged_state(CLOTHING_DAMAGED)
	update_appearance()

/obj/item/clothing/Destroy()
	user_vars_remembered = null //Oh god somebody put REFERENCES in here? not to worry, we'll clean it up
	QDEL_NULL(moth_snack)
	return ..()

/obj/item/clothing/dropped(mob/living/user)
	..()
	if(!istype(user))
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	for(var/trait in clothing_traits)
		REMOVE_CLOTHING_TRAIT(user, trait)
	if(iscarbon(user) && tint)
		var/mob/living/carbon/carbon_user = user
		carbon_user.update_tint()
	if(LAZYLEN(user_vars_remembered))
		for(var/variable in user_vars_remembered)
			if(variable in user.vars)
				if(user.vars[variable] == user_vars_to_edit[variable]) //Is it still what we set it to? (if not we best not change it)
					user.vars[variable] = user_vars_remembered[variable]
		user_vars_remembered = initial(user_vars_remembered) // Effectively this sets it to null.

/obj/item/clothing/equipped(mob/living/user, slot)
	. = ..()
	if (!istype(user))
		return
	if(slot_flags & slot) //Was equipped to a valid slot for this item?
		if(iscarbon(user) && LAZYLEN(zones_disabled))
			RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(bristle), override = TRUE)
		for(var/trait in clothing_traits)
			ADD_CLOTHING_TRAIT(user, trait)
		if(iscarbon(user) && tint)
			var/mob/living/carbon/carbon_user = user
			carbon_user.update_tint()
		if (LAZYLEN(user_vars_to_edit))
			for(var/variable in user_vars_to_edit)
				if(variable in user.vars)
					LAZYSET(user_vars_remembered, variable, user.vars[variable])
					user.vv_edit_var(variable, user_vars_to_edit[variable])

// If the item is a piece of clothing and is being worn, make sure it updates on the player
/obj/item/clothing/update_greyscale()
	. = ..()

	var/mob/living/carbon/human/wearer = loc

	if(!istype(wearer))
		return

	wearer.update_clothing(slot_flags)

/**
 * Inserts a trait (or multiple traits) into the clothing traits list
 *
 * If worn, then we will also give the wearer the trait as if equipped
 *
 * This is so you can add clothing traits without worrying about needing to equip or unequip them to gain effects
 */
/obj/item/clothing/proc/attach_clothing_traits(trait_or_traits)
	if(!islist(trait_or_traits))
		trait_or_traits = list(trait_or_traits)

	LAZYOR(clothing_traits, trait_or_traits)
	var/mob/wearer = loc
	if(istype(wearer) && (wearer.get_slot_by_item(src) & slot_flags))
		for(var/new_trait in trait_or_traits)
			ADD_CLOTHING_TRAIT(wearer, new_trait)

/**
 * Removes a trait (or multiple traits) from the clothing traits list
 *
 * If worn, then we will also remove the trait from the wearer as if unequipped
 *
 * This is so you can add clothing traits without worrying about needing to equip or unequip them to gain effects
 */
/obj/item/clothing/proc/detach_clothing_traits(trait_or_traits)
	if(!islist(trait_or_traits))
		trait_or_traits = list(trait_or_traits)

	LAZYREMOVE(clothing_traits, trait_or_traits)
	var/mob/wearer = loc
	if(istype(wearer))
		for(var/new_trait in trait_or_traits)
			REMOVE_CLOTHING_TRAIT(wearer, new_trait)

/obj/item/clothing/examine(mob/user)
	. = ..()
	if(damaged_clothes == CLOTHING_SHREDDED)
		. += span_warning("<b>[p_Theyre()] completely shredded and require[p_s()] mending before [p_they()] can be worn again!</b>")
		return

	if(TRAIT_FAST_CUFFING in clothing_traits)
		. += "[src] increase the speed that you handcuff others."

	for(var/zone in damage_by_parts)
		var/pct_damage_part = damage_by_parts[zone] / limb_integrity * 100
		var/zone_name = parse_zone(zone)
		switch(pct_damage_part)
			if(100 to INFINITY)
				. += span_warning("<b>The [zone_name] is useless and requires mending!</b>")
			if(60 to 99)
				. += span_warning("The [zone_name] is heavily shredded!")
			if(30 to 59)
				. += span_danger("The [zone_name] is partially shredded.")

	if(atom_storage)
		var/list/how_cool_are_your_threads = list("<span class='notice'>")
		if(atom_storage.attack_hand_interact)
			how_cool_are_your_threads += "[src]'s storage opens when clicked.\n"
		else
			how_cool_are_your_threads += "[src]'s storage opens when dragged to yourself.\n"
		if (atom_storage.can_hold?.len) // If pocket type can hold anything, vs only specific items
			how_cool_are_your_threads += "[src] can store [atom_storage.max_slots] <a href='byond://?src=[REF(src)];show_valid_pocket_items=1'>item\s</a>.\n"
		else
			how_cool_are_your_threads += "[src] can store [atom_storage.max_slots] item\s that are [weight_class_to_text(atom_storage.max_specific_storage)] or smaller.\n"
		if(atom_storage.quickdraw)
			how_cool_are_your_threads += "You can quickly remove an item from [src] using Right-Click.\n"
		if(atom_storage.silent)
			how_cool_are_your_threads += "Adding or removing items from [src] makes no noise.\n"
		how_cool_are_your_threads += "</span>"
		. += how_cool_are_your_threads.Join()

	if(get_armor().has_any_armor() || (flags_cover & (HEADCOVERSMOUTH|PEPPERPROOF)) || (clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
		. += span_notice("It has a <a href='byond://?src=[REF(src)];list_armor=1'>tag</a> listing its protection classes.")

/obj/item/clothing/examine_tags(mob/user)
	. = ..()
	if (clothing_flags & THICKMATERIAL)
		.["thick"] = "Protects from most injections and sprays."
	if (clothing_flags & CASTING_CLOTHES)
		.["magical"] = "Allows magical beings to cast spells when wearing [src]."
	if((clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
		.["pressureproof"] = "Protects the wearer from extremely low or high pressure, such as vacuum of space."
	if(flags_cover & PEPPERPROOF)
		.["pepperproof"] = "Protects the wearer from the effects of pepperspray."
	if (heat_protection || cold_protection)
		var/heat_desc
		var/cold_desc
		switch (max_heat_protection_temperature)
			if (400 to 1000)
				heat_desc = "high"
			if (1001 to 1600)
				heat_desc = "very high"
			if (1601 to 35000)
				heat_desc = "extremely high"
		switch (min_cold_protection_temperature)
			if (160 to 272)
				cold_desc = "low"
			if (72 to 159)
				cold_desc = "very low"
			if (0 to 71)
				cold_desc = "extremely low"
		.["thermally insulated"] = "Protects the wearer from [jointext(list(heat_desc, cold_desc) - null, " and ")] temperatures."

/obj/item/clothing/examine_descriptor(mob/user)
	return "clothing"

/obj/item/clothing/Topic(href, href_list)
	. = ..()

	if(href_list["list_armor"])
		var/list/readout = list()

		var/datum/armor/armor = get_armor()
		var/added_damage_header = FALSE
		for(var/damage_key in ARMOR_LIST_DAMAGE())
			var/rating = armor.get_rating(damage_key)
			if(!rating)
				continue
			if(!added_damage_header)
				readout += "<b><u>ARMOR (I-X)</u></b>"
				added_damage_header = TRUE
			readout += "[armor_to_protection_name(damage_key)] [armor_to_protection_class(rating)]"

		var/added_durability_header = FALSE
		for(var/durability_key in ARMOR_LIST_DURABILITY())
			var/rating = armor.get_rating(durability_key)
			if(!rating)
				continue
			if(!added_durability_header)
				readout += "<b><u>DURABILITY (I-X)</u></b>"
				added_damage_header = TRUE
			readout += "[armor_to_protection_name(durability_key)] [armor_to_protection_class(rating)]"

		if((flags_cover & HEADCOVERSMOUTH) || (flags_cover & PEPPERPROOF))
			var/list/things_blocked = list()
			if(flags_cover & HEADCOVERSMOUTH)
				things_blocked += span_tooltip("Because this item is worn on the head and is covering the mouth, it will block facehugger proboscides, killing facehuggers.", "facehuggers")
			if(flags_cover & PEPPERPROOF)
				things_blocked += "pepperspray"
			if(length(things_blocked))
				readout += "<b><u>COVERAGE</u></b>"
				readout += "It will block [english_list(things_blocked)]."

		if((clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
			var/list/parts_covered = list()
			var/output_string = "It"
			if(!(clothing_flags & STOPSPRESSUREDAMAGE))
				output_string = "When sealed, it"
			if(body_parts_covered & HEAD)
				parts_covered += "head"
			if(body_parts_covered & CHEST)
				parts_covered += "torso"
			if(body_parts_covered & (ARMS|HANDS))
				parts_covered += "arms"
			if(body_parts_covered & (LEGS|FEET))
				parts_covered += "legs"
			if(length(parts_covered))
				readout += "[output_string] will protect the wearer's [english_list(parts_covered)] from [span_tooltip("The extremely low pressure is the biggest danger posed by the vacuum of space.", "low pressure")]."

		var/heat_prot
		switch (max_heat_protection_temperature)
			if (400 to 1000)
				heat_prot = "minor"
			if (1001 to 1600)
				heat_prot = "some"
			if (1601 to 35000)
				heat_prot = "extreme"
		if (heat_prot)
			. += "[src] offers the wearer [heat_protection] protection from heat, up to [max_heat_protection_temperature] kelvin."

		if(min_cold_protection_temperature)
			readout += "It will insulate the wearer from [min_cold_protection_temperature <= SPACE_SUIT_MIN_TEMP_PROTECT ? span_tooltip("While not as dangerous as the lack of pressure, the extremely low temperature of space is also a hazard.", "the cold of space, down to [min_cold_protection_temperature] kelvin") : "cold, down to [min_cold_protection_temperature] kelvin"]."

		if(!length(readout))
			readout += "No armor or durability information available."

		var/formatted_readout = span_notice("<b>PROTECTION CLASSES</b><hr>[jointext(readout, "\n")]")
		to_chat(usr, boxed_message(formatted_readout))

/**
 * Rounds armor_value down to the nearest 10, divides it by 10 and then converts it to Roman numerals.
 *
 * Arguments:
 * * armor_value - Number we're converting
 */
/obj/item/clothing/proc/armor_to_protection_class(armor_value)
	if (armor_value < 0)
		. = "-"
	. += "\Roman[round(abs(armor_value), 10) / 10]"
	return .

/obj/item/clothing/atom_break(damage_flag)
	. = ..()
	update_clothes_damaged_state(CLOTHING_DAMAGED)

	if(isliving(loc)) //It's not important enough to warrant a message if it's not on someone
		var/mob/living/M = loc
		if(src in M.get_equipped_items())
			to_chat(M, span_warning("Your [name] start[p_s()] to fall apart!"))
		else
			to_chat(M, span_warning("[src] start[p_s()] to fall apart!"))

// you just dont get the same feeling with handwashed clothes
/obj/item/clothing/machine_wash()
	. = ..()
	if(stubborn_stains) //Just can't make it feel right
		return

	var/fresh_mood = AddComponent( \
		/datum/component/onwear_mood, \
		saved_event_type = /datum/mood_event/fresh_laundry, \
		examine_string = "[src] looks crisp and pristine.", \
	)

	QDEL_IN(fresh_mood, 2 MINUTES)

//This mostly exists so subtypes can call appriopriate update icon calls on the wearer.
/obj/item/clothing/proc/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	damaged_clothes = damaged_state

/obj/item/clothing/update_overlays()
	. = ..()
	if(!damaged_clothes)
		return

	var/index = "[REF(icon)]-[icon_state]"
	var/static/list/damaged_clothes_icons = list()
	var/icon/damaged_clothes_icon = damaged_clothes_icons[index]
	if(!damaged_clothes_icon)
		damaged_clothes_icon = icon(icon, icon_state, , 1)
		damaged_clothes_icon.Blend("#fff", ICON_ADD) //fills the icon_state with white (except where it's transparent)
		damaged_clothes_icon.Blend(icon('icons/effects/item_damage.dmi', "itemdamaged"), ICON_MULTIPLY) //adds damage effect and the remaining white areas become transparant
		damaged_clothes_icon = fcopy_rsc(damaged_clothes_icon)
		damaged_clothes_icons[index] = damaged_clothes_icon
	. += damaged_clothes_icon

/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
		// in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/

/proc/generate_female_clothing(index, t_color, icon, type)
	var/icon/female_clothing_icon = icon("icon"=icon, "icon_state"=t_color)
	var/female_icon_state = "female[type == FEMALE_UNIFORM_FULL ? "_full" : ((!type || type & FEMALE_UNIFORM_TOP_ONLY) ? "_top" : "")][type & FEMALE_UNIFORM_NO_BREASTS ? "_no_breasts" : ""]"
	var/icon/female_cropping_mask = icon("icon" = 'icons/mob/clothing/under/masking_helpers.dmi', "icon_state" = female_icon_state)
	female_clothing_icon.Blend(female_cropping_mask, ICON_MULTIPLY)
	female_clothing_icon = fcopy_rsc(female_clothing_icon)
	GLOB.female_clothing_icons[index] = female_clothing_icon

/// Proc that adjusts the clothing item, used by things like breathing masks, welding helmets, welding goggles etc.
/obj/item/clothing/proc/adjust_visor(mob/living/user)
	if(!can_use(user))
		return FALSE

	visor_toggling()

	var/message
	if(up)
		message = src.alt_toggle_message || "You push [src] out of the way."
	else
		message = src.toggle_message || "You push [src] back into place."

	to_chat(user, span_notice("[message]"))

	//play sounds when toggling the visor up or down (if there is any)
	if(visor_toggle_up_sound && up)
		playsound(src, visor_toggle_up_sound, 20, TRUE, -1)
	if(visor_toggle_down_sound && !up)
		playsound(src, visor_toggle_down_sound, 20, TRUE, -1)

	update_item_action_buttons()

	if(user.is_holding(src))
		user.update_held_items()
		return TRUE
	user.update_clothing(slot_flags)
	if(!iscarbon(user))
		return TRUE
	var/mob/living/carbon/carbon_user = user
	if(up)
		carbon_user.refresh_obscured()
	if(visor_vars_to_toggle & VISOR_TINT)
		carbon_user.update_tint()
	if((visor_flags & (MASKINTERNALS|HEADINTERNALS)) && carbon_user.invalid_internals())
		carbon_user.cutoff_internals()
	return TRUE

/obj/item/clothing/proc/visor_toggling() //handles all the actual toggling of flags
	up = !up
	SEND_SIGNAL(src, COMSIG_CLOTHING_VISOR_TOGGLE, up)
	clothing_flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= visor_flags_cover
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)
	update_appearance() //most of the time the sprite changes

/obj/item/clothing/proc/can_use(mob/user)
	return istype(user) && !user.incapacitated

/obj/item/clothing/proc/spawn_shreds()
	new /obj/effect/decal/cleanable/shreds(get_turf(src), name)

/obj/item/clothing/atom_destruction(damage_flag)
	if(damage_flag in list(ACID, FIRE))
		return ..()
	if(damage_flag == BOMB)
		//so the shred survives potential turf change from the explosion.
		addtimer(CALLBACK(src, PROC_REF(spawn_shreds)), 0.1 SECONDS)
		deconstruct(FALSE)
	if(damage_flag == CONSUME) //This allows for moths to fully consume clothing, rather than damaging it like other sources like brute
		var/turf/current_position = get_turf(src)
		new /obj/effect/decal/cleanable/shreds(current_position, name)
		if(isliving(loc))
			var/mob/living/possessing_mob = loc
			possessing_mob.visible_message(span_danger("[src] is consumed until naught but shreds remains!"), span_boldwarning("[src] falls apart into little bits!"))
		deconstruct(FALSE)
	else
		body_parts_covered = NONE
		slot_flags = NONE
		update_clothes_damaged_state(CLOTHING_SHREDDED)
		if(isliving(loc))
			var/mob/living/M = loc
			if(src in M.get_equipped_items()) //make sure they were wearing it and not attacking the item in their hands
				M.visible_message(span_danger("[M]'s [src.name] fall[p_s()] off, [p_theyre()] completely shredded!"), span_warning("<b>Your [src.name] fall[p_s()] off, [p_theyre()] completely shredded!</b>"), vision_distance = COMBAT_MESSAGE_RANGE)
				M.dropItemToGround(src)
			else
				M.visible_message(span_danger("[src] fall[p_s()] apart, completely shredded!"), vision_distance = COMBAT_MESSAGE_RANGE)
		name = "shredded [initial(name)]" // change the name -after- the message, not before.
		update_appearance()
	SEND_SIGNAL(src, COMSIG_ATOM_DESTRUCTION, damage_flag)

/// If we're a clothing with at least 1 shredded/disabled zone, give the wearer a periodic heads up letting them know their clothes are damaged
/obj/item/clothing/proc/bristle(mob/living/L)
	SIGNAL_HANDLER

	if(!istype(L))
		return
	if(prob(0.2))
		to_chat(L, span_warning("The damaged threads on your [src.name] chafe!"))

/obj/item/clothing/apply_fantasy_bonuses(bonus)
	. = ..()
	set_armor(get_armor().generate_new_with_modifiers(list(ARMOR_ALL = bonus)))

/obj/item/clothing/remove_fantasy_bonuses(bonus)
	set_armor(get_armor().generate_new_with_modifiers(list(ARMOR_ALL = -bonus)))
	return ..()

/// Returns a list of overlays with our blood, if we're bloodied
/obj/item/clothing/proc/get_blood_overlay(blood_state)
	if (!GET_ATOM_BLOOD_DECAL_LENGTH(src))
		return

	var/mutable_appearance/blood_overlay = null
	if(clothing_flags & LARGE_WORN_ICON)
		blood_overlay = mutable_appearance('icons/effects/64x64.dmi', "[blood_state]blood_large")
	else
		blood_overlay = mutable_appearance('icons/effects/blood.dmi', "[blood_state]blood")

	blood_overlay.color = get_blood_dna_color()

	var/emissive_alpha = get_blood_emissive_alpha(is_worn = TRUE)
	if (emissive_alpha)
		var/mutable_appearance/emissive_overlay = emissive_appearance(blood_overlay.icon, blood_overlay.icon_state, src, alpha = emissive_alpha, effect_type = EMISSIVE_NO_BLOOM)
		blood_overlay.overlays += emissive_overlay

	return blood_overlay
