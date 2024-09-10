/// The baseline time to take for doing actions with the forge, like heating glass, setting ceramics, etc.
#define BASELINE_ACTION_TIME (4 SECONDS)

/// The basline for how long an item such as molten glass will be kept workable after heating
#define BASELINE_HEATING_DURATION (25 SECONDS)

/// The amount the forge's temperature will change per process
#define FORGE_DEFAULT_TEMPERATURE_CHANGE 5
/// The maximum temperature the forge can reach
#define MAX_FORGE_TEMP 100
/// The minimum temperature for using the forge
#define MIN_FORGE_TEMP 50
/// The duration that objects heated in the forge are heated for
#define FORGE_HEATING_DURATION (1 MINUTES)

/// Defines for different levels of the forge, ranging from no level (you play like a noob) to legendary
#define FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB 1
#define FORGE_LEVEL_NOVICE 2
#define FORGE_LEVEL_APPRENTICE 3
#define FORGE_LEVEL_JOURNEYMAN 4
#define FORGE_LEVEL_EXPERT 5
#define FORGE_LEVEL_MASTER 6
#define FORGE_LEVEL_LEGENDARY 7

/// The maximum amount of temperature loss decrease that upgrades can give the forge
#define MAX_TEMPERATURE_LOSS_DECREASE 5

/// The chance per piece of wood added that charcoal will form later
#define CHARCOAL_CHANCE 45

/// The minimum units of a reagent rerquired to imbue it into a weapon
#define MINIMUM_IMBUING_REAGENT_AMOUNT 100

/// Defines for the different levels of smoke coming out of the forge, (good, neutral, bad) are all used for baking, (not cooking) is used for when there is no tray in the forge
#define SMOKE_STATE_NONE 0
#define SMOKE_STATE_GOOD 1
#define SMOKE_STATE_NEUTRAL 2
#define SMOKE_STATE_BAD 3
#define SMOKE_STATE_NOT_COOKING 4

/obj/structure/reagent_forge
	name = "forge"
	desc = "A structure built out of bricks, for heating up metal, or glass, or ceramic, or food, or anything really."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_structures.dmi'
	icon_state = "forge_inactive"

	anchored = TRUE
	density = TRUE

	/// What the current internal temperature of the forge is
	var/forge_temperature = 0
	/// What temperature the forge is moving towards
	var/target_temperature = 0
	/// What the minimum target temperature is, used for upgrades
	var/minimum_target_temperature = 0
	/// What is the current reduction for temperature decrease
	var/temperature_loss_reduction = 0
	/// How many seconds of weak fuel (wood) does the forge have left
	var/forge_fuel_weak = 0
	/// How many seconds of strong fuel (coal) does the forge have left
	var/forge_fuel_strong = 0
	/// If the forge is capable of reagent forging or not
	var/reagent_forging = FALSE
	/// Cooldown time for processing on the forge
	COOLDOWN_DECLARE(forging_cooldown)
	/// Is the forge in use or not? If true, prevents most interactions with the forge
	var/in_use = FALSE
	/// The current 'level' of the forge, how upgraded is it from zero to three
	var/forge_level = FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB
	/// What smoke particles should be coming out of the forge
	var/smoke_state = SMOKE_STATE_NONE
	/// Tracks any oven tray placed inside of the forge
	var/obj/item/plate/oven_tray/used_tray
	/// The list of possible things to make with materials used on the forge
	var/static/list/choice_list = list(
		"Chain" = /obj/item/forging/incomplete/chain,
		"Plate" = /obj/item/forging/incomplete/plate,
		"Sword" = /obj/item/forging/incomplete/sword,
		"Katana" = /obj/item/forging/incomplete/katana,
		"Dagger" = /obj/item/forging/incomplete/dagger,
		"Staff" = /obj/item/forging/incomplete/staff,
		"Spear" = /obj/item/forging/incomplete/spear,
		"Axe" = /obj/item/forging/incomplete/axe,
		"Hammer" = /obj/item/forging/incomplete/hammer,
		"Pickaxe" = /obj/item/forging/incomplete/pickaxe,
		"Shovel" = /obj/item/forging/incomplete/shovel,
		"Arrowhead" = /obj/item/forging/incomplete/arrowhead,
		"Rail Nail" = /obj/item/forging/incomplete/rail_nail,
		"Rail Cart" = /obj/item/forging/incomplete/rail_cart,
	)
	/// List of possible choices for the selection radial
	var/list/radial_choice_list = list()
	/// Blacklist that contains reagents that weapons and armor are unable to be imbued with.
	var/static/list/disallowed_reagents = typecacheof(list(
		/datum/reagent/inverse/,
		/datum/reagent/consumable/entpoly,
		/datum/reagent/pax,
		/datum/reagent/consumable/liquidelectricity/enriched,
		/datum/reagent/teslium,
		/datum/reagent/eigenstate,
		/datum/reagent/toxin/acid,
		/datum/reagent/phlogiston,
		/datum/reagent/napalm,
		/datum/reagent/thermite,
		/datum/reagent/medicine/earthsblood,
		/datum/reagent/medicine/ephedrine,
		/datum/reagent/medicine/epinephrine,
	))

