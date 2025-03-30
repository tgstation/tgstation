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
		balloon_alert(user, "already solved")
		return
	if(!isliving(user))
		return
	var/mob/living/solver = user
	// Oh yea. Now we're gaming.
	var/skill_level = solver?.mind?.get_skill_level(/datum/skill/gaming) || 1
	to_chat(solver, "You concentrate on solving [src]...")
	if(!do_after(solver, round((13*rarity) SECONDS / skill_level)))
		balloon_alert(solver, "lost concentration!")
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

/obj/item/cube/blender/Destroy(force)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	handle_dropping()
	return ..()

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

// Time cube (time cube)
/obj/item/cube/time_cube
	name = "\improper TIME CUBE"
	desc = "<div class='boxed_message red_box'><center><span class='notice'>STATION HAS 4 CORNER\n\
	SIMULTANEOUS 4-DAY\n\
	<b>TIME CUBE</b>\n\
	IN ONLY 24 HOUR ROTATION\n\
	<u>4 CORNER DAYS, CUBES 4 QUAD EARTH- No 1 Day God.</u>\n\
	*********************\n\
	FREE SPEECH in NANOTRASEN is\n\
	\"BULLSHIT\",\n\
	EVIL EDUCATORS\n\
	block and suppress\n\
	www.timecube.ntnet.\n\
	You are educated evil,\n\
	and might have to kill\n\
	the evil ONE teaching\n\
	educators before you\n\
	can learn that 4 corner\n\
	days actually exist -but\n\
	all Cube Truth denied.\n\
	Dumb ass educators fear\n\
	me and hide from debate.</span></center></div>"
	icon_state = "timecube"
	rarity = MYTHICAL_CUBE
	reference = TRUE
	overwrite_held_color = COLOR_OFF_WHITE
	/// Who owns us - I should really find a way to make this its own datum or something since I'm using it so much
	var/datum/weakref/owner
	/// How long we wait between stops
	var/cooldown_time = 1 MINUTES
	/// How long the stop lasts
	var/stop_duration = 10 SECONDS
	/// The radius of the stop
	var/radius = 3

	COOLDOWN_DECLARE(stop_time_cooldown)

/obj/item/cube/time_cube/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	register_context()
	add_overlay(mutable_appearance(icon = icon, icon_state = "timecube_glow", appearance_flags = KEEP_TOGETHER | KEEP_APART))

/obj/item/cube/time_cube/Destroy(force)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	handle_dropping()
	return ..()

/// Check if we were picked up by a mob, and keep that user as a weakref until we're removed
/obj/item/cube/time_cube/proc/on_moved(atom/movable/source, atom/oldloc, direction, forced, list/old_locs)
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

/// Make the user immune to timestop
/obj/item/cube/time_cube/proc/handle_equipping(mob/living/holder)
	owner = WEAKREF(holder)
	ADD_TRAIT(holder, TRAIT_TIME_STOP_IMMUNE, REF(src))

/// remove the immunity
/obj/item/cube/time_cube/proc/handle_dropping()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	REMOVE_TRAIT(user, TRAIT_TIME_STOP_IMMUNE, REF(src))
	owner = null

/obj/item/cube/time_cube/attack_self(mob/user)
	. = ..()
	if(!isliving(user))
		return
	if(!COOLDOWN_FINISHED(src, stop_time_cooldown))
		balloon_alert(user, "not ready!")
		to_chat(user, span_notice("[src] will be ready in [DisplayTimeText(COOLDOWN_TIMELEFT(src, stop_time_cooldown))]"))
		return
	var/time_immune = list()
	time_immune += user
	new /obj/effect/timestop(get_turf(user), radius, stop_duration, time_immune)
	COOLDOWN_START(src, stop_time_cooldown, cooldown_time)

/obj/item/cube/time_cube/examine(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, stop_time_cooldown))
		. += span_notice("[src] will be ready in [DisplayTimeText(COOLDOWN_TIMELEFT(src, stop_time_cooldown))]")

/obj/item/cube/time_cube/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		return NONE
	if(!COOLDOWN_FINISHED(src, stop_time_cooldown))
		return NONE
	if(held_item == src)
		context[SCREENTIP_CONTEXT_LMB] = "TIME CUBE"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE


/// Nitro box (Crash Bandicoot)
/obj/item/grenade/impact/nitro
	name = "nitro cube"
	desc = "A cube prone to explosive results."
	icon = 'icons/obj/cubes.dmi'
	icon_state = "nitro"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
	light_range = 2
	light_power = 3
	light_system = OVERLAY_LIGHT
	light_color = COLOR_LIME
	light_on = FALSE

