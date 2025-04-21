/*!
 * Contains the eldritch robes for heretics, a suit of armor that they can make via a ritual
 */

// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	inhand_icon_state = null
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEBELT
	body_parts_covered = CHEST | GROIN | LEGS | FEET | ARMS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clothing_flags = THICKMATERIAL
	transparent_protection = HIDEGLOVES | HIDESUITSTORAGE | HIDEJUMPSUIT | HIDESHOES | HIDENECK
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/ballistic/rifle/lionhunter)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	armor_type = /datum/armor/eldritch_armor

/obj/item/clothing/suit/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	if(hood_up)
		return

	// Our hood gains the heretic_focus element.
	. += span_notice("Allows you to cast heretic spells while the hood is up.")

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR | HIDEFACIALHAIR | HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER_HYPER_SENSITIVE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clothing_flags = THICKMATERIAL | SNUG_FIT
	armor_type = /datum/armor/eldritch_armor

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/datum/armor/eldritch_armor
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 35
	bio = 20
	fire = 20
	acid = 20
	wound = 20

//---- Path-Specific Eldritch Robes, First is robes, then is hood
// Ash
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash
	name = "\improper Scorched Mantle"
	desc = "Left to burn to tatters, what remains is naught but a blackened echo of the mantle of the Watch. \
		Yet the soot-choked folds turn blade and flame from the form within. A brief reprieve before its gaze turns inwards."
	icon_state = "ash_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	armor_type = /datum/armor/eldritch_armor/ash
	flags_inv = HIDEBELT
	body_parts_covered = FULL_BODY
	heat_protection = FULL_BODY
	max_heat_protection_temperature = 50000
	actions_types = list(/datum/action/item_action/toggle/flames)
	/// If our robes are actively generating flames
	var/flame_generation = FALSE
	/// Cooldown before our robes will create new flames
	COOLDOWN_DECLARE(flame_creation)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		user.fire_stack_decay_rate = initial(user.fire_stack_decay_rate)
		if(flame_generation)
			toggle_flames(user)
		return
	user.fire_stack_decay_rate = 0

/datum/action/item_action/toggle/flames
	button_icon = 'icons/effects/magic.dmi'
	button_icon_state = "fireball"

/datum/action/item_action/toggle/flames/do_effect(trigger_flags)
	var/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/item_target = target
	if(!item_target || !istype(item_target))
		return FALSE
	item_target.toggle_flames(owner)

/// Starts/Stops the passive generation of fire stacks on our wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/proc/toggle_flames(mob/user)
	if(!flame_generation)
		START_PROCESSING(SSobj, src)
		user.balloon_alert(user, "enabled")
	else
		STOP_PROCESSING(SSobj, src)
		user.balloon_alert(user, "disabled")
		if(!isliving(user))
			user.extinguish()
		else
			var/mob/living/living_mob = user
			living_mob.extinguish_mob()
	flame_generation = !flame_generation

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, flame_creation))
		return
	var/mob/living/wearer = loc
	if(!isliving(wearer))
		STOP_PROCESSING(SSobj, src)
		flame_generation = FALSE
		return
	COOLDOWN_START(src, flame_creation, 5 SECONDS)
	wearer.adjust_fire_stacks(1)
	wearer.fire_stack_decay_rate = 0
	wearer.ignite_mob(TRUE)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	name = "\improper Scorched Mantle"
	desc = "Left to burn to tatters, what remains is naught but a blackened echo of the mantle of the Watch. \
		Yet the soot-choked folds turn blade and flame from the form within. A brief reprieve before its gaze turns inwards."
	icon_state = "ash_armor"
	armor_type = /datum/armor/eldritch_armor/ash

/datum/armor/eldritch_armor/ash
	melee = 40
	bullet = 60
	laser = 40
	energy = 40
	bomb = 100
	bio = 20
	fire = 100
	acid = 20
	wound = 20

// Blade
/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade
	name = "\improper Shattered Panoply"
	desc = "The sharpened edges of this ancient suit of armor assert a revelation known to aspirants of battle; \
			a true warrior can not be distinguished from the blade they wield."
	icon_state = "blade_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	armor_type = /datum/armor/eldritch_armor/blade
	siemens_coefficient = 0

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		user.remove_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE), REF(src))
		return
	user.add_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE), REF(src))

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	name = "\improper Shattered Panoply"
	desc = "The sharpened edges of this ancient suit of armor assert a revelation known to aspirants of battle; \
			a true warrior can not be distinguished from the blade they wield."
	icon_state = "blade_armor"
	armor_type = /datum/armor/eldritch_armor/blade
	siemens_coefficient = 0

/datum/armor/eldritch_armor/blade
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	bio = 50
	fire = 50
	acid = 50
	wound = 50

