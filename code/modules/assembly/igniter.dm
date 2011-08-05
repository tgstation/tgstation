/obj/item/device/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances. Does not function well as a lighter."
	icon = 'new_assemblies.dmi'
	icon_state = "igniter"
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 100
	throwforce = 5
	w_class = 1.0
	throw_speed = 3
	throw_range = 10

	var
		secured = 1
		small_icon_state_left = "igniter_left"
		small_icon_state_right = "igniter_right"
		list/small_icon_state_overlays = null
		obj/holder = null
		cooldown = 0

	proc
		Activate()//Called when this assembly is pulsed by another one
		Secure()
		Unsecure()
		Attach_Assembly(var/obj/A, var/mob/user)
		Process_cooldown()


	IsAssembly()
		return 1


	Process_cooldown()
		src.cooldown--
		if(src.cooldown <= 0)	return 0
		spawn(10)
			src.Process_cooldown()
		return 1


	Activate()
		if((!secured) || (cooldown > 0))
			return 0
		var/turf/location = get_turf(src.loc)
		if(location)
			location.hotspot_expose(1000,1000)
		cooldown = 2
		spawn(10)
			Process_cooldown()
		return 1


	Secure()
		if(secured)
			return 0
		secured = 1
		return 1


	Unsecure()
		if(!secured)
			return 0
		secured = 0
		return 1


	Attach_Assembly(var/obj/A, var/mob/user)
		holder = new/obj/item/device/assembly_holder(get_turf(src))
		if(holder:attach(A,src,user))
			user.show_message("\blue You attach the [A.name] to the [src.name]!")
			return 1
		return 0


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(W.IsAssembly())
			var/obj/item/device/D = W
			if((!D:secured) && (!src.secured))
				Attach_Assembly(D,user)
		if(isscrewdriver(W))
			if(src.secured)
				Unsecure()
				user.show_message("\blue The [src.name] can now be attached!")
			else
				Secure()
				user.show_message("\blue The [src.name] is ready!")
			return
		else
			..()
		return


	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		spawn( 5 )
			Activate()
			return
		return


	examine()
		set src in view()
		..()
		if ((in_range(src, usr) || src.loc == usr))
			if (src.secured)
				usr.show_message("The [src.name] is ready!")
			else
				usr.show_message("The [src.name] can be attached!")
		return