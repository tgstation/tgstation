///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/decal/mecha_wreckage
	name = "Exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Completely unrepairable."
	icon = 'mecha.dmi'
	density = 1
	anchored = 1
	opacity = 0
	var/list/welder_salvage = list("/obj/item/stack/sheet/r_metal","/obj/item/stack/sheet/metal","/obj/item/stack/rods")
	var/list/wirecutters_salvage = list("/obj/item/weapon/cable_coil")
	var/list/crowbar_salvage = list("/obj/item/weapon/cell")
	var/list/equipment = new
	var/salvage_num = 5
	var/list/salvage

	New()
		..()
		salvage = new
		return

/obj/decal/mecha_wreckage/ex_act(severity)
	if(severity < 3)
		spawn
			del src
	return

/obj/decal/mecha_wreckage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if(salvage_num <= 0)
			user << "You can't see anything of value left on this wreck."
			return
		if (W:remove_fuel(0,user))
			var/type = prob(70)?pick(welder_salvage):null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src]", "You cut [N] from [src]", "You hear a sound of welder nearby")
			else
				user << "You failed to salvage anything valuable from [src]."
			salvage_num--
		else
			user << "\blue You need more welding fuel to complete this task."
			return
	if(istype(W, /obj/item/weapon/wirecutters))
		if(salvage_num <= 0)
			user << "You can't see anything of value left on this wreck."
			return
		else
			var/type = prob(70)?pick(wirecutters_salvage):null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src].", "You cut [N] from [src].")
			else
				user << "You failed to salvage anything valuable from [src]."
			salvage_num--
	if(istype(W, /obj/item/weapon/crowbar))
		if(salvage.len)
			var/obj/S = pick(salvage)
			if(S)
				S.loc = get_turf(user)
				salvage -= S
				user.visible_message("[user] pries [S] from [src].", "You pry [S] from [src].")
			return
		if(salvage_num<=0)
			user << "You can't see anything of value left on this wreck."
			return
		else
			var/type = prob(70)?pick(crowbar_salvage):null
			if(type)
				var/N = new type(get_turf(user))
				if(istype(N, /obj/item/weapon/cell))
					N:maxcharge = rand(5000,12000)
					N:charge = 0
				user.visible_message("[user] pries [N] from [src].", "You pry [N] from [src].")
			else
				user << "You failed to salvage anything from [src]."
			salvage_num--
	else
		..()
	return


/obj/decal/mecha_wreckage/gygax
	name = "Gygax wreckage"
	icon_state = "gygax-broken"


/obj/decal/mecha_wreckage/marauder
	name = "Marauder wreckage"
	icon_state = "marauder-broken"


/obj/decal/mecha_wreckage/ripley
	name = "Ripley wreckage"
	icon_state = "ripley-broken"


/obj/decal/mecha_wreckage/durand
	name = "Durand wreckage"
	icon_state = "durand-broken"

/obj/decal/mecha_wreckage/phazon
	name = "Phazon wreckage"
	icon_state = "phazon-broken"
