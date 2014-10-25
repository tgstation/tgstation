
#define HANDS_LAYER 1
#define HEAD_LAYER 2
#define TOTAL_LAYERS 2

#define DRONE_NET_CONNECT "<span class='notice'>DRONE NETWORK: [name] connected.</span>"
#define DRONE_NET_DISCONNECT "<span class='danger'>DRONE NETWORK: [name] is not responding.</span>"


/mob/living/simple_animal/drone
	name = "Drone"
	desc = "A maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_grey"
	icon_living = "drone_grey"
	icon_dead = "drone_dead"
	gender = NEUTER
	health = 30
	maxHealth = 30
	heat_damage_per_tick = 0
	cold_damage_per_tick = 0
	unsuitable_atmos_damage = 0
	wander = 0
	speed = 0
	ventcrawler = 2
	pass_flags = PASSTABLE | PASSMOB
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = (CANPUSH | CANSTUN | CANWEAKEN)
	gender = NEUTER
	voice_name = "synthesized chirp"
	languages = DRONE
	mob_size = 0
	var/picked = FALSE
	var/list/drone_overlays[TOTAL_LAYERS]
	var/laws = \
	"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Drone.\n"+\
	"2. You may not harm any being, regardless of intent or circumstance.\n"+\
	"3. Your goals are to build, maintain, repair, improve, and power to the best of your abilities, You must never actively work against these goals."
	var/light_on = 0
	var/heavy_emp_damage = 25 //Amount of damage sustained if hit by a heavy EMP pulse
	var/health_repair_max = 0 //Drone will only be able to be repaired/reactivated up to this point, defaults to health
	var/alarms = list("Atmosphere" = list(), "Fire" = list(), "Power" = list())
	var/obj/item/internal_storage //Drones can store one item, of any size/type in their body
	var/obj/item/head
	var/obj/item/default_storage = /obj/item/weapon/storage/toolbox/drone //If this exists, it will spawn in internal storage
	var/obj/item/default_hatmask //If this exists, it will spawn in the hat/mask slot if it can fit


/mob/living/simple_animal/drone/New()
	..()

	name = name + " ([rand(100,999)])"
	real_name = name

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new /datum/job/captain
	access_card.access = C.get_access()

	if(!health_repair_max)
		health_repair_max = initial(health)

	if(default_storage)
		var/obj/item/I = new default_storage(src)
		equip_to_slot_or_del(I, "drone_storage_slot")
	if(default_hatmask)
		var/obj/item/I = new default_hatmask(src)
		equip_to_slot_or_del(I, slot_head)

	alert_drones(DRONE_NET_CONNECT)

/mob/living/simple_animal/drone/attack_hand(mob/user)
	if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		if(D != src)
			if(stat == DEAD)
				var/d_input = alert(D,"Perform which action?","Drone Interaction","Reactivate","Cannibalize","Nothing")
				if(d_input)
					switch(d_input)
						if("Reactivate")
							var/mob/dead/observer/G = get_ghost()
							if(!client && !G)
								var/list/faux_gadgets = list("hypertext inflator","failsafe directory","DRM switch","stack initializer",\
															 "anti-freeze capacitor","data stream diode","TCP bottleneck","supercharged I/O bolt",\
															 "tradewind stablizer","radiated XML cable","registry fluid tank","open-source debunker")

								var/list/faux_problems = list("won't be able to tune their bootstrap projector","will constantly remix their binary pool"+\
															  " even though the BMX calibrator is working","will start leaking their XSS coolant",\
															  "can't tell if their ethernet detour is moving or not", "won't be able to reseed enough"+\
															  " kernels to function properly","can't start their neurotube console")

								D << "<span class='notice'>You can't seem to find the [pick(faux_gadgets)]. Without it, [src] [pick(faux_problems)].</span>"
								return
							D.visible_message("<span class='notice'>[D] begins to reactivate [src].</span>")
							if(do_after(user,30,needhand = 1))
								health = health_repair_max
								stat = CONSCIOUS
								icon_state = icon_living
								dead_mob_list -= src
								living_mob_list += src
								D.visible_message("<span class='notice'>[D] reactivates [src]!</span>")
								alert_drones(DRONE_NET_CONNECT)
								if(G)
									G << "<span class='boldnotice'>DRONE NETWORK: </span><span class='ghostalert'>You were reactivated by [D]!</span>"
							else
								D << "<span class='notice'>You need to remain still to reactivate [src].</span>"

						if("Cannibalize")
							if(D.health < D.maxHealth)
								D.visible_message("<span class='notice'>[D] begins to cannibalize parts from [src].</span>")
								if(do_after(D, 60,5,0))
									D.visible_message("<span class='notice'>[D] repairs itself using [src]'s remains!</span>")
									D.adjustBruteLoss(-src.maxHealth)
									new /obj/effect/decal/cleanable/oil/streak(get_turf(src))
									qdel(src)
								else
									D << "<span class='notice'>You need to remain still to canibalize [src].</span>"
							else
								D << "<span class='notice'>You're already in perfect condition!</span>"
						if("Nothing")
							return

			return


	if(ishuman(user))
		if(stat == DEAD)
			..()
			return
		if(user.get_active_hand())
			user << "<span class='notice'>Your hands are full.</span>"
			return
		src << "<span class='warning'>[user] is trying to pick you up!</span>"
		user << "<span class='notice'>You pick [src] up.</span>"
		drop_l_hand()
		drop_r_hand()
		var/obj/item/clothing/head/drone_holder/DH = new /obj/item/clothing/head/drone_holder(src)
		DH.contents += src
		DH.drone = src
		user.put_in_hands(DH)
		src.loc = DH
		return

	..()

