/mob/living/simple_animal/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	layer = 5
	density = 0
	anchored = 0
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB

	radio_key = /obj/item/device/encryptionkey/headset_sec
	radio_channel = "Security" //Security channel
	bot_type = SEC_BOT
	model = "Securitron"
	bot_core_type = /obj/machinery/bot_core/secbot
	window_id = "autosec"
	window_name = "Automatic Security Unit v1.6"

	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/declare_arrests = 1 //When making an arrest, should it notify everyone on the security channel?
	var/idcheck = 0 //If true, arrest people with no IDs
	var/weaponscheck = 0 //If true, arrest people for weapons if they lack access
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff

/mob/living/simple_animal/bot/secbot/beepsky
	name = "Officer Beep O'sky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	idcheck = 0
	weaponscheck = 0
	auto_patrol = 1

/mob/living/simple_animal/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	radio_channel = "AI Private"

/mob/living/simple_animal/bot/secbot/New()
	..()
	icon_state = "secbot[on]"
	spawn(3)
		var/datum/job/detective/J = new/datum/job/detective
		access_card.access += J.get_access()
		prev_access = access_card.access

	//SECHUD
	var/datum/atom_hud/secsensor = huds[DATA_HUD_SECURITY_ADVANCED]
	secsensor.add_hud_to(src)

/mob/living/simple_animal/bot/secbot/turn_on()
	..()
	icon_state = "secbot[on]"

/mob/living/simple_animal/bot/secbot/turn_off()
	..()
	icon_state = "secbot[on]"

/mob/living/simple_animal/bot/secbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = 0
	walk_to(src,0)
	last_found = world.time

/mob/living/simple_animal/bot/secbot/set_custom_texts()

	text_hack = "You overload [name]'s target identification system."
	text_dehack = "You reboot [name] and restore the target identification."
	text_dehack_fail = "[name] refuses to accept your authority!"

/mob/living/simple_animal/bot/secbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += text({"
<TT><B>Securitron v1.6 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},

"<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user))
		dat += text({"<BR>
Arrest Unidentifiable Persons: []<BR>
Arrest for Unauthorized Weapons: []<BR>
Arrest for Warrant: []<BR>
Operating Mode: []<BR>
Report Arrests[]<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=idcheck'>[idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=weaponscheck'>[weaponscheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )
	
	return	dat

/mob/living/simple_animal/bot/secbot/Topic(href, href_list)

	..()

	switch(href_list["operation"])
		if("idcheck")
			idcheck = !idcheck
			update_controls()
		if("weaponscheck")
			weaponscheck = !weaponscheck
			update_controls()
		if("ignorerec")
			check_records = !check_records
			update_controls()
		if("switchmode")
			arrest_type = !arrest_type
			update_controls()
		if("declarearrests")
			declare_arrests = !declare_arrests
			update_controls()

/mob/living/simple_animal/bot/secbot/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == "harm")
		threatlevel = M.assess_threat(src)
		threatlevel += 6
		if(threatlevel >= 4)
			target = M
			mode = BOT_HUNT
	return ..()

/mob/living/simple_animal/bot/secbot/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "harm") // Any intent but harm will heal, so we shouldn't get angry.
		return
	if(!istype(W, /obj/item/weapon/screwdriver) && (W.force) && (!target) && (W.damtype != STAMINA) ) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		threatlevel = user.assess_threat(src)
		threatlevel += 6
		if(threatlevel >= 4)
			target = user
			mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/Emag(mob/user)
	..()

	if(emagged == 2)
		if(user)
			user << "<span class='danger'>You short out [src]'s target assessment circuits.</span>"
			oldtarget_name = user.name
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		declare_arrests = 0
		icon_state = "secbot[on]"

/mob/living/simple_animal/bot/secbot/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if (!Proj.nodamage && Proj.damage < src.health)
				threatlevel = Proj.firer.assess_threat(src)
				threatlevel += 6
				if(threatlevel >= 4)
					target = Proj.firer
					mode = BOT_HUNT
	..()


/mob/living/simple_animal/bot/secbot/UnarmedAttack(atom/A)
	if(!on)
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C.stunned || arrest_type)
			stun_attack(A)
		else if(C.canBeHandcuffed() && !C.handcuffed)
			cuff(A)
	else
		..()

