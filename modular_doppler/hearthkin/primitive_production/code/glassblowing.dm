#define DEFAULT_TIMED (4 SECONDS)
#define STEP_BLOW "blow"
#define STEP_SPIN "spin"
#define STEP_PADDLE "paddle"
#define STEP_SHEAR "shear"
#define STEP_JACKS "jacks"

/obj/item/glassblowing
	icon = 'modular_doppler/hearthkin/primitive_production/icons/prim_fun.dmi'

/obj/item/glassblowing/glass_globe
	name = "glass globe"
	desc = "A glass bowl that is capable of carrying things."
	icon_state = "glass_globe"
	material_flags = MATERIAL_COLOR
	custom_materials = list(
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)

/datum/export/glassblowing
	cost = CARGO_CRATE_VALUE * 5
	unit_name = "glassblowing product"
	export_types = list(
		/obj/item/glassblowing/glass_lens,
		/obj/item/glassblowing/glass_globe,
		/obj/item/reagent_containers/cup/bowl/blowing_glass,
		/obj/item/reagent_containers/cup/beaker/large/blowing_glass,
		/obj/item/plate/blowing_glass
	)

/datum/export/glassblowing/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	return ..()

/obj/item/glassblowing/glass_lens
	name = "glass lens"
	desc = "A convex glass lens that would make an excellent magnifying glass if it were attached to a handle."
	icon_state = "glass_lens"

/obj/item/reagent_containers/cup/bowl/blowing_glass
	name = "glass bowl"
	desc = "A glass bowl that is capable of carrying things."
	icon = 'modular_doppler/hearthkin/primitive_production/icons/prim_fun.dmi'
	icon_state = "glass_bowl"
	custom_materials = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT)
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR

/obj/item/reagent_containers/cup/beaker/large/blowing_glass
	name = "glass cup"
	desc = "A glass cup that is capable of carrying liquids."
	icon = 'modular_doppler/hearthkin/primitive_production/icons/prim_fun.dmi'
	icon_state = "glass_cup"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR

/obj/item/plate/blowing_glass
	name = "glass plate"
	desc = "A glass plate that is capable of carrying things."
	icon = 'modular_doppler/hearthkin/primitive_production/icons/prim_fun.dmi'
	icon_state = "glass_plate"
	custom_materials = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT)
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR

/obj/item/glassblowing/molten_glass
	name = "molten glass"
	desc = "A glob of molten glass, ready to be shaped into art."
	icon_state = "molten_glass"
	///the cooldown if it's still molten / requires heating up
	COOLDOWN_DECLARE(remaining_heat)
	///the typepath of the item that will be produced when the required actions are met
	var/chosen_item
	///the list of steps remaining
	var/list/steps_remaining
	///the amount of time this glass will stay heated, updated each time it gets put in the forge based on the user's skill
	var/total_time
	///whether this glass's chosen item has completed all its steps. So we don't have to keep checking this a million times once it's done.
	var/is_finished = FALSE

/obj/item/glassblowing/molten_glass/examine(mob/user)
	. = ..()
	var/message = get_examine_message(src)
	if(message)
		. += message

/obj/item/glassblowing/molten_glass/pickup(mob/living/user)
	if(!istype(user))
		return ..()

	. = ..()

	try_burn_user(user)

/**
 * Tries to burn the user if the glass is still molten hot.
 *
 * Arguments:
 * * mob/living/user - user to burn
 */
/obj/item/glassblowing/molten_glass/proc/try_burn_user(mob/living/user)
	if(!COOLDOWN_FINISHED(src, remaining_heat))
		to_chat(user, span_warning("You burn your hands trying to pick up [src]!"))
		user.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
		user.dropItemToGround(src)
		var/obj/item/bodypart/affecting = user.get_active_hand()
		user.investigate_log("was burned their hand on [src] for [15] at [AREACOORD(user)]", INVESTIGATE_CRAFTING)
		return affecting?.receive_damage(0, 15, wound_bonus = CANT_WOUND)