/obj/item/grenade/impact/nitro/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = LEGENDARY_CUBE, isreference = TRUE, ismapload = mapload)
	add_filter("armed_glow", 11, rays_filter(1, COLOR_LIME, 0))

/obj/item/grenade/impact/nitro/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_LIME))

/obj/item/grenade/impact/nitro/arm_grenade(mob/user, delayoverride, msg, volume)
	. = ..()
	icon_state = initial(icon_state)
	transition_filter_chain(src, "armed_glow", INDEFINITE,\
		FilterChainStep(rays_filter(20, COLOR_LIME, 1), 5 SECONDS, CUBIC_EASING),\
		FilterChainStep(rays_filter(18, COLOR_LIME, 0), 5 SECONDS, CUBIC_EASING))
	set_light_on(TRUE)

/obj/item/grenade/impact/nitro/thrown_impact(atom/source, atom/hit_atom)
	. = ..()
	set_light_on(FALSE)
	remove_filter("armed_glow")


/// Companion Cube (Portal)
/obj/item/cube/companion
	name = "weighted companion cube"
	desc = "Probably the only thing you can trust on this damn station."
	icon_state = "companion"
	rarity = MYTHICAL_CUBE
	reference = TRUE
	overwrite_held_color = COLOR_SILVER
	w_class = WEIGHT_CLASS_BULKY
	/// Who owns us
	var/datum/weakref/owner

/obj/item/cube/companion/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/beauty, 300)
	/// It's weighted
	AddElement(/datum/element/falling_hazard, damage = 25, wound_bonus = 15, hardhat_safety = FALSE, crushes = TRUE)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/cube/companion/Destroy(force)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	handle_dropping()
	return ..()

/// Check if we were picked up by a mob, and keep that user as a weakref until we're removed
/obj/item/cube/companion/proc/on_moved(atom/movable/source, atom/oldloc, direction, forced, list/old_locs)
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

/// Oh cube, how I love you!
/obj/item/cube/companion/proc/handle_equipping(mob/living/holder)
	owner = WEAKREF(holder)
	holder.clear_mood_event("companion_cube_lose")
	holder.add_mood_event("companion_cube_get", /datum/mood_event/companion_cube_get)

/// NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
/obj/item/cube/companion/proc/handle_dropping()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	user.clear_mood_event("companion_cube_get")
	user.add_mood_event("companion_cube_lose", /datum/mood_event/companion_cube_loss)
	owner = null

/datum/mood_event/companion_cube_get
	description = "I love having my weighted companion cube! It's my best friend!"
	mood_change = 20
	category = "companion_cube_get"

/datum/mood_event/companion_cube_loss
	description = "I LOST MY WEIGHTED COMPANION CUBE!!"
	/// You'd be sad too bro
	mood_change = -100000
	/// I genuinely don't know what I was on when I made it but it's here now I guess
	special_screen_obj = "mood_cube"
	timeout = 30 SECONDS
	category = "companion_cube_lose"


// Hip to Be Cube (Huey Lewis and The News)
/obj/item/cube/vinyl
	name = "Honk Lewis and The Crews - It's Hip To Be Cube (Vinyl Single)"
	desc = "You like Honk Lewis and the Crews?"
	icon_state = "vinyl"
	rarity = EPIC_CUBE
	reference = TRUE
	overwrite_held_color = COLOR_SILVER
	/// Who owns us
	var/datum/weakref/owner
	/// Handles finding us some cubes
	/// Finnicky since I believe it only checks if the cubes are the things that move and not you, but whatever it works enough
	var/datum/proximity_monitor/advanced/cube/mood_buff

/obj/item/cube/vinyl/examine(mob/user)
	. = ..()
	/// Adjust the dates in respect to the gameyear
	. += "Their early work was a little too new wave for my taste. But when Spess came out in '[abs((CURRENT_STATION_YEAR-17) % 100)], \
	I think they really came into their own, commercially and artistically. The whole album has a clear, crisp sound, \
	and a new sheen of consummate professionalism that really gives the songs a big boost. He's been compared to J'alvis Cousteau, \
	but I think Honk has a far more bitter, cynical sense of humor. In '[abs((CURRENT_STATION_YEAR-13) % 100)], Honk released this; Slip!, their most accomplished album. \
	I think their undisputed masterpiece is \"Hip To Be Cube\". A song so catchy, most people probably don't listen to the lyrics. \
	But they should, because it's not just about the pleasures of conformity and the importance of trends. It's also a personal statement about the band itself!"

