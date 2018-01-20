#define DAMAGE			1
#define FIRE			2
#define LIGHT			1
#define WINDOW			2
#define RIM	    		3
#define PAINT			4

/obj/item/pod_paint_bucket
	name = "space pod paintkit"
	desc = "Pimp your ride"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "paint_red"

/obj/vehicle/sealed/spacepod
	name = "\improper space pod"
	desc = "A space pod meant for space travel."
	icon = 'goon/icons/48x48/pods.dmi'


	max_integrity = 250
	flags_2 = UNACIDABLE | HEAR_1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hud_possible = list(DIAG_HUD, DIAG_BATT_HUD)

	density = TRUE //Dense. To raise the heat.
	opacity = FALSE
	anchored = TRUE // So you can't push it.

	layer = SPACEPOD_LAYER

	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/use_internal_tank = TRUE
	var/internal_tank_valve = ONE_ATMOSPHERE

	var/mutable_appearance/list/pod_overlays
	var/list/pod_paint_effect
	var/list/colors = new/list(4)

	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell

	var/obj/item/device/radio/mech/radio
	var/obj/item/device/gps/gps



	autogrant_actions_passenger = list(/datum/action/vehicle/spacepod/exit)

	hud_possible = list(DIAG_HUD, DIAG_BATT_HUD)


	var/has_paint = FALSE
	var/hatch_open = FALSE

	var/empcounter = 0 //Used for disabling movement when hit by an EMP
	var/next_move = 0



	var/lights = FALSE
	var/lights_power = 6
	var/list/icon_light_color = list(POD_CIV = null, \
									 POD_SEC = "#BBF093", \
									 POD_SYNDIE = LIGHT_COLOR_RED, \
									 POD_GOLD = null, \
									 POD_BLACK = "#3B8FE5", \
									 POD_ENGO = "#CCCC00")



	max_occupants = 1
	max_drivers = 1
	var/obj/item/storage/internal/cargo_hold

	var/datum/pod_armor/pod_armor
	var/armor_multiplier_applied = FALSE //used for determining if the construction process already applied the armor multiplier
	var/internal_temp_regulation = TRUE

	var/unlocked = TRUE
	var/panel_open = FALSE

	var/list/equipment = list()

	bound_width = 64
	bound_height = 64

	var/next_firetime = 0
	var/list/starting_equipment

	var/has_power_been_lost = FALSE

/obj/vehicle/sealed/spacepod/generate_actions()
	for(var/SA in list( \
			/datum/action/vehicle/spacepod/lockpod, \
			/datum/action/vehicle/spacepod/poddoor,\
			/datum/action/vehicle/spacepod/weapons,\
			/datum/action/vehicle/spacepod/cargo, \
			/datum/action/vehicle/spacepod/lights, \
			/datum/action/vehicle/spacepod/checkseat,\
			/datum/action/vehicle/spacepod/airtank \
		))
		initialize_controller_action_type(SA, VEHICLE_CONTROL_PERMISSION)
	initialize_passenger_action_type(/datum/action/vehicle/spacepod/exit)


/obj/vehicle/sealed/spacepod/Initialize(mapload, datum/pod_armor/p_armor_type = /datum/pod_armor/civ , already_applying=FALSE)
	. = ..(mapload)

	setDir(EAST)
	cell = new cell_type(src)
	add_cabin()
	add_radio()
	add_airtank()
	add_gps()

	use_internal_tank = TRUE
	GLOB.poi_list += src

	GLOB.spacepods_list += src
	START_PROCESSING(SSobj, src)
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_podhealth()
	diag_hud_set_podcharge()
	if(!armor_multiplier_applied && !already_applying)
		pod_armor = new p_armor_type
		max_integrity *= pod_armor.armor_multiplier
		obj_integrity *= pod_armor.armor_multiplier
		armor_multiplier_applied = TRUE
	cargo_hold = new/obj/item/storage/internal(src)
	cargo_hold.w_class = 5	//so you can put bags in
	cargo_hold.storage_slots = 0	//You need to install cargo modules to use it.
	cargo_hold.max_w_class = 5		//fit almost anything
	cargo_hold.max_combined_w_class = 0 //you can optimize your stash with larger items

	for(var/turf/T in locs)
		for(var/obj/structure/spacepod_frame/I in T.contents)
			qdel(I)

	if(LAZYLEN(starting_equipment))
		for(var/A in starting_equipment)
			var/obj/item/device/spacepod_equipment/SE = new A(src)
			add_equipment(E=SE)


