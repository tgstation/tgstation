/obj/structure/chair/alt_attack_hand(mob/living/user)
	if(Adjacent(user) && istype(user))
		if(!item_chair || !user.can_hold_items() || !has_buckled_mobs() || buckled_mobs.len > 1 || dir != user.dir || flags_1 & NODECONSTRUCT_1)
			return TRUE
		if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
			to_chat(user, "<span class='warning'>You can't do that right now!</span>")
			return TRUE
		if(user.getStaminaLoss() >= STAMINA_SOFTCRIT)
			to_chat(user, "<span class='warning'>You're too exhausted for that.</span>")
			return TRUE
		var/mob/living/poordude = buckled_mobs[1]
		if(!istype(poordude))
			return TRUE
		user.visible_message("<span class='notice'>[user] pulls [src] out from under [poordude].</span>", "<span class='notice'>You pull [src] out from under [poordude].</span>")
		var/C = new item_chair(loc)
		user.put_in_hands(C)
		poordude.Knockdown(20)//rip in peace
		user.adjustStaminaLoss(5)
		unbuckle_all_mobs(TRUE)
		qdel(src)
		return TRUE
