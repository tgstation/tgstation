#define DAMAGE			1
#define FIRE			2
#define LIGHT			1
#define WINDOW			2
#define RIM	    		3
#define PAINT			4

/obj/item/weapon/pod_paint_bucket
	name = "space pod paintkit"
	desc = "Pimp your ride"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_red"

/obj/spacepod
	name = "\improper space pod"
	desc = "A space pod meant for space travel."
	icon = 'goon/icons/48x48/pods.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 0

	anchored = 1

	layer = 3.9
	infra_luminosity = 15

	var/list/mob/pilot	//There is only ever one pilot and he gets all the privledge
	var/list/mob/passengers = list() //passengers can't do anything and are variable in number
	var/max_passengers = 0
	var/obj/item/weapon/storage/internal/cargo_hold

	var/datum/spacepod/equipment/equipment_system

	var/battery_type = "/obj/item/weapon/stock_parts/cell/high"
	var/obj/item/weapon/stock_parts/cell/battery

	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/use_internal_tank = 0
	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin

	var/datum/effect_system/trail_follow/ion/space_trail/ion_trail

	var/hatch_open = 0

	var/next_firetime = 0

	var/has_paint = 0

	flags = UNACIDABLE | HEAR

	var/list/pod_overlays
	var/list/pod_paint_effect
	var/list/colors = new/list(4)
	var/health = 250
	var/empcounter = 0 //Used for disabling movement when hit by an EMP

	var/lights = 0
	var/lights_power = 6
	var/list/icon_light_color = list("pod_civ" = null, \
									 "pod_mil" = "#BBF093", \
									 "pod_synd" = LIGHT_COLOR_RED, \
									 "pod_gold" = null, \
									 "pod_black" = "#3B8FE5", \
									 "pod_industrial" = "#CCCC00")

	var/unlocked = 1

	var/move_delay = 2
	var/next_move = 0

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


/obj/spacepod/New()
	. = ..()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")
	if(!pod_paint_effect)
		pod_paint_effect = new/list(4)
		pod_paint_effect[LIGHT] = image(icon,icon_state = "LIGHTS")
		pod_paint_effect[WINDOW] = image(icon,icon_state = "Windows")
		pod_paint_effect[RIM] = image(icon,icon_state = "RIM")
		pod_paint_effect[PAINT] = image(icon,icon_state = "PAINT")
	bound_width = 64
	bound_height = 64
	dir = EAST
	battery = new battery_type(src)
	add_cabin()
	add_airtank()
	src.ion_trail = new /datum/effect_system/trail_follow/ion/space_trail()
	src.ion_trail.set_up(src)
	src.ion_trail.start()
	src.use_internal_tank = 1
	equipment_system = new(src)
	equipment_system.installed_modules += battery
	GLOB.spacepods_list += src
	cargo_hold = new/obj/item/weapon/storage/internal(src)
	cargo_hold.w_class = 5	//so you can put bags in
	cargo_hold.storage_slots = 0	//You need to install cargo modules to use it.
	cargo_hold.max_w_class = 5		//fit almost anything
	cargo_hold.max_combined_w_class = 0 //you can optimize your stash with larger items

/obj/spacepod/Destroy()
	if(equipment_system.cargo_system)
		equipment_system.cargo_system.removed(null)
	QDEL_NULL(equipment_system)
	QDEL_NULL(cargo_hold)
	QDEL_NULL(battery)
	QDEL_NULL(cabin_air)
	QDEL_NULL(internal_tank)
	QDEL_NULL(ion_trail)
	occupant_sanity_check()
	if(pilot)
		pilot.forceMove(get_turf(src))
		pilot = null
	if(passengers)
		for(var/mob/M in passengers)
			M.forceMove(get_turf(src))
			passengers -= M
	GLOB.spacepods_list -= src
	return ..()

