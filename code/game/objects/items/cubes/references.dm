// Cubes that are a reference to something else
/obj/item/cube/reference/examine(mob/user)
	. = ..()
	. += span_tinynicegreen("Something about this cube feels familiar...")

// Puzzle
/obj/item/cube/reference/puzzle
	name = "\improper Lament Configuration"
	desc = "A strange box of metal and wood, you get a strange feeling looking at it."
	icon_state = "lament"
	rarity = EPIC_CUBE
	/// Have we solved the puzzle?
	var/solved = FALSE
	/// The message we say when we solve it
	var/solve_msg = "THE BOX, YOU OPENED IT!"

/obj/item/cube/reference/puzzle/attack_self(mob/user)
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
	balloon_alert(solver, solve_msg)
	solved = TRUE
	icon_state = "[icon_state]_solved"
	update_cube_rarity(rarity+1)

/obj/item/cube/reference/puzzle/examine(mob/user)
	. = ..()
	if(!solved)
		. += span_notice("It is yet to be solved...")
	else
		. += span_nicegreen("It's already been solved!")

/obj/item/cube/reference/puzzle/rubiks
	name = "\improper Rubik's Cube"
	desc = "A famous cube housing a small sliding puzzle."
	icon_state = "rubik"
	rarity = RARE_CUBE
	solve_msg = "Solved!"

// Craft
/obj/item/cube/reference/craft
	name = "grass cube"
	desc = "Despite being made of solid soil, you can dig inside to find the occasional diamond!"
	icon_state = "craft"
	rarity = MYTHICAL_CUBE
	/// How much is a full stack of diamonds?
	var/full_stack = 64
	/// How long does it take for us to mine diamonds? Default: 15 SECONDS
	var/mine_cooldown = 15 SECONDS

	COOLDOWN_DECLARE(cube_diamond_cooldown)

/obj/item/cube/reference/craft/Initialize(mapload)
	. = ..()
	create_storage(2, WEIGHT_CLASS_HUGE, full_stack, /obj/item/stack/sheet/mineral/diamond)
	atom_storage.numerical_stacking = TRUE
	START_PROCESSING(SSobj, src)

/obj/item/cube/reference/craft/examine(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, cube_diamond_cooldown))
		. += span_notice("It will mine a new diamond in [DisplayTimeText(COOLDOWN_TIMELEFT(src, cube_diamond_cooldown))].")

/// Create a diamond after a cooldown
/obj/item/cube/reference/craft/process(seconds_per_tick)
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

/obj/item/cube/reference/generic
	name = "perfectly generic cube"
	desc = "It's entirely non-noteworthy."
	icon_state = "generic_object"
	rarity = MYTHICAL_CUBE
