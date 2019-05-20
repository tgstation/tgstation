//Originally stolen from paradise. Credits to tigercat2000.
//Modified a lot by Kokojo and Tortellini Tony for hippiestation.
//Heavily refactored by tgstation
/obj/machinery/pool
	icon = 'icons/obj/machines/pool.dmi'
	anchored = TRUE

/obj/machinery/pool/controller
	name = "\improper Pool Controller"
	desc = "An advanced substance generation and fluid tank management system that can refill the contents of a pool to a completely different substance in minutes."
	icon_state = "poolc_3"
	density = TRUE
	use_power = TRUE
	idle_power_usage = 75
	var/list/linkedturfs //List contains all of the linked pool turfs to this controller, assignment happens on initialize
	var/list/mobs_in_pool = list()//List contains all the mobs currently in the pool.
	var/temperature = POOL_NORMAL //1-5 Frigid Cool Normal Warm Scalding
	var/srange = 6 //The range of the search for pool turfs, change this for bigger or smaller pools.
	var/list/linkedmist = list() //Used to keep track of created mist
	var/misted = FALSE //Used to check for mist.
	var/cur_reagent = "water"
	var/drainable = FALSE
	var/drained = FALSE
	var/bloody = 0
	var/obj/machinery/pool/drain/linked_drain = null
	var/obj/machinery/pool/filter/linked_filter = null
	var/interact_delay = 0 //cooldown on messing with settings
	var/reagent_delay = 0 //cooldown on reagent ticking
	var/shocked = FALSE//Shocks morons, like an airlock.
	var/tempunlocked = FALSE
	var/old_rcolor

/obj/machinery/pool/controller/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	create_reagents(100)
	wires = new /datum/wires/poolcontroller(src)
	scan_things()

/obj/machinery/pool/controller/proc/scan_things()
	for(var/turf/open/pool/W in range(srange,src))
		LAZYADD(linkedturfs, W)
		W.controller = src
	for(var/obj/machinery/pool/drain/pooldrain in range(srange,src))
		linked_drain = pooldrain
		linked_drain.pool_controller = src
	for(var/obj/machinery/pool/filter/F in range(srange, src))			
		linked_filter = F
		linked_filter.pool_controller = src

/obj/machinery/pool/controller/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	linked_drain = null
	linked_filter = null
	linkedturfs.Cut()
	mobs_in_pool.Cut()
	return ..()

/obj/machinery/pool/controller/emag_act(user as mob) //Emag_act, this is called when it is hit with a cryptographic sequencer.
	if(!(obj_flags & EMAGGED)) //If it is not already emagged, emag it.
		to_chat(user, "<span class='warning'>You disable the [src]'s safety features.</span>")
		do_sparks(5, TRUE, src)
		obj_flags |= EMAGGED
		tempunlocked = TRUE
		drainable = TRUE
		log_game("[key_name(user)] emagged [src]")
		message_admins("[key_name_admin(user)] emagged [src]")
	else
		to_chat(user, "<span class='warning'>The interface on [src] is already too damaged to short it again.</span>")
		return

/obj/machinery/pool/controller/attackby(obj/item/W, mob/user)
	if(shocked && !(stat & NOPOWER))
		shock(user,50)
	if(stat & (BROKEN))
		return

	if(istype(W,/obj/item/reagent_containers))
		if(W.reagents.total_volume >= 100) //check if there's enough reagent
			for(var/datum/reagent/R in W.reagents.reagent_list)
				if(R.id in GLOB.blacklisted_pool_reagents)
					to_chat(user, "\The [src] cannot accept [R.name].")
					reagents.clear_reagents()
					return
				if(R.reagent_state == SOLID)
					to_chat(user, "The pool cannot accept reagents in solid form!.")
					reagents.clear_reagents()
					return
			reagents.clear_reagents()
			W.reagents.copy_to(reagents, 100)
			W.reagents.clear_reagents()
			user.visible_message("<span class='notice'>\The [src] makes a slurping noise.</span>", "<span class='notice'>All of the contents of \the [W] are quickly suctioned out by the machine!</span")
			updateUsrDialog()
			var/reagent_names = ""
			for(var/datum/reagent/R in reagents.reagent_list)
				reagent_names += "[R.name], "
			log_game("[key_name(user)] has changed the [src] chems to [reagent_names]")
			message_admins("[key_name_admin(user)] has changed the [src] chems to [reagent_names].")
			interact_delay = world.time + 15
		else
			to_chat(user, "<span class='notice'>\The [src] beeps unpleasantly as it rejects the beaker. It must not have enough in it.</span>")
			return
	else if(panel_open && is_wire_tool(W))
		wires.interact(user)
	else
		return ..()