/obj/vehicle/sealed/spacepod/Destroy()
	QDEL_NULL(cargo_hold)
	QDEL_NULL(cell)
	if(loc)
		loc.assume_air(cabin_air)
		air_update_turf()
	QDEL_NULL(cabin_air)
	QDEL_NULL(internal_tank)
	GLOB.spacepods_list -= src
	GLOB.poi_list.Remove(src)
	for(var/mob/M in occupants)
		M.clear_alert("charge")
		M.clear_alert("mech damage")
		remove_occupant(M)
	STOP_PROCESSING(SSobj, src)
	return ..()


///////////////////
////SETUP PROCS////
///////////////////
/obj/vehicle/sealed/spacepod/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	cabin_air.gases[/datum/gas/oxygen][MOLES] = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.gases[/datum/gas/nitrogen][MOLES] = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/vehicle/sealed/spacepod/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/vehicle/sealed/spacepod/proc/add_radio()
	radio = new(src)
	radio.name = "[name] radio"
	radio.desc = "if you see this then you should probably file a bug report"
	radio.subspace_transmission = TRUE
	radio.broadcasting = FALSE

/obj/vehicle/sealed/spacepod/proc/add_gps()
	gps = new(src)
	gps.name = "[name] gps"
	gps.desc = "if you see this then you should probably file a bug report"
	gps.icon = icon
	gps.icon_state = icon_state
	gps.gpstag = "SPOD"


/////////////////////////
////ATMOSPHERIC PROCS////
/////////////////////////

/obj/vehicle/sealed/spacepod/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	return ..()

/obj/vehicle/sealed/spacepod/return_air()
	if(use_internal_tank)
		return cabin_air
	return ..()

/obj/vehicle/sealed/spacepod/proc/return_pressure()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_pressure()
	return


////////////////////
////DAMAGE PROCS////
////////////////////

