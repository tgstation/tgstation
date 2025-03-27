// Cubes that are a reference to something else

// Puzzle Cube
/// Lament Configuration (Hellraiser)
/obj/item/cube/puzzle
	name = "\improper Lament Configuration"
	desc = "A strange box of metal and wood, you get a strange feeling looking at it."
	icon_state = "lament"
	rarity = EPIC_CUBE
	reference = TRUE
	overwrite_held_color = COLOR_LIGHT_BROWN
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
	overwrite_held_color = COLOR_BRIGHT_BLUE

// Grass (Minecraft)
/obj/item/cube/craft
	name = "grass cube"
	desc = "Despite being made of solid soil, you can dig inside to find the occasional diamond!"
	icon_state = "craft"
	rarity = MYTHICAL_CUBE
	reference = TRUE
	overwrite_held_color = COLOR_LIGHT_BROWN
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
	overwrite_held_color = COLOR_LIME

/obj/item/cube/generic/Initialize(mapload)
	. = ..()
	/// It's PERFECTLY generic.
	AddComponent(/datum/component/anti_magic, \
		antimagic_flags = MAGIC_RESISTANCE | MAGIC_RESISTANCE_MIND | MAGIC_RESISTANCE_HOLY, \
		inventory_flags = ITEM_SLOT_HANDS, \
		cooldown_speed = 10 SECONDS, \
		can_examine = TRUE\
	)

// Stock part cubes
/// Energon cube (Transformers)
/obj/item/stock_parts/capacitor/energon
	name = "energon cube"
	desc = "A capacitor which transports power through the 3rd dimension for higher throughput."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "energon"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
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

/obj/item/stock_parts/capacitor/energon/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_LIGHT_PINK))

/// Tesseract (Marvel)
/obj/item/stock_parts/power_store/cell/tesseract
	name = "tesseract"
	desc = "A rechargable power cell which pulls charge from the 3rd dimension to generate new electricity out of thin air."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "tesseract"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
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

/obj/item/stock_parts/power_store/cell/tesseract/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_BRIGHT_BLUE))

/// Holocron (Star Wars)
/obj/item/stock_parts/scanning_module/holocron
	name = "holocron cube"
	desc = "A compact scanning module capable of scanning in the 3rd dimension to create data unobservable to conventional technology."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "holocron"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
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

/obj/item/stock_parts/scanning_module/holocron/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_BRIGHT_BLUE))

/// Piston (Minecraft)
/obj/item/stock_parts/servo/piston
	name = "cubic piston"
	desc = "A servo motor capable of moving objects in and out of the 3rd dimension for increased precision."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "piston"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
	rating = 5
	energy_rating = 15
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.6)

/obj/item/stock_parts/servo/piston/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = LEGENDARY_CUBE, isreference = TRUE, ismapload = mapload)

/datum/stock_part/servo/piston
	tier = 5
	physical_object_type = /obj/item/stock_parts/servo/piston

/obj/item/stock_parts/servo/piston/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_GRAY))

/// Moving Box (The Binding of Isaac)
/obj/item/stock_parts/matter_bin/moving
	name = "moving box"
	desc = "A container capable of shunting matter into the 3rd dimension to await later retrieval."
	icon = 'icons/obj/cubes.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
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

/obj/item/stock_parts/matter_bin/moving/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_LIGHT_BROWN))

// Charged Blaster Cannon (Terraria)
/obj/item/stock_parts/micro_laser/charged_blaster
	name = "charged blaster cube"
	icon_state = "charged_blaster"
	desc = "A tiny device which routes light through the 3rd dimension in order to charge a powerful and precise laser beam!"
	icon = 'icons/obj/cubes.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
	rating = 5
	energy_rating = 15
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)

/obj/item/stock_parts/micro_laser/charged_blaster/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = LEGENDARY_CUBE, isreference = TRUE, ismapload = mapload)

/datum/stock_part/micro_laser/charged_blaster
	tier = 5
	physical_object_type = /obj/item/stock_parts/micro_laser/charged_blaster

/obj/item/stock_parts/micro_laser/charged_blaster/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_SILVER))

/// Question Mark Block (Mario)
/obj/item/gift/anything/questionmark
	name = "\improper ? cube"
	desc = "A cube is fine and all, but breaking it open could result in anything! It could even be a cube!"
	icon = 'icons/obj/cubes.dmi'
	icon_state = "question"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
	resistance_flags = INDESTRUCTIBLE
	random_icon = FALSE
	random_pixshift = FALSE
	unwrap_trash = /obj/effect/decal/cleanable/rubble
	tearsound = list('sound/effects/rock/rock_break.ogg' = 50)
	unwrap_time = 3 SECONDS
	unwrap_verbs = list("crushes", "breaks open", "fractures")

/obj/item/gift/anything/questionmark/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = MYTHICAL_CUBE, isreference = TRUE, ismapload = mapload)

/obj/item/gift/anything/questionmark/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_GOLD))

