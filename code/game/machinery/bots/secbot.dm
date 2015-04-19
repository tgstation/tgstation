/obj/machinery/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5
//	weight = 1.0E7
	req_access = list(access_security)
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
//	var/emagged = 0 //Emagged Secbots view everyone as a criminal
	var/declare_arrests = 1 //When making an arrest, should it notify everyone on the security channel?
	var/idcheck = 0 //If true, arrest people with no IDs
	var/weaponscheck = 0 //If true, arrest people for weapons if they lack access
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	radio_frequency = SEC_FREQ //Security channel
	bot_type = SEC_BOT

/obj/machinery/bot/secbot/beepsky
	name = "Officer Beep O'sky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	idcheck = 0
	weaponscheck = 0
	auto_patrol = 1

/obj/machinery/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	radio_frequency = AIPRIV_FREQ

/obj/item/weapon/secbot_assembly
	name = "incomplete securitron assembly"
	desc = "Some sort of bizarre assembly made from a proximity sensor, helmet, and signaler."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess



/obj/machinery/bot/secbot/New()
	..()
	icon_state = "secbot[on]"
	spawn(3)

		var/datum/job/detective/J = new/datum/job/detective
		botcard.access = J.get_access()
		prev_access = botcard.access


/obj/machinery/bot/secbot/turn_on()
	..()
	icon_state = "secbot[on]"
	updateUsrDialog()

/obj/machinery/bot/secbot/turn_off()
	..()
	icon_state = "secbot[on]"
	updateUsrDialog()

/obj/machinery/bot/secbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = 0
	walk_to(src,0)
	last_found = world.time

/obj/machinery/bot/secbot/set_custom_texts()

	text_hack = "You overload [name]'s target identification system."
	text_dehack = "You reboot [name] and restore the target identification."
	text_dehack_fail = "[name] refuses to accept your authority!"

/obj/machinery/bot/secbot/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/secbot/interact(mob/user as mob)
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

	var/datum/browser/popup = new(user, "autosec", "Automatic Security Unit v1.6")
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/bot/secbot/Topic(href, href_list)

	..()

	switch(href_list["operation"])
		if("idcheck")
			idcheck = !idcheck
			updateUsrDialog()
		if("weaponscheck")
			weaponscheck = !weaponscheck
			updateUsrDialog()
		if("ignorerec")
			check_records = !check_records
			updateUsrDialog()
		if("switchmode")
			arrest_type = !arrest_type
			updateUsrDialog()
		if("declarearrests")
			declare_arrests = !declare_arrests
			updateUsrDialog()


/obj/machinery/bot/secbot/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(user) && !open && !emagged)
			locked = !locked
			user << "Controls are now [locked ? "locked." : "unlocked."]"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='danger'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='danger'> Access denied.</span>"
	else
		..()
		if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "harm") // Any intent but harm will heal, so we shouldn't get angry.
			return
		if(!istype(W, /obj/item/weapon/screwdriver) && (W.force) && (!target) && (W.damtype != STAMINA) ) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
			threatlevel = user.assess_threat(src)
			threatlevel += 6
			if(threatlevel >= 4)
				target = user
				mode = BOT_HUNT

/obj/machinery/bot/secbot/Emag(mob/user as mob)
	..()

	if(emagged == 2)
		if(user)
			user << "<span class='danger'> You short out [src]'s target assessment circuits.</span>"
			oldtarget_name = user.name
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		declare_arrests = 0
		icon_state = "secbot[on]"

/obj/machinery/bot/secbot/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if (!Proj.nodamage && Proj.damage < src.health)
				threatlevel = Proj.firer.assess_threat(src)
				threatlevel += 6
				if(threatlevel >= 4)
					target = Proj.firer
					mode = BOT_HUNT
	..()

/obj/machinery/bot/secbot/bot_process()
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
					playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
					icon_state = "secbot-c"
					spawn(2)
						icon_state = "secbot[on]"
					var/mob/living/carbon/M = target
					if(istype(M, /mob/living/carbon/human))
						M.stuttering = 5
						M.Stun(5)
						M.Weaken(5)
					else
						M.Weaken(5)
						M.stuttering = 5
						M.Stun(5)

					if(declare_arrests)
						var/area/location = get_area(src)
						speak("[arrest_type ? "Detaining" : "Arresting"] level [threatlevel] scumbag <b>[target]</b> in [location].", radio_frequency)
					target.visible_message("<span class='danger'>[src] has stunned [target]!</span>",\
											"<span class='userdanger'>[src] has stunned you!</span>")

					mode = BOT_PREP_ARREST
					anchored = 1
					target_lastloc = M.loc
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
						mode = BOT_ARREST
						playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
						target.visible_message("<span class='danger'>[src] is trying to put zipties on [target]!</span>",\
											"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
						spawn(60)
							if( !Adjacent(target) || !isturf(target.loc) ) //if he's in a closet or not adjacent, we cancel cuffing.
								return
							if(!target.handcuffed)
								target.handcuffed = new /obj/item/weapon/restraints/handcuffs/cable/zipties/used(target)
								target.update_inv_handcuffed(0)	//update the handcuffs overlay
								playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
								back_to_idle()
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

/obj/machinery/bot/secbot/proc/back_to_idle()
	anchored = 0
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	spawn(0)
		bot_process() //ensure bot quickly responds

/obj/machinery/bot/secbot/proc/back_to_hunt()
	anchored = 0
	frustration = 0
	mode = BOT_HUNT
	spawn(0)
		bot_process() //ensure bot quickly responds
// look for a criminal in view of the bot

/obj/machinery/bot/secbot/proc/look_for_perp()
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
				bot_process()	// ensure bot quickly responds to a perp
			break
		else
			continue
/obj/machinery/bot/secbot/proc/check_for_weapons(var/obj/item/slot_item)
	if(slot_item && slot_item.needs_permit)
		return 1
	return 0

/obj/machinery/bot/secbot/explode()

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

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(loc)
	qdel(src)

/obj/machinery/bot/secbot/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT

//Secbot Construction

/obj/item/clothing/head/helmet/attackby(var/obj/item/device/assembly/signaler/S, mob/user as mob, params)
	..()
	if(!issignaler(S))
		..()
		return

	if(type != /obj/item/clothing/head/helmet/sec) //Eh, but we don't want people making secbots out of space helmets.
		return

	if(!helmetCam) //I am so sorry for this. I could not think of a less terrible (and lazy) way.
		user << "<span class='warning'>[src] needs to have a camera attached first!</span>"
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
		user.drop_item()
		build_step++
		user << "<span class='notice'>You add the prox sensor to [src]!</span>"
		overlays += "hs_eye"
		name = "helmet/signaler/prox sensor assembly"
		qdel(I)

	else if(((istype(I, /obj/item/robot_parts/l_arm)) || (istype(I, /obj/item/robot_parts/r_arm))) && (build_step == 2))
		user.drop_item()
		build_step++
		user << "<span class='notice'>You add the robot arm to [src]!</span>"
		name = "helmet/signaler/prox sensor/robot arm assembly"
		overlays += "hs_arm"
		qdel(I)

	else if((istype(I, /obj/item/weapon/melee/baton)) && (build_step >= 3))
		user.drop_item()
		build_step++
		user << "<span class='notice'>You complete the Securitron! Beep boop.</span>"
		var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot
		S.loc = get_turf(src)
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