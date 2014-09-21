
//**************************************************************
// Defibrillator
//**************************************************************

/obj/item/weapon/melee/defibrillator
	name = "defibrillator"
	desc = "Use this to shock someone's heart back to normal cardiac rythm."
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
			if(ishuman(user)) H.apply_damage(10, BURN)
			src.charges--
			src.update_icon()
		else
			src.ready = !src.ready
			user << "<span class='notice'>You turn on [src] and take the paddles out.</span>"
			user << "You turn off [src] and put the paddles back in."
			playsound(get_turf(src),"sparks",75,1,-1)
			src.update_icon()
	else user << "<span class='warning'>[src] is out of charge.</span>"
	add_fingerprint(user)
	return

/obj/item/weapon/melee/defibrillator/attackby(obj/item/weapon/W,mob/user)
	if(istype(W,/obj/item/weapon/card/emag))
		src.emagged = !src.emagged
		if(src.emagged)
			user << "<span class='warning'>You short out [src]'s safety protocols using [W].</span>"
			src.overlays += "defib_emag"
		else
			user << "<span class='notice'>You reset [src]'s safety protocols using [W].</span>"
			src.overlays.Cut()
	else . = ..()
	return

/obj/item/weapon/melee/defibrillator/attack(mob/M,mob/user)
	if(!ishuman(M)) user << "You can't defibrillate that. You're not even sure it has a heart!."
	else if(!src.charges) user << "<span class='warning'>[src] is out of charge.</span>"
	else if(!src.ready) user << "Take the paddles out first."
	else if(world.time < src.nextShock) user << "<span class='warning'>[src] is still building up charge.</span>"
	else
		var/mob/living/carbon/human/target = M
		if(!(target.stat == 2 || target.stat == DEAD))
			if(src.emagged) src.shockAttack(target,user)
			else user << "<span class='warning'>[src] buzzes: Cardiac rythm normal. Safety engaged.</span>"
		else src.attemptDefib(target,user)
	return

/obj/item/weapon/melee/defibrillator/proc/shockAttack(mob/living/carbon/human/target,mob/user)
	var/datum/organ/internal/heart/heart = target.internal_organs["heart"]
	target.visible_message("<span class='danger'>[target.name] has been shocked with the [src] by [user]!</span>")
	target.Weaken(rand(6,12))
	target.apply_damage(rand(30,60),BURN,"chest")
	heart.damage += rand(5,60)
	target.emote("gasp")
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
	src.nextShock = world.time + 5
	return

/obj/item/weapon/melee/defibrillator/proc/attemptDefib(mob/living/carbon/human/target,mob/user)
	src.sparks.start()
	playsound(get_turf(src),'sound/items/defib.ogg',50,1)
	src.charges--
	src.update_icon()
	user << "<span class='notice'>You shock [target] with the paddles.</span>"
	if(target.mind && !target.client)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind == target.mind)
				ghost << 'sound/effects/adminhelp.ogg'
				ghost << "<span class='danger'>Someone is trying to revive your body. Return to it if you want to be resurrected!</span>"
				break
	if(target.wear_suit && istype(target.wear_suit,/obj/item/clothing/suit/armor) && prob(75))
		user << "<span class='warning'>[src] buzzes: Defibrillation failed. Please apply on bare skin.</span>"
	else if(target.w_uniform && istype(target.w_uniform,/obj/item/clothing/under && prob(50)))
		user << "<span class='warning'>[src] buzzes: Defibrillation failed. Please apply on bare skin.</span>"
	else
		var/datum/organ/internal/heart/heart = target.internal_organs["heart"]
		if(prob(50)) heart.damage = 0
		target.apply_damage(-target.getOxyLoss(),OXY)
		target.updatehealth()
		target.visible_message("<span class='warning'>[target]'s body convulses a bit.</span>")
		var/datum/organ/external/head/head = target.get_organ("head")
		if((target.health > config.health_threshold_dead)\
		&&(!(head.status & ORGAN_DESTROYED))\
		&&(!(M_NOCLONE in target.mutations))\
		&&(target.brain_op_stage < 4))
			target.visible_message("<span class='notice'>[src] beeps: Defibrillation successful.</span>")
			dead_mob_list -= target
			living_mob_list += target
			target.tod = null
			target.stat = CONSCIOUS
			target.regenerate_icons()
			target.update_canmove()
			flick("e_flash",target.flash)
			target << "<span class='notice'>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane.</span>"
	src.nextShock = world.time + 40
	return
