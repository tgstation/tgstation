/obj/mecha/combat
	force = 30
	internal_damage_threshold = 50
	damage_absorption = list("brute"=0.7,"fire"=1,"bullet"=0.7,"laser"=0.85,"energy"=1,"bomb"=0.8)
	var/am = "d3c2fbcadca903a41161ccc9df9cf948"
	var/thrusters = 0
	var/datum/action/mecha/mech_toggle_thrusters/thrusters_action = new

/obj/mecha/combat/moved_inside(mob/living/carbon/human/H)
	if(..())
		if(H.client)
			H.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0

/obj/mecha/combat/mmi_moved_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	if(..())
		if(occupant.client)
			occupant.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0


/obj/mecha/combat/go_out()
	if(src.occupant && src.occupant.client)
		src.occupant.client.mouse_pointer_icon = initial(src.occupant.client.mouse_pointer_icon)
	..()
	return

/obj/mecha/combat/Topic(href,href_list)
	..()
	var/datum/topic_input/filter = new (href,href_list)
	if(filter.get("close"))
		am = null
		return

/obj/mecha/combat/Process_Spacemove(movement_dir = 0)
	if(..())
		return 1
	if(thrusters && movement_dir && use_power(step_energy_drain))
		return 1
	return 0

/datum/action/mecha/mech_toggle_thrusters
	name = "Toggle Thrusters"
	button_icon_state = "mech_thrusters_off"

/datum/action/mecha/mech_toggle_thrusters/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/combat/M = chassis
	if(M.get_charge() > 0)
		M.thrusters = !M.thrusters
		button_icon_state = "mech_thrusters_[M.thrusters ? "on" : "off"]"
		M.log_message("Toggled thrusters.")
		M.occupant_message("<font color='[M.thrusters?"blue":"red"]'>Thrusters [M.thrusters?"en":"dis"]abled.")
