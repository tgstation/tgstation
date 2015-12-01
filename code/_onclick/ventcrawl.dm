var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber, /obj/machinery/atmospherics/unary/vent)

/mob/living/proc/can_ventcrawl()
	return 0

/mob/living/proc/ventcrawl_carry()
	for(var/atom/A in src.contents)
		if(!(isInTypes(A, canEnterVentWith)))
			to_chat(src, "<SPAN CLASS='warning'>You can't be carrying items or have items equipped when vent crawling!</SPAN>")
			return 0
	return 1

// Vent crawling whitelisted items, whoo
/mob/living
	var/canEnterVentWith = "/obj/item/weapon/implant=0&/obj/item/clothing/mask/facehugger=0&/obj/item/device/radio/borg=0&/obj/machinery/camera=0"

/mob/living/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery) && src.can_ventcrawl())
		src.handle_ventcrawl(A)
		return 1
	return ..()

/mob/living/carbon/human/can_ventcrawl()
	return istype(w_uniform,/obj/item/clothing/under/contortionist)

/mob/living/carbon/human/ventcrawl_carry()
	if(istype(w_uniform,/obj/item/clothing/under/contortionist))
		var/obj/item/clothing/under/contortionist/C = w_uniform
		return C.check_clothing(src)
	return 1

/obj/item/clothing/under/contortionist/verb/crawl_through_vent()
	set name = "Crawl Through Vent"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/user = usr
	if(istype(user) && user.w_uniform == src && check_clothing(user))
		var/pipe = user.start_ventcrawl()
		if(pipe)
			user.handle_ventcrawl(pipe)

/mob/proc/start_ventcrawl()
	var/atom/pipe
	var/list/pipes = list()
	for(var/obj/machinery/atmospherics/unary/U in range(1))
		if(is_type_in_list(U,ventcrawl_machinery) && Adjacent(U))
			pipes |= U
	if(!pipes || !pipes.len)
		to_chat(src, "There are no pipes that you can ventcrawl into within range!")
		return
	if(pipes.len == 1)
		pipe = pipes[1]
	else
		pipe = input("Crawl Through Vent", "Pick a pipe") as null|anything in pipes
	if(canmove && pipe)
		return pipe

/mob/living/carbon/slime/can_ventcrawl()
	return 1

/mob/living/carbon/monkey/can_ventcrawl()
	return 1

/mob/living/silicon/robot/mommi/can_ventcrawl()
	return 1

/mob/living/silicon/robot/mommi/ventcrawl_carry()
	return 1

/mob/living/simple_animal/borer/can_ventcrawl()
	return 1

/mob/living/simple_animal/mouse/can_ventcrawl()
	return 1

/mob/living/simple_animal/spiderbot/can_ventcrawl()
	return 1

/mob/living/carbon/alien/can_ventcrawl()
	return 1

/mob/living/carbon/alien/ventcrawl_carry()
	return 1

/mob/living/carbon/alien/humanoid/queen/can_ventcrawl()
	return 0


/mob/living/var/ventcrawl_layer = PIPING_LAYER_DEFAULT

/mob/living/proc/handle_ventcrawl(var/atom/clicked_on)
	diary << "[src] is ventcrawling."
	if(!stat)
		if(!lying)

/*
			if(clicked_on)
				to_chat(world, "We start with [clicked_on], and [clicked_on.type]")
*/
			var/obj/machinery/atmospherics/unary/vent_found

			if(clicked_on && Adjacent(clicked_on))
				vent_found = clicked_on
				if(!istype(vent_found) || !vent_found.can_crawl_through())
					vent_found = null


			if(!vent_found)
				for(var/obj/machinery/atmospherics/machine in range(1,src))
					if(is_type_in_list(machine, ventcrawl_machinery))
						vent_found = machine

					if(!vent_found.can_crawl_through())
						vent_found = null

					if(vent_found)
						break

			if(vent_found)
				if(vent_found.network && (vent_found.network.normal_members.len || vent_found.network.line_members.len))

					to_chat(src, "You begin climbing into the ventilation system...")
					if(vent_found.air_contents && !issilicon(src))

						switch(vent_found.air_contents.temperature)
							if(0 to BODYTEMP_COLD_DAMAGE_LIMIT)
								to_chat(src, "<span class='danger'>You feel a painful freeze coming from the vent!</span>")
							if(BODYTEMP_COLD_DAMAGE_LIMIT to T0C)
								to_chat(src, "<span class='warning'>You feel an icy chill coming from the vent.</span>")
							if(T0C + 40 to BODYTEMP_HEAT_DAMAGE_LIMIT)
								to_chat(src, "<span class='warning'>You feel a hot wash coming from the vent.</span>")
							if(BODYTEMP_HEAT_DAMAGE_LIMIT to INFINITY)
								to_chat(src, "<span class='danger'>You feel a searing heat coming from the vent!</span>")

						switch(vent_found.air_contents.pressure)
							if(0 to HAZARD_LOW_PRESSURE)
								to_chat(src, "<span class='danger'>You feel a rushing draw pulling you into the vent!</span>")
							if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
								to_chat(src, "<span class='warning'>You feel a strong drag pulling you into the vent.</span>")
							if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
								to_chat(src, "<span class='warning'>You feel a strong current pushing you away from the vent.</span>")
							if(HAZARD_HIGH_PRESSURE to INFINITY)
								to_chat(src, "<span class='danger'>You feel a roaring wind pushing you away from the vent!</span>")

					if(!do_after(src,vent_found, 45,,0))
						return

					if(!client)
						return

					if(!ventcrawl_carry())
						return

					visible_message("<B>[src] scrambles into the ventilation ducts!</B>", "You climb into the ventilation system.")

					forceMove(vent_found)
					add_ventcrawl(vent_found)

				else
					to_chat(src, "This vent is not connected to anything.")

			else
				to_chat(src, "You must be standing on or beside an air vent to enter it.")

		else
			to_chat(src, "You can't vent crawl while you're stunned!")

	else
		to_chat(src, "You must be conscious to do this!")
	return

/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	is_ventcrawling = 1
	candrop = 0
	var/datum/pipe_network/network = starting_machine.return_network(starting_machine)
	if(!network)
		return
	for(var/datum/pipeline/pipeline in network.line_members)
		for(var/obj/machinery/atmospherics/A in (pipeline.members || pipeline.edges))
			if(!A.pipe_image)
				A.pipe_image = image(A, A.loc, layer = 20, dir = A.dir) //the 20 puts it above Byond's darkness (not its opacity view)
			pipes_shown += A.pipe_image
			client.images += A.pipe_image

/mob/living/proc/remove_ventcrawl()
	is_ventcrawling = 0
	candrop = 1
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		client.eye = src

	pipes_shown.len = 0
