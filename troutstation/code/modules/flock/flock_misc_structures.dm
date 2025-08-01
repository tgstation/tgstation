














// Cult Airlocks

// /obj/machinery/door/airlock/cult
// 	name = "cult airlock"
// 	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
// 	overlays_file = 'icons/obj/doors/airlocks/cult/runed/overlays.dmi'
// 	assemblytype = /obj/structure/door_assembly/door_assembly_cult
// 	hackProof = TRUE
// 	aiControlDisabled = AI_WIRE_DISABLED
// 	req_access = list(ACCESS_BLOODCULT)
// 	damage_deflection = 10
// 	var/openingoverlaytype = /obj/effect/temp_visual/cult/door
// 	var/friendly = FALSE
// 	var/stealthy = FALSE

// /obj/machinery/door/airlock/cult/Initialize(mapload)
// 	. = ..()
// 	new openingoverlaytype(loc)
// 	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

// /obj/machinery/door/airlock/cult/canAIControl(mob/user)
// 	return (IS_CULTIST(user) && !isAllPowerCut())

// /obj/machinery/door/airlock/cult/on_break()
// 	set_panel_open(TRUE)

// /obj/machinery/door/airlock/cult/isElectrified()
// 	return FALSE

// /obj/machinery/door/airlock/cult/hasPower()
// 	return TRUE

// /obj/machinery/door/airlock/cult/allowed(mob/living/L)
// 	if(!density)
// 		return TRUE
// 	if(friendly || IS_CULTIST(L) || isshade(L) || isconstruct(L))
// 		if(!stealthy)
// 			new openingoverlaytype(loc)
// 		return TRUE
// 	else
// 		if(!stealthy)
// 			new /obj/effect/temp_visual/cult/sac(loc)
// 			var/atom/throwtarget
// 			throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
// 			SEND_SOUND(L, sound(SFX_HALLUCINATION_TURN_AROUND,0,1,50))
// 			flash_color(L, flash_color=COLOR_CULT_RED, flash_time=20)
// 			L.Paralyze(40)
// 			L.throw_at(throwtarget, 5, 1)
// 		return FALSE

// /obj/machinery/door/airlock/cult/proc/conceal()
// 	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
// 	overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
// 	name = "Airlock"
// 	desc = "It opens and closes."
// 	stealthy = TRUE
// 	update_appearance()

// /obj/machinery/door/airlock/cult/proc/reveal()
// 	icon = initial(icon)
// 	overlays_file = initial(overlays_file)
// 	name = initial(name)
// 	desc = initial(desc)
// 	stealthy = initial(stealthy)
// 	update_appearance()

// /obj/machinery/door/airlock/cult/narsie_act()
// 	return

// /obj/machinery/door/airlock/cult/friendly
// 	friendly = TRUE

// /obj/machinery/door/airlock/cult/glass
// 	glass = TRUE
// 	opacity = FALSE

// /obj/machinery/door/airlock/cult/glass/friendly
// 	friendly = TRUE

// /obj/machinery/door/airlock/cult/unruned
// 	icon = 'icons/obj/doors/airlocks/cult/unruned/cult.dmi'
// 	overlays_file = 'icons/obj/doors/airlocks/cult/unruned/overlays.dmi'
// 	assemblytype = /obj/structure/door_assembly/door_assembly_cult/unruned
// 	openingoverlaytype = /obj/effect/temp_visual/cult/door/unruned

// /obj/machinery/door/airlock/cult/unruned/friendly
// 	friendly = TRUE

// /obj/machinery/door/airlock/cult/unruned/glass
// 	glass = TRUE
// 	opacity = FALSE

// /obj/machinery/door/airlock/cult/unruned/glass/friendly
// 	friendly = TRUE

// /obj/machinery/door/airlock/cult/weak
// 	name = "brittle cult airlock"
// 	desc = "An airlock hastily corrupted by blood magic, it is unusually brittle in this state."
// 	normal_integrity = 150
// 	damage_deflection = 5
// 	armor_type = /datum/armor/none
