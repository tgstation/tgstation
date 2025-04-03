//* Random cubes //
/obj/item/cube/random
	name = "random Common Cube"
	desc = "A cube that's full of surprises!"
	tool_behaviour = null
	light_system = OVERLAY_LIGHT
	light_on = FALSE

	/// Used for cubes that create more cubes
	var/static/list/random_rarity_list = list(
		/obj/effect/spawner/random/cube,
		/obj/effect/spawner/random/cube/uncommon,
		/obj/effect/spawner/random/cube/rare,
		/obj/effect/spawner/random/cube/epic,
		/obj/effect/spawner/random/cube/legendary,
		/obj/effect/spawner/random/cube/mythical
	)
	/// Flags for anything that doesn't inherently have an examine string
	var/cube_examine_flags = NONE
	cube_color = COLOR_WHITE
	/// The person that picked us up, if anything requires it.
	var/datum/weakref/owner

	/// All possible tool behaviors for the cube
	var/list/cube_tools
	/// If we're a laser gun
	var/lasergun = FALSE
	/// If this is true, we wait for someone to pick us up and then register a leash component to them.
	var/ready_leash = FALSE
	/// If we're going to reverse the holder's movements
	var/reverse_movements = FALSE
	/// Speen
	var/speen = FALSE

	/// Initiate silly gravity if we're not null
	var/funnygrav
	/// How many steps the user has taken since picking up cube w/ negative grav
	var/step_count = 0
	/// If you walk outside on a planetary turf, you fly up. To the sky. And Explode.
	var/you_fucked_up = FALSE


	COOLDOWN_DECLARE(cube_laser_cooldown)

/obj/item/cube/random/Initialize(mapload)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	give_random_icon()
	apply_rand_size()
	randcolor()
	create_random_name()
	. = ..()
	give_random_effects()

/obj/item/cube/fetch_cube_list()
	var/list/possible_random_cube_visuals = list(
		"cube" = 500,
		"isometric" = 250,
		"small" = 15*rarity,
		"massive" = 10*rarity,
		"plane" = 6*rarity,
		"voxel" = 5+rarity,
		"sphere" = 1+rarity,
		"pixel" = 1
	)
	return possible_random_cube_visuals

/obj/item/cube/random/Destroy(force)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	QDEL_NULL(light)
	handle_dropping()
	return ..()

/obj/item/cube/random/examine(mob/user)
	. = ..()
	if((cube_examine_flags & CUBE_TOOL))
		var/cube_tool_examine = span_notice("It can be used as [EXAMINE_HINT("[tool_behaviour_name(tool_behaviour)]")]")
		if(length(cube_tools) > 1)
			cube_tool_examine += span_notice("\nIt can be thrown to randomly swap between the following tools:\n")
			for(var/tbehavior in cube_tools)
				cube_tool_examine += "- [tbehavior]\n"
		. += boxed_message(cube_tool_examine)
	if((cube_examine_flags & CUBE_EGG))
		. += span_notice("It's going to hatch!")
	if((cube_examine_flags & CUBE_BUTCHER))
		. += span_notice("It can be used to butcher animals!")
	if((cube_examine_flags & CUBE_LASER))
		. += span_warning("It can shoot lasers!")
	if((cube_examine_flags & CUBE_LEASHED))
		. += span_notice("It's currently leashed to someone!")
	if((cube_examine_flags & CUBE_FUNNY))
		. += span_sans("It looks pretty funny!")
	if((cube_examine_flags & CUBE_SURGICAL))
		. += span_notice("It can be used to start surgery!")
	if((cube_examine_flags & CUBE_VAMPIRIC))
		. += span_warning("It heals you when you hit enemies!")
	if((cube_examine_flags & CUBE_GPS))
		. += span_notice("It's outputting its location!")
	if((cube_examine_flags & CUBE_CIRCUIT))
		. += span_notice("It has a slot for circuits!")
	if((cube_examine_flags & CUBE_STORAGE))
		. += span_notice("It can store items!")
	if((cube_examine_flags & CUBE_WEAPON))
		. += span_warning("It's much more powerful!")
	if((cube_examine_flags & CUBE_FISH))
		. += span_notice("It's rippling like deep water. It looks like something's moving inside...")
	if((cube_examine_flags & CUBE_FAITH))
		. += span_notice("It's emitting a holy light!")
	if(ready_leash)
		. += span_notice("It will leash to the next person who picks it up.")