/obj/spacepod/proc/update_icons()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")

	if(!pod_paint_effect)
		pod_paint_effect = new/list(4)
		pod_paint_effect[LIGHT] = image(icon,icon_state = "LIGHTS")
		pod_paint_effect[WINDOW] = image(icon,icon_state = "Windows")
		pod_paint_effect[RIM] = image(icon,icon_state = "RIM")
		pod_paint_effect[PAINT] = image(icon,icon_state = "PAINT")
	overlays.Cut()

	if(has_paint)
		var/image/to_add
		if(!isnull(pod_paint_effect[LIGHT]))
			to_add = pod_paint_effect[LIGHT]
			to_add.color = colors[LIGHT]
			overlays += to_add
		if(!isnull(pod_paint_effect[WINDOW]))
			to_add = pod_paint_effect[WINDOW]
			to_add.color = colors[WINDOW]
			overlays += to_add
		if(!isnull(pod_paint_effect[RIM]))
			to_add = pod_paint_effect[RIM]
			to_add.color = colors[RIM]
			overlays += to_add
		if(!isnull(pod_paint_effect[PAINT]))
			to_add = pod_paint_effect[PAINT]
			to_add.color = colors[PAINT]
			overlays += to_add
	if(health <= round(initial(health)/2))
		overlays += pod_overlays[DAMAGE]
		if(health <= round(initial(health)/4))
			overlays += pod_overlays[FIRE]


	light_color = icon_light_color[src.icon_state]

/obj/spacepod/bullet_act(var/obj/item/projectile/P)
	if(P.damage_type == BRUTE || P.damage_type == BURN)
		deal_damage(P.damage)
	P.on_hit(src)

/obj/spacepod/blob_act()
	deal_damage(30)
	return

/obj/spacepod/attack_animal(mob/living/simple_animal/user as mob)
	if(user.melee_damage_upper == 0)
		user.emote(1, "[user.friendly] [src]")
	else
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		deal_damage(damage)
		visible_message("<span class='danger'>[user]</span> [user.attacktext] [src]!")
		log_attack("<font color='red'>attacked [src.name]</font>")
	return

