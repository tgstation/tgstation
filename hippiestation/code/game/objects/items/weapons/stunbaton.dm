
/obj/item/weapon/melee/baton
	var/stamforce = 80

/obj/item/weapon/melee/baton/cattleprod/hippie_cattleprod
	w_class = WEIGHT_CLASS_NORMAL
	stunforce = 0.1


/obj/item/weapon/melee/baton/proc/baton_stun_hippie_makeshift(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(0, "[user]'s [name]", src, MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/weapons/Genhit.ogg', 50, 1)
			return 0
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return 0
	else
		if(!deductcharge(hitcost))
			return 0

	L.Stun(stunforce)
	L.staminaloss += stamforce //Not reduced by armour to give it an edge over a taser.
	L.apply_effect(STUTTER, 7) //Duration of sec baton
	if(user)
		user.lastattacked = L
		L.lastattacker = user
		L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
								"<span class='userdanger'>[user] has stunned you with [src]!</span>")
		add_logs(user, L, "stunned")

	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(GLOB.hit_appends)

	return 1