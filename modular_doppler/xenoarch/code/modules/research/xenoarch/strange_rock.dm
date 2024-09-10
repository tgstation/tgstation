#define DIG_UNDEFINED 	(1<<0) //when the strange rock is dug by an item with no dig depth.
#define DIG_DELETE 		(1<<1) //when the strange rock is dug too deep and gets destroyed in the process.
#define DIG_ROCK		(1<<2) //when the strange rock is just dug, with no additional effects.

#define BRUSH_DELETE	(2<<0) //when the strange rock is brushed and the strange rock gets destroyed.
#define BRUSH_UNCOVER	(2<<1) //when the strange rock is brushed and the strange rock reveals what it held.
#define BRUSH_NONE		(2<<2) //when the strange rock is brushed, with no additional effects.

#define REWARD_ONE 1
#define REWARD_TWO 2
#define REWARD_THREE 3

/obj/item/xenoarch/strange_rock
	name = "strange rock"
	desc = "A mysterious, strange rock that has the potential to have a wonderful item. Also possible for it to have our disposed garbage."
	icon_state = "rock"

	///The max depth a strange rock can be
	var/max_depth
	///The depth away/subtracted from the max_depth
	var/safe_depth
	//The depth chosen between the max and the max - safe depth
	var/item_depth
	//The depth that has been currently dug
	var/dug_depth = 0
	//The item that is hidden within the strange rock
	var/hidden_item
	///Whether the item has been measured, revealing the dug depth
	var/measured = FALSE
	///Whether the ite has been scanned, revealing the max and safe depth
	var/scanned = FALSE
	///Whether the ite has been advance scanned, revealing the true depth
	var/adv_scanned = FALSE
	///The scan state for when encountering the strange rock ore in mining.
	var/scan_state = "rock_Strange"
	///The tier of the item that was chosen, 1-100 then 1-3
	var/choose_tier

/obj/item/xenoarch/strange_rock/Initialize(mapload)
	. = ..()
	create_item()
	create_depth()

/obj/item/xenoarch/strange_rock/examine(mob/user)
	. = ..()
	. += span_notice("[scanned ? "This item has been scanned. Max Depth: [max_depth] cm. Safe Depth: [safe_depth] cm." : "This item has not been scanned."]")
	if(adv_scanned)
		. += span_notice("The item depth is [item_depth] cm.")
	. += span_notice("[measured ? "This item has been measured. Dug Depth: [dug_depth]." : "This item has not been measured."]")
	if(measured && dug_depth > item_depth)
		. += span_warning("The rock is crumbling, even just brushing it will destroy it!")

/obj/item/xenoarch/strange_rock/proc/create_item()
	choose_tier = rand(1,100)
	switch(choose_tier)
		if(1 to 60)
			hidden_item = pick_weight(GLOB.tier1_reward)
			choose_tier = REWARD_ONE
		if(61 to 87)
			hidden_item = pick_weight(GLOB.tier2_reward)
			choose_tier = REWARD_TWO
		if(88 to 100)
			hidden_item = pick_weight(GLOB.tier3_reward)
			choose_tier = REWARD_THREE

/obj/item/xenoarch/strange_rock/proc/create_depth()
	max_depth = rand(21, (22 * choose_tier))
	safe_depth = rand(1, 10)
	item_depth = rand((max_depth - safe_depth), max_depth)
	dug_depth = rand(0, 10)

//returns true if the strange rock is measured
/obj/item/xenoarch/strange_rock/proc/get_measured()
	if(measured)
		return FALSE
	measured = TRUE
	return TRUE

//returns true if the strange rock is scanned
/obj/item/xenoarch/strange_rock/proc/get_scanned(use_advanced = FALSE)
	if(scanned)
		if(!adv_scanned && use_advanced)
			adv_scanned = TRUE
			return TRUE
		return FALSE
	scanned = TRUE
	if(use_advanced)
		adv_scanned = TRUE
	return TRUE

/obj/item/xenoarch/strange_rock/proc/try_dig(dig_amount)
	if(!dig_amount)
		return DIG_UNDEFINED
	dug_depth += dig_amount
	if(dug_depth > item_depth)
		qdel(src)
		return DIG_DELETE
	return DIG_ROCK

/obj/item/xenoarch/strange_rock/proc/try_uncover()
	if(dug_depth > item_depth)
		qdel(src)
		return BRUSH_DELETE
	if(dug_depth == item_depth)
		new hidden_item(get_turf(src))
		qdel(src)
		return BRUSH_UNCOVER
	try_dig(1)
	return BRUSH_NONE

