#define DEFAULT_TIMED 5 SECONDS
#define MASTER_TIMED 2 SECONDS

/obj/item/skillchip/glassblowing_master
	name = "Glassblowing Master skillchip"
	desc = "A master of glass, perhaps even capable of creating life from glass and fire."
	auto_traits = list(TRAIT_GLASSBLOWING_MASTER)
	skill_name = "Glass-Blowing Master"
	skill_description = "Master the ability to use glass within glassblowing."
	skill_icon = "certificate"
	activate_message = "<span class='notice'>The faults within the glass are now to be seen.</span>"
	deactivate_message = "<span class='notice'>Glass becomes more obscured.</span>"

/obj/item/glassblowing
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'

/obj/item/glassblowing/glass_globe
	name = "glass globe"
	desc = "A glass bowl that is capable of carrying things."
	icon_state = "glass_bowl"

/datum/export/glassblowing
	cost = 3000
	unit_name = "glassblowing product"
	export_types = list(/obj/item/glassblowing/glass_lens,
						/obj/item/glassblowing/glass_globe,
						/obj/item/reagent_containers/glass/bowl/blowing_glass,
						/obj/item/reagent_containers/glass/beaker/large/blowing_glass,
						/obj/item/plate/blowing_glass)

/datum/export/glassblowing/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	. = ..()

/obj/item/glassblowing/glass_lens
	name = "glass lens"
	desc = "A glass bowl that is capable of carrying things."
	icon_state = "glass_bowl"

/obj/item/reagent_containers/glass/bowl/blowing_glass
	name = "glass bowl"
	desc = "A glass bowl that is capable of carrying things."
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'
	icon_state = "glass_bowl"

/obj/item/reagent_containers/glass/beaker/large/blowing_glass
	name = "glass cup"
	desc = "A glass cup that is capable of carrying liquids."
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'
	icon_state = "glass_cup"
	custom_materials = null

/obj/item/plate/blowing_glass
	name = "glass plate"
	desc = "A glass plate that is capable of carrying things."
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'
	icon_state = "glass_plate"

/obj/item/glassblowing/molten_glass
	name = "molten glass"
	desc = "A glob of molten glass, ready to be shaped into art."
	icon_state = "molten_glass"
	///the time check against world.time if its still molten / requires heating up
	var/world_molten = 0
	var/list/required_actions = list(0,0,0,0,0) //blowing, spinning, paddles, shears, jacks
	var/list/current_actions = list(0,0,0,0,0)
	var/chosen_item

/obj/item/glassblowing/molten_glass/Initialize()
	. = ..()
	world_molten = world.time + 15 SECONDS

/obj/item/glassblowing/molten_glass/examine(mob/user)
	. = ..()
	if(world_molten < world.time)
		. += span_notice("[src] has cooled down and will require reheating to modify!")
	if(required_actions[1])
		. += "You require [required_actions[1]] blowing actions!"
		. += "You currently have [current_actions[1]] blowing actions!"
	if(required_actions[2])
		. += "You require [required_actions[2]] spinning actions!"
		. += "You currently have [current_actions[2]] spinning actions!"
	if(required_actions[3])
		. += "You require [required_actions[3]] paddling actions!"
		. += "You currently have [current_actions[3]] paddling actions!"
	if(required_actions[4])
		. += "You require [required_actions[4]] shearing actions!"
		. += "You currently have [current_actions[4]] shearing actions!"
	if(required_actions[5])
		. += "You require [required_actions[5]] jacking actions!"
		. += "You currently have [current_actions[5]] jacking actions!"

/obj/item/glassblowing/molten_glass/pickup(mob/user)
	if(!isliving(user))
		return ..()
	var/mob/living/living_user = user
	if(world_molten >= world.time)
		to_chat(living_user, span_warning("You burn your hands trying to pick up [src]!"))
		living_user.adjustFireLoss(15)
		user.dropItemToGround(src)
		return
	return ..()

/obj/item/glassblowing/blowing_rod
	name = "blowing rod"
	desc = "A tool that is used to hold the molten glass as well as help shape it."
	icon_state = "blow_pipe_empty"
	var/in_use = FALSE

/datum/crafting_recipe/glass_blowing_rod
	name = "Glass-blowing Blowing Rod"
	result = /obj/item/glassblowing/blowing_rod
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_PRIMAL

