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

/datum/wires/Destroy()
	holder = null
	signallers = list()
	return ..()

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

/datum/wires/proc/IsInteractionTool(obj/item/I)
	if(istype(I, /obj/item/device/multitool))
		return 1

	if(istype(I, /obj/item/weapon/wirecutters))
		return 1

	if(istype(I, /obj/item/device/assembly))
		var/obj/item/device/assembly/A = I
		if(A.attachable)
			return 1

	return 0

/datum/wires/ui_interact(mob/user, ui_key = "wires", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = wire_state)
	
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "wires", holder.name, 200 + wire_count*50, 470, master_ui, state)
		ui.open()

/datum/wires/proc/Interact(mob/living/user)
	if(holder && CanUse(user)) //remove this
		ui_interact(user)
		//Active prox sensors and similar on wires
		for(var/A in signallers)
			if(istype(signallers[A], /obj/item))
				var/obj/item/I = signallers[A]
				if(I.on_found(user))
					return

/datum/wires/proc/getStatus()
	return

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

/datum/wires/proc/GetColour(index)
	for(var/colour in wires)
		if(wires[colour] == index)
			return colour

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

/datum/wires/get_ui_data()
	var/list/data = list()
	var/list/payload = list()
	for(var/colour in wires)
		payload.Add(list(list("colour"=colour,"isCut"=IsColourCut(colour),"hasAttachment"=IsAttached(colour))))
	data["wires"] = payload
	data["holderInfo"] = getStatus()
	return data

/datum/wires/ui_act(action, params)
	if(..())
		return

	var/target_wire = params["wire"]
	var/mob/living/L = usr
	if(!istype(L) || !CanUse(L)) //only physical beings can touch these. Sorry admins, maybe later
		return
	var/obj/item/I = L.get_active_hand()
	switch(action)
		if("cut")
			if(istype(I, /obj/item/weapon/wirecutters))
				CutWireColour(target_wire)
			else
				L << "<span class='warning'>You need wirecutters!</span>"
		if("pulse")
			if(istype(I, /obj/item/device/multitool))
				PulseColour(target_wire)
			else
				L << "<span class='warning'>You need a multitool!</span>"
		if("attach")
			//Detach
			if(IsAttached(target_wire))
				var/obj/item/O = Detach(target_wire)
				if(O)
					L.put_in_hands(O)
			// Attach
			else
				if(istype(I, /obj/item/device/assembly))
					var/obj/item/device/assembly/A = I;
					if(A.attachable)
						if(!L.drop_item())
							return
						Attach(target_wire, A)
					else
						L << "<span class='warning'>You need an attachable assembly!</span>"
	return 1