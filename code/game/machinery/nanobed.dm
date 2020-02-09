#define NANITE_TOGGLE_COOLDOWN 10
/**
A special medical bed that stores a nanite swarm, which is applied to the patient on activation.
Effectively this allows use of nanites for medical use without requiring commitment,
as well as allowing a specific cloud setup for medical purposes, which would be wasteful if kept active on a normal host.
**/
/obj/machinery/nanobed
	name = "Nanite Bed"
	desc = "A bed that is designed to heal patients lying on it with temporary nanites."
	icon = 'icons/obj/machines/nanobed.dmi'
	icon_state = "nanobed"
	circuit = /obj/item/circuitboard/machine/nanobed
	density = FALSE
	can_buckle = TRUE
	buckle_lying = 90
	idle_power_usage = 40
	active_power_usage = 340
	var/datum/component/nanites/guest/internal_nanites ///The nanite component that does the action
	var/nanite_active = FALSE ///Checks if the bed is currently distributing nanites
	var/nanite_can_toggle = 0 ///Prevents spamming nanite toggling
	var/obj/machinery/computer/operating/op_computer ///The connected operating computer for surgeries
	var/obj/effect/overlay/vis/mattress_on ///Overlay of the mattress during activity

///Creates the nanite component as well as linking any adjacent operating computer
/obj/machinery/nanobed/Initialize()
	. = ..()
	internal_nanites = AddComponent(/datum/component/nanites/guest, 100, 1, 1)
	for(var/direction in GLOB.cardinals)
		op_computer = locate(/obj/machinery/computer/operating, get_step(src, direction))
		if(op_computer)
			op_computer.nbed = src
			break

///Cleans up the internal nanites and unlinks the operating computer if there is one
/obj/machinery/nanobed/Destroy()
	qdel(internal_nanites)
	if(op_computer && op_computer.nbed == src)
		op_computer.nbed = null
	return ..()

/obj/machinery/nanobed/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The nanite volume meter indicates <b>[internal_nanites.nanite_volume]/[internal_nanites.max_nanites]</b>.</span>"
	. += "<span class='notice'>Alt-click to [nanite_active ? "turn off" : "turn on"] the machine.</span>"
	. += "<span class='notice'>\The [src] is [op_computer ? "linked" : "<b>NOT</b> linked"] to a nearby operating computer.</span>"

/obj/machinery/nanobed/AltClick(mob/user)
	if(world.time >= nanite_can_toggle && user.canUseTopic(src, BE_CLOSE))
		nanite_active = !nanite_active
		nanite_can_toggle = world.time + NANITE_TOGGLE_COOLDOWN
		playsound(src, 'sound/machines/click.ogg', 60, TRUE)
		user.visible_message("<span class='notice'>\The [src] [nanite_active ? "powers on" : "shuts down"].</span>", \
					"<span class='notice'>You [nanite_active ? "power on" : "shut down"] \the [src].</span>", \
					"<span class='hear'>You hear a nearby machine [nanite_active ? "power on" : "shut down"].</span>")
		update_icon()

/obj/machinery/nanobed/Exited(atom/movable/AM, atom/newloc)
	if(AM == occupant)
		internal_nanites.unset_host_mob()
	. = ..()

/obj/machinery/nanobed/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "nanobed_broken"
		return
	if(panel_open || machine_stat & MAINT)
		icon_state = "nanobed_maintenance"
		return
	icon_state = "nanobed"

/obj/machinery/nanobed/update_overlays()
	. = ..()
	if(nanites_running())
		. += "nanobed_on"

/obj/machinery/nanobed/proc/nanites_running()
	return nanite_active && is_operational()

/obj/machinery/nanobed/proc/link_nanites(mob/living/target)
	if(target != occupant)
		return
	var/success = internal_nanites.set_host_mob(target)
	if(!success)
		playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE, 2)
		say("Target not compatible with nanites.")
		return
	playsound(src, 'sound/machines/triple_beep.ogg', 50, TRUE, 2)
	say("Nanite link established successfully.")
	use_power = ACTIVE_POWER_USE

/obj/machinery/nanobed/proc/unlink_nanites()
	internal_nanites.unset_host_mob()
	use_power = IDLE_POWER_USE

/obj/machinery/nanobed/post_buckle_mob(mob/living/L)
	if(!can_be_occupant(L))
		return
	occupant = L
	if(nanites_running())
		link_nanites(L)
	update_icon()

///Used for the surgery computer
/obj/machinery/nanobed/proc/check_patient()
	if(occupant)
		return TRUE
	else
		return FALSE

/obj/machinery/nanobed/post_unbuckle_mob(mob/living/L)
	if(L == occupant)
		unlink_nanites()
		occupant = null
	update_icon()

/obj/machinery/nanobed/process()
	if(!(occupant && isliving(occupant)))
		use_power = IDLE_POWER_USE
		return
	var/mob/living/L = occupant
	if(nanites_running())
		//If we somehow have an occupant that isn't the nanites' target, switch the link to the new mob
		if(occupant != internal_nanites.host_mob)
			link_nanites(L)
	else if(internal_nanites.host_mob)
		//Unlink nanites if the bed stops working
		unlink_nanites()

/obj/machinery/nanobed/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	. |= default_deconstruction_screwdriver(user, "nanobed_maintenance", "nanobed", I)
	update_icon()

/obj/machinery/nanobed/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	return default_deconstruction_crowbar(I) || .

/obj/machinery/nanobed/attack_robot(mob/user)
	if(Adjacent(user) && occupant)
		unbuckle_mob(occupant)
	else
		..()

/obj/machinery/nanobed/interact(mob/user)
	//If clicking would unbuckle the occupant, do that instead
	if(Adjacent(user) && occupant)
		return FALSE
	. = ..()

/obj/machinery/nanobed/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanobed", name, 400, 300, master_ui, state)
		ui.open()

/obj/machinery/nanobed/ui_data()
	var/list/data = list()
	data["active"] = nanite_active
	data["cloud_id"] = internal_nanites.cloud_id
	return data

/obj/machinery/nanobed/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle_active")
			AltClick(usr)
			. = TRUE
		if("set_cloud")
			var/new_cloud = text2num(params["code"])
			if(!isnull(new_cloud))
				new_cloud = CLAMP(round(new_cloud, 1),1,100)
				internal_nanites.set_cloud(usr, new_cloud)
			. = TRUE

#undef NANITE_TOGGLE_COOLDOWN
