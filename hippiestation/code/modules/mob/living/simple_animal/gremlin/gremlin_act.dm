/obj/proc/npc_tamper_act(mob/living/L)
	return NPC_TAMPER_ACT_FORGET

/obj/machinery/atmospherics/components/binary/passive_gate/npc_tamper_act(mob/living/L)
	if(prob(50)) //Turn on/off
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(L)]", INVESTIGATE_ATMOS)
	else //Change pressure
		target_pressure = rand(0, MAX_OUTPUT_PRESSURE)
		investigate_log("was set to [target_pressure] kPa by [key_name(L)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/npc_tamper_act(mob/living/L)
	if(prob(50)) //Turn on/off
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(L)]", INVESTIGATE_ATMOS)
	else //Change pressure
		target_pressure = rand(0, MAX_OUTPUT_PRESSURE)
		investigate_log("was set to [target_pressure] kPa by [key_name(L)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/volume_pump/npc_tamper_act(mob/living/L)
	if(prob(50)) //Turn on/off
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(L)]", INVESTIGATE_ATMOS)
	else //Change pressure
		transfer_rate = rand(0, MAX_TRANSFER_RATE)
		investigate_log("was set to [transfer_rate] L/s by [key_name(L)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/valve/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/space_heater/npc_tamper_act(mob/living/L)
	var/list/choose_modes = list("standby", "heat", "cool")
	if(prob(50))
		choose_modes -= mode
		mode = pick(choose_modes)
	else
		on = !on
	update_icon()

/obj/machinery/shield_gen/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/firealarm/npc_tamper_act(mob/living/L)
	alarm()

/obj/machinery/airalarm/npc_tamper_act(mob/living/L)
	if(panel_open)
		wires.npc_tamper(L)
	else
		panel_open = !panel_open

/obj/machinery/ignition_switch/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/flasher_button/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/crema_switch/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/camera/npc_tamper_act(mob/living/L)
	if(!panel_open)
		panel_open = !panel_open
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/atmospherics/components/unary/cryo_cell/npc_tamper_act(mob/living/L)
	if(prob(50))
		if(beaker)
			beaker.forceMove(loc)
			beaker = null
	else
		if(occupant)
			if(state_open)
				if (close_machine() == usr)
					on = TRUE
			else
				open_machine()

/obj/machinery/door_control/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/door/airlock/npc_tamper_act(mob/living/L)
	//Open the firelocks as well, otherwise they block the way for our gremlin which isn't fun
	for(var/obj/machinery/door/firedoor/F in get_turf(src))
		if(F.density)
			F.npc_tamper_act(L)

	if(prob(40)) //40% - mess with wires
		if(!panel_open)
			panel_open = !panel_open
		if(wires)
			wires.npc_tamper(L)
	else //60% - just open it
		open()

/obj/machinery/gibber/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/light_switch/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/turretid/npc_tamper_act(mob/living/L)
	enabled = rand(0, 1)
	lethal = rand(0, 1)
	updateTurrets()

/obj/machinery/vending/npc_tamper_act(mob/living/L)
	if(!panel_open)
		panel_open = !panel_open
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/shower/npc_tamper_act(mob/living/L)
	attack_hand(L)


/obj/machinery/cooking/deepfryer/npc_tamper_act(mob/living/L)
	//Deepfry a random nearby item
	var/list/pickable_items = list()

	for(var/obj/item/I in range(1, L))
		pickable_items.Add(I)

	if(!pickable_items.len)
		return

	var/obj/item/I = pick(pickable_items)

	attackby(I, L) //shove the item in, even if it can't be deepfried normally

/obj/machinery/power/apc/npc_tamper_act(mob/living/L)
	if(!panel_open)
		panel_open = !panel_open
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/power/rad_collector/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/power/emitter/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/particle_accelerator/control_box/npc_tamper_act(mob/living/L)
	if(!panel_open)
		panel_open = !panel_open
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/computer/communications/npc_tamper_act(mob/living/user)
	if(!authenticated)
		if(prob(20)) //20% chance to log in
			authenticated = TRUE

	else //Already logged in
		if(prob(50)) //50% chance to log off
			authenticated = FALSE
		else if(istype(user, /mob/living/simple_animal/hostile/gremlin)) //make a hilarious public message
			var/mob/living/simple_animal/hostile/gremlin/G = user
			var/result = G.generate_markov_chain()

			if(result)
				if(prob(85))
					SScommunications.make_announcement(G, FALSE, result)
					var/turf/T = get_turf(G)
					log_say("[key_name(usr)] ([ADMIN_JMP(T)]) has made a captain announcement: [result]")
					message_admins("[key_name_admin(G)] has made a captain announcement.", 1)
				else
					if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
						SSshuttle.requestEvac(G, result)
					else if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
						SSshuttle.cancelEvac(G)

/obj/machinery/button/door/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/machinery/sleeper/npc_tamper_act(mob/living/L)
	if(prob(75))
		inject_chem(pick(available_chems))
	else
		if(state_open)
			close_machine()
		else
			open_machine()

/obj/machinery/power/smes/npc_tamper_act(mob/living/L)
	if(prob(50)) //mess with input
		input_level = rand(0, input_level_max)
	else //mess with output
		output_level = rand(0, output_level_max)

/obj/machinery/syndicatebomb/npc_tamper_act(mob/living/L) //suicide bomber gremlins
	if(!open_panel)
		open_panel = !open_panel
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/computer/bank_machine/npc_tamper_act(mob/living/L)
	siphoning = !siphoning

/obj/machinery/computer/slot_machine/npc_tamper_act(mob/living/L)
	spin(L)