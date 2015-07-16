/obj/machinery/bot/ed209
	name = "\improper ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed2090"
	layer = 5.0
	density = 1
	anchored = 0
//	weight = 1.0E7
	req_access = list(access_security)
	health = 100
	maxhealth = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	var/lastfired = 0
	var/shot_delay = 3 //.3 seconds between shots
	var/lasercolor = ""
	var/disabled = 0//A holder for if it needs to be disabled, if true it will not seach for targets, shoot at targets, or move, currently only used for lasertag

	//var/lasers = 0

	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
//var/emagged = 0 //Emagged Secbots view everyone as a criminal
	var/declare_arrests = 1 //When making an arrest, should it notify everyone wearing sechuds?
	var/idcheck = 1 //If true, arrest people with no IDs
	var/weaponscheck = 1 //If true, arrest people for weapons if they don't have access
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/projectile = /obj/item/projectile/energy/electrode //Holder for projectile type
	var/shoot_sound = 'sound/weapons/Taser.ogg'
	radio_frequency = SEC_FREQ
	bot_type = SEC_BOT
	model = "ED-209"


/obj/item/weapon/ed209_assembly
	name = "\improper ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = ""


/obj/machinery/bot/ed209/New(loc,created_name,created_lasercolor)
	..()
	if(created_name)
		name = created_name
	if(created_lasercolor)
		lasercolor = created_lasercolor
	icon_state = "[lasercolor]ed209[on]"
	set_weapon() //giving it the right projectile and firing sound.
	spawn(3)
		var/datum/job/detective/J = new/datum/job/detective
		botcard.access += J.get_access()
		prev_access = botcard.access

		if(lasercolor)
			shot_delay = 6//Longer shot delay because JESUS CHRIST
			check_records = 0//Don't actively target people set to arrest
			arrest_type = 1//Don't even try to cuff
			req_access = list(access_maint_tunnels, access_theatre)
			arrest_type = 1
			if((lasercolor == "b") && (name == "\improper ED-209 Security Robot"))//Picks a name if there isn't already a custome one
				name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
			if((lasercolor == "r") && (name == "\improper ED-209 Security Robot"))
				name = pick("RED RAMPAGE","RED ROVER","RED KILLDEATH MURDERBOT")

/obj/machinery/bot/ed209/turn_on()
	. = ..()
	icon_state = "[lasercolor]ed209[on]"
	mode = BOT_IDLE
	updateUsrDialog()

/obj/machinery/bot/ed209/turn_off()
	..()
	icon_state = "[lasercolor]ed209[on]"
	updateUsrDialog()

/obj/machinery/bot/ed209/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = 0
	walk_to(src,0)
	last_found = world.time
	set_weapon()

/obj/machinery/bot/ed209/set_custom_texts()
	text_hack = "You disable [name]'s combat inhibitor."
	text_dehack = "You restore [name]'s combat inhibitor."
	text_dehack_fail = "[name] ignores your attempts to restrict him!"