/obj/structure/reagent_forge/examine(mob/user)
	. = ..()

	if(used_tray)
		. += span_notice("It has [used_tray] in it, which can be removed with an <b>empty hand</b>.")
	else
		. += span_notice("You can place an <b>oven tray</b> in this to <b>bake</b> any items on it.")

	if(forge_level < FORGE_LEVEL_LEGENDARY)
		. += span_notice("Using an <b>empty hand</b> on [src] will upgrade it, if your forging skill level is above the current upgrade's level.")

	switch(forge_level)
		if(FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB)
			. += span_notice("This forge has not been upgraded yet.")

		if(FORGE_LEVEL_NOVICE)
			. += span_notice("This forge has been upgraded by a novice smith.")

		if(FORGE_LEVEL_APPRENTICE)
			. += span_notice("This forge has been upgraded by an apprentice smith.")

		if(FORGE_LEVEL_JOURNEYMAN)
			. += span_notice("This forge has been upgraded by a journeyman smith.")

		if(FORGE_LEVEL_EXPERT)
			. += span_notice("This forge has been upgraded by an expert smith.")

		if(FORGE_LEVEL_MASTER)
			. += span_notice("This forge has been upgraded by a master smith.")

		if(FORGE_LEVEL_LEGENDARY)
			. += span_hierophant("This forge has been upgraded by a legendary smith.") // Legendary skills give you the greatest gift of all, cool text

	switch(temperature_loss_reduction)
		if(0)
			. += span_notice("[src] will lose heat at a normal rate.")
		if(1)
			. += span_notice("[src] will lose heat slightly slower than usual.")
		if(2)
			. += span_notice("[src] will lose heat a bit slower than usual.")
		if(3)
			. += span_notice("[src] will lose heat much slower than usual.")
		if(4)
			. += span_notice("[src] will lose heat signficantly slower than usual.")
		if(5)
			. += span_notice("[src] will lose heat at a practically negligible rate.")

	. += span_notice("<br>[src] is currently [forge_temperature] degrees hot, going towards [target_temperature] degrees.<br>")

	if(reagent_forging && (is_species(user, /datum/species/lizard/ashwalker) || is_species(user, /datum/species/human/felinid/primitive)))
		. += span_warning("[src] has a fine gold trim, it is ready to imbue chemicals into reagent objects.")

	return .

/obj/structure/reagent_forge/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	populate_radial_choice_list()
	update_appearance()
	upgrade_forge(forced = TRUE)

/// Fills out the radial choice list with everything in the choice_list's contents
/obj/structure/reagent_forge/proc/populate_radial_choice_list()
	if(!length(choice_list))
		return

	if(length(radial_choice_list))
		return

	for(var/forge_option in choice_list)
		var/obj/resulting_item = choice_list[forge_option]
		radial_choice_list[forge_option] = image(icon = initial(resulting_item.icon), icon_state = initial(resulting_item.icon_state))

/obj/structure/reagent_forge/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(particles)
	if(used_tray)
		QDEL_NULL(used_tray)
	. = ..()

/obj/structure/reagent_forge/update_appearance(updates)
	. = ..()
	cut_overlays()

	if(reagent_forging) // If we can do reagent forging, give the forge the gold trim
		var/image/gold_overlay = image(icon = icon, icon_state = "forge_masterwork_trim")
		add_overlay(gold_overlay)

	if(used_tray) // If we have a tray inside, check if the forge is on or not, then give the corresponding tray overlay
		var/image/tray_overlay = image(icon = icon, icon_state = "forge_tray_[check_fuel(just_checking = TRUE) ? "active" : "inactive"]")
		add_overlay(tray_overlay)

/// Checks if the forge has fuel, if so what type. If it has either type of fuel, returns TRUE, otherwise returns FALSE. just_checking will check if there is fuel without taking actions
/obj/structure/reagent_forge/proc/check_fuel(just_checking = FALSE)
	if(forge_fuel_strong) // Check for strong fuel (coal) first, as it has more power over weaker fuels
		if(just_checking)
			return TRUE

		forge_fuel_strong -= 5 SECONDS
		target_temperature = 100
		return TRUE

	if(forge_fuel_weak) // If there's no strong fuel, maybe we have weak fuel (wood)
		if(just_checking)
			return TRUE

		forge_fuel_weak -= 5 SECONDS
		target_temperature = 50
		return TRUE

	if(just_checking)
		return FALSE

	target_temperature = minimum_target_temperature // If the forge has no fuel, then we should lowly return to the minimum lowest temp we can do
	return FALSE

/// Gives the forge the ability to imbue reagents into things
/obj/structure/reagent_forge/proc/create_reagent_forge()
	if(reagent_forging) // If the forge can already do reagent forging, then we can skip the rest of this
		return
	reagent_forging = TRUE
	update_appearance()

/// Creates both a fail message balloon alert, and sets in_use to false
/obj/structure/reagent_forge/proc/fail_message(mob/living/user, message)
	balloon_alert(user, message)
	in_use = FALSE

