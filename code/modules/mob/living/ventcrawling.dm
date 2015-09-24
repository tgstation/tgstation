
var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/components/unary/vent_pump, /obj/machinery/atmospherics/components/unary/vent_scrubber)

//VENTCRAWLING

/mob/living/proc/handle_ventcrawl(atom/A)
	if(!ventcrawler || !Adjacent(A))
		return
	if(stat)
		src << "You must be conscious to do this!"
		return
	if(lying)
		src << "You can't vent crawl while you're stunned!"
		return
	if(restrained())
		src << "You can't vent crawl while you're restrained!"
		return

	var/obj/machinery/atmospherics/components/unary/vent_found


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
		var/datum/pipeline/vent_found_parent = vent_found.PARENT1
		if(vent_found_parent && (vent_found_parent.members.len || vent_found_parent.other_atmosmch))
			visible_message("<span class='notice'>[src] begins climbing into the ventilation system...</span>" ,"<span class='notice'>You begin climbing into the ventilation system...</span>")

			if(!do_after(src, 25, target = vent_found))
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


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/components/unary/starting_machine)
	if(!istype(starting_machine) || !starting_machine.returnPipenet())
		return
	var/list/totalMembers = list()
	var/datum/pipeline/starting_machine_parent = starting_machine.PARENT1
	totalMembers += starting_machine_parent.members
	totalMembers += starting_machine_parent.other_atmosmch

	for(var/obj/machinery/atmospherics/A in totalMembers)
		if(!A.pipe_vision_img)
			A.pipe_vision_img = image(A, A.loc, layer = 20, dir = A.dir)
			//20 for being above darkness
		pipes_shown += A.pipe_vision_img
		if(client)
			client.images += A.pipe_vision_img


/mob/living/proc/remove_ventcrawl()
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		client.eye = src
	pipes_shown.len = 0




//OOP
/atom/proc/update_pipe_vision(atom/new_loc = null)
	return

/mob/living/update_pipe_vision(atom/new_loc = null)
	. = loc
	if(new_loc)
		. = new_loc
	remove_ventcrawl()
	add_ventcrawl(.)