/obj/machinery/bot/ed209/attack_hand(mob/user)
	. = ..()
	if (.)
		return
	var/dat
	dat += hack(user)
	dat += text({"
<TT><B>Security Unit v2.6 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]<BR>"},

"<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user))
		if(!lasercolor)
			dat += text({"<BR>
Arrest Unidentifiable Persons: []<BR>
Arrest for Unauthorized Weapons: []<BR>
Arrest for Warrant: []<BR>
<BR>
Operating Mode: []<BR>
Report Arrests[]<BR>
Auto Patrol[]"},

"<A href='?src=\ref[src];operation=idcheck'>[idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=weaponscheck'>[weaponscheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )
	var/datum/browser/popup = new(user, "autoed209", "Automatic Security Unit v2.6")
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/bot/ed209/Topic(href, href_list)
	if(lasercolor && (istype(usr,/mob/living/carbon/human)))
		var/mob/living/carbon/human/H = usr
		if((lasercolor == "b") && (istype(H.wear_suit, /obj/item/clothing/suit/redtag)))//Opposing team cannot operate it
			return
		else if((lasercolor == "r") && (istype(H.wear_suit, /obj/item/clothing/suit/bluetag)))
			return
	..()

	switch(href_list["operation"])
		if ("idcheck")
			idcheck = !idcheck
		if("weaponscheck")
			weaponscheck = !weaponscheck
			updateUsrDialog()
		if ("ignorerec")
			check_records = !check_records
			updateUsrDialog()
		if ("switchmode")
			arrest_type = !arrest_type
			updateUsrDialog()
		if("declarearrests")
			declare_arrests = !declare_arrests
			updateUsrDialog()

/obj/machinery/bot/ed209/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (allowed(user) && !open && !emagged)
			locked = !locked
			user << "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='notice'>Access denied.</span>"
	else
		..()
		if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "harm") // Any intent but harm will heal, so we shouldn't get angry.
			return
		if (!istype(W, /obj/item/weapon/screwdriver) && (!target)) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
			if(W.force && W.damtype != STAMINA)//If force is non-zero and damage type isn't stamina.
				threatlevel = user.assess_threat(src)
				threatlevel += 6
				if(threatlevel >= 4)
					target = user
					if(lasercolor)//To make up for the fact that lasertag bots don't hunt
						shootAt(user)
					mode = BOT_HUNT

/obj/machinery/bot/ed209/Emag(mob/user)
	..()
	if(emagged == 2)
		if(user)
			user << "<span class='warning'>You short out [src]'s target assessment circuits.</span>"
			oldtarget_name = user.name
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		declare_arrests = 0
		icon_state = "[lasercolor]ed209[on]"
		set_weapon()

/obj/machinery/bot/ed209/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if (!Proj.nodamage && Proj.damage < src.health)
				threatlevel = Proj.firer.assess_threat(src)
				threatlevel += 6
				if(threatlevel >= 4)
					target = Proj.firer
					mode = BOT_HUNT
	..()

/obj/machinery/bot/ed209/bot_process()
	if (!..())
		return

	if(disabled)
		return

	var/list/targets = list()
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a target
		var/threatlevel = 0
		if ((C.stat) || (C.lying))
			continue
		threatlevel = C.assess_threat(src, lasercolor)
		//speak(C.real_name + text(": threat: []", threatlevel))
		if (threatlevel < 4 )
			continue

		var/dst = get_dist(src, C)
		if ( dst <= 1 || dst > 7)
			continue

		targets += C
	if (targets.len>0)
		var/mob/living/carbon/t = pick(targets)
		if ((t.stat!=2) && (t.lying != 1) && (!t.handcuffed)) //we don't shoot people who are dead, cuffed or lying down.
			shootAt(t)
	switch(mode)

		if(BOT_IDLE)		// idle
			walk_to(src,0)
			if(!lasercolor) //lasertag bots don't want to arrest anyone
				look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			if (frustration >= 8)
				walk_to(src,0)
				back_to_idle()

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc)) // if right next to perp
					playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
					icon_state = "[lasercolor]ed209-c"
					spawn(2)
						icon_state = "[lasercolor]ed209[on]"
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
					if ((get_dist(src, target)) >= (olddist))
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
			else
				mode = BOT_PREP_ARREST
				anchored = 0

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


	return

/obj/machinery/bot/ed209/proc/back_to_idle()
	anchored = 0
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	spawn(0)
		bot_process() //ensure bot quickly responds

/obj/machinery/bot/ed209/proc/back_to_hunt()
	anchored = 0
	frustration = 0
	mode = BOT_HUNT
	spawn(0)
		bot_process() //ensure bot quickly responds

// look for a criminal in view of the bot