/// Randomize size
/obj/item/cube/random/proc/apply_rand_size()
	if(!prob(10*rarity))
		return
	var/randscale = rand(0.5, 2.0)
	transform.Scale(randscale,randscale)

/// Create a random name for the cube with a complexity based off its rarity
/obj/item/cube/random/proc/create_random_name()
	var/adjective_string = ""
	if(rarity > 2)
		for(var/i in 1 to (rarity-2))
			adjective_string += " [pick(GLOB.adjectives)]"

	switch(rarity)
		if(1)
			name = "[pick(GLOB.adjectives)] Cube"
		if(2)
			switch(rand(1,2))
				if(1)
					name = "[pick(GLOB.adjectives)] Cube of the [pick(GLOB.station_suffixes)]"
				if(2)
					name = "[pick(GLOB.adjectives)] Cube of [pick(GLOB.ing_verbs)]"
		else
			switch(rand(1,2))
				if(1)
					name = "[pick(GLOB.adjectives)] Cube of the[adjective_string] [pick(GLOB.station_suffixes)]"
				if(2)
					name = "[pick(GLOB.adjectives)] Cube of[adjective_string] [pick(GLOB.ing_verbs)]"

/// Random cube effects
/obj/item/cube/random/proc/give_random_effects()
	if(prob(10*rarity))
		// I'll be surprised if anyone even tests for this, but I still think it's funny
		AddElement(/datum/element/ignites_matches)
	/// All the possible effects random cubes can have. Gets pick()-ed once per rarity level, removing previous picks to not have repeats
	var/list/possible_cube_effects = list(
		PROC_REF(make_food),
		PROC_REF(make_reagents),
		PROC_REF(make_circuit),
		PROC_REF(make_boomerang),
		PROC_REF(make_tool),
		PROC_REF(make_laser),
		PROC_REF(make_melee),
		PROC_REF(make_storage),
		PROC_REF(make_weight),
		PROC_REF(make_butcher),
		PROC_REF(make_bake),
		PROC_REF(make_egg),
		PROC_REF(make_fishing),
		PROC_REF(make_gps),
		PROC_REF(make_fantasy),
		PROC_REF(make_leashed),
		PROC_REF(make_holy),
		PROC_REF(make_scope),
		PROC_REF(make_funny),
		PROC_REF(make_toy),
		PROC_REF(make_surgical),
		PROC_REF(make_reverse),
		PROC_REF(make_vampire),
		PROC_REF(make_speen),
		PROC_REF(make_material),
		PROC_REF(make_lamp),
		PROC_REF(make_gravity),
	)

	for(var/i in 1 to rarity)
		var/rand_swap = pick(possible_cube_effects)
		call(src, rand_swap)()
		possible_cube_effects -= rand_swap

/// Make the cube a food w/ random consumable reagents
/obj/item/cube/random/proc/make_food()
	if(!reagents)
		create_reagents(50, INJECTABLE | DRAWABLE | pick(AMOUNT_VISIBLE, TRANSPARENT) | pick(SEALED_CONTAINER, OPENCONTAINER))
	var/list/cube_reagents = list()
	var/cube_foodtypes
	var/list/cube_tastes = list()
	for(var/r in 1 to rarity)
		cube_reagents[get_random_consumable_reagent_id()] += rand(2,5*rarity)
		cube_foodtypes |= get_random_bitflag("foodtypes")
		cube_tastes[pick(GLOB.adjectives)] += rand(1,rarity)

	AddComponentFrom(
		SOURCE_EDIBLE_INNATE,\
		/datum/component/edible,\
		initial_reagents = cube_reagents,\
		food_flags = pick(NONE, FOOD_FINGER_FOOD),\
		foodtypes = cube_foodtypes,\
		eat_time = round(3 SECONDS/rarity),\
		tastes = cube_tastes)

