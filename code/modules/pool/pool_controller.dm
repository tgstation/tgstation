#define FRIGID 1
#define COOL 2
#define NORMAL 3
#define WARM 4
#define SCALDING 5

//Originally stolen from paradise. Credits to tigercat2000.
//Modified a lot by Kokojo and Tortellini Tony.
//Modified even more and completely rebuilt ui by YoYoBatty.
/obj/machinery/poolcontroller
	name = "\improper Pool Controller"
	desc = "A controller for the nearby pool."
	icon = 'icons/turf/pool.dmi'
	icon_state = "poolc_3"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 75
	var/list/linkedturfs //List contains all of the linked pool turfs to this controller, assignment happens on initialize
	var/temperature = NORMAL //1-5 Frigid Cool Normal Warm Scalding
	var/srange = 10 //The range of the search for pool turfs, change this for bigger or smaller pools.
	var/linkedmist = list() //Used to keep track of created mist
	var/misted = FALSE //Used to check for mist.
	var/obj/item/reagent_containers/beaker = null
	var/cur_reagent = "Water"
	var/drainable = FALSE
	var/drained = FALSE
	var/bloody = FALSE
	var/obj/machinery/drain/linkeddrain = null
	var/timer = 0 //we need a cooldown on that shit.
	var/reagenttimer = 0 //We need 2.
	var/shocked = FALSE//Shocks morons, like an airlock.
	var/tempunlocked = FALSE
	var/old_rcolor
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE


/obj/machinery/poolcontroller/Initialize()
	. = ..()
	STOP_PROCESSING(SSmachines, src)
	START_PROCESSING(SSprocessing, src)
	wires = new /datum/wires/poolcontroller(src)
	for(var/turf/open/pool/W in range(srange,src)) //Search for /turf/open/beach/water in the range of var/srange
		LAZYADD(linkedturfs, W)
	for(var/obj/machinery/drain/pooldrain in range(srange,src))
		linkeddrain = pooldrain

/obj/machinery/poolcontroller/Destroy()
	if(beaker)
		beaker.forceMove(get_turf(src))
		beaker = null
	linkeddrain = null
	linkedturfs.Cut()
	return ..()

/obj/machinery/poolcontroller/emag_act(mob/user) //Emag_act, this is called when it is hit with a cryptographic sequencer.
	if(!(obj_flags & EMAGGED)) //If it is not already emagged, emag it.
		to_chat(user, "<span class='warning'>You disable the [src]'s safety features.</span>")
		do_sparks(5, TRUE, src)
		obj_flags |= EMAGGED
		tempunlocked = TRUE
		drainable = TRUE
		if(GLOB.adminlog)
			log_game("[key_name(user)] emagged [src]")
			message_admins("[key_name_admin(user)] emagged [src]")
	else
		to_chat(user, "<span class='warning'>The interface on [src] has been damaged.</span>")
		return

/obj/machinery/poolcontroller/attackby(obj/item/W, mob/user)
	if(shocked && !(machine_stat & NOPOWER))
		shock(user,50)
	if(machine_stat & (BROKEN))
		return

	if(istype(W,/obj/item/reagent_containers/glass/beaker))
		if(beaker)
			to_chat(user, "A beaker is already loaded into the machine.")
			return
		if(W.reagents.total_volume >= 100 && W.reagents.reagent_list.len ==1) //check if full and allow one reageant only.
			for(var/X in W.reagents.reagent_list)
				var/datum/reagent/R = X
				if(R.reagent_state == SOLID)
					to_chat(user, "The pool cannot accept reagents in solid form!.")
					return
				else
					beaker =  W
					user.dropItemToGround(W)
					W.forceMove(src)
					to_chat(user, "You add the beaker to the machine!")
					updateUsrDialog()
					cur_reagent = "[R.name]"
					for(var/I in linkedturfs)
						var/turf/open/pool/P = I
						if(P.reagents)
							P.reagents.clear_reagents()
							P.reagents.add_reagent(R.type, 100)
					if(GLOB.adminlog)
						log_game("[key_name(user)] has changed the [src] chems to [R.name]")
						message_admins("[key_name_admin(user)] has changed the [src] chems to [R.name].")
					timer = 15
		else
			to_chat(user, "<span class='notice'>This machine only accepts full large beakers of one reagent.</span>")
			return
	else if(panel_open && is_wire_tool(W))
		wires.interact(user)
	else
		return ..()