/obj/item/xenoarch/strange_rock/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/xenoarch/hammer))
		var/obj/item/xenoarch/hammer/xeno_hammer = I
		to_chat(user, span_notice("You begin carefully using your hammer."))
		if(!do_after(user, xeno_hammer.dig_speed, target = src))
			to_chat(user, span_warning("You interrupt your careful planning, damaging the rock in the process!"))
			dug_depth += rand(1,5)
			return
		switch(try_dig(xeno_hammer.dig_amount))
			if(DIG_UNDEFINED)
				message_admins("Tell coders something broke with xenoarch hammers and dig amount.")
				return
			if(DIG_DELETE)
				to_chat(user, span_warning("The rock crumbles, leaving nothing behind."))
				return
			if(DIG_ROCK)
				to_chat(user, span_notice("You successfully dig around the item."))

	if(istype(I, /obj/item/xenoarch/brush))
		var/obj/item/xenoarch/brush/xeno_brush = I
		to_chat(user, span_notice("You begin carefully using your brush."))
		if(!do_after(user, xeno_brush.dig_speed, target = src))
			to_chat(user, span_warning("You interrupt your careful planning, damaging the rock in the process!"))
			dug_depth += rand(1,5)
			return
		switch(try_uncover())
			if(BRUSH_DELETE)
				to_chat(user, span_warning("The rock crumbles, leaving nothing behind."))
				return
			if(BRUSH_UNCOVER)
				to_chat(user, span_notice("You successfully brush around the item, fully revealing the item!"))
				return
			if(BRUSH_NONE)
				to_chat(user, span_notice("You brush around the item, but it wasn't revealed... hammer some more."))

	if(istype(I, /obj/item/xenoarch/tape_measure))
		to_chat(user, span_notice("You begin carefully using your measuring tape."))
		if(!do_after(user, 4 SECONDS, target = src))
			to_chat(user, span_warning("You interrupt your careful planning, damaging the rock in the process!"))
			dug_depth += rand(1,5)
			return
		if(get_measured())
			to_chat(user, span_notice("You successfully attach a holo measuring tape to the strange rock; the strange rock will now report its dug depth always!"))
			return
		to_chat(user, span_warning("The strange rock was already marked with a holo measuring tape."))

	if(istype(I, /obj/item/xenoarch/handheld_scanner))
		var/obj/item/xenoarch/handheld_scanner/item_scanner = I
		to_chat(user, span_notice("You begin to scan [src] using [item_scanner]."))
		if(!do_after(user, item_scanner.scanning_speed, target = src))
			to_chat(user, span_warning("You interrupt your scanning, damaging the rock in the process!"))
			dug_depth += rand(1,5)
			return
		if(get_scanned(item_scanner.scan_advanced))
			to_chat(user, span_notice("You successfully attach a holo scanning module to the strange rock; the strange rock will now report its depth information always!"))
			if(adv_scanned)
				to_chat(user, span_notice("The rock's item depth is being reported!"))
			return
		to_chat(user, span_warning("The strange rock was already marked with a holo scanning module."))

//turfs
/turf/closed/mineral/strange_rock
	mineralAmt = 1
	icon = MAP_SWITCH('modular_doppler/xenoarch/icons/smoothrocks.dmi', 'modular_doppler/xenoarch/icons/mining.dmi')
	scan_state = "rock_Strange"
	mineralType = /obj/item/xenoarch/strange_rock

/turf/closed/mineral/strange_rock/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/random/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE
	mineralChance = 10

/turf/closed/mineral/random/volcanic/mineral_chances()
	return list(
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/gold = 10,
		/turf/closed/mineral/strange_rock/volcanic = 10,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/gibtonite/volcanic = 4,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/bluespace_crystal = 1
		)

/turf/closed/mineral/strange_rock/ice
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'modular_doppler/xenoarch/icons/mining.dmi')
	icon_state = "icerock_strange"
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/misc/asteroid/snow/ice
	baseturfs = /turf/open/misc/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/strange_rock/ice/icemoon
	turf_type = /turf/open/misc/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/random/snow/mineral_chances()
	return list(
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/gold = 10,
		/turf/closed/mineral/strange_rock/ice/icemoon = 10,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/gibtonite/ice/icemoon = 4,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/bluespace_crystal = 1,
		)

/turf/closed/mineral/random/snow/underground
	baseturfs = /turf/open/misc/asteroid/snow/icemoon
	// abundant ore
	mineralChance = 20

/turf/closed/mineral/random/snow/underground/mineral_chances()
	return list(
		/obj/item/stack/ore/silver = 24,
		/obj/item/stack/ore/titanium = 22,
		/obj/item/stack/ore/gold = 20,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/uranium = 10,
		/turf/closed/mineral/strange_rock/ice/icemoon = 10,
		/turf/closed/mineral/gibtonite/ice/icemoon = 8,
		/obj/item/stack/ore/diamond = 4,
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stack/ore/bananium = 1,
		)

//small gibonite fix
/turf/closed/mineral/gibtonite/asteroid
	icon = MAP_SWITCH('modular_doppler/xenoarch/icons/mining.dmi', 'icons/turf/mining.dmi')
	icon_state = "redrock_Gibonite_inactive"
	base_icon_state = "red_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/misc/asteroid
	baseturfs = /turf/open/misc/asteroid
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/strange_rock/asteroid
	icon = MAP_SWITCH('modular_doppler/xenoarch/icons/mining.dmi', 'icons/turf/mining.dmi')
	icon_state = "redrock_strange"
	base_icon_state = "red_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/misc/asteroid
	baseturfs = /turf/open/misc/asteroid
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/random/stationside/asteroid/rockplanet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	turf_type = /turf/open/misc/asteroid
	mineralChance = 30

/turf/closed/mineral/random/stationside/asteroid/rockplanet/mineral_chances()
	return list(
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/gold = 10,
		/turf/closed/mineral/strange_rock/asteroid = 10,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/gibtonite/asteroid = 4,
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 1,
		)

#undef DIG_UNDEFINED
#undef DIG_DELETE
#undef DIG_ROCK

#undef BRUSH_DELETE
#undef BRUSH_UNCOVER
#undef BRUSH_NONE

#undef REWARD_ONE
#undef REWARD_TWO
#undef REWARD_THREE
