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

/obj/spacepod
	name = "\improper space pod"
	desc = "A space pod meant for space travel."
	icon = 'goon/icons/48x48/pods.dmi'
	density = TRUE //Dense. To raise the heat.
	opacity = 0

	anchored = TRUE

	layer = SPACEPOD_LAYER


	var/list/mob/living/pilot //There is only ever one pilot and he gets all the privledge
	var/list/mob/living/passengers = list() //passengers can't do anything and are variable in number
	var/max_passengers = 0
	var/obj/item/storage/internal/cargo_hold

	var/datum/spacepod/equipment/equipment_system

	var/internal_temp_regulation = TRUE

	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell

	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/use_internal_tank = FALSE

	var/datum/effect_system/trail_follow/ion/space_trail/ion_trail

	var/hatch_open = FALSE

	var/next_firetime = 0

	var/max_temperature = 25000

	var/internal_tank_valve = ONE_ATMOSPHERE

	var/has_paint = FALSE

	flags_2 = UNACIDABLE | HEAR_1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	var/mutable_appearance/list/pod_overlays
	var/list/pod_paint_effect
	var/list/colors = new/list(4)

	max_integrity = 250

	var/empcounter = 0 //Used for disabling movement when hit by an EMP

	var/lights = FALSE
	var/lights_power = 6
	var/list/icon_light_color = list("pod_civ" = null, \
									 "pod_mil" = "#BBF093", \
									 "pod_synd" = LIGHT_COLOR_RED, \
									 "pod_gold" = null, \
									 "pod_black" = "#3B8FE5", \
									 "pod_industrial" = "#CCCC00")

	var/unlocked = TRUE

	var/move_delay = 2
	var/next_move = 0

	var/datum/action/innate/spacepod/exit/list/exit_action = list()
	var/datum/action/innate/spacepod/lockpod/list/lock_action = list()
	var/datum/action/innate/spacepod/poddoor/list/door_action = list()
	var/datum/action/innate/spacepod/weapons/list/fire_action = list()
	var/datum/action/innate/spacepod/cargo/list/unload_action = list()
	var/datum/action/innate/spacepod/lights/list/light_action = list()
	var/datum/action/innate/spacepod/checkseat/list/seat_action = list()
	var/datum/action/innate/spacepod/airtank/list/tank_action = list()

	var/obj/item/device/radio/mech/radio
	var/obj/item/device/gps/gps

	hud_possible = list(DIAG_HUD, DIAG_BATT_HUD)

	var/armor_multiplier_applied = FALSE //used for determining if the construction process already applied the armorer multiplier

	var/datum/pod_armor/pod_armor


/obj/spacepod/proc/apply_paint(mob/user as mob)
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
		else
	var/coloradd = input(user, "Choose a color", "Color") as color
	colors[part_type] = coloradd
	if(!has_paint)
		has_paint = 1
	update_icons()

/obj/spacepod/proc/get_intergrity()
	return obj_integrity/max_integrity*100

/obj/spacepod/Initialize(mapload, datum/pod_armor/p_armor)
	. = ..(mapload)
	if (p_armor)
		pod_armor = new p_armor

	else
		pod_armor = new
	update_icons()
	setDir(EAST)
	cell = new cell_type(src)
	add_cabin()
	add_radio()
	add_airtank()
	add_gps()
	ion_trail = new /datum/effect_system/trail_follow/ion/space_trail()
	ion_trail.set_up(src)
	ion_trail.start()
	use_internal_tank = 1
	GLOB.poi_list += src
	equipment_system = new(src)
	equipment_system.installed_modules += cell
	GLOB.spacepods_list += src
	START_PROCESSING(SSobj, src)
	prepare_huds()
	var/datum/atom_hud/data/diagnostic/diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_podhealth()
	diag_hud_set_podcharge()
	if (!armor_multiplier_applied)
		max_integrity *= pod_armor.armor_multiplier
		obj_integrity *= pod_armor.armor_multiplier
		armor_multiplier_applied = TRUE
	cargo_hold = new/obj/item/storage/internal(src)
	cargo_hold.w_class = 5	//so you can put bags in
	cargo_hold.storage_slots = 0	//You need to install cargo modules to use it.
	cargo_hold.max_w_class = 5		//fit almost anything
	cargo_hold.max_combined_w_class = 0 //you can optimize your stash with larger items

	armorDesc()

	for(var/turf/T in locs)
		for(var/obj/I in T.contents)
			if(istype(I, /obj/structure/spacepod_frame))
				QDEL_NULL(I)


