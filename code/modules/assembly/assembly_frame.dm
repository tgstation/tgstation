/obj/item/device/assembly_frame
	name = "assembly frame"
	desc = "A large metal box with a frame inside, designed to store and link tiny assemblies like timers and signalers. There is a display with an interface for connecting assemblies together."

	icon_state = "assembly_box"
	origin_tech = "programming=3;engineering=3;magnets=3"

	var/list/obj/item/device/assembly/assemblies = list()

	var/list/connections = list() //Assembly associated with the list of assemblies it's connected to

/obj/item/device/assembly_frame/Destroy()
	for(var/obj/item/device/assembly/AS in connections)
		var/list/L = connections[AS]

		for(var/DC in L)
			AS.disconnected(DC, in_frame = 1)

	connections = null

	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))

	assemblies = null

	..()

/obj/item/device/assembly_frame/proc/get_assembly_href(var/obj/item/device/assembly/A)
	var/txt_buttons = "<a href='?src=\ref[src];eject=1;assembly=\ref[A]'>\[X\]</a><a href='?src=\ref[src];pulse=1;assembly=\ref[A]'>\[P\]</a>"

	var/txt_assembly_number = "([assemblies.Find(A)])"

	var/txt_assembly = "<a href='?src=\ref[src];interact=1;assembly=\ref[A]'><b>[A]</b></a>"

	var/txt_connections
	if(!connections.Find(A))
		txt_connections = "<small>(<a href='?src=\ref[src];connect=1;assembly=\ref[A]'>connect</a>)</small>"
	else
		txt_connections = "<small> [A.connection_text]: "

		var/list/list_of_connections = connections[A]

		if(list_of_connections.len)
			for(var/obj/item/device/assembly/C in list_of_connections)
				txt_connections += "[assemblies.Find(C)]-<a href='?src=\ref[src];disconnect=1;assembly=\ref[A];disconnect_which=\ref[C]'><b>[C.short_name][C.labeled]</b></a>, "

			txt_connections += "<a href='?src=\ref[src];connect=1;assembly=\ref[A]'><b>add more</b></a></small>"

	return "[txt_buttons] [txt_assembly_number] [txt_assembly] [txt_connections]"

///////

/obj/item/device/assembly_frame/attack_self(mob/user)
	var/dat = "<h4>AdCo. Assembly Frame MK II <small>\[<a href='?src=\ref[src];help=1'>?</a>\]</small></h4><br>"

	if(!assemblies.len)
		dat += "<p>No assemblies found!</p>"
	else
		for(var/obj/item/device/assembly/A in assemblies)

			dat += "<p>[get_assembly_href(A)]</p>"

			//Example result:

			//[X][P] (1) remote signalling device sending signals to: 2-speaker (alert), 3-timer (countdown), add more
			//[X][P] (2) speaker (alert) (connect)
			//[X][P] (3) timer (countdown) sending signals to: 4-signaler (radio alert), add more
			//[X][P] (4) signaler (radio alert) (connect)

			//Clicking on [X] ejects the assembly
			//Clicking on [P] pulses the assembly
			//Clicking on the assembly's name allows you to change its settings (or otherwise interact with it
			//Clicking on (connect) or "add more" allows you to select an assembly to connect to
			//Clicking on any assembly after "sending signals to" will remove the connection

	var/datum/browser/popup = new(user, "\ref[src]", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "\ref[src]")

	return

