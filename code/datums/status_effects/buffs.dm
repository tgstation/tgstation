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
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return ..()

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
	playsound(owner, 'sound/magic/teleport_diss.ogg', 50, 1)
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
	SEND_SOUND(owner, sound('sound/magic/summon_karp.ogg', volume = 25))
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
		desc += "<br><b>[Floor(vanguard["stuns_absorbed"] * 0.1)]</b> seconds of stuns held back.\
		[GLOB.ratvar_awakens ? "":"<br><b>[Floor(min(vanguard["stuns_absorbed"] * 0.025, 20))]</b> seconds of stun will affect you."]"
	..()

/datum/status_effect/vanguard_shield/Destroy()
	qdel(progbar)
	progbar = null
	return ..()

/datum/status_effect/vanguard_shield/on_apply()
	owner.log_message("gained Vanguard stun immunity", INDIVIDUAL_ATTACK_LOG)
	owner.add_stun_absorption("vanguard", 200, 1, "'s yellow aura momentarily intensifies!", "Your ward absorbs the stun!", " radiating with a soft yellow light!")
	owner.visible_message("<span class='warning'>[owner] begins to faintly glow!</span>", "<span class='brass'>You will absorb all stuns for the next twenty seconds.</span>")
	owner.SetStun(0, FALSE)
	owner.SetKnockdown(0)
	progbar = new(owner, duration, owner)
	progbar.bar.color = list("#FAE48C", "#FAE48C", "#FAE48C", rgb(0,0,0))
	progbar.update(duration - world.time)
	return ..()

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
		if(!GLOB.ratvar_awakens && stuns_blocked && !otheractiveabsorptions)
			vanguard["end_time"] = 0 //so it doesn't absorb the stuns we're about to apply
			owner.Knockdown(stuns_blocked)
			message_to_owner = "<span class='boldwarning'>The weight of the Vanguard's protection crashes down upon you!</span>"
			if(stuns_blocked >= 300)
				message_to_owner += "\n<span class='userdanger'>You faint from the exertion!</span>"
				stuns_blocked *= 2
				owner.Unconscious(stuns_blocked)
		else
			stuns_blocked = 0 //so logging is correct in cases where there were stuns blocked but we didn't stun for other reasons
		owner.visible_message("<span class='warning'>[owner]'s glowing aura fades!</span>", message_to_owner)
		owner.log_message("lost Vanguard stun immunity[stuns_blocked ? "and was stunned for [stuns_blocked]":""]", INDIVIDUAL_ATTACK_LOG)


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
	owner.log_message("gained Inath-neq's invulnerability", INDIVIDUAL_ATTACK_LOG)
	owner.visible_message("<span class='warning'>[owner] shines with azure light!</span>", "<span class='notice'>You feel Inath-neq's power flow through you! You're invincible!</span>")
	var/oldcolor = owner.color
	owner.color = "#1E8CE1"
	owner.fully_heal()
	owner.add_stun_absorption("inathneq", 150, 2, "'s flickering blue aura momentarily intensifies!", "Inath-neq's power absorbs the stun!", " glowing with a flickering blue light!")
	owner.status_flags |= GODMODE
	animate(owner, color = oldcolor, time = 150, easing = EASE_IN)
	addtimer(CALLBACK(owner, /atom/proc/update_atom_colour), 150)
	playsound(owner, 'sound/magic/ethereal_enter.ogg', 50, 1)
	return ..()

/datum/status_effect/inathneqs_endowment/on_remove()
	owner.log_message("lost Inath-neq's invulnerability", INDIVIDUAL_ATTACK_LOG)
	owner.visible_message("<span class='warning'>The light around [owner] flickers and dissipates!</span>", "<span class='boldwarning'>You feel Inath-neq's power fade from your body!</span>")
	owner.status_flags &= ~GODMODE
	playsound(owner, 'sound/magic/ethereal_exit.ogg', 50, 1)


/datum/status_effect/cyborg_power_regen
	id = "power_regen"
	duration = 100
	alert_type = /obj/screen/alert/status_effect/power_regen
	var/power_to_give = 0 //how much power is gained each tick

/datum/status_effect/cyborg_power_regen/on_creation(mob/living/new_owner, new_power_per_tick)
	. = ..()
	if(. && isnum(new_power_per_tick))
		power_to_give = new_power_per_tick

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
	owner.log_message("gained His Grace's stun immunity", INDIVIDUAL_ATTACK_LOG)
	owner.add_stun_absorption("hisgrace", INFINITY, 3, null, "His Grace protects you from the stun!")
	return ..()

/datum/status_effect/his_grace/tick()
	bloodlust = 0
	var/graces = 0
	for(var/obj/item/his_grace/HG in owner.held_items)
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
	owner.log_message("lost His Grace's stun immunity", INDIVIDUAL_ATTACK_LOG)
	if(islist(owner.stun_absorption) && owner.stun_absorption["hisgrace"])
		owner.stun_absorption -= "hisgrace"


/datum/status_effect/wish_granters_gift //Fully revives after ten seconds.
	id = "wish_granters_gift"
	duration = 50
	alert_type = /obj/screen/alert/status_effect/wish_granters_gift

/datum/status_effect/wish_granters_gift/on_apply()
	to_chat(owner, "<span class='notice'>Death is not your end! The Wish Granter's energy suffuses you, and you begin to rise...</span>")
	return ..()

/datum/status_effect/wish_granters_gift/on_remove()
	owner.revive(full_heal = 1, admin_revive = 1)
	owner.visible_message("<span class='warning'>[owner] appears to wake from the dead, having healed all wounds!</span>", "<span class='notice'>You have regenerated.</span>")
	owner.update_canmove()