/mob/living/simple_animal/bot/secbot/proc/cuff(mob/living/carbon/C)
	mode = BOT_ARREST
	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
	C.visible_message("<span class='danger'>[src] is trying to put zipties on [C]!</span>",\
						"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
	spawn(60)
		if( !Adjacent(C) || !isturf(C.loc) ) //if he's in a closet or not adjacent, we cancel cuffing.
			return
		if(!C.handcuffed)
			C.handcuffed = new /obj/item/weapon/restraints/handcuffs/cable/zipties/used(C)
			C.update_inv_handcuffed(0)	//update the handcuffs overlay
			playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
			back_to_idle()

/mob/living/simple_animal/bot/secbot/proc/stun_attack(mob/living/carbon/C)
	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
	icon_state = "secbot-c"
	spawn(2)
		icon_state = "secbot[on]"
	var/threat = 5
	if(istype(C, /mob/living/carbon/human))
		C.stuttering = 5
		C.Stun(5)
		C.Weaken(5)
		var/mob/living/carbon/human/H = C
		threat = H.assess_threat(src)
	else
		C.Weaken(5)
		C.stuttering = 5
		C.Stun(5)
	add_logs(src,C,"stunned")
	if(declare_arrests)
		var/area/location = get_area(src)
		speak("[arrest_type ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C]</b> in [location].", radio_channel)
	C.visible_message("<span class='danger'>[src] has stunned [C]!</span>",\
							"<span class='userdanger'>[src] has stunned you!</span>")

/mob/living/simple_animal/bot/secbot/handle_automated_action()
	if (!..())
		return

	switch(mode)

		if(BOT_IDLE)		// idle

			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp

			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				walk_to(src,0)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc))	// if right next to perp
					stun_attack(target)

					mode = BOT_PREP_ARREST
					anchored = 1
					target_lastloc = target.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					walk_to(src, target,1,4)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_PREP_ARREST)		// preparing to arrest target

			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if( !Adjacent(target) || !isturf(target.loc) ||  target.weakened < 2 )
				back_to_hunt()
				return

			if(iscarbon(target) && target.canBeHandcuffed())
				if(!arrest_type)
					if(!target.handcuffed)  //he's not cuffed? Try to cuff him!
						cuff(target)
					else
						back_to_idle()
						return
			else
				back_to_idle()
				return

		if(BOT_ARREST)
			if (!target)
				anchored = 0
				mode = BOT_IDLE
				last_found = world.time
				frustration = 0
				return

			if(target.handcuffed) //no target or target cuffed? back to idle.
				back_to_idle()
				return

			if( !Adjacent(target) || !isturf(target.loc) || (target.loc != target_lastloc && target.weakened < 2) ) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
				return
			else //Try arresting again if the target escapes.
				mode = BOT_PREP_ARREST
				anchored = 0

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


	return

/mob/living/simple_animal/bot/secbot/proc/back_to_idle()
	anchored = 0
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	spawn(0)
		handle_automated_action() //ensure bot quickly responds

/mob/living/simple_animal/bot/secbot/proc/back_to_hunt()
	anchored = 0
	frustration = 0
	mode = BOT_HUNT
	spawn(0)
		handle_automated_action() //ensure bot quickly responds
// look for a criminal in view of the bot

