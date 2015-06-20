/obj/machinery/dominator
	name = "dominator"
	desc = "A visibly sinister device. Looks like you can break it if you hit it enough."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = 1
	anchored = 1.0
	layer = 3.6
	var/maxhealth = 300
	var/health = 300
	var/gang
	var/operating = 0

/obj/machinery/dominator/New()
	if(!istype(ticker.mode, /datum/game_mode/gang))
		qdel(src)
		return
	SetLuminosity(2)

/obj/machinery/dominator/examine(mob/user)
	..()
	if(operating == -1)
		user << "<span class='danger'>It looks completely busted.</span>"
		return

	var/datum/game_mode/gang/mode = ticker.mode
	var/time = null
	if(gang == "A")
		if(isnum(mode.A_timer))
			time = max(mode.A_timer, 0)
	if(gang == "B")
		if(isnum(mode.B_timer))
			time = max(mode.B_timer, 0)
	if(isnum(time))
		if(time > 0)
			user << "<span class='notice'>Hostile Takeover in progress. Estimated [time] seconds remain.</span>"
		else
			user << "<span class='notice'>Hostile Takeover of [station_name()] successful. Have a great day.</span>"
	else
		user << "<span class='notice'>System on standby.</span>"
	user << "<span class='danger'>System Integrity: [round((health/maxhealth)*100,1)]%</span>"


/obj/machinery/dominator/proc/healthcheck(var/damage)
	var/iconname = "dominator"
	if(gang)
		iconname += "-[gang]"
		SetLuminosity(3)

	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread

	health -= damage

	if(health > (maxhealth/2))
		if(prob(damage*2))
			sparks.set_up(5, 1, src)
			sparks.start()
	else
		sparks.set_up(5, 1, src)
		sparks.start()
		iconname += "-damaged"

	if(operating != -1)
		if(health <= 0)
			set_broken()
		else
			icon_state = iconname

	if(health <= -100)
		new /obj/item/stack/sheet/plasteel(src.loc)
		qdel(src)

/obj/machinery/dominator/proc/set_broken()
	var/datum/game_mode/gang/mode = ticker.mode
	if(gang == "A")
		mode.A_timer = "OFFLINE"
	if(gang == "B")
		mode.B_timer = "OFFLINE"
	if(gang)
		if(!isnum(mode.A_timer) && !isnum(mode.B_timer))
			SSshuttle.emergencyNoEscape = 0
			if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
				SSshuttle.emergency.mode = SHUTTLE_DOCKED
				SSshuttle.emergency.timer = world.time
				priority_announce("Hostile enviroment resolved. You have 3 minutes to board the Emergency Shuttle.", null, 'sound/AI/shuttledock.ogg', "Priority")
			else
				priority_announce("All hostile activity within station systems have ceased.","Network Alert")

			if(get_security_level() == "delta")
				set_security_level("red")

			for(var/obj/item/weapon/pinpointer/pointer in world)
				pointer.scandisk() //Reset the pinpointer

		else if(isnum(mode.A_timer) || isnum(mode.B_timer))
			for(var/obj/machinery/dominator/dom in world)
				if(dom.operating)
					for(var/obj/item/weapon/pinpointer/pointer in world)
						pointer.the_disk = dom //The pinpointer now tracks the dominator's location
					break

		ticker.mode.message_gangtools(((gang=="A") ? ticker.mode.A_tools : ticker.mode.B_tools),"Hostile takeover cancelled: Dominator is no longer operational.",1,1)

	SetLuminosity(0)
	icon_state = "dominator-broken"
	operating = -1

/obj/machinery/dominator/Destroy()
	if(operating != -1)
		set_broken()
	..()

/obj/machinery/dominator/emp_act(severity)
	healthcheck(100)
	..()

/obj/machinery/dominator/ex_act(severity, target)
	if(target == src)
		qdel(src)
		return
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			healthcheck(120)
		if(3.0)
			healthcheck(30)
	return

/obj/machinery/dominator/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			var/damage = Proj.damage
			if(Proj.forcedodge)
				damage *= 0.5
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
			visible_message("<span class='danger'>[src] was hit by [Proj].</span>")
			healthcheck(damage)
	..()

/obj/machinery/dominator/blob_act()
	healthcheck(110)

/obj/machinery/dominator/attackby(I as obj, user as mob, params)

	return

/obj/machinery/dominator/attack_hand(mob/user)
	if(operating)
		examine(user)
		return

	var/datum/game_mode/gang/mode = ticker.mode
	var/gang_territory
	var/timer

	var/tempgang
	if(user.mind in (ticker.mode.A_gang|ticker.mode.A_bosses))
		tempgang = "A"
		gang_territory = ticker.mode.A_territory.len
		timer = mode.A_timer
	else if(user.mind in (ticker.mode.B_gang|ticker.mode.B_bosses))
		tempgang = "B"
		gang_territory = ticker.mode.B_territory.len
		timer = mode.B_timer

	if(!tempgang)
		examine(user)
		return

	if(isnum(timer)) //In theory, this shouldn't happen. But if it does, they get this meme
		user << "<span class='warning'>Error: Hostile Takeover is already in progress.</span>"
		return

	var/time = max(300,900 - ((round((gang_territory/start_state.num_territories)*200, 1) - 60) * 15))
	if(alert(user,"With [round((gang_territory/start_state.num_territories)*100, 1)]% station control, a takeover will require [time] seconds.\nYour gang will be unable to gain influence while it is active.\nThe entire station will likely be alerted to it once it starts.\nAre you ready?","Confirm","Ready","Later") == "Ready")
		if ((!in_range(src, user) || !istype(src.loc, /turf)))
			return 0
		gang = tempgang
		mode.domination(gang,1,src)
		src.name = "[gang_name(gang)] Gang [src.name]"
		healthcheck(0)
		operating = 1
		ticker.mode.message_gangtools(((gang=="A") ? ticker.mode.A_tools : ticker.mode.B_tools),"Hostile takeover in progress: Estimated [time] seconds until victory.")

/obj/machinery/dominator/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	user.visible_message("<span class='danger'>[user] smashes against [src] with its claws.</span>",\
	"<span class='danger'>You smash against [src] with your claws.</span>",\
	"<span class='italics'>You hear metal scraping.</span>")
	healthcheck(15)

/obj/machinery/dominator/attack_animal(mob/living/user as mob)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	M.do_attack_animation(src)
	if(M.melee_damage_upper <= 0)
		return
	healthcheck(M.melee_damage_upper)

/obj/machinery/dominator/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		healthcheck(M.force)
	return

/obj/machinery/dominator/attack_hulk(mob/user)
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	user.visible_message("<span class='danger'>[user] smashes [src].</span>",\
	"<span class='danger'>You punch [src].</span>",\
	"<span class='italics'>You hear metal being slammed.</span>")
	healthcheck(5)

/obj/machinery/dominator/attackby(obj/item/weapon/I as obj, mob/living/user as mob, params)
	if(istype(I, /obj/item/weapon))
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if( (I.flags&NOBLUDGEON) || !I.force )
			return
		playsound(src, 'sound/weapons/smash.ogg', 50, 1)
		visible_message("<span class='danger'>[user] has hit \the [src] with [I].</span>")
		if(I.damtype == BURN || I.damtype == BRUTE)
			healthcheck(I.force)
		return