/obj/machinery/pool/controller/screwdriver_act(mob/living/user, obj/item/W)
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
/obj/machinery/pool/controller/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
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

/obj/machinery/pool/controller/proc/poolreagent()
	if(reagents.reagent_list.len > 0)
		for(var/turf/open/pool/W in linkedturfs)
			for(var/mob/living/carbon/human/swimee in W)
				for(var/datum/reagent/R in reagents.reagent_list)
					if(R.reagent_state == SOLID)
						R.reagent_state = LIQUID
					swimee.reagents.add_reagent(R.id, 0.5) //osmosis
				reagents.reaction(swimee, VAPOR, 0.03) //3 percent
			for(var/obj/objects in W)
				if(W.reagents)
					W.reagents.reaction(objects, VAPOR, 1)
	reagent_delay = world.time + POOL_REAGENT_TICK_INTERVAL
	changecolor()


/obj/machinery/pool/controller/process()
	updateUsrDialog()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!drained)
		updatePool()
		if(reagent_delay <= world.time)
			poolreagent()

/obj/machinery/pool/controller/proc/updatePool()
	if(!drained)
		for(var/mob/living/M in mobs_in_pool)
			switch(temperature) //Apply different effects based on what the temperature is set to.
				if(POOL_SCALDING) //Scalding
					M.adjust_bodytemperature(50,0,500)
				if(POOL_WARM) //Warm
					M.adjust_bodytemperature(20,0,360) //Heats up mobs till the termometer shows up
				if(POOL_NORMAL) //Normal temp does nothing, because it's just room temperature water.
				if(POOL_COOL)
					M.adjust_bodytemperature(-20,250) //Cools mobs till the termometer shows up
				if(POOL_FRIGID) //Freezing
					M.adjust_bodytemperature(-60) //cool mob at -35k per cycle, less would not affect the mob enough.
					if(M.bodytemperature <= 50 && !M.stat)
						M.apply_status_effect(/datum/status_effect/freon)
			if(ishuman(M))
				var/mob/living/carbon/human/drownee = M
				if(!drownee || drownee.stat == DEAD)
					return
				if(drownee.lying && !drownee.internal)
					if(drownee.stat != CONSCIOUS)
						drownee.adjustOxyLoss(9)
					else
						drownee.adjustOxyLoss(4)
						if(prob(35))
							to_chat(drownee, "<span class='danger'>You're drowning!</span>")

/* not sure what to do about this part
			for(var/obj/effect/decal/cleanable/decal in W)
				CHECK_TICK
				animate(decal, alpha = 10, time = 20)
				QDEL_IN(decal, 25)
				if(istype(decal,/obj/effect/decal/cleanable/blood) || istype(decal, /obj/effect/decal/cleanable/trail_holder))
					bloody = TRUE
					*/
	changecolor()

/obj/machinery/pool/controller/proc/changecolor()
	if(drained)
		return
	var/rcolor
	if(reagents.reagent_list.len)
		rcolor = mix_color_from_reagents(reagents.reagent_list)
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

/obj/machinery/pool/controller/proc/miston() //Spawn /obj/effect/mist (from the shower) on all linked pool tiles
	for(var/X in linkedturfs)
		var/turf/open/pool/W = X
		if(W.filled)
			var/M = new /obj/effect/mist(W)
			if(misted)
				return
			linkedmist += M
	misted = TRUE //var just to keep track of when the mist on proc has been called.

/obj/machinery/pool/controller/proc/mistoff() //Delete all /obj/effect/mist from all linked pool tiles.
	for(var/M in linkedmist)
		qdel(M)
	misted = FALSE //no mist left, turn off the tracking var

