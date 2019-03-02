/obj/item/melee/baton/destabilizer
	stunforce = 0
	name = "destabilizer"
	desc = "Looks futuristic, it can instantly knock any gem out."
	icon_state = "destabilizer"
	item_state = "destabilizer"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'

/datum/design/destabilizer
	name = "Destabilizer"
	desc = "Era 2 Tech, instantly poofs any gem."
	id = "destabilizer"
	build_path = /obj/item/melee/baton/destabilizer
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 2000, MAT_PLASMA = 2000, MAT_BLUESPACE = 2000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/obj/item/melee/baton/destabilizer/attack(mob/M, mob/living/carbon/human/user)
	if(status && user.has_trait(TRAIT_CLUMSY) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		if(isgem(user))
			user.setCloneLoss(9001) //FUCK EM UP!
		deductcharge(hitcost)
		return

	if(iscyborg(M))
		..()
		return


	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(check_martial_counter(L, user))
			return

	if(user.a_intent != INTENT_HARM)
		if(status)
			if(baton_stun(M, user))
				user.do_attack_animation(M)
				return
		else
			M.visible_message("<span class='warning'>[user] has prodded [M] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
	else
		if(status)
			baton_stun(M, user)
		..()

/obj/item/melee/baton/destabilizer/baton_stun(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/weapons/genhit.ogg', 50, 1)
			return 0
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return 0
	else
		if(!deductcharge(hitcost))
			return 0

	if(user)
		L.lastattacker = user.real_name
		L.lastattackerckey = user.ckey
		L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
								"<span class='userdanger'>[user] has stunned you with [src]!</span>")
		log_combat(user, L, "destabilized")

	if(istype(L,/mob/living/carbon))
		var/mob/living/carbon/C = L
		if(isgem(C))
			C.setCloneLoss(9001) //FUCK EM UP!

	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(GLOB.hit_appends)


	return 1