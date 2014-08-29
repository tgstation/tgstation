/obj/item/weapon/melee/defibrillator
	name = "\improper emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to recall people back from the etheral planes or send them there."
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
		playsound(get_turf(src), 'sound/items/defib.ogg', 50, 1)
		return (FIRELOSS)

/obj/item/weapon/melee/defibrillator/update_icon()
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

/obj/item/weapon/melee/defibrillator/attack_self(mob/user as mob)
	if(status && (M_CLUMSY in user.mutations) && prob(50))
		spark_system.attach(user)
		spark_system.set_up(5, 0, src)
		spark_system.start()
		user << "<span class='warning'>You touch the paddles together, shorting the device.</span>"
		playsound(get_turf(src), "sparks", 75, 1, -1)
		user.Weaken(5)
		var/mob/living/carbon/human/H = user
		if(ishuman(user))
			H.apply_damage(10, BURN)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return
	if(charges > 0)
		status = !status
		user << "<span class='notice'>[src] is now [status ? "on" : "off"].</span>"
		playsound(get_turf(src), "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		user << "<span class='warning'>[src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/melee/defibrillator/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/card/emag))
		var/image/I = image("icon" = "icons/obj/weapons.dmi", "icon_state" = "defib_emag")
		if(emagged == 0)
			emagged = 1
			usr << "<span class='warning'>You short out [src]'s safety protocols using [W].</span>"
			overlays += I
		else
			emagged = 0
			usr << "<span class='notice'>You reset [src]'s safety protocols using [W].</span>"
			overlays -= I

/obj/item/weapon/melee/defibrillator/attack(mob/M as mob, mob/user as mob)
	var/mob/living/carbon/human/H = M
	if(!ishuman(M))
		..()
		return
	var/datum/organ/internal/heart/dropthebeat = H.internal_organs["heart"]
	if(status)
		if(emagged)
			H.visible_message("<span class='danger'>[M.name] has been touched by the defibrillator paddles in the chest by [user]!</span>")
			if(charges >= 2)
				H.Weaken(10)
				H.apply_damage(20, BURN, "chest")
				if(prob(80)) //Life 101 : Sending loadse electricity through your chest is bad for your heart
					if(prob(60))
						H.apply_damage(10, BURN, "chest") //Bonus
						dropthebeat.damage += 5 //Ouchie
						H.emote("gasp")
					else
						H.apply_damage(30, BURN, "chest") //Dead
						dropthebeat.damage += 60 //Drop the beat
						H.emote("scream") //I have no beat and I must scream
			else
				H.Weaken(5)
				H.apply_damage(10, BURN)
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
			playsound(get_turf(src), 'sound/items/defib.ogg', 50, 1)
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Shocked [H.name] ([H.ckey]) with an emagged [src.name]</font>"
			H.attack_log += "\[[time_stamp()]\]<font color='orange'> Shocked by [user.name] ([user.ckey]) with an emagged [src.name]</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) shocked [H.name] ([H.ckey]) with an emagged [src.name]</font>" )
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user
			return
		H.visible_message("<span class='notice'>[user] starts setting up the defibrillator paddles on [M.name]'s chest.</span>", "<span class='notice'>You start setting up the defibrillator paddles on [M.name]'s chest.</span>")
		if(do_after(user, 50))
			if(H.stat == 2 || H.stat == DEAD)
				var/uni = 0
				var/armor = 0
				var/fixable = H.getOxyLoss() //Simple but efficient. You'd have popped a Dex+ pill anyways
				playsound(get_turf(src), 'sound/items/defib.ogg', 50, 1)
				spark_system.attach(M)
				spark_system.set_up(5, 0, M)
				spark_system.start()
				charges--
				if(charges < 1)
					charges = 0
					status = 0
				update_icon()
				for(var/obj/item/carried_item in H.contents)
					if(istype(carried_item, /obj/item/clothing/under))
						uni = 1
					if(istype(carried_item, /obj/item/clothing/suit/armor))
						armor = 1
				if(armor) //I'm sure I should apply the paddles on hardsuit plating
					if(prob(95))
						viewers(M) << "<span class='warning'>[src] buzzes: Resuscitation failed. Please apply on bare skin.</span>"
						H.apply_damage(5, BURN, "chest")
						return
					else
						H.apply_damage(-fixable, OXY) //Tada
				else if(uni && !armor) //Just a suit, still bad
					if(prob(50))
						viewers(M) << "<span class='warning'>[src] buzzes: Resuscitation failed. Please apply on bare skin.</span>"
						H.apply_damage(10, BURN, "chest")
						return
					else
						H.apply_damage(-fixable, OXY)
				else
					if(prob(5))
						viewers(M) << "<span class='warning'>[src] buzzes: Resuscitation failed. Please apply on bare skin.</span>"
						H.apply_damage(15, BURN, "chest")
						return
					else
						H.apply_damage(-fixable, OXY)
				H.updatehealth() //forces a health update, otherwise the oxyloss adjustment wouldnt do anything
				M.visible_message("<span class='warning'>[M]'s body convulses a bit.</span>")
				if(!H.client && H.mind)
					for(var/mob/dead/observer/ghost in player_list)
						if(ghost.mind == H.mind)
							ghost << 'sound/effects/adminhelp.ogg'
							ghost << "<b><font color = #330033><font size = 3>An attempt to defibrillate you has been made. Return to your body if you want to be resurrected!</b> (Verbs -> Ghost -> Re-enter corpse)</font color>"
							break
				var/datum/organ/external/temp = H.get_organ("head")
				if(!H.client)
					viewers(M) << "<span class='notice'>[src] beeps: Resuscitation failed. Patient's brain shows no cerebral activity. Try again in a few seconds.</span>"
					return
				if(H.health > config.health_threshold_dead && !(temp.status & ORGAN_DESTROYED) && !(M_NOCLONE in H.mutations) && !H.suiciding && (H.brain_op_stage < 4))
					viewers(M) << "<span class='notice'>[src] beeps: Resuscitation successful.</span>"
					spawn(0)
						if(H.stat == 2)
							dead_mob_list -= H
							living_mob_list += H
							H.tod = null

							// restore us to conciousness
							H.stat = CONSCIOUS
							H.regenerate_icons()
							H.update_canmove()
						flick("e_flash", M.flash)
						H.apply_effect(10, EYE_BLUR)
						H.apply_effect(10, PARALYZE)
						H << "<span class='notice'><b>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane.</b><br><i>Not today.</i></span>"
						H.emote("gasp")
				else
					viewers(M) << "<span class='warning'>[src] buzzes: Resuscitation failed. Patient is beyond saving.</span>"
			else
				viewers(M) << "<span class='warning'>[src] buzzes: Patient is not in need of resuscitation.</span>"