/obj/item/cube/vinyl/Initialize(mapload)
	. = ..()
	mood_buff = new(_host = src, range = 4, _ignore_if_not_on_turf = FALSE)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/cube/vinyl/Destroy(force)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	handle_dropping()
	QDEL_NULL(mood_buff)
	return ..()

/// Check if we were picked up by a mob, and keep that user as a weakref until we're removed
/obj/item/cube/vinyl/proc/on_moved(atom/movable/source, atom/oldloc, direction, forced, list/old_locs)
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

/obj/item/cube/vinyl/proc/handle_equipping(mob/living/holder)
	owner = WEAKREF(holder)

/obj/item/cube/vinyl/proc/handle_dropping()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	owner = null

/datum/proximity_monitor/advanced/cube/field_turf_crossed(atom/movable/crossed, turf/old_location, turf/new_location)
	if (!isobj(crossed)|| !can_see(crossed, host, current_range))
		return
	on_seen(crossed)

/datum/proximity_monitor/advanced/cube/proc/on_seen(obj/seen_obj)
	if(!istype(host, /obj/item/cube/vinyl))
		return
	var/obj/item/cube/vinyl/host_vinyl = host
	var/mob/living/viewer = host_vinyl.owner?.resolve()
	if(!viewer)
		return
	if(!viewer.mind || !viewer.mob_mood || (viewer.stat != CONSCIOUS) || viewer.is_blind())
		return
	var/datum/component/cuboid/is_cube = seen_obj.GetComponent(/datum/component/cuboid)
	if(!is_cube)
		return
	to_chat(viewer, span_notice("Woah, that's a good lookin' cube!"))
	viewer.add_mood_event("nice_cube", /datum/mood_event/vinyl_cube_seen, seen_obj, is_cube.rarity)

/datum/mood_event/vinyl_cube_seen
	description = "That cube <i>does</i> look pretty hip!"
	mood_change = 1
	category = "nice_cube"

/datum/mood_event/vinyl_cube_seen/add_effects(obj/cube, rarity)
	mood_change = rarity
	description = "[cube] <i>does</i> look pretty hip!"
	return ..()


// Dehydrated Cube (Megamind)
/obj/item/food/monkeycube/dehydrated
	name = "dehydrated cube"
	desc = "'olo"
	icon = 'icons/obj/cubes.dmi'
	icon_state = "dehydrated"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "cuboid"
	bite_consumption = 1
	faction = FACTION_NEUTRAL
	food_reagents = list(
		/datum/reagent/ash = 30,
		/datum/reagent/medicine/strange_reagent = 1,
	)
	foodtypes = MEAT | TOXIC
	tastes = list("dust" = 1, "dryness" = 1)

/obj/item/food/monkeycube/dehydrated/Initialize(mapload)
	spawned_mob = create_random_mob()
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = MYTHICAL_CUBE, isreference = TRUE, ismapload = mapload)
	add_overlay(emissive_appearance(icon, "dehydrated_glow", src))

/obj/item/food/monkeycube/dehydrated/examine(mob/user)
	. = ..()
	. += span_tinynotice("The bottom says: <b>Just add water!</b>")

/obj/item/food/monkeycube/dehydrated/color_atom_overlay(mutable_appearance/cubelay)
	return filter_appearance_recursive(cubelay, color_matrix_filter(COLOR_CYAN))

/// Escafil Device (Animorphs)
/obj/item/cube/escafil
	name = "escafil device"
	desc = "An ancient cosmic device capable of bestowing upon the holder the ability to change forms at will."
	icon_state = "escafil"
	rarity = MYTHICAL_CUBE
	reference = TRUE
	overwrite_held_color = COLOR_SAMPLE_PURPLE
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	/// Typepath of a mob we have scanned, we only store one at a time
	var/stored_mob_type
	/// Our current transformation action
	/// If you don't put it in your pocket you are permanently stuck as that creature until death
	/// and that's really funny
	var/datum/action/cooldown/spell/shapeshift/polymorph_belt/transform_action

/obj/item/cube/escafil/Initialize(mapload)
	. = ..()
	var/static/cached_texture_icon
	if(!cached_texture_icon)
		cached_texture_icon = icon('icons/mob/human/textures.dmi', "spacey")

	add_filter("space_filter", 2, layering_filter(icon = cached_texture_icon, blend_mode = BLEND_INSET_OVERLAY))

/obj/item/cube/escafil/Destroy(force)
	QDEL_NULL(transform_action)
	return ..()

/obj/item/cube/escafil/examine(mob/user)
	. = ..()
	if (stored_mob_type)
		var/mob/living/will_become = stored_mob_type
		. += span_notice("It contains digitised [initial(will_become.name)] DNA.")