/obj/machinery/pool/controller/proc/handle_temp()
	interact_delay = world.time + 10
	mistoff()
	icon_state = "poolc_[temperature]"
	if(temperature == POOL_SCALDING)
		miston()
	update_icon()

/obj/machinery/pool/controller/proc/CanUpTemp(mob/user)
	if(temperature == POOL_WARM && (tempunlocked || issilicon(user) || IsAdminGhost(user)) || temperature < POOL_WARM)
		return TRUE
	return FALSE

/obj/machinery/pool/controller/proc/CanDownTemp(mob/user)
	if(temperature == POOL_COOL && (tempunlocked || issilicon(user) || IsAdminGhost(user)) || temperature > POOL_COOL)
		return TRUE
	return FALSE

/obj/machinery/pool/controller/Topic(href, href_list)
	if(..())
		return
	if(interact_delay > world.time)
		return
	if(href_list["IncreaseTemp"])
		if(CanUpTemp(usr))
			temperature++
			handle_temp()
	if(href_list["DecreaseTemp"])
		if(CanDownTemp(usr))
			temperature--
			handle_temp()
	if(href_list["Activate Drain"])
		if((drainable || issilicon(usr) || IsAdminGhost(usr)) && !linked_drain.active)
			mistoff()
			interact_delay = world.time + 60
			linked_drain.active = TRUE
			linked_drain.timer = 15
			if(!linked_drain.status)
				new /obj/effect/whirlpool(linked_drain.loc)
				temperature = POOL_NORMAL
			else
				new /obj/effect/waterspout(linked_drain.loc)
				temperature = POOL_NORMAL
			handle_temp()
			bloody = FALSE
	updateUsrDialog()

/obj/machinery/pool/controller/proc/temp2text()
	switch(temperature)
		if(POOL_FRIGID)
			return "<span class='bad'>Frigid</span>"
		if(POOL_COOL)
			return "<span class='good'>Cool</span>"
		if(POOL_NORMAL)
			return "<span class='good'>Normal</span>"
		if(POOL_WARM)
			return "<span class='good'>Warm</span>"
		if(POOL_SCALDING)
			return "<span class='bad'>Scalding</span>"
		else
			return "Outside of possible range."

/obj/machinery/pool/controller/ui_interact(mob/user)
	. = ..()
	if(.)
		return
	if(shocked && !(stat & NOPOWER))
		shock(user,50)
	if(panel_open && !isAI(user))
		return wires.interact(user)
	if(stat & (NOPOWER|BROKEN))
		return
	var/datum/browser/popup = new(user, "Pool Controller", name, 300, 450)
	var/dat = ""
	if(interact_delay > world.time)
		dat += "<span class='notice'>[(interact_delay - world.time)] seconds left until [src] can operate again.</span><BR>"
	dat += text({"
		<h3>Temperature</h3>
		<div class='statusDisplay'>
		<B>Current temperature:</B> [temp2text()]<BR>
		[CanUpTemp(user) ? "<a href='?src=\ref[src];IncreaseTemp=1'>Increase Temperature</a><br>" : "<span class='linkOff'>Increase Temperature</span><br>"]
		[CanDownTemp(user) ? "<a href='?src=\ref[src];DecreaseTemp=1'>Decrease Temperature</a><br>" : "<span class='linkOff'>Decrease Temperature</span><br>"]
		</div>
		<h3>Drain</h3>
		<div class='statusDisplay'>
		<B>Drain status:</B> [(issilicon(user) || IsAdminGhost(user) || drainable) ? "<span class='bad'>Enabled</span>" : "<span class='good'>Disabled</span>"]
		<br><b>Pool status:</b> "})
	if(!drained)
		dat += "<span class='good'>Full</span><BR>"
	else
		dat += "<span class='bad'>Drained</span><BR>"
	if((issilicon(user) || IsAdminGhost(user) || drainable) && !linked_drain.active)
		dat += "<a href='?src=\ref[src];Activate Drain=1'>[drained ? "Fill" : "Drain"] Pool</a><br>"
	popup.set_content(dat)
	popup.open()

/obj/machinery/pool/controller/proc/reset(wire)
	switch(wire)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
