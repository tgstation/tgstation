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
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	var/mob/living/user
	var/mob/living/target
	var/thrall_ability = FALSE

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
	if(!thrall_ability && !shadowling_check(user))
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
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
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
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
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


////////////////
////ENTHRALL////
////////////////

/obj/effect/proc_holder/spell/targeted/enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	panel = "Shadowling Abilities"
	charge_max = 0
	human_req = TRUE
	clothes_req = FALSE
	range = 1 //Adjacent to user
	action_icon_state = "enthrall"
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	var/enthralling = FALSE

/obj/effect/proc_holder/spell/targeted/enthrall/cast(list/targets,mob/living/carbon/human/user = usr)
	listclearnulls(SSticker.mode.thralls)
	if(!shadowling_check(user))
		revert_cast()
		return
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(user, target))
			to_chat(user, "<span class='warning'>You need to be closer to enthrall [target]!</span>")
			revert_cast()
			return
		if(!target.key || !target.mind)
			to_chat(user, "<span class='warning'>The target has no mind!</span>")
			revert_cast()
			return
		if(target.stat)
			to_chat(user, "<span class='warning'>The target must be conscious!</span>")
			revert_cast()
			return
		if(is_shadow_or_thrall(target))
			to_chat(user, "<span class='warning'>You can not enthrall allies!</span>")
			revert_cast()
			return
		if(!ishuman(target))
			to_chat(user, "<span class='warning'>You can only enthrall humans!</span>")
			revert_cast()
			return
		if(enthralling)
			to_chat(user, "<span class='warning'>You are already enthralling!</span>")
			revert_cast()
			return
		if(!target.client)
			to_chat(user, "<span class='warning'>[target]'s mind is vacant of activity.</span>")
		enthralling = TRUE

		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					to_chat(user, "<span class='notice'>You place your hands to [target]'s head...</span>")
					user.visible_message("<span class='warning'>[user] places their hands onto the sides of [target]'s head!</span>")
				if(2)
					to_chat(user, "<span class='notice'>You begin preparing [target]'s mind as a blank slate...</span>")
					user.visible_message("<span class='warning'>[user]'s palms flare a bright red against [target]'s temples!</span>")
					to_chat(target, "<span class='danger'>A terrible red light floods your mind. You collapse as conscious thought is wiped away.</span>")
					target.Knockdown(120)
					if(target.isloyal())
						to_chat(user, "<span class='notice'>They are protected by an implant. You begin to shut down the nanobots in their brain - this will take some time..</span>")
						user.visible_message("<span class='warning'>[user] pauses, then dips their head in concentration!</span>")
						to_chat(target, "<span class='boldannounce'>You feel your mental protection faltering</span>")
						if(!do_mob(user, target, 650)) //65 seconds to remove a loyalty implant. yikes!
							to_chat(user, "<span class='warning'>The enthralling has been interrupted - your target's mind returns to its previous state.</span>")
							to_chat(target, "<span class='userdanger'>You wrest yourself away from [user]'s hands and compose yourself</span>")
							enthralling = 0
							return
						to_chat(user, "<span class='notice'>The nanobots composing the mindshield implant have been rendered inert. Now to continue.</span>")
						user.visible_message("<span class='warning'>[user] relaxes again.</span>")
						for(var/obj/item/implant/mindshield/L in target)
							if(L)
								qdel(L)
						to_chat(target, "<span class='boldannounce'>Your mental protection unexpectedly falters, dims, dies.</span>")
				if(3)
					to_chat(user, "<span class='notice'>You begin planting the tumor that will control the new thrall...</span>")
					user.visible_message("<span class='warning'>A strange energy passes from [user]'s hands into [target]'s head!</span>")
					to_chat(target, "<span class='boldannounce'>You feel your memories twisting, morphing. A sense of horror dominates your mind.</span>")
			if(!do_mob(user, target, 70)) //around 21 seconds total for enthralling, 86 for someone with a loyalty implant
				to_chat(user, "<span class='warning'>The enthralling has been interrupted - your target's mind returns to its previous state.</span>")
				to_chat(target, "<span class='userdanger'>You wrest yourself away from [user]'s hands and compose yourself</span>")
				enthralling = FALSE
				return

		enthralling = FALSE
		to_chat(user, "<span class='shadowling'>You have enthralled <b>[target.real_name]</b>!</span>")
		target.visible_message("<span class='big'>[target] looks to have experienced a revelation!</span>", \
							   "<span class='warning'>False faces all d<b>ark not real not real not--</b></span>")
		target.setOxyLoss(0) //In case the shadowling was choking them out
		target.mind.special_role = "thrall"
		var/obj/item/organ/internal/shadowtumor/ST = new
		ST.Insert(target, FALSE, FALSE)
		add_thrall(target.mind)
		if(target.reagents.has_reagent("frostoil")) //Stabilize body temp incase the sling froze them earlier
			target.reagents.remove_reagent("frostoil")
			to_chat(target, "<span class='notice'>You feel warmer... it feels good.</span>")
			target.bodytemperature = 310