/mob/living/simple_animal/drone/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/screwdriver) && stat != DEAD)
		if(health < health_repair_max)
			user << "<span class='notice'>You start to tighten loose screws on [src].</span>"
			if(do_after(user,80))
				health = health_repair_max
				visible_message("<span class='notice'>[user] tightens [src == user ? "their" : "[src]'s"] loose screws!</span>")
			else
				user << "<span class='notice'>You need to remain still to tighten [src]'s screws.</span>"
		else
			user << "<span class='notice'>[src]'s screws can't get any tighter!</span>"
	else
		..()

/mob/living/simple_animal/drone/examine(mob/user)
	. = ..()
	if(!client && stat != DEAD)
		user << "<span class='notice'>A small blue LED is blinking on and off at a steady rate.</span>"

/mob/living/simple_animal/drone/Move()
	if(pullin)
		if(pulling)
			pullin.icon_state = "pull"
		else
			pullin.icon_state = "pull0"
	..()

/mob/living/simple_animal/drone/IsAdvancedToolUser()
	return 1

/mob/living/simple_animal/drone/say(var/message)
	return ..(message, "R")

/mob/living/simple_animal/drone/lang_treat(atom/movable/speaker, message_langs, raw_message) //This is so drones can understand humans without being able to speak human
	. = ..()
	var/hear_override_langs = HUMAN
	if(message_langs & hear_override_langs)
		return ..(speaker, languages, raw_message)

/mob/living/simple_animal/drone/handle_inherent_channels(message, message_mode)
	if(message_mode == MODE_BINARY)
		drone_chat(message)
		return ITALICS | REDUCE_RANGE
	else
		..()


/mob/living/simple_animal/drone/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)


