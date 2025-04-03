
// Operating Table / Beds / Lockers

/obj/structure/bed/abductor
	name = "resting contraption"
	desc = "This looks similar to contraptions from Earth. Could aliens be stealing our technology?"
	icon = 'icons/obj/antags/abductor.dmi'
	build_stack_type = /obj/item/stack/sheet/mineral/abductor
	icon_state = "bed"

/obj/structure/table_frame/abductor
	name = "alien table frame"
	desc = "A sturdy table frame made from alien alloy."
	icon_state = "alien_frame"
	framestack = /obj/item/stack/sheet/mineral/abductor
	framestackamount = 1

/obj/structure/table_frame/abductor/get_table_type(obj/item/stack/our_stack)
	if(istype(our_stack, /obj/item/stack/sheet/mineral/abductor))
		return /obj/structure/table/abductor
	if(istype(our_stack, /obj/item/stack/sheet/mineral/silver))
		return /obj/structure/table/optable/abductor

/obj/structure/table/abductor
	name = "alien table"
	desc = "Advanced flat surface technology at work!"
	icon = 'icons/obj/smooth_structures/alien_table.dmi'
	icon_state = "alien_table-0"
	base_icon_state = "alien_table"
	buildstack = /obj/item/stack/sheet/mineral/abductor
	framestack = /obj/item/stack/sheet/mineral/abductor
	buildstackamount = 1
	framestackamount = 1
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_TABLES
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_TABLES
	frame = /obj/structure/table_frame/abductor
	custom_materials = list(/datum/material/silver =SHEET_MATERIAL_AMOUNT)
	can_flip = FALSE

/obj/structure/table/optable/abductor
	name = "alien operating table"
	desc = "Used for alien medical procedures. The surface is covered in tiny spines."
	frame = /obj/structure/table_frame/abductor
	buildstack = /obj/item/stack/sheet/mineral/silver
	framestack = /obj/item/stack/sheet/mineral/abductor
	buildstackamount = 1
	framestackamount = 1
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "bed"
	can_buckle = TRUE
	buckle_lying = 90
	/// Amount to inject per second
	var/inject_amount = 0.5

	var/static/list/injected_reagents = list(/datum/reagent/medicine/cordiolis_hepatico)

/obj/structure/table/optable/abductor/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/optable/abductor/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(iscarbon(AM))
		START_PROCESSING(SSobj, src)
		to_chat(AM, span_danger("You feel a series of tiny pricks!"))

/obj/structure/table/optable/abductor/process(seconds_per_tick)
	. = PROCESS_KILL
	for(var/mob/living/carbon/victim in get_turf(src))
		. = TRUE
		for(var/chemical in injected_reagents)
			if(victim.reagents.get_reagent_amount(chemical) < inject_amount * seconds_per_tick)
				victim.reagents.add_reagent(chemical, inject_amount * seconds_per_tick)
	return .

/obj/structure/table/optable/abductor/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/closet/abductor
	name = "alien locker"
	desc = "Contains secrets of the universe."
	icon_state = "abductor"
	icon_door = "abductor"
	can_weld_shut = FALSE
	door_anim_time = 0
	material_drop = /obj/item/stack/sheet/mineral/abductor

/obj/structure/door_assembly/door_assembly_abductor
	name = "alien airlock assembly"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	base_name = "alien airlock"
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/abductor
	material_type = /obj/item/stack/sheet/mineral/abductor
	noglass = TRUE
