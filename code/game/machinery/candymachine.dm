//Candy Machine shamelessly created by ripping apart the gashapon machine and frankensteining together this horrifying new creation.


/obj/machinery/sweet
	name = "\improper Sweet Machine"
	desc = "Insert coin, recieve a sweet!"
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "sweetmachine"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/sweet/attackby(var/obj/O as obj, var/mob/user as mob)
	if (stat & (NOPOWER|BROKEN))
		return ..()
	if (istype(O, /obj/item/weapon/coin/))
		user.drop_item(O, src)
		user.visible_message("[user] puts a coin into [src] and turns the knob.", "You put a coin into [src] and turn the knob.")
		src.visible_message("[src] clicks softly.")
		sleep(rand(10,15))
		src.visible_message("[src] dispenses a sweet!")
		new /obj/item/weapon/reagent_containers/food/snacks/sweet(src.loc)
		qdel(O)
	else
		return ..()