//////////////////////
////SLING HIVEMIND////
//////////////////////

/obj/effect/proc_holder/spell/shadowling_hivemind //Lets a shadowling talk to its allies
	name = "Hivemind Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Shadowling Abilities"
	charge_max = 0
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/shadowling_hivemind/cast(mob/living/user,mob/user = usr)
	if(!is_shadow(user))
		to_chat(user, "<span class='warning'>You must be a shadowling to do that!</span>")
		return
	var/text = stripped_input(user, "What do you want to say your thralls and fellow shadowlings?.", "Hive Chat", "")
	if(!text)
		return
	var/my_message = "<font size=2><span class='shadowling'><b>\[Shadowling\]</b><i> [user.real_name]</i>: [text]</span></font>"
	for(var/mob/M in GLOB.mob_list)
		if(is_shadow_or_thrall(M))
			to_chat(M, my_message)
		if(M in GLOB.dead_mob_list)
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [my_message]")
	log_say("[user.real_name]/[user.key] : [text]")


///////////////
////REHATCH////
///////////////

/obj/effect/proc_holder/spell/shadowling_regenarmor //Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor
	name = "Rapid Re-Hatch"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	panel = "Shadowling Abilities"
	charge_max = 600
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "regen_armor"

/obj/effect/proc_holder/spell/shadowling_regenarmor/cast(mob/living/carbon/human/user)
	if(!is_shadow(user))
		to_chat(user, "<span class='warning'>You must be a shadowling to do this!</span>")
		revert_cast()
		return
	user.visible_message("<span class='warning'>[user]'s skin suddenly bubbles and shifts around their body!</span>", \
						 "<span class='shadowling'>You regenerate your protective armor and cleanse your form of defects.</span>")
	user.setCloneLoss(0)
	user.set_species(/datum/species/shadow/ling)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(user), slot_head)




///////////////////////////
////COLLECTIVE HIVEMIND////
///////////////////////////

/obj/effect/proc_holder/spell/self/collective_mind //Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	panel = "Shadowling Abilities"
	charge_max = 300 //30 second cooldown to prevent spam
	human_req = TRUE
	clothes_req = FALSE
	action_icon_state = "collective_mind"
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	var/blind_smoke_acquired
	var/screech_acquired
	var/reviveThrallAcquired

/obj/effect/proc_holder/spell/self/collective_mind/cast(mob/living/carbon/human/user)
	if(!shadowling_check(user))
		revert_cast()
		return
	var/thralls = 0
	var/victory_threshold = SSticker.mode.required_thralls
	var/mob/M

	to_chat(user, "<span class='shadowling'><b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b></span>")

	for(var/_M in get_antagonists(ANTAG_DATUM_THRALL))
		var/mob/M = _M
		thralls++
		to_chat(M, "<span class='shadowling'>You feel hooks sink into your mind and pull.</span>")

	if(!do_after(user, 30, target = user))
		to_chat(user, "<span class='warning'>Your concentration has been broken. The mental hooks you have sent out now retract into your mind.</span>")
		return

	if(thralls >= CEILING(3*SSticker.mode.thrall_ratio) && !screech_acquired)
		screech_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms.</span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/unearthly_screech(null))

	if(thralls >= CEILING(5*SSticker.mode.thrall_ratio) && !blind_smoke_acquired)
		blind_smoke_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. It will create a choking cloud that will blind any non-thralls who enter. \
			</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/blindness_smoke(null))

	if(thralls >= CEILING(9*SSticker.mode.thrall_ratio) && !reviveThrallAcquired)
		reviveThrallAcquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. This will, after a short time, bring a dead thrall completely back to life \
		with no bodily defects.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/revive_thrall(null))

	if(thralls < victory_threshold)
		to_chat(user, "<span class='shadowling'>You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present.</span>")

	else if(thralls >= victory_threshold)
		to_chat(user, "<span class='shadowling'><b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i></span>")
		to_chat(user, "<span class='shadowling'><b>You may find Ascendance in the Shadowling Evolution tab.</b></span>")
		for(M in GLOB.alive_mob_list)
			if(is_shadow(M))
				var/obj/effect/proc_holder/spell/self/collective_mind/CM
				if(CM in M.mind.spell_list)
					M.mind.spell_list -= CM
					qdel(CM)
				M.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_hatch)
				M.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_ascend(null))
				if(M == user)
					to_chat(user, "<span class='shadowling'><i>You project this power to the rest of the shadowlings.</i></span>")
				else
					to_chat(M, "<span class='shadowling'><b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b></span>") //Tells all the other shadowlings



