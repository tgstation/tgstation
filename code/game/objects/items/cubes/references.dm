// Cubes that are a reference to something else
/obj/item/cube/reference/reference/examine(mob/user)
	. = ..()
	. += span_tinynotice("Something about this cube feels familiar...")

// Puzzle
/obj/item/cube/reference/reference/puzzle
	name = "\improperLament Configuration"
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
	name = "\improperRubik's Cube"
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

	COOLDOWN_DECLARE(cube_diamond_cooldown)

/obj/item/cube/reference/craft/Initialize(mapload)
	. = ..()
	create_storage(1, WEIGHT_CLASS_HUGE, 64, /obj/item/stack/sheet/mineral/diamond)
	atom_storage.numerical_stacking = TRUE
	START_PROCESSING(SSobj, src)

/obj/item/cube/reference/craft/examine(mob/user)
	. = ..()
	. += span_notice("It will mine a new diamond in [DisplayTimeText(COOLDOWN_TIMELEFT(src, cube_diamond_cooldown))].")

/obj/item/cube/reference/craft/process(seconds_per_tick)
	. = ..()
	do_cube_process(seconds_per_tick)

/// Create a diamond every 15 seconds
/obj/item/cube/reference/craft/proc/do_cube_process(seconds_per_tick)
	if(COOLDOWN_FINISHED(src, cube_diamond_cooldown))
		var/obj/item/stack/sheet/mineral/diamond/inserted = locate(/obj/item/stack/sheet/mineral/diamond) in atom_storage.real_location
		if(!inserted)
			new /obj/item/stack/sheet/mineral/diamond(atom_storage.real_location)
		else
			if(inserted.amount < 64)
				inserted.add(1)

		COOLDOWN_START(src, cube_diamond_cooldown, 15 SECONDS)

/obj/item/cube/reference/generic
	name = "perfectly generic cube"
	desc = "It's entirely non-noteworthy."
	rarity = MYTHICAL_CUBE