/obj/spacepod/Destroy()
	if(equipment_system.cargo_system)
		equipment_system.cargo_system.removed(null)
	QDEL_NULL(equipment_system)
	QDEL_NULL(cargo_hold)
	QDEL_NULL(cell)
	if(loc)
		loc.assume_air(cabin_air)
		air_update_turf()
	QDEL_NULL(cabin_air)
	QDEL_NULL(internal_tank)
	QDEL_NULL(ion_trail)
	occupant_sanity_check()
	if(pilot)
		pilot.forceMove(get_turf(src))
		Remove_Actions(pilot)
		pilot.clear_alert("charge")
		pilot.clear_alert("mech damage")
		pilot = null
	if(passengers)
		for(var/mob/living/M in passengers)
			M.forceMove(get_turf(src))
			Remove_Actions(M)
			passengers -= M
	GLOB.spacepods_list -= src
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/spacepod/proc/update_icons()
	cut_overlays()
	icon_state = pod_armor.icon_state
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
	overlays.Cut()

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
	if(equipment_system.weapon_system && equipment_system.weapon_system.overlay_icon)
		var/mutable_appearance/weapon_overlay = mutable_appearance(icon, icon_state = equipment_system.weapon_system.overlay_icon)
		add_overlay(weapon_overlay)
	light_color = icon_light_color[icon_state]
	bound_width = 64
	bound_height = 64

/obj/spacepod/bullet_act(obj/item/projectile/P)
	if(P.damage_type == BRUTE || P.damage_type == BURN)
		take_damage(P.damage)
	P.on_hit(src)

/obj/spacepod/blob_act()
	take_damage(30)
	return

/obj/spacepod/attack_animal(mob/living/simple_animal/user as mob)
	if(user.melee_damage_upper == 0)
		user.emote(1, "[user.friendly] [src]")
	else
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		take_damage(damage)
		visible_message("<span class='danger'>[user]</span> [user.attacktext] [src]!")
		log_attack("<font color='red'>attacked [name]</font>")
	return

/obj/spacepod/proc/fixReg()
	internal_temp_regulation = TRUE
	message_to_riders("<span class='notice'>The pod console displays 'Temperature regulation online. Have a safe day!'.</span>")

/obj/spacepod/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = TRUE
	radio.broadcasting = FALSE

/obj/spacepod/proc/add_gps()
	gps = new(src)
	gps.name = "[src] gps"
	gps.icon = icon
	gps.icon_state = icon_state
	gps.gpstag = "SPOD"

/obj/spacepod/examine(mob/user)
	..()
	var/integrity = obj_integrity*100/max_integrity
	switch(integrity)
		if(85 to 100)
			to_chat(user, "It's fully intact.")
		if(65 to 85)
			to_chat(user, "It's slightly damaged.")
		if(45 to 65)
			to_chat(user, "It's badly damaged.")
		if(25 to 45)
			to_chat(user, "It's heavily damaged.")
		if(0 to 1)
			to_chat(user, "<span class='danger'>It looks like it's experiencing a core failure! Take cover!</span>")
		else
			to_chat(user, "It's falling apart.")
	if(LAZYLEN(equipment_system.installed_modules))
		to_chat(user, "It's equipped with:")
		for(var/obj/item/device/spacepod_equipment/ME in equipment_system.installed_modules)
			to_chat(user, "[icon2html(ME, user)] [ME]")
	if(pilot)
		to_chat(user, "[pilot] appears to be in the pilot's seat.")
	if(LAZYLEN(passengers) && isobserver(user))
		for(var/mob/living/M in passengers)
			to_chat(user, "[M] is a a passenger.")
/obj/spacepod/proc/armorDesc()
	switch(pod_armor.name)
		if("civ")
			desc = "A sleek civilian space pod."
		if("black")
			desc = "An all black space pod with no insignias."
		if("mil")
			desc = "A dark grey space pod brandishing the Nanotrasen Military insignia"
		if("pod_synd")
			desc = "A menacing military space pod with Fuck NT stenciled onto the side"
		if("gold")
			desc = "A civilian space pod with a gold body, must have cost somebody a pretty penny"
		if("industrial")
			desc = "A rough looking space pod meant for industrial work"
	update_icons()

