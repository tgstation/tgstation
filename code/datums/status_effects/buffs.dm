//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 30
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
	duration = 300
	tick_interval = 30
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
	duration = 200
	tick_interval = 0 //tick as fast as possible
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /obj/screen/alert/status_effect/vanguard
	var/datum/progressbar/progbar

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
		desc += "<br><b>[vanguard["stuns_absorbed"] * 2]</b> seconds of stuns held back.\
		[ratvar_awakens ? "":"<br><b>[round(min(vanguard["stuns_absorbed"] * 0.25, 20)) * 2]</b> seconds of stun will affect you."]"
	..()

/datum/status_effect/vanguard_shield/Destroy()
	qdel(progbar)
	progbar = null
	return ..()

/datum/status_effect/vanguard_shield/on_apply()
	add_logs(owner, null, "gained Vanguard stun immunity")
	owner.add_stun_absorption("vanguard", 200, 1, "'s yellow aura momentarily intensifies!", "Your ward absorbs the stun!", " radiating with a soft yellow light!")
	owner.visible_message("<span class='warning'>[owner] begins to faintly glow!</span>", "<span class='brass'>You will absorb all stuns for the next twenty seconds.</span>")
	progbar = new(owner, duration, owner)
	progbar.bar.color = list("#FAE48C", "#FAE48C", "#FAE48C", rgb(0,0,0))
	progbar.update(duration - world.time)

/datum/status_effect/vanguard_shield/tick()
	progbar.update(duration - world.time)

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
				stuns_blocked *= 2
				owner.Paralyse(stuns_blocked)
		else
			stuns_blocked = 0 //so logging is correct in cases where there were stuns blocked but we didn't stun for other reasons
		owner.visible_message("<span class='warning'>[owner]'s glowing aura fades!</span>", message_to_owner)
		add_logs(owner, null, "lost Vanguard stun immunity[stuns_blocked ? "and was stunned for [stuns_blocked]":""]")


/datum/status_effect/inathneqs_endowment
	id = "inathneqs_endowment"
	duration = 150
	alert_type = /obj/screen/alert/status_effect/inathneqs_endowment

/obj/screen/alert/status_effect/inathneqs_endowment
	name = "Inath-neq's Endowment"
	desc = "Adrenaline courses through you as the Resonant Cogwheel's energy shields you from all harm!"
	icon_state = "inathneqs_endowment"
	alerttooltipstyle = "clockcult"

/datum/status_effect/inathneqs_endowment/on_apply()
	add_logs(owner, null, "gained Inath-neq's invulnerability")
	owner.visible_message("<span class='warning'>[owner] shines with azure light!</span>", "<span class='notice'>You feel Inath-neq's power flow through you! You're invincible!</span>")
	var/oldcolor = owner.color
	owner.color = "#1E8CE1"
	owner.fully_heal()
	owner.add_stun_absorption("inathneq", 150, 2, "'s flickering blue aura momentarily intensifies!", "Inath-neq's power absorbs the stun!", " glowing with a flickering blue light!")
	owner.status_flags |= GODMODE
	animate(owner, color = oldcolor, time = 150, easing = EASE_IN)
	addtimer(CALLBACK(owner, /atom/proc/update_atom_colour), 150)
	playsound(owner, 'sound/magic/Ethereal_Enter.ogg', 50, 1)

/datum/status_effect/inathneqs_endowment/on_remove()
	add_logs(owner, null, "lost Inath-neq's invulnerability")
	owner.visible_message("<span class='warning'>The light around [owner] flickers and dissipates!</span>", "<span class='boldwarning'>You feel Inath-neq's power fade from your body!</span>")
	owner.status_flags &= ~GODMODE
	playsound(owner, 'sound/magic/Ethereal_Exit.ogg', 50, 1)


/datum/status_effect/cyborg_power_regen
	id = "power_regen"
	duration = 100
	alert_type = /obj/screen/alert/status_effect/power_regen
	var/power_to_give = 0 //how much power is gained each tick

/obj/screen/alert/status_effect/power_regen
	name = "Power Regeneration"
	desc = "You are quickly regenerating power!"
	icon_state = "power_regen"

/datum/status_effect/cyborg_power_regen/tick()
	var/mob/living/silicon/robot/cyborg = owner
	if(!istype(cyborg) || !cyborg.cell)
		qdel(src)
		return
	playsound(cyborg, 'sound/effects/light_flicker.ogg', 50, 1)
	cyborg.cell.give(power_to_give)

/datum/status_effect/his_grace
	id = "his_grace"
	duration = -1
	tick_interval = 4
	alert_type = /obj/screen/alert/status_effect/his_grace
	var/bloodlust = 0

/obj/screen/alert/status_effect/his_grace
	name = "His Grace"
	desc = "His Grace hungers, and you must feed Him."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/obj/screen/alert/status_effect/his_grace/MouseEntered(location,control,params)
	desc = initial(desc)
	var/datum/status_effect/his_grace/HG = attached_effect
	desc += "<br><font size=3><b>Current Bloodthirst: [HG.bloodlust]</b></font>\
	<br>Becomes undroppable at <b>[HIS_GRACE_FAMISHED]</b>\
	<br>Will consume you at <b>[HIS_GRACE_CONSUME_OWNER]</b>"
	..()

/datum/status_effect/his_grace/on_apply()
	add_logs(owner, null, "gained His Grace's stun immunity")
	owner.add_stun_absorption("hisgrace", INFINITY, 3, null, "His Grace protects you from the stun!")

/datum/status_effect/his_grace/tick()
	bloodlust = 0
	var/graces = 0
	for(var/obj/item/weapon/his_grace/HG in owner.held_items)
		if(HG.bloodthirst > bloodlust)
			bloodlust = HG.bloodthirst
		if(HG.awakened)
			graces++
	if(!graces)
		owner.apply_status_effect(STATUS_EFFECT_HISWRATH)
		qdel(src)
		return
	var/grace_heal = bloodlust * 0.05
	owner.adjustBruteLoss(-grace_heal)
	owner.adjustFireLoss(-grace_heal)
	owner.adjustToxLoss(-grace_heal, TRUE, TRUE)
	owner.adjustOxyLoss(-(grace_heal * 2))
	owner.adjustCloneLoss(-grace_heal)

/datum/status_effect/his_grace/on_remove()
	add_logs(owner, null, "lost His Grace's stun immunity")
	if(islist(owner.stun_absorption) && owner.stun_absorption["hisgrace"])
		owner.stun_absorption -= "hisgrace"


/datum/status_effect/wish_granters_gift //Fully revives after ten seconds.
	id = "wish_granters_gift"
	duration = 50
	alert_type = /obj/screen/alert/status_effect/wish_granters_gift

/datum/status_effect/wish_granters_gift/on_apply()
	to_chat(owner, "<span class='notice'>Death is not your end! The Wish Granter's energy suffuses you, and you begin to rise...</span>")

/datum/status_effect/wish_granters_gift/on_remove()
	owner.revive(full_heal = 1, admin_revive = 1)
	owner.visible_message("<span class='warning'>[owner] appears to wake from the dead, having healed all wounds!</span>", "<span class='notice'>You have regenerated.</span>")
	owner.update_canmove()

/obj/screen/alert/status_effect/wish_granters_gift
	name = "Wish Granter's Immortality"
	desc = "You are being resurrected!"
	icon_state = "wish_granter"
