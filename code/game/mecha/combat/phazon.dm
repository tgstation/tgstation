/obj/mecha/combat/phazon
	desc = "An exosuit which can only be described as 'WTF?'."
	name = "Phazon"
	icon_state = "phazon"
	step_in = 1
	dir_in = 1 //Facing North.
	step_energy_drain = 3
	health = 200
	deflect_chance = 30
	damage_absorption = list("brute"=0.7,"fire"=0.7,"bullet"=0.7,"laser"=0.7,"energy"=0.7,"bomb"=0.7)
	max_temperature = 1000
	infra_luminosity = 3
	wreckage = /obj/effect/decal/mecha_wreckage/phazon
	add_req_access = 1
	//operation_req_access = list()
	internal_damage_threshold = 25
	force = 15
	var/phasing = 0
	var/phasing_energy_drain = 200
	max_equip = 4


/obj/mecha/combat/phazon/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/rcd
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/gravcatapult
	ME.attach(src)
	return

/obj/mecha/combat/phazon/Bump(var/atom/obstacle)
	if(phasing && get_charge()>=phasing_energy_drain)
		spawn()
			if(can_move)
				can_move = 0
				flick("phazon-phase", src)
				src.loc = get_step(src,src.dir)
				src.use_power(phasing_energy_drain)
				sleep(step_in*3)
				can_move = 1
	else
		. = ..()
	return

/obj/mecha/combat/phazon/click_action(atom/target,mob/user)
	if(phasing)
		src.occupant_message("Unable to interact with objects while phasing")
		return
	else
		return ..()

/obj/mecha/combat/phazon/verb/switch_damtype()
	set category = "Exosuit Interface"
	set name = "Change melee damage type"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return
	var/new_damtype = alert(src.occupant,"Melee Damage Type",null,"Brute","Fire","Toxic")
	switch(new_damtype)
		if("Brute")
			damtype = "brute"
		if("Fire")
			damtype = "fire"
		if("Toxic")
			damtype = "tox"
	src.occupant_message("Melee damage type switched to [new_damtype ]")
	return

/obj/mecha/combat/phazon/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];phasing=1'><span id="phasing_command">[phasing?"Dis":"En"]able phasing</span></a><br>
						<a href='?src=\ref[src];switch_damtype=1'>Change melee damage type</a><br>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/phazon/Topic(href, href_list)
	..()
	if (href_list["switch_damtype"])
		src.switch_damtype()
	if (href_list["phasing"])
		phasing = !phasing
		send_byjax(src.occupant,"exosuit.browser","phasing_command","[phasing?"Dis":"En"]able phasing")
		src.occupant_message("<font color=\"[phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")
	return