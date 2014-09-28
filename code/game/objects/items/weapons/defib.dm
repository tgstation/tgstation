
//**************************************************************
// Defibrillator
//**************************************************************

/obj/item/weapon/melee/defibrillator
	name = "emergency defibrillator"
	desc = "Used to restore fibrilating patients, and somehow bring them back from the dead too."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "defib_full"
	item_state = "defib"
	w_class = 3
	force = 5
	throwforce = 5
	origin_tech = "biotech=3"

	var/datum/effect/effect/system/spark_spread/sparks = new
	var/charges = 10
	var/ready = 0
	var/nextShock
	var/emagged = 0
	var/revivedelay = 50 //I hope those are ticks

/obj/item/weapon/melee/defibrillator/New()
	src.sparks.set_up(5,0,src)
	src.sparks.attach(src)
	return ..()

/obj/item/weapon/melee/defibrillator/suicide_act(mob/user)
	viewers(user) << "<span class='warning'>[user] is putting the live paddles on \his chest! It looks like \he's trying to commit suicide.</span>"
	playsound(get_turf(src),'sound/items/defib.ogg',50,1)
	return (FIRELOSS)

/obj/item/weapon/melee/defibrillator/update_icon()
	src.icon_state = "defib"
	if(src.charges)
		if(src.ready)	src.icon_state += "paddleout"
		else			src.icon_state += "paddlein"
		switch(src.charges)
			if(7 to INFINITY)	src.icon_state += "_full"
			if(4 to 6)			src.icon_state += "_half"
			else				src.icon_state += "_low"
	else src.icon_state += "empty"
	return

/obj/item/weapon/melee/defibrillator/attack_self(mob/user)
	if(src.charges)
		if((M_CLUMSY in user.mutations) && prob(50))
			user << "<span class='warning'>You touch the paddles together, shorting the device.</span>"
			src.sparks.start()
			playsound(get_turf(src),"sparks",75,1,-1)
			user.Weaken(5)
			var/mob/living/carbon/human/H = user
			if(ishuman(user)) H.apply_damage(20, BURN)
			src.charges--
			src.update_icon()
		else
			src.ready = !src.ready
			user << "<span class='notice'>You turn [src] [ready? "on and take the paddles out" : "off and put the paddles back in"].</span>"
			playsound(get_turf(src),"sparks",75,1,-1)
			src.update_icon()
	else user << "<span class='warning'>[src] is out of charges.</span>"
	add_fingerprint(user)
	return

/obj/item/weapon/melee/defibrillator/attackby(obj/item/weapon/W,mob/user)
	if(istype(W,/obj/item/weapon/card/emag))
		src.emagged = !src.emagged
		if(src.emagged)
			user << "<span class='warning'>You short out [src]'s safety protocols.</span>"
			src.overlays += "defib_emag"
		else
			user << "<span class='notice'>You reset [src]'s safety protocols.</span>"
			src.overlays.Cut()
	else . = ..()
	return

/obj/item/weapon/melee/defibrillator/attack(mob/M,mob/user)
	if(!ishuman(M)) user << "<span class='warning'>You can't defibrilate [M]. You don't even know where to put the paddles!</span>"
	else if(!src.charges) user << "<span class='warning'>[src] is out of charges.</span>"
	else if(!src.ready) user << "<span class='notice'>Take the paddles out first.</span>"
	else if(world.time < src.nextShock) user << "<span class='warning'>[src] is still charging back up.</span>"
	else
		var/mob/living/carbon/human/target = M
		if(!(target.stat == 2 || target.stat == DEAD))
			if(src.emagged) src.shockAttack(target,user)
			else user << "<span class='notice'>[src] buzzes: Cardiac rhythm normal.</span>"
		else src.attemptDefib(target,user)
	return

