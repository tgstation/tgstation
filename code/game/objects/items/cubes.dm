//* Randomized cube spawners (not to be confused with random cubes)
/obj/effect/spawner/random/cube_all
	name = "cube spawner (All Rarities)"
	desc = "Roll the small cubes to see if you get the good cubes or the bad cubes."
	icon_state = "loot"
	remove_if_cant_spawn = FALSE //don't remove stuff from the global list, which other can use.
	// see code/_globalvars/lists/objects.dm for loot table

/obj/effect/spawner/random/cube_all/Initialize(mapload)
	loot = GLOB.all_cubes
	return ..()

/obj/effect/spawner/random/cube_all/skew_loot_weights(list/loot_list, exponent)
	///We only need to skew the weights once, since it's a global list used by all maint spawners.
	var/static/already_cubed = FALSE
	if(loot_list == GLOB.all_cubes && already_cubed)
		return
	already_cubed = TRUE
	return ..()

/obj/effect/spawner/random/cube
	name = "cube spawner (Common)"
	desc = "Used to roll for those delicious cubes."
	icon_state = "loot"
	remove_if_cant_spawn = FALSE

	/// The rarity of the cube we're going to get. Just use this as an index instead of manually inputting an Initialize() proc in all the others.
	var/cube_rarity = COMMON_CUBE
	/// The list of the lists of all cubes
	var/static/list/all_cubelists = list(
		GLOB.common_cubes,
		GLOB.uncommon_cubes,
		GLOB.rare_cubes,
		GLOB.epic_cubes,
		GLOB.legendary_cubes,
		GLOB.mythical_cubes,
		)

/obj/effect/spawner/random/cube/Initialize(mapload)
	loot = all_cubelists[cube_rarity]
	return ..()

/obj/effect/spawner/random/cube/uncommon
	name = "cube spawner (Uncommon)"
	cube_rarity = UNCOMMON_CUBE

/obj/effect/spawner/random/cube/rare
	name = "cube spawner (Rare)"
	cube_rarity = RARE_CUBE

/obj/effect/spawner/random/cube/epic
	name = "cube spawner (Epic)"
	cube_rarity = EPIC_CUBE

/obj/effect/spawner/random/cube/legendary
	name = "cube spawner (Legendary)"
	cube_rarity = LEGENDARY_CUBE

/obj/effect/spawner/random/cube/mythical
	name = "cube spawner (Mythical)"
	cube_rarity = MYTHICAL_CUBE

/obj/item/cube
	name = "dev cube"
	desc = "You shouldn't be seeing this cube!"
	icon = 'icons/obj/cubes.dmi'
	icon_state = "cube"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("cubes", "squares", "deducts")
	attack_verb_simple = list("cube", "square", "deduct")

	/// The rarity of this cube
	var/rarity = COMMON_CUBE

/obj/item/cube/Initialize(mapload)
	. = ..()
	force = rarity
	throwforce = rarity
	AddElement(/datum/element/beauty, 25*rarity)
	AddComponent(/datum/component/cuboid, cube_rarity = rarity)

//* Random cubes //

/obj/item/cube/random
	name = "Random Common Cube"
	desc = "A cube that's full of surprises!"
	tool_behavior = null
	/// All possible tool behaviors for the cube
	var/list/cube_tools = list()
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
	/// If we're a laser gun
	var/lasergun = FALSE
	/// If this is true, we wait for someone to pick us up and then register a leash component to them.
	var/ready_leash = FALSE
	/// If we have a bane, the species that we are baneful to
	var/datum/species/bane
	/// If we're going to reverse the holder's movements
	var/reverse_movements = FALSE
	/// Speen
	var/speen = FALSE

	COOLDOWN_DECLARE(cube_laser_cooldown)

/obj/item/cube/random/Initialize(mapload)
	give_random_icon()
	apply_rand_size()
	randcolor()
	create_random_name()
	. = ..()
	give_random_effects()

/obj/item/cube/random/examine(mob/user)
	. = ..()
	if((cube_examine_flags & CUBE_TOOL))
		var/cube_tool_examine = span_notice("It can be used as [tool_behaviour_name(tool_behaviour)]")
		if(length(cube_tools) > 1)
			cube_tool_examine += span_notice("\nIt can be thrown to randomly swap between the following tools:\n")
			for(var/tbehavior in cube_tools)
				cube_tool_examine += "- [tool_behaviour]\n"
		. += boxed_message(cube_tool_examine)
	if((cube_examine_flags & CUBE_IGNITER))
		. += span_warning("It will ignite anything it hits!")
	if((cube_examine_flags & CUBE_EGG))
		. += span_notice("It's going to hatch!")
	if((cube_examine_flags & CUBE_BUTCHER))
		. += span_notice("It can be used to butcher animals!")
	if((cube_examine_flags & CUBE_LASER))
		. += span_warning("It can shoot lasers!")
	if((cube_examine_flags & CUBE_LEASHED))
		. += span_notice("It's currently leashed to someone!")
	if((cube_examine_flags & CUBE_SLIP))
		. += span_notice("It's extra slippery!")
	if((cube_examine_flags & CUBE_FUNNY))
		. += span_clown("It looks pretty funny!")
	if((cube_examine_flags & CUBE_SURGICAL))
		. += span_notice("It can be used to start surgery!")
	if(bane)
		. += span_warning("It deals extra damage to [bane.plural_form]")
	if((cube_examine_flags & CUBE_VAMPIRIC))
		. += span_warning("It heals you when you hit enemies!")