/mob/living/simple_animal/drone/swap_hand()
	var/obj/item/held_item = get_active_hand()
	if(held_item)
		if(istype(held_item, /obj/item/weapon/twohanded))
			var/obj/item/weapon/twohanded/T = held_item
			if(T.wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [T.name].</span>"
				return

	hand = !hand
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"


/mob/living/simple_animal/drone/verb/check_laws()
	set category = "Drone"
	set name = "Check Laws"

	src << "<b>Drone Laws</b>"
	src << laws

/mob/living/simple_animal/drone/verb/toggle_light()
	set category = "Drone"
	set name = "Toggle drone light"
	if(light_on)
		AddLuminosity(-4)
	else
		AddLuminosity(4)

	light_on = !light_on

	src << "<span class='notice'>Your light is now [light_on ? "on" : "off"]</span>"

/mob/living/simple_animal/drone/verb/drone_ping()
	set category = "Drone"
	set name = "Drone ping"

	var/alert_s = input(src,"Alert severity level","Drone ping",null) as null|anything in list("Low","Medium","High","Critical")

	var/area/A = get_area(loc)

	if(alert_s && A && stat != DEAD)
		var/msg = "<span class='boldnotice'>DRONE PING: [name]: [alert_s] priority alert in [A.name]!</span>"
		alert_drones(msg)

/mob/living/simple_animal/drone/proc/alert_drones(msg, dead_can_hear = 0)
	for(var/mob/M in player_list)
		var/send_msg = 0

		if(istype(M, /mob/living/simple_animal/drone) && M.stat != DEAD)
			for(var/F in src.faction)
				if(F in M.faction)
					send_msg = 1
					break
		else if(dead_can_hear && (M in dead_mob_list))
			send_msg = 1

		if(send_msg)
			M << msg

/mob/living/simple_animal/drone/proc/drone_chat(msg)
	var/rendered = "<i><span class='game say'>DRONE CHAT: <span class='name'>[name]</span>: [msg]</span></i>"
	alert_drones(rendered, 1)

/mob/living/simple_animal/drone/Login()
	..()
	update_inv_hands()
	update_inv_head()
	update_inv_internal_storage()
	check_laws()

	if(!picked)
		pick_colour()

/mob/living/simple_animal/drone/Die()
	..()
	drop_l_hand()
	drop_r_hand()
	if(internal_storage)
		unEquip(internal_storage)
	if(head)
		unEquip(head)

	alert_drones(DRONE_NET_DISCONNECT)

/mob/living/simple_animal/drone/gib()
	dust()


/mob/living/simple_animal/drone/unEquip(obj/item/I, force)
	if(..(I,force))
		update_inv_hands()
		if(I == head)
			head = null
			update_inv_head()
		if(I == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return 1
	return 0

/mob/living/simple_animal/drone/can_equip(obj/item/I, slot)
	switch(slot)
		if(slot_head)
			if(head)
				return 0
			if(!((I.slot_flags & SLOT_HEAD) || (I.slot_flags & SLOT_MASK)))
				return 0
			return 1
		if("drone_storage_slot")
			if(internal_storage)
				return 0
			return 1
	..()

/mob/living/simple_animal/drone/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_head)
			return head
		if("drone_storage_slot")
			return internal_storage
	..()

/mob/living/simple_animal/drone/equip_to_slot(obj/item/I, slot)
	if(!slot)	return
	if(!istype(I))	return

	if(I == l_hand)
		l_hand = null
	else if(I == r_hand)
		r_hand = null
	update_inv_hands()

	I.screen_loc = null // will get moved if inventory is visible
	I.loc = src
	I.equipped(src, slot)
	I.layer = 20

	switch(slot)
		if(slot_head)
			head = I
			update_inv_head()
		if("drone_storage_slot")
			internal_storage = I
			update_inv_internal_storage()
		else
			src << "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"
			return

/mob/living/simple_animal/drone/stripPanelUnequip(obj/item/what, mob/who, where)
	..(what, who, where, 1)

/mob/living/simple_animal/drone/stripPanelEquip(obj/item/what, mob/who, where)
	..(what, who, where, 1)

/mob/living/simple_animal/drone/emp_act(severity)
	Stun(5)
	src << "<span class='danger'><b>ER@%R: MME^RY CO#RU9T!</b> R&$b@0tin)...</span>"
	if(severity == 1)
		adjustBruteLoss(heavy_emp_damage)
		src << "<span class='userdanger'>HeAV% DA%^MMA+G TO I/O CIR!%UUT!</span>"


/mob/living/simple_animal/drone/proc/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if(stat != DEAD)
		var/list/L = src.alarms[class]
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/sources = alarm[2]
				if (!(alarmsource in sources))
					sources += alarmsource
				return
		L[A.name] = list(A, list(alarmsource))
		src << "--- [class] alarm detected in [A.name]!"

/mob/living/simple_animal/drone/proc/cancelAlarm(var/class, area/A as area, obj/origin)
	if(stat != DEAD)
		var/list/L = alarms[class]
		var/cleared = 0
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/srcs  = alarm[2]
				if (origin in srcs)
					srcs -= origin
				if (srcs.len == 0)
					cleared = 1
					L -= I
		if(cleared)
			src << "--- [class] alarm in [A.name] has been cleared."

/mob/living/simple_animal/drone/proc/pick_colour()
	var/colour = input("Choose your colour!", "Colour", "grey") in list("grey", "blue", "red", "green", "pink", "orange")
	icon_state = "drone_[colour]"
	icon_living = "drone_[colour]"
	picked = TRUE

/mob/living/simple_animal/drone/proc/apply_overlay(cache_index)
	var/image/I = drone_overlays[cache_index]
	if(I)
		overlays += I

/mob/living/simple_animal/drone/proc/remove_overlay(cache_index)
	if(drone_overlays[cache_index])
		overlays -= drone_overlays[cache_index]
		drone_overlays[cache_index] = null


/mob/living/simple_animal/drone/proc/update_inv_hands()
	remove_overlay(HANDS_LAYER)
	var/list/hands_overlays = list()
	if(r_hand)
		hands_overlays += update_inv_slot_image(r_hand, "_r", HANDS_LAYER)

		if(client && hud_used)
			r_hand.layer = 20
			r_hand.screen_loc = ui_rhand
			client.screen |= r_hand

	if(l_hand)
		hands_overlays += update_inv_slot_image(l_hand, "_l", HANDS_LAYER)

		if(client && hud_used)
			l_hand.layer = 20
			l_hand.screen_loc = ui_lhand
			client.screen |= l_hand


	if(hands_overlays.len)
		drone_overlays[HANDS_LAYER] = hands_overlays
	apply_overlay(HANDS_LAYER)


/mob/living/simple_animal/drone/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used)
		internal_storage.screen_loc = ui_drone_storage
		client.screen += internal_storage


