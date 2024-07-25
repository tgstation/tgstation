/obj/machinery/health_scanner_floor
	name = "floor scanner"
	desc = "Gives patients a brief medical overview by stepping on it."

	icon_state = "floor_scanner"
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'

	density = FALSE
	anchored = TRUE

	maptext_x = -16
	maptext_y = 32
	maptext_width = 64

	pixel_y = -8
	var/obj/effect/abstract/maptext_holder/floor_scanner/maptext_obj

	COOLDOWN_DECLARE(scan_cd)

/obj/machinery/health_scanner_floor/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/repackable, item_to_pack_into = /obj/item/flatpacked_machine/generic, repacking_time = 3 SECONDS, generic_repack = TRUE)

	maptext_obj = new(src)
	vis_contents += maptext_obj

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, connections)
	AddElement(/datum/element/elevation, 4)

/obj/machinery/health_scanner_floor/proc/generate_maptext(mob/living/carbon/stepper)
	var/health_precent = stepper.health

	var/oxygen = stepper.getOxyLoss()
	var/toxin = stepper.getToxLoss()
	var/brute = stepper.getBruteLoss()
	var/burn = stepper.getFireLoss()
	//screw cloning I hate clone damage

	return "<span style='text-align: center'>[MAPTEXT_PIXELLARI("[health_precent]%")]\n <span style='color: #40b0ff;'>[oxygen]</span> - <span style='color: #33ff33;'>[toxin]</span> - <span style='color: #ffee00;'>[burn]</span> - <span style='color: #ff6666;'>[brute]</span></span>"

/obj/machinery/health_scanner_floor/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!iscarbon(arrived))
		return
	if(!COOLDOWN_FINISHED(src, scan_cd))
		return
	COOLDOWN_START(src, scan_cd, 3 SECONDS)

	arrived.visual_masked_scan()
	maptext_obj.maptext = generate_maptext(arrived)
	animate(maptext_obj, 0.25 SECONDS, maptext_y = 32, easing = BOUNCE_EASING)

	addtimer(CALLBACK(src, PROC_REF(clear_maptext)), 3 SECONDS)

/obj/machinery/health_scanner_floor/proc/clear_maptext()
	maptext_obj.maptext = null
	maptext_obj.maptext_y = 0

/obj/effect/abstract/maptext_holder/floor_scanner
	plane = GAME_PLANE_UPPER

	maptext_x = -16
	maptext_width = 64