/// Makes the cube a reagent holder w/ random reagents
/obj/item/cube/random/proc/make_reagents()
	if(!reagents)
		create_reagents(50, INJECTABLE | DRAWABLE | pick(AMOUNT_VISIBLE, TRANSPARENT) | pick(SEALED_CONTAINER, OPENCONTAINER))
	if(prob(15*rarity))
		reagents.flags |= pick(NO_REACT, REAGENT_HOLDER_INSTANT_REACT)
	reagents.maximum_volume = rand(50, 50*rarity)
	for(var/c in 1 to rarity)
		reagents.add_reagent(get_random_reagent_id(), rand(5,10*rarity))
	/// Try to make it less likely to explode you by normalizing the temp
	var/temp_raw = rand(0, rarity*150)
	reagents.set_temperature(round((temp_raw/(rarity*150))**2*(rarity*150)))

/// Makes it a circuit shell
/obj/item/cube/random/proc/make_circuit()
	AddComponent(/datum/component/shell, list(
	new /obj/item/circuit_component/cube()
	), SHELL_CAPACITY_SMALL)
	cube_examine_flags |= CUBE_CIRCUIT

/// Makes it a boomerang. For some reason a lot of these component procs won't work if I break it into lines like lists, so they're a bit wide
/obj/item/cube/random/proc/make_boomerang()
	AddComponent(/datum/component/boomerang, boomerang_throw_range = max(throw_range + (rarity-6),1), examine_message = "When thrown, [src] will return after [max(throw_range + (rarity-6),1)] meters!")

/// Makes it shoot lasers
/obj/item/cube/random/proc/make_laser()
	cube_examine_flags |= CUBE_LASER
	lasergun = TRUE

/// Increases melee damage
/obj/item/cube/random/proc/make_melee()
	cube_examine_flags |= CUBE_WEAPON
	force = max(3 * rarity, WOUND_MINIMUM_DAMAGE)
	wound_bonus = rarity
	throwforce = 3*rarity
	demolition_mod = 1.05*round(rarity/4)
	AddElement(/datum/element/kneecapping)

/// Makes it a storage object
/obj/item/cube/random/proc/make_storage()
	create_storage(rarity, rarity, (rarity * 7))
	cube_examine_flags |= CUBE_STORAGE

/// Edits the weight of the cube based off the rarity, and forces it to be dense
/obj/item/cube/random/proc/make_weight()
	w_class = clamp(7-rarity, 1, 5)
	AddElement(/datum/element/falling_hazard, damage = 2 * rarity, wound_bonus = 5, hardhat_safety = TRUE, crushes = FALSE, impact_sound = drop_sound)

/// Lets you butcher mobs wtih it
/obj/item/cube/random/proc/make_butcher()
	AddComponent(/datum/component/butchering, speed = round(10 SECONDS/rarity), effectiveness = 100-round(50/rarity))
	cube_examine_flags |= CUBE_BUTCHER

/// You can bake it to reroll it
/obj/item/cube/random/proc/make_bake()
	AddComponent( /datum/component/bakeable, random_rarity_list[rarity], rand(15 SECONDS, 15 * clamp(round(7-rarity), COMMON_CUBE, MYTHICAL_CUBE)), TRUE, TRUE)

/// It will hatch and reroll in a certain amount of time.
/obj/item/cube/random/proc/make_egg()
	AddComponent( /datum/component/fertile_egg, embryo_type = random_rarity_list[rarity], minimum_growth_rate = 1*rarity, maximum_growth_rate = 2*rarity, total_growth_required = round(5000/rarity), current_growth = 0)
	cube_examine_flags |= CUBE_EGG

/// You can fish in the cube to get more cubes of a lower rarity
/obj/item/cube/random/proc/make_fishing()
	AddComponent(/datum/component/fishing_spot, GLOB.preset_fish_sources[/datum/fish_source/cube])
	cube_examine_flags |= CUBE_FISH

/// The cube now outputs its location. Honestly can be pretty bad if you don't want to give up your good cube, but that's funny so whatever
/obj/item/cube/random/proc/make_gps()
	AddComponent(/datum/component/gps, "[src]")
	cube_examine_flags |= CUBE_GPS

/// This one probably accounts for half of the item effects
/obj/item/cube/random/proc/make_fantasy()
	var/fantasy_quality = rand(rarity, 15)
	if(prob(50-(rarity*5)))
		fantasy_quality = -fantasy_quality
	AddComponent(/datum/component/fantasy, fantasy_quality)

/// Preps us so the next mob to pick us up becomes leashed
/obj/item/cube/random/proc/make_leashed()
	if(cube_examine_flags & CUBE_LEASHED)
		return
	ready_leash = TRUE

