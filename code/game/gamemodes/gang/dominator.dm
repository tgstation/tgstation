/obj/machinery/dominator
	name = "dominator"
	desc = "A visibly sinister device. Looks like you can break it if you hit it enough."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = 1
	anchored = 1.0
	layer = 3.6
	var/maxhealth = 200
	var/health = 200
	var/datum/gang/gang
	var/operating = 0	//-1=broken, 0=standby, 1=takeover
	var/warned = 0	//if this device has set off the warning at <3 minutes yet

/obj/machinery/dominator/New()
	..()
	SetLuminosity(2)

/obj/machinery/dominator/examine(mob/user)
	..()
	if(operating == -1)
		user << "<span class='danger'>It looks completely busted.</span>"
		return

	var/time
	if(gang && isnum(gang.dom_timer))
		time = max(gang.dom_timer, 0)
		if(time > 0)
			user << "<span class='notice'>Hostile Takeover in progress. Estimated [time] seconds remain.</span>"
		else
			user << "<span class='notice'>Hostile Takeover of [station_name()] successful. Have a great day.</span>"
	else
		user << "<span class='notice'>System on standby.</span>"
	user << "<span class='danger'>System Integrity: [round((health/maxhealth)*100,1)]%</span>"

/obj/machinery/dominator/process()
	..()
	if(gang && isnum(gang.dom_timer))
		if(gang.dom_timer > 0)
			playsound(loc, 'sound/items/timer.ogg', 30, 0)
			if(!warned && (gang.dom_timer < 180))
				warned = 1
				var/area/domloc = get_area(loc)
				gang.message_gangtools("Less than 3 minutes remain in hostile takeover. Defend your dominator at [initial(domloc.name)]!")
				for(var/datum/gang/G in ticker.mode.gangs)
					if(G != gang)
						G.message_gangtools("WARNING: [gang.name] Gang takeover imminent. Their dominator at [initial(domloc.name)] must be destroyed!",1,1)
		else
			SSmachine.processing -= src

/obj/machinery/dominator/proc/healthcheck(var/damage)
	var/iconname = "dominator"
	if(gang)
		iconname += "-[gang.color]"
		SetLuminosity(3)

	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread

	health -= damage

	if(health > (maxhealth/2))
		if(prob(damage*2))
			sparks.set_up(5, 1, src)
			sparks.start()
	else if(operating >= 0)
		sparks.set_up(5, 1, src)
		sparks.start()
		overlays += "damage"

	if(operating != -1)
		if(health <= 0)
			set_broken()
		else
			icon_state = iconname

	if(health <= -100)
		new /obj/item/stack/sheet/plasteel(src.loc)
		qdel(src)

/obj/machinery/dominator/proc/set_broken()
	if(gang)
		gang.dom_timer = "OFFLINE"

		var/takeover_in_progress = 0
		for(var/datum/gang/G in ticker.mode.gangs)
			if(isnum(G.dom_timer))
				takeover_in_progress = 1
				break
		if(!takeover_in_progress)
			SSshuttle.emergencyNoEscape = 0
			if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
				SSshuttle.emergency.mode = SHUTTLE_DOCKED
				SSshuttle.emergency.timer = world.time
				priority_announce("Hostile enviroment resolved. You have 3 minutes to board the Emergency Shuttle.", null, 'sound/AI/shuttledock.ogg', "Priority")
			else
				priority_announce("All hostile activity within station systems have ceased.","Network Alert")

			if(get_security_level() == "delta")
				set_security_level("red")

		gang.message_gangtools("Hostile takeover cancelled: Dominator is no longer operational.[gang.dom_attempts ? " You have [gang.dom_attempts] attempt remaining." : " The station network will have likely blocked any more attempts by us."]",1,1)

	SetLuminosity(0)
	icon_state = "dominator-broken"
	overlays.Cut()
	operating = -1
	SSmachine.processing -= src

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

	var/datum/gang/tempgang

	if(user.mind in ticker.mode.get_all_gangsters())
		tempgang = user.mind.gang_datum
	else
		examine(user)
		return

	if(isnum(tempgang.dom_timer))
		user << "<span class='warning'>Error: Hostile Takeover is already in progress.</span>"
		return

	if(!tempgang.dom_attempts)
		user << "<span class='warning'>Error: Unable to breach station network. Firewall has logged our signature and is blocking all further attempts.</span>"
		return

	var/time = max(300,900 - ((round((tempgang.territory.len/start_state.num_territories)*200, 1) - 60) * 15))
	if(alert(user,"With [round((tempgang.territory.len/start_state.num_territories)*100, 1)]% station control, a takeover will require [time] seconds.\nYour gang will be unable to gain influence while it is active.\nThe entire station will likely be alerted to it once it starts.\nYou have [tempgang.dom_attempts] attempt(s) remaining. Are you ready?","Confirm","Ready","Later") == "Ready")
		if (!tempgang.dom_attempts || !in_range(src, user) || !istype(src.loc, /turf))
			return 0

		gang = tempgang
		gang.dom_attempts --
		gang.domination()
		src.name = "[gang.name] Gang [src.name]"
		healthcheck(0)
		operating = 1
		SSmachine.processing += src
		var/area/A = get_area(loc)
		var/locname = initial(A.name)
		priority_announce("Network breach detected in [locname]. The [gang.name] Gang is attempting to seize control of the station!","Network Alert")
		gang.message_gangtools("Hostile takeover in progress: Estimated [time] seconds until victory.[gang.dom_attempts ? "" : " This is your final attempt."]")
		for(var/datum/gang/G in ticker.mode.gangs)
			if(G != gang)
				G.message_gangtools("Enemy takeover attempt detected in [locname]: Estimated [time] seconds until our defeat.",1,1)

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