/obj/item/glassblowing/blowing_rod/examine(mob/user)
	. = ..()
	var/obj/item/glassblowing/molten_glass/find_glass = locate() in contents
	if(find_glass)
		if(find_glass.required_actions[1])
			. += "You require [find_glass.required_actions[1]] blowing actions!"
			. += "You currently have [find_glass.current_actions[1]] blowing actions!"
		if(find_glass.required_actions[2])
			. += "You require [find_glass.required_actions[2]] spinning actions!"
			. += "You currently have [find_glass.current_actions[2]] spinning actions!"
		if(find_glass.required_actions[3])
			. += "You require [find_glass.required_actions[3]] paddling actions!"
			. += "You currently have [find_glass.current_actions[3]] paddling actions!"
		if(find_glass.required_actions[4])
			. += "You require [find_glass.required_actions[4]] shearing actions!"
			. += "You currently have [find_glass.current_actions[4]] shearing actions!"
		if(find_glass.required_actions[5])
			. += "You require [find_glass.required_actions[5]] jacking actions!"
			. += "You currently have [find_glass.current_actions[5]] jacking actions!"

/obj/item/glassblowing/blowing_rod/proc/check_valid_table()
	for(var/obj/structure/table/check_table in range(1, get_turf(src)))
		if(!(check_table.resistance_flags & FLAMMABLE))
			return TRUE //if you can find a table that is not flammable, good
	return FALSE

/obj/item/glassblowing/blowing_rod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()
	if(istype(target, /obj/item/glassblowing/molten_glass))
		var/obj/item/glassblowing/molten_glass/attacking_glass = target
		var/obj/item/glassblowing/molten_glass/find_glass = locate() in contents
		if(find_glass)
			to_chat(user, span_warning("[src] already has some glass on it still!"))
			return
		attacking_glass.forceMove(src)
		to_chat(user, span_notice("[src] picks up [target]."))
		icon_state = "blow_pipe_full"
		return
	return ..()

/obj/item/glassblowing/blowing_rod/attackby(obj/item/I, mob/living/user, params)
	var/actioning_speed = HAS_TRAIT(user, TRAIT_GLASSBLOWING_MASTER) ? MASTER_TIMED : DEFAULT_TIMED
	var/obj/item/glassblowing/molten_glass/find_glass = locate() in contents

	if(istype(I, /obj/item/glassblowing/molten_glass))
		if(find_glass)
			to_chat(user, span_warning("[src] already has some glass on it still!"))
			return
		I.forceMove(src)
		to_chat(user, span_notice("[src] picks up [I]."))
		icon_state = "blow_pipe_full"
		return

	if(istype(I, /obj/item/glassblowing/paddle))
		if(in_use)
			return
		in_use = TRUE
		if(!check_valid_table())
			to_chat(user, span_warning("You must be near a non-flammable table!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin using [I] on [src]."))
		if(!do_after(user, actioning_speed, target = src))
			to_chat(user, span_warning("You interrupt an action!"))
			in_use = FALSE
			return
		if(!check_valid_table())
			to_chat(user, span_warning("You must be near a non-flammable table!"))
			in_use = FALSE
			return
		find_glass.current_actions[3]++
		to_chat(user, span_notice("You finish using [I] on [src]."))
		in_use = FALSE
		return

	if(istype(I, /obj/item/glassblowing/shears))
		if(in_use)
			return
		in_use = TRUE
		if(!check_valid_table())
			to_chat(user, span_warning("You must be near a non-flammable table!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin using [I] on [src]."))
		if(!do_after(user, actioning_speed, target = src))
			to_chat(user, span_warning("You interrupt an action!"))
			in_use = FALSE
			return
		if(!check_valid_table())
			to_chat(user, span_warning("You must be near a non-flammable table!"))
			in_use = FALSE
			return
		find_glass.current_actions[4]++
		to_chat(user, span_notice("You finish using [I] on [src]."))
		in_use = FALSE
		return

	if(istype(I, /obj/item/glassblowing/jacks))
		if(in_use)
			return
		in_use = TRUE
		if(!check_valid_table())
			to_chat(user, span_warning("You must be near a non-flammable table!"))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin using [I] on [src]."))
		if(!do_after(user, actioning_speed, target = src))
			to_chat(user, span_warning("You interrupt an action!"))
			in_use = FALSE
			return
		if(!check_valid_table())
			to_chat(user, span_warning("You must be near a non-flammable table!"))
			in_use = FALSE
			return
		find_glass.current_actions[5]++
		to_chat(user, span_notice("You finish using [I] on [src]."))
		in_use = FALSE
		return

	return ..()