/mob/living/simple_animal/bot/secbot/proc/look_for_perp()
	anchored = 0
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(src)

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			playsound(loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = BOT_HUNT
			spawn(0)
				handle_automated_action()	// ensure bot quickly responds to a perp
			break
		else
			continue
/mob/living/simple_animal/bot/secbot/proc/check_for_weapons(var/obj/item/slot_item)
	if(slot_item && slot_item.needs_permit)
		return 1
	return 0

/mob/living/simple_animal/bot/secbot/explode()

	walk_to(src,0)
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/secbot_assembly/Sa = new /obj/item/weapon/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += "hs_hole"
	Sa.created_name = name
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/weapon/melee/baton(Tsec)

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(loc)
	..()

/mob/living/simple_animal/bot/secbot/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/Crossed(atom/movable/AM)
	if(ismob(AM) && target)
		var/mob/living/carbon/C = AM
		if(!istype(C) || !C || in_range(src, target))
			return
		C.visible_message("<span class='warning'>[pick( \
						  "[C] dives out of [src]'s way!", \
						  "[C] stumbles over [src]!", \
						  "[C] jumps out of [src]'s path!", \
						  "[C] trips over [src] and falls!", \
						  "[C] topples over [src]!", \
						  "[C] leaps out of [src]'s way!")]</span>")
		C.Weaken(2)
		return
	..()

//Secbot Construction

/obj/item/clothing/head/helmet/attackby(obj/item/device/assembly/signaler/S, mob/user, params)
	..()
	if(!issignaler(S))
		..()
		return

	if(type != /obj/item/clothing/head/helmet/sec) //Eh, but we don't want people making secbots out of space helmets.
		return

	if(F) //Has a flashlight. Player must remove it, else it will be lost forever.
		user << "<span class='warning'>The mounted flashlight is in the way, remove it first!</span>"
		return

	if(S.secured)
		qdel(S)
		var/obj/item/weapon/secbot_assembly/A = new /obj/item/weapon/secbot_assembly
		user.put_in_hands(A)
		user << "<span class='notice'>You add the signaler to the helmet.</span>"
		user.unEquip(src, 1)
		qdel(src)
	else
		return

/obj/item/weapon/secbot_assembly/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/weapon/weldingtool))
		if(!build_step)
			var/obj/item/weapon/weldingtool/WT = I
			if(WT.remove_fuel(0, user))
				build_step++
				overlays += "hs_hole"
				user << "<span class='notice'>You weld a hole in [src]!</span>"
		else if(build_step == 1)
			var/obj/item/weapon/weldingtool/WT = I
			if(WT.remove_fuel(0, user))
				build_step--
				overlays -= "hs_hole"
				user << "<span class='notice'>You weld the hole in [src] shut!</span>"

	else if(isprox(I) && (build_step == 1))
		if(!user.unEquip(I))
			return
		build_step++
		user << "<span class='notice'>You add the prox sensor to [src]!</span>"
		overlays += "hs_eye"
		name = "helmet/signaler/prox sensor assembly"
		qdel(I)

	else if(((istype(I, /obj/item/robot_parts/l_arm)) || (istype(I, /obj/item/robot_parts/r_arm))) && (build_step == 2))
		if(!user.unEquip(I))
			return
		build_step++
		user << "<span class='notice'>You add the robot arm to [src]!</span>"
		name = "helmet/signaler/prox sensor/robot arm assembly"
		overlays += "hs_arm"
		qdel(I)

	else if((istype(I, /obj/item/weapon/melee/baton)) && (build_step >= 3))
		if(!user.unEquip(I))
			return
		build_step++
		user << "<span class='notice'>You complete the Securitron! Beep boop.</span>"
		var/mob/living/simple_animal/bot/secbot/S = new/mob/living/simple_animal/bot/secbot(get_turf(src))
		S.name = created_name
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t

	else if(istype(I, /obj/item/weapon/screwdriver))
		if(!build_step)
			new /obj/item/device/assembly/signaler(get_turf(src))
			new /obj/item/clothing/head/helmet/sec(get_turf(src))
			user << "<span class='notice'>You disconnect the signaler from the helmet.</span>"
			qdel(src)

		else if(build_step == 2)
			overlays -= "hs_eye"
			new /obj/item/device/assembly/prox_sensor(get_turf(src))
			user << "<span class='notice'>You detach the proximity sensor from [src].</span>"
			build_step--

		else if(build_step == 3)
			overlays -= "hs_arm"
			new /obj/item/robot_parts/l_arm(get_turf(src))
			user << "<span class='notice'>You remove the robot arm from [src].</span>"
			build_step--

/obj/machinery/bot_core/secbot
	req_access = list(access_security)