// Cosmic
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic
	name = "\improper Starwoven Cloak"
	desc = "Gleaming gems conjure forth wisps of power, turning about to illuminate the wearer in a dim radiance. \
			Gazing upon the robe, you cannot help but feel noticed."
	icon_state = "cosmic_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	armor_type = /datum/armor/eldritch_armor/cosmic
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/toggle/gravity)
	/// If our robes are making us weightless
	var/weightless_enabled = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot) && weightless_enabled)
		toggle_gravity(user)

/datum/action/item_action/toggle/gravity
	button_icon = 'icons/effects/magic.dmi'
	button_icon_state = "magicm"

/datum/action/item_action/toggle/gravity/do_effect(trigger_flags)
	var/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/item_target = target
	if(!item_target || !istype(item_target))
		return FALSE
	item_target.toggle_gravity(owner)

/// Gives us free movement in 0 gravity when enabled
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/proc/toggle_gravity(mob/living/user)
	if(!weightless_enabled)
		user.add_traits(list(TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), REF(src))
		user.balloon_alert(user, "enabled")
	else
		user.remove_traits(list(TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), REF(src))
		user.balloon_alert(user, "disabled")
	weightless_enabled = !weightless_enabled

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	name = "\improper Starwoven Hood"
	desc = "Gleaming gems conjure forth wisps of power, turning about to illuminate the wearer in a dim radiance. \
			Gazing upon the robe, you cannot help but feel noticed."
	icon_state = "cosmic_armor"
	armor_type = /datum/armor/eldritch_armor/cosmic
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/datum/armor/eldritch_armor/cosmic
	melee = 20
	bullet = 30
	laser = 60
	energy = 60
	bomb = 35
	bio = 20
	fire = 20
	acid = 20
	wound = 20

// Flesh
/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh
	icon_state = "flesh_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	armor_type = /datum/armor/eldritch_armor/flesh

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	icon_state = "flesh_armor"
	armor_type = /datum/armor/eldritch_armor/flesh

/datum/armor/eldritch_armor/flesh
	melee = 60
	bullet = 40
	laser = 30
	energy = 30
	bomb = 35
	bio = 100
	fire = 0
	acid = 100
	wound = 20

// Lock
/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock
	icon_state = "lock_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	armor_type = /datum/armor/eldritch_armor/lock

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	icon_state = "lock_armor"
	armor_type = /datum/armor/eldritch_armor/lock

/datum/armor/eldritch_armor/lock
	melee = 40
	bullet = 40
	laser = 40
	energy = 40
	bomb = 40
	bio = 40
	fire = 40
	acid = 40
	wound = 40

// Moon
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon
	name = "\improper Resplendant Regalia"
	desc = "The confounding nature of this opulent garb turns and twists the sight. \
			The viewer must come to a chilling revelation; \
			what they see is as true as any other face."
	icon_state = "moon_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	armor_type = /datum/armor/eldritch_armor/moon
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEMUTWINGS

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	name = "\improper Resplendant Hood"
	icon_state = "moon_armor"
	armor_type = /datum/armor/eldritch_armor/moon

/datum/armor/eldritch_armor/moon
	melee = 0
	bullet = 0
	laser = 0
	energy = 0
	bomb = 0
	bio = 0
	fire = 0
	acid = 0
	wound = 0

// Rust
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust
	name = "\improper Salvaged Remains"
	desc = "Touching the folds of this plain robe seem to fill you with unease. \
			Even looking fills you with a sense of vertigo. \
			Some pulse threatening to pull you within."
	icon_state = "rust_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	armor_type = /datum/armor/eldritch_armor/rust

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED))
		return
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if our armor values should be increased on the new turf
 */
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		armor_type = /datum/armor/eldritch_armor/rust/on_rust
		ADD_TRAIT(source, TRAIT_PIERCEIMMUNE, REF(src))
	else
		armor_type = initial(armor_type)
		REMOVE_TRAIT(source, TRAIT_PIERCEIMMUNE, REF(src))

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	name = "\improper Salvaged Remains"
	desc = "Touching the folds of this plain robe seem to fill you with unease. \
			Even looking fills you with a sense of vertigo. \
			Some pulse threatening to pull you within."
	icon_state = "rust_armor"
	armor_type = /datum/armor/eldritch_armor/rust

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED))
		return
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if our armor values should be increased on the new turf
 */
/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		armor_type = /datum/armor/eldritch_armor/rust/on_rust
	else
		armor_type = initial(armor_type)

/datum/armor/eldritch_armor/rust
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 50
	bio = 30
	fire = 0
	acid = 0
	wound = 30