/obj/machinery/poolcontroller/screwdriver_act(mob/living/user, obj/item/W)
	. = ..()
	if(.)
		return TRUE
	cut_overlays()
	panel_open = !panel_open
	to_chat(user, "You [panel_open ? "open" : "close"] the maintenance panel.")
	W.play_tool_sound(src)
	if(panel_open)
		add_overlay("wires")
	return TRUE

//procs
/obj/machinery/poolcontroller/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(electrocute_mob(user, get_area(src), src, 0.7))
		return TRUE
	else
		return FALSE

/obj/machinery/poolcontroller/proc/poolreagent()
	for(var/X in linkedturfs)
		var/turf/open/pool/W = X
		for(var/mob/living/carbon/human/swimee in W)
			if(beaker && cur_reagent && W.reagents)
				for(var/Q in W.reagents.reagent_list)
					var/datum/reagent/R = Q
					if(R.reagent_state == SOLID)
						R.reagent_state = LIQUID
				W.reagents.expose(swimee, VAPOR, 0.03) //3 percent
				for(var/Q in W.reagents.reagent_list)
					var/datum/reagent/R = Q
					swimee.reagents.add_reagent(R.type, 0.5) //osmosis
		for(var/obj/objects in W)
			if(beaker && cur_reagent && W.reagents)
				W.reagents.expose(objects, VAPOR, 1)
			reagenttimer = 4
	changecolor()


/obj/machinery/poolcontroller/process()
	updatePool() //Call the mob affecting proc)
	if(timer > 0)
		timer--
		updateUsrDialog()
	if(reagenttimer > 0)
		reagenttimer--
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!reagenttimer && !drained)
		poolreagent()

/obj/machinery/poolcontroller/proc/updatePool()
	if(!drained)
		for(var/X in linkedturfs) //Check for pool-turfs linked to the controller.
			var/turf/open/pool/W = X
			for(var/mob/living/M in W) //Check for mobs in the linked pool-turfs.
				switch(temperature) //Apply different effects based on what the temperature is set to.
					if(SCALDING) //Scalding
						M.adjust_bodytemperature(50,0,500)
						to_chat(M, "<span class='danger'>The water is searing!</span>")
					if(WARM) //Warm
						M.adjust_bodytemperature(20,0,360) //Heats up mobs till the termometer shows up
					if(NORMAL) //Normal temp does nothing, because it's just room temperature water.
						if(iscarbon(M))
							var/mob/living/carbon/C = M
							C.adjust_bodytemperature(C.natural_bodytemperature_stabilization())
					if(COOL)
						M.adjust_bodytemperature(-20,250) //Cools mobs till the termometer shows up
					if(FRIGID) //Freezing
						M.adjust_bodytemperature(-60) //cool mob at -35k per cycle, less would not affect the mob enough.
						to_chat(M, "<span class='warning'>The water is is freezing!</span>")
						if(M.bodytemperature <= 50 && !M.stat)
							M.apply_status_effect(/datum/status_effect/freon)
				var/mob/living/carbon/human/drownee = M
				if(drownee.stat == DEAD)
					continue
				if(drownee && !(drownee.mobility_flags & MOBILITY_STAND) && !drownee.internal)
					if(drownee.stat != CONSCIOUS)
						M.adjustOxyLoss(9)
						to_chat(drownee, "<span class='danger'>You're quickly drowning!</span>")
					else
						if(!drownee.internal)
							M.adjustOxyLoss(4)
							if(prob(35))
								to_chat(drownee, "<span class='danger'>You're lacking air!</span>")

			for(var/obj/effect/decal/cleanable/decal in W)
				CHECK_TICK
				animate(decal, alpha = 10, time = 20)
				QDEL_IN(decal, 25)
				if(istype(decal,/obj/effect/decal/cleanable/blood) || istype(decal, /obj/effect/decal/cleanable/trail_holder))
					bloody = TRUE
	changecolor()

