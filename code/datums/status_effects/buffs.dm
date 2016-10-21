//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 3
	alert_type = /obj/screen/alert/status_effect/shadow_mend

/obj/screen/alert/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	icon_state = "shadow_mend"

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message("<span class='notice'>Violet light wraps around [owner]'s body!</span>", "<span class='notice'>Violet light wraps around your body!</span>")
	playsound(owner, 'sound/magic/Teleport_app.ogg', 50, 1)

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
	playsound(owner, 'sound/magic/Teleport_diss.ogg', 50, 1)
	owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)


/datum/status_effect/void_price
	id = "void_price"
	duration = 30
	tick_interval = 3
	alert_type = /obj/screen/alert/status_effect/void_price

/obj/screen/alert/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	icon_state = "shadow_mend"

/datum/status_effect/void_price/tick()
	owner << sound('sound/magic/Summon_Karp.ogg', volume = 25)
	owner.adjustBruteLoss(3)



/datum/status_effect/vanguard_shield
	id = "vanguard"
	duration = 20
	alert_type = /obj/screen/alert/status_effect/vanguard

/obj/screen/alert/status_effect/vanguard
	name = "Vanguard"
	desc = "You're absorbing stuns! 25% of all stuns taken will affect you after this effect ends."
	icon_state = "vanguard"
	alerttooltipstyle = "clockcult"

/obj/screen/alert/status_effect/vanguard/MouseEntered(location,control,params)
	var/mob/living/L = usr
	if(istype(L)) //this is probably more safety than actually needed
		var/vanguard = L.stun_absorption["vanguard"]
		desc = initial(desc)
		desc += "<br><b>[vanguard["stuns_absorbed"] * 2]</b> seconds of stuns held back.<br><b>[round(min(vanguard["stuns_absorbed"] * 0.25, 20)) * 2]</b> seconds of stun will affect you."
	..()

/datum/status_effect/vanguard_shield/on_apply()
	owner.add_stun_absorption("vanguard", 200, 1, "'s yellow aura momentarily intensifies!", "Your ward absorbs the stun!", " radiating with a soft yellow light!")
	owner.visible_message("<span class='warning'>[owner] begins to faintly glow!</span>", "<span class='brass'>You will absorb all stuns for the next twenty seconds.</span>")

/datum/status_effect/vanguard_shield/on_remove()
	var/vanguard = owner.stun_absorption["vanguard"]
	var/stuns_blocked = 0
	if(vanguard)
		stuns_blocked = round(min(vanguard["stuns_absorbed"] * 0.25, 20))
	if(owner.stat != DEAD)
		var/message_to_owner = "<span class='warning'>You feel your Vanguard quietly fade...</span>"
		var/otheractiveabsorptions = FALSE
		for(var/i in owner.stun_absorption)
			if(owner.stun_absorption[i]["end_time"] > world.time && owner.stun_absorption[i]["priority"] > vanguard["priority"])
				otheractiveabsorptions = TRUE
		if(!ratvar_awakens && stuns_blocked && !otheractiveabsorptions)
			vanguard["end_time"] = 0 //so it doesn't absorb the stuns we're about to apply
			owner.Stun(stuns_blocked)
			owner.Weaken(stuns_blocked)
			message_to_owner = "<span class='boldwarning'>The weight of the Vanguard's protection crashes down upon you!</span>"
			if(stuns_blocked >= 15)
				message_to_owner += "\n<span class='userdanger'>You faint from the exertion!</span>"
				owner.Paralyse(stuns_blocked * 2)
		owner.visible_message("<span class='warning'>[owner]'s glowing aura fades!</span>", message_to_owner)



/datum/status_effect/inathneqs_endowment
	id = "inathneqs_endowment"
	duration = 15
	alert_type = /obj/screen/alert/status_effect/inathneqs_endowment

/obj/screen/alert/status_effect/inathneqs_endowment
	name = "Inath-neq's Endowment"
	desc = "Adrenaline courses through you as the Resonant Cogwheel's energy shields you from all harm!"
	icon_state = "inathneqs_endowment"
	alerttooltipstyle = "clockcult"