/obj/vehicle/sealed/spacepod/attack_alien(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(15)
	playsound(loc, 'sound/weapons/slash.ogg', 50, 1, -1)
	to_chat(user, "<span class='warning'>You slash at [src]!</span>")
	visible_message("<span class='warning'>The [user] slashes at [name]'s armor!</span>")
	return

/obj/vehicle/sealed/spacepod/proc/explodify()
	QDEL_IN(src, 10)
	message_to_riders("<span class='userdanger'>Exit the spacepod immediately, explosion immi-</span>")
	explosion(loc, 2, 4, 8)
	visible_message("<span class='danger'>[src] violently explodes!</span>")
	var/turf/T = get_turf(src)
	log_game("The spacepod \[name: [name], [format_pilot_text()]\] exploded at [COORD(T)]!")
	message_admins("The spacepod \[name: [name], [format_pilot_text()]\] exploded at [ADMIN_JMP(T)]!")
	qdel(src)

/obj/vehicle/sealed/spacepod/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	log_attack("[user] attacked the spacepod \[name: [name], [format_pilot_text()]\] with [I]!")
	update_icon()

/obj/vehicle/sealed/spacepod/take_damage(damage, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	var/percentage = (obj_integrity / max_integrity) * 100
	if(percentage <= 25 && percentage > 0)
		play_sound_to_riders('sound/effects/alert.ogg')
		message_to_riders("<span class='danger'>Pod integrity at [percentage]%!</span>")
	update_icon()
	diag_hud_set_podhealth()

/obj/vehicle/sealed/spacepod/proc/repair_damage(repair_amount)
	if(obj_integrity)
		obj_integrity = min(max_integrity, obj_integrity + repair_amount)
		update_icon()
		diag_hud_set_podhealth()

/obj/vehicle/sealed/spacepod/obj_destruction(damage_flag)
	var/turf/T = get_turf(src)
	message_to_riders("<span class='userdanger'>Critical damage to the vessel detected, core explosion imminent!</span>")
	message_admins("The spacepod, \[[name]\], is about to explode at [ADMIN_JMP(T)]!")
	addtimer(CALLBACK(src, .proc/explodify), 50)


/obj/vehicle/sealed/spacepod/ex_act(severity)
	switch(severity)
		if(1)
			if(LAZYLEN(occupants))
				for(var/mob/living/M in occupants)
					var/mob/living/carbon/human/H = M
					if(H)
						remove_occupant(H)
						H.forceMove(get_turf(src))
						H.ex_act(severity + 1)
						to_chat(H, "<span class='warning'>You are forcefully thrown from [src]!</span>")
			qdel(src)
		if(2)
			take_damage(100)
		if(3)
			if(prob(40))
				take_damage(50)


/obj/vehicle/sealed/spacepod/bullet_act(obj/item/projectile/P)
	. = ..(P)
	if(P.damage_type == BRUTE || P.damage_type == BURN)
		take_damage(P.damage)

/obj/vehicle/sealed/spacepod/blob_act()
	take_damage(30)
	return

/obj/vehicle/sealed/spacepod/attack_animal(mob/living/simple_animal/user as mob)
	if(user.melee_damage_upper == 0)
		user.emote(1, "[user.friendly] [src]")
	else
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		take_damage(damage)
		visible_message("<span class='danger'>[user]</span> [user.attacktext] [src]!")
		log_attack("<font color='red'>attacked [name]</font>")
	return

/obj/vehicle/sealed/spacepod/emp_act(severity)
	cargo_hold.emp_act(severity)

	if(cell && cell.charge > 0)
		cell.use((cell.charge/3)/(severity*2))
	take_damage(80 / severity)
	if(empcounter < (40 / severity))
		empcounter = 40 / severity

	switch(severity)
		if(1)
			message_to_riders("<span class='warning'>The pod console flashes 'Heavy EMP WAVE DETECTED'.</span>")
		if(2)
			message_to_riders("<span class='warning'>The pod console flashes 'EMP WAVE DETECTED'.</span>")

	if (prob(50/severity))
		internal_temp_regulation = FALSE
		message_to_riders("<span class='warning'>The pod console flashes 'TEMPERATURE REGULATION OFFLINE! REBOOTING SYSTEM.'.</span>")
		addtimer(CALLBACK(src, .proc/fixReg), 300/severity)

/obj/vehicle/sealed/spacepod/proc/fixReg()
	internal_temp_regulation = TRUE
	message_to_riders("<span class='notice'>The pod console displays 'Temperature regulation online. Have a safe day!'.</span>")


///////////////////////////
////COMMUNICATION PROCS////
///////////////////////////

/obj/vehicle/sealed/spacepod/proc/play_sound_to_riders(mysound)
	if(!LAZYLEN(occupants))
		return
	var/sound/S = sound(mysound)
	S.volume = 50
	for(var/mob/living/M in occupants)
		SEND_SOUND(M, S)

/obj/vehicle/sealed/spacepod/proc/message_to_riders(mymessage)
	if(!LAZYLEN(occupants))
		return
	for(var/mob/living/M in occupants)
		to_chat(M, mymessage)


/obj/vehicle/sealed/spacepod/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(speaker in occupants)
		if(radio.broadcasting)
			radio.talk_into(speaker, text, , spans, message_language)
		//flick speech bubble
		var/list/speech_bubble_recipients = list()
		for(var/mob/M in get_hearers_in_view(7,src))
			if(M.client)
				speech_bubble_recipients.Add(M.client)
		INVOKE_ASYNC(GLOBAL_PROC, /.proc/flick_overlay, image('icons/mob/talk.dmi', src, "machine[say_test(raw_message)]",SPACEPOD_LAYER+1), speech_bubble_recipients, 30)
	cargo_hold.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)
	return ..()


//////////////////
////MISC PROCS////
//////////////////

/obj/vehicle/sealed/spacepod/proc/get_driver()
	var/list/_M = return_controllers_with_flag(VEHICLE_CONTROL_DRIVE) //there shouldn't be more than one person with VEHICLE_CONTROL_DRIVE and if there is then whoever VV'd the max_drivers should be kicked in the nuts
	if(LAZYLEN(_M) && _M[1])
		return _M[1]

/obj/vehicle/sealed/spacepod/proc/format_pilot_text()
	var/mob/M = get_driver()
	if(M)
		return "pilot: [M], ckey [M.ckey]"
	else
		return "no pilot"

/obj/vehicle/sealed/spacepod/after_add_occupant(mob/M)
	. = ..()
	if(is_driver(M))
		M.verbs += /obj/vehicle/sealed/spacepod/proc/rename_pod

/obj/vehicle/sealed/spacepod/after_remove_occupant(mob/M)
	. = ..()
	M.verbs -= /obj/vehicle/sealed/spacepod/proc/rename_pod
	M.forceMove(loc)



///////////////////////
////VISUAL BULLSHIT////
///////////////////////

/obj/vehicle/sealed/spacepod/update_icon()
	cut_overlays()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = mutable_appearance(icon, "pod_damage")
		pod_overlays[FIRE] = mutable_appearance(icon, "pod_fire")
	if(!pod_paint_effect)
		pod_paint_effect = new/list(4)
		pod_paint_effect[LIGHT] = mutable_appearance(icon,icon_state = "LIGHTS")
		pod_paint_effect[WINDOW] = mutable_appearance(icon,icon_state = "Windows")
		pod_paint_effect[RIM] = mutable_appearance(icon,icon_state = "RIM")
		pod_paint_effect[PAINT] = mutable_appearance(icon,icon_state = "PAINT")

	if(has_paint)
		var/image/to_add
		if(!isnull(pod_paint_effect[LIGHT]))
			to_add = pod_paint_effect[LIGHT]
			to_add.color = colors[LIGHT]
			add_overlay(to_add)
		if(!isnull(pod_paint_effect[WINDOW]))
			to_add = pod_paint_effect[WINDOW]
			to_add.color = colors[WINDOW]
			add_overlay(to_add)
		if(!isnull(pod_paint_effect[RIM]))
			to_add = pod_paint_effect[RIM]
			to_add.color = colors[RIM]
			add_overlay(to_add)
		if(!isnull(pod_paint_effect[PAINT]))
			to_add = pod_paint_effect[PAINT]
			to_add.color = colors[PAINT]
			add_overlay(to_add)
	if(obj_integrity <= round(max_integrity/2))
		add_overlay(pod_overlays[DAMAGE])
		if(obj_integrity <= round(max_integrity/4))
			add_overlay(pod_overlays[FIRE])
	light_color = icon_light_color[icon_state]
	if(LAZYLEN(equipment) && equipment[POD_EQUIPMENT_WEAPON])
		var/obj/item/device/spacepod_equipment/weaponry/weapon = equipment[POD_EQUIPMENT_WEAPON]
		if(!weapon.overlay_icon)
			return //dont even waste our time
		add_overlay(mutable_appearance(icon, icon_state = weapon.overlay_icon))

/obj/vehicle/sealed/spacepod/proc/apply_paint(mob/user as mob)
	var/part_type
	var/part = input(user, "Choose part", null) as null|anything in list("Lights","Rim","Paint","Windows")
	switch(part)
		if("Lights")
			part_type = LIGHT
		if("Rim")
			part_type = RIM
		if("Paint")
			part_type = PAINT
		if("Windows")
			part_type = WINDOW
	var/coloradd = input(user, "Choose a color", "Color") as color
	colors[part_type] = coloradd
	if(!has_paint)
		has_paint = TRUE
	update_icon()



/////////////////////////
////INTERACTION PROCS////
/////////////////////////

/obj/vehicle/sealed/spacepod/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>The maintenance hatch is [hatch_open ? "opened" : "closed"].</span>")
	var/integrity = obj_integrity*100/max_integrity
	switch(integrity)
		if(85 to 100)
			to_chat(user, "<span class='notice'>It's fully intact.</span>")
		if(65 to 85)
			to_chat(user, "<span class='warning'>It's slightly damaged.</span>")
		if(45 to 65)
			to_chat(user, "<span class='warning'>It's badly damaged.</span>")
		if(25 to 45)
			to_chat(user, "<span class='danger'>It's heavily damaged.</span>")
		if(0 to 1)
			to_chat(user, "<span class='danger'><B>It looks like it's experiencing a core failure! Take cover!</B></span>")
		else
			to_chat(user, "<span class='warning'>It's falling apart.</span>")

	var/passengers = (occupants - return_drivers())
	var/driver = get_driver()
	if(driver)
		to_chat(user, "<span class='notice'>[driver] appears to be in the pilot's seat.</span>")
	if(LAZYLEN(passengers) && isobserver(user))
		for(var/mob/living/M in passengers)
			to_chat(user, "<span class='notice'>[M] is a a passenger.</span>")
	if(LAZYLEN(equipment))
		to_chat(user, "<span class='notice'><B>It's equipped with:</B></span>")
		for(var/obj/item/device/spacepod_equipment/ME in equipment)
			to_chat(user, " [icon2html(ME, user)] [ME]")

/obj/vehicle/sealed/spacepod/attack_hand(mob/user as mob)
	if(user in occupants)
		return
	if(user.a_intent == INTENT_GRAB && unlocked && LAZYLEN(occupants))
		var/mob/living/target = occupants[1]

		if(target && istype(target))
			visible_message("<span class='warning'>[user] is trying to rip the door open and pull [target] out of the [src]!</span>",
				"<span class='warning'>You see [user] outside the door trying to rip it open!</span>")
			if(do_after(user, 50, target = src))
				target.forceMove(get_turf(src))
				remove_passenger_actions(target)
				remove_controller_actions(target)
				remove_occupant(target)
				target.Stun(15)

				target.visible_message("<span class='warning'>[user] flings the door open and tears [target] out of the [src]</span>",
					"<span class='warning'>The door flies open and you are thrown out of the [src] and to the ground!</span>")
				return
			target.visible_message("<span class='warning'>[user] was unable to get the door open!</span>",
					"<span class='warning'>You manage to keep [user] out of the [src]!</span>")
		return

	if(!hatch_open && cargo_hold.storage_slots > 0 && unlocked)
		cargo_hold.show_to(user)
	else
		to_chat(user, "<span class='notice'>The storage compartment is locked</span>")
	remove_equipment(user)

/obj/vehicle/sealed/spacepod/attackby(obj/item/W as obj, mob/user as mob, params)
	if(user in occupants)
		return
	if(user.a_intent == INTENT_HARM)
		return ..()
	else
		if(istype(W, /obj/item/pod_paint_bucket))
			apply_paint(user)
			return
		if(istype(W, /obj/item/weldingtool))
			if(!hatch_open)
				to_chat(user, "<span class='warning'>You must open the maintenance hatch before attempting repairs.</span>")
				return
			var/obj/item/weldingtool/WT = W
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>The welder must be on for this task.</span>")
				return
			if(obj_integrity < max_integrity)
				to_chat(user, "<span class='notice'>You start welding the spacepod...</span>")
				playsound(loc, W.usesound, 50, 1)
				if(do_after(user, 20 * W.toolspeed, target = src))
					if(!src || !WT.remove_fuel(3, user)) return
					repair_damage(10)
					to_chat(user, "<span class='notice'>You mend some [pick("dents","bumps","damage")] with \the [WT]</span>")
				return
			to_chat(user, "<span class='boldnotice'>[src] is fully repaired!</span>")
			return
		if(istype(W, /obj/item/stock_parts/cell))
			if(!hatch_open)
				to_chat(user, "<span class='warning'>The maintenance hatch is closed!</span>")
				return
			if(cell)
				to_chat(user, "<span class='notice'>The pod already has a power cell.</span>")
				return
			to_chat(user, "<span class='notice'>You insert [W] into the pod.</span>")
			user.dropItemToGround(W)
			cell = W
			W.forceMove(src)
			return
		if(istype(W, /obj/item/device/spacepod_equipment))
			var/obj/item/device/spacepod_equipment/SE = W
			if(!hatch_open)
				to_chat(user, "<span class='warning'>The maintenance hatch is closed!</span>")
				return
			LAZYINITLIST(equipment)
			add_equipment(user, SE)
			return
		if(istype(W, /obj/item/device/spacepod_key) && istype(equipment[POD_EQUIPMENT_LOCK], /obj/item/device/spacepod_equipment/lock/keyed))
			var/obj/item/device/spacepod_key/key = W
			var/obj/item/device/spacepod_equipment/lock/keyed/LK = equipment[POD_EQUIPMENT_LOCK]
			if(key.id == LK.id)
				unlocked = !unlocked
				user.visible_message("<span class='notice'>[user] [unlocked ? "unlocks" : "locks"] \the [src].</span>", "<span class='notice'>You [unlocked ? "unlock" : "lock"] \the [src].</span>")
				return
			else
				to_chat(user, "<span class='warning'>This is the wrong key!</span>")
				return
		if(istype(equipment[POD_EQUIPMENT_LOCK], /obj/item/device/spacepod_equipment/lock/keyed) && istype(W, /obj/item/device/lock_buster))
			var/obj/item/device/lock_buster/L = W
			if(L.on && equipment[POD_EQUIPMENT_LOCK])
				user.visible_message(user, "<span class='warning'>[user] is drilling through the [src]'s lock!</span>",
					"<span class='notice'>You start drilling through the [src]'s lock!</span>")
				if(do_after(user, 100 * W.toolspeed, target = src))
					QDEL_NULL(equipment[POD_EQUIPMENT_LOCK])
					user.visible_message(user, "<span class='warning'>[user] has destroyed the [src]'s lock!</span>",
						"<span class='notice'>You destroy the [src]'s lock!</span>")
				else
					user.visible_message(user, "<span class='warning'>[user] fails to break through the [src]'s lock!</span>",
					"<span class='notice'>You were unable to break through the [src]'s lock!</span>")
				return
			to_chat(user, "<span class='notice'>Turn the [L] on first.</span>")
			return


/obj/vehicle/sealed/spacepod/MouseDrop_T(atom/A, mob/user)
	if(!unlocked)
		to_chat(user, "<span class='warning'>[src] is locked!</span>")
		return
	if((user in occupants) || (A in occupants))
		return

	if(isliving(user))
		var/mob/living/M = user
		if(occupant_amount() >= max_occupants)
			return
		if(A == M)
			visible_message("<span class='danger'>[user] starts climbing into \the [src]!</span>")
		else
			visible_message("<span class='danger'>[M] starts loading [A] into \the [src]!</span>")
		if(do_after(user, 50, target = M))
			if(occupant_amount() >= max_occupants)
				return
			mob_enter(M, TRUE)
			return
	else
		to_chat(user, "<span class='danger'>You can't put [A] in there!</span>")

/obj/vehicle/sealed/spacepod/crowbar_act(mob/user, obj/item/tool)
	if(unlocked || hatch_open)
		hatch_open = !hatch_open
		playsound(loc, tool.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>")
	else
		to_chat(user, "<span class='warning'>The hatch is locked shut!</span>")

//////////////////////
////MOVEMENT PROCS////
//////////////////////

/obj/vehicle/sealed/spacepod/driver_move(mob/user, direction)
	if(world.time < next_move)
		return FALSE
	var/moveship = TRUE
	var/obj/item/device/spacepod_equipment/thruster/TR = GetThruster()
	if(!TR)
		message_to_riders("<span class='warning'>There's no thruster installed! How do you expect to move?</span>")
		return
	var/extra_cell = 0
	var/extra_move_delay = 0
	if(cell && cell.charge >= TR.power_on_move && obj_integrity > 0 && empcounter == 0)
		setDir(direction)
		new /obj/effect/temp_visual/spacepod_trail(src, src)
		switch(direction)
			if(NORTH)
				if(inertia_dir == SOUTH)
					inertia_dir = 0
					moveship = FALSE
			if(SOUTH)
				if(inertia_dir == NORTH)
					inertia_dir = 0
					moveship = FALSE
			if(EAST)
				if(inertia_dir == WEST)
					inertia_dir = 0
					moveship = FALSE
			if(WEST)
				if(inertia_dir == EAST)
					inertia_dir = 0
					moveship = FALSE
		if(moveship)
			var/datum/gas_mixture/current = loc.return_air()
			var/area/A = get_area(src)
			if(!isspaceturf(loc) && TR.pressure_sensitive && current && (current.return_pressure() > TR.max_pressure) && !istype(A, /area/construction/podbay)) //so you can't podrace inside, but you can still explore ruins or exploded parts of the station
				extra_move_delay = 6
				extra_cell += 5
			Move(get_step(src, direction), direction)
			var/scrape = FALSE
			for(var/turf/T in locs)
				for(var/obj/item/device/spacepod_equipment/cargo/C in GetAllEquipment())
					for(var/obj/item/I in T.contents)
						C.passover(I)
				if(isfloorturf(T) && prob(45) && !istype(A, /area/construction/podbay) && !(istype(T, /turf/open/floor/engine) || istype(T, /turf/open/floor/plating) || istype(T, /turf/open/floor/plasteel)))
					var/turf/open/floor/F = T
					if(F.floor_tile)
						scrape = TRUE //just so we avoid doing the scrape message multiple time
						new F.floor_tile(F)
						F.make_plating()
						if(prob(35))
							take_damage(rand(0.5, 7.5))
			if(scrape)
				visible_message("<span class='danger'>[src] scrapes against the floor, tearing it open!</span>")

	else
		if(!cell)
			to_chat(user, "<span class='warning'>No energy cell detected.</span>")
		else if(cell.charge < TR.power_on_move)
			to_chat(user, "<span class='warning'>Not enough charge left.</span>")
		else if(obj_integrity < 1)
			to_chat(user, "<span class='warning'>She's dead, Jim</span>")
		else if(empcounter != 0)
			to_chat(user, "<span class='warning'>The pod control interface isn't responding. The console indicates [empcounter] seconds before reboot.</span>")
		else
			to_chat(user, "<span class='warning'>Unknown error has occurred, yell at the coders.</span>")
		return FALSE
	cell.charge = max(0, cell.charge - (TR.power_on_move + extra_cell))
	next_move = world.time + TR.move_delay + extra_move_delay

///////////////
////PROCESS////
///////////////

/obj/vehicle/sealed/spacepod/process()
	if(internal_temp_regulation)
		if(cabin_air && cabin_air.return_volume() > 0)
			var/delta = cabin_air.temperature - T20C
			cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))

	if(internal_tank)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()

		var/release_pressure = internal_tank_valve
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = return_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(t_air)
					t_air.merge(removed)
				else //just delete the cabin gas, we're in space or some shit
					qdel(removed)

	var/mob/living/pilot = get_driver()
	if(pilot)
		if(cell)
			var/cellcharge = cell.charge/cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					pilot.clear_alert("charge")
				if(0.5 to 0.75)
					pilot.throw_alert("charge", /obj/screen/alert/lowcell, 1)
				if(0.25 to 0.5)
					pilot.throw_alert("charge", /obj/screen/alert/lowcell, 2)
				if(0.01 to 0.25)
					pilot.throw_alert("charge", /obj/screen/alert/lowcell, 3)
				else
					pilot.throw_alert("charge", /obj/screen/alert/emptycell)

		var/integrity = obj_integrity/max_integrity*100
		switch(integrity)
			if(30 to 45)
				pilot.throw_alert("mech damage", /obj/screen/alert/low_mech_integrity, 1)
			if(15 to 35)
				pilot.throw_alert("mech damage", /obj/screen/alert/low_mech_integrity, 2)
			if(-INFINITY to 15)
				pilot.throw_alert("mech damage", /obj/screen/alert/low_mech_integrity, 3)
			else
				pilot.clear_alert("mech damage")

	if(cell)
		var/losepower = FALSE
		if(!has_power_been_lost && cell.charge < 1)
			has_power_been_lost = TRUE
			losepower = TRUE
		else if(has_power_been_lost && cell.charge >= 1)
			has_power_been_lost = FALSE
			losepower = FALSE
		for(var/obj/item/device/spacepod_equipment/SE in equipment)
			if(SE.power_use)
				if(!cell.use(SE.power_use) && losepower)
					SE.on_power_loss()