/// Adjust the temperature to head towards the target temperature, changing icon and creating light if the temperature is rising
/obj/structure/reagent_forge/proc/check_temp()
	if(forge_temperature > target_temperature) // Being above the target temperature will cause the forge to cool down
		forge_temperature -= (FORGE_DEFAULT_TEMPERATURE_CHANGE - temperature_loss_reduction)
		return

	else if((forge_temperature < target_temperature) && (forge_fuel_weak || forge_fuel_strong)) // Being below the target temp, and having fuel, will cause the temp to rise
		forge_temperature += FORGE_DEFAULT_TEMPERATURE_CHANGE
		return

/// If the forge is in use, checks if there is an oven tray, then if there are any mobs actually in use range. If not sets the forge to not be in use.
/obj/structure/reagent_forge/proc/check_in_use()
	if(!in_use)
		return

	if(used_tray) // We check if there's a tray because trays inside of the forge count as it being in use, even if nobody is around
		return

	for(var/mob/living/living_mob in range(1,src))
		if(!living_mob)
			in_use = FALSE

/// Spawns a piece of coal at the forge and renames it to charcoal
/obj/structure/reagent_forge/proc/spawn_coal()
	var/obj/item/stack/sheet/mineral/coal/spawn_coal = new(get_turf(src))
	spawn_coal.name = "charcoal"

/obj/structure/reagent_forge/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, forging_cooldown))
		return

	COOLDOWN_START(src, forging_cooldown, 5 SECONDS)
	check_fuel()
	check_temp()
	check_in_use() // This is here to ensure the forge doesn't remain in_use if it really isn't



	if(!used_tray && check_fuel(just_checking = TRUE))
		set_smoke_state(SMOKE_STATE_NOT_COOKING) // If there is no tray but we have fuel, use the not cooking smoke state
		return

	if(!check_fuel(just_checking = TRUE)) // If there's no fuel, remove it all
		set_smoke_state(SMOKE_STATE_NONE)
		return

	handle_baking_things(seconds_per_tick)

/// Sends signals to bake and items on the used tray, setting the smoke state of the forge according to the most cooked item in it
/obj/structure/reagent_forge/proc/handle_baking_things(seconds_per_tick)
	if(forge_temperature < MIN_FORGE_TEMP) // If we are below minimum forge temp, don't continue on to cooking
		return

	/// The worst off item being baked in our forge right now, to ensure people know when gordon ramsay is gonna be upset at them
	var/worst_cooked_food_state = 0
	for(var/obj/item/baked_item as anything in used_tray.contents)

		var/signal_result = SEND_SIGNAL(baked_item, COMSIG_ITEM_OVEN_PROCESS, src, seconds_per_tick)

		if(signal_result & COMPONENT_HANDLED_BAKING)
			if(signal_result & COMPONENT_BAKING_GOOD_RESULT && worst_cooked_food_state < SMOKE_STATE_GOOD)
				worst_cooked_food_state = SMOKE_STATE_GOOD
			else if(signal_result & COMPONENT_BAKING_BAD_RESULT && worst_cooked_food_state < SMOKE_STATE_NEUTRAL)
				worst_cooked_food_state = SMOKE_STATE_NEUTRAL
			continue

		worst_cooked_food_state = SMOKE_STATE_BAD
		baked_item.fire_act(1000) // Overcooked food really does burn, hot hot hot!

		if(SPT_PROB(10, seconds_per_tick))
			var/list/asomnia_havers = get_hearers_in_view(DEFAULT_MESSAGE_RANGE, src)
			for(var/mob/cannot_smell in asomnia_havers)
				if(!HAS_TRAIT(cannot_smell, TRAIT_ANOSMIA))
					asomnia_havers -= cannot_smell
			visible_message(span_danger("You smell a burnt smell coming from [src]!"), ignored_mobs = asomnia_havers)
			// Give indication that something is burning in the oven
	set_smoke_state(worst_cooked_food_state)

/// Sets the type of particles that the forge should be generating
/obj/structure/reagent_forge/proc/set_smoke_state(new_state)
	if(new_state == smoke_state)
		return

	smoke_state = new_state

	QDEL_NULL(particles)

	switch(smoke_state)
		if(SMOKE_STATE_NONE)
			icon_state = "forge_inactive"
			set_light(0, 0) // If we aren't heating up and thus not on fire, turn the fire light off
			return

		if(SMOKE_STATE_BAD)
			particles = new /particles/smoke()
			particles.position = list(6, 4, 0)

		if(SMOKE_STATE_NEUTRAL)
			particles = new /particles/smoke/steam()
			particles.position = list(6, 4, 0)

		if(SMOKE_STATE_GOOD)
			particles = new /particles/smoke/steam/mild()
			particles.position = list(6, 4, 0)

		if(SMOKE_STATE_NOT_COOKING)
			particles = new /particles/smoke/mild()
			particles.position = list(6, 4, 0)

	icon_state = "forge_active"
	set_light(3, 1, LIGHT_COLOR_FIRE)