/obj/item/weapon/melee/defibrillator/proc/shockAttack(mob/living/carbon/human/target,mob/user)
	var/datum/organ/internal/heart/heart = target.internal_organs["heart"]
	target.visible_message("<span class='danger'>[target.name] has been shocked in the chest with the [src] by [user]!</span>")
	target.Weaken(rand(6,12))
	target.apply_damage(rand(30,60),BURN,"chest")
	heart.damage += rand(5,60)
	target.emote("scream") //If we're going this route, it kinda hurts
	target.updatehealth()
	spawn() //Logging
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Shocked [target.name] ([target.ckey]) with an emagged [src.name]</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Shocked by [user.name] ([user.ckey]) with an emagged [src.name]</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) shocked [target.name] ([target.ckey]) with an emagged [src.name]</font>" )
		if(!iscarbon(user)) target.LAssailant = null
		else target.LAssailant = user
	src.sparks.start()
	playsound(get_turf(src),'sound/items/defib.ogg',50,1)
	src.charges--
	src.update_icon()
	src.nextShock = world.timeofday + revivedelay*0.2
	return

/obj/item/weapon/melee/defibrillator/proc/attemptDefib(mob/living/carbon/human/target,mob/user)
	user.visible_message("[user] starts setting up the paddles on [target]'s chest","You start setting up the paddles on [target]'s chest")
	if(do_after(user,30))
		src.sparks.start()
		playsound(get_turf(src),'sound/items/defib.ogg',50,1)
		src.charges--
		src.update_icon()
		user << "<span class='notice'>You shock [target] with the paddles.</span>"
		if(target.mind && !target.client)
			for(var/mob/dead/observer/ghost in player_list)
				if(ghost.mind == target.mind && ghost.can_reenter_corpse)
					ghost << 'sound/effects/adminhelp.ogg'
					ghost << "<span class='danger'>Someone is trying to revive your body. Return to it if you want to be resurrected!</span>"
					user << "<span class='warning'>[src] buzzes: Defibrillation failed. Vital signs too weak, please try again.</span>"
					break
		if(!target.client || !target.mind) //Let's call up the ghost and then still revive the corspe ! Also, bodies with clients only, thank you
			user << "<span class='warning'>[src] buzzes: Defibrillation failed. Patient shows no vital signs.</span>"
			return
		if(target.wear_suit && istype(target.wear_suit,/obj/item/clothing/suit/armor) && prob(95)) //75 ? Let's stay realistic here
			user << "<span class='warning'>[src] buzzes: Defibrillation failed. Please apply on bare skin.</span>"
		else if(target.w_uniform && istype(target.w_uniform,/obj/item/clothing/under && prob(50)))
			user << "<span class='warning'>[src] buzzes: Defibrillation failed. Please apply on bare skin.</span>"
		else
			var/datum/organ/internal/heart/heart = target.internal_organs["heart"]
			if(prob(25)) heart.damage += 5 //Allow the defibrilator to possibly worsen heart damage. Still rare enough to just be the "clone damage" of the defib
			target.apply_damage(-target.getOxyLoss(),OXY)
			target.updatehealth()
			target.visible_message("<span class='warning'>[target]'s body convulses a bit.</span>")
			var/datum/organ/external/head/head = target.get_organ("head")
			if((target.health > config.health_threshold_dead)\
			&&(!(head.status & ORGAN_DESTROYED))\
			&&(!(M_NOCLONE in target.mutations))\
			&&(target.has_brain()))
				target.visible_message("<span class='notice'>[src] beeps: Defibrillation successful.</span>")
				dead_mob_list -= target
				living_mob_list += target
				target.tod = null
				target.stat = CONSCIOUS
				target.regenerate_icons()
				//target.update_canmove()
				flick("e_flash",target.flash)
				target.apply_effect(10, EYE_BLUR) //I'll still put this back in to avoid dumd "pounce back up" behavior
				target.apply_effect(10, PARALYZE)
				target.update_canmove()
				target << "<span class='notice'>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane.</span>"
			else
				target.visible_message("<span class='notice'>[src] buzzes: Defibrillation failed. Patient's condition does not allow reviving.</span>")
		target.apply_damage(rand(1,5),BURN,"chest") //Better not try too much times
		src.nextShock = world.timeofday + revivedelay
		return