/obj/spacepod/attack_alien(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(15)
	playsound(loc, 'sound/weapons/slash.ogg', 50, 1, -1)
	to_chat(user, "<span class='warning'>You slash at [src]!</span>")
	visible_message("<span class='warning'>The [user] slashes at [name]'s armor!</span>")
	return

/obj/spacepod/proc/explodify()
	message_to_riders("<span class='userdanger'>Exit the spacepod immediately, explosion immi-</span>")
	explosion(loc, 2, 4, 8)
	visible_message("<span class='danger'>[src] violently explodes!</span>")
	var/turf/T = get_turf(src)
	log_game("The spacepod \[name: [name], pilot: [pilot]([pilot.ckey]) exploded at [COORD(T)]!")
	message_admins("The spacepod \[name: [name], pilot: [pilot]([pilot.ckey])\] exploded at [ADMIN_JMP(T)]!")
	qdel(src)

/obj/spacepod/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	log_attack("[user] attacked the spacepod \[name: [name], pilot: [pilot]([pilot.ckey])\] with [I]!")

/obj/spacepod/take_damage(damage, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	var/percentage = (obj_integrity / max_integrity) * 100
	occupant_sanity_check()
	if(percentage <= 25 && percentage > 0)
		play_sound_to_riders('sound/effects/alert.ogg')
		message_to_riders("<span class='danger'>Pod integrity at [percentage]%!</span>")
	update_icons()
	diag_hud_set_podhealth()

/obj/spacepod/proc/repair_damage(repair_amount)
	if(obj_integrity)
		obj_integrity = min(max_integrity, obj_integrity + repair_amount)
		update_icons()
		diag_hud_set_podhealth()

/obj/spacepod/obj_destruction(damage_flag)
	var/turf/T = get_turf(src)
	message_to_riders("<span class='userdanger'>Critical damage to the vessel detected, core explosion imminent!</span>")
	message_admins("The spacepod, \[[name]\], is about to explode at [ADMIN_JMP(T)]!")
	addtimer(CALLBACK(src, .proc/explodify), 50)


/obj/spacepod/ex_act(severity)
	occupant_sanity_check()
	switch(severity)
		if(1)
			if(passengers || pilot)
				for(var/mob/living/M in passengers | pilot)
					var/mob/living/carbon/human/H = M
					if(H)
						H.forceMove(get_turf(src))
						H.ex_act(severity + 1)
						to_chat(H, "<span class='warning'>You are forcefully thrown from [src]!</span>")
			qdel(ion_trail)
			qdel(src)
		if(2)
			take_damage(100)
		if(3)
			if(prob(40))
				take_damage(50)

/obj/spacepod/emp_act(severity)
	occupant_sanity_check()
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

	diag_hud_set_podcharge()

/obj/spacepod/proc/play_sound_to_riders(mysound)
	if(length(passengers | pilot) == 0)
		return
	var/sound/S = sound(mysound)
	S.volume = 50
	for(var/mob/living/M in passengers | pilot)
		SEND_SOUND(M, S)

/obj/spacepod/proc/message_to_riders(mymessage)
	if(length(passengers | pilot) == 0)
		return
	for(var/mob/living/M in passengers | pilot)
		to_chat(M, mymessage)

/obj/spacepod/attackby(obj/item/W as obj, mob/user as mob, params)
	if(user.a_intent == INTENT_HARM)
		..()
		take_damage(W.force)
	else
		if(istype(W, /obj/item/pod_paint_bucket))
			apply_paint(user)
			return
		if(istype(W, /obj/item/device/spacepod_equipment))
			var/obj/item/device/spacepod_equipment/SE = W
			if(!hatch_open)
				to_chat(user, "<span class='warning'>The maintenance hatch is closed!</span>")
				return
			if(!equipment_system)
				to_chat(user, "<span class='warning'>The pod has no equipment datum, yell at the coders</span>")
				return
			add_equipment(user, W, "[SE.slot]_system")
			update_icons()
			return
		if(istype(W, /obj/item/crowbar))
			if(!equipment_system.lock_system || unlocked || hatch_open)
				hatch_open = !hatch_open
				playsound(loc, W.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>")
			else
				to_chat(user, "<span class='warning'>The hatch is locked shut!</span>")
			return
		if(istype(W, /obj/item/stock_parts/cell))
			if(!hatch_open)
				to_chat(user, "<span class='warning'>The maintenance hatch is closed!</span>")
				return
			if(cell)
				to_chat(user, "<span class='notice'>The pod already has a power cell.</span>")
				return
			to_chat(user, "<span class='notice'>You insert [W] into the pod.</span>")
			user.drop_item(W)
			cell = W
			W.forceMove(src)
			return
		if(istype(W, /obj/item/device/spacepod_key) && istype(equipment_system.lock_system, /obj/item/device/spacepod_equipment/lock/keyed))
			var/obj/item/device/spacepod_key/key = W
			if(key.id == equipment_system.lock_system.id)
				if(unlocked)
					to_chat(user, "<span class='notice'>You lock [src].</span>")
					unlocked = FALSE
				else
					to_chat(user, "<span class='notice'>You unlock [src].</span>")
					unlocked = TRUE
				return
			else
				to_chat(user, "<span class='warning'>This is the wrong key!</span>")
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
					to_chat(user, "<span class='notice'>You mend some [pick("dents","bumps","damage")] with [WT]</span>")
				return
			to_chat(user, "<span class='boldnotice'>[src] is fully repaired!</span>")
			return

		if(istype(W, /obj/item/device/lock_buster))
			var/obj/item/device/lock_buster/L = W
			if(L.on && equipment_system.lock_system)
				user.visible_message(user, "<span class='warning'>[user] is drilling through the [src]'s lock!</span>",
					"<span class='notice'>You start drilling through the [src]'s lock!</span>")
				if(do_after(user, 100 * W.toolspeed, target = src))
					QDEL_NULL(equipment_system.lock_system)
					user.visible_message(user, "<span class='warning'>[user] has destroyed the [src]'s lock!</span>",
						"<span class='notice'>You destroy the [src]'s lock!</span>")
				else
					user.visible_message(user, "<span class='warning'>[user] fails to break through the [src]'s lock!</span>",
					"<span class='notice'>You were unable to break through the [src]'s lock!</span>")
				return
			to_chat(user, "<span class='notice'>Turn the [L] on first.</span>")
			return

		if(cargo_hold.storage_slots > 0 && !hatch_open && unlocked) // must be the last option as all items not listed prior will be stored
			cargo_hold.attackby(W, user, params)

/obj/spacepod/proc/add_equipment(mob/user, var/obj/item/device/spacepod_equipment/SPE, var/slot)
	if(equipment_system.vars[slot])
		to_chat(user, "<span class='notice'>The pod already has a [sys_name(slot)], remove it first.</span>")
		return
	else
		to_chat(user, "<span class='notice'>You insert [SPE] into the pod.</span>")
		user.drop_item(SPE)
		SPE.forceMove(src)
		equipment_system.vars[slot] = SPE
		var/obj/item/device/spacepod_equipment/system = equipment_system.vars[slot]
		system.my_atom = src
		equipment_system.installed_modules += SPE
		max_passengers += SPE.occupant_mod
		cargo_hold.storage_slots += SPE.storage_mod["slots"]
		cargo_hold.max_combined_w_class += SPE.storage_mod["w_class"]

/obj/spacepod/attack_hand(mob/user as mob)
	if(user.a_intent == INTENT_GRAB && unlocked)
		var/mob/living/target
		if(pilot)
			target = pilot
		else if(passengers.len > 0)
			target = passengers[1]

		if(target && istype(target))
			visible_message("<span class='warning'>[user] is trying to rip the door open and pull [target] out of the [src]!</span>",
				"<span class='warning'>You see [user] outside the door trying to rip it open!</span>")
			if(do_after(user, 50, target = src))
				target.forceMove(get_turf(src))
				target.Stun(1)
				if(pilot)
					pilot = null
				else
					passengers -= target
				target.visible_message("<span class='warning'>[user] flings the door open and tears [target] out of the [src]</span>",
					"<span class='warning'>The door flies open and you are thrown out of the [src] and to the ground!</span>")
				return
			target.visible_message("<span class='warning'>[user] was unable to get the door open!</span>",
					"<span class='warning'>You manage to keep [user] out of the [src]!</span>")

	if(!hatch_open)
		if(cargo_hold.storage_slots > 0)
			if(unlocked)
				cargo_hold.show_to(user)
			else
				to_chat(user, "<span class='notice'>The storage compartment is locked</span>")
		return ..()
	if(!equipment_system || !istype(equipment_system))
		to_chat(user, "<span class='warning'>The pod has no equipment datum, or is the wrong type, yell at MoreRobustThanYou.</span>")
		return
	var/list/possible = list()
	if(cell)
		possible.Add("Energy Cell")
	if(equipment_system.weapon_system)
		possible.Add("Weapon System")
	if(equipment_system.misc_system)
		possible.Add("Misc. System")
	if(equipment_system.cargo_system)
		possible.Add("Cargo System")
	if(equipment_system.sec_cargo_system)
		possible.Add("Secondary Cargo System")
	if(equipment_system.lock_system)
		possible.Add("Lock System")
	if(equipment_system.thruster_system)
		possible.Add("Thruster System")
	switch(input(user, "Remove which equipment?", null, null) as null|anything in possible)
		if("Energy Cell")
			if(user.put_in_hands(cell))
				to_chat(user, "<span class='notice'>You remove [cell] from the space pod</span>")
				cell = null
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
			return
		if("Weapon System")
			remove_equipment(user, equipment_system.weapon_system, "weapon_system")
			return
		if("Misc. System")
			remove_equipment(user, equipment_system.misc_system, "misc_system")
			return
		if("Cargo System")
			remove_equipment(user, equipment_system.cargo_system, "cargo_system")
			return
		if("Secondary Cargo System")
			remove_equipment(user, equipment_system.sec_cargo_system, "sec_cargo_system")
			return
		if("Lock System")
			remove_equipment(user, equipment_system.lock_system, "lock_system")
		if("Thruster System")
			remove_equipment(user, equipment_system.thruster_system, "thruster_system")

/obj/spacepod/proc/remove_equipment(mob/user, var/obj/item/device/spacepod_equipment/SPE, var/slot)

	if(passengers.len > max_passengers - SPE.occupant_mod)
		to_chat(user, "<span class='warning'>Someone is sitting in [SPE]!</span>")
		return

	var/sum_w_class = 0
	for(var/obj/item/I in cargo_hold.contents)
		sum_w_class += I.w_class
	if(cargo_hold.contents.len > cargo_hold.storage_slots - SPE.storage_mod["slots"] || sum_w_class > cargo_hold.max_combined_w_class - SPE.storage_mod["w_class"])
		to_chat(user, "<span class='warning'>Empty [SPE] first!</span>")
		return

	if(user.put_in_hands(SPE))
		to_chat(user, "<span class='notice'>You remove [SPE] from the equipment system.</span>")
		equipment_system.installed_modules -= SPE
		max_passengers -= SPE.occupant_mod
		cargo_hold.storage_slots -= SPE.storage_mod["slots"]
		cargo_hold.max_combined_w_class -= SPE.storage_mod["w_class"]
		SPE.removed(user)
		SPE.my_atom = null
		equipment_system.vars[slot] = null
		return
	to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")


/obj/spacepod/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(speaker == pilot || speaker in passengers)
		if(radio.broadcasting)
			radio.talk_into(speaker, text, , spans, message_language)
		//flick speech bubble
		var/list/speech_bubble_recipients = list()
		for(var/mob/M in get_hearers_in_view(7,src))
			if(M.client)
				speech_bubble_recipients.Add(M.client)
		INVOKE_ASYNC(GLOBAL_PROC, /.proc/flick_overlay, image('icons/mob/talk.dmi', src, "machine[say_test(raw_message)]",SPACEPOD_LAYER+1), speech_bubble_recipients, 30)
	cargo_hold.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)
	..()


/obj/spacepod/proc/return_inv()

	var/list/L = list(  )

	L += contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	return L

/obj/spacepod/get_cell()
	return cell

/obj/spacepod/civilian
	icon_state = "pod_civ"
	pod_armor = /datum/pod_armor/civ
	desc = "A sleek civilian space pod."

/obj/spacepod/random
	icon_state = "pod_civ"
	pod_armor = /datum/pod_armor/civ
// placeholder

/obj/spacepod/random/Initialize()
	. = ..()
	icon_state = pick("pod_civ", "pod_black", "pod_mil", "pod_synd", "pod_gold", "pod_industrial")
	switch(icon_state)
		if("pod_civ")
			desc = "A sleek civilian space pod."
			pod_armor = /datum/pod_armor/civ
		if("pod_black")
			desc = "An all black space pod with no insignias."
			pod_armor = /datum/pod_armor/black
		if("pod_mil")
			desc = "A dark grey space pod brandishing the Nanotrasen Military insignia"
			pod_armor = /datum/pod_armor/security
		if("pod_synd")
			desc = "A menacing military space pod with Fuck NT stenciled onto the side"
			pod_armor = /datum/pod_armor/syndicate
		if("pod_gold")
			desc = "A civilian space pod with a gold body, must have cost somebody a pretty penny"
			pod_armor = /datum/pod_armor/gold
		if("pod_industrial")
			desc = "A rough looking space pod meant for industrial work"
			pod_armor = /datum/pod_armor/industrial
	update_icons()

/obj/spacepod/proc/toggle_internal_tank(mob/user)

	if(user.incapacitated())
		return

	if(user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from your chair")
		return
	use_internal_tank = !use_internal_tank
	to_chat(user, "<span class='notice'>Now taking air from [use_internal_tank?"internal airtank":"environment"].</span>")

/obj/spacepod/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.assert_gases("o2","n2")
	cabin_air.gases["o2"][MOLES] = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.gases["n2"][MOLES] = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/spacepod/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/spacepod/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	return ..()

/obj/spacepod/return_air()
	if(use_internal_tank)
		return cabin_air
	return ..()

/obj/spacepod/proc/return_pressure()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_pressure()
	return


/obj/spacepod/return_temperature()
    var/datum/gas_mixture/t_air = return_air()
    if(t_air)
        return t_air.return_temperature()

/obj/spacepod/proc/moved_other_inside(mob/living/carbon/human/H as mob)
	occupant_sanity_check()
	if(passengers.len < max_passengers)
		H.stop_pulling()
		H.forceMove(src)
		passengers += H
		H.forceMove(src)
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		return TRUE

/obj/spacepod/MouseDrop_T(atom/A, mob/user)
	if(user == pilot || user in passengers)
		return

	if(istype(A,/mob))
		var/mob/M = A
		if(!isliving(M))
			return

		occupant_sanity_check()

		if(M != user && unlocked && (M.stat == DEAD || M.incapacitated()))
			if(passengers.len >= max_passengers && !pilot)
				to_chat(user, "<span class='danger'><b>That person can't fly the pod!</b></span>")
				return FALSE
			if(passengers.len < max_passengers)
				visible_message("<span class='danger'>[user.name] starts loading [M.name] into the pod!</span>")
				if(do_after(user, 50, target = M))
					moved_other_inside(M)
			return

		if(M == user)
			enter_pod(user)
			return

	if(istype(A, /obj/structure/ore_box) && equipment_system.cargo_system && istype(equipment_system.cargo_system,/obj/item/device/spacepod_equipment/cargo/ore)) // For loading ore boxes
		load_cargo(user, A)
		return

	if(istype(A, /obj/structure/closet/crate) && equipment_system.cargo_system && istype(equipment_system.cargo_system, /obj/item/device/spacepod_equipment/cargo/crate)) // For loading crates
		load_cargo(user, A)

/obj/spacepod/proc/load_cargo(mob/user, var/obj/O)
	var/obj/item/device/spacepod_equipment/cargo/ore/C = equipment_system.cargo_system
	if(!C.storage)
		to_chat(user, "<span class='notice'>You begin loading [O] into [src]'s [equipment_system.cargo_system]</span>")
		if(do_after(user, 40, target = src))
			C.storage = O
			O.forceMove(C)
			to_chat(user, "<span class='notice'>You load [O] into [src]'s [equipment_system.cargo_system]!</span>")
		else
			to_chat(user, "<span class='warning'>You fail to load [O] into [src]'s [equipment_system.cargo_system]</span>")
	else
		to_chat(user, "<span class='warning'>[src] already has \an [C.storage]</span>")

/obj/spacepod/proc/enter_pod(mob/user)
	if(user.stat != CONSCIOUS)
		return FALSE

	if(equipment_system.lock_system && !unlocked)
		to_chat(user, "<span class='warning'>[src]'s doors are locked!</span>")
		return FALSE

	if(!istype(user))
		return FALSE

	var/fukkendisk = locate(/obj/item/disk/nuclear) in GetAllContents(user)

	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return FALSE
	if(!ishuman(user))
		return FALSE

	if(fukkendisk) //to prevent the captain from fucking off into space with the disk during ops.
		to_chat(user, "<span class='danger'><B>The nuke-disk is locking the door every time you try to open it. You get the feeling that it doesn't want to go into the spacepod.</b></span>")
		return FALSE

	for(var/mob/living/simple_animal/slime/S in range(1,user))
		if(S.Target == user)
			to_chat(user, "You're too busy getting your life sucked out of you.")
			return FALSE

	move_inside(user)

/obj/spacepod/proc/move_inside(mob/user)
	if(!istype(user))
		log_game("SHIT'S GONE WRONG WITH THE SPACEPOD [src] AT [x], [y], [z], AREA [get_area(src)], TURF [get_turf(src)]")

	occupant_sanity_check()

	if(passengers.len <= max_passengers)
		visible_message("<span class='notice'>[user] starts to climb into [src].</span>")
		if(do_after(user, 40, target = src))
			if(!pilot || pilot == null)
				user.stop_pulling()
				pilot = user
				user.forceMove(src)
				add_fingerprint(user)
				playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
				Grant_Actions(pilot)
				return
			if(passengers.len < max_passengers)
				user.stop_pulling()
				passengers += user
				user.forceMove(src)
				add_fingerprint(user)
				Grant_Actions(user)
				playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
			else
				to_chat(user, "<span class='notice'>You were too slow. Try better next time, loser.</span>")
		else
			to_chat(user, "<span class='notice'>You stop entering [src].</span>")
	else
		to_chat(user, "<span class='danger'>You can't fit in [src], it's full!</span>")

/obj/spacepod/proc/occupant_sanity_check()  // going to have to adjust this later for cargo refactor
	if(passengers)
		if(passengers.len > max_passengers)
			for(var/i = passengers.len; i <= max_passengers; i--)
				var/mob/living/occupant = passengers[i - 1]
				occupant.forceMove(get_turf(src))
				log_game("##SPACEPOD WARNING: passengers EXCEED CAP: MAX passengers [max_passengers], passengers [english_list(passengers)], TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers[i - 1] = null
		for(var/mob/living/M in passengers)
			if(!ismob(M))
				M.forceMove(get_turf(src))
				log_game("##SPACEPOD WARNING: NON-MOB OCCUPANT [M], TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers -= M
			else if(M.loc != src)
				log_game("##SPACEPOD WARNING: OCCUPANT [M] ESCAPED, TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers -= M

/obj/spacepod/proc/exit_pod(mob/user)
	if(!istype(user))
		return

	if(user.incapacitated()) // unconscious and restrained people can't let themselves out
		return

	occupant_sanity_check()

	if(user == pilot)
		user.forceMove(get_turf(src))
		pilot = null
		to_chat(user, "<span class='notice'>You climb out of [src].</span>")
		Remove_Actions(user)
		user.clear_alert("charge")
		user.clear_alert("mech damage")
	if(user in passengers)
		user.forceMove(get_turf(src))
		passengers -= user
		to_chat(user, "<span class='notice'>You climb out of [src].</span>")
		Remove_Actions(user)

/obj/spacepod/proc/lock_pod(mob/user)

	if(user.incapacitated())
		return

	if(user in passengers && user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from your chair")
		return

	unlocked = !unlocked
	to_chat(user, "<span class='warning'>You [unlocked ? "unlock" : "lock"] the doors.</span>")


/obj/spacepod/proc/toggleDoors(mob/user)

	if(user.incapacitated())
		return

	if(user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from your chair")
		return

	for(var/obj/machinery/door/poddoor/multi_tile/P in orange(3,src))
		var/mob/living/carbon/human/L = user
		if(P.check_access(L.get_active_held_item()) || P.check_access(L.wear_id))
			if(P.density)
				P.open()
				return TRUE
			else
				P.close()
				return TRUE
		for(var/mob/living/carbon/human/O in passengers)
			if(P.check_access(O.get_active_held_item()) || P.check_access(O.wear_id))
				if(P.density)
					P.open()
					return TRUE
				else
					P.close()
					return TRUE
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	to_chat(user, "<span class='warning'>You are not close to any pod doors.</span>")

/obj/spacepod/proc/fireWeapon(mob/user)

	if(user.incapacitated())
		return

	if(user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from your chair")
		return
	if(!equipment_system.weapon_system)
		to_chat(user, "<span class='warning'>[src] has no weapons!</span>")
		return
	equipment_system.weapon_system.fire_weapons(user)

/obj/spacepod/proc/unload(mob/user)
	if(user.incapacitated())
		return

	if(user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from your chair")
		return
	if(!equipment_system.cargo_system)
		to_chat(user, "<span class='warning'>[src] has no cargo system!</span>")
		return
	equipment_system.cargo_system.unload()

/obj/spacepod/proc/toggleLights(mob/user)

	if(user.incapacitated())
		return

	if(user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from your chair")
		return
	lightsToggle()

/obj/spacepod/proc/lightsToggle()
	lights = !lights
	if(lights)
		set_light(lights_power)
	else
		set_light(0)
	to_chat(pilot, "Lights toggled [lights ? "on" : "off"].")
	for(var/mob/living/M in passengers)
		to_chat(M, "Lights toggled [lights ? "on" : "off"].")

/obj/spacepod/proc/checkSeat(mob/user)
	if(user.incapacitated())
		return

	to_chat(user, "<span class='notice'>You start rooting around under the seat for lost items</span>")
	if(do_after(user, 40, target = src))
		var/obj/badlist = list(internal_tank, cargo_hold, pilot, cell, radio, gps) + passengers + equipment_system.installed_modules
		var/list/true_contents = contents - badlist
		if(true_contents.len > 0)
			var/obj/I = pick(true_contents)
			if(user.put_in_hands(I))
				contents -= I
				to_chat(user, "<span class='notice'>You find a [I] [pick("under the seat", "under the console", "in the mainenance access")]!</span>")
			else
				to_chat(user, "<span class='notice'>You think you saw something shiny, but you can't reach it!</span>")
		else
			to_chat(user, "<span class='notice'>You fail to find anything of value.</span>")
	else
		to_chat(user, "<span class='notice'>You decide against searching the [src]</span>")

/obj/spacepod/proc/enter_after(delay as num, var/mob/user as mob, var/numticks = 5)
	var/delayfraction = delay/numticks

	var/turf/T = user.loc

	for(var/i = 0, i<numticks, i++)
		sleep(delayfraction)
		if(!src || !user || !user.canmove || !(user.loc == T))
			return FALSE

	return TRUE



/obj/spacepod/relaymove(mob/user, direction)
	if(user != pilot)
		return
	handlerelaymove(user, direction)

/obj/spacepod/proc/handlerelaymove(mob/user, direction)
	if(world.time < next_move)
		return FALSE
	var/moveship = 1
	var/extra_cell = 0
	move_delay = 2
	if( istype(equipment_system.thruster_system, /obj/item/device/spacepod_equipment/thruster) )
		move_delay = equipment_system.thruster_system.delay
		extra_cell += equipment_system.thruster_system.power_usage
	if(cell && cell.charge >= 1 && obj_integrity > 0 && empcounter == 0)
		setDir(direction)
		switch(direction)
			if(NORTH)
				if(inertia_dir == SOUTH)
					inertia_dir = 0
					moveship = 0
			if(SOUTH)
				if(inertia_dir == NORTH)
					inertia_dir = 0
					moveship = 0
			if(EAST)
				if(inertia_dir == WEST)
					inertia_dir = 0
					moveship = 0
			if(WEST)
				if(inertia_dir == EAST)
					inertia_dir = 0
					moveship = 0
		if(moveship)
			var/datum/gas_mixture/current = loc.return_air()
			if(current.return_pressure() > ONE_ATMOSPHERE * 0.5 && !istype(get_area(src), /area/engine/pod_construction)) //so you can't podrace inside, but you can still explore ruins or exploded parts of the station
				move_delay = 6
				extra_cell += 5
			Move(get_step(src, direction), direction)
			if(equipment_system.cargo_system)
				for(var/turf/T in locs)
					for(var/obj/item/I in T.contents)
						equipment_system.cargo_system.passover(I)

	else
		if(!cell)
			to_chat(user, "<span class='warning'>No energy cell detected.</span>")
		else if(cell.charge < 1)
			to_chat(user, "<span class='warning'>Not enough charge left.</span>")
		else if(!obj_integrity)
			to_chat(user, "<span class='warning'>She's dead, Jim</span>")
		else if(empcounter != 0)
			to_chat(user, "<span class='warning'>The pod control interface isn't responding. The console indicates [empcounter] seconds before reboot.</span>")
		else
			to_chat(user, "<span class='warning'>Unknown error has occurred, yell at the coders.</span>")
		return FALSE
	cell.charge = max(0, cell.charge - (1 + extra_cell))
	next_move = world.time + move_delay

/obj/effect/landmark/spacepod/random
	name = "spacepod spawner"
	invisibility = 101
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/spacepod/random/Initialize()
	. = ..()

/obj/spacepod/shuttleRotate(rotation)
	setDir(turn(dir, -rotation))

/obj/spacepod/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock) //this is to avoid fuckery
	if(rotation)
		shuttleRotate(rotation)
	loc = newT
	if(pilot || passengers.len > 0)
		update_parallax_contents()

/obj/spacepod/process()
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


	diag_hud_set_podcharge()
	diag_hud_set_podhealth()


/obj/spacepod/verb/rename_pod(new_name as text)
	set name = "Rename Pod"
	set desc = "Rename your spacepod"
	set category = "Spacepod"
	set src = usr.loc
	set popup_menu = 0

	if(usr.incapacitated())
		return

	if(usr != pilot)
		to_chat(usr, "<span class='danger'>You are unable to rename the pod, as you are not the pilot!</span>")
	else
		name = new_name

/obj/spacepod/verb/toggle_speaker()
	set name = "Configure Radio"
	set category = "Spacepod"
	set src = usr.loc
	set popup_menu = 0

	if(usr.incapacitated())
		return

	if(usr != pilot)
		to_chat(usr, "<span class='danger'>You cannot reach the buttons!</span>")
	else
		radio.interact(usr)


/obj/spacepod/verb/gps()
	set name = "View GPS"
	set category = "Spacepod"
	set src = usr.loc
	set popup_menu = 0

	if(usr.incapacitated())
		return

	if(!isobserver(usr))
		gps.ui_interact(usr)

/obj/spacepod/proc/sys_name(sname)
	switch(sname)
		if("weapon_system")
			return "Weapon System"
		if("cargo_system")
			return "Cargo System"
		if("sec_cargo_system")
			return "Secondary Cargo System"
		if("lock_system")
			return "Lock System"
		if("thruster_system")
			return "Thruster System"
	return "Misc System"


/obj/spacepod/template
	var/datum/pod_armor/armortype
	var/obj/item/device/spacepod_equipment/weaponry/weapon

/obj/spacepod/template/Initialize(mapload)
	. = ..(mapload, armortype)
	if(weapon)
		var/obj/item/device/spacepod_equipment/weaponry/T = new weapon
		T.loc = equipment_system
		equipment_system.weapon_system = T
		equipment_system.weapon_system.my_atom = src
		equipment_system.installed_modules += T
	update_icons()

/obj/spacepod/template/syndicate
	armortype = /datum/pod_armor/syndicate
	weapon = /obj/item/device/spacepod_equipment/weaponry/laser

/obj/spacepod/template/security
	armortype = /datum/pod_armor/security
	weapon = /obj/item/device/spacepod_equipment/weaponry/disabler

/obj/spacepod/template/industrial
	armortype = /datum/pod_armor/industrial

#undef DAMAGE
#undef FIRE
#undef WINDOW
#undef LIGHT
#undef RIM
#undef PAINT
