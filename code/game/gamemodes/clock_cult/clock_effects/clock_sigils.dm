//Sigils: Rune-like markings on the ground with various effects.
/obj/effect/clockwork/sigil
	name = "sigil"
	desc = "A strange set of markings drawn on the ground."
	clockwork_desc = "A sigil of some purpose."
	icon_state = "sigil"
	layer = LOW_OBJ_LAYER
	alpha = 50
	resistance_flags = NONE
	var/affects_servants = FALSE
	var/stat_affected = CONSCIOUS
	var/sigil_name = "Sigil"
	var/resist_string = "glows blinding white" //string for when a null rod blocks its effects, "glows [resist_string]"

/obj/effect/clockwork/sigil/attackby(obj/item/I, mob/living/user, params)
	if(I.force && !is_servant_of_ratvar(user))
		user.visible_message("<span class='warning'>[user] scatters [src] with [I]!</span>", "<span class='danger'>You scatter [src] with [I]!</span>")
		qdel(src)
		return 1
	return ..()

/obj/effect/clockwork/sigil/attack_hand(mob/user)
	if(iscarbon(user) && !user.stat && (!is_servant_of_ratvar(user) || (is_servant_of_ratvar(user) && user.a_intent == INTENT_HARM)))
		user.visible_message("<span class='warning'>[user] stamps out [src]!</span>", "<span class='danger'>You stomp on [src], scattering it into thousands of particles.</span>")
		qdel(src)
		return 1
	..()

/obj/effect/clockwork/sigil/ex_act(severity)
	visible_message("<span class='warning'>[src] scatters into thousands of particles.</span>")
	qdel(src)

/obj/effect/clockwork/sigil/Crossed(atom/movable/AM)
	..()
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.stat <= stat_affected)
			if((!is_servant_of_ratvar(L) || (affects_servants && is_servant_of_ratvar(L))) && (L.mind || L.has_status_effect(STATUS_EFFECT_SIGILMARK)) && !isdrone(L))
				var/obj/item/I = L.null_rod_check()
				if(I)
					L.visible_message("<span class='warning'>[L]'s [I.name] [resist_string], protecting them from [src]'s effects!</span>", \
					"<span class='userdanger'>Your [I.name] [resist_string], protecting you!</span>")
					return
				sigil_effects(L)

/obj/effect/clockwork/sigil/proc/sigil_effects(mob/living/L)


//Sigil of Transgression: Stuns the first non-servant to walk on it and flashes all nearby non_servants. Nar-Sian cultists are damaged and knocked down for a longer stun
/obj/effect/clockwork/sigil/transgression
	name = "dull sigil"
	desc = "A dull, barely-visible golden sigil. It's as though light was carved into the ground."
	icon = 'icons/effects/clockwork_effects.dmi'
	clockwork_desc = "A sigil that will stun the first non-servant to cross it. Nar-Sie's dogs will be knocked down."
	icon_state = "sigildull"
	color = "#FAE48C"
	sigil_name = "Sigil of Transgression"

/obj/effect/clockwork/sigil/transgression/sigil_effects(mob/living/L)
	var/target_flashed = L.flash_act()
	for(var/mob/living/M in viewers(5, src))
		if(!is_servant_of_ratvar(M) && M != L)
			M.flash_act()
	if(iscultist(L))
		L << "<span class='heavy_brass'>\"Watch your step, wretch.\"</span>"
		L.adjustBruteLoss(10)
		L.Weaken(7)
	L.visible_message("<span class='warning'>[src] appears around [L] in a burst of light!</span>", \
	"<span class='userdanger'>[target_flashed ? "An unseen force":"The glowing sigil around you"] holds you in place!</span>")
	L.Stun(5)
	new /obj/effect/overlay/temp/ratvar/sigil/transgression(get_turf(src))
	qdel(src)


//Sigil of Submission: After a short time, converts any non-servant standing on it. Knocks down and silences them for five seconds afterwards.
/obj/effect/clockwork/sigil/submission
	name = "ominous sigil"
	desc = "A luminous golden sigil. Something about it really bothers you."
	clockwork_desc = "A sigil that will enslave the first person to cross it, provided they remain on it for seven seconds."
	icon_state = "sigilsubmission"
	color = "#FAE48C"
	alpha = 125
	stat_affected = UNCONSCIOUS
	resist_string = "glows faintly yellow"
	var/convert_time = 70
	var/glow_light = 2 //soft light
	var/glow_falloff = 1
	var/delete_on_finish = TRUE
	sigil_name = "Sigil of Submission"
	var/glow_type