////////////////////
////POD SUBTYPES////
////////////////////


/obj/vehicle/sealed/spacepod/random
	icon_state = "pod_civ"
	pod_armor = /datum/pod_armor/civ
// placeholder

/obj/vehicle/sealed/spacepod/random/Initialize()
	pod_armor = pick(subtypesof(/datum/pod_armor))
	return ..()


/obj/vehicle/sealed/spacepod/civilian
	icon_state = "pod_civ"
	pod_armor = /datum/pod_armor/civ
	desc = "A sleek civilian space pod."
	starting_equipment = list(/obj/item/device/spacepod_equipment/thruster)

/obj/vehicle/sealed/spacepod/security
	icon_state = "pod_mil"
	pod_armor = /datum/pod_armor/security
	starting_equipment = list(/obj/item/device/spacepod_equipment/thruster)

/obj/vehicle/sealed/spacepod/syndicate
	icon_state = "pod_synd"
	pod_armor = /datum/pod_armor/syndicate
	starting_equipment = list(/obj/item/device/spacepod_equipment/thruster, /obj/item/device/spacepod_equipment/action/cloaker, /obj/item/device/spacepod_equipment/weaponry/laser, /obj/item/device/spacepod_equipment/sec_cargo/back_seat)
	cell_type = /obj/item/stock_parts/cell/hyper


