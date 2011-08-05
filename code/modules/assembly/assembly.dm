/*
Desc:	Sorta a hack/workaround to get interfaceish things into this engine.
		To use an interface just override the proc in your object and set it to return true.
		If an object returns true for one of these it should have ALL of the commented out procs and vars defined in its class.
*/



/*
Name:	IsAssembly
Desc:	If true is an assembly that can work with the holder
*/
/obj/proc/IsAssembly()
	return 0
/*
	var
		secured = 1
		small_icon_state_left = null
		small_icon_state_right = null
		list/small_icon_state_overlays = null
		obj/holder = null
		cooldown = 0//To prevent spam

	proc
		Activate()//Called when this assembly is pulsed by another one
		Secure()//Code that has to happen when the assembly is ready goes here
		Unsecure()//Code that has to happen when the assembly is taken off of the ready state goes here
		Attach_Assembly(var/obj/A, var/mob/user)//Called when an assembly is attacked by another
		Process_cooldown()//Call this via spawn(10) to have it count down the cooldown var


	IsAssembly()
		return 1


	Process_cooldown()
		cooldown--
		if(cooldown <= 0)	return 0
		spawn(10)
			Process_cooldown()
		return 1


	Activate()
		if((!secured) || (cooldown > 0))//Make sure to add something using cooldown or such to prevent spam
			return 0
		cooldown = 2
		spawn(10)
			Process_cooldown()
		return 0


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
*/

/*
Name:	IsAssemblyHolder
Desc:	If true is an object that can hold an assemblyholder object
*/
/obj/proc/IsAssemblyHolder()
	return 0
/*
	proc
		Process_Activation(var/obj/item/device/D)
*/