/obj/effect/clockwork/sigil/submission/New()
	..()
	SetLuminosity(glow_light,glow_falloff)

/obj/effect/clockwork/sigil/submission/proc/post_channel(mob/living/L)

/obj/effect/clockwork/sigil/submission/sigil_effects(mob/living/L)
	L.visible_message("<span class='warning'>[src] begins to glow a piercing magenta!</span>", "<span class='sevtug'>You feel something start to invade your mind...</span>")
	var/oldcolor = color
	animate(src, color = "#AF0AAF", time = convert_time)
	var/obj/effect/overlay/temp/ratvar/sigil/glow
	if(glow_type)
		glow = new glow_type(get_turf(src))
		animate(glow, alpha = 255, time = convert_time)
	var/I = 0
	while(I < convert_time && get_turf(L) == get_turf(src))
		I++
		sleep(1)
	if(get_turf(L) != get_turf(src))
		if(glow)
			qdel(glow)
		animate(src, color = oldcolor, time = 20)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 20)
		visible_message("<span class='warning'>[src] slowly stops glowing!</span>")
		return
	post_channel(L)
	if(is_eligible_servant(L))
		L << "<span class='heavy_brass'>\"You belong to me now.\"</span>"
	add_servant_of_ratvar(L)
	L.Weaken(3) //Completely defenseless for about five seconds - mainly to give them time to read over the information they've just been presented with
	L.Stun(3)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.silent += 5
	var/message = "[sigil_name] in [get_area(src)] <span class='sevtug'>[is_servant_of_ratvar(L) ? "successfully converted" : "failed to convert"]</span>"
	for(var/M in mob_list)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, L)
			M <<  "[link] <span class='heavy_brass'>[message] [L.real_name]!</span>"
		else if(is_servant_of_ratvar(M))
			if(M == L)
				M << "<span class='heavy_brass'>[message] you!</span>"
			else
				M << "<span class='heavy_brass'>[message] [L.real_name]!</span>"
	if(delete_on_finish)
		qdel(src)
	else
		animate(src, color = oldcolor, time = 20)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 20)
		visible_message("<span class='warning'>[src] slowly stops glowing!</span>")


//Sigil of Accession: After a short time, converts any non-servant standing on it though implants. Knocks down and silences them for five seconds afterwards.
/obj/effect/clockwork/sigil/submission/accession
	name = "terrifying sigil"
	desc = "A luminous brassy sigil. Something about it makes you want to flee."
	clockwork_desc = "A sigil that will enslave any person who crosses it, provided they remain on it for seven seconds. \n\
	It can convert a mindshielded target once before disppearing, but can convert any number of non-implanted targets."
	icon_state = "sigiltransgression"
	color = "#A97F1B"
	alpha = 200
	glow_light = 4 //bright light
	glow_falloff = 3
	delete_on_finish = FALSE
	sigil_name = "Sigil of Accession"
	glow_type = /obj/effect/overlay/temp/ratvar/sigil/accession
	resist_string = "glows bright orange"

/obj/effect/clockwork/sigil/submission/accession/post_channel(mob/living/L)
	if(L.isloyal())
		delete_on_finish = TRUE
		L.visible_message("<span class='warning'>[L] visibly trembles!</span>", \
		"<span class='sevtug'>[text2ratvar("You will be mine and his. This puny trinket will not stop me.")]</span>")
		for(var/obj/item/weapon/implant/mindshield/M in L.implants)
			qdel(M)


//Sigil of Transmission: Stores power for clockwork machinery, serving as a battery.
/obj/effect/clockwork/sigil/transmission
	name = "suspicious sigil"
	desc = "A glowing orange sigil. The air around it feels staticky."
	clockwork_desc = "A sigil that will serve as a battery for clockwork structures."
	icon_state = "sigiltransmission"
	color = "#EC8A2D"
	alpha = 50
	resist_string = "glows faintly"
	sigil_name = "Sigil of Transmission"
	affects_servants = TRUE
	var/power_charge = CLOCKCULT_POWER_UNIT //starts with CLOCKCULT_POWER_UNIT by default

/obj/effect/clockwork/sigil/transmission/ex_act(severity)
	if(severity == 3)
		modify_charge(-500)
		visible_message("<span class='warning'>[src] flares a brilliant orange!</span>")
	else
		..()

