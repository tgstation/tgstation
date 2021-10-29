#define DEFAULT_SPIN 4 SECONDS
#define MASTER_SPIN 2 SECONDS

/obj/item/skillchip/ceramic_master
	name = "Ceramic Master skillchip"
	desc = "A master of clay, perhaps even capable of creating life from clay and fire."
	auto_traits = list(TRAIT_CERAMIC_MASTER)
	skill_name = "Ceramic Master"
	skill_description = "Master the ability to use clay within ceramics."
	skill_icon = "certificate"
	activate_message = "<span class='notice'>The faults within the clay are now to be seen.</span>"
	deactivate_message = "<span class='notice'>Clay becomes more obscured.</span>"

/obj/structure/water_source/puddle/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_item = O
		if(!glass_item.use(1))
			return
		new /obj/item/ceramic/clay(get_turf(src))
		return
	return ..()

/turf/open/water/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_item = C
		if(!glass_item.use(1))
			return
		new /obj/item/ceramic/clay(src)
		return
	return ..()

/obj/structure/sink/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/stack/ore/glass))
		if(dispensedreagent != /datum/reagent/water)
			return
		if(reagents.total_volume <= 0)
			return
		var/obj/item/stack/ore/glass/glass_item = O
		if(!glass_item.use(1))
			return
		new /obj/item/ceramic/clay(get_turf(src))
		return
	return ..()

/obj/item/ceramic
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'
	var/forge_item

/obj/item/ceramic/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon_item = I
		if(!forge_item || !crayon_item.paint_color)
			return
		color = crayon_item.paint_color
		to_chat(user, span_notice("You color [src] with [crayon_item]..."))
		return
	return ..()

/obj/item/ceramic/clay
	name = "clay"
	desc = "A pile of clay that can be used to create ceramic artwork."
	icon_state = "clay"

/datum/export/ceramics
	cost = 1000
	unit_name = "ceramic product"
	export_types = list(/obj/item/plate/ceramic,
						/obj/item/reagent_containers/glass/bowl/ceramic,
						/obj/item/reagent_containers/glass/beaker/large/ceramic)

/datum/export/ceramics/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	. = ..()

/datum/export/ceramics_unfinished
	cost = 300
	unit_name = "unfinished ceramic product"
	export_types = list(/obj/item/ceramic/plate,
						/obj/item/ceramic/bowl,
						/obj/item/ceramic/cup)

/datum/export/ceramics_unfinished/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	. = ..()

/obj/item/ceramic/plate
	name = "ceramic plate"
	desc = "A piece of clay that is flat, in the shape of a plate."
	icon_state = "clay_plate"
	forge_item = /obj/item/plate/ceramic

/obj/item/plate/ceramic
	name = "ceramic plate"
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'
	icon_state = "clay_plate"

/obj/item/ceramic/bowl
	name =  "ceramic bowl"
	desc = "A piece of clay with a raised lip, in the shape of a bowl."
	icon_state = "clay_bowl"
	forge_item = /obj/item/reagent_containers/glass/bowl/ceramic

/obj/item/reagent_containers/glass/bowl/ceramic
	name = "ceramic bowl"
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'
	icon_state = "clay_bowl"
	custom_materials = null

/obj/item/ceramic/cup
	name = "ceramic cup"
	desc = "A piece of clay with high walls, in the shape of a cup. It can hold 120 units."
	icon_state = "clay_cup"
	forge_item = /obj/item/reagent_containers/glass/beaker/large/ceramic

/obj/item/reagent_containers/glass/beaker/large/ceramic
	name = "ceramic cup"
	desc = "A cup that is made from ceramic."
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'
	icon_state = "clay_cup"
	custom_materials = null

/obj/structure/throwing_wheel
	name = "throwing wheel"
	desc = "A machine that allows you to throw clay."
	icon = 'modular_skyrat/modules/primitive_fun/icons/prim_fun.dmi'
	icon_state = "throw_wheel_empty"
	density = TRUE
	anchored = TRUE
	var/in_use = FALSE

/obj/structure/throwing_wheel/attackby(obj/item/I, mob/living/user, params)
	var/spinning_speed = HAS_TRAIT(user, TRAIT_CERAMIC_MASTER) ? MASTER_SPIN : DEFAULT_SPIN
	if(istype(I, /obj/item/ceramic/clay))
		if(length(contents) >= 1)
			return
		if(!do_after(user, spinning_speed, target = src))
			return
		I.forceMove(src)
		icon_state = "throw_wheel_full"
		return
	if(I.tool_behaviour == TOOL_CROWBAR)
		new /obj/item/stack/sheet/iron/ten(get_turf(src))
		qdel(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		anchored = !anchored
		return
	return ..()

/obj/structure/throwing_wheel/proc/use_clay(spawn_type, mob/user)
	var/spinning_speed = HAS_TRAIT(user, TRAIT_CERAMIC_MASTER) ? MASTER_SPIN : DEFAULT_SPIN
	var/given_message = list(
		"You slowly start spinning the throwing wheel...",
		"You place your hands on the clay, slowly shaping it...",
		"You start becoming satisfied with what you have made...",
		"You slowly stop the throwing wheel from spinning...",
		"You stop the throwing wheel, admiring your new creation...",
	)
	for(var/loop_try in 1 to 5)
		if(!do_after(user, spinning_speed, target = src))
			in_use = FALSE
			return
		to_chat(user, span_notice(given_message[loop_try]))
	var/obj/change_obj = new spawn_type(get_turf(src))
	var/atom/movable/get_atom = contents[1]
	change_obj.color = get_atom.color
	qdel(get_atom)
	icon_state = "throw_wheel_empty"
	in_use = FALSE

/obj/structure/throwing_wheel/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/spinning_speed = HAS_TRAIT(user, TRAIT_CERAMIC_MASTER) ? MASTER_SPIN : DEFAULT_SPIN
	if(in_use)
		return
	in_use = TRUE
	if(length(contents) >= 1)
		var/user_input = tgui_alert(user, "What would you like to do?", "Choice Selection", list("Create", "Remove"))
		if(!user_input)
			in_use = FALSE
			return
		switch(user_input)
			if("Create")
				var/creation_choice = tgui_alert(user, "What you like to create?", "Creation Choice", list("Cup", "Plate", "Bowl"))
				if(!creation_choice)
					in_use = FALSE
					return
				switch(creation_choice)
					if("Cup")
						use_clay(/obj/item/ceramic/cup, user)
					if("Plate")
						use_clay(/obj/item/ceramic/plate, user)
					if("Bowl")
						use_clay(/obj/item/ceramic/bowl, user)
				return
			if("Remove")
				if(!do_after(user, spinning_speed, target = src))
					in_use = FALSE
					return
				var/atom/movable/get_atom = contents[1]
				get_atom.forceMove(get_turf(src))
				user.put_in_active_hand(get_atom)
				in_use = FALSE
				icon_state = "throw_wheel_empty"
				return
	in_use = FALSE
	return

#undef DEFAULT_SPIN
#undef MASTER_SPIN