/datum/status_effect/inathneqs_endowment/on_apply()
	owner.visible_message("<span class='warning'>[owner] shines with azure light!</span>", "<span class='notice'>You feel Inath-neq's power flow through you! You're invincible!</span>")
	owner.color = "#1E8CE1"
	owner.fully_heal()
	owner.add_stun_absorption("inathneq", 150, 2, "'s flickering blue aura momentarily intensifies!", "Inath-neq's power absorbs the stun!", " glowing with a flickering blue light!")
	owner.status_flags |= GODMODE
	animate(owner, color = initial(owner.color), time = 150, easing = EASE_IN)
	playsound(owner, 'sound/magic/Ethereal_Enter.ogg', 50, 1)

/datum/status_effect/inathneqs_endowment/on_remove()
	owner.visible_message("<span class='warning'>The light around [owner] flickers and dissipates!</span>", "<span class='boldwarning'>You feel Inath-neq's power fade from your body!</span>")
	owner.status_flags &= ~GODMODE
	playsound(owner, 'sound/magic/Ethereal_Exit.ogg', 50, 1)



/datum/status_effect/wraith_spectacles
	id = "wraith_spectacles"
	duration = -1 //remains until eye damage done reaches 0 while the glasses are not worn
	tick_interval = 2
	alert_type = /obj/screen/alert/status_effect/wraith_spectacles
	var/eye_damage_done = 0
	var/nearsight_breakpoint = 30
	var/blind_breakpoint = 45

/obj/screen/alert/status_effect/wraith_spectacles
	name = "Wraith Spectacles"
	desc = "You're wearing/not wearing a pair of wraith spectacles and have taken <b>X</b> eye damage from them overall.<br>\
	Your eye damage is increasing/decreasing.<br>\
	You will become nearsighted when you reach <b>nearsight_breakpoint</b> eye damage.<br>\
	You will become blind when you reach <b>blind_breakpoint</b> eye damage.<br>"
	icon_state = "wraithspecs"
	alerttooltipstyle = "clockcult"

/obj/screen/alert/status_effect/wraith_spectacles/MouseEntered(location,control,params)
	var/mob/living/carbon/human/L = usr
	if(istype(L)) //this is probably more safety than actually needed
		var/datum/status_effect/wraith_spectacles/W = attached_effect
		var/glasses_right = istype(L.glasses, /obj/item/clothing/glasses/wraith_spectacles)
		desc = "[glasses_right ? "<font color=#DAAA18><b>":""]You are [glasses_right ? "":"not "]wearing wraith spectacles[glasses_right ? "!</b></font>":"."]<br>\
		You have taken <font color=#DAAA18><b>[W.eye_damage_done]</b></font> eye damage from them.<br>"
		if(L.disabilities & NEARSIGHT)
			desc += "<font color=#DAAA18><b>You are nearsighted!</b></font><br>"
		else if(glasses_right)
			desc += "You will become nearsighted at <font color=#DAAA18><b>[W.nearsight_breakpoint]</b></font> eye damage.<br>"
		if(L.disabilities & BLIND)
			desc += "<font color=#DAAA18><b>You are blind!</b></font>"
		else if(glasses_right)
			desc += "You will become blind at <font color=#DAAA18><b>[W.blind_breakpoint]</b></font> eye damage."
	..()

/datum/status_effect/wraith_spectacles/tick()
	if(!ishuman(owner))
		cancel_effect()
		return
	var/mob/living/carbon/human/H = owner
	if(istype(H.glasses, /obj/item/clothing/glasses/wraith_spectacles) && !ratvar_awakens)
		if(H.disabilities & BLIND)
			return
		H.adjust_eye_damage(1)
		eye_damage_done++
		if(eye_damage_done >= 20)
			H.adjust_blurriness(2)
		if(eye_damage_done >= nearsight_breakpoint)
			if(H.become_nearsighted())
				H << "<span class='nzcrentr'>Your vision doubles, then trebles. Darkness begins to close in. You can't keep this up!</span>"
		if(eye_damage_done >= blind_breakpoint)
			if(H.become_blind())
				H << "<span class='nzcrentr_large'>A piercing white light floods your vision. Suddenly, all goes dark!</span>"
		if(prob(min(20, 5 + eye_damage_done)))
			H << "<span class='nzcrentr_small'><i>Your eyes continue to burn.</i></span>"
	else
		if(ratvar_awakens)
			H.cure_nearsighted()
			H.cure_blind()
			H.adjust_eye_damage(-eye_damage_done)
			eye_damage_done = 0
		else if(prob(50) && eye_damage_done)
			H.adjust_eye_damage(-1)
			eye_damage_done--
		if(!eye_damage_done)
			cancel_effect()