///////////////////////
////EQUIPMENT STUFF////
///////////////////////

/obj/vehicle/sealed/spacepod/proc/add_equipment(mob/user, obj/item/device/spacepod_equipment/E)
	if(!E || !(E.slot || E.size))
		return
	LAZYINITLIST(equipment)
	if(user && E.syndicate && !(("syndicate" in user.faction) || user.mind.has_antag_datum(/datum/antagonist/traitor)))
		to_chat(user, "<span class='warning'>You can't really find out how to install \the [E]. Where is the plug, even?!</span>")
		return
	if(E.slot && !equipment[E.slot])
		equipment[E.slot] = E
	else if(E.size && ((calculate_equipment_size() + E.size) <= MAX_POD_EQUIPMENT_SIZE))
		equipment += E
	else if(E.size && !((calculate_equipment_size() + E.size) <= MAX_POD_EQUIPMENT_SIZE))
		if(user)
			to_chat(user, "<span class='danger'>There's not enough room in \the [src] for [E]!</span>")
		return
	else
		if(user)
			to_chat(user, "<span class='danger'>You fail to install [E] into \the [src].</span>")
		return
	to_chat(user, "<span class='notice'>You insert [E] into \the [src].</span>")
	E.my_atom = src
	if(user)
		user.dropItemToGround(E)
	E.forceMove(src)
	cargo_hold.storage_slots += E.storage_mod["slots"]
	cargo_hold.max_combined_w_class += E.storage_mod["w_class"]
	max_occupants += E.occupant_mod
	E.added(user)