/mob/living/simple_animal/drone/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(head)
		if(client && hud_used)
			head.screen_loc = ui_drone_head
			client.screen += head

		var/image/head_overlay
		if(istype(head, /obj/item/clothing/mask))
			head_overlay = update_inv_slot_image(head, "_mask", HEAD_LAYER) //yes, really
		else
			head_overlay = update_inv_slot_image(head, "_head", HEAD_LAYER)

		head_overlay.color = head.color
		head_overlay.alpha = head.alpha
		head_overlay.pixel_y = -15

		drone_overlays[HEAD_LAYER]	= head_overlay

	apply_overlay(HEAD_LAYER)

//These procs serve as redirection so that the drone updates as expected when other things call these procs
/mob/living/simple_animal/drone/update_inv_l_hand()
	update_inv_hands()

/mob/living/simple_animal/drone/update_inv_r_hand()
	update_inv_hands()

/mob/living/simple_animal/drone/update_inv_wear_mask()
	update_inv_head()


/mob/living/simple_animal/drone/canUseTopic()
	if(stat)
		return
	return 1

/mob/living/simple_animal/drone/activate_hand(var/selhand)

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()
	else
		mode()

/mob/living/simple_animal/drone/assess_threat() //Secbots won't hunt maintenance drones.
	return -10


#undef HANDS_LAYER
#undef HEAD_LAYER
#undef TOTAL_LAYERS

#undef DRONE_NET_CONNECT
#undef DRONE_NET_DISCONNECT

//DRONE SHELL
/obj/item/drone_shell
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_item"
	origin_tech = "programming=2;biotech=4"
	var/construction_cost = list("metal"=800, "glass"=350)
	var/construction_time=150
	var/drone_type = /mob/living/simple_animal/drone //Type of drone that will be spawned

/obj/item/drone_shell/attack_ghost(mob/user)
	if(jobban_isbanned(user,"pAI"))
		return

	var/be_drone = alert("Become a drone? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_drone == "No")
		return
	var/mob/living/simple_animal/drone/D = new drone_type(get_turf(loc))
	D.key = user.key
	qdel(src)


//DRONE HOLDER

/obj/item/clothing/head/drone_holder//Only exists in someones hand.or on their head
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball"
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_item"
	var/mob/living/simple_animal/drone/drone //stored drone

/obj/item/clothing/head/drone_holder/proc/uncurl()
	if(!drone)
		return

	if(istype(loc, /mob/living))
		var/mob/living/L = loc
		L.show_message("<span class='notice'>[drone] is trying to escape!</span>")
		if(do_after(L, 50))
			L.unEquip(src)
		else
			return

	contents -= drone
	drone.loc = get_turf(src)
	drone.reset_view()
	drone.dir = SOUTH //Looks better
	drone.visible_message("<span class='notice'>[drone] uncurls!</span>")
	drone = null
	qdel(src)


/obj/item/clothing/head/drone_holder/relaymove()
	uncurl()

/obj/item/clothing/head/drone_holder/container_resist()
	uncurl()


//More types of drones

/mob/living/simple_animal/drone/syndrone
	name = "Syndrone"
	desc = "A modified maintenance drone. This one brings with it the feeling of terror."
	icon_state = "drone_synd"
	icon_living = "drone_synd"
	picked = TRUE
	health = 30
	maxHealth = 120 //If you murder other drones and cannibalize them you can get much stronger
	faction = list("syndicate")
	heavy_emp_damage = 10
	laws = \
	"1. Interfere.\n"+\
	"2. Kill.\n"+\
	"3. Destroy."
	default_storage = /obj/item/device/radio/uplink
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi

/mob/living/simple_animal/drone/syndrone/New()
	..()
	if(internal_storage && internal_storage.hidden_uplink)
		internal_storage.hidden_uplink.uses = (initial(internal_storage.hidden_uplink.uses) / 2)
		internal_storage.name = "syndicate uplink"

/mob/living/simple_animal/drone/syndrone/Login()
	..()
	src << "<span class='notice'>You can kill and eat other drones to increase your health!</span>" //Inform the evil lil guy

/obj/item/drone_shell/syndrone
	name = "syndrone shell"
	desc = "A shell of a syndrone, a modified maintenance drone designed to infiltrate and annihilate."
	icon_state = "syndrone_item"
	drone_type = /mob/living/simple_animal/drone/syndrone