/obj/structure/reagent_forge/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(used_tray)
		remove_tray_from_forge(user)
		return

	upgrade_forge(user)

/obj/structure/reagent_forge/proc/upgrade_forge(mob/living/user, forced = FALSE)
	var/level_to_upgrade_to

	if(forced || !user) // This is to make sure the ready subtype of forge still works
		level_to_upgrade_to = forge_level
	else
		level_to_upgrade_to = user.mind.get_skill_level(/datum/skill/smithing)

	if((forge_level == level_to_upgrade_to) && !forced)
		to_chat(user, span_notice("[src] was already upgraded by your level of expertise!"))
		return

	switch(level_to_upgrade_to) // Remember to carry things over from past levels in case someone skips levels in upgrading
		if(SKILL_LEVEL_NONE)
			if(!forced)
				to_chat(user, span_notice("You'll need some forging skills to really understand how to upgrade [src]."))
			return

		if(SKILL_LEVEL_NOVICE)
			if(!forced)
				to_chat(user, span_notice("With some experience, you've come to realize there are some easily fixable spots with poor insulation..."))
			temperature_loss_reduction = 1
			forge_level = FORGE_LEVEL_NOVICE

		if(SKILL_LEVEL_APPRENTICE)
			if(!forced)
				to_chat(user, span_notice("Further insulation and protection of the thinner areas means [src] will lose heat just that little bit slower."))
			temperature_loss_reduction = 2
			forge_level = FORGE_LEVEL_APPRENTICE

		if(SKILL_LEVEL_JOURNEYMAN)
			if(!forced)
				to_chat(user, span_notice("Some careful placement and stoking of the flame will allow you to keep at least the embers burning..."))
			minimum_target_temperature = 25 // Will allow quicker reheating from having no fuel
			temperature_loss_reduction = 3
			forge_level = FORGE_LEVEL_JOURNEYMAN

		if(SKILL_LEVEL_EXPERT)
			if(!forced)
				to_chat(user, span_notice("[src] has become nearly perfect, able to hold heat for long enough that even a piece of wood can outmatch the longevity of lesser forges."))
			temperature_loss_reduction = 4
			minimum_target_temperature = 25
			forge_level = FORGE_LEVEL_EXPERT

		if(SKILL_LEVEL_MASTER)
			if(!forced)
				to_chat(user, span_notice("The perfect forge for a perfect metalsmith, with your knowledge it should bleed heat so slowly, that not even you will live to see [src] cool."))
			temperature_loss_reduction = MAX_TEMPERATURE_LOSS_DECREASE
			minimum_target_temperature = 25
			forge_level = FORGE_LEVEL_MASTER

		if(SKILL_LEVEL_LEGENDARY)
			if(!forced)
				if(is_species(user, /datum/species/lizard/ashwalker) || is_species(user, /datum/species/human/felinid/primitive))
					to_chat(user, span_notice("With just the right heat treating technique, metal could be made to accept reagents..."))
					create_reagent_forge()
				if(forge_level == FORGE_LEVEL_MASTER)
					to_chat(user, span_warning("It is impossible to further improve the forge!"))
			temperature_loss_reduction = MAX_TEMPERATURE_LOSS_DECREASE
			minimum_target_temperature = 25 // This won't matter except in a few cases here, but we still need to cover those few cases
			forge_level = FORGE_LEVEL_LEGENDARY

	playsound(src, 'sound/weapons/parry.ogg', 50, TRUE) // Play a feedback sound to really let players know we just did an upgrade

/obj/structure/reagent_forge/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!used_tray && istype(attacking_item, /obj/item/plate/oven_tray))
		add_tray_to_forge(user, attacking_item)
		return TRUE

	if(in_use) // If the forge is currently in use by someone (or there is a tray in it) then we cannot use it
		if(used_tray)
			balloon_alert(user, "remove [used_tray] first")
		balloon_alert(user, "forge busy")
		return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/mineral/wood)) // Wood is a weak fuel, and will only get the forge up to 50 temperature
		refuel(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/mineral/coal)) // Coal is a strong fuel that doesn't need bellows to heat up properly
		refuel(attacking_item, user, TRUE)
		return TRUE

	if(istype(attacking_item, /obj/item/stack/ore))
		smelt_ore(attacking_item, user)
		return TRUE

	if(attacking_item.GetComponent(/datum/component/reagent_weapon))
		handle_weapon_imbue(attacking_item, user)
		return TRUE

	if(attacking_item.GetComponent(/datum/component/reagent_clothing))
		handle_clothing_imbue(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/ceramic))
		handle_ceramics(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/glass))
		handle_glass_sheet_melting(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/glassblowing/metal_cup))
		handle_metal_cup_melting(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/stack/rods))
		in_use = TRUE
		smelt_iron_rods(attacking_item, user)
		in_use = FALSE
		return TRUE

	return ..()