/// You can edit religions using the cube
/obj/item/cube/random/proc/make_holy()
	AddComponent(/datum/component/religious_tool, RELIGION_TOOL_INVOKE, force_catalyst_afterattack = FALSE, charges = rarity)
	cube_examine_flags |= CUBE_FAITH

/// Makes it work as a scope
/obj/item/cube/random/proc/make_scope()
	var/rangemod = 2+round((-3+rarity)/5,0.1)
	AddComponent(/datum/component/scope, range_modifier = rangemod)

/// Slips whoever walks on it, and if they're holding it while they fall from something it laughs.
/obj/item/cube/random/proc/make_funny()
	AddComponent(/datum/component/wearertargeting/sitcomlaughter, CALLBACK(src, PROC_REF(after_sitcom_laugh)))
	cube_examine_flags |= CUBE_FUNNY
	AddComponent(/datum/component/slippery, knockdown = rarity SECONDS, lube_flags = NO_SLIP_WHEN_WALKING)

/// Make it squeaky & let you talk out of it like a puppet
/obj/item/cube/random/proc/make_toy()
	AddComponent(/datum/component/squeak)
	AddElement(/datum/element/toy_talk)

/// Let you start surgeries with it like drapes
/obj/item/cube/random/proc/make_surgical()
	AddComponent(/datum/component/surgery_initiator)
	cube_examine_flags |= CUBE_SURGICAL

/// Makes picking it up reverse your control scheme
/obj/item/cube/random/proc/make_reverse()
	reverse_movements = TRUE

/// Makes hitting people with it steal life from them
/obj/item/cube/random/proc/make_vampire()
	AddElement(/datum/element/lifesteal, flat_heal = rarity)
	cube_examine_flags |= CUBE_VAMPIRIC

/// Makes you spin.
/obj/item/cube/random/proc/make_speen()
	speen = TRUE

/// Makes it output light
/obj/item/cube/random/proc/make_lamp()
	set_light_range_power_color(
		max(round(rarity/2, 0.1), 1.4),
		(1 + round(rarity/5, 0.1)),
		BlendRGB(cube_color, COLOR_VERY_LIGHT_GRAY, 0.3))
	light_on = TRUE

/// Makes it either negate your gravity or RARELY flip you upside down.
/obj/item/cube/random/proc/make_gravity()
	if(prob(round(5*rarity/200,0.1)))
		funnygrav = NEGATIVE_GRAVITY
	else
		funnygrav = ZERO_GRAVITY

/// Makes the cube into a random tool
/obj/item/cube/random/proc/make_tool()
	cube_tools = list()
	var/list/possible_tools = list() + GLOB.all_tool_behaviours
	for(var/t in 1 to rarity)
		var/new_tool = pick(possible_tools)
		cube_tools += new_tool
		possible_tools -= new_tool

	tool_behaviour = pick(cube_tools)
	toolspeed = round(1/rarity, 0.1)
	cube_examine_flags |= CUBE_TOOL
	/// All possible sounds that the cubes can have if they are tools
	var/list/cube_toolsounds = list(
		'sound/items/tools/jaws_pry.ogg'= 50,
		'sound/items/weapons/sonic_jackhammer.ogg'= 25,
		'sound/items/tools/crowbar.ogg'= 50,
		'sound/items/tools/screwdriver.ogg'= 50,
		'sound/items/tools/screwdriver2.ogg'= 50,
		'sound/items/pshoom/pshoom.ogg'= 25,
		'sound/items/tools/drill_use.ogg'= 50,
		'sound/items/tools/welder.ogg'= 50,
		'sound/items/tools/welder2.ogg'= 50,
		'sound/items/tools/wirecutter.ogg'= 50,
		'sound/items/tools/ratchet.ogg'= 50,
		'sound/effects/empulse.ogg'= 25,
		'sound/items/toy_squeak/toysqueak1.ogg'=rarity,
		'sound/items/toy_squeak/toysqueak2.ogg'=rarity,
		'sound/items/toy_squeak/toysqueak3.ogg'=rarity
	)
	usesound = list()
	for(var/newsound in 1 to rarity)
		var/newcubesound = pick_weight(cube_toolsounds)
		usesound += newcubesound
		cube_toolsounds -= newcubesound