/obj/machinery/poolcontroller/proc/changecolor()
	if(drained)
		return
	var/rcolor
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		rcolor = mix_color_from_reagents(beaker.reagents.reagent_list)
	if(rcolor == old_rcolor)
		return // small performance upgrade hopefully?
	old_rcolor = rcolor
	for(var/X in linkedturfs)
		var/turf/open/pool/color1 = X
		if(bloody)
			if(rcolor)
				color1.watereffect.color = BlendRGB(rgb(150, 20, 20), rcolor, 0.5)
				color1.watertop.color = color1.watereffect.color
			else
				color1.watereffect.color = rgb(150, 20, 20)
				color1.watertop.color = color1.watereffect.color
		else if(!bloody && rcolor)
			color1.watereffect.color = rcolor
			color1.watertop.color = color1.watereffect.color
		else
			color1.watereffect.color = null
			color1.watertop.color = null

/obj/machinery/poolcontroller/proc/miston() //Spawn /obj/effect/mist (from the shower) on all linked pool tiles
	for(var/X in linkedturfs)
		var/turf/open/pool/W = X
		if(W.filled)
			var/M = new /obj/effect/mist(W)
			if(misted)
				return
			linkedmist += M
	misted = TRUE //var just to keep track of when the mist on proc has been called.

/obj/machinery/poolcontroller/proc/mistoff() //Delete all /obj/effect/mist from all linked pool tiles.
	for(var/M in linkedmist)
		qdel(M)
	misted = FALSE //no mist left, turn off the tracking var

/obj/machinery/poolcontroller/proc/handle_temp()
	timer = 10
	mistoff()
	icon_state = "poolc_[temperature]"
	if(temperature == SCALDING)
		miston()
	update_icon()

/obj/machinery/poolcontroller/proc/CanUpTemp(mob/user)
	if(temperature == WARM && (tempunlocked || issilicon(user) || isAdminGhostAI(user)) || temperature < WARM)
		return TRUE
	return FALSE

/obj/machinery/poolcontroller/proc/CanDownTemp(mob/user)
	if(temperature == COOL && (tempunlocked || issilicon(user) || isAdminGhostAI(user)) || temperature > COOL)
		return TRUE
	return FALSE

/obj/machinery/poolcontroller/proc/removeBeaker()
	var/obj/item/reagent_containers/glass/B = beaker
	if(QDELETED(B))
		return
	B.forceMove(loc)
	beaker = null
	cur_reagent = initial(cur_reagent)
	changecolor()

/obj/machinery/poolcontroller/proc/ToggleDrain(mob/user)
	if(isDrainable(user) && !linkeddrain.active)
		handle_temp()
		timer = 15
		linkeddrain.active = TRUE
		linkeddrain.timer = 15
		if(!linkeddrain.status)
			new /obj/effect/whirlpool(linkeddrain.loc)
			temperature = NORMAL
		else
			new /obj/effect/effect/waterspout(linkeddrain.loc)
			temperature = NORMAL
		bloody = FALSE

/obj/machinery/poolcontroller/proc/isDrainable(mob/user)
	return (drainable || issilicon(user) || isAdminGhostAI(user))

/obj/machinery/poolcontroller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PoolController", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/poolcontroller/ui_data(mob/user)
	. = list()
	.["timer"] = timer
	.["temperature"] = temperature
	.["drainable"] = isDrainable(user)
	.["poolstatus"] = drained
	.["reagent"] = cur_reagent
	.["hasBeaker"] = beaker


/obj/machinery/poolcontroller/ui_act(action, params)
	if(..())
		return
	if(timer)
		return
	switch(action)
		if("toggle_drain")
			ToggleDrain(usr)
			. = TRUE

		if("remove_beaker")
			removeBeaker()
			. = TRUE

		if("lower_temp")
			if(CanDownTemp(usr))
				temperature--
				handle_temp()
				. = TRUE

		if("raise_temp")
			if(CanUpTemp(usr))
				temperature++
				handle_temp()
				. = TRUE

/obj/machinery/poolcontroller/proc/reset(wire)
	switch(wire)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