///////////////////
////BLIND SMOKE////
///////////////////

/obj/effect/proc_holder/spell/blindness_smoke //Spawns a cloud of smoke that blinds non-thralls/shadows and grants slight healing to shadowlings and their allies
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	charge_max = 600
	human_req = TRUE
	clothes_req = FALSE
	action_icon_state = "black_smoke"
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	sound = 'sound/effects/bamf.ogg'

/obj/effect/proc_holder/spell/blindness_smoke/cast(mob/living/carbon/human/user) //Extremely hacky
	if(!shadowling_check(user))
		revert_cast()
		return
	user.visible_message("<span class='warning'>[user] bends over and coughs out a cloud of black smoke!</span>")
	to_chat(user, "<span class='shadowling'>You regurgitate a vast cloud of blinding smoke.</span>")
	var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(user.loc) //hacky
	B.reagents.clear_reagents() //Just in case!
	B.invisibility = INFINITY //This ought to do the trick
	B.reagents.add_reagent("blindness_smoke", 10)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(B)
	if(S)
		S.set_up(B.reagents, 4, 0, B.loc)
		S.start()
	qdel(B)




/////////////////////
////SONIC SCREECH////
/////////////////////

/obj/effect/proc_holder/spell/unearthly_screech //Damages nearby windows, confuses nearby carbons, and outright stuns silly cones
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	panel = "Shadowling Abilities"
	charge_max = 300
	human_req = TRUE
	clothes_req = FALSE
	action_icon_state = "screech"
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	sound = 'sound/effects/screech.ogg'

/obj/effect/proc_holder/spell/unearthly_screech/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	user.audible_message("<span class='warning'><b>[user] lets out a horrible scream!</b></span>")
	for(var/turf/T in view(7, src))
		for(var/mob/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == user) //No message for the user, of course
					continue
				else
					continue
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				to_chat(M, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
				M.confused += 10
				M.adjustEarDamage(0, 30)//as bad as a changeling shriek
			else if(issilicon(target))
				var/mob/living/silicon/S = target
				to_chat(S, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
				sp.set_up(5, 1, S)
				sp.start()
				S.Knockdown(6)
		for(var/obj/structure/window/W in T.contents)
			W.take_damage(rand(80, 100))


/////////////////////
////SHUTTLE DELAY////
/////////////////////

/obj/effect/proc_holder/spell/targeted/shadowling_extend_shuttle
	name = "Destroy Engines"
	desc = "Extends the time of the emergency shuttle's arrival by fifteen minutes. This can only be used once."
	panel = "Shadowling Abilities"
	range = 1
	human_req = TRUE
	clothes_req = FALSE
	charge_max = 600
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "extend_shuttle"

/obj/effect/proc_holder/spell/targeted/shadowling_extend_shuttle/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	for(var/mob/living/carbon/human/target in targets)
		if(target.stat)
			revert_cast()
			return
		if(!is_thrall(target))
			to_chat(user, "<span class='warning'>[target] must be a thrall.</span>")
			revert_cast()
			return
		if(SSshuttle.emergency.mode != SHUTTLE_CALL)
			to_chat(user, "span class='warning'>The shuttle must be inbound only to the station.</span>")
			revert_cast()
			return
		var/mob/living/carbon/human/M = target
		user.visible_message("<span class='warning'>[user]'s eyes flash a bright red!</span>", \
						  "<span class='notice'>You begin to draw [M]'s life force.</span>")
		M.visible_message("<span class='warning'>[M]'s face falls slack, their jaw slightly distending.</span>", \
						  "<span class='boldannounce'>You are suddenly transported... far, far away...</span>")
		if(!do_after(user, 50, target = M))
			to_chat(M, "<span class='warning'>You are snapped back to reality, your haze dissipating!</span>")
			to_chat(user, "<span class='warning'>You have been interrupted. The draw has failed.</span>")
			return
		to_chat(user, "<span class='notice'>You project [M]'s life force toward the approaching shuttle, extending its arrival duration!</span>")
		M.visible_message("<span class='warning'>[M]'s eyes suddenly flare red. They proceed to collapse on the floor, not breathing.</span>", \
						  "<span class='warning'><b>...speeding by... ...pretty blue glow... ...touch it... ...no glow now... ...no light... ...nothing at all...</span>")
		M.death()
		if(SSshuttle.emergency.mode == SHUTTLE_CALL)
			var/timer = SSshuttle.emergency.timeLeft()
			timer += 9000
			priority_announce("Major system failure aboard the emergency shuttle. This will extend its arrival time by approximately 15 minutes...", "System Failure", 'sound/misc/notice1.ogg')
			SSshuttle.emergency.setTimer(timer)
		user.mind.spell_list.Remove(src) //Can only be used once!
		qdel(src)