/// Default Cube (Blender)
// random_cubes can also invert your gravity but this is guaranteed while that is an exceedingly low chance.
/obj/item/cube/blender
	name = "default cube"
	desc = "You feel a strange desire to destroy this..."
	icon_state = "blender"
	rarity = MYTHICAL_CUBE
	reference = TRUE
	overwrite_held_color = COLOR_OFF_WHITE
	/// Who owns us
	var/datum/weakref/owner
	/// How many steps the user has taken since picking up cube w/ negative grav
	var/step_count = 0
	/// If you walk outside on a planetary turf, you fly up. To the sky. And Explode.
	var/you_fucked_up = FALSE

/obj/item/cube/blender/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	AddElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)

/// Check if we were picked up by a mob, and keep that user as a weakref until we're removed
/obj/item/cube/blender/proc/on_moved(atom/movable/source, atom/oldloc, direction, forced, list/old_locs)
	SIGNAL_HANDLER

	var/mob/living/existing_user = owner?.resolve()
	var/mob/living/holder = get_held_mob()
	if(existing_user)
		if(!holder)
			handle_dropping()
			return
		if(existing_user == holder)
			return
	else if(holder)
		handle_equipping(holder)


/obj/item/cube/blender/proc/handle_equipping(mob/living/user)
	owner = WEAKREF(user)
	passtable_on(src, TRAIT_FORCED_GRAVITY)
	user.AddElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
	playsound(src, 'sound/effects/curse/curseattack.ogg', 50)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_upstairs))
	RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(on_talk))
	ADD_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))
	passtable_on(user, REF(src))
	check_upstairs()


/// Upside down
/obj/item/cube/blender/proc/on_talk(datum/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= "upside_down"

/// Again ripped from atrocinator, but edited to account for lack of modsuit
/obj/item/cube/blender/proc/check_upstairs(atom/movable/source, atom/oldloc, direction, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	if(you_fucked_up || user.has_gravity() > NEGATIVE_GRAVITY)
		return

	var/turf/open/current_turf = get_turf(user)
	var/turf/open/openspace/turf_above = get_step_multiz(user, UP)
	if(current_turf && istype(turf_above))
		current_turf.zFall(user)
		return

	else if(!turf_above && istype(current_turf) && current_turf.planetary_atmos) //nothing holding you down
		INVOKE_ASYNC(src, PROC_REF(fly_away))
		return

	if (forced || (SSlag_switch.measures[DISABLE_FOOTSTEPS] && !(HAS_TRAIT(source, TRAIT_BYPASS_MEASURES))))
		return

	if(!(step_count % 2))
		playsound(current_turf, 'sound/items/modsuit/atrocinator_step.ogg', 50)
	step_count++

#define FLY_TIME 5 SECONDS

// Because it's a little harder to just "not turn on the cube outside", we're instead calling destroy_legs()
/obj/item/cube/blender/proc/fly_away()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	you_fucked_up = TRUE
	ADD_TRAIT(src, TRAIT_NODROP, NEGATIVE_GRAVITY_TRAIT)
	playsound(src, 'sound/effects/whirthunk.ogg', 75)
	to_chat(user, span_userdanger("[src] is pulling you into space! You can't let go!"))
	user.Stun(FLY_TIME, ignore_canstun = TRUE)
	animate(user, FLY_TIME, pixel_z = 300, alpha = 0)
	addtimer(CALLBACK(src, PROC_REF(initiate_fall)), FLY_TIME)

#undef FLY_TIME
#define FALL_TIME 3 DECISECONDS

/// We're pretty high up huh
/obj/item/cube/blender/proc/initiate_fall()
	passtable_off(src, TRAIT_FORCED_GRAVITY)
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	playsound(src, 'sound/effects/whirthunk.ogg', 25)
	to_chat(user, span_userdanger("[src] suddenly stops pulling you. You're starting to fall!"))
	animate(user, FALL_TIME, pixel_z = 0, alpha = 255)
	addtimer(CALLBACK(src, PROC_REF(destroy_legs)), FALL_TIME)

#undef FALL_TIME

/// Honestly destroying more than just the legs but yknow, it's similar enough
/obj/item/cube/blender/proc/destroy_legs()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	handle_neggrav_remove()
	REMOVE_TRAIT(src, TRAIT_NODROP, NEGATIVE_GRAVITY_TRAIT)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/effects/gravhit.ogg', 75)
	investigate_log("was sent plummeting to [user.p_their()] death by [src].", INVESTIGATE_DEATHS)
	user.gib(DROP_ALL_REMAINS)

/obj/item/cube/blender/proc/handle_neggrav_remove()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	UnregisterSignal(user, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOB_SAY
	))
	user.RemoveElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
	step_count = 0
	REMOVE_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))
	passtable_off(user, REF(src))
	var/turf/open/openspace/current_turf = get_turf(user)
	if(istype(current_turf))
		current_turf.zFall(user, falling_from_move = TRUE)

// It's at least not permanent
/obj/item/cube/blender/proc/handle_dropping()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	handle_neggrav_remove()
	owner = null