/obj/spacepod/attack_alien(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	deal_damage(15)
	playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
	to_chat(user, "<span class='warning'>You slash at [src]!</span>")
	visible_message("<span class='warning'>The [user] slashes at [src.name]'s armor!</span>")
	return

/obj/spacepod/proc/deal_damage(var/damage)
	var/oldhealth = health
	health = max(0, health - damage)
	var/percentage = (health / initial(health)) * 100
	occupant_sanity_check()
	if(oldhealth > health && percentage <= 25 && percentage > 0)
		play_sound_to_riders('sound/effects/alert.ogg')
	if(oldhealth > health && !health)
		play_sound_to_riders('sound/effects/alert.ogg')
	if(!health)
		spawn(0)
			message_to_riders("<span class='userdanger'>Critical damage to the vessel detected, core explosion imminent!</span>")
			for(var/i = 10, i >= 0; --i)
				message_to_riders("<span class='warning'>[i]</span>")
				if(i == 0)
					explosion(loc, 2, 4, 8)
					qdel(src)
				sleep(10)

	update_icons()

/obj/spacepod/proc/repair_damage(var/repair_amount)
	if(health)
		health = min(initial(health), health + repair_amount)
		update_icons()


/obj/spacepod/ex_act(severity)
	occupant_sanity_check()
	switch(severity)
		if(1)
			if(passengers || pilot)
				for(var/mob/M in passengers | pilot)
					var/mob/living/carbon/human/H = M
					if(H)
						H.forceMove(get_turf(src))
						H.ex_act(severity + 1)
						to_chat(H, "<span class='warning'>You are forcefully thrown from [src]!</span>")
			qdel(ion_trail)
			qdel(src)
		if(2)
			deal_damage(100)
		if(3)
			if(prob(40))
				deal_damage(50)

/obj/spacepod/emp_act(severity)
	occupant_sanity_check()
	cargo_hold.emp_act(severity)

	if(battery && battery.charge > 0)
		battery.use((battery.charge/3)/(severity*2))
	deal_damage(80 / severity)
	if(empcounter < (40 / severity))
		empcounter = 40 / severity

	switch(severity)
		if(1)
			message_to_riders("<span class='warning'>The pod console flashes 'Heavy EMP WAVE DETECTED'.</span>")
		if(2)
			message_to_riders("<span class='warning'>The pod console flashes 'EMP WAVE DETECTED'.</span>")

/obj/spacepod/proc/play_sound_to_riders(mysound)
	if(length(passengers | pilot) == 0)
		return
	var/sound/S = sound(mysound)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = 50
	for(var/mob/M in passengers | pilot)
		M << S

/obj/spacepod/proc/message_to_riders(mymessage)
	if(length(passengers | pilot) == 0)
		return
	for(var/mob/M in passengers | pilot)
		to_chat(M, mymessage)

/obj/spacepod/attackby(obj/item/W as obj, mob/user as mob, params)
	if(user.a_intent == INTENT_HARM)
		..()
		deal_damage(W.force)
	else
		if(istype(W, /obj/item/weapon/crowbar))
			if(!equipment_system.lock_system || unlocked || hatch_open)
				hatch_open = !hatch_open
				playsound(loc, W.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>")
			else
				to_chat(user, "<span class='warning'>The hatch is locked shut!</span>")
			return
		if(istype(W, /obj/item/weapon/stock_parts/cell))
			if(!hatch_open)
				to_chat(user, "<span class='warning'>The maintenance hatch is closed!</span>")
				return
			if(battery)
				to_chat(user, "<span class='notice'>The pod already has a battery.</span>")
				return
			to_chat(user, "<span class='notice'>You insert [W] into the pod.</span>")
			user.drop_item(W)
			battery = W
			W.forceMove(src)
			return
		if(istype(W, /obj/item/device/spacepod_equipment))
			if(!hatch_open)
				to_chat(user, "<span class='warning'>The maintenance hatch is closed!</span>")
				return
			if(!equipment_system)
				to_chat(user, "<span class='warning'>The pod has no equipment datum, yell at the coders</span>")
				return
			if(istype(W, /obj/item/device/spacepod_equipment/weaponry))
				add_equipment(user, W, "weapon_system")
				return
			if(istype(W, /obj/item/device/spacepod_equipment/misc))
				add_equipment(user, W, "misc_system")
				return
			if(istype(W, /obj/item/device/spacepod_equipment/cargo))
				add_equipment(user, W, "cargo_system")
				return
			if(istype(W, /obj/item/device/spacepod_equipment/sec_cargo))
				add_equipment(user, W, "sec_cargo_system")
				return
			if(istype(W, /obj/item/device/spacepod_equipment/lock))
				add_equipment(user, W, "lock_system")
				return

		if(istype(W, /obj/item/device/spacepod_key) && istype(equipment_system.lock_system, /obj/item/device/spacepod_equipment/lock/keyed))
			var/obj/item/device/spacepod_key/key = W
			if(key.id == equipment_system.lock_system.id)
				lock_pod()
				return
			else
				to_chat(user, "<span class='warning'>This is the wrong key!</span>")
				return

		if(istype(W, /obj/item/weapon/weldingtool))
			if(!hatch_open)
				to_chat(user, "<span class='warning'>You must open the maintenance hatch before attempting repairs.</span>")
				return
			var/obj/item/weapon/weldingtool/WT = W
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>The welder must be on for this task.</span>")
				return
			if(health < initial(health))
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

obj/spacepod/proc/add_equipment(mob/user, var/obj/item/device/spacepod_equipment/SPE, var/slot)
	if(equipment_system.vars[slot])
		to_chat(user, "<span class='notice'>The pod already has a [slot], remove it first.</span>")
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
			src.visible_message("<span class='warning'>[user] is trying to rip the door open and pull [target] out of the [src]!</span>",
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
		to_chat(user, "<span class='warning'>The pod has no equpment datum, or is the wrong type, yell at IK3I.</span>")
		return
	var/list/possible = list()
	if(battery)
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
	switch(input(user, "Remove which equipment?", null, null) as null|anything in possible)
		if("Energy Cell")
			if(user.put_in_hands(battery))
				to_chat(user, "<span class='notice'>You remove [battery] from the space pod</span>")
				battery = null
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
	cargo_hold.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)
	..()


/obj/spacepod/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	return L

/obj/spacepod/civilian
	icon_state = "pod_civ"
	desc = "A sleek civilian space pod."

/obj/spacepod/civilian/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/weapon/pod_paint_bucket))
		apply_paint(user)
		return

