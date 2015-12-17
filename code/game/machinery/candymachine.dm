//Candy Machine shamelessly created by ripping apart the gashapon machine and frankensteining together this horrifying new creation.


/obj/machinery/sweet
	name = "\improper Sweet Machine"
	desc = "Insert coin, recieve a sweet!"
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "sweetmachine"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK | EMAGGABLE
	emag_cost = 0
	emagged = 0

/obj/machinery/sweet/attackby(var/obj/O as obj, var/mob/user as mob)
	if (stat & (NOPOWER|BROKEN))
		return ..()
	if (is_type_in_list(O, list(/obj/item/weapon/coin/, /obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin)))
		if(emagged == 1)
			user.drop_item(O, src)
			user.visible_message("<span class='notice'>[user] puts a coin into [src] and turns the knob.", "You put a coin into [src] and turn the knob.</span>")
			src.visible_message("<span class='notice'>[src] rattles ominously!</span>")
			sleep(rand(10,15))
			src.visible_message("<span class='notice'>[src] dispenses a strange sweet!</span>")
			new /obj/item/weapon/reagent_containers/food/snacks/sweet/strange(src.loc)
			qdel(O)
		else
			user.drop_item(O, src)
			user.visible_message("<span class='notice'>[user] puts a coin into [src] and turns the knob.", "<span class='notice'>You put a coin into [src] and turn the knob.</span>")
			src.visible_message("<span class='notice'>[src] clicks softly.</span>")
			sleep(rand(10,15))
			src.visible_message("<span class='notice'>[src] dispenses a sweet!</span>")
			new /obj/item/weapon/reagent_containers/food/snacks/sweet(src.loc)
			qdel(O)
	else
		return ..()

/obj/machinery/sweet/emag(mob/user)
	if(emagged == 0)
		user.simple_message("<span class='warning'>You inexplicably short out the [src.name].</span>")
		emagged = 1
	return
