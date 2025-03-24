// Cubes that are a reference to something else

// Puzzle Cube
/// Lament Configuration (Hellraiser)
/obj/item/cube/puzzle
	name = "\improper Lament Configuration"
	desc = "A strange box of metal and wood, you get a strange feeling looking at it."
	icon_state = "lament"
	rarity = EPIC_CUBE
	reference = TRUE
	/// Have we solved the puzzle?
	var/solved = FALSE
	/// Swaps our message & summons a silly little guy
	var/eldritchsolve = TRUE

/obj/item/cube/puzzle/attack_self(mob/user)
	. = ..()
	if(solved)
		balloon_alert(user, "Already solved")
		return
	if(!isliving(user))
		return
	var/mob/living/solver = user
	// Oh yea. Now we're gaming.
	var/skill_level = solver?.mind?.get_skill_level(/datum/skill/gaming) || 1
	to_chat(solver, "You concentrate on solving [src]...")
	if(!do_after(solver, round((13*rarity) SECONDS / skill_level)))
		balloon_alert(solver, "Lost concentration!")
		return
	solver?.mind?.adjust_experience(/datum/skill/gaming, 15*rarity)
	var/solve_msg = "Solved!"
	if(eldritchsolve)
		solve_msg = "THE BOX, YOU OPENED IT!"
		addtimer(CALLBACK(src, PROC_REF(he_did_what), solver), 5 SECONDS)
	balloon_alert(solver, solve_msg)
	solved = TRUE
	icon_state = "[icon_state]_solved"
	update_cube_rarity(rarity+1)

/// Spawn the guy
/obj/item/cube/puzzle/proc/he_did_what(mob/living/user)
	var/turf/newloc = pick(spiral_range_turfs(5, get_turf(user)))
	var/mob/living/pinhead = new /mob/living/basic/heretic_summon/stalker(newloc)
	new /obj/effect/temp_visual/mook_dust(get_turf(newloc))
	playsound(pinhead, 'sound/effects/magic/demon_attack1.ogg', 75)
	pinhead.say("I CAME!!")

/obj/item/cube/puzzle/examine(mob/user)
	. = ..()
	if(!solved)
		. += span_notice("It is yet to be solved...")
	else
		. += span_nicegreen("It's already been solved!")

/// Rubiks (Real Life)
/obj/item/cube/puzzle/rubiks
	name = "\improper Rubik's Cube"
	desc = "A famous cube housing a small sliding puzzle."
	icon_state = "rubik"
	rarity = RARE_CUBE
	eldritchsolve = FALSE

// Grass (Minecraft)
/obj/item/cube/craft
	name = "grass cube"
	desc = "Despite being made of solid soil, you can dig inside to find the occasional diamond!"
	icon_state = "craft"
	rarity = MYTHICAL_CUBE
	reference = TRUE
	/// How much is a full stack of diamonds?
	var/full_stack = 64
	/// How long does it take for us to mine diamonds? Default: 15 SECONDS
	var/mine_cooldown = 15 SECONDS

	COOLDOWN_DECLARE(cube_diamond_cooldown)

/obj/item/cube/craft/Initialize(mapload)
	. = ..()
	create_storage(2, WEIGHT_CLASS_HUGE, full_stack, /obj/item/stack/sheet/mineral/diamond)
	atom_storage.numerical_stacking = TRUE
	START_PROCESSING(SSobj, src)

/obj/item/cube/craft/examine(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, cube_diamond_cooldown))
		. += span_notice("It will mine a new diamond in [DisplayTimeText(COOLDOWN_TIMELEFT(src, cube_diamond_cooldown))].")

/// Create a diamond after a cooldown
/obj/item/cube/craft/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, cube_diamond_cooldown))
		return
	var/successful_haul = FALSE
	var/total_in_stack = 0
	var/list/sheets = list()
	for(var/obj/item/stack/sheet/miningaway in get_all_contents())
		total_in_stack += miningaway.amount
		if(miningaway.amount < miningaway.max_amount)
			sheets += miningaway
	if(total_in_stack >= full_stack)
		COOLDOWN_START(src, cube_diamond_cooldown, mine_cooldown)
		return
	if(sheets.len)
		var/obj/item/stack/sheet/miningaway = sheets[1]
		miningaway.add(1)
		successful_haul = TRUE
	else
		new /obj/item/stack/sheet/mineral/diamond(atom_storage.real_location)
		successful_haul = TRUE

	if(successful_haul)
		balloon_alert_to_viewers(message = "mined a diamond!", vision_distance = SAMETILE_MESSAGE_RANGE)

	COOLDOWN_START(src, cube_diamond_cooldown, mine_cooldown)

