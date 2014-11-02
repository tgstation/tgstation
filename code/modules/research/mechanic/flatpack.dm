/obj/structure/closet/crate/flatpack
	name = "flatpack"
	desc = "A ready-to-assemble machine flatpack produced in the space-Swedish style.<br>Crowbar the flatpack open and follow the obtuse instructions to make the resulting machine."
	icon = 'icons/obj/machines/flatpack.dmi'
	icon_state = "flatpack"
	density = 1
	anchored = 0
	var/obj/machinery/machine = null

/obj/structure/closet/crate/flatpack/New()
	..()
	icon_state = "flatpack" //it gets changed in the crate code, so we reset it here

/obj/structure/closet/crate/flatpack/attackby(var/atom/A, mob/user)
	if(istype(A, /obj/item/weapon/crowbar))
		user <<"<span class='notice'>You begin to open the flatpack...</span>"
		if(do_after(user, 40))
			if(machine)
				user <<"<span class='notice'>\icon [src]You successfully unpack \the [src]!</span>"
				machine.loc = get_turf(src)
				machine.RefreshParts()
			else
				user <<"<span class='notice'>\icon [src]It seems this [src] was empty...</span>"
			for(var/atom/movable/AM in src)
				AM.loc = get_turf(src)
			qdel(src)
			return 1
		return

/obj/structure/closet/crate/flatpack/attack_hand()
	return