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
	if(!proximity)
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target

		if(C.stat == DEAD && !user.combat_mode)
			defib(C, user)
			return

		if(C.electrocute_act(15, user, 1, SHOCK_NOGLOVES | SHOCK_NOSTUN))//doesnt stun. never let this stun
			C.dropItemToGround(C.get_active_held_item())
			C.dropItemToGround(C.get_inactive_held_item())
			C.add_confusion(15)
			C.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
			return ..()
		else
			user.visible_message("<span class='warning'>[user] fails to electrocute [target]!</span>")
			return ..()
	else if(isliving(target))
		var/mob/living/L = target
		L.electrocute_act(15, user, 1, SHOCK_NOSTUN)
		L.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] electrocutes you!</span>")
		return ..()
	else
		to_chat(user,"<span class='warning'>The electricity doesn't seem to affect [target]...</span>")
		return ..()

#define HALFWAYCRITDEATH ((HEALTH_THRESHOLD_CRIT + HEALTH_THRESHOLD_DEAD) * 0.5)

/obj/item/melee/touch_attack/shock/proc/defib(mob/living/carbon/target, mob/living/carbon/user)

	if(target.can_defib() == DEFIB_POSSIBLE)
		target.notify_ghost_cloning("Your heart is being defibrillated!")
		target.grab_ghost() // Shove them back in their body.

	user.visible_message("<span class='warning'>[user] begins to place [user.p_their()] hand on [target]'s chest.</span>", "<span class='warning'>You begin to place your hand on [target]'s chest...</span>")
	if(do_after(user, 5 SECONDS, target))
		for(var/obj/item/clothing/C in target.get_equipped_items())
			if((C.body_parts_covered & CHEST) && (C.clothing_flags & THICKMATERIAL)) //check to see if something is obscuring their chest.
				return FALSE
		if(isliving(target.pulledby)) //CLEAR!
			var/mob/living/M = target.pulledby
			if(M.electrocute_act(30, target))
				M.visible_message("<span class='danger'>[M] is electrocuted by [M.p_their()] contact with [target]!</span>")
				M.emote("scream")
		target.visible_message("<span class='warning'>[target]'s body convulses a bit.</span>")
		playsound(src, 'sound/machines/defib_zap.ogg', 75, TRUE, -1)
		if(!target.can_defib())
			return FALSE
		var/total_brute = target.getBruteLoss()
		var/total_burn = target.getFireLoss()
		if (target.health > HALFWAYCRITDEATH)
			target.adjustOxyLoss(target.health - HALFWAYCRITDEATH, 0)
		else
			var/overall_damage = total_brute + total_burn + target.getToxLoss() + target.getOxyLoss()
			var/mobhealth = target.health
			target.adjustOxyLoss((mobhealth - HALFWAYCRITDEATH) * (target.getOxyLoss() / overall_damage), 0)
			target.adjustToxLoss((mobhealth - HALFWAYCRITDEATH) * (target.getToxLoss() / overall_damage), 0, TRUE) // force tox heal for toxin lovers too
			target.adjustFireLoss((mobhealth - HALFWAYCRITDEATH) * (total_burn / overall_damage), 0)
			target.adjustBruteLoss((mobhealth - HALFWAYCRITDEATH) * (total_brute / overall_damage), 0)
		target.updatehealth() // Previous "adjust" procs don't update health, so we do it manually.
		target.set_heartattack(FALSE)
		target.grab_ghost()
		target.revive(full_heal = FALSE, admin_revive = FALSE)
		target.emote("gasp")
		target.Jitter(100)
		SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "saved_life", /datum/mood_event/saved_life)
		log_combat(user, target, "revived", "shock touch")
