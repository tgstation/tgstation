// Wire datums. Created by Giacomand.
// Was created to replace a horrible case of copy and pasted code with no care for maintability.
// Goodbye Door wires, Cyborg wires, Vending Machine wires, Autolathe wires
// Protolathe wires, APC wires and Camera wires!

#define MAX_FLAG 65535

var/list/same_wires = list()
// 12 colours, if you're adding more than 12 wires then add more colours here
var/list/wireColours = list("red", "blue", "green", "black", "orange", "brown", "gold", "gray", "cyan", "navy", "purple", "pink")

/datum/wires

	var/random = 0 // Will the wires be different for every single instance.
	var/atom/holder = null // The holder
	var/holder_type = null // The holder type; used to make sure that the holder is the correct type.
	var/wire_count = 0 // Max is 16
	var/wires_status = 0 // BITFLAG OF WIRES

	var/list/wires = list()
	var/list/signallers = list()

	var/table_options = " align='center'"
	var/row_options1 = " width='80px'"
	var/row_options2 = " width='260px'"
	var/window_x = 370
	var/window_y = 470

/datum/wires/New(var/atom/holder)
	..()
	src.holder = holder
	if(!istype(holder, holder_type))
		CRASH("Our holder is null/the wrong type!")
		return

	// Generate new wires
	if(random)
		GenerateWires()
	// Get the same wires
	else
		// We don't have any wires to copy yet, generate some and then copy it.
		if(!same_wires[holder_type])
			GenerateWires()
			same_wires[holder_type] = src.wires.Copy()
		else
			var/list/wires = same_wires[holder_type]
			src.wires = wires // Reference the wires list.

/datum/wires/proc/GenerateWires()
	var/list/colours_to_pick = wireColours.Copy() // Get a copy, not a reference.
	var/list/indexes_to_pick = list()
	//Generate our indexes
	for(var/i = 1; i < MAX_FLAG && i < (1 << wire_count); i += i)
		indexes_to_pick += i
	colours_to_pick.len = wire_count // Downsize it to our specifications.

	while(colours_to_pick.len && indexes_to_pick.len)
		// Pick and remove a colour
		var/colour = pick_n_take(colours_to_pick)

		// Pick and remove an index
		var/index = pick_n_take(indexes_to_pick)

		src.wires[colour] = index
		//wires = shuffle(wires)


/datum/wires/proc/Interact(mob/living/user)

	var/html = null
	if(holder && CanUse(user))
		html = GetInteractWindow()
	if(html)
		user.set_machine(holder)
	else
		user.unset_machine()
		// No content means no window.
		user << browse(null, "window=wires")
		return

	var/datum/browser/popup = new(user, "wires", holder.name, window_x, window_y)
	popup.set_content(html)
	popup.set_title_image(user.browse_rsc_icon(holder.icon, holder.icon_state))
	popup.open()

/datum/wires/proc/GetInteractWindow()
	var/html = "<div class='block'>"
	html += "<h3>Exposed Wires</h3>"
	html += "<table[table_options]>"

	for(var/colour in wires)
		html += "<tr>"
		html += "<td[row_options1]><font color='[colour]'>[capitalize(colour)]</font></td>"
		html += "<td[row_options2]>"
		html += "<A href='?src=\ref[src];action=1;cut=[colour]'>[IsColourCut(colour) ? "Mend" :  "Cut"]</A>"
		html += " <A href='?src=\ref[src];action=1;pulse=[colour]'>Pulse</A>"
		html += " <A href='?src=\ref[src];action=1;attach=[colour]'>[IsAttached(colour) ? "Detach" : "Attach"] Signaller</A></td></tr>"
	html += "</table>"
	html += "</div>"

	return html

