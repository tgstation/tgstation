//Bureaucracy machine!
//Simply set this up in the hopline and you can serve people based on ticket numbers

/obj/machinery/ticket_machine
	name = "ticket machine"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticketmachine"
	desc = "A marvel of bureaucratic engineering encased in an efficient plastic shell. It can be refilled with a hand labeler refill roll and linked to buttons with a multitool."
	density = FALSE
	maptext_height = 26
	maptext_width = 32
	maptext_x = 7
	maptext_y = 10
	layer = HIGH_OBJ_LAYER
	var/ticket_number = 0 //Increment the ticket number whenever the HOP presses his button
	var/current_number = 0 //What customer are we currently serving?
	var/max_number = 999 //To stop the text going fucky. At this point, you need to refill it.
	var/cooldown = 50 //Small cooldown, stops the clown from immediately breaking it.
	var/ready = TRUE
	var/id = "ticket_machine_default" //For buttons

/obj/machinery/ticket_machine/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I)) //make sure it has a data buffer
		return
	var/obj/item/multitool/M = I
	M.buffer = src
	to_chat(user, "<span class='notice'>You store linkage information in [I]'s buffer.</span>")
	return TRUE

/obj/machinery/ticket_machine/emag_act(mob/user) //Emag the ticket machine to dispense burning tickets, as well as randomize its customer number to destroy the HOP's mind.
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='warning'>You overload [src]'s bureaucratic logic circuitry to its MAXIMUM setting.</span>")
	ticket_number = rand(0,999)
	obj_flags |= EMAGGED

/obj/machinery/ticket_machine/Initialize()
	. = ..()
	update_icon()

/obj/machinery/ticket_machine/proc/increment()
	if(current_number >= ticket_number)
		return
	playsound(src, 'sound/misc/announce_dig.ogg', 50, 0)
	say("Next customer, please!")
	current_number ++ //Increment the one we're serving.
	update_icon() //Update our icon here rather than when they take a ticket to show the current ticket number being served

/obj/machinery/button/ticket_machine
	name = "increment ticket counter"
	desc = "Use this button when you've served a customer to tell the next one to come forward."
	device_type = /obj/item/assembly/control/ticket_machine
	req_access = list()
	id = "ticket_machine_default"

/obj/machinery/button/ticket_machine/Initialize()
	. = ..()
	if(device)
		var/obj/item/assembly/control/ticket_machine/ours = device
		ours.id = id

/obj/machinery/button/ticket_machine/multitool_act(mob/living/user, obj/item/I)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		var/obj/item/multitool/M = I
		if(M.buffer && !istype(M.buffer, /obj/machinery/ticket_machine))
			return
		var/obj/item/assembly/control/ticket_machine/controller = device
		controller.linked = M.buffer
		id = null
		controller.id = null
		to_chat(user, "<span class='warning'>You've linked [src] to [controller.linked].</span>")

/obj/item/assembly/control/ticket_machine
	name = "ticket machine controller"
	desc = "A remote controller for the HOP's ticket machine."
	var/obj/machinery/ticket_machine/linked //To whom are we linked?

/obj/item/assembly/control/ticket_machine/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/assembly/control/ticket_machine/LateInitialize()
	find_machine()

/obj/item/assembly/control/ticket_machine/proc/find_machine() //Locate the one to which we're linked
	for(var/obj/machinery/ticket_machine/ticketsplease in GLOB.machines)
		if(ticketsplease.id == id)
			linked = ticketsplease
	if(linked)
		return TRUE
	else
		return FALSE

/obj/item/assembly/control/ticket_machine/activate()
	if(cooldown)
		return
	if(!linked)
		return
	cooldown = TRUE
	linked.increment()
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 10)

/obj/machinery/ticket_machine/update_icon()
	switch(ticket_number) //Gives you an idea of how many tickets are left
		if(0 to 200)
			icon_state = "ticketmachine_100"
		if(201 to 800)
			icon_state = "ticketmachine_50"
		if(801 to 999)
			icon_state = "ticketmachine_0"
	handle_maptext()

/obj/machinery/ticket_machine/proc/handle_maptext()
	switch(ticket_number) //This is here to handle maptext offsets so that the numbers align.
		if(0 to 9)
			maptext_x = 13
		if(10 to 99)
			maptext_x = 10
		if(100 to 999)
			maptext_x = 8
	maptext = "[current_number]" //Finally, apply the maptext

/obj/machinery/ticket_machine/attackby(obj/item/I, mob/user, params)
	..()
	if(ticket_number >= max_number)
		to_chat(user, "<span class='notice'>[src] refuses [I]!, perhaps it's already full?.</span>")
		return
	if(istype(I, /obj/item/hand_labeler_refill))
		to_chat(user, "<span class='notice'>You start to refill [src]'s ticket holder (doing this will reset its ticket count!).</span>")
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>You insert [I] into [src] as it whirrs nondescriptly.</span>")
			qdel(I)
			ticket_number = 0
			current_number = 0
			max_number = initial(max_number)
			update_icon()
			return
	if(istype(I, /obj/item/ticket_machine_ticket))
		to_chat(user, "<span class='warning'>You start to cram [I] into [src]'s recycling bin.</span>")
		if(do_after(user, 20, target = src)) //Slight delay so they don't accidentally dispose of their ticket and move to the BACK OF THE LINE
			qdel(I)
			return

/obj/machinery/ticket_machine/proc/reset_cooldown()
	ready = TRUE

/obj/machinery/ticket_machine/attack_hand(mob/living/carbon/user)
	. = ..()
	if(!ready)
		to_chat(user,"Temporarily unable to dispense ticket, please be patient!")
		return
	if(ticket_number >= max_number)
		to_chat(user,"Ticket supply depleted, please refill this unit with a hand labeller refill cartridge!")
		return
	ready = FALSE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
	addtimer(CALLBACK(src, .proc/reset_cooldown), cooldown)//Small cooldown to prevent the clown from ripping out every ticket
	ticket_number ++
	to_chat(user, "<span class='notice'>You take a ticket from [src], looks like you're customer #[ticket_number]...</span>")
	var/obj/item/ticket_machine_ticket/theirticket = new /obj/item/ticket_machine_ticket(get_turf(src))
	theirticket.name = "Ticket #[ticket_number]"
	theirticket.maptext = "<font color='#000000'>[ticket_number]</font>"
	theirticket.saved_maptext = "<font color='#000000'>[ticket_number]</font>"
	user.put_in_hands(theirticket)
	if(obj_flags & EMAGGED) //Emag the machine to destroy the HOP's life.
		theirticket.fire_act()
		user.dropItemToGround(theirticket)
		user.adjust_fire_stacks(1)
		user.IgniteMob()
		return

/obj/item/ticket_machine_ticket
	name = "Ticket"
	desc = "A ticket which shows your place in the line, you can put it back into the ticket machine when youre done with it."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticket"
	maptext_x = 7
	maptext_y = 10
	w_class = WEIGHT_CLASS_TINY
	var/saved_maptext = null

/obj/item/ticket_machine_ticket/attack_hand(mob/user)
	. = ..()
	maptext = saved_maptext //For some reason, storage code removes all maptext off objs, this stops its number from being wiped off when taken out of storage.

/obj/item/ticket_machine_ticket/attackby(obj/item/P, mob/living/carbon/human/user, params) //Stolen from papercode
	..()
	if(P.is_hot())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
								"<span class='userdanger'>You miss the paper and accidentally light yourself on fire!</span>")
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()

/obj/item/ticket_machine_ticket/fire_act(exposed_temperature, exposed_volume)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		icon_state = "ticket_onfire"