/// Take the given tray and place it inside the forge, updating everything relevant to that
/obj/structure/reagent_forge/proc/add_tray_to_forge(mob/living/user, obj/item/plate/oven_tray/tray)
	if(used_tray) // This shouldn't be able to happen but just to be safe
		balloon_alert_to_viewers("already has tray")
		return

	if(!user.transferItemToLoc(tray, src, silent = FALSE))
		return

	// need to send the right signal for each item in the tray
	for(var/obj/item/baked_item in tray.contents)
		SEND_SIGNAL(baked_item, COMSIG_ITEM_OVEN_PLACED_IN, src, user)

	balloon_alert_to_viewers("put [tray] in [src]")
	used_tray = tray
	in_use = TRUE // You can't use the forge if there's a tray sitting in it
	update_appearance()

/// Take the used_tray and spit it out, updating everything relevant to that
/obj/structure/reagent_forge/proc/remove_tray_from_forge(mob/living/carbon/user)
	if(!used_tray)
		if(user)
			balloon_alert_to_viewers("no tray")
		return

	if(user)
		user.put_in_hands(used_tray)
		balloon_alert_to_viewers("removed [used_tray]")
	else
		used_tray.forceMove(get_turf(src))
	used_tray = null
	in_use = FALSE

/// Adds to either the strong or weak fuel timers from the given stack
/obj/structure/reagent_forge/proc/refuel(obj/item/stack/refueling_stack, mob/living/user, is_strong_fuel = FALSE)
	in_use = TRUE

	if(is_strong_fuel)
		if(forge_fuel_strong >= 5 MINUTES)
			fail_message(user, "[src] is full on coal")
			return
	if(forge_fuel_weak >= 5 MINUTES)
		fail_message(user, "[src] is full on wood")
		return

	balloon_alert_to_viewers("refueling...")

	var/obj/item/stack/sheet/stack_sheet = refueling_stack
	if(!do_after(user, 3 SECONDS, target = src) || !stack_sheet.use(1))
		fail_message(user, "stopped fueling")
		return

	if(is_strong_fuel)
		forge_fuel_strong += 5 MINUTES
	else
		forge_fuel_weak += 5 MINUTES
	in_use = FALSE
	balloon_alert(user, "fueled [src]")
	user.mind.adjust_experience(/datum/skill/smithing, 5) // You gain small amounts of experience from useful fueling

	if(prob(CHARCOAL_CHANCE) && !is_strong_fuel)
		to_chat(user, span_notice("[src]'s fuel is packed densely enough to have made some charcoal!"))
		addtimer(CALLBACK(src, PROC_REF(spawn_coal)), 1 MINUTES)

/// Takes given ore and smelts it, possibly producing extra sheets if upgraded
/obj/structure/reagent_forge/proc/smelt_ore(obj/item/stack/ore/ore_item, mob/living/user)
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER)

	if(!ore_item.refined_type)
		fail_message(user, "cannot smelt [ore_item]")
		return

	balloon_alert_to_viewers("smelting...")

	if(!do_after(user, skill_modifier * 3 SECONDS, target = src))
		fail_message(user, "stopped smelting [ore_item]")
		return

	var/src_turf = get_turf(src)
	var/spawning_item = ore_item.refined_type
	var/ore_to_sheet_amount = ore_item.amount

	for(var/spawn_ore in 1 to ore_to_sheet_amount)
		new spawning_item(src_turf)

	in_use = FALSE
	qdel(ore_item)
	return

/// Handles weapon reagent imbuing
/obj/structure/reagent_forge/proc/handle_weapon_imbue(obj/attacking_item, mob/living/user)
	//This code will refuse all non-ashwalkers & non-icecats from imbuing
	if(!ishuman(user))
		to_chat(user, span_danger("It is impossible for you to imbue!")) //maybe remove (ashwalkers & icecats only) after some time
		return

	var/mob/living/carbon/human/human_user = user
	if(!is_species(human_user, /datum/species/lizard/ashwalker) && !is_species(human_user, /datum/species/human/felinid/primitive))
		to_chat(user, span_danger("It is impossible for you to imbue!")) //maybe remove (ashwalkers & icecats only) after some time
		return

	in_use = TRUE
	balloon_alert_to_viewers("imbuing...")

	var/obj/item/attacking_weapon = attacking_item

	var/datum/component/reagent_weapon/weapon_component = attacking_weapon.GetComponent(/datum/component/reagent_weapon)
	if(!weapon_component)
		fail_message(user, "cannot imbue")
		return

	if(length(weapon_component.imbued_reagent))
		fail_message(user, "already imbued")
		return

	if(!do_after(user, 10 SECONDS, target = src))
		fail_message(user, "stopped imbuing")
		return

	for(var/datum/reagent/weapon_reagent as anything in attacking_weapon.reagents.reagent_list)
		if(weapon_reagent.volume < MINIMUM_IMBUING_REAGENT_AMOUNT)
			attacking_weapon.reagents.remove_reagent(weapon_reagent.type)
			continue

		if(is_type_in_typecache(weapon_reagent, disallowed_reagents))
			balloon_alert(user, "cannot imbue with [weapon_reagent.name]")
			attacking_weapon.reagents.remove_reagent(weapon_reagent.type, include_subtypes = TRUE)
			continue

		weapon_component.imbued_reagent += weapon_reagent.type
		attacking_weapon.name = "[weapon_reagent.name] [attacking_weapon.name]"

	attacking_weapon.color = mix_color_from_reagents(attacking_weapon.reagents.reagent_list)
	balloon_alert_to_viewers("imbued [attacking_weapon]")
	user.mind.adjust_experience(/datum/skill/smithing, 60)
	playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
	in_use = FALSE
	return TRUE

