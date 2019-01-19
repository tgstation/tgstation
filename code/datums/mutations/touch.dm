/datum/mutation/human/shock
	name = "Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>You feel power flow through your hands.</span>"
	instability = 40
	locked = TRUE

/obj/effect/proc_holder/spell/targeted/touch/shock
	name = "Zap"
	desc = "Channel electricity to your hand to shock people with."
	hand_path = /obj/item/melee/touch_attack/shock
	charge_max = 100
	clothes_req = FALSE
	action_icon_state = "zap"

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	catchphrase = null
	on_use_sound = 'sound/weapons/zapbang.ogg'
	icon_state = "zapper"
	item_state = "zapper"

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.has_trait(TRAIT_SHOCKIMMUNE))
			user.visible_message("<span class='warning'>[user] fails to zap [target]!</span>")
			return ..()
		C.confused += 10
		C.Jitter(30)
		C.adjustFireLoss(10)
		C.dropItemToGround(C.get_active_held_item())
		C.dropItemToGround(C.get_inactive_held_item())
		C.visible_message("<span class='danger'>[user] zaps [target]!</span>","<span class='userdanger'>[user] zaps you, and you feel an electric shock surge through you!</span>")
		return ..()
	else if(isliving(target))
		var/mob/living/L = target
		L.adjustFireLoss(10)
		L.visible_message("<span class='danger'>[user] zaps [target]!</span>","<span class='userdanger'>[user] zaps you, and you feel an electric shock surge through you!</span>")
		return ..()
	else
		to_chat(user,"<span class='warning'>The electricity doesn't seem to affect [target]...</span>")
		return ..()