/datum/armor/eldritch_armor/rust/on_rust
	melee = 60
	bullet = 60
	laser = 60
	energy = 60
	bomb = 100
	bio = 60
	fire = 0
	acid = 0
	wound = 60

// Void
/obj/item/clothing/suit/hooded/cultrobes/eldritch/void
	name = "\improper Hollow Weave"
	desc = "At first, the empty canvas of this robe seems to shimmer with a faint, cold light. \
			Yet upon tracking the shape of the folds more carefully, it is better to describe it as the absence of such a thing."
	icon_state = "void_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/void
	armor_type = /datum/armor/eldritch_armor/void
	/// Cooldown before we can go back into stealth
	COOLDOWN_DECLARE(stealth_cooldown)
	/// Timer before our stealth runs out
	var/stealth_timer

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/equipped(mob/living/user, slot)
	. = ..()
	if((slot_flags & slot) || !timeleft(stealth_timer))
		return
	deltimer(stealth_timer)
	end_stealth(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type, damage_type)
	. = ..()
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		return
	COOLDOWN_START(src, stealth_cooldown, 20 SECONDS)
	stealth_timer = addtimer(CALLBACK(src, PROC_REF(end_stealth), owner), 5 SECONDS, TIMER_STOPPABLE)
	owner.alpha = 0
	return TRUE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/proc/end_stealth(mob/living/carbon/human/owner)
	animate(owner, time = 1 SECONDS, alpha = initial(owner.alpha))

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/void
	name = "\improper Hollow Weave"
	desc = "At first, the empty canvas of this robe seems to shimmer with a faint, cold light. \
			Yet upon tracking the shape of the folds more carefully, it is better to describe it as the absence of such a thing."
	icon_state = "void_armor"
	armor_type = /datum/armor/eldritch_armor/void

/datum/armor/eldritch_armor/void
	melee = 40
	bullet = 40
	laser = 50
	energy = 50
	bomb = 40
	bio = 40
	fire = 40
	acid = 40
	wound = 40

// Void cloak. Turns invisible with the hood up, lets you hide stuff.
/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	armor_type = /datum/armor/cult_hoodie_void

/datum/armor/cult_hoodie_void
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 15
	wound = 10

/obj/item/clothing/head/hooded/cult_hoodie/void/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), INNATE_TRAIT)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	inhand_icon_state = null
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	body_parts_covered = CHEST|GROIN|ARMS
	// slightly worse than normal cult robes
	armor_type = /datum/armor/cultrobes_void
	alternative_mode = TRUE

/datum/armor/cultrobes_void
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 15
	wound = 10

/obj/item/clothing/suit/hooded/cultrobes/void/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/void_cloak)
	make_visible()
	ADD_TRAIT(src, TRAIT_CONTRABAND_BLOCKER, INNATE_TRAIT)

/obj/item/clothing/suit/hooded/cultrobes/void/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING)
		RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(hide_item))
		RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(show_item))

/obj/item/clothing/suit/hooded/cultrobes/void/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_MOB_EQUIPPED_ITEM))

/obj/item/clothing/suit/hooded/cultrobes/void/proc/hide_item(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(slot & ITEM_SLOT_SUITSTORE)
		item.add_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/void/proc/show_item(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	item.remove_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/void/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user) || !hood_up)
		return

	// Let examiners know this works as a focus only if the hood is down
	. += span_notice("Allows you to cast heretic spells while the hood is down.")
	. += span_notice("Is space worthy as long as the hood is down.")

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_down(obj/item/clothing/head/hooded/hood)
	make_visible()
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/void/can_create_hood()
	if(!isliving(loc))
		CRASH("[src] attempted to make a hood on a non-living thing: [loc]")
	var/mob/living/wearer = loc
	if(IS_HERETIC_OR_MONSTER(wearer))
		return TRUE

	loc.balloon_alert(loc, "can't get the hood up!")
	return FALSE

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_created(obj/item/clothing/head/hooded/hood)
	. = ..()
	make_invisible()

/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_invisible()
	add_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), REF(src))
	RemoveElement(/datum/element/heretic_focus)

	if(isliving(loc))
		loc.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), REF(src))
		REMOVE_TRAIT(loc, TRAIT_RESISTLOWPRESSURE, REF(src))
		loc.balloon_alert(loc, "cloak hidden")
		loc.visible_message(span_notice("Light shifts around [loc], making the cloak around them invisible!"))

/// Makes our cloak "visible" again.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_visible()
	remove_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), REF(src))
	AddElement(/datum/element/heretic_focus)

	if(isliving(loc))
		loc.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), REF(src))
		loc.balloon_alert(loc, "cloak revealed")
		loc.visible_message(span_notice("A kaleidoscope of colours collapses around [loc], a cloak appearing suddenly around their person!"))