/// Handles clothing imbuing, extremely similar to weapon imbuing but not in the same proc because of how uhh... goofy the way this has to be done is
/obj/structure/reagent_forge/proc/handle_clothing_imbue(obj/attacking_item, mob/living/user)
	//This code will refuse all non-ashwalkers & non-icecats from imbuing
	if(!ishuman(user))
		to_chat(user, span_danger("It is impossible for you to imbue!")) //maybe remove (ashwalkers & icecats only) after some time
		return

	var/mob/living/carbon/human/human_user = user
	if(!is_species(human_user, /datum/species/lizard/ashwalker) && !is_species(human_user, /datum/species/human/felinid/primitive))
		to_chat(user, span_danger("It is impossible for you to imbue!")) //maybe remove (ashwalkers & icecats only) after some time
		return

	in_use = TRUE
	balloon_alert_to_viewers("imbuing...")

	var/obj/item/attacking_clothing = attacking_item

	var/datum/component/reagent_clothing/clothing_component = attacking_clothing.GetComponent(/datum/component/reagent_clothing)
	if(!clothing_component)
		fail_message(user, "cannot imbue")
		return

	if(length(clothing_component.imbued_reagent))
		fail_message(user, "already imbued")
		return

	if(!do_after(user, 10 SECONDS, target = src))
		fail_message(user, "stopped imbuing")
		return

	for(var/datum/reagent/clothing_reagent as anything in attacking_clothing.reagents.reagent_list)
		if(clothing_reagent.volume < MINIMUM_IMBUING_REAGENT_AMOUNT)
			attacking_clothing.reagents.remove_reagent(clothing_reagent.type, include_subtypes = TRUE)
			continue

		if(is_type_in_typecache(clothing_reagent, disallowed_reagents))
			balloon_alert(user, "cannot imbue with [clothing_reagent.name]")
			attacking_clothing.reagents.remove_reagent(clothing_reagent.type, include_subtypes = TRUE)
			continue

		clothing_component.imbued_reagent += clothing_reagent.type
		attacking_clothing.name = "[clothing_reagent.name] [attacking_clothing.name]"

	attacking_clothing.color = mix_color_from_reagents(attacking_clothing.reagents.reagent_list)
	balloon_alert_to_viewers("imbued [attacking_clothing]")
	user.mind.adjust_experience(/datum/skill/smithing, 60)
	playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
	in_use = FALSE
	return TRUE

/// Sets ceramic items from their unusable state into their finished form
/obj/structure/reagent_forge/proc/handle_ceramics(obj/attacking_item, mob/living/user)
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/obj/item/ceramic/ceramic_item = attacking_item
	var/ceramic_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * BASELINE_ACTION_TIME

	if(!ceramic_item.forge_item)
		fail_message(user, "cannot set [ceramic_item]")
		return

	balloon_alert_to_viewers("setting [ceramic_item]")

	if(!do_after(user, ceramic_speed, target = src))
		fail_message("stopped setting [ceramic_item]")
		return

	balloon_alert(user, "finished setting [ceramic_item]")
	var/obj/item/ceramic/spawned_ceramic = new ceramic_item.forge_item(get_turf(src))
	user.mind.adjust_experience(/datum/skill/production, 50)
	spawned_ceramic.color = ceramic_item.color
	qdel(ceramic_item)
	in_use = FALSE

/// Handles the creation of molten glass from glass sheets
/obj/structure/reagent_forge/proc/handle_glass_sheet_melting(obj/attacking_item, mob/living/user)
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/obj/item/stack/sheet/glass/glass_item = attacking_item
	var/glassblowing_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * BASELINE_ACTION_TIME
	var/glassblowing_amount = BASELINE_HEATING_DURATION / user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER)

	balloon_alert_to_viewers("heating...")

	if(!do_after(user, glassblowing_speed, target = src) || !glass_item.use(1))
		fail_message(user, "stopped heating [glass_item]")
		return

	in_use = FALSE
	var/obj/item/glassblowing/molten_glass/spawned_glass = new /obj/item/glassblowing/molten_glass(get_turf(src))
	user.mind.adjust_experience(/datum/skill/production, 10)
	COOLDOWN_START(spawned_glass, remaining_heat, glassblowing_amount)
	spawned_glass.total_time = glassblowing_amount