/obj/item/cube/escafil/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if (.)
		return
	if (!isliving(target_mob))
		return
	if (!isanimal_or_basicmob(target_mob))
		balloon_alert(user, "target too complex!")
		return TRUE
	if (target_mob.mob_biotypes & (MOB_HUMANOID|MOB_ROBOTIC|MOB_SPECIAL|MOB_SPIRIT|MOB_UNDEAD))
		balloon_alert(user, "incompatible!")
		return TRUE
	if (!target_mob.compare_sentience_type(SENTIENCE_ORGANIC))
		balloon_alert(user, "target too intelligent!")
		return TRUE
	if (stored_mob_type == target_mob.type)
		balloon_alert(user, "already scanned!")
		return TRUE
	if (DOING_INTERACTION_WITH_TARGET(user, target_mob))
		balloon_alert(user, "busy!")
		return TRUE
	balloon_alert(user, "scanning...")
	visible_message(span_notice("[user] begins scanning [target_mob] with [src]."))
	if (!do_after(user, delay = 5 SECONDS, target = target_mob))
		return TRUE
	visible_message(span_notice("[user] scans [target_mob] with [src]."))
	stored_mob_type = target_mob.type
	update_transform_action()
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
	return TRUE

/// Make sure we can transform into the scanned target
/obj/item/cube/escafil/proc/update_transform_action()
	if (isnull(stored_mob_type))
		return
	if (isnull(transform_action))
		transform_action = add_item_action(/datum/action/cooldown/spell/shapeshift/polymorph_belt)
	transform_action.update_type(stored_mob_type)


/// Pain Box (Dune)
/obj/item/cube/pain
	name = "nerve inducer box"
	desc = "A box with a hole at the front, the perfect size for a hand."
	icon_state = "pain"
	rarity = MYTHICAL_CUBE
	reference = TRUE
	overwrite_held_color = COLOR_TRAM_LIGHT_BLUE
	/// Time to use for the cooldown
	var/time_for_cooldown = 5 MINUTES

	COOLDOWN_DECLARE(pain_cooldown)

/obj/item/cube/pain/attack_self(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, pain_cooldown))
		balloon_alert(user, "not ready!")
		return
	if(!ishuman(user))
		balloon_alert(user, "only humans can use [src]!")
		return
	balloon_alert(user, "focusing...")
	if(!do_after(user, 2 SECONDS))
		balloon_alert(user, "you lose your nerve and pull away")
		return
	var/mob/living/carbon/human/owner = user
	var/hitzone = owner.held_index_to_dir(owner.active_hand_index) == "r" ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND
	var/obj/item/bodypart/affecting = owner.get_active_hand()
	owner.apply_damage(5, BURN, hitzone)
	owner.cause_wound_of_type_and_severity(WOUND_PIERCE, affecting, WOUND_SEVERITY_TRIVIAL)
	owner.emote("scream")
	owner.reagents.add_reagent(/datum/reagent/determination/painbox, WOUND_DETERMINATION_MAX)
	COOLDOWN_START(src, pain_cooldown, time_for_cooldown)
	icon_state = "pain_cooldown"
	flick("pain_hit", src)
	balloon_alert_to_viewers("snaps shut!")
	addtimer(CALLBACK(src, PROC_REF(cooldown_finished_flick)), time_for_cooldown)
	addtimer(CALLBACK(src, PROC_REF(cracksound)), 8 DECISECONDS)

/// To line up with the flick() we offset this by a few deciseconds
/obj/item/cube/pain/proc/cracksound()
	playsound(src, 'sound/effects/wounds/crack2.ogg', 70, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/// Opens back up visually
/obj/item/cube/pain/proc/cooldown_finished_flick()
	icon_state = "pain"
	flick("pain_open", src)
	balloon_alert_to_viewers("opens up")

/obj/item/cube/pain/examine(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, pain_cooldown))
		. += span_notice("It will open again in [DisplayTimeText(COOLDOWN_TIMELEFT(src, pain_cooldown))]")

/datum/reagent/determination/painbox/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.clear_mood_event("pain_cube")

/datum/reagent/determination/painbox/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	affected_mob.add_mood_event("pain_cube", /datum/mood_event/pain_cube_used)

/datum/mood_event/pain_cube_used
	description = "<b>OH GOD MY HAND!</b>"
	mood_change = -20
	category = "pain_cube"
	/// We should ideally remove this anyway from the chem but just in case something causes that to be skipped, do this
	timeout = 2 MINUTES
