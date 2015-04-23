
var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber)

//VENTCRAWLING

/mob/living/proc/handle_ventcrawl(var/atom/A)
	if(!ventcrawler || !Adjacent(A))
		return
	if(stat)
		src << "You must be conscious to do this!"
		return
	if(lying)
		src << "You can't vent crawl while you're stunned!"
		return

	var/obj/machinery/atmospherics/unary/vent_found


	if(A)
		vent_found = A
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
		if(vent_found.parent && (vent_found.parent.members.len || vent_found.parent.other_atmosmch))
			visible_message("<span class='notice'>[src] begins climbing into the ventilation system...</span>" ,"<span class='notice'>You begin climbing into the ventilation system...</span>")

			if(!do_after(src, 25))
				return

			if(!client)
				return

			if(iscarbon(src) && contents.len && ventcrawler < 2)//It must have atleast been 1 to get this far
				for(var/obj/item/I in contents)
					var/failed = 0
					if(istype(I, /obj/item/weapon/implant))
						continue
					else
						failed++

					if(failed)
						src << "<span class='warning'>You can't crawl around in the ventilation ducts with items!</span>"
						return

			visible_message("<span class='notice'>[src] scrambles into the ventilation ducts!</span>","<span class='notice'>You climb into the ventilation ducts.</span>")
			loc = vent_found
			add_ventcrawl(vent_found)
	else
		src << "<span class='warning'>This ventilation duct is not connected to anything!</span>"


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/unary/starting_machine)
	if(!starting_machine)
		return
	var/list/totalMembers = starting_machine.parent.members + starting_machine.parent.other_atmosmch
	for(var/atom/A in totalMembers)
		var/image/new_image = image(A, A.loc, dir = A.dir)
		pipes_shown += new_image
		if(client)
			client.images += new_image


/mob/living/proc/remove_ventcrawl()
	for(var/image/current_image in pipes_shown)
		client.images -= current_image

	pipes_shown.len = 0

	if(client)
		client.eye = src



//OOP
/atom/proc/update_pipe_vision()
	return

/mob/living/update_pipe_vision()
	if(pipes_shown.len)
		if(!istype(loc, /obj/machinery/atmospherics))
			remove_ventcrawl()
	else
		if(istype(loc, /obj/machinery/atmospherics))
			add_ventcrawl(loc)
