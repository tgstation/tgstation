//im lazy so i'll do this
#define SLING_ACTIONS_DMI 'icons/mob/actions/actions_shadowling.dmi'



/proc/shadowling_check(var/mob/living/carbon/human/H)
	if(!H || !istype(H)) return
	if(H.dna.species.id == "shadowling" && is_shadow(H)) return TRUE
	if(H.dna.species.id == "l_shadowling" && is_thrall(H)) return TRUE
	if(!is_shadow_or_thrall(H)) to_chat(usr, "<span class='warning'>You can't wrap your head around how to do this.</span>")
	else if(is_thrall(H)) to_chat(H, "<span class='warning'>You aren't powerful enough to do this.</span>")
	else if(is_shadow(H)) to_chat(H, "<span class='warning'>Your telepathic ability is suppressed. Hatch or use Rapid Re-Hatch first.</span>")
	return FALSE




/obj/effect/proc_holder/spell/targeted/sling //Stuns and mutes a human target for 10 seconds
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
	action_icon = SLING_ACTIONS_DMI
	var/mob/living/user
	var/mob/living/target

/obj/effect/proc_holder/spell/targeted/sling/Click()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/msg
	if(!can_cast(user))
		msg = "<span class='warning'>You can no longer cast [name]!</span>"
		remove_ranged_ability(msg)
		return
	if(active)
		remove_ranged_ability()
	else
		add_ranged_ability(user, null, TRUE)

	if(action)
		action.UpdateButtonIcon()


/obj/effect/proc_holder/spell/targeted/sling/InterceptClickOn(mob/living/caller, params, atom/t)
	if(!isliving(t))
		to_chat(caller, "<span class='warning'>You may only use this ability on living things!</span>")
		revert_cast()
		return
	user = caller
	target = t
	if(!shadowling_check(user))
		revert_cast()
		return

/obj/effect/proc_holder/spell/targeted/sling/revert_cast()
	. = ..()
	remove_ranged_ability()

/obj/effect/proc_holder/spell/targeted/sling/start_recharge()
	. = ..()
	if(action)
		action.UpdateButtonIcon()



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////now that the initial types are out of the way, we can get to the abilities!//////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////GLARE
/obj/effect/proc_holder/spell/targeted/sling/glare //Stuns and mutes a human target for 10 seconds
	name = "Glare"
	desc = "Disrupts the target's motor and speech abilities."
	panel = "Shadowling Abilities"
	charge_max = 300
	human_req = 1
	clothes_req = 0
	action_icon_state = "glare"


/obj/effect/proc_holder/spell/targeted/sling/glare/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	if(target.stat)
		to_chat(user, "<span class='warning'>[target] must be conscious!</span>")
		revert_cast()
		return
	if(is_shadow_or_thrall(target))
		to_chat(user, "<span class='warning'>You cannot glare at allies!</span>")
		revert_cast()
		return
	var/mob/living/carbon/human/M = target
	user.visible_message("<span class='warning'><b>[user]'s eyes flash a purpleish-red!</b></span>")
	var/distance = get_dist(target, user)
	if (distance <= 1) //Melee
		target.visible_message("<span class='danger'>[target] suddendly collapses...</span>")
		to_chat(target, "<span class='userdanger'>A purple light flashes across your vision, and you lose control of your movements!</span>")
		target.Stun(100)
		M.silent += 10
	else //Distant glare
		var/loss = 100 - ((distance - 1) * 18)
		target.adjustStaminaLoss(loss)
		target.stuttering = loss
		to_chat(target, "<span class='userdanger'>A purple light flashes across your vision, and exhaustion floods your body...</span>")
		target.visible_message("<span class='danger'>[target] looks very tired...</span>")
	charge_counter = 0
	start_recharge()
	remove_ranged_ability()
	user = null
	target = null


////////////
////VEIL////
////////////

/obj/effect/proc_holder/spell/veil //Puts out most nearby lights except for flares and yellow slime cores
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	panel = "Shadowling Abilities"
	charge_max = 150 //Short cooldown because people can just turn the lights back on
	human_req = TRUE
	clothes_req = FALSE
	action_icon_state = "veil"
	action_icon = SLING_ACTIONS_DMI
	var/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime)
	var/admin_override = FALSE //Requested by Shadowlight213. Allows anyone to cast the spell, not just shadowlings.

/obj/effect/proc_holder/spell/veil/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user) && !admin_override)
		revert_cast()
		return
	to_chat(user, "<span class='shadowling'>You silently disable all nearby lights.</span>")
	var/list/in_view = view(6, user)
	for(var/turf/T in in_view)
		for(var/obj/F in T.contents)
			F.disable_lights()
		for(var/mob/living/H in T.contents)
			for(var/obj/item/F in H)
				F.disable_lights()
		for(var/obj/machinery/camera/cam in T.contents)
			cam.set_light(0)
			if(prob(10))
				cam.emp_act(2)
		for(var/mob/living/silicon/robot/borg in T.contents)
			if(!borg.lamp_cooldown)
				borg.update_headlamp(TRUE, INFINITY)
				to_chat(borg, "<span class='danger'>Your headlamp is fried! You'll need a human to help replace it.</span>")
	for(var/obj/structure/glowshroom/G in view(7, user)) //High radius because glowshroom spam wrecks shadowlings
		G.visible_message("<span class='warning'>[G] withers away!</span>")
		qdel(G)

////////////////////
////FLASH FREEZE////
////////////////////
/obj/effect/proc_holder/spell/flashfreeze //Stuns and freezes nearby people - a bit more effective than a changeling's cryosting. but doesn't last nearly as long
	name = "Flash Freeze"
	desc = "Instantly freezes the blood of nearby people, stunning them for a short moment and causing burn damage."
	panel = "Shadowling Abilities"
	charge_max = 550
	human_req = TRUE
	clothes_req = FALSE
	action_icon = SLING_ACTIONS_DMI
	action_icon_state = "icy_veins"
	sound = 'sound/effects/ghost2.ogg'

/obj/effect/proc_holder/spell/flashfreeze/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	to_chat(user, "<span class='shadowling'>You freeze the nearby air.</span>")
	for(var/mob/living/carbon/M in view(3, src))
		if(is_shadow_or_thrall(M))
			if(M == user) //No message for the user, of course
				continue
			else
				to_chat(M, "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>")
				continue
		to_chat(M, "<span class='userdanger'>A wave of shockingly cold air engulfs you!</span>")
		M.Stun(5)
		M.apply_damage(10, BURN)
		if(M.bodytemperature)
			M.bodytemperature -= 200 //Extreme amount of initial cold
		if(M.reagents)
			M.reagents.add_reagent("frostoil", 10)