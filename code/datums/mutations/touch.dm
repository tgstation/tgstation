/datum/mutation/human/shock
	name = "Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>You feel power flow through your hands.</span>"
	text_lose_indication = "<span class='notice'>The energy in your hands subsides.</span>"
	power = /obj/effect/proc_holder/spell/targeted/touch/shock
	instability = 30

/obj/effect/proc_holder/spell/targeted/touch/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with."
	drawmessage = "You channel electricity into your hand."
	dropmessage = "You let the electricity from your hand dissipate."
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
	inhand_icon_state = "zapper"

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isliving(target))
		return
	var/mob/living/living_target = target
	if(!living_target.electrocute_act(15, user, 1, SHOCK_NOGLOVES | SHOCK_NOSTUN)) //Doesn't stun. Never let this stun.
		user.visible_message(span_warning("[user] fails to electrocute [target]!"))
		return ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.dropItemToGround(carbon_target.get_active_held_item())
		carbon_target.dropItemToGround(carbon_target.get_inactive_held_item())
		carbon_target.add_confusion(15)
	living_target.visible_message(span_danger("[user] electrocutes [target]!"),span_userdanger("[user] electrocutes you!"))
	return ..()
