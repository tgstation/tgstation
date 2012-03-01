/obj/mecha/combat/marauder
	desc = "Heavy-duty, combat exosuit, developed after the Durand model. Rarely found among civilian populations."
	name = "Marauder"
	icon_state = "marauder"
	step_in = 5
	health = 500
	deflect_chance = 25
	damage_absorption = list("brute"=0.5,"fire"=0.7,"bullet"=0.45,"laser"=0.6,"energy"=0.7,"bomb"=0.7)
	max_temperature = 5000
	infra_luminosity = 3
	var/zoom = 0
	var/thrusters = 0
	var/smoke = 5
	var/smoke_ready = 1
	var/smoke_cooldown = 100
	var/datum/effect/effect/system/harmless_smoke_spread/smoke_system = new
	operation_req_access = list(access_cent_specops)
	wreckage = /obj/effect/decal/mecha_wreckage/marauder
	add_req_access = 0
	internal_damage_threshold = 25
	force = 45
	max_equip = 4

/obj/mecha/combat/marauder/seraph
	desc = "Heavy-duty, command-type exosuit. This is a custom model, utilized only by high-ranking military personnel."
	name = "Seraph"
	icon_state = "seraph"
	operation_req_access = list(access_cent_creed)
	step_in = 3
	health = 550
	wreckage = /obj/effect/decal/mecha_wreckage/seraph
	internal_damage_threshold = 20
	force = 55
	max_equip = 5

/obj/mecha/combat/marauder/mauler
	desc = "Heavy-duty, combat exosuit, developed off of the existing Marauder model."
	name = "Mauler"
	icon_state = "mauler"
	operation_req_access = list(access_syndicate)
	wreckage = /obj/effect/decal/mecha_wreckage/mauler

/obj/mecha/combat/marauder/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	src.smoke_system.set_up(3, 0, src)
	src.smoke_system.attach(src)
	return

/obj/mecha/combat/marauder/seraph/New()
	..()//Let it equip whatever is needed.
	var/obj/item/mecha_parts/mecha_equipment/ME
	if(equipment.len)//Now to remove it and equip anew.
		for(ME in equipment)
			equipment -= ME
			del(ME)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	return

/obj/mecha/combat/marauder/relaymove(mob/user,direction)
	if(user != src.occupant) //While not "realistic", this piece is player friendly.
		user.loc = get_turf(src)
		user << "You climb out from [src]"
		return 0
	if(!can_move)
		return 0
	if(zoom)
		if(world.time - last_message > 20)
			src.occupant_message("Unable to move while in zoom mode.")
			last_message = world.time
		return 0
	if(connected_port)
		if(world.time - last_message > 20)
			src.occupant_message("Unable to move while connected to the air system port")
			last_message = world.time
		return 0
	if(!thrusters && src.pr_inertial_movement.active())
		return 0
	if(state || !get_charge())
		return 0
	var/tmp_step_in = step_in
	var/tmp_step_energy_drain = step_energy_drain
	var/move_result = 0
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		move_result = mechsteprand()
	else if(src.dir!=direction)
		move_result = mechturn(direction)
	else
		move_result	= mechstep(direction)
	if(move_result)
		if(istype(src.loc, /turf/space))
			if(!src.check_for_support())
				src.pr_inertial_movement.start(list(src,direction))
				if(thrusters)
					src.pr_inertial_movement.set_process_args(list(src,direction))
					tmp_step_energy_drain = step_energy_drain*2

		can_move = 0
		spawn(tmp_step_in) can_move = 1
		use_power(tmp_step_energy_drain)
		return 1
	return 0


/obj/mecha/combat/marauder/verb/toggle_thrusters()
	set category = "Exosuit Interface"
	set name = "Toggle thrusters"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return
	if(src.occupant)
		if(get_charge() > 0)
			thrusters = !thrusters
			src.log_message("Toggled thrusters.")
			src.occupant_message("<font color='[src.thrusters?"blue":"red"]'>Thrusters [thrusters?"en":"dis"]abled.")
	return


/obj/mecha/combat/marauder/verb/smoke()
	set category = "Exosuit Interface"
	set name = "Smoke"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return
	if(smoke_ready && smoke>0)
		src.smoke_system.start()
		smoke--
		smoke_ready = 0
		spawn(smoke_cooldown)
			smoke_ready = 1
	return

/obj/mecha/combat/marauder/verb/zoom()
	set category = "Exosuit Interface"
	set name = "Zoom"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return
	if(src.occupant.client)
		src.zoom = !src.zoom
		src.log_message("Toggled zoom mode.")
		src.occupant_message("<font color='[src.zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>")
		if(zoom)
			src.occupant.client.view = 12
			src.occupant << sound('imag_enh.ogg',volume=50)
		else
			src.occupant.client.view = world.view//world.view - default mob view size
	return


/obj/mecha/combat/marauder/go_out()
	if(src.occupant && src.occupant.client)
		src.occupant.client.view = world.view
		src.zoom = 0
	..()
	return


/obj/mecha/combat/marauder/get_stats_part()
	var/output = ..()
	output += {"<b>Smoke:</b> [smoke]
					<br>
					<b>Thrusters:</b> [thrusters?"on":"off"]
					"}
	return output


/obj/mecha/combat/marauder/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_thrusters=1'>Toggle thrusters</a><br>
						<a href='?src=\ref[src];toggle_zoom=1'>Toggle zoom mode</a><br>
						<a href='?src=\ref[src];smoke=1'>Smoke</a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/marauder/Topic(href, href_list)
	..()
	if (href_list["toggle_thrusters"])
		src.toggle_thrusters()
	if (href_list["smoke"])
		src.smoke()
	if (href_list["toggle_zoom"])
		src.zoom()
	return