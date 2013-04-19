/obj/item/security/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	m_amt = 500
	origin_tech = "materials=1"
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes


/obj/item/security/handcuffs/attack(mob/living/carbon/C, mob/user)
	if(CLUMSY in user.mutations && prob(50))
		user << "<span class='warning'>Uh... how do those things work?!</span>"
		if(!C.handcuffed)
			user.drop_item()
			loc = C
			C.handcuffed = src
			C.update_inv_handcuffed(0)
			return

	var/cable = 0
	if(istype(src, /obj/item/security/handcuffs/cable))
		cable = 1

	if(!C.handcuffed)
		C.visible_message("<span class='danger'>[user] is trying to put handcuffs on [C]!</span>", \
							"<span class='userdanger'>[user] is trying to put handcuffs on [C]!</span>")

		if(cable)
			playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		else
			playsound(loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)

		var/turf/user_loc = user.loc
		var/turf/C_loc = C.loc
		if(do_after(user, 50))
			if(!C || C.handcuffed)
				return
			if(user_loc == user.loc && C_loc == C.loc)
				user.drop_item()
				loc = C
				C.handcuffed = src
				C.update_inv_handcuffed(0)
			if(cable)
				feedback_add_details("handcuffs","C")
			else
				feedback_add_details("handcuffs","H")

			C.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been handcuffed (attempt) by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to handcuff [C.name] ([C.ckey])</font>")
			log_attack("<font color='red'>[user.name] ([user.ckey]) Attempted to handcuff [C.name] ([C.ckey])</font>")


/obj/item/security/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_red"
	item_state = "coil_red"
	breakouttime = 300 //Deciseconds = 30s

/obj/item/security/handcuffs/cable/red
	icon_state = "cuff_red"

/obj/item/security/handcuffs/cable/yellow
	icon_state = "cuff_yellow"

/obj/item/security/handcuffs/cable/blue
	icon_state = "cuff_blue"
	item_state = "coil_blue"

/obj/item/security/handcuffs/cable/green
	icon_state = "cuff_green"

/obj/item/security/handcuffs/cable/pink
	icon_state = "cuff_pink"

/obj/item/security/handcuffs/cable/orange
	icon_state = "cuff_orange"

/obj/item/security/handcuffs/cable/cyan
	icon_state = "cuff_cyan"

/obj/item/security/handcuffs/cable/white
	icon_state = "cuff_white"


/obj/item/security/handcuffs/cyborg/attack(mob/living/carbon/C, mob/user)
	if(isrobot(user))
		if(!C.handcuffed)
			var/turf/user_loc = user.loc
			var/turf/C_loc = C.loc
			playsound(loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
			C.visible_message("<span class='danger'>[user] is trying to put handcuffs on [C]!</span>", \
								"<span class='userdanger'>[user] is trying to put handcuffs on [C]!</span>")
			if(do_after(user, 30))
				if(!C || C.handcuffed)
					return
				if(user_loc == user.loc && C_loc == C.loc)
					C.handcuffed = new /obj/item/security/handcuffs(C)
					C.update_inv_handcuffed(0)