// Generic cube (Homestuck)
/obj/item/cube/generic
	name = "perfectly generic cube"
	desc = "It's entirely non-noteworthy."
	icon_state = "generic_object"
	rarity = MYTHICAL_CUBE
	reference = TRUE

// Stock part cubes
/// Energon cube (Transformers)
/obj/item/stock_parts/capacitor/energon
	name = "energon cube"
	desc = "A capacitor which transports power through the 3rd dimension for higher throughput."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "energon"
	rating = 5
	energy_rating = 15
	custom_materials = list(/datum/material/alloy/plasmaglass=SMALL_MATERIAL_AMOUNT)
	light_range = 2
	light_power = 0.5
	light_system = OVERLAY_LIGHT
	light_color = COLOR_LIGHT_PINK

/obj/item/stock_parts/capacitor/energon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = LEGENDARY_CUBE, isreference = TRUE, ismapload = mapload)

/datum/stock_part/capacitor/energon
	tier = 5
	physical_object_type = /obj/item/stock_parts/capacitor/energon

/// Tesseract (Marvel)
/obj/item/stock_parts/power_store/cell/tesseract
	name = "tesseract"
	desc = "A rechargable power cell which pulls charge from the 3rd dimension to generate new electricity out of thin air."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "tesseract"
	charge_light_type = null
	connector_type = null
	maxcharge = STANDARD_CELL_CHARGE * 50
	custom_materials = list(/datum/material/bluespace=SMALL_MATERIAL_AMOUNT*4)
	chargerate = STANDARD_CELL_RATE * 2
	light_range = 2
	light_power = 0.5
	light_system = OVERLAY_LIGHT
	light_color = COLOR_BRIGHT_BLUE

/obj/item/stock_parts/power_store/cell/tesseract/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = MYTHICAL_CUBE, isreference = TRUE, ismapload = mapload)
	START_PROCESSING(SSobj, src)

/// Welcome back Hypercharged Yellow Slime Core
/obj/item/stock_parts/power_store/cell/tesseract/process(seconds_per_tick)
	give(0.1 * chargerate * seconds_per_tick)

/// Holocron (Star Wars)
/obj/item/stock_parts/scanning_module/holocron
	name = "holocron cube"
	desc = "A compact scanning module capable of scanning in the 3rd dimension to create data unobservable to conventional technology."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "holocron"
	rating = 5
	energy_rating = 15
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.8, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4)
	light_range = 1
	light_power = 0.5
	light_system = OVERLAY_LIGHT
	light_color = COLOR_BRIGHT_BLUE

/obj/item/stock_parts/scanning_module/holocron/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = LEGENDARY_CUBE, isreference = TRUE, ismapload = mapload)

/datum/stock_part/scanning_module/holocron
	tier = 5
	physical_object_type = /obj/item/stock_parts/scanning_module/holocron

/// Piston (Minecraft)
/obj/item/stock_parts/servo/piston
	name = "cubic piston"
	desc = "A servo motor capable of moving objects in and out of the 3rd dimension for increased precision."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "piston"
	rating = 5
	energy_rating = 15
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.6)

/obj/item/stock_parts/servo/piston/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = LEGENDARY_CUBE, isreference = TRUE, ismapload = mapload)

/datum/stock_part/servo/piston
	tier = 5
	physical_object_type = /obj/item/stock_parts/servo/piston

/// Moving Box (The Binding of Isaac)
/obj/item/stock_parts/matter_bin/moving
	name = "moving box"
	desc = "A container capable of shunting matter into the 3rd dimension to await later retrieval."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "moving"
	rating = 5
	energy_rating = 15
	custom_materials = list(/datum/material/cardboard=SMALL_MATERIAL_AMOUNT*4)

/obj/item/stock_parts/matter_bin/moving/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = LEGENDARY_CUBE, isreference = TRUE, ismapload = mapload)

/datum/stock_part/matter_bin/moving
	tier = 5
	physical_object_type = /obj/item/stock_parts/matter_bin/moving
