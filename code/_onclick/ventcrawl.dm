var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber)

/mob/living/carbon/slime/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return
	..(A)

/mob/living/carbon/monkey/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return
	..(A)

/mob/living/silicon/robot/mommi/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return
	..(A)

/mob/living/simple_animal/borer/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return
	..(A)

/mob/living/simple_animal/mouse/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return
	..(A)

/mob/living/simple_animal/spiderbot/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return
	..(A)

/mob/living/carbon/alien/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return
	..(A)


/mob/living/proc/handle_ventcrawl(var/atom/clicked_on) // -- TLE -- Merged by Carn
	diary << "[src] is ventcrawling."
	if(!stat)
		if(!lying)

/*
			if(clicked_on)
				world << "We start with [clicked_on], and [clicked_on.type]"
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

					src << "You begin climbing into the ventilation system..."
					if(vent_found.air_contents && !issilicon(src))

						switch(vent_found.air_contents.temperature)
							if(0 to BODYTEMP_COLD_DAMAGE_LIMIT)
								src << "<span class='danger'>You feel a painful freeze coming from the vent!</span>"
							if(BODYTEMP_COLD_DAMAGE_LIMIT to T0C)
								src << "<span class='warning'>You feel an icy chill coming from the vent.</span>"
							if(T0C + 40 to BODYTEMP_HEAT_DAMAGE_LIMIT)
								src << "<span class='warning'>You feel a hot wash coming from the vent.</span>"
							if(BODYTEMP_HEAT_DAMAGE_LIMIT to INFINITY)
								src << "<span class='danger'>You feel a searing heat coming from the vent!</span>"

						switch(vent_found.air_contents.pressure)
							if(0 to HAZARD_LOW_PRESSURE)
								src << "<span class='danger'>You feel a rushing draw pulling you into the vent!</span>"
							if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
								src << "<span class='warning'>You feel a strong drag pulling you into the vent.</span>"
							if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
								src << "<span class='warning'>You feel a strong current pushing you away from the vent.</span>"
							if(HAZARD_HIGH_PRESSURE to INFINITY)
								src << "<span class='danger'>You feel a roaring wind pushing you away from the vent!</span>"

					if(!do_after(src, 45,,0))
						return

					if(!client)
						return

					if(contents.len && !isrobot(src))
						for(var/obj/item/carried_item in contents)//If the ventcrawler got on objects.
							if(!(isInTypes(carried_item, canEnterVentWith)))
								src << "<SPAN CLASS='warning'>You can't be carrying items or have items equipped when vent crawling!</SPAN>"
								return

					visible_message("<B>[src] scrambles into the ventilation ducts!</B>", "You climb into the ventilation system.")

					loc = vent_found
					add_ventcrawl(vent_found)

				else
					src << "This vent is not connected to anything."

			else
				src << "You must be standing on or beside an air vent to enter it."

		else
			src << "You can't vent crawl while you're stunned!"

	else
		src << "You must be conscious to do this!"
	return

/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
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
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		client.eye = src

	pipes_shown.len = 0
