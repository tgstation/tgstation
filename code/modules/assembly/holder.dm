/obj/item/device/assembly_holder
	name = "Assembly"
	desc = "Holds various devices"//Fix this by adding dynamic desc
	icon = 'new_assemblies.dmi'
	icon_state = "holder"
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 100
	throwforce = 5
	w_class = 1.0
	throw_speed = 3
	throw_range = 10

	var
		secured = 0
		obj/item/device/assembly_left = null
		obj/item/device/assembly_right = null
		//The "other" thing will go here

	proc
		attach(var/obj/item/device/D, var/obj/item/device/D2, var/mob/user)
		Process_Activation(var/obj/item/device/D)


	IsAssemblyHolder()
		return 1


	attach(var/obj/item/device/D, var/obj/item/device/D2, var/mob/user)
		if((!D)||(!D2))	return 0
		if((!D.IsAssembly())||(!D2.IsAssembly()))	return 0
		if((D:secured)||(D2:secured))	return 0
		if(user)
			user.remove_from_mob(D)
			user.remove_from_mob(D2)
		D:holder = src
		D2:holder = src
		D.loc = src
		D2.loc = src
		assembly_left = D
		assembly_right = D2
		src.name = "[D.name] [D2.name] assembly"
		update_icon()
		return 1


	update_icon()
		src.overlays = null
		if(assembly_left)
			src.overlays += assembly_left:small_icon_state_left
			for(var/O in assembly_left:small_icon_state_overlays)
				src.overlays += text("[]_l", O)
		if(assembly_right)
			src.overlays += assembly_right:small_icon_state_right
			for(var/O in assembly_right:small_icon_state_overlays)
				src.overlays += text("[]_r", O)
//		if(other)
//			other.update_icon()


	examine()
		set src in view()
		..()
		if ((in_range(src, usr) || src.loc == usr))
			if (src.secured)
				usr.show_message("The [src.name] is ready!")
			else
				usr.show_message("The [src.name] can be attached!")
		return


	HasProximity(atom/movable/AM as mob|obj)
		if(!assembly_left || !assembly_right)	return 0
		assembly_left.HasProximity(AM)
		assembly_right.HasProximity(AM)


	Move()//I dont like this but it will do for now
		var/t = src.dir
		..()
		if(istype(assembly_left,/obj/item/device/infra))
			assembly_left.dir = t
			del(assembly_left:first)
		if(istype(assembly_right,/obj/item/device/infra))
			assembly_right.dir = t
			del(assembly_right:first)
		return


	attack_hand()//I dont like this one either
		if(istype(assembly_left,/obj/item/device/infra))
			del(assembly_left:first)
		if(istype(assembly_right,/obj/item/device/infra))
			del(assembly_right:first)
		..()
		return


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(isscrewdriver(W))
			if(!assembly_left || !assembly_right)
				user.show_message("\red Assembly part missing!")
				return
			if(src.secured)
				src.secured = 0
				assembly_left:Unsecure()
				assembly_right:Unsecure()
				user.show_message("\blue The [src.name] can now be taken apart!")
			else
				src.secured = 1
				assembly_left:Secure()
				assembly_right:Secure()
				user.show_message("\blue The [src.name] is ready!")
			update_icon()
			return
		else
			..()
		return


	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if(src.secured)
			if(!assembly_left || !assembly_right)
				user.show_message("\red Assembly part missing!")
				return
			if(istype(assembly_left,assembly_right.type))//If they are the same type it causes issues due to window code
				switch(alert("Which side would you like to use?",,"Left","Right"))
					if("Left")
						assembly_left.attack_self(user)
					if("Right")
						assembly_right.attack_self(user)
				return
			else
				assembly_left.attack_self(user)
				assembly_right.attack_self(user)
		else
			var/turf/T = get_turf(src)
			if(!T)	return 0
			if(assembly_left)
				assembly_left:holder = null
				assembly_left.loc = T
			if(assembly_right)
				assembly_right:holder = null
				assembly_right.loc = T
			spawn(0)
				del(src)
		return


	Process_Activation(var/obj/item/device/D)
		if(!D)	return 0
		if(assembly_left == D)
			assembly_right:Activate()
			//If anymore things can be on a holder this will have to be edited
		else if(assembly_right == D)
			assembly_left:Activate()
//		else if(assemblyother == D)
//			assembly_left.Activate()
//			assembly_right.Activate()
		return 1