/obj/item/cube/random/get_all_tool_behaviours()
	if(isnull(tool_behaviour))
		return null
	return cube_tools

// Throw-activated tool swapping so we don't mess with the other possible effects, also because it's funny
/obj/item/cube/random/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, gentle, quickstart = TRUE)
	. = ..()
	if(!.)
		return
	if(isnull(tool_behaviour) || length(cube_tools) < 2)
		return
	tool_behaviour = pick(cube_tools)
	balloon_alert(thrower, "[tool_behaviour]")

/// Add custom materials
/obj/item/cube/random/proc/make_material()
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS | MATERIAL_EFFECTS
	switch(pick("All for one","One for all"))
		if("All for one")
			var/datum/material/cube_mat = pick(GLOB.typecache_material)
			var/list/mymat = list()
			if(cube_mat.type == /datum/material/alloy)
				cube_mat = /datum/material/wood
			mymat[cube_mat] = SHEET_MATERIAL_AMOUNT * rarity
			set_custom_materials(mymat)
		if("One for all")
			var/list/mymat = list()
			for(var/m in 1 to rarity)
				var/datum/material/cube_mat = pick(GLOB.typecache_material)
				if(cube_mat.type == /datum/material/alloy)
					cube_mat = /datum/material/wood
				mymat[cube_mat] += SHEET_MATERIAL_AMOUNT
			set_custom_materials(mymat)

// If we're a lasergun, then we can fire lasers!
/obj/item/cube/random/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!lasergun)
		return NONE
	if(!COOLDOWN_FINISHED(src, cube_laser_cooldown))
		playsound(src, 'sound/items/weapons/gun/general/dry_fire.ogg', 30, TRUE)
		to_chat(user, "It will be ready to fire in [DisplayTimeText(COOLDOWN_TIMELEFT(src, cube_laser_cooldown))].")
		return ITEM_INTERACT_FAILURE
	fire_projectile(/obj/projectile/beam/laser/carbine, interacting_with, 'sound/items/weapons/laser2.ogg', user)
	COOLDOWN_START(src, cube_laser_cooldown, (10-rarity) SECONDS) // Not very fast to make up for the fact it uses no ammo
	return ITEM_INTERACT_SUCCESS

/// Used for the "Funny" effect
/obj/item/cube/random/proc/after_sitcom_laugh(mob/victim)
	victim.visible_message("[src] lets out a burst of laughter!")

/// Check if we were picked up by a mob, and keep that user as a weakref until we're removed
/obj/item/cube/random/proc/on_moved(atom/movable/source, atom/oldloc, direction, forced, list/old_locs)
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

/obj/item/cube/random/proc/handle_equipping(mob/living/user)
	owner = WEAKREF(user)
	// If we have the leash effect but haven't been leashed yet, then leash to the first person that picks us up
	if(ready_leash)
		AddComponent(/datum/component/leash, user, rarity+1, /obj/effect/decal/cleanable/confetti)
		cube_examine_flags |= CUBE_LEASHED
		ready_leash = FALSE
	// Self-explanitory
	if(reverse_movements)
		user.AddElement(/datum/element/inverted_movement)
	// Way funnier than you'll imagine
	if(speen)
		user.AddElement(/datum/element/wheel)
	if(!isnull(funnygrav))
		if(funnygrav < ZERO_GRAVITY)
			handle_neggrav_add(user)
		// User gets hit heavy if negative but the cube is built different
		AddElement(/datum/element/forced_gravity, funnygrav)
		passtable_on(src, TRAIT_FORCED_GRAVITY)
		user.AddElement(/datum/element/forced_gravity, funnygrav)

// It's at least not permanent
/obj/item/cube/random/proc/handle_dropping()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	user.RemoveElement(/datum/element/inverted_movement)
	user.RemoveElement(/datum/element/wheel)
	user.RemoveElement(/datum/element/forced_gravity, funnygrav)
	if(funnygrav < ZERO_GRAVITY)
		handle_neggrav_remove()
	owner = null

///Ripped from the atrocinator
/obj/item/cube/random/proc/handle_neggrav_add(mob/user)
	playsound(src, 'sound/effects/curse/curseattack.ogg', 50)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_upstairs))
	RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(on_talk))
	ADD_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))
	passtable_on(user, REF(src))
	check_upstairs()

