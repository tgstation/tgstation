
/proc/isassembly(O)
	if(istype(O, /obj/item/device/assembly))
		return 1
	return 0

/proc/isigniter(O)
	if(istype(O, /obj/item/device/assembly/igniter))
		return 1
	return 0

/proc/isinfared(O)
	if(istype(O, /obj/item/device/assembly/infra))
		return 1
	return 0

/proc/isprox(O)
	if(istype(O, /obj/item/device/assembly/prox_sensor))
		return 1
	return 0

/proc/issignaler(O)
	if(istype(O, /obj/item/device/assembly/signaler))
		return 1
	return 0

/proc/istimer(O)
	if(istype(O, /obj/item/device/assembly/timer))
		return 1
	return 0


/obj/item/device/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'new_assemblies.dmi'
	icon_state = ""
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	w_class = 2.0
	m_amt = 100
	g_amt = 0
	w_amt = 0
	throwforce = 2
	throw_speed = 3
	throw_range = 10
	origin_tech = "magnets=1"

	var/secured = 1
	var/small_icon_state_left = null
	var/small_icon_state_right = null
	var/list/small_icon_state_overlays = null
	var/obj/item/device/assembly_holder/holder = null
	var/cooldown = 0//To prevent spam
	var/wires = WIRE_RECEIVE | WIRE_PULSE

	var/const/WIRE_RECEIVE = 1			//Allows Pulsed(0) to call Activate()
	var/const/WIRE_PULSE = 2				//Allows Pulse(0) to act on the holder
	var/const/WIRE_PULSE_SPECIAL = 4		//Allows Pulse(0) to act on the holders special assembly
	var/const/WIRE_RADIO_RECEIVE = 8		//Allows Pulsed(1) to call Activate()
	var/const/WIRE_RADIO_PULSE = 16		//Allows Pulse(1) to send a radio message

	proc/activate()									//What the device does when turned on
		return

	proc/pulsed(var/radio = 0)						//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
		return

	proc/pulse(var/radio = 0)						//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
		return

	proc/toggle_secure()								//Code that has to happen when the assembly is un\secured goes here
		return

	proc/attach_assembly(var/obj/A, var/mob/user)	//Called when an assembly is attacked by another
		return

	proc/process_cooldown()							//Called via spawn(10) to have it count down the cooldown var
		return

	proc/holder_movement()							//Called when the holder is moved
		return

	proc/interact(mob/user as mob)					//Called when attack_self is called
		return


	process_cooldown()
		cooldown--
		if(cooldown <= 0)	return 0
		spawn(10)
			process_cooldown()
		return 1


	pulsed(var/radio = 0)
		if(holder && (wires & WIRE_RECEIVE))
			activate()
		if(radio && (wires & WIRE_RADIO_RECEIVE))
			activate()
		return 1


	pulse(var/radio = 0)
		if(holder && (wires & WIRE_PULSE))
			holder.process_activation(src, 1, 0)
		if(holder && (wires & WIRE_PULSE_SPECIAL))
			holder.process_activation(src, 0, 1)
//		if(radio && (wires & WIRE_RADIO_PULSE))
			//Not sure what goes here quite yet send signal?
		return 1


	activate()
		if(!secured || (cooldown > 0))	return 0
		cooldown = 2
		spawn(10)
			process_cooldown()
		return 1


	toggle_secure()
		secured = !secured
		update_icon()
		return secured


	attach_assembly(var/obj/item/device/assembly/A, var/mob/user)
		holder = new/obj/item/device/assembly_holder(get_turf(src))
		if(holder.attach(A,src,user))
			user.show_message("\blue You attach the [A.name] to the [name]!")
			return 1
		return 0


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(isassembly(W))
			var/obj/item/device/assembly/A = W
			if((!A.secured) && (!secured))
				attach_assembly(A,user)
				return
		if(isscrewdriver(W))
			if(toggle_secure())
				user.show_message("\blue The [name] is ready!")
			else
				user.show_message("\blue The [name] can now be attached!")
			return
		..()
		return


	process()
		processing_objects.Remove(src)
		return


	examine()
		set src in view()
		..()
		if((in_range(src, usr) || loc == usr))
			if(secured)
				usr.show_message("The [name] is ready!")
			else
				usr.show_message("The [name] can be attached!")
		return


	attack_self(mob/user as mob)
		if(!user)	return 0
		user.machine = src
		interact(user)
		return 1


	interact(mob/user as mob)
		return //HTML MENU FOR WIRES GOES HERE

/*
Name:	IsAssemblyHolder
Desc:	If true is an object that can hold an assemblyholder object
*/
/obj/proc/IsAssemblyHolder()
	return 0
/*
	proc
		Process_Activation(var/obj/D, var/normal = 1, var/special = 1)
*/



/*
Name:	IsSpecialAssembly
Desc:	If true is an object that can be attached to an assembly holder but is a special thing like a plasma can or door
*/

/obj/proc/IsSpecialAssembly()
	return 0
/*
	var
		small_icon_state = null//If this obj will go inside the assembly use this for icons
		list/small_icon_state_overlays = null//Same here
		obj/holder = null
		cooldown = 0//To prevent spam

	proc
		Activate()//Called when this assembly is pulsed by another one
		Process_cooldown()//Call this via spawn(10) to have it count down the cooldown var
		Attach_Holder(var/obj/H, var/mob/user)//Called when an assembly holder attempts to attach, sets src's loc in here


	Activate()
		if(cooldown > 0)
			return 0
		cooldown = 2
		spawn(10)
			Process_cooldown()
		//Rest of code here
		return 0


	Process_cooldown()
		cooldown--
		if(cooldown <= 0)	return 0
		spawn(10)
			Process_cooldown()
		return 1


	Attach_Holder(var/obj/H, var/mob/user)
		if(!H)	return 0
		if(!H.IsAssemblyHolder())	return 0
		//Remember to have it set its loc somewhere in here


*/