/obj/item/glassblowing/blowing_rod
	name = "blowing rod"
	desc = "A tool that is used to hold the molten glass as well as help shape it."
	icon_state = "blow_pipe_empty"
	tool_behaviour = TOOL_BLOWROD
	/// Whether the rod is in use currently; will try to prevent many other actions on it
	var/in_use = FALSE
	/// A ref to the glass item being blown
	var/datum/weakref/glass_ref

/obj/item/glassblowing/blowing_rod/examine(mob/user)
	. = ..()
	var/obj/item/glassblowing/molten_glass/glass = glass_ref.resolve()
	if(!glass)
		return
	var/message = get_examine_message(glass)
	if(message)
		. += message


/**
 * Create the examine message and return it.
 *
 * This will include all the remaining steps and whether the glass has cooled down or not.
 *
 * Arguments:
 * * obj/item/glassblowing/molten_glass/glass - the glass object being examined
 *
 * Returns the examine message.
 */
/obj/item/glassblowing/proc/get_examine_message(obj/item/glassblowing/molten_glass/glass)
	if(COOLDOWN_FINISHED(glass, remaining_heat))
		. += span_warning("The glass has cooled down and will require reheating to modify! ")
	if(!length(glass.steps_remaining))
		return
	if(glass.steps_remaining[STEP_BLOW])
		. += "The glass requires [glass.steps_remaining[STEP_BLOW]] more blowing actions! "
	if(glass.steps_remaining[STEP_SPIN])
		. += "The glass requires [glass.steps_remaining[STEP_SPIN]] more spinning actions! "
	if(glass.steps_remaining[STEP_PADDLE])
		. += "The glass requires [glass.steps_remaining[STEP_PADDLE]] more paddling actions! "
	if(glass.steps_remaining[STEP_SHEAR])
		. += "The glass requires [glass.steps_remaining[STEP_SHEAR]] more shearing actions! "
	if(glass.steps_remaining[STEP_JACKS])
		. += "The glass requires [glass.steps_remaining[STEP_JACKS]] more jacking actions!"

