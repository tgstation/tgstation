/obj/item/device/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags = CONDUCT
	w_class = 2.0
	materials = list(MAT_METAL=100)
	throwforce = 2
	throw_speed = 3
	throw_range = 7
	origin_tech = "magnets=1"

	var/secured = 1
	var/list/attached_overlays = null
	var/obj/item/device/assembly_holder/holder = null
	var/cooldown = 0//To prevent spam
	var/wires = WIRE_RECEIVE | WIRE_PULSE
	var/attachable = 0 // can this be attached to wires
	var/datum/wires/connected = null

	var/const/WIRE_RECEIVE = 1			//Allows Pulsed(0) to call Activate()
	var/const/WIRE_PULSE = 2				//Allows Pulse(0) to act on the holder
	var/const/WIRE_PULSE_SPECIAL = 4		//Allows Pulse(0) to act on the holders special assembly
	var/const/WIRE_RADIO_RECEIVE = 8		//Allows Pulsed(1) to call Activate()
	var/const/WIRE_RADIO_PULSE = 16		//Allows Pulse(1) to send a radio message

/obj/item/device/assembly/proc/holder_movement()							//Called when the holder is moved
	return

/obj/item/device/assembly/proc/describe()									// Called by grenades to describe the state of the trigger (time left, etc)
	return "The trigger assembly looks broken!"


/obj/item/device/assembly/proc/is_secured(mob/user)
	if(!secured)
		user << "<span class='warning'>The [name] is unsecured!</span>"
		return 0
	return 1


//Called via spawn(10) to have it count down the cooldown var
/obj/item/device/assembly/proc/process_cooldown()
	cooldown--
	if(cooldown <= 0)
		return 0
	spawn(10)
		process_cooldown()
	return 1


//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
/obj/item/device/assembly/proc/pulsed(var/radio = 0)
	if(holder && (wires & WIRE_RECEIVE))
		activate()
	if(radio && (wires & WIRE_RADIO_RECEIVE))
		activate()
	return 1


//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
/obj/item/device/assembly/proc/pulse(var/radio = 0)
	if(src.connected && src.wires)
		connected.Pulse(src)
		return 1
	if(holder && (wires & WIRE_PULSE))
		holder.process_activation(src, 1, 0)
	if(holder && (wires & WIRE_PULSE_SPECIAL))
		holder.process_activation(src, 0, 1)
	return 1


// What the device does when turned on
/obj/item/device/assembly/proc/activate()
	if(!secured || (cooldown > 0))
		return 0
	cooldown = 2
	spawn(10)
		process_cooldown()
	return 1


/obj/item/device/assembly/proc/toggle_secure()
	secured = !secured
	update_icon()
	return secured


/obj/item/device/assembly/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(isassembly(W))
		var/obj/item/device/assembly/A = W
		if((!A.secured) && (!secured))
			holder = new/obj/item/device/assembly_holder(get_turf(src))
			holder.assemble(src,A,user)
			user << "<span class='notice'>You attach and secure \the [A] to \the [src]!</span>"
		else
			user << "<span class='warning'>Both devices must be in attachable mode to be attached together.</span>"
		return
	if(istype(W, /obj/item/weapon/screwdriver))
		if(toggle_secure())
			user << "<span class='notice'>\The [src] is ready!</span>"
		else
			user << "<span class='notice'>\The [src] can now be attached!</span>"
		return
	..()
	return


/obj/item/device/assembly/process()
	SSobj.processing.Remove(src)
	return


/obj/item/device/assembly/examine(mob/user)
	..()
	if(secured)
		user << "\The [src] is secured and ready to be used."
	else
		user << "\The [src] can be attached to other things."


/obj/item/device/assembly/attack_self(mob/user as mob)
	if(!user)
		return 0
	user.set_machine(src)
	interact(user)
	return 1


/obj/item/device/assembly/interact(mob/user as mob)
	return //HTML MENU FOR WIRES GOES HERE