/// Upside down
/obj/item/cube/random/proc/on_talk(datum/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= "upside_down"

/// Again ripped from atrocinator, but edited to account for lack of modsuit
/obj/item/cube/random/proc/check_upstairs(atom/movable/source, atom/oldloc, direction, forced, list/old_locs, momentum_change)
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
/obj/item/cube/random/proc/fly_away()
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
#define FALL_TIME 5 DECISECONDS

/// We're pretty high up huh
/obj/item/cube/random/proc/initiate_fall()
	funnygrav = null
	RemoveElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
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
/obj/item/cube/random/proc/destroy_legs()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	user.RemoveElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
	handle_neggrav_remove()
	REMOVE_TRAIT(src, TRAIT_NODROP, NEGATIVE_GRAVITY_TRAIT)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/effects/gravhit.ogg', 75)
	investigate_log("was sent plummeting to [user.p_their()] death by [src].", INVESTIGATE_DEATHS)
	user.gib(DROP_ALL_REMAINS)

/obj/item/cube/random/proc/handle_neggrav_remove()
	var/mob/living/user = owner?.resolve()
	if(!user)
		return
	UnregisterSignal(user, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOB_SAY
	))
	step_count = 0
	REMOVE_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))
	passtable_off(user, REF(src))
	var/turf/open/openspace/current_turf = get_turf(user)
	if(istype(current_turf))
		current_turf.zFall(user, falling_from_move = TRUE)


//* Circuit shell for random cubes
// All about throwing the cube, because I think it's funny as hell
/obj/item/circuit_component/cube
	display_name = "Cube"
	desc = "Circuit for the extraneous functions of a Cubic object"
	///The cube in reference
	var/obj/item/cube/random/mycube


	///Who is holding the cube
	var/datum/port/output/holder
	///Who is throwing the cube
	var/datum/port/output/thrower
	///Toggled when we throw the cube
	var/datum/port/output/thrown
	///Who did we throw the cube against
	var/datum/port/output/victim
	///Toggled when we hit them with the cube
	var/datum/port/output/victim_hit

/obj/item/circuit_component/cube/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/cube))
		mycube = shell

	if(isnull(mycube))
		return

	RegisterSignal(mycube, COMSIG_MOVABLE_PRE_THROW, PROC_REF(cubethrown))
	RegisterSignal(mycube, COMSIG_MOVABLE_IMPACT, PROC_REF(hit_target))
	RegisterSignal(mycube, COMSIG_ITEM_PICKUP, PROC_REF(cube_held))

/obj/item/circuit_component/cube/unregister_shell(atom/movable/shell)
	if(mycube)
		UnregisterSignal(mycube, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_EQUIPPED))
		mycube = null
	return ..()

/obj/item/circuit_component/cube/populate_ports()
	holder = add_output_port("Holder", PORT_TYPE_ATOM)
	thrower = add_output_port("Thrower", PORT_TYPE_ATOM)
	thrown = add_output_port("Thrown", PORT_TYPE_SIGNAL)
	victim = add_output_port("Throw Victim", PORT_TYPE_ATOM)
	victim_hit = add_output_port("Victim Hit", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/cube/proc/cubethrown(atom/source, list/throw_args)
	SIGNAL_HANDLER
	var/mob/thrown_by = throw_args[4]
	if(istype(thrown_by))
		thrower.set_output(thrown_by)
	thrown.set_output(COMPONENT_SIGNAL)


/obj/item/circuit_component/cube/proc/hit_target(atom/source, atom/hit_atom)
	SIGNAL_HANDLER
	victim.set_output(hit_atom)
	victim_hit.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/cube/proc/cube_held(atom/source, mob/user)
	SIGNAL_HANDLER
	holder.set_output(user)

//* Random cube rarities
/obj/item/cube/random/uncommon
	name = "Random Uncommon Cube"
	rarity = UNCOMMON_CUBE

/obj/item/cube/random/rare
	name = "Random Rare Cube"
	rarity = RARE_CUBE

/obj/item/cube/random/epic
	name = "Random Epic Cube"
	rarity = EPIC_CUBE

/obj/item/cube/random/legendary
	name = "Random Legendary Cube"
	rarity = LEGENDARY_CUBE

/obj/item/cube/random/mythical
	name = "Random Mythical Cube"
	rarity = MYTHICAL_CUBE