/obj/item/device/assembly_frame/Topic(href, href_list)
	if(..()) return

	var/obj/item/device/assembly/AS = locate(href_list["assembly"])

	if(href_list["connect"]) //Connect AS to another assembly
		if(!istype(AS))
			return

		if(!assemblies.Find(AS)) //Assembly isn't in the board
			return

		var/list/active_connections = connections[AS]

		if(assemblies.len == 1) //Only one assembly in the board (this one) - return
			return

		spawn()
			var/list/list_to_take_from = (assemblies - AS)

			if(active_connections)
				list_to_take_from -= active_connections

			var/list/list_for_input = list()
			for(var/A in list_to_take_from)
				list_for_input["[assemblies.Find(A)]-[A]"] = A //The list is full of strings that are associated with assemblies


			var/choice = input(usr, "Send output from [AS] to which device?", "[src]") as null|anything in list_for_input //This input only returns a string with the assembly's number and name
			choice = list_for_input[choice] //Get the ACTUAL assembly object

			if(..()) return

			if(!choice) return

			///////////////Don't do infinite loops kids/////
			if(istype(choice, /obj/item/device/assembly/math) && istype(AS, /obj/item/device/assembly/math)) //Both assemblies are math circuits
				var/list/choices_connections = connections[choice]
				if(choices_connections && (AS in choices_connections)) //If the other assembly is connected to us (and right now we're trying to connect ourselves to it, creating an infinite loop of math)
					to_chat(usr, "<span class='info'>SYSTEM ERROR: Infinite loop detected, operation aborted.</span>")
					return

			////////////////////////////////////////////////

			if(!active_connections) //If there ISN'T a list with connections
				connections[AS] = list(choice) //Make a new one
			else
				active_connections |= choice

			AS.connected(choice, in_frame = 1)

			to_chat(usr, "<span class='info'>You connect \the [AS] to \the [choice].</span>")

			if(usr)
				attack_self(usr)

	if(href_list["eject"]) //Eject AS from the frame
		if(!istype(AS))
			return

		if(!assemblies.Find(AS))
			return

		if(AS.loc != src)
			to_chat(usr, "<span class='warning'>A pink light flashes on \the [src], indicating an error.</span>")
			return

		eject_assembly(AS)

		to_chat(usr, "<span class='info'>You remove \the [AS] from \the [src].</span>")

	if(href_list["pulse"])
		if(!istype(AS))
			return

		if(!assemblies.Find(AS))
			return

		if(AS.loc != src)
			to_chat(usr, "<span class='warning'>A green light flashes on \the [src], indicating an error.</span>")
			return

		AS.pulsed()

	if(href_list["interact"])
		if(!istype(AS))
			return

		if(!assemblies.Find(AS))
			return

		AS.attack_self(usr)

	if(href_list["disconnect"]) //Remove link from AS to specified assembly
		var/obj/item/device/assembly/disconnected = locate(href_list["disconnect_which"]) //Find assembly to disconnect from AS

		if(!istype(AS))
			to_chat(usr, "<span class='info'>[AS] isn't an assembly.</span>")
			return

		if(!istype(disconnected))
			to_chat(usr, "<span class='info'>[disconnected] isn't an assembly.</span>")
			return

		if(!assemblies.Find(AS))
			to_chat(usr, "<span class='info'>[AS] isn't connected to \the [src]!</span>")
			return

		var/list/L = connections[AS] //Find list of assemblies connected to AS

		if(!L)
			to_chat(usr, "<span class='warning'>A red light flashes on \the [src], indicating an error.</span>")
			return

		L.Remove(disconnected) //Remove the disconnected assembly from that list
		AS.disconnected(disconnected, in_frame = 1)

		if(!L.len) //If AS isn't connected to anything, remove AS from the list of assemblies with connections
			connections.Remove(AS)

	if(href_list["help"])
		//Here comes the fluff
		spawn(2)
			to_chat(usr, "<span class='notice'>You press \the [src]'s help button.</span>")
			sleep(5)
			to_chat(usr, "----------------------------------")
			to_chat(usr, "<span class='info'><h5>AdCo. Assembly Frame MK II</h5></span>")
			to_chat(usr, "----------------------------------")
			sleep(5)
			to_chat(usr, "<span class='info'>To connect a device to the assembly frame, insert it into any of the numbered sockets inside.</span>")
			to_chat(usr, "<span class='info'>The device list on the monitor displays all connected devices along with their number. To the right of each device is a list of other devices that are connected to it.</span>")
			to_chat(usr, "<span class='info'>To make device A send signals to device B, first ensure that both devices are connected to the assembly frame. Then press the \"connect\" button next to device A on the monitor, and select device B. Any signals emitted by device A will now be received by device B (but not vice versa).")
			to_chat(usr, "<span class='info'>To stop device A from receiving device B's signals, find device B in the device list. To the right of device B is a list of other devices that are connected to it. Find device A in that list and select it. Device A will no longer receive signals from device B.")
			to_chat(usr, "<span class='info'>To pulse a device, press the \[P\] button next to it.")
			to_chat(usr, "<span class='info'>To eject a device, press the \[X\] button next to it.")

		return

	if(usr)
		attack_self(usr)

/obj/item/device/assembly_frame/proc/receive_pulse(var/obj/item/device/assembly/from)
	if(!assemblies.Find(from)) return
	if(!connections.Find(from)) return

	var/list/connected_to_source = connections[from]

	from.send_pulses_to_list(connected_to_source)



/obj/item/device/assembly_frame/attackby(obj/item/W, mob/user)
	..()

	if(istype(W, /obj/item/device/assembly))
		var/obj/item/device/assembly/AS = W

		if(user.drop_item(AS, src))
			AS.holder = src
			assemblies.Add(AS)

		if(!AS.secured)
			AS.toggle_secure() //Make it secured

	else if(istype(W, /obj/item/device/assembly_holder))
		to_chat(user, "<span class='notice'>\The [W] is too big for any of the sockets here. Try taking it apart.")
		return


/obj/item/device/assembly_frame/proc/eject_assembly(obj/item/device/assembly/AS) //Disconnect an assembly from everything, then remove it
	for(var/A in connections) //Remove all references to this assembly in this board
		var/list/L = connections[A]
		L.Remove(AS)

		var/obj/item/device/assembly/disconnected_from = A
		disconnected_from.disconnected(AS, in_frame = 1)

		if(!L.len) //If list of A's connections is empty
			connections.Remove(A) //Remove A from the list of assemblies with connections

	assemblies.Remove(AS)
	connections.Remove(AS)

	AS.holder = null
	AS.forceMove(get_turf(src))