/obj/effect/clockwork/sigil/transmission/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='[power_charge ? "brass":"alloy"]'>It is storing <b>[ratvar_awakens ? "INFINITY":"[power_charge]"]W</b> of power.</span>"
		if(iscyborg(user))
			user << "<span class='brass'>You can recharge from the [sigil_name] by crossing it.</span>"

/obj/effect/clockwork/sigil/transmission/sigil_effects(mob/living/L)
	if(is_servant_of_ratvar(L))
		if(iscyborg(L))
			charge_cyborg(L)
	else if(power_charge)
		L << "<span class='brass'>You feel a slight, static shock.</span>"

/obj/effect/clockwork/sigil/transmission/proc/charge_cyborg(mob/living/silicon/robot/cyborg)
	if(!cyborg_checks(cyborg))
		return
	cyborg << "<span class='brass'>You start to charge from the [sigil_name]...</span>"
	if(!do_after(cyborg, 50, target = src))
		return
	if(!cyborg_checks(cyborg))
		return
	var/giving_power = min(Floor(cyborg.cell.maxcharge - cyborg.cell.charge, MIN_CLOCKCULT_POWER), power_charge) //give the borg either all our power or their missing power floored to MIN_CLOCKCULT_POWER
	if(modify_charge(giving_power))
		cyborg.visible_message("<span class='warning'>[cyborg] glows a brilliant orange!</span>")
		var/previous_color = cyborg.color
		cyborg.color = list("#EC8A2D", "#EC8A2D", "#EC8A2D", rgb(0,0,0))
		var/datum/status_effect/cyborg_power_regen/CPR = cyborg.apply_status_effect(STATUS_EFFECT_POWERREGEN)
		CPR.power_to_give = giving_power * 0.1 //ten ticks, restoring 10% each
		animate(cyborg, color = previous_color, time = 100)
		addtimer(CALLBACK(cyborg, /atom/proc/update_atom_colour), 100)

/obj/effect/clockwork/sigil/transmission/proc/cyborg_checks(mob/living/silicon/robot/cyborg)
	if(!cyborg.cell)
		cyborg << "<span class='warning'>You have no cell!</span>"
		return FALSE
	if(!power_charge)
		cyborg << "<span class='warning'>The [sigil_name] has no stored power!</span>"
		return FALSE
	if(cyborg.cell.charge > cyborg.cell.maxcharge - MIN_CLOCKCULT_POWER)
		cyborg << "<span class='warning'>You are already at maximum charge!</span>"
		return FALSE
	if(cyborg.has_status_effect(STATUS_EFFECT_POWERREGEN))
		cyborg << "<span class='warning'>You are already regenerating power!</span>"
		return FALSE
	return TRUE

/obj/effect/clockwork/sigil/transmission/New()
	..()
	update_glow()

/obj/effect/clockwork/sigil/transmission/proc/modify_charge(amount)
	if(ratvar_awakens)
		update_glow()
		return TRUE
	if(power_charge - amount < 0)
		return FALSE
	power_charge -= amount
	update_glow()
	return TRUE

/obj/effect/clockwork/sigil/transmission/proc/update_glow()
	if(ratvar_awakens)
		alpha = 255
	else
		alpha = min(initial(alpha) + power_charge*0.02, 255)
	if(!power_charge)
		SetLuminosity(0)
	else
		SetLuminosity(round(alpha*0.03, 1), round(alpha*0.02, 1))


//Vitality Matrix: Drains health from non-servants to heal or even revive servants.
/obj/effect/clockwork/sigil/vitality
	name = "comforting sigil"
	desc = "A faint blue sigil. Looking at it makes you feel protected."
	clockwork_desc = "A sigil that will drain non-Servants that remain on it. Servants that remain on it will be healed if it has any vitality drained."
	icon_state = "sigilvitality"
	color = "#123456"
	alpha = 75
	affects_servants = TRUE
	stat_affected = DEAD
	resist_string = "glows shimmering yellow"
	sigil_name = "Vitality Matrix"
	var/static/vitality = 0
	var/base_revive_cost = 20
	var/sigil_active = FALSE
	var/animation_number = 3 //each cycle increments this by 1, at 4 it produces an animation and resets
	var/static/list/damage_heal_order = list(CLONE, TOX, BURN, BRUTE, OXY) //we heal damage in this order