/// Randomize the color for the cube
/obj/item/cube/proc/randcolor()
	add_filter("cubecolor", 1, color_matrix_filter(ready_random_color()))

/// Randomize icons (once I make more generic ones)
/obj/item/cube/random/proc/give_random_icon()
	if(!prob(10*rarity))
		return
	icon_state = pick(
		"small",
	)

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
		// A little something for free that barely anyone will notice
		AddElement(/datum/element/ignites_matches)
	//! Continue random effects
	var/list/possible_cube_effects = list(
	"Edible",
	"Chemical",
	"Circuit",
	"Boomerang",
	"Tool",
	"Laser Gun",
	"Melee",
	"Storage",
	"Weight",
	"Butcher",
	"Bake",
	"Egg",
	"Fishing Spot",
	"GPS",
	"Igniter",
	"Leashed",
	"Religious",
	"Scope",
	"Slip",
	"Funny",
	"Squeak",
	"Surgical",
	"Bane",
	"Haunted",
	"Reverse",
	"Vampire",
	"Speen"
	)
	for(var/i in 1 to rarity)
		var/rand_swap = pick(possible_cube_effects)
		switch(rand_swap)
			if("Edible")
				make_food()
			if("Chemical")
				make_reagents()
			if("Circuit")
				AddComponent(/datum/component/shell, list(
				new /obj/item/circuit_component/cube()
				), SHELL_CAPACITY_SMALL)
			if("Boomerang")
				AddComponent(
					/datum/component/boomerang,
					boomerang_throw_range = rarity,
					examine_message = "When thrown, [src] will return after [rarity] meters!"
					)
			if("Tool")
				make_tool()
			if("Laser Gun")
				cube_examine_flags |= CUBE_LASER
				lasergun = TRUE
			if("Melee")
				cube_examine_flags |= CUBE_WEAPON
				AddElement(/datum/element/kneecapping)
				force = 3 * rarity
				wound_bonus = rarity
				throwforce = 3*rarity
				demolition_mod = 1.05*round(rarity/4)
			if("Storage")
				create_storage(rarity, rarity, (rarity * 7))
			if("Weight")
				w_class = clamp(6-rarity, 1, 5)
				AddElement(/datum/element/falling_hazard, damage = 2*rarity, wound_bonus = 5, hardhat_safety = TRUE, crushes = FALSE, impact_sound = drop_sound)
			if("Butcher")
				AddComponent(/datum/component/butchering, \
				speed = round(10 SECONDS/rarity), \
				effectiveness = 100-round(50/rarity), \
				)
				cube_examine_flags |= CUBE_BUTCHER
			if("Bake")
				AddComponent(
					/datum/component/bakeable,
					random_rarity_list[rarity],
					rand(15 SECONDS, 15 * clamp(round(7-rarity), COMMON_CUBE, MYTHICAL_CUBE)),
					TRUE, TRUE)
			if("Egg")
				AddComponent(\
					/datum/component/fertile_egg,\
					embryo_type = random_rarity_list[rarity],\
					minimum_growth_rate = 1*rarity,\
					maximum_growth_rate = 2*rarity,\
					total_growth_required = round(400/rarity),\
					current_growth = 0,\
				)
				cube_examine_flags |= CUBE_EGG
			if("Fishing Spot")
				AddComponent(/datum/component/fishing_spot, GLOB.preset_fish_sources[/datum/fish_source/cube])
			if("GPS")
				AddComponent(/datum/component/gps, "[src]")
			if("Igniter")
				AddComponent(/datum/component/igniter, rarity)
				cube_examine_flags |= CUBE_IGNITER
			if("Leashed")
				ready_leash = TRUE
			if("Religious")
				AddComponent(/datum/component/religious_tool, RELIGION_TOOL_INVOKE, force_catalyst_afterattack = FALSE, charges = rarity)
			if("Scope")
				AddComponent(/datum/component/scope, range_modifier = rarity)
			if("Slip")
				AddComponent(/datum/component/slippery, knockdown = rarity SECONDS, lube_flags = NO_SLIP_WHEN_WALKING)
				cube_examine_flags |= CUBE_SLIP
			if("Funny")
				AddComponent(/datum/component/wearertargeting/sitcomlaughter, CALLBACK(src, PROC_REF(after_sitcom_laugh)))
				cube_examine_flags |= CUBE_FUNNY
			if("Squeak")
				AddComponent(/datum/component/squeak)
				AddElement(/datum/element/toy_talk)
			if("Surgical")
				AddComponent(/datum/component/surgery_initiator)
				cube_examine_flags |= CUBE_SURGICAL
			if("Bane")
				bane = pick(typecacheof(datum/species, ignore_root_path = TRUE))
				AddElement(/datum/element/bane, target_type = bane, damage_multiplier = round(rarity/10,0.1))
			if("Haunted")
				AddElement(/datum/element/haunted)
			if("Reverse")
				reverse_movements = TRUE
			if("Vampire")
				AddElement(/datum/element/lifesteal, flat_heal = rarity)
				cube_examine_flags |= CUBE_VAMPIRIC
			if("Speen")
				speen = TRUE

		possible_cube_effects -= rand_swap