/obj/item/glassblowing/blowing_rod/attack_self(mob/user, modifiers)
	var/actioning_speed = HAS_TRAIT(user, TRAIT_GLASSBLOWING_MASTER) ? MASTER_TIMED : DEFAULT_TIMED
	var/obj/item/glassblowing/molten_glass/find_glass = locate() in contents

	if(find_glass)
		if(find_glass.world_molten < world.time)
			to_chat(user, span_warning("The glass has cooled down far too much to be handled..."))
			return
		if(in_use)
			to_chat(user, span_warning("[src] is busy being used!"))
			return
		in_use = TRUE
		if(!find_glass.chosen_item)
			var/choice = tgui_input_list(user, "What would you like to make?", "Choice Selection", list("Plate", "Bowl", "Globe", "Cup", "Lens"))
			if(!choice)
				in_use = FALSE
				return
			switch(choice)
				if("Plate")
					find_glass.chosen_item = /obj/item/plate/blowing_glass
					find_glass.required_actions = list(3,3,3,0,0) //blowing, spinning, paddling
				if("Bowl")
					find_glass.chosen_item = /obj/item/reagent_containers/glass/bowl/blowing_glass
					find_glass.required_actions = list(2,2,2,0,3) //blowing, spinning, paddling
				if("Globe")
					find_glass.chosen_item = /obj/item/glassblowing/glass_globe
					find_glass.required_actions = list(6,3,0,0,0) //blowing, spinning
				if("Cup")
					find_glass.chosen_item = /obj/item/reagent_containers/glass/beaker/large/blowing_glass
					find_glass.required_actions = list(3,3,3,0,0) //blowing, spinning, paddling
				if("Lens")
					find_glass.chosen_item = /obj/item/glassblowing/glass_lens
					find_glass.required_actions = list(0,0,3,3,3) //paddling, shearing, jacking
			in_use = FALSE
			return
		else
			var/action_choice = tgui_alert(user, "What would you like to do?", "Action Selection", list("Blow", "Spin", "Remove"))
			if(!action_choice)
				in_use = FALSE
				return
			switch(action_choice)
				if("Blow")
					if(!check_valid_table())
						to_chat(user, span_warning("You must be near a non-flammable table!"))
						in_use = FALSE
						return
					to_chat(user, span_notice("You begin blowing [src]."))
					if(!do_after(user, actioning_speed, target = src))
						to_chat(user, span_warning("You interrupt an action!"))
						in_use = FALSE
						return
					if(!check_valid_table())
						to_chat(user, span_warning("You must be near a non-flammable table!"))
						in_use = FALSE
						return
					find_glass.current_actions[1]++
					to_chat(user, span_notice("You finish blowing [src]."))
				if("Spin")
					if(!check_valid_table())
						to_chat(user, span_warning("You must be near a non-flammable table!"))
						in_use = FALSE
						return
					to_chat(user, span_notice("You begin spinning [src]."))
					if(!do_after(user, actioning_speed, target = src))
						to_chat(user, span_warning("You interrupt an action!"))
						in_use = FALSE
						return
					if(!check_valid_table())
						to_chat(user, span_warning("You must be near a non-flammable table!"))
						in_use = FALSE
						return
					find_glass.current_actions[2]++
					to_chat(user, span_notice("You finish spinning [src]."))
				if("Remove")
					if(find_glass.current_actions[1] < find_glass.required_actions[1])
						in_use = FALSE
						find_glass.forceMove(get_turf(src))
						return
					if(find_glass.current_actions[2] < find_glass.required_actions[2])
						in_use = FALSE
						find_glass.forceMove(get_turf(src))
						return
					if(find_glass.current_actions[3] < find_glass.required_actions[3])
						in_use = FALSE
						find_glass.forceMove(get_turf(src))
						return
					if(find_glass.current_actions[4] < find_glass.required_actions[4])
						in_use = FALSE
						find_glass.forceMove(get_turf(src))
						return
					if(find_glass.current_actions[5] < find_glass.required_actions[5])
						in_use = FALSE
						find_glass.forceMove(get_turf(src))
						return
					new find_glass.chosen_item(get_turf(src))
					in_use = FALSE
					qdel(find_glass)
					return
			in_use = FALSE
			return
	return ..()


/obj/item/glassblowing/jacks
	name = "jacks"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "jacks"

/datum/crafting_recipe/glass_jack
	name = "Glass-blowing Jacks"
	result = /obj/item/glassblowing/jacks
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_PRIMAL

/obj/item/glassblowing/paddle
	name = "paddle"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "paddle"

/datum/crafting_recipe/glass_paddle
	name = "Glass-blowing Paddle"
	result = /obj/item/glassblowing/paddle
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_PRIMAL

/obj/item/glassblowing/shears
	name = "shears"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "shears"

/datum/crafting_recipe/glass_shears
	name = "Glass-blowing Shears"
	result = /obj/item/glassblowing/shears
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_PRIMAL

/obj/item/glassblowing/metal_cup
	name = "metal cup"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "metal_cup_empty"
	var/has_sand = FALSE

/datum/crafting_recipe/glass_metal_cup
	name = "Glass-blowing Metal Cup"
	result = /obj/item/glassblowing/metal_cup
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_PRIMAL

/obj/item/glassblowing/metal_cup/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_obj = I
		if(!glass_obj.use(1))
			return
		has_sand = TRUE
		icon_state = "metal_cup_full"
	return ..()

#undef DEFAULT_TIMED
#undef MASTER_TIMED
