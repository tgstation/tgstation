/obj/item/weapon/pai_cable/proc/plugin(obj/machinery/M as obj, mob/user as mob)
	if(istype(M, /obj/machinery/door) || istype(M, /obj/machinery/camera))
		user.visible_message("[user] inserts [src] into a data port on [M].", "<span class='notice'>You insert [src] into a data port on [M].</span>", "<span class='italics'>You hear the satisfying click of a wire jack fastening into place.</span>")
		user.drop_item()
		src.loc = M
		src.machine = M
	else
		user.visible_message("[user] dumbly fumbles to find a place on [M] to plug in [src].", "<span class='warning'>There aren't any ports on [M] that match the jack belonging to [src]!</span>")

/obj/item/weapon/pai_cable/attack(obj/machinery/M as obj, mob/user as mob)
	src.plugin(M, user)