/obj/spacepod/random
	icon_state = "pod_civ"
// placeholder

/obj/spacepod/sec
	name = "\improper security spacepod"
	desc = "An armed security spacepod with reinforced armor plating."
	icon_state = "pod_mil"
	health = 400

/obj/spacepod/sec/New()
	..()
	var/obj/item/device/spacepod_equipment/weaponry/burst_taser/T = new /obj/item/device/spacepod_equipment/weaponry/taser
	T.loc = equipment_system
	equipment_system.weapon_system = T
	equipment_system.weapon_system.my_atom = src
	equipment_system.installed_modules += T
	var/obj/item/device/spacepod_equipment/misc/tracker/L = new /obj/item/device/spacepod_equipment/misc/tracker
	L.loc = equipment_system
	equipment_system.misc_system = L
	equipment_system.misc_system.my_atom = src
	equipment_system.misc_system.enabled = 1
	equipment_system.installed_modules += L
	var/obj/item/device/spacepod_equipment/sec_cargo/chair/C = new /obj/item/device/spacepod_equipment/sec_cargo/chair
	C.loc = equipment_system
	equipment_system.sec_cargo_system = C
	equipment_system.sec_cargo_system.my_atom = src
	equipment_system.installed_modules += C
	max_passengers = 1
	var/obj/item/device/spacepod_equipment/lock/keyed/K = new /obj/item/device/spacepod_equipment/lock/keyed
	K.loc = equipment_system
	equipment_system.lock_system = K
	equipment_system.lock_system.my_atom = src
	equipment_system.lock_system.id = 100000
	equipment_system.installed_modules += K

/obj/spacepod/random/New()
	..()
	icon_state = pick("pod_civ", "pod_black", "pod_mil", "pod_synd", "pod_gold", "pod_industrial")
	switch(icon_state)
		if("pod_civ")
			desc = "A sleek civilian space pod."
		if("pod_black")
			desc = "An all black space pod with no insignias."
		if("pod_mil")
			desc = "A dark grey space pod brandishing the Nanotrasen Military insignia"
		if("pod_synd")
			desc = "A menacing military space pod with Fuck NT stenciled onto the side"
		if("pod_gold")
			desc = "A civilian space pod with a gold body, must have cost somebody a pretty penny"
		if("pod_industrial")
			desc = "A rough looking space pod meant for industrial work"
	update_icons()

/obj/spacepod/verb/toggle_internal_tank()
	set name = "Toggle internal airtank usage"
	set category = "Spacepod"
	set src = usr.loc
	set popup_menu = 0

	if(usr.incapacitated())
		return

	if(usr != src.pilot)
		to_chat(usr, "<span class='notice'>You can't reach the controls from your chair")
		return
	use_internal_tank = !use_internal_tank
	to_chat(usr, "<span class='notice'>Now taking air from [use_internal_tank?"internal airtank":"environment"].</span>")

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

/obj/spacepod/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()

/obj/spacepod/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)

/obj/spacepod/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/spacepod/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()

/obj/spacepod/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()