/obj/item/glassblowing/blowing_rod/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/obj/item/glassblowing/molten_glass/attacking_glass = interacting_with
	if(!istype(attacking_glass))
		return NONE

	if(glass_ref?.resolve())
		to_chat(user, span_warning("[src] already has some glass on it!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(attacking_glass, src))
		return ITEM_INTERACT_BLOCKING
	glass_ref = WEAKREF(attacking_glass)
	to_chat(user, span_notice("[src] picks up [attacking_glass]."))
	icon_state = "blow_pipe_full"
	return ITEM_INTERACT_SUCCESS

/obj/item/glassblowing/blowing_rod/attackby(obj/item/attacking_item, mob/living/user, params)
	var/actioning_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * DEFAULT_TIMED
	var/obj/item/glassblowing/molten_glass/glass = glass_ref?.resolve()

	if(istype(attacking_item, /obj/item/glassblowing/molten_glass))
		if(glass)
			to_chat(user, span_warning("[src] already has some glass on it still!"))
			return
		if(!user.transferItemToLoc(attacking_item, src))
			return
		glass_ref = WEAKREF(attacking_item)
		to_chat(user, span_notice("[src] picks up [attacking_item]."))
		icon_state = "blow_pipe_full"
		return

	if(istype(attacking_item, /obj/item/glassblowing/paddle))
		do_glass_step(STEP_PADDLE, user, actioning_speed, glass)
		return

	if(istype(attacking_item, /obj/item/glassblowing/shears))
		do_glass_step(STEP_SHEAR, user, actioning_speed, glass)
		return

	if(istype(attacking_item, /obj/item/glassblowing/jacks))
		do_glass_step(STEP_JACKS, user, actioning_speed, glass)
		return

	return ..()

/obj/item/glassblowing/blowing_rod/attack_self(mob/user, modifiers)
	return ..()

/obj/item/glassblowing/blowing_rod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GlassBlowing", name)
		ui.open()

/obj/item/glassblowing/blowing_rod/ui_data()
	var/obj/item/glassblowing/molten_glass/glass = glass_ref?.resolve()

	var/data = list()
	data["inUse"] = in_use

	if(glass)
		data["glass"] = list(
			timeLeft = COOLDOWN_TIMELEFT(glass, remaining_heat),
			totalTime = glass.total_time,
			chosenItem = null,
			stepsRemaining = glass.steps_remaining,
			isFinished = glass.is_finished
		)

		var/obj/item_path = glass.chosen_item
		data["glass"]["chosenItem"] = item_path ? list(name = initial(item_path.name), type = item_path) : null
	else
		data["glass"] = null

	return data

/obj/item/glassblowing/blowing_rod/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!Adjacent(usr))
		return
	add_fingerprint(usr)

	var/obj/item/glassblowing/molten_glass/glass = glass_ref?.resolve()
	var/actioning_speed = usr.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * DEFAULT_TIMED

	if(!glass)
		return

	if(action == "Remove")
		if(!glass.chosen_item)
			remove_glass(usr, glass)
			in_use = FALSE
			return

		if(glass.is_finished)
			create_item(usr, glass)
			in_use = FALSE
		else
			remove_glass(usr, glass)
		return

	if(!glass.chosen_item)
		switch(action)
			if("Plate")
				glass.chosen_item = /obj/item/plate/blowing_glass
				glass.steps_remaining = list(blow=3,spin=3,paddle=3,shear=0,jacks=0) //blowing, spinning, paddling
			if("Bowl")
				glass.chosen_item = /obj/item/reagent_containers/cup/bowl/blowing_glass
				glass.steps_remaining = list(blow=2,spin=2,paddle=2,shear=0,jacks=3) //blowing, spinning, paddling
			if("Globe")
				glass.chosen_item = /obj/item/glassblowing/glass_globe
				glass.steps_remaining = list(blow=6,spin=3,paddle=0,shear=0,jacks=0) //blowing, spinning
			if("Cup")
				glass.chosen_item = /obj/item/reagent_containers/cup/beaker/large/blowing_glass
				glass.steps_remaining = list(blow=3,spin=3,paddle=3,shear=0,jacks=0) //blowing, spinning, paddling
			if("Lens")
				glass.chosen_item = /obj/item/glassblowing/glass_lens
				glass.steps_remaining = list(blow=0,spin=0,paddle=3,shear=3,jacks=3) //paddling, shearing, jacking
			if("Bottle")
				glass.chosen_item = /obj/item/reagent_containers/cup/glass/bottle/small
				glass.steps_remaining = list(blow=3,spin=2,paddle=3,shear=0,jacks=0) //blowing, spinning, paddling
	else
		switch(action)
			if("Blow")
				do_glass_step(STEP_BLOW, usr, actioning_speed, glass)
			if("Spin")
				do_glass_step(STEP_SPIN, usr, actioning_speed, glass)
			if("Paddle")
				do_glass_step(STEP_PADDLE, usr, actioning_speed, glass)
			if("Shear")
				do_glass_step(STEP_SHEAR, usr, actioning_speed, glass)
			if("Jacks")
				do_glass_step(STEP_JACKS, usr, actioning_speed, glass)
			if("Cancel")
				glass.chosen_item = null
				glass.steps_remaining = null
				glass.is_finished = FALSE
				to_chat(usr, span_notice("You start over with the [src]."))


/**
 * Removes the glass object from the rod.
 *
 * Try to put the glass into the user's hands, or on the floor if that fails.
 *
 * Arguments:
 * * mob/user - the mob doing the removing
 * * obj/item/glassblowing/molten_glass/glass - the glass object
 *
 * Returns TRUE or FALSE.
 */
/obj/item/glassblowing/blowing_rod/proc/remove_glass(mob/user, obj/item/glassblowing/molten_glass/glass)
	if(!glass)
		return

	in_use = FALSE
	user.put_in_hands(glass)
	glass.try_burn_user(user)
	glass_ref = null
	icon_state = "blow_pipe_empty"

/**
 * Creates the finished product and delete the glass object used to make it.
 *
 * Try to put the finished product into the user's hands
 *
 * Arguments:
 * * mob/user - the user doing the creating
 * * obj/item/glassblowing/molten_glass/glass - the glass object
 *
 * Returns TRUE or FALSE.
 */
/obj/item/glassblowing/blowing_rod/proc/create_item(mob/user, obj/item/glassblowing/molten_glass/glass)
	if(!glass)
		return
	if(in_use)
		return

	in_use = TRUE
	user.put_in_hands(new glass.chosen_item)
	user.mind.adjust_experience(/datum/skill/production, 30)
	glass_ref = null
	qdel(glass)
	icon_state = "blow_pipe_empty"
	return

/**
 * Display fail message and reset in_use.
 *
 * Craft is finished when all steps in steps_remaining are 0.
 *
 * Arguments:
 * * mob/user - mob to display to
 * * message - to display
 */
/obj/item/glassblowing/blowing_rod/proc/fail_message(message, mob/user)
	to_chat(user, span_warning(message))
	in_use = FALSE

/**
 * Try to do a glassblowing action.
 *
 * Checks for a table and valid tool if applicable, and updates the steps_remaining on the glass object.
 *
 * Arguments:
 * * step_id - the step id e.g. STEP_BLOW
 * * actioning_speed - the speed based on the user's production skill
 * * obj/item/glassblowing/molten_glass/glass - the glass object
 */
/obj/item/glassblowing/blowing_rod/proc/do_glass_step(step_id, mob/user, actioning_speed, obj/item/glassblowing/molten_glass/glass)
	if(!glass)
		return

	if(COOLDOWN_FINISHED(glass, remaining_heat))
		balloon_alert(user, "glass too cool!")
		return FALSE

	if(in_use)
		return

	in_use = TRUE

	if(!check_valid_table(user))
		fail_message("You must be near a non-flammable table!", user)
		return

	var/atom/movable/tool_to_use = check_valid_tool(user, step_id)
	if(!tool_to_use)
		in_use = FALSE
		return FALSE

	to_chat(user, span_notice("You begin to [step_id] [src]."))
	if(!do_after(user, actioning_speed, target = src))
		fail_message("You interrupt an action!", user)
		REMOVE_TRAIT(tool_to_use, TRAIT_CURRENTLY_GLASSBLOWING, TRAIT_GLASSBLOWING)
		return FALSE

	if(glass.steps_remaining)
		// We do not want to have negative values here
		if(glass.steps_remaining[step_id] > 0)
			glass.steps_remaining[step_id]--
			if(check_finished(glass))
				glass.is_finished = TRUE

	REMOVE_TRAIT(tool_to_use, TRAIT_CURRENTLY_GLASSBLOWING, TRAIT_GLASSBLOWING)
	in_use = FALSE

	to_chat(user, span_notice("You finish trying to [step_id] [src]."))
	user.mind.adjust_experience(/datum/skill/production, 10)


/**
 * Check if there is a non-flammable table nearby to do the crafting on.
 *
 * If the user is a master in the production skill, they can skip tables.
 *
 * Arguments:
 * * mob/living/user - the mob doing the action
 *
 * Returns TRUE or FALSE.
 */
/obj/item/glassblowing/blowing_rod/proc/check_valid_table(mob/living/user)
	var/skill_level = user.mind.get_skill_level(/datum/skill/production)
	if(skill_level >= SKILL_LEVEL_MASTER) //
		return TRUE
	for(var/obj/structure/table/check_table in range(1, get_turf(src)))
		if(!(check_table.resistance_flags & FLAMMABLE))
			return TRUE
	return FALSE

/**
 * Check if user is carrying the proper tool for the step.
 *
 * Arguments:
 * * mob/living/carbon/human/user - the mob doing the action
 * * step_id - the step id of the action being done
 *
 * We check to see if the user is using the right tool and if they are currently glassblowing with it.
 * If the correct tool is being used we return the tool. Otherwise we return `FALSE`
 */
/obj/item/glassblowing/blowing_rod/proc/check_valid_tool(mob/living/carbon/human/user, step_id)
	if(!istype(user))
		return FALSE

	if(step_id == STEP_BLOW || step_id == STEP_SPIN)
		if(HAS_TRAIT(user, TRAIT_CURRENTLY_GLASSBLOWING))
			balloon_alert(user, "already glassblowing!")
			return FALSE

		ADD_TRAIT(user, TRAIT_CURRENTLY_GLASSBLOWING, TRAIT_GLASSBLOWING)
		return user

	var/obj/item/glassblowing/used_tool
	switch(step_id)
		if(STEP_PADDLE)
			used_tool = user.is_holding_item_of_type(/obj/item/glassblowing/paddle)
		if(STEP_SHEAR)
			used_tool = user.is_holding_item_of_type(/obj/item/glassblowing/shears)
		if(STEP_JACKS)
			used_tool = user.is_holding_item_of_type(/obj/item/glassblowing/jacks)

	if(!used_tool)
		balloon_alert(user, "need the right tool!")
		return FALSE

	if(HAS_TRAIT(used_tool, TRAIT_CURRENTLY_GLASSBLOWING))
		balloon_alert(user, "already in use!")
		return FALSE

	ADD_TRAIT(used_tool, TRAIT_CURRENTLY_GLASSBLOWING, TRAIT_GLASSBLOWING)
	return used_tool

/**
 * Checks if the glass is ready to craft into its chosen item.
 *
 * Craft is finished when all steps in steps_remaining are 0.
 *
 * Arguments:
 * * obj/item/glassblowing/molten_glass/glass - the glass object
 *
 * Returns TRUE or FALSE.
 */
/obj/item/glassblowing/blowing_rod/proc/check_finished(obj/item/glassblowing/molten_glass/glass)
	for(var/step_id in glass.steps_remaining)
		if(glass.steps_remaining[step_id] != 0)
			return FALSE
	return TRUE

/datum/crafting_recipe/glassblowing_recipe
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_MISC

/datum/crafting_recipe/glassblowing_recipe/glass_blowing_rod
	name = "Glass-blowing Blowing Rod"
	result = /obj/item/glassblowing/blowing_rod

/obj/item/glassblowing/jacks
	name = "jacks"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "jacks"

/datum/crafting_recipe/glassblowing_recipe/glass_jack
	name = "Glass-blowing Jacks"
	result = /obj/item/glassblowing/jacks

/obj/item/glassblowing/paddle
	name = "paddle"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "paddle"

/datum/crafting_recipe/glassblowing_recipe/glass_paddle
	name = "Glass-blowing Paddle"
	result = /obj/item/glassblowing/paddle

/obj/item/glassblowing/shears
	name = "shears"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "shears"

/datum/crafting_recipe/glassblowing_recipe/glass_shears
	name = "Glass-blowing Shears"
	result = /obj/item/glassblowing/shears

/obj/item/glassblowing/metal_cup
	name = "metal cup"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "metal_cup_empty"
	var/has_sand = FALSE

/datum/crafting_recipe/glassblowing_recipe/glass_metal_cup
	name = "Glass-blowing Metal Cup"
	result = /obj/item/glassblowing/metal_cup

/obj/item/glassblowing/metal_cup/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_obj = I
		if(!glass_obj.use(1))
			return
		has_sand = TRUE
		icon_state = "metal_cup_full"
	return ..()

#undef DEFAULT_TIMED
#undef STEP_BLOW
#undef STEP_SPIN
#undef STEP_PADDLE
#undef STEP_SHEAR
#undef STEP_JACKS