/datum/wires/Topic(href, href_list)
	..()
	if(usr.Adjacent(holder) && isliving(usr))
		var/mob/living/L = usr
		if(CanUse(L) && href_list["action"])
			var/obj/item/I = L.get_active_hand()
			holder.add_hiddenprint(L)
			if(href_list["cut"]) // Toggles the cut/mend status
				if(istype(I, /obj/item/weapon/wirecutters))
					var/colour = href_list["cut"]
					CutWireColour(colour)
				else
					L << "<span class='warning'>You need wirecutters!</span>"

			else if(href_list["pulse"])
				if(istype(I, /obj/item/device/multitool))
					var/colour = href_list["pulse"]
					PulseColour(colour)
				else
					L << "<span class='warning'>You need a multitool!</span>"

			else if(href_list["attach"])
				var/colour = href_list["attach"]
				// Detach
				if(IsAttached(colour))
					var/obj/item/O = Detach(colour)
					if(O)
						L.put_in_hands(O)

				// Attach
				else
					if(istype(I, /obj/item/device/assembly))
						var/obj/item/device/assembly/A = I;
						if(A.attachable)
							if(!L.drop_item())
								return
							Attach(colour, A)
						else
							L << "<span class='warning'>You need a attachable assembly!</span>"




		// Update Window
			Interact(usr)

	if(href_list["close"])
		usr << browse(null, "window=wires")
		usr.unset_machine(holder)

//
// Overridable Procs
//

// Called when wires cut/mended.
/datum/wires/proc/UpdateCut(index, mended)
	return

// Called when wire pulsed. Add code here.
/datum/wires/proc/UpdatePulsed(index)
	return

/datum/wires/proc/CanUse(mob/living/L)
	return 1

// Example of use:
/*

var/const/BOLTED= 1
var/const/SHOCKED = 2
var/const/SAFETY = 4
var/const/POWER = 8

/datum/wires/door/UpdateCut(var/index, var/mended)
	var/obj/machinery/door/airlock/A = holder
	switch(index)
		if(BOLTED)
		if(!mended)
			A.bolt()
	if(SHOCKED)
		A.shock()
	if(SAFETY )
		A.safety()

*/


//
// Helper Procs
//

/datum/wires/proc/PulseColour(colour)
	PulseIndex(GetIndex(colour))

/datum/wires/proc/PulseIndex(index)
	if(IsIndexCut(index))
		return
	UpdatePulsed(index)

/datum/wires/proc/GetIndex(colour)
	if(wires[colour])
		var/index = wires[colour]
		return index
	else
		CRASH("[colour] is not a key in wires.")

//
// Is Index/Colour Cut procs
//

/datum/wires/proc/IsColourCut(colour)
	var/index = GetIndex(colour)
	return IsIndexCut(index)

/datum/wires/proc/IsIndexCut(index)
	return (index & wires_status)

//
// Signaller Procs
//

/datum/wires/proc/IsAttached(colour)
	if(signallers[colour])
		return 1
	return 0

/datum/wires/proc/GetAttached(colour)
	if(signallers[colour])
		return signallers[colour]
	return null

/datum/wires/proc/Attach(colour, obj/item/device/assembly/S)
	if(colour && S && S.attachable)
		if(!IsAttached(colour))
			signallers[colour] = S
			S.loc = holder
			S.connected = src
			return S

/datum/wires/proc/Detach(colour)
	if(colour)
		var/obj/item/device/assembly/S = GetAttached(colour)
		if(S)
			signallers -= colour
			S.connected = null
			S.loc = holder.loc
			return S


/datum/wires/proc/Pulse(obj/item/device/assembly/S)

	for(var/colour in signallers)
		if(S == signallers[colour])
			PulseColour(colour)
			break


//
// Cut Wire Colour/Index procs
//

/datum/wires/proc/CutWireColour(colour)
	var/index = GetIndex(colour)
	CutWireIndex(index)

/datum/wires/proc/CutWireIndex(index)
	if(IsIndexCut(index))
		wires_status &= ~index
		UpdateCut(index, 1)
	else
		wires_status |= index
		UpdateCut(index, 0)

/datum/wires/proc/RandomCut()
	var/r = rand(1, wires.len)
	CutWireIndex(r)

/datum/wires/proc/CutAll()
	for(var/i = 1; i < MAX_FLAG && i < (1 << wire_count); i += i)
		CutWireIndex(i)

/datum/wires/proc/IsAllCut()
	if(wires_status == (1 << wire_count) - 1)
		return 1
	return 0

//
//Shuffle and Mend
//

/datum/wires/proc/Shuffle()
	wires_status = 0
	GenerateWires()