/obj/machinery/bot/ed209/proc/look_for_perp()
	if(disabled)
		return
	anchored = 0
	threatlevel = 0
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if ((C.stat) || (C.handcuffed))
			continue

		if ((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(src, lasercolor)

		if (!threatlevel)
			continue

		else if (threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			playsound(loc, pick('sound/voice/ed209_20sec.ogg', 'sound/voice/EDPlaceholder.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = BOT_HUNT
			spawn(0)
				bot_process()	// ensure bot quickly responds to a perp
			break
		else
			continue

/obj/machinery/bot/ed209/proc/check_for_weapons(var/obj/item/slot_item)
	if(slot_item && slot_item.needs_permit)
		return 1
	return 0

/* terrible
/obj/machinery/bot/ed209/Bumped(atom/movable/M as mob|obj)
	spawn(0)
		if (M)
			var/turf/T = get_turf(src)
			M:loc = T
*/

/obj/machinery/bot/ed209/explode()
	walk_to(src,0)
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/ed209_assembly/Sa = new /obj/item/weapon/ed209_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(!lasercolor)
		var/obj/item/weapon/gun/energy/gun/advtaser/G = new /obj/item/weapon/gun/energy/gun/advtaser(Tsec)
		G.power_supply.charge = 0
		G.update_icon()
	else if(lasercolor == "b")
		var/obj/item/weapon/gun/energy/laser/bluetag/G = new /obj/item/weapon/gun/energy/laser/bluetag(Tsec)
		G.power_supply.charge = 0
		G.update_icon()
	else if(lasercolor == "r")
		var/obj/item/weapon/gun/energy/laser/redtag/G = new /obj/item/weapon/gun/energy/laser/redtag(Tsec)
		G.power_supply.charge = 0
		G.update_icon()

	if (prob(50))
		new /obj/item/robot_parts/l_leg(Tsec)
		if (prob(25))
			new /obj/item/robot_parts/r_leg(Tsec)
	if (prob(25))//50% chance for a helmet OR vest
		if (prob(50))
			new /obj/item/clothing/head/helmet(Tsec)
		else
			if(!lasercolor)
				new /obj/item/clothing/suit/armor/vest(Tsec)
			if(lasercolor == "b")
				new /obj/item/clothing/suit/bluetag(Tsec)
			if(lasercolor == "r")
				new /obj/item/clothing/suit/redtag(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(loc)
	qdel(src)

/obj/machinery/bot/ed209/proc/set_weapon()  //used to update the projectile type and firing sound
	shoot_sound = 'sound/weapons/laser.ogg'
	if(emagged == 2)
		if(lasercolor)
			projectile = /obj/item/projectile/lasertag
		else
			projectile = /obj/item/projectile/beam
	else
		if(!lasercolor)
			shoot_sound = 'sound/weapons/Taser.ogg'
			projectile = /obj/item/projectile/energy/electrode
		else if(lasercolor == "b")
			projectile = /obj/item/projectile/lasertag/bluetag
		else if(lasercolor == "r")
			projectile = /obj/item/projectile/lasertag/redtag

/obj/machinery/bot/ed209/proc/shootAt(mob/target)
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/turf/T = loc
	var/atom/U = (istype(target, /atom/movable) ? target.loc : target)
	if ((!( U ) || !( T )))
		return
	while(!( istype(U, /turf) ))
		U = U.loc
	if (!( istype(T, /turf) ))
		return

	//if(lastfired && world.time - lastfired < 100)

	if(!projectile)
		return

	if (!( istype(U, /turf) ))
		return
	var/obj/item/projectile/A = new projectile (loc)
	playsound(loc, shoot_sound, 50, 1)
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.fire()

/obj/machinery/bot/ed209/attack_alien(mob/living/carbon/alien/user)
	..()
	if (!isalien(target))
		target = user
		mode = BOT_HUNT


/obj/machinery/bot/ed209/emp_act(severity)

	if(severity==2 && prob(70))
		..(severity-1)
	else
		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( loc )
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)
		spawn(10)
			qdel(pulse2)
		var/list/mob/living/carbon/targets = new
		for (var/mob/living/carbon/C in view(12,src))
			if (C.stat==2)
				continue
			targets += C
		if(targets.len)
			if(prob(50))
				var/mob/toshoot = pick(targets)
				if (toshoot)
					targets-=toshoot
					if (prob(50) && emagged < 2)
						emagged = 2
						set_weapon()
						shootAt(toshoot)
						emagged = 0
						set_weapon()
					else
						shootAt(toshoot)
			else if(prob(50))
				if(targets.len)
					var/mob/toarrest = pick(targets)
					if (toarrest)
						target = toarrest
						mode = BOT_HUNT



/obj/item/weapon/ed209_assembly/attackby(obj/item/weapon/W, mob/user, params)
	..()

	if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)	return
		if(!in_range(src, usr) && loc != usr)	return
		created_name = t
		return

	switch(build_step)
		if(0,1)
			if(istype(W, /obj/item/robot_parts/l_leg) || istype(W, /obj/item/robot_parts/r_leg))
				if(!user.unEquip(W))
					return
				qdel(W)
				build_step++
				user << "<span class='notice'>You add the robot leg to [src].</span>"
				name = "legs/frame assembly"
				if(build_step == 1)
					item_state = "ed209_leg"
					icon_state = "ed209_leg"
				else
					item_state = "ed209_legs"
					icon_state = "ed209_legs"

		if(2)
			var/newcolor = ""
			if(istype(W, /obj/item/clothing/suit/redtag))
				newcolor = "r"
			else if(istype(W, /obj/item/clothing/suit/bluetag))
				newcolor = "b"
			if(newcolor || istype(W, /obj/item/clothing/suit/armor/vest))
				if(!user.unEquip(W))
					return
				lasercolor = newcolor
				qdel(W)
				build_step++
				user << "<span class='notice'>You add the armor to [src].</span>"
				name = "vest/legs/frame assembly"
				item_state = "[lasercolor]ed209_shell"
				icon_state = "[lasercolor]ed209_shell"

		if(3)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					build_step++
					name = "shielded frame assembly"
					user << "<span class='notice'>You weld the vest to [src].</span>"
		if(4)
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/clothing/head/helmet/bluetaghelm))
						return

				if("r")
					if(!istype(W, /obj/item/clothing/head/helmet/redtaghelm))
						return

				if("")
					if(!istype(W, /obj/item/clothing/head/helmet))
						return

			if(!user.unEquip(W))
				return
			qdel(W)
			build_step++
			user << "<span class='notice'>You add the helmet to [src].</span>"
			name = "covered and shielded frame assembly"
			item_state = "[lasercolor]ed209_hat"
			icon_state = "[lasercolor]ed209_hat"

		if(5)
			if(isprox(W))
				if(!user.unEquip(W))
					return
				qdel(W)
				build_step++
				user << "<span class='notice'>You add the prox sensor to [src].</span>"
				name = "covered, shielded and sensored frame assembly"
				item_state = "[lasercolor]ed209_prox"
				icon_state = "[lasercolor]ed209_prox"

		if(6)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if (coil.get_amount() < 1)
					user << "<span class='warning'>You need one length of cable to wire the ED-209!</span>"
					return
				user << "<span class='notice'>You start to wire [src]...</span>"
				if (do_after(user, 40, target = src))
					if (coil.get_amount() >= 1 && build_step == 6)
						coil.use(1)
						build_step = 7
						user << "<span class='notice'>You wire the ED-209 assembly.</span>"
						name = "wired ED-209 assembly"

		if(7)
			var/newname = ""
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/weapon/gun/energy/laser/bluetag))
						return
					newname = "bluetag ED-209 assembly"
				if("r")
					if(!istype(W, /obj/item/weapon/gun/energy/laser/redtag))
						return
					newname = "redtag ED-209 assembly"
				if("")
					if(!istype(W, /obj/item/weapon/gun/energy/gun/advtaser))
						return
					newname = "taser ED-209 assembly"
				else
					return
			if(!user.unEquip(W))
				return
			name = newname
			build_step++
			user << "<span class='notice'>You add [W] to [src].</span>"
			item_state = "[lasercolor]ed209_taser"
			icon_state = "[lasercolor]ed209_taser"
			qdel(W)

		if(8)
			if(istype(W, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				var/turf/T = get_turf(user)
				user << "<span class='notice'>You start attaching the gun to the frame...</span>"
				sleep(40)
				if(get_turf(user) == T)
					build_step++
					name = "armed [name]"
					user << "<span class='notice'>Taser gun attached.</span>"

		if(9)
			if(istype(W, /obj/item/weapon/stock_parts/cell))
				if(!user.unEquip(W))
					return
				build_step++
				user << "<span class='notice'>You complete the ED-209.</span>"
				var/turf/T = get_turf(src)
				new /obj/machinery/bot/ed209(T,created_name,lasercolor)
				qdel(W)
				user.unEquip(src, 1)
				qdel(src)


/obj/machinery/bot/ed209/bullet_act(obj/item/projectile/Proj)
	if(!disabled)
		var/lasertag_check = 0
		if((lasercolor == "b"))
			if(istype(Proj, /obj/item/projectile/lasertag/redtag))
				lasertag_check++
		else if((lasercolor == "r"))
			if(istype(Proj, /obj/item/projectile/lasertag/bluetag))
				lasertag_check++
		if(lasertag_check)
			icon_state = "[lasercolor]ed2090"
			disabled = 1
			target = null
			spawn(100)
				disabled = 0
				icon_state = "[lasercolor]ed2091"
			return 1
		else
			..(Proj)
	else
		..(Proj)

/obj/machinery/bot/ed209/bluetag/New()//If desired, you spawn red and bluetag bots easily
	new /obj/machinery/bot/ed209(get_turf(src),null,"b")
	qdel(src)


/obj/machinery/bot/ed209/redtag/New()
	new /obj/machinery/bot/ed209(get_turf(src),null,"r")
	qdel(src)
