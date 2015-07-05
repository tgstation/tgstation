/obj/item/device/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	flags = CONDUCT
	throwforce = 5
	w_class = 2.0
	throw_speed = 2
	throw_range = 7

	var/obj/item/device/assembly/a_left = null
	var/obj/item/device/assembly/a_right = null

/obj/item/device/assembly_holder/IsAssemblyHolder()
	return 1


/obj/item/device/assembly_holder/proc/assemble(var/obj/item/device/assembly/A, var/obj/item/device/assembly/A2, var/mob/user)
	attach(A,user)
	attach(A2,user)
	name = "[A.name]-[A2.name] assembly"
	update_icon()
	feedback_add_details("assembly_made","[name]")

/obj/item/device/assembly_holder/proc/attach(var/obj/item/device/assembly/A, var/mob/user)
	if(!A.remove_item_from_storage(src))
		if(user)
			user.remove_from_mob(A)
		A.loc = src
	A.holder = src
	A.toggle_secure()
	if(!a_left)
		a_left = A
	else
		a_right = A

/obj/item/device/assembly_holder/update_icon()
	overlays.Cut()
	if(a_left)
		overlays += "[a_left.icon_state]_left"
		for(var/O in a_left.attached_overlays)
			overlays += "[O]_l"
	if(a_right)
		src.overlays += "[a_right.icon_state]_right"
		for(var/O in a_right.attached_overlays)
			overlays += "[O]_r"
	if(master)
		master.update_icon()

/obj/item/device/assembly_holder/HasProximity(atom/movable/AM as mob|obj)
	if(a_left)
		a_left.HasProximity(AM)
	if(a_right)
		a_right.HasProximity(AM)


/obj/item/device/assembly_holder/Crossed(atom/movable/AM as mob|obj)
	if(a_left)
		a_left.Crossed(AM)
	if(a_right)
		a_right.Crossed(AM)

/obj/item/device/assembly_holder/on_found(mob/finder as mob)
	if(a_left)
		a_left.on_found(finder)
	if(a_right)
		a_right.on_found(finder)

/obj/item/device/assembly_holder/Move()
	..()
	if(a_left && a_right)
		a_left.holder_movement()
		a_right.holder_movement()
	return

/obj/item/device/assembly_holder/attack_hand()//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	if(a_left && a_right)
		a_left.holder_movement()
		a_right.holder_movement()
	..()
	return

/obj/item/device/assembly_holder/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		var/turf/T = get_turf(src)
		if(!T)
			return 0
		if(a_left)
			a_left.holder = null
			a_left.loc = T
		if(a_right)
			a_right.holder = null
			a_right.loc = T
		qdel(src)
	else
		..()

/obj/item/device/assembly_holder/attack_self(mob/user as mob)
	src.add_fingerprint(user)
	if(!a_left || !a_right)
		user << "<span class='danger'>Assembly part missing!</span>"
		return
	if(istype(a_left,a_right.type))//If they are the same type it causes issues due to window code
		switch(alert("Which side would you like to use?",,"Left","Right"))
			if("Left")	a_left.attack_self(user)
			if("Right")	a_right.attack_self(user)
		return
	else
		a_left.attack_self(user)
		a_right.attack_self(user)


/obj/item/device/assembly_holder/proc/process_activation(var/obj/D, var/normal = 1, var/special = 1)
	if(!D)
		return 0
	if((normal) && (a_right) && (a_left))
		if(a_right != D)
			a_right.pulsed(0)
		if(a_left != D)
			a_left.pulsed(0)
	if(master)
		master.receive_signal()
	return 1