/obj/vehicle/sealed/spacepod/proc/remove_equipment(mob/user)
	if(!equipment || !user)
		return
	var/possible = list()
	if(cell)
		possible += cell
	possible += equipment
	var/what_to_remove = input(user, "Choose the equipment you wish to take out:", "Spacepod")  as null|anything in possible
	if(istype(what_to_remove, /obj/item/stock_parts/cell))
		user.visible_message("<span class='notice'>[user] removes \the [cell] from \the [src].</span>", "<span class='notice'>You remove \the [cell] from \the [src].</span>")
		cell.forceMove(user.loc)
		user.put_in_hands(cell)
		cell = null
	else if(istype(equipment[what_to_remove], /obj/item/device/spacepod_equipment)) //this happens for "special slots" that don't contribute to total size, like weaponry
		var/obj/item/device/spacepod_equipment/SE = equipment[what_to_remove]
		if(!SE)
			return
		SE.forceMove(user.loc)
		user.put_in_hands(SE)
		equipment[what_to_remove] = null
		SE.removed(user)
		SE.my_atom = null
		max_occupants -= SE.occupant_mod
		if(cargo_hold)
			cargo_hold.storage_slots -= SE.storage_mod["slots"]
			cargo_hold.max_combined_w_class -= SE.storage_mod["w_class"]
		user.visible_message("<span class='notice'>[user] removes \the [SE] from \the [src].</span>", "<span class='notice'>You remove \the [SE] from \the [src].</span>")
	else if(istype(what_to_remove, /obj/item/device/spacepod_equipment))
		var/obj/item/device/spacepod_equipment/SE = what_to_remove
		if(!SE)
			return
		user.visible_message("<span class='notice'>[user] removes \the [SE] from \the [src].</span>", "<span class='notice'>You remove \the [SE] from \the [src].</span>")
		SE.forceMove(user.loc)
		user.put_in_hands(SE)
		cargo_hold.storage_slots -= SE.storage_mod["slots"]
		max_occupants -= SE.occupant_mod
		cargo_hold.max_combined_w_class -= SE.storage_mod["w_class"]
		equipment.Remove(SE)
		SE.removed(user)
		SE.my_atom = null
	update_icon()


