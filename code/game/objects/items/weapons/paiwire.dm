<<<<<<< HEAD
/obj/item/weapon/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	flags = NOBLUDGEON
	var/obj/machinery/machine

/obj/item/weapon/pai_cable/proc/plugin(obj/machinery/M, mob/living/user)
	if(!user.drop_item())
		return
	user.visible_message("[user] inserts [src] into a data port on [M].", "<span class='notice'>You insert [src] into a data port on [M].</span>", "<span class='italics'>You hear the satisfying click of a wire jack fastening into place.</span>")
	src.loc = M
	machine = M
=======
/obj/item/weapon/pai_cable/proc/plugin(obj/machinery/M as obj, mob/user as mob)
	if(istype(M, /obj/machinery/door) || istype(M, /obj/machinery/camera))
		user.visible_message("[user] inserts [src] into a data port on [M].", "You insert [src] into a data port on [M].", "You hear the satisfying click of a wire jack fastening into place.")
		if(user && user.get_active_hand() == src)
			user.drop_item(src, M, force_drop = 1)
		src.machine = M
	else
		user.visible_message("[user] dumbly fumbles to find a place on [M] to plug in [src].", "There aren't any ports on [M] that match the jack belonging to [src].")

/obj/item/weapon/pai_cable/attack(obj/machinery/M as obj, mob/user as mob)
	src.plugin(M, user)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
