/mob/living/simple_animal/bot/honkbot
	name = "\improper Honkbot"
	desc = "A little robot. It looks happy with its bike horn."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "honkbot0"
	density = FALSE
	anchored = FALSE
	health = 20
	maxHealth = 20
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB

	radio_key = /obj/item/device/encryptionkey/headset_service //doesn't have security key
	radio_channel = "Service" //Service
	bot_type = SEC_BOT
	model = "Honkbot"
	bot_core_type = /obj/machinery/bot_core/honkbot
	window_id = "autosec"
	window_name = "Honkomatic Bike Horn Unit v1.0"
	allow_pai = 1 //Damn right we'll pAI these
	data_hud_type = DATA_HUD_SECURITY_ADVANCED // show jobs

	var/honksound = 'sound/items/bikehorn.ogg' //customizable
	var/spam_flag = 0
	var/cooldowntime = 30
	var/cooldowntimehorn = 10
	var/cooldowntimeEmag = 5
	var/mob/living/carbon/target
	var/oldtarget_name
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/threatlevel
	var/declare_arrests = 0 // speak, you shall not, unless to Honk
	var/idcheck = 1 //Chases unknowns
	var/fcheck = 1 //And armed people
	var/check_records = 1 //Doesn't care about criminals
	var/arrest_type = 0
	var/weaponscheck = 1

/mob/living/simple_animal/bot/honkbot/New()
	..()
	icon_state = "honkbot[on]"
	auto_patrol = 1
	spawn(3)
		var/datum/job/clown/J = new/datum/job/clown
		access_card.access += J.get_access()
		prev_access = access_card.access

/mob/living/simple_animal/bot/honkbot/turn_on()
	..()
	icon_state = "honkbot[on]"

/mob/living/simple_animal/bot/honkbot/turn_off()
	..()
	icon_state = "honkbot[on]"

/mob/living/simple_animal/bot/honkbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = 0
	walk_to(src,0)
	last_found = world.time

/mob/living/simple_animal/bot/honkbot/set_custom_texts()

	text_hack = "You overload [name]'s sound control system"
	text_dehack = "You reboot [name] and restore the sound control system."
	text_dehack_fail = "[name] refuses to accept your authority!"

/mob/living/simple_animal/bot/honkbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>Honkomatic Bike Horn Unit v1.0 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},

"<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += text({"<BR> Auto Patrol: []"},

"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )
	return	dat


/mob/living/simple_animal/bot/honkbot/Topic(href, href_list)
	if(..())
		return 1

/mob/living/simple_animal/bot/honkbot/proc/retaliate(mob/living/carbon/human/H)
	threatlevel = H.assess_threat(src)
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		mode = BOT_HUNT

/mob/living/simple_animal/bot/honkbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == "harm")
		retaliate(H)
		spawn(5)
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 1, -1)
	return ..()


/mob/living/simple_animal/bot/honkbot/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weldingtool) && user.a_intent != INTENT_HARM).
		return
	if(!istype(W, /obj/item/screwdriver) && (W.force) && (!target) && (W.damtype != STAMINA) ) // Check for welding tool to fix #2432.
		retaliate(user)
		spawn(5)
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 1, -1)

/mob/living/simple_animal/bot/honkbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			user << "<span class='danger'>You short out [src]'s sound control system.</span>"
			oldtarget_name = user.name
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 1, -1)
		icon_state = "honkbot[on]"

/mob/living/simple_animal/bot/honkbot/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health)
				retaliate(Proj.firer)
	..()


/mob/living/simple_animal/bot/honkbot/UnarmedAttack(atom/A)
	if(!on)
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if (!emagged)
			honk_attack(A)
		else
			if(!C.IsStun() || arrest_type)
				stun_attack(A)
		..()
	else if (!spam_flag) //honking at the ground
		bike_horn(A)


/mob/living/simple_animal/bot/honkbot/hitby(atom/movable/AM, skipcatch = 0, hitpush = 1, blocked = 0)
	if(istype(AM, /obj/item))
		playsound(loc, honksound, 50, 1, -1)
		var/obj/item/I = AM
		if(I.throwforce < src.health && I.thrownby && (istype(I.thrownby, /mob/living/carbon/human)))
			var/mob/living/carbon/human/H = I.thrownby
			retaliate(H)
	..()

/mob/living/simple_animal/bot/honkbot/proc/bike_horn() //use bike_horn
	if (!emagged)
		if(ckey == null) //check if a player is controlling
			playsound(loc, honksound, 50, 1, -1)
		else
			if (!spam_flag)
				playsound(loc, honksound, 50, 1, -1)
				spam_flag = 1 //prevent spam
		icon_state = "honkbot-c"
		spawn(5)
			icon_state = "honkbot[on]"
		spawn(cooldowntimehorn)
			spam_flag = 0

	else //emagged honkbots will spam short and memorable sounds.

		if (ckey == null)
			playsound(loc, pick('sound/items/bikehorn.ogg', 'sound/items/AirHorn2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/items/AirHorn.ogg', 'sound/effects/reee.ogg', 'sound/effects/adminhelp.ogg', 'sound/items/WEEOO1.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bcreep.ogg','sound/magic/Fireball.ogg' ,'sound/effects/pray.ogg', 'sound/voice/hiss1.ogg','sound/machines/buzz-sigh.ogg', 'sound/machines/ping.ogg', 'sound/weapons/flashbang.ogg', 'sound/weapons/bladeslice.ogg'), 50, 0)
			// to be put at 100 volume: (Weeoo1, bcreep, blaw, hiss, flashbang )
		else
			if (!spam_flag)
				playsound(loc, pick('sound/items/bikehorn.ogg', 'sound/items/AirHorn2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/items/AirHorn.ogg', 'sound/effects/reee.ogg', 'sound/effects/adminhelp.ogg', 'sound/items/WEEOO1.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bcreep.ogg','sound/magic/Fireball.ogg' ,'sound/effects/pray.ogg', 'sound/voice/hiss1.ogg','sound/machines/buzz-sigh.ogg', 'sound/machines/ping.ogg', 'sound/weapons/flashbang.ogg', 'sound/weapons/bladeslice.ogg'), 50, 0)
				spam_flag = 1 // prevent spam
		icon_state = "honkbot-e"
		spawn(30) // keep flashing
			icon_state = "honkbot[on]"
		spawn(cooldowntimehorn)
			spam_flag = 0