/// Make the cube a food w/ random consumable reagents
/obj/item/cube/random/proc/make_food()
	/// I'm like 90% sure trying to reference the bitflags as a list was the reason my computer was crashing 4 times so I'm just putting it here instead
	var/static/foodtype_list = list(
		MEAT,
		VEGETABLES,
		RAW,
		JUNKFOOD,
		GRAIN,
		FRUIT,
		DAIRY,
		FRIED,
		ALCOHOL,
		SUGAR,
		GROSS,
		TOXIC,
		PINEAPPLE,
		BREAKFAST,
		CLOTH,
		NUTS,
		SEAFOOD,
		ORANGES,
		BUGS,
		GORE,
		STONE,
	)
	if(!reagents)
		create_reagents(50, INJECTABLE | DRAWABLE | pick(AMOUNT_VISIBLE, TRANSPARENT) | pick(SEALED_CONTAINER, OPENCONTAINER))
	var/list/cube_reagents
	var/cube_foodtypes
	var/list/cube_tastes
	for(var/r in 1 to rarity)
		cube_reagents += list(subtypesof(/datum/reagent/consumable) = rand(2,5*rarity))
		cube_foodtypes |= pick(foodtype_list)
		cube_tastes += list("[pick(GLOB.adjectives)]" = rand(1,rarity))

	AddComponentFrom(
		SOURCE_EDIBLE_INNATE,\
		/datum/component/edible,\
		initial_reagents = cube_reagents,\
		food_flags = pick(NONE, FOOD_FINGER_FOOD),\
		foodtypes = cube_foodtypes,\
		eat_time = round(3 SECONDS/rarity),\
		tastes = cube_tastes,\
	)

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

/// Makes the cube into a random tool
/obj/item/cube/random/proc/make_tool()
	for(var/t in 1 to rarity)
		cube_tools += pick(ALL_TOOLS)
	tool_behavior = pick(cube_tools)
	toolspeed = round(1/rarity, 0.1)
	cube_examine_flags |= CUBE_TOOL

// Throw-activated tool swapping so we don't mess with the other possible effects, also because it's funny
/obj/item/cube/random/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, gentle, quickstart = TRUE)
	. = ..()
	if(!.)
		return
	if(isnull(tool_behavior) || length(cube_tools) < 2)
		return
	tool_behavior = pick(cube_tools)
	balloon_alert(thrower, "[tool_behavior]")

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


/obj/item/cube/random/pickup(mob/user)
	. = ..()
	// If we have the leash effect but haven't been leashed yet, then leash to the first person that picks us up
	if(ready_leash)
		AddComponent(/datum/component/leash, user, 6, /obj/effect/decal/cleanable/confetti)
		cube_examine_flags |= CUBE_LEASHED
		ready_leash = FALSE
	// Self-explanitory
	if(reverse_movements)
		user.AddElement(/datum/element/inverted_movement)
	// Way funnier than you'll imagine
	if(speen)
		user.AddElement(/datum/element/wheel)

/// Used for the funny effect
/obj/item/cube/random/proc/after_sitcom_laugh(mob/victim)
	victim.visible_message("[src] lets out a burst of laughter!")

// It's at least not permanent
/obj/item/cube/random/dropped(mob/user, silent = FALSE)
	. = ..()
	user.RemoveElement(/datum/element/inverted_movement)
	user.RemoveElement(/datum/element/wheel)


//* Circuit shell for random cubes
// All about throwing the cube, because I think it's funny as hell
/obj/item/circuit_component/cube
	display_name = "Cube"
	desc = "Circuit for the extraneous functions of a Cubic object"
	///The cube in reference
	var/obj/item/cube/random/mycube

	///Who is holding the cube
	var/datum/port/output/holder
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

	RegisterSignal(mycube, COMSIG_MOVABLE_POST_THROW, PROC_REF(cubethrown))
	RegisterSignal(mycube, COMSIG_MOVABLE_IMPACT, PROC_REF(hit_target))
	RegisterSignal(mycube, COMSIG_ITEM_EQUIPPED, PROC_REF(cube_held))

/obj/item/circuit_component/cube/unregister_shell(atom/movable/shell)
	if(mycube)
		UnregisterSignal(mycube, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_EQUIPPED))
		mycube = null
	return ..()

/obj/item/circuit_component/cube/populate_ports()
	holder = add_output_port("Holder", PORT_TYPE_ATOM)
	thrown = add_output_port("Thrown", PORT_TYPE_SIGNAL)
	victim = add_output_port("Throw Victim", PORT_TYPE_ATOM)
	victim_hit = add_output_port("Victim Hit", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/cube/proc/cubethrown(atom/source)
	SIGNAL_HANDLER
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