/obj/screen/alert/status_effect/wish_granters_gift
	name = "Wish Granter's Immortality"
	desc = "You are being resurrected!"
	icon_state = "wish_granter"

/datum/status_effect/cult_master
	id = "The Cult Master"
	duration = -1
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/alive = TRUE

/datum/status_effect/cult_master/proc/deathrattle()
	if(!QDELETED(GLOB.cult_narsie))
		return //if nar-sie is alive, don't even worry about it
	var/area/A = get_area(owner)
	for(var/datum/mind/B in SSticker.mode.cult)
		if(isliving(B.current))
			var/mob/living/M = B.current
			SEND_SOUND(M, sound('sound/hallucinations/veryfar_noise.ogg'))
			to_chat(M, "<span class='cultlarge'>The Cult's Master, [owner], has fallen in \the [A]!</span>")

/datum/status_effect/cult_master/tick()
	if(owner.stat != DEAD && !alive)
		alive = TRUE
		return
	if(owner.stat == DEAD && alive)
		alive = FALSE
		deathrattle()

/datum/status_effect/cult_master/on_remove()
	deathrattle()
	. = ..()

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /obj/screen/alert/status_effect/blooddrunk
	var/last_health = 0
	var/last_bruteloss = 0
	var/last_fireloss = 0
	var/last_toxloss = 0
	var/last_oxyloss = 0
	var/last_cloneloss = 0
	var/last_staminaloss = 0

/obj/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		owner.maxHealth *= 10
		owner.bruteloss *= 10
		owner.fireloss *= 10
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			for(var/X in C.bodyparts)
				var/obj/item/bodypart/BP = X
				BP.brute_dam *= 10
				BP.burn_dam *= 10
		owner.toxloss *= 10
		owner.oxyloss *= 10
		owner.cloneloss *= 10
		owner.staminaloss *= 10
		owner.updatehealth()
		last_health = owner.health
		last_bruteloss = owner.getBruteLoss()
		last_fireloss = owner.getFireLoss()
		last_toxloss = owner.getToxLoss()
		last_oxyloss = owner.getOxyLoss()
		last_cloneloss = owner.getCloneLoss()
		last_staminaloss = owner.getStaminaLoss()
		owner.log_message("gained blood-drunk stun immunity", INDIVIDUAL_ATTACK_LOG)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1)

/datum/status_effect/blooddrunk/tick() //multiply the effect of healing by 10
	if(owner.health > last_health)
		var/needs_health_update = FALSE
		var/new_bruteloss = owner.getBruteLoss()
		if(new_bruteloss < last_bruteloss)
			var/heal_amount = (new_bruteloss - last_bruteloss) * 10
			owner.adjustBruteLoss(heal_amount, updating_health = FALSE)
			new_bruteloss = owner.getBruteLoss()
			needs_health_update = TRUE
		last_bruteloss = new_bruteloss

		var/new_fireloss = owner.getFireLoss()
		if(new_fireloss < last_fireloss)
			var/heal_amount = (new_fireloss - last_fireloss) * 10
			owner.adjustFireLoss(heal_amount, updating_health = FALSE)
			new_fireloss = owner.getFireLoss()
			needs_health_update = TRUE
		last_fireloss = new_fireloss

		var/new_toxloss = owner.getToxLoss()
		if(new_toxloss < last_toxloss)
			var/heal_amount = (new_toxloss - last_toxloss) * 10
			owner.adjustToxLoss(heal_amount, updating_health = FALSE)
			new_toxloss = owner.getToxLoss()
			needs_health_update = TRUE
		last_toxloss = new_toxloss

		var/new_oxyloss = owner.getOxyLoss()
		if(new_oxyloss < last_oxyloss)
			var/heal_amount = (new_oxyloss - last_oxyloss) * 10
			owner.adjustOxyLoss(heal_amount, updating_health = FALSE)
			new_oxyloss = owner.getOxyLoss()
			needs_health_update = TRUE
		last_oxyloss = new_oxyloss

		var/new_cloneloss = owner.getCloneLoss()
		if(new_cloneloss < last_cloneloss)
			var/heal_amount = (new_cloneloss - last_cloneloss) * 10
			owner.adjustCloneLoss(heal_amount, updating_health = FALSE)
			new_cloneloss = owner.getCloneLoss()
			needs_health_update = TRUE
		last_cloneloss = new_cloneloss

		var/new_staminaloss = owner.getStaminaLoss()
		if(new_staminaloss < last_staminaloss)
			var/heal_amount = (new_staminaloss - last_staminaloss) * 10
			owner.adjustStaminaLoss(heal_amount, updating_health = FALSE)
			new_staminaloss = owner.getStaminaLoss()
			needs_health_update = TRUE
		last_staminaloss = new_staminaloss

		if(needs_health_update)
			owner.updatehealth()
			owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1)
	last_health = owner.health

/datum/status_effect/blooddrunk/on_remove()
	tick()
	owner.maxHealth *= 0.1
	owner.bruteloss *= 0.1
	owner.fireloss *= 0.1
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		for(var/X in C.bodyparts)
			var/obj/item/bodypart/BP = X
			BP.brute_dam *= 0.1
			BP.burn_dam *= 0.1
	owner.toxloss *= 0.1
	owner.oxyloss *= 0.1
	owner.cloneloss *= 0.1
	owner.staminaloss *= 0.1
	owner.updatehealth()
	owner.log_message("lost blood-drunk stun immunity", INDIVIDUAL_ATTACK_LOG)
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