/// Handles creating molten glass from a metal cup filled with sand
/obj/structure/reagent_forge/proc/handle_metal_cup_melting(obj/attacking_item, mob/living/user)
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/obj/item/glassblowing/metal_cup/metal_item = attacking_item
	var/glassblowing_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * BASELINE_ACTION_TIME
	var/glassblowing_amount = BASELINE_HEATING_DURATION / user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER)

	if(!metal_item.has_sand)
		fail_message(user, "[metal_item] has no sand")
		return

	balloon_alert_to_viewers("heating...")

	if(!do_after(user, glassblowing_speed, target = src))
		fail_message(user, "stopped heating [metal_item]")
		return

	in_use = FALSE
	metal_item.has_sand = FALSE
	metal_item.icon_state = "metal_cup_empty" // This should be handled a better way but presently this is how it works
	var/obj/item/glassblowing/molten_glass/spawned_glass = new /obj/item/glassblowing/molten_glass(get_turf(src))
	user.mind.adjust_experience(/datum/skill/production, 10)
	COOLDOWN_START(spawned_glass, remaining_heat, glassblowing_amount)
	spawned_glass.total_time = glassblowing_amount

/// Almost a copy from the proc smelt_ore but to smelt iron rods
/obj/structure/reagent_forge/proc/smelt_iron_rods(obj/attacking_item, mob/living/user)

	var/obj/item/stack/rods/rod_item = attacking_item

	if(!istype(rod_item))
		return

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER)

	if(rod_item.amount < 2)
		fail_message(user, "too few iron rods to smelt")
		return

	balloon_alert_to_viewers("smelting...")

	if(!do_after(user, skill_modifier * 3 SECONDS, target = src))
		fail_message(user, "stopped smelting [rod_item]")
		return

	var/rods_to_sheet_amount = round((rod_item.amount / 2))
	var/used_rods = rod_item.amount

	if(ISODD(used_rods))
		used_rods = used_rods - 1

	rod_item.use(used_rods)
	new /obj/item/stack/sheet/iron(drop_location(), rods_to_sheet_amount)

	balloon_alert_to_viewers("finished smelting!")

/obj/structure/reagent_forge/billow_act(mob/living/user, obj/item/tool)
	if(in_use) // Preventing billow use if the forge is in use to prevent spam
		fail_message(user, "forge busy")
		return ITEM_INTERACT_SUCCESS

	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER)
	var/obj/item/forging/forge_item = tool

	if(!forge_fuel_strong && !forge_fuel_weak)
		fail_message(user, "no fuel in [src]")
		return ITEM_INTERACT_SUCCESS

	if(forge_temperature >= MAX_FORGE_TEMP)
		fail_message(user, "[src] cannot heat further")
		return ITEM_INTERACT_SUCCESS

	balloon_alert_to_viewers("billowing...")

	in_use = TRUE
	while(forge_temperature < 91)
		if(!do_after(user, (skill_modifier * forge_item.toolspeed) SECONDS, target = src))
			balloon_alert_to_viewers("stopped billowing")
			in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		forge_temperature += 10
		user.mind.adjust_experience(/datum/skill/smithing, 5) // Billowing, like fueling, gives you some experience in forging

	in_use = FALSE
	balloon_alert(user, "successfully heated [src]")
	return ITEM_INTERACT_SUCCESS

/obj/structure/reagent_forge/tong_act(mob/living/user, obj/item/tool)
	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER)
	var/obj/item/forging/forge_item = tool

	if(in_use || forge_item.in_use)
		fail_message(user, "forge busy")
		return ITEM_INTERACT_SUCCESS

	in_use = TRUE
	forge_item.in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		forge_item.in_use = FALSE
		return ITEM_INTERACT_SUCCESS

	// Here we check the item used on us (tongs) for an incomplete forge item of some kind to heat
	var/obj/item/forging/incomplete/search_incomplete = locate(/obj/item/forging/incomplete) in forge_item.contents
	if(search_incomplete)
		if(!COOLDOWN_FINISHED(search_incomplete, heating_remainder))
			fail_message(user, "metal doesn't need heating")
			forge_item.in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		balloon_alert_to_viewers("heating [search_incomplete]")

		if(!do_after(user, skill_modifier * forge_item.toolspeed, target = src))
			balloon_alert_to_viewers("stopped heating [search_incomplete]")
			forge_item.in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		COOLDOWN_START(search_incomplete, heating_remainder, FORGE_HEATING_DURATION)
		in_use = FALSE
		forge_item.in_use = FALSE
		user.mind.adjust_experience(/datum/skill/smithing, 5) // Heating up forge items grants some experience
		balloon_alert(user, "successfully heated [search_incomplete]")
		return ITEM_INTERACT_SUCCESS

	// Here we check the item used on us (tongs) for a stack of some kind to create an object from
	var/obj/item/stack/search_stack = locate(/obj/item/stack) in forge_item.contents
	if(search_stack)
		var/user_choice = show_radial_menu(user, src, radial_choice_list, radius = 38, require_near = TRUE, tooltips = TRUE)
		if(!user_choice)
			fail_message(user, "nothing chosen")
			forge_item.in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		// Sets up a list of the materials to give to the item later
		var/list/material_list = list()

		if(search_stack.material_type)
			material_list[GET_MATERIAL_REF(search_stack.material_type)] = SHEET_MATERIAL_AMOUNT

		else
			for(var/material as anything in search_stack.custom_materials)
				material_list[material] = SHEET_MATERIAL_AMOUNT

		if(!search_stack.use(1))
			fail_message(user, "not enough of [search_stack]")
			forge_item.in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		balloon_alert_to_viewers("heating [search_stack]")

		if(!do_after(user, skill_modifier * forge_item.toolspeed, target = src))
			balloon_alert_to_viewers("stopped heating [search_stack]")
			forge_item.in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		var/spawn_item = choice_list[user_choice]
		var/obj/item/forging/incomplete/incomplete_item = new spawn_item(get_turf(src))

		if(material_list)
			incomplete_item.set_custom_materials(material_list)

		COOLDOWN_START(incomplete_item, heating_remainder, FORGE_HEATING_DURATION)
		in_use = FALSE
		forge_item.in_use = FALSE
		balloon_alert(user, "prepared [search_incomplete] into [user_choice]")
		search_stack = locate(/obj/item/stack) in forge_item.contents

		if(!search_stack)
			forge_item.icon_state = "tong_empty"
		return ITEM_INTERACT_SUCCESS

	in_use = FALSE
	forge_item.in_use = FALSE
	return ITEM_INTERACT_SUCCESS