/mob/living/simple_animal/bot/honkbot/proc/honk_attack(mob/living/carbon/C) // horn attack
	if (ckey == null) //check if a player is controlling
		playsound(loc, honksound, 50, 1, -1)
	else
		playsound(loc, honksound, 50, 1, -1)
		spam_flag = 1 // prevent spam
	icon_state = "honkbot-c"
	spawn(5)
		icon_state = "honkbot[on]"
	spawn(cooldowntimehorn)
		spam_flag = 0

/mob/living/simple_animal/bot/honkbot/proc/stun_attack(mob/living/carbon/C) // airhorn stun
	playsound(loc, 'sound/items/AirHorn.ogg', 100, 1, -1) //HOOOOOOOOOOOOONK!!
	icon_state = "honkbot-c"
	spawn(5)
		icon_state = "honkbot[on]"

	if(ishuman(C))
		C.stuttering = 20
		C.Jitter(50)
		C.Knockdown(80)
		var/mob/living/carbon/human/H = C

		if (!emagged) //HONK once, then leave
			threatlevel = H.assess_threat(src)
			threatlevel -= 6
			//target = old_target
		else // you really don't want to hit an emagged honkbot
			threatlevel = H.assess_threat(src)
			threatlevel = 6 // will never let you go
	else
		C.stuttering = 20
		C.Knockdown(80)

	add_logs(src,C,"honked")
	spawn(cooldowntime)
		spam_flag = 0
	C.visible_message("<span class='danger'>[src] has honked [C]!</span>",\
					"<span class='userdanger'>[src] has honked you!</span>")

/mob/living/simple_animal/bot/honkbot/handle_automated_action()
	if(!..())
		return

	switch(mode)

		if(BOT_IDLE)		// idle

			walk_to(src,0)
			look_for_perp()
			if(!mode && auto_patrol)
				mode = BOT_START_PATROL

		if(BOT_HUNT)

			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				walk_to(src,0)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc))

					if(threatlevel <= 4)
						honk_attack(target)
					else
						if(threatlevel >= 6)
							spawn(0)
								stun_attack(target)
								anchored = 0
								target_lastloc = target.loc
					return

				else	// not next to perp
					var/turf/olddist = get_dist(src, target)
					walk_to(src, target,1,4)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()


		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


	return

/mob/living/simple_animal/bot/honkbot/proc/back_to_idle()
	anchored = 0
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	spawn(0)
		handle_automated_action() //ensure bot quickly responds

/mob/living/simple_animal/bot/honkbot/proc/back_to_hunt()
	anchored = 0
	frustration = 0
	mode = BOT_HUNT
	spawn(0)
		handle_automated_action() //ensure bot quickly responds


/mob/living/simple_animal/bot/honkbot/proc/look_for_perp()
	anchored = 0
	for (var/mob/living/carbon/C in view(7,src))
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(src)

		//if(!threatlevel)
			//continue

		if(threatlevel <= 3)
			if(C in view(4,src)) //keep the range short for patrolling
				if(!spam_flag)
					spam_flag = 1
					bike_horn()
					spawn(cooldowntime)
						spam_flag = 0

		else if(threatlevel >= 10)
			bike_horn() //just spam the shit outta this

		else if(threatlevel >= 4)
			if(!spam_flag)
				target = C
				oldtarget_name = C.name
				bike_horn()
				speak("Honk!")
				visible_message("<b>[src]</b> starts chasing [C.name]!")
				mode = BOT_HUNT
				spawn(0)
					handle_automated_action()	// ensure bot quickly responds to a perp
				break
			else
				continue

/mob/living/simple_animal/bot/honkbot/explode()

	walk_to(src,0)
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/honkbot_assembly/Sa = new /obj/item/honkbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.created_name = name

	new /obj/item/bikehorn(Tsec)
	new /obj/item/device/assembly/prox_sensor(Tsec)
	if(prob(50))
		new /obj/item/bodypart/l_arm/robot(Tsec)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(loc)
	..()

/mob/living/simple_animal/bot/honkbot/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT

/mob/living/simple_animal/bot/honkbot/Crossed(atom/movable/AM)
	if(ismob(AM))
		if(prob(30)) //you're far more likely to trip on a honkbot
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
			C.Knockdown(10)
			playsound(loc, 'sound/misc/sadtrombone.ogg', 50, 1, -1)
			speak("Honk!")
			icon_state = "honkbot-c"
			spawn(5)
				icon_state = "honkbot[on]"
			return
	..()

/obj/machinery/bot_core/honkbot
	req_access = list(ACCESS_THEATRE)