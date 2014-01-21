/obj/item/weapon/melee/defibrilator
	name = "emergency defibrilator"
	desc = "A handheld emergency defibrilator, used to bring people back from the brink of death or put them there."
	icon_state = "defib_full"
	item_state = "defib"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 5
	w_class = 3
	var/emagged = 0
	var/charges = 10
	var/status = 0
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
	origin_tech = "biotech=3"

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the live paddles on \his chest! It looks like \he's trying to commit suicide.</b>"
		return (OXYLOSS)

/obj/item/weapon/melee/defibrilator/update_icon()
	if(!status)
		if(charges >= 7)
			icon_state = "defib_full"
		if(charges <= 6 && charges >= 4)
			icon_state = "defib_half"
		if(charges <= 3 && charges >= 1)
			icon_state = "defib_low"
		if(charges <= 0)
			icon_state = "defib_empty"
	else
		if(charges >= 7)
			icon_state = "defibpaddleout_full"
		if(charges <= 6 && charges >= 4)
			icon_state = "defibpaddleout_half"
		if(charges <= 3 && charges >= 1)
			icon_state = "defibpaddleout_low"

/obj/item/weapon/melee/defibrilator/attack_self(mob/user as mob)
	if(status && (M_CLUMSY in user.mutations) && prob(50))
		spark_system.attach(user)
		spark_system.set_up(5, 0, src)
		spark_system.start()
		user << "\red You touch the paddles together shorting the device."
		user.Weaken(5)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return
	if(charges > 0)
		status = !status
		user << "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>"
		playsound(get_turf(src), "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		user << "<span class='warning'>\The [src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/melee/defibrilator/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/card/emag))
		var/image/I = image("icon" = "icons/obj/weapons.dmi", "icon_state" = "defib_emag")
		if(emagged == 0)
			emagged = 1
			usr << "\red [W] unlocks [src]'s safety protocols"
			overlays += I
		else
			emagged = 0
			usr << "\blue [W] sets [src]'s safety protocols"
			overlays -= I

/obj/item/weapon/melee/defibrilator/attack(mob/M as mob, mob/user as mob)
	var/tobehealed
	var/threshhold = -config.health_threshold_dead
	var/mob/living/carbon/human/H = M
	if(!ishuman(M))
		..()
		return
	if(status)
		if(user.a_intent == "hurt" && emagged)
			H.visible_message("<span class='danger'>[M.name] has been touched by the defibrilator paddles by [user]!</span>")
			if(charges >= 2)
				H.Weaken(10)
				H.adjustOxyLoss(10)
			else
				H.Weaken(5)
				H.adjustOxyLoss(5)
			H.updatehealth() //forces health update before next life tick
			spark_system.attach(M)
			spark_system.set_up(5, 0, M)
			spark_system.start()
			charges -= 2
			if(charges < 0)
				charges = 0
			if(!charges)
				status = 0
			update_icon()
			playsound(get_turf(src), 'sound/weapons/Egloves.ogg', 50, 1, -1)
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Defibrilated [H.name] ([H.ckey]) with [src.name]</font>"
			H.attack_log += "\[[time_stamp()]\]<font color='orange'> Defibrilated by [user.name] ([user.ckey]) with [src.name]</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) defibrilated [H.name] ([H.ckey]) with [src.name]</font>" )
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user
			return
		H.visible_message("\blue [user] places the defibrilator paddles on [M.name]'s chest.", "\blue You place the defibrilator paddles on [M.name]'s chest.")
		if(do_after(user, 10))
			if(H.stat == 2 || H.stat == DEAD)
				var/uni = 0
				var/armor = 0
				var/health = H.health
				for(var/obj/item/carried_item in H.contents)
					if(istype(carried_item, /obj/item/clothing/under))
						uni = 1
					if(istype(carried_item, /obj/item/clothing/suit/armor))
						armor = 1
				if(uni && armor)
					if(prob(30))
						spark_system.attach(M)
						spark_system.start()
					if(prob(30))
						tobehealed = health + threshhold
						tobehealed -= 5 //They get 5 health in crit to heal the person or inject stabalizers
						H.adjustOxyLoss(tobehealed)
				else if(uni || armor)
					if(prob(30))
						spark_system.attach(M)
						spark_system.start()
					if(prob(60))
						tobehealed = health + threshhold
						tobehealed -= 5 //They get 5 health in crit to heal the person or inject stabalizers
						H.adjustOxyLoss(tobehealed)
				else
					if(prob(90))
						tobehealed = health + threshhold
						tobehealed -= 5 //They get 5 health in crit to heal the person or inject stabalizers
						H.adjustOxyLoss(tobehealed)
				H.updatehealth() //forces a health update, otherwise the oxyloss adjustment wouldnt do anything
				M.visible_message("\red [M]'s body convulses a bit.")
				var/datum/organ/external/temp = H.get_organ("head")
				if(H.health > -100 && !(temp.status & ORGAN_DESTROYED) && !(M_NOCLONE in H.mutations) && !H.suiciding)
					viewers(M) << "\blue [src] beeps: Resuscitation successful."
					spawn(0)
						H.stat = 1
						dead_mob_list -= H
						living_mob_list |= H
						H.emote("gasp")
				else
					viewers(M) << "\blue [src] beeps: Resuscitation failed."
				charges--
				if(charges < 1)
					charges = 0
					status = 0
				update_icon()
			else
				user.visible_message("\blue [src] beeps: Patient is not in a valid state.")