/obj/vehicle/sealed/spacepod/proc/GetAllEquipment()
	. = list()
	for(var/A in equipment)
		if(islist(A))
			for(var/B in A)
				. += B
		else
			. += A

/obj/vehicle/sealed/spacepod/proc/GetThruster()
	if(!istype(equipment[POD_EQUIPMENT_THRUSTER], /obj/item/device/spacepod_equipment/thruster))
		return FALSE
	return equipment[POD_EQUIPMENT_THRUSTER]

/obj/vehicle/sealed/spacepod/proc/calculate_equipment_size()
	. = 0
	for(var/A in equipment)
		var/obj/item/device/spacepod_equipment/SE = A
		if(SE.slot)
			continue
		. += SE.size

////////////////////
////ACTION PROCS////
////////////////////

/obj/vehicle/sealed/spacepod/proc/checkSeat(mob/user)
	if(user.incapacitated())
		return
	to_chat(user, "<span class='notice'>You start rooting around under the seat for lost items</span>")
	if(do_after(user, 40, target = src))
		var/obj/badlist = list(internal_tank, cargo_hold, cell, radio, gps) + occupants + equipment
		var/list/true_contents = contents - badlist
		if(LAZYLEN(true_contents))
			var/obj/I = pick(true_contents)
			if(user.put_in_hands(I))
				contents -= I
				to_chat(user, "<span class='notice'>You find a [I] [pick("under the seat", "under the console", "in the maintenance access")]!</span>")
			else
				to_chat(user, "<span class='notice'>You think you saw something shiny, but you can't reach it!</span>")
		else
			to_chat(user, "<span class='notice'>You fail to find anything of value.</span>")
	else
		to_chat(user, "<span class='notice'>You decide against searching the [src]</span>")


