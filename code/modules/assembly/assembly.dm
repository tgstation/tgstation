#define VALUE_VARIABLE_NAME 1 //See var/list/accessible_values below!
#define VALUE_VARIABLE_TYPE 2
#define VALUE_VARIABLE_MIN  3 //Minimum possible number value
#define VALUE_VARIABLE_MAX  4 //Maximum possible number value

var/global/list/assembly_short_name_to_type = list() //Please, I beg you, don't give two different types of assembly the same short_name

/obj/item/device/assembly
	name = "assembly"
	var/short_name //Short name of the assembly. If the name is "remote signalling device", short_name must be something like "signaler"

	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags = FPRINT
	siemens_coefficient = 1
	w_class = 2.0
	starting_materials = list(MAT_IRON = 100)
	w_type = RECYK_ELECTRONIC
	throwforce = 2
	throw_speed = 3
	throw_range = 10
	origin_tech = "magnets=1"

	var/show_status = 1 //in order to prevent the signaler button in signaler.dm from saying "... is ready!" when examined
	var/secured = 1
	var/list/attached_overlays = null
	var/obj/item/device/assembly_holder/holder = null
	var/cooldown = 0//To prevent spam
	var/wires = WIRE_RECEIVE | WIRE_PULSE

	var/const/WIRE_RECEIVE = 1			//Allows Pulsed(0) to call Activate()
	var/const/WIRE_PULSE = 2				//Allows Pulse(0) to act on the holder
	var/const/WIRE_PULSE_SPECIAL = 4		//Allows Pulse(0) to act on the holders special assembly
	var/const/WIRE_RADIO_RECEIVE = 8		//Allows Pulsed(1) to call Activate()
	var/const/WIRE_RADIO_PULSE = 16		//Allows Pulse(1) to send a radio message

	var/connection_text = "sending signals to" //For assembly frames

	var/list/accessible_values = list()

	// List of variables that can be READ / WRITTEN TO by other assemblies.
		// Format of the list:
		//
		// accessible_values = list("Time" = "time;number",\
		//	"Frequency" = "freq;number",\
		//	"Code" = "code;number")
		//
		// "Time" - name of this value. Can be anything
		// "time;number" - parameters. Convert this to a list using params2list, and access them by doing either list[VALUE_VARIABLE_NAME] or list[VALUE_VARIABLE_TYPE]

		//The example above allows any assembly (connected to an assembly frame) to access this assembly's time, frequency and code, e.g. a math circuit can READ this assembly's time, multiply it by 90 and SET this assembly's time to the result

/obj/item/device/assembly/New()
	..()

	if(!short_name)
		short_name = name

/obj/item/device/assembly/proc/activate()									//What the device does when turned on
	return

/obj/item/device/assembly/proc/pulsed(var/radio = 0)						//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
	return

/obj/item/device/assembly/proc/pulse(var/radio = 0)						//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
	return

/obj/item/device/assembly/proc/toggle_secure()								//Code that has to happen when the assembly is un\secured goes here
	return

/obj/item/device/assembly/proc/attach_assembly(var/obj/A, var/mob/user)	//Called when an assembly is attacked by another
	return

/obj/item/device/assembly/proc/process_cooldown()							//Called via spawn(10) to have it count down the cooldown var
	return

/obj/item/device/assembly/proc/holder_movement()							//Called when the holder is moved
	return

/obj/item/device/assembly/interact(mob/user as mob)					//Called when attack_self is called
	return

/obj/item/device/assembly/proc/describe()									// Called by grenades to describe the state of the trigger (time left, etc)
	return "The trigger assembly looks broken!"

/obj/item/device/assembly/proc/send_pulses_to_list(var/list/L) //Send pulse to all assemblies in list.
	if(!L || !L.len) return

	for(var/obj/item/device/assembly/A in L)
		A.pulsed()

/obj/item/device/assembly/proc/get_value(var/value) //Get the assembly's value (to be used with various circuits). value = an element from the accessible_values list!
	if(!value in accessible_values) return

	var/list/L = params2list(accessible_values[value])
	var/var_to_grab = L[VALUE_VARIABLE_NAME]

	return vars[var_to_grab]

/obj/item/device/assembly/proc/write_to_value(var/value, var/new_value) //Attempt to write to assembly's value. This handles value's type (num/text), whether writing is possible, etc.
	if(!value in accessible_values) return

	var/list/L = params2list(accessible_values[value])

	if(L[VALUE_VARIABLE_TYPE] == "number")
		if(!isnum(new_value)) //Attempted to write a non-number to a number var - abort!
			return

		if(L.len >= VALUE_VARIABLE_MAX)
			new_value = Clamp(new_value, text2num(L[VALUE_VARIABLE_MIN]), text2num(L[VALUE_VARIABLE_MAX]))
	else
		if(!istext(new_value))  //Attempted to write a non-string to a string var - convert the non-string into a string and continue
			new_value = "[new_value]"

	//text values can accept either numbers or text, so don't check for that

	var/var_to_change = L[VALUE_VARIABLE_NAME]

	set_value(var_to_change, new_value)

	return

/obj/item/device/assembly/proc/set_value(var/var_name, var/new_value) //Actually change the assembly's var. No sanity or anything
	vars[var_name] = new_value

/obj/item/device/assembly/proc/connected(var/obj/item/device/assembly/A, in_frame = 0) //Called when assembly is connected to another assembly. in_frame is 1 if the connection occured in an assembly frame
	return

/obj/item/device/assembly/proc/disconnected(var/obj/item/device/assembly/A, in_frame = 0) //Called when assembly is disconnected from another assembly
	return

/obj/item/device/assembly/process_cooldown()
	cooldown--
	if(cooldown <= 0)	return 0
	spawn(10)
		process_cooldown()
	return 1

/obj/item/device/assembly/Destroy()
	if(istype(src.loc, /obj/item/device/assembly_holder) || istype(holder))
		var/obj/item/device/assembly_holder/A = src.loc
		if(A.a_left == src)
			A.a_left = null
		else if(A.a_right == src)
			A.a_right = null
		src.holder = null
	else if(istype(src.loc, /obj/item/device/assembly_frame))
		var/obj/item/device/assembly_frame/AF = src.loc

		AF.eject_assembly(src)

	..()

/obj/item/device/assembly/pulsed(var/radio = 0)
	if(holder && (wires & WIRE_RECEIVE))
		activate()
	if(radio && (wires & WIRE_RADIO_RECEIVE))
		activate()
	return 1


/obj/item/device/assembly/pulse(var/radio = 0)
	if(istype(holder, /obj/item/device/assembly_frame))
		var/obj/item/device/assembly_frame/AB = holder

		AB.receive_pulse(src)
	else
		if(holder && (wires & WIRE_PULSE))
			holder.process_activation(src, 1, 0)
		if(holder && (wires & WIRE_PULSE_SPECIAL))
			holder.process_activation(src, 0, 1)

	if(istype(loc,/obj/item/weapon/grenade)) // This is a hack.  Todo: Manage this better -Sayu
		var/obj/item/weapon/grenade/G = loc
		G.prime() 							 // Adios, muchachos
//		if(radio && (wires & WIRE_RADIO_PULSE))
		//Not sure what goes here quite yet send signal?
	return 1


/obj/item/device/assembly/activate()
	if(!secured || (cooldown > 0))	return 0
	cooldown = 2
	spawn(10)
		process_cooldown()
	return 1


/obj/item/device/assembly/toggle_secure()
	secured = !secured
	update_icon()
	return secured


/obj/item/device/assembly/attach_assembly(var/obj/item/device/assembly/A, var/mob/user)
	holder = new/obj/item/device/assembly_holder(get_turf(src))
	if(holder.attach(A,src,user))
		to_chat(user, "<span class='notice'>You attach \the [A] to \the [src]!</span>")
		return 1
	return 0


/obj/item/device/assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isassembly(W))
		var/obj/item/device/assembly/A = W
		if((!A.secured) && (!secured))
			attach_assembly(A,user)
			return
	if(isscrewdriver(W))
		if(toggle_secure())
			to_chat(user, "<span class='notice'>\The [src] is ready!</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] can now be attached!</span>")
		return
	..()
	return


/obj/item/device/assembly/process()
	processing_objects.Remove(src)
	return


/obj/item/device/assembly/examine(mob/user)
	..()
	if(show_status)
		if(secured)
			to_chat(user, "<span class='info'>\The [src] is ready!</span>")
		else
			to_chat(user, "<span class='info'>\The [src] can be attached!</span>")

/obj/item/device/assembly/attack_self(mob/user as mob)
	if(!user)	return 0
	user.set_machine(src)
	interact(user)
	return 1


/obj/item/device/assembly/interact(mob/user as mob)
	return //HTML MENU FOR WIRES GOES HERE

/*
	var/small_icon_state = null//If this obj will go inside the assembly use this for icons
	var/list/small_icon_state_overlays = null//Same here
	var/obj/holder = null
	var/cooldown = 0//To prevent spam

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