/obj/effect/clockwork/sigil/vitality/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='[vitality ? "inathneq_small":"alloy"]'>It has access to <b>[ratvar_awakens ? "INFINITE":"[vitality]"]</b> units of vitality.</span>"
		if(ratvar_awakens)
			user << "<span class='inathneq_small'>It can revive Servants at no cost!</span>"
		else
			user << "<span class='inathneq_small'>It can revive Servants at a cost of <b>[base_revive_cost]</b> vitality plus vitality equal to the non-oxygen damage they have, in addition to being destroyed in the process.</span>"

/obj/effect/clockwork/sigil/vitality/sigil_effects(mob/living/L)
	if((is_servant_of_ratvar(L) && L.suiciding) || sigil_active)
		return
	visible_message("<span class='warning'>[src] begins to glow bright blue!</span>")
	animate(src, alpha = 255, time = 10)
	addtimer(CALLBACK(src, .proc/update_alpha), 10)
	sleep(10)
//as long as they're still on the sigil and are either not a servant or they're a servant AND it has remaining vitality
	while(L && (!is_servant_of_ratvar(L) || (is_servant_of_ratvar(L) && (ratvar_awakens || vitality))) && get_turf(L) == get_turf(src))
		sigil_active = TRUE
		if(animation_number >= 4)
			new /obj/effect/overlay/temp/ratvar/sigil/vitality(get_turf(src))
			animation_number = 0
		animation_number++
		if(!is_servant_of_ratvar(L))
			var/vitality_drained = 0
			if(L.stat == DEAD)
				vitality_drained = L.maxHealth
				var/obj/effect/overlay/temp/ratvar/sigil/vitality/V = new /obj/effect/overlay/temp/ratvar/sigil/vitality(get_turf(src))
				animate(V, alpha = 0, transform = matrix()*2, time = 8)
				playsound(L, 'sound/magic/WandODeath.ogg', 50, 1)
				L.visible_message("<span class='warning'>[L] collapses in on [L.p_them()]self as [src] flares bright blue!</span>")
				L << "<span class='inathneq_large'>\"[text2ratvar("Your life will not be wasted.")]\"</span>"
				for(var/obj/item/W in L)
					if(!L.dropItemToGround(W))
						qdel(W)
				L.dust()
			else
				if(!ratvar_awakens && L.stat == CONSCIOUS)
					vitality_drained = L.adjustToxLoss(1)
				else
					vitality_drained = L.adjustToxLoss(1.5)
			if(vitality_drained)
				vitality += vitality_drained
			else
				break
		else
			if(L.stat == DEAD)
				var/revival_cost = base_revive_cost + L.getCloneLoss() + L.getToxLoss() + L.getFireLoss() + L.getBruteLoss() //ignores oxygen damage
				if(ratvar_awakens)
					revival_cost = 0
				var/mob/dead/observer/ghost = L.get_ghost(TRUE)
				if(vitality >= revival_cost && (ghost || (L.mind && L.mind.active)))
					if(ghost)
						ghost.reenter_corpse()
					L.revive(1, 1)
					var/obj/effect/overlay/temp/ratvar/sigil/vitality/V = new /obj/effect/overlay/temp/ratvar/sigil/vitality(get_turf(src))
					animate(V, alpha = 0, transform = matrix()*2, time = 8)
					playsound(L, 'sound/magic/Staff_Healing.ogg', 50, 1)
					L.visible_message("<span class='warning'>[L] suddenly gets back up, [ratvar_awakens ? "[L.p_their()] body dripping blue ichor":"even as [src] scatters into blue sparks around [L.p_them()]"]!</span>", \
					"<span class='inathneq'>\"[text2ratvar("You will be okay, child.")]\"</span>")
					vitality -= revival_cost
					if(!ratvar_awakens)
						qdel(src)
				break
			var/vitality_for_cycle = 3
			if(!ratvar_awakens)
				if(L.stat == CONSCIOUS)
					vitality_for_cycle = 2
				vitality_for_cycle = min(vitality, vitality_for_cycle)
			var/vitality_used = L.heal_ordered_damage(vitality_for_cycle, damage_heal_order)

			if(!vitality_used)
				break

			if(!ratvar_awakens)
				vitality -= vitality_used

		sleep(2)

	if(sigil_active)
		animation_number = initial(animation_number)
		sigil_active = FALSE
		visible_message("<span class='warning'>[src] slowly stops glowing!</span>")
	if(sigil_active || alpha == 255)
		animate(src, alpha = initial(alpha), time = 10)
		addtimer(CALLBACK(src, .proc/update_alpha), 10)

/obj/effect/clockwork/sigil/vitality/proc/update_alpha()
	if(sigil_active)
		alpha = 255
	else
		alpha = initial(alpha)