/obj/vehicle/sealed/spacepod/proc/unload(mob/user)
	if(user.incapacitated())
		return
	for(var/obj/item/device/spacepod_equipment/cargo/C in equipment)
		C.unload()

/obj/vehicle/sealed/spacepod/proc/toggleDoors(mob/user)
	if(user.incapacitated())
		return

	for(var/obj/machinery/door/poddoor/multi_tile/P in orange(3,src))
		for(var/mob/living/carbon/human/O in occupants)
			if(P.check_access(O.get_active_held_item()) || P.check_access(O.wear_id))
				if(P.density)
					P.open()
					return TRUE
				else
					P.close()
					return TRUE
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	to_chat(user, "<span class='warning'>You are not to close to any pod doors.</span>")

/obj/vehicle/sealed/spacepod/proc/lock_pod(mob/user)
	if(user.incapacitated())
		return
	if(!equipment[POD_EQUIPMENT_LOCK])
		to_chat(user, "<span class='warning'>This pod has no lock system installed!</span>")
		return
	unlocked = !unlocked
	to_chat(user, "<span class='warning'>You [unlocked ? "unlock" : "lock"] the doors.</span>")


////////////////
//// VERBS! ////
////////////////

/obj/vehicle/sealed/spacepod/proc/rename_pod(new_name as text)
	set name = "Rename Spacepod"
	set category = "Spacepod"
	if(occupants[usr] && occupants[usr] != "[VEHICLE_CONTROL_DRIVE]")
		return
	if(new_name && length(new_name) <= MAX_NAME_LEN)
		name = new_name