/obj/structure/reagent_forge/blowrod_act(mob/living/user, obj/item/tool)
	var/obj/item/glassblowing/blowing_rod/blowing_item = tool
	var/glassblowing_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * BASELINE_ACTION_TIME
	var/glassblowing_amount = BASELINE_HEATING_DURATION / user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER)

	if(in_use)
		to_chat(user, span_warning("You cannot do multiple things at the same time!"))
		return ITEM_INTERACT_SUCCESS
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "The temperature is not hot enough to start heating [blowing_item].")
		return ITEM_INTERACT_SUCCESS

	var/obj/item/glassblowing/molten_glass/find_glass = locate() in blowing_item.contents
	if(!find_glass)
		fail_message(user, "[blowing_item] does not have any glass to heat up.")
		return ITEM_INTERACT_SUCCESS

	if(!COOLDOWN_FINISHED(find_glass, remaining_heat))
		fail_message(user, "[find_glass] is still has remaining heat.")
		return ITEM_INTERACT_SUCCESS

	to_chat(user, span_notice("You begin heating up [blowing_item]."))

	if(!do_after(user, glassblowing_speed, target = src))
		fail_message(user, "[blowing_item] is interrupted in its heating process.")
		return ITEM_INTERACT_SUCCESS

	COOLDOWN_START(find_glass, remaining_heat, glassblowing_amount)
	find_glass.total_time = glassblowing_amount
	to_chat(user, span_notice("You finish heating up [blowing_item]."))
	user.mind.adjust_experience(/datum/skill/smithing, 5)
	user.mind.adjust_experience(/datum/skill/production, 10)
	in_use = FALSE
	return ITEM_INTERACT_SUCCESS

/obj/structure/reagent_forge/wrench_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	deconstruct(TRUE)
	return TRUE

/obj/structure/reagent_forge/atom_deconstruct(disassembled)
	new /obj/item/stack/sheet/iron/ten(get_turf(src))
	return ..()

/obj/structure/reagent_forge/tier2
	forge_level = FORGE_LEVEL_NOVICE

/obj/structure/reagent_forge/tier3
	forge_level = FORGE_LEVEL_APPRENTICE

/obj/structure/reagent_forge/tier4
	forge_level = FORGE_LEVEL_JOURNEYMAN

/obj/structure/reagent_forge/tier5
	forge_level = FORGE_LEVEL_EXPERT

/obj/structure/reagent_forge/tier6
	forge_level = FORGE_LEVEL_MASTER

/obj/structure/reagent_forge/tier7
	forge_level = FORGE_LEVEL_LEGENDARY

/obj/structure/reagent_forge/tier7/imbuing/Initialize(mapload)
	. = ..()
	create_reagent_forge()

/particles/smoke/mild
	spawning = 1
	velocity = list(0, 0.3, 0)
	friction = 0.25

#undef BASELINE_ACTION_TIME

#undef BASELINE_HEATING_DURATION

#undef FORGE_DEFAULT_TEMPERATURE_CHANGE
#undef MAX_FORGE_TEMP
#undef MIN_FORGE_TEMP
#undef FORGE_HEATING_DURATION

#undef FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB
#undef FORGE_LEVEL_NOVICE
#undef FORGE_LEVEL_APPRENTICE
#undef FORGE_LEVEL_JOURNEYMAN
#undef FORGE_LEVEL_EXPERT
#undef FORGE_LEVEL_MASTER
#undef FORGE_LEVEL_LEGENDARY

#undef MAX_TEMPERATURE_LOSS_DECREASE

#undef CHARCOAL_CHANCE

#undef MINIMUM_IMBUING_REAGENT_AMOUNT

#undef SMOKE_STATE_NONE
#undef SMOKE_STATE_GOOD
#undef SMOKE_STATE_NEUTRAL
#undef SMOKE_STATE_BAD
#undef SMOKE_STATE_NOT_COOKING