/obj/spacepod/proc/moved_other_inside(var/mob/living/carbon/human/H as mob)
	occupant_sanity_check()
	if(passengers.len < max_passengers)
		H.stop_pulling()
		H.forceMove(src)
		passengers += H
		H.forceMove(src)
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		return 1

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
				to_chat(usr, "<span class='danger'><b>That person can't fly the pod!</b></span>")
				return 0
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
	if(usr.stat != CONSCIOUS)
		return 0

	if(equipment_system.lock_system && !unlocked)
		to_chat(user, "<span class='warning'>[src]'s doors are locked!</span>")
		return 0

	if(get_dist(src, user) > 2 || get_dist(usr, user) > 1)
		to_chat(usr, "They are too far away to put inside")
		return 0

	if(!istype(user))
		return 0

	var/fukkendisk = locate(/obj/item/weapon/disk/nuclear) in GetAllContents(user)

	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return 0
	if(!ishuman(user))
		return 0

	if(fukkendisk)
		to_chat(user, "<span class='danger'><B>The nuke-disk is locking the door every time you try to open it. You get the feeling that it doesn't want to go into the spacepod.</b></span>")
		return 0

	for(var/mob/living/simple_animal/slime/S in range(1,usr))
		if(S.Target == user)
			to_chat(user, "You're too busy getting your life sucked out of you.")
			return 0

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
				return
			if(passengers.len < max_passengers)
				user.stop_pulling()
				passengers += user
				user.forceMove(src)
				add_fingerprint(user)
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
				var/mob/occupant = passengers[i - 1]
				occupant.forceMove(get_turf(src))
				log_game("##SPACEPOD WARNING: passengers EXCEED CAP: MAX passengers [max_passengers], passengers [english_list(passengers)], TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers[i - 1] = null
		for(var/mob/M in passengers)
			if(!ismob(M))
				M.forceMove(get_turf(src))
				log_game("##SPACEPOD WARNING: NON-MOB OCCUPANT [M], TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers -= M
			else if(M.loc != src)
				log_game("##SPACEPOD WARNING: OCCUPANT [M] ESCAPED, TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers -= M

/obj/spacepod/verb/exit_pod()
	set name = "Exit pod"
	set category = "Spacepod"
	set src = usr.loc

	var/mob/user = usr
	if(!istype(user))
		return

	if(usr.incapacitated()) // unconscious and restrained people can't let themselves out
		return

	occupant_sanity_check()

	if(user == pilot)
		user.forceMove(get_turf(src))
		pilot = null
		to_chat(user, "<span class='notice'>You climb out of [src].</span>")
	if(user in passengers)
		user.forceMove(get_turf(src))
		passengers -= user
		to_chat(user, "<span class='notice'>You climb out of [src].</span>")

/obj/spacepod/verb/lock_pod()
	set name = "Lock Doors"
	set category = "Spacepod"
	set src = usr.loc

	if(usr.incapacitated())
		return

	if(usr in passengers && usr != src.pilot)
		to_chat(usr, "<span class='notice'>You can't reach the controls from your chair")
		return

	unlocked = !unlocked
	to_chat(usr, "<span class='warning'>You [unlocked ? "unlock" : "lock"] the doors.</span>")


/obj/spacepod/verb/toggleDoors()
	set name = "Toggle Nearby Pod Doors"
	set category = "Spacepod"
	set src = usr.loc

	if(usr.incapacitated())
		return

	if(usr != src.pilot)
		to_chat(usr, "<span class='notice'>You can't reach the controls from your chair")
		return

	for(var/obj/machinery/door/poddoor/multi_tile/P in orange(3,src))
		var/mob/living/carbon/human/L = usr
		if(P.check_access(L.get_active_held_item()) || P.check_access(L.wear_id))
			if(P.density)
				P.open()
				return 1
			else
				P.close()
				return 1
		for(var/mob/living/carbon/human/O in passengers)
			if(P.check_access(O.get_active_held_item()) || P.check_access(O.wear_id))
				if(P.density)
					P.open()
					return 1
				else
					P.close()
					return 1
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return

	to_chat(usr, "<span class='warning'>You are not close to any pod doors.</span>")

/obj/spacepod/verb/fireWeapon()
	set name = "Fire Pod Weapons"
	set desc = "Fire the weapons."
	set category = "Spacepod"
	set src = usr.loc

	if(usr.incapacitated())
		return

	if(usr != src.pilot)
		to_chat(usr, "<span class='notice'>You can't reach the controls from your chair")
		return
	if(!equipment_system.weapon_system)
		to_chat(usr, "<span class='warning'>[src] has no weapons!</span>")
		return
	equipment_system.weapon_system.fire_weapons()

/obj/spacepod/verb/unload()
	set name = "Unload Cargo"
	set desc = "Unloads the cargo"
	set category = "Spacepod"
	set src = usr.loc

	if(usr.incapacitated())
		return

	if(usr != src.pilot)
		to_chat(usr, "<span class='notice'>You can't reach the controls from your chair")
		return
	if(!equipment_system.cargo_system)
		to_chat(usr, "<span class='warning'>[src] has no cargo system!</span>")
		return
	equipment_system.cargo_system.unload()

/obj/spacepod/verb/toggleLights()
	set name = "Toggle Lights"
	set category = "Spacepod"
	set src = usr.loc

	if(usr.incapacitated())
		return

	if(usr != src.pilot)
		to_chat(usr, "<span class='notice'>You can't reach the controls from your chair")
		return
	lightsToggle()

/obj/spacepod/proc/lightsToggle()
	lights = !lights
	if(lights)
		set_light(lights_power)
	else
		set_light(0)
	to_chat(usr, "Lights toggled [lights ? "on" : "off"].")
	for(var/mob/M in passengers)
		to_chat(M, "Lights toggled [lights ? "on" : "off"].")

/obj/spacepod/verb/checkSeat()
	set name = "Check under Seat"
	set category = "Spacepod"
	set src = usr.loc
	var/mob/user = usr

	if(usr.incapacitated())
		return

	to_chat(user, "<span class='notice'>You start rooting around under the seat for lost items</span>")
	if(do_after(user, 40, target = src))
		var/obj/badlist = list(internal_tank, cargo_hold, pilot, battery) + passengers + equipment_system.installed_modules
		var/list/true_contents = contents - badlist
		if(true_contents.len > 0)
			var/obj/I = pick(true_contents)
			if(user.put_in_hands(I))
				src.contents -= I
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
			return 0

	return 1



/obj/spacepod/relaymove(mob/user, direction)
	if(usr != src.pilot)
		return
	handlerelaymove(user, direction)

/obj/spacepod/proc/handlerelaymove(mob/user, direction)
	if(world.time < next_move)
		return 0
	var/moveship = 1
	if(battery && battery.charge >= 1 && health && empcounter == 0)
		src.dir = direction
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
			Move(get_step(src, direction), direction)
			if(equipment_system.cargo_system)
				for(var/turf/T in locs)
					for(var/obj/item/I in T.contents)
						equipment_system.cargo_system.passover(I)

	else
		if(!battery)
			to_chat(user, "<span class='warning'>No energy cell detected.</span>")
		else if(battery.charge < 1)
			to_chat(user, "<span class='warning'>Not enough charge left.</span>")
		else if(!health)
			to_chat(user, "<span class='warning'>She's dead, Jim</span>")
		else if(empcounter != 0)
			to_chat(user, "<span class='warning'>The pod control interface isn't responding. The console indicates [empcounter] seconds before reboot.</span>")
		else
			to_chat(user, "<span class='warning'>Unknown error has occurred, yell at the coders.</span>")
		return 0
	battery.charge = max(0, battery.charge - 1)
	next_move = world.time + move_delay

/obj/effect/landmark/spacepod/random
	name = "spacepod spawner"
	invisibility = 101
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/spacepod/random/New()
	..()

/obj/spacepod/process()
	var/obj/spacepod/spacepod = src //fuck you paracode for making me do this
	if(spacepod && spacepod.internal_tank)
		var/datum/gas_mixture/tank_air = spacepod.internal_tank.return_air()
		var/datum/gas_mixture/cabin_air = spacepod.cabin_air

		var/release_pressure = ONE_ATMOSPHERE
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = spacepod.get_turf_air()
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
	else
		return

	if(spacepod.cabin_air && spacepod.cabin_air.return_volume() > 0)
		var/delta = spacepod.cabin_air.temperature - T20C
		spacepod.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))


#undef DAMAGE
#undef FIRE
#undef WINDOW
#undef LIGHT
#undef RIM
#undef PAINT