#define EMPOWERED_THRALL_LIMIT 5

/obj/effect/proc_holder/spell/proc/shadowling_check(var/mob/living/carbon/human/H)
	if(!H || !istype(H)) return
	if(H.dna.species.id == "shadowling" && is_shadow(H)) return 1
	if(H.dna.species.id == "l_shadowling" && is_thrall(H)) return 1
	if(!is_shadow_or_thrall(usr)) to_chat(usr, "<span class='warning'>You can't wrap your head around how to do this.</span>")
	else if(is_thrall(usr)) to_chat(usr, "<span class='warning'>You aren't powerful enough to do this.</span>")
	else if(is_shadow(usr)) to_chat(usr, "<span class='warning'>Your telepathic ability is suppressed. Hatch or use Rapid Re-Hatch first.</span>")
	return 0




/obj/effect/proc_holder/spell/targeted/sling //Stuns and mutes a human target for 10 seconds
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
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
	if(!ishuman(t))
		to_chat(caller, "<span class='warning'>You may only use this ability on humans!</span>")
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

/obj/effect/proc_holder/spell/targeted/sling/glare //Stuns and mutes a human target for 10 seconds
	name = "Glare"
	desc = "Disrupts the target's motor and speech abilities."
	panel = "Shadowling Abilities"
	charge_max = 300
	human_req = 1
	clothes_req = 0
	action_icon_state = "glare"
	action_icon = 'hippiestation/icons/mob/actions.dmi'


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
		var/loss = 100 - ((distance - 1) * 15)
		target.adjustStaminaLoss(loss)
		target.stuttering = loss
		to_chat(target, "<span class='userdanger'>A purple light flashes across your vision, and exhaustion floods your body...</span>")
		target.visible_message("<span class='danger'>[target] looks very tired...</span>")
	charge_counter = 0
	start_recharge()
	remove_ranged_ability()


/obj/effect/proc_holder/spell/aoe_turf/veil //Puts out most nearby lights except for flares and yellow slime cores
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	panel = "Shadowling Abilities"
	charge_max = 150 //Short cooldown because people can just turn the lights back on
	human_req = 1
	clothes_req = 0
	range = 5
	action_icon_state = "veil"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	var/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime)
	var/admin_override = 0 //Requested by Shadowlight213. Allows anyone to cast the spell, not just shadowlings.

/obj/effect/proc_holder/spell/aoe_turf/veil/proc/extinguishItem(obj/item/I) //Does not darken items held by mobs due to mobs having separate luminosity, use extinguishMob() or write your own proc.
	if(istype(I, /obj/item/device/flashlight))
		var/obj/item/device/flashlight/F = I
		if(F.on)
			if(is_type_in_list(I, blacklisted_lights))
				I.visible_message("<span class='danger'>[I] dims slightly before scattering the shadows around it.</span>")
				return F.brightness_on //Necessary because flashlights become 0-luminosity when held.  I don't make the rules of lightcode.
			F.on = 0
			F.update_brightness()
	else if(istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/P = I
		P.fon = 0
	I.set_light(0)
	return I.luminosity

/obj/effect/proc_holder/spell/aoe_turf/veil/proc/extinguishMob(mob/living/H)
	var/blacklistLuminosity = 0
	for(var/obj/item/F in H)
		blacklistLuminosity += extinguishItem(F)
	H.set_light(blacklistLuminosity) //I hate lightcode for making me do it this way


/obj/effect/proc_holder/spell/aoe_turf/veil/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user) && !admin_override)
		revert_cast()
		return
	to_chat(user, "<span class='shadowling'>You silently disable all nearby lights.</span>")
	for(var/turf/T in view(5))
		for(var/obj/item/F in T.contents)
			extinguishItem(F)
		for(var/obj/machinery/light/L in T.contents)
			L.on = 0
			L.visible_message("<span class='warning'>[L] flickers and falls dark.</span>")
			L.update(0)
		for(var/obj/machinery/computer/C in T.contents)
			C.set_light(0)
			C.visible_message("<span class='warning'>[C] grows dim, its screen barely readable.</span>")
		for(var/obj/structure/glowshroom/G in orange(7, user)) //High radius because glowshroom spam wrecks shadowlings
			G.visible_message("<span class='warning'>[G] withers away!</span>")
			qdel(G)
		for(var/mob/living/H in T.contents)
			extinguishMob(H)
		for(var/mob/living/silicon/robot/borgie in T.contents)
			borgie.update_headlamp(TRUE, 150)
			borgie.lamp_intensity = 0
		for(var/obj/machinery/camera/cam in T.contents)
			cam.set_light(0)
			if(prob(10))
				cam.emp_act(2)

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze //Stuns and freezes nearby people - a bit more effective than a changeling's cryosting
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage."
	panel = "Shadowling Abilities"
	range = 3
	charge_max = 250
	human_req = 1
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "icy_veins"
	sound = 'sound/effects/ghost2.ogg'

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	to_chat(user, "<span class='shadowling'>You freeze the nearby air.</span>")
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			if(is_shadow_or_thrall(M))
				if(M == user) //No message for the user, of course
					continue
				else
					to_chat(M, "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>")
					continue
			to_chat(M, "<span class='userdanger'>A wave of shockingly cold air engulfs you!</span>")
			M.Stun(2)
			M.apply_damage(10, BURN)
			if(M.bodytemperature)
				M.bodytemperature -= 200 //Extreme amount of initial cold
			if(M.reagents)
				M.reagents.add_reagent("frostoil", 15) //Half of a cryosting




/obj/effect/proc_holder/spell/targeted/enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	panel = "Shadowling Abilities"
	charge_max = 0
	human_req = 1
	clothes_req = 0
	range = 1 //Adjacent to user
	action_icon_state = "enthrall"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	var/enthralling = 0

/obj/effect/proc_holder/spell/targeted/enthrall/cast(list/targets,mob/living/carbon/human/user = usr)
	listclearnulls(SSticker.mode.thralls)
	if(!(user.mind in SSticker.mode.shadows)) return
	if(user.dna.species.id != "shadowling")
		if(SSticker.mode.thralls.len >= 5)
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
		enthralling = 1

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
				enthralling = 0
				return

		enthralling = 0
		to_chat(user, "<span class='shadowling'>You have enthralled <b>[target.real_name]</b>!</span>")
		target.visible_message("<span class='big'>[target] looks to have experienced a revelation!</span>", \
							   "<span class='warning'>False faces all d<b>ark not real not real not--</b></span>")
		target.setOxyLoss(0) //In case the shadowling was choking them out
		target.mind.special_role = "thrall"
		SSticker.mode.add_thrall(target.mind)
		if(target.reagents.has_reagent("frostoil")) //Stabilize body temp incase the sling froze them earlier
			target.reagents.remove_reagent("frostoil", 100)
			to_chat(target, "<span class='notice'>You feel warmer... it feels good.</span>")
			target.bodytemperature = 310


/obj/effect/proc_holder/spell/self/shadowling_hivemind //Lets a shadowling talk to its allies
	name = "Hivemind Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Shadowling Abilities"
	charge_max = 0
	human_req = 1
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/self/shadowling_hivemind/cast(mob/living/user,mob/user = usr)
	if(!is_shadow(user))
		to_chat(user, "<span class='warning'>You must be a shadowling to do that!</span>")
		return
	var/text = stripped_input(user, "What do you want to say your thralls and fellow shadowlings?.", "Hive Chat", "")
	if(!text)
		return
	var/my_message = "<span class='shadowling'><b>\[Shadowling\]</b><i> [user.real_name]</i>: [text]</span>"
	for(var/mob/M in GLOB.mob_list)
		if(is_shadow_or_thrall(M))
			to_chat(M, my_message)
		if(M in GLOB.dead_mob_list)
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [my_message]")
	log_say("[user.real_name]/[user.key] : [text]")



/obj/effect/proc_holder/spell/self/shadowling_regenarmor //Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor
	name = "Rapid Re-Hatch"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	panel = "Shadowling Abilities"
	charge_max = 600
	human_req = 1
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "regen_armor"

/obj/effect/proc_holder/spell/self/shadowling_regenarmor/cast(mob/living/carbon/human/user)
	if(!is_shadow(user))
		to_chat(user, "<span class='warning'>You must be a shadowling to do this!</span>")
		revert_cast()
		return
	user.visible_message("<span class='warning'>[user]'s skin suddenly bubbles and shifts around their body!</span>", \
						 "<span class='shadowling'>You regenerate your protective armor and cleanse your form of defects.</span>")
	user.adjustCloneLoss(user.getCloneLoss())
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(user), slot_head)
	user.set_species(/datum/species/shadow/ling)


/obj/effect/proc_holder/spell/self/collective_mind //Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	panel = "Shadowling Abilities"
	charge_max = 300 //30 second cooldown to prevent spam
	human_req = 1
	clothes_req = 0
	action_icon_state = "collective_mind"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
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

	for(M in GLOB.living_mob_list)
		if(is_thrall(M))
			thralls++
			to_chat(M, "<span class='shadowling'>You feel hooks sink into your mind and pull.</span>")

	if(!do_after(user, 30, target = user))
		to_chat(user, "<span class='warning'>Your concentration has been broken. The mental hooks you have sent out now retract into your mind.</span>")
		return

	if(thralls >= 3 && !screech_acquired)
		screech_acquired = 1
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms.</span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/unearthly_screech(null))

	if(thralls >= 5 && !blind_smoke_acquired)
		blind_smoke_acquired = 1
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. It will create a choking cloud that will blind any non-thralls who enter. \
			</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/self/blindness_smoke(null))

	if(thralls >= 9 && !reviveThrallAcquired)
		reviveThrallAcquired = 1
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. This will, after a short time, bring a dead thrall completely back to life \
		with no bodily defects.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/revive_thrall(null))

	if(thralls < victory_threshold)
		to_chat(user, "<span class='shadowling'>You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present.</span>")

	else if(thralls >= victory_threshold)
		to_chat(user, "<span class='shadowling'><b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i></span>")
		to_chat(user, "<span class='shadowling'><b>You may find Ascendance in the Shadowling Evolution tab.</b></span>")
		for(M in GLOB.living_mob_list)
			if(is_shadow(M))
				var/obj/effect/proc_holder/spell/self/collective_mind/CM
				if(CM in M.mind.spell_list)
					M.mind.spell_list -= CM
					qdel(CM)
				M.mind.RemoveSpell(/obj/effect/proc_holder/spell/self/shadowling_hatch)
				M.mind.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_ascend(null))
				if(M == user)
					to_chat(user, "<span class='shadowling'><i>You project this power to the rest of the shadowlings.</i></span>")
				else
					to_chat(M, "<span class='shadowling'><b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b></span>") //Tells all the other shadowlings


/obj/effect/proc_holder/spell/self/blindness_smoke //Spawns a cloud of smoke that blinds non-thralls/shadows and grants slight healing to shadowlings and their allies
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	charge_max = 600
	human_req = 1
	clothes_req = 0
	action_icon_state = "black_smoke"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	sound = 'sound/effects/bamf.ogg'

/obj/effect/proc_holder/spell/self/blindness_smoke/cast(mob/living/carbon/human/user) //Extremely hacky
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

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech //Damages nearby windows, confuses nearby carbons, and outright stuns silly cones
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	panel = "Shadowling Abilities"
	range = 7
	charge_max = 300
	human_req = 1
	clothes_req = 0
	action_icon_state = "screech"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	sound = 'sound/effects/screech.ogg'

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	user.audible_message("<span class='warning'><b>[user] lets out a horrible scream!</b></span>")
	for(var/turf/T in targets)
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

/obj/effect/proc_holder/spell/targeted/revive_thrall //Completely revives a dead thrall
	name = "Black Recuperation"
	desc = "Revives or empowers a thrall."
	panel = "Shadowling Abilities"
	range = 1
	charge_max = 600
	human_req = 1
	clothes_req = 0
	include_user = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "revive_thrall"

/obj/effect/proc_holder/spell/targeted/revive_thrall/cast(list/targets,mob/user = usr)
	if(!shadowling_check(user))
		revert_cast()
		return
	for(var/mob/living/carbon/human/thrallToRevive in targets)
		var/choice = alert(user,"Empower a living thrall or revive a dead one?",,"Empower","Revive","Cancel")
		switch(choice)
			if("Empower")
				if(!is_thrall(thrallToRevive))
					to_chat(user, "<span class='warning'>[thrallToRevive] is not a thrall.</span>")
					revert_cast()
					return
				if(thrallToRevive.stat != CONSCIOUS)
					to_chat(user, "<span class='warning'>[thrallToRevive] must be conscious to become empowered.</span>")
					revert_cast()
					return
				if(thrallToRevive.dna.species.id == "l_shadowling")
					to_chat(user, "<span class='warning'>[thrallToRevive] is already empowered.</span>")
					revert_cast()
					return
				var/empowered_thralls = 0
				for(var/datum/mind/M in SSticker.mode.thralls)
					if(!ishuman(M.current))
						return
					var/mob/living/carbon/human/H = M.current
					if(H.dna.species.id == "l_shadowling")
						empowered_thralls++
				if(empowered_thralls >= EMPOWERED_THRALL_LIMIT)
					to_chat(user, "<span class='warning'>You cannot spare this much energy. There are too many empowered thralls.</span>")
					revert_cast()
					return
				user.visible_message("<span class='danger'>[user] places their hands over [thrallToRevive]'s face, red light shining from beneath.</span>", \
									"<span class='shadowling'>You place your hands on [thrallToRevive]'s face and begin gathering energy...</span>")
				to_chat(thrallToRevive, "<span class='userdanger'>[user] places their hands over your face. You feel energy gathering. Stand still...</span>")
				if(!do_mob(user, thrallToRevive, 80))
					to_chat(user, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
					revert_cast()
					return
				to_chat(user, "<span class='shadowling'><b><i>You release a massive surge of power into [thrallToRevive]!</b></i></span>")
				user.visible_message("<span class='boldannounce'><i>Red lightning surges into [thrallToRevive]'s face!</i></span>")
				playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', 50, 1)
				playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
				user.Beam(thrallToRevive,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
				thrallToRevive.Knockdown(5)
				thrallToRevive.visible_message("<span class='warning'><b>[thrallToRevive] collapses, their skin and face distorting!</span>", \
											   "<span class='userdanger'><i>AAAAAAAAAAAAAAAAAAAGH-</i></span>")
				if (!do_mob(user, thrallToRevive, 5))
					thrallToRevive.Unconscious(600)
					thrallToRevive.visible_message("<span class='warning'><b>[thrallToRevive] gasps, and passes out!</b></span>", "<span class='warning'><i>That... feels nice....</i></span>")
					to_chat(user, "<span class='warning'>We have been interrupted! [thrallToRevive] will need to rest to recover.</span>")
					return
				thrallToRevive.visible_message("<span class='warning'>[thrallToRevive] slowly rises, no longer recognizable as human.</span>", \
											   "<span class='shadowling'><b>You feel new power flow into you. You have been gifted by your masters. You now closely resemble them. You are empowered in \
											    darkness but wither slowly in light. In addition, Lesser Glare and Guise have been upgraded into their true forms.</b></span>")
				thrallToRevive.set_species(/datum/species/shadow/ling/lesser)
				thrallToRevive.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/lesser_glare)
				thrallToRevive.mind.RemoveSpell(/obj/effect/proc_holder/spell/self/lesser_shadow_walk)
				thrallToRevive.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/sling/glare(null))
			if("Revive")
				if(!is_thrall(thrallToRevive))
					to_chat(user, "<span class='warning'>[thrallToRevive] is not a thrall.</span>")
					revert_cast()
					return
				if(thrallToRevive.stat != DEAD)
					to_chat(user, "<span class='warning'>[thrallToRevive] is not dead.</span>")
					revert_cast()
					return
				user.visible_message("<span class='danger'>[user] kneels over [thrallToRevive], placing their hands on \his chest.</span>", \
									"<span class='shadowling'>You crouch over the body of your thrall and begin gathering energy...</span>")
				thrallToRevive.notify_ghost_cloning("Your masters are resuscitating you! Re-enter your corpse if you wish to be brought to life.", source = thrallToRevive)
				if(!do_mob(user, thrallToRevive, 30))
					to_chat(user, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
					revert_cast()
					return
				to_chat(user, "<span class='shadowling'><b><i>You release a massive surge of power into [thrallToRevive]!</b></i></span>")
				user.visible_message("<span class='boldannounce'><i>Red lightning surges from [user]'s hands into [thrallToRevive]'s chest!</i></span>")
				playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', 50, 1)
				playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
				user.Beam(thrallToRevive,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
				var/b = do_mob(user, thrallToRevive, 20)
				if(thrallToRevive.revive(full_heal = 1))
					thrallToRevive.visible_message("<span class='boldannounce'>[thrallToRevive] heaves in breath, dim red light shining in their eyes.</span>", \
											   "<span class='shadowling'><b><i>You have returned. One of your masters has brought you from the darkness beyond.</b></i></span>")
					thrallToRevive.Knockdown(4)
					thrallToRevive.emote("gasp")
					playsound(thrallToRevive, "bodyfall", 50, 1)
					if (!b)
						thrallToRevive.Knockdown(50)
						thrallToRevive.Unconscious(500)
						thrallToRevive.visible_message("<span class='boldannounce'>[thrallToRevive] collapses in exhaustion.</span>", \
						   "<span class='warning'><b><i>You collapse in exhaustion... nap..... dark.</b></i></span>")
			else
				revert_cast()
				return


/obj/effect/proc_holder/spell/targeted/shadowling_extend_shuttle
	name = "Destroy Engines"
	desc = "Extends the time of the emergency shuttle's arrival by fifteen minutes. This can only be used once."
	panel = "Shadowling Abilities"
	range = 1
	human_req = 1
	clothes_req = 0
	charge_max = 600
	action_icon = 'hippiestation/icons/mob/actions.dmi'
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
			var/more_minutes = 9000
			var/timer = SSshuttle.emergency.timeLeft()
			timer += more_minutes
			priority_announce("Major system failure aboard the emergency shuttle. This will extend its arrival time by approximately 15 minutes...", "System Failure", 'sound/misc/notice1.ogg')
			SSshuttle.emergency.setTimer(timer)
		user.mind.spell_list.Remove(src) //Can only be used once!
		qdel(src)


// THRALL ABILITIES BEYOND THIS POINT //


/obj/effect/proc_holder/spell/targeted/lesser_glare //a defensive ability, nothing else. can't be used to stun people, steal tasers, etc. Just good for escaping
	name = "Lesser Glare"
	desc = "Makes a single target dizzy for a bit."
	panel = "Thrall Abilities"
	charge_max = 450
	human_req = 1
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "glare"

/obj/effect/proc_holder/spell/targeted/lesser_glare/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		if(!ishuman(target) || !target)
			to_chat(user, "<span class='warning'>You nay only glare at humans!</span>")
			revert_cast()
			return
		if(target.stat)
			to_chat(user, "<span class='warning'>[target] must be conscious!</span>")
			revert_cast()
			return
		if(is_shadow_or_thrall(target))
			to_chat(user, "<span class='warning'>You cannot glare at allies!</span>")
			revert_cast()
			return
		var/mob/living/carbon/human/M = target
		user.visible_message("<span class='warning'><b>[user]'s eyes flash a bright red!</b></span>")
		target.visible_message("<span class='danger'>[target] suddendly looks dizzy and nauseous...</span>")
		if(in_range(target, user))
			to_chat(target, "<span class='userdanger'>Your gaze is forcibly drawn into [user]'s eyes, and you suddendly feel dizzy and nauseous...</span>")
		else //Only alludes to the thrall if the target is close by
			to_chat(target, "<span class='userdanger'>Red lights suddenly dance in your vision, and you suddendly feel dizzy and nauseous...</span>")
		M.confused += 25
		M.Jitter(50)
		if(prob(25))
			M.vomit(10)



/obj/effect/proc_holder/spell/self/lesser_shadow_walk //Thrall version of Shadow Walk, only works in darkness, doesn't grant phasing, but gives near-invisibility
	name = "Guise"
	desc = "Wraps your form in shadows, making you harder to see."
	panel = "Thrall Abilities"
	charge_max = 1200
	human_req = 1
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	clothes_req = 0
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/self/lesser_shadow_walk/proc/reappear(mob/living/carbon/human/user)
	user.visible_message("<span class='warning'>[user] appears from nowhere!</span>", "<span class='shadowling'>Your shadowy guise slips away.</span>")
	user.alpha = initial(user.alpha)

/obj/effect/proc_holder/spell/self/lesser_shadow_walk/cast(mob/living/carbon/human/user)
	user.visible_message("<span class='warning'>[user] suddenly fades away!</span>", "<span class='shadowling'>You veil yourself in darkness, making you harder to see.</span>")
	user.alpha = 10
	addtimer(CALLBACK(src, .proc/reappear, user), 40)



/obj/effect/proc_holder/spell/targeted/night_vision/thrall //Toggleable night vision for thralls
	name = "Thrall Darksight"
	desc = "Allows you to see in the dark!"
	action_icon_state = "darksight"
	action_icon = 'hippiestation/icons/mob/actions.dmi'

/obj/effect/proc_holder/spell/self/lesser_shadowling_hivemind //Lets a thrall talk with their allies
	name = "Lesser Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Thrall Abilities"
	charge_max = 50
	human_req = 1
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/self/lesser_shadowling_hivemind/cast(mob/living/carbon/human/user)
	if(!is_shadow_or_thrall(user))
		to_chat(user, "<span class='warning'><b>As you attempt to commune with the others, an agonizing spike of pain drives itself into your head!</b></span>")
		user.apply_damage(10, BRUTE, "head")
		return
	var/text = stripped_input(user, "What do you want to say your masters and fellow thralls?.", "Lesser Commune", "")
	if(!text)
		return
	text = "<span class='shadowling'><b>\[Thrall\]</b><i> [user.real_name]</i>: [text]</span>"
	for(var/mob/M in GLOB.mob_list)
		if(is_shadow_or_thrall(M))
			to_chat(M, text)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [text]")
	log_say("[user.real_name]/[user.key] : [text]")


// ASCENDANT ABILITIES BEYOND THIS POINT //
// YES THEY'RE OP, BUT THEY'VE WON AT THE POINT WHERE THEY HAVE THIS, SO WHATEVER. //


/obj/effect/proc_holder/spell/targeted/sling/annihilate //Gibs someone instantly.
	name = "Annihilate"
	desc = "Gibs someone instantly."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = 0
	action_icon_state = "annihilate"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	sound = 'sound/magic/Staff_Chaos.ogg'

/obj/effect/proc_holder/spell/targeted/sling/annihilate/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	var/mob/living/boom = target
	if(user.incorporeal_move)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast()
		return
	if(is_shadow(boom)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
		to_chat(user, "<span class='warning'>Making an ally explode seems unwise.<span>")
		revert_cast()
		return
	if(istype(boom, /mob/living/simple_animal/pet/dog/corgi))
		to_chat(user, "<span class='warning'>Not even we are that bad of monsters..<span>")
		revert_cast()
		return
	if (!boom.is_holding(/obj/item/storage/backpack/holding)) //so people actually have a chance to kill ascended slings without being insta-sploded
		user.visible_message("<span class='warning'>[user]'s markings flare as they gesture at [boom]!</span>", \
							"<span class='shadowling'>You direct a lance of telekinetic energy into [boom].</span>")
		if(iscarbon(boom))
			playsound(boom, 'sound/magic/Disintegrate.ogg', 100, 1)
		boom.visible_message("<span class='userdanger'>[boom] explodes!</span>")
		boom.gib()
	else
		to_chat(user, "<span class='warning'>The telekinetic energy is absorbed by the bluespace portal in [boom]'s hand!<span>")
		to_chat(boom, "<span class='userdanger'>You feel a slight recoil from the bag of holding!<span>")

/obj/effect/proc_holder/spell/targeted/sling/hypnosis //Enthralls someone instantly. Nonlethal alternative to Annihilate
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "enthrall"

/obj/effect/proc_holder/spell/targeted/sling/hypnosis/InterceptClickOn(mob/living/caller, params, atom/t)
	if(user.incorporeal_move)
		revert_cast()
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		return

	if(is_shadow_or_thrall(target))
		to_chat(user, "<span class='warning'>You cannot enthrall an ally.<span>")
		revert_cast()
		return
	if(!target.ckey || !target.mind)
		to_chat(user, "<span class='warning'>The target has no mind.</span>")
		revert_cast()
		return
	if(target.stat)
		to_chat(user, "<span class='warning'>The target must be conscious.</span>")
		revert_cast()
		return
	if(!ishuman(target))
		to_chat(user, "<span class='warning'>You can only enthrall humans.</span>")
		revert_cast()
		return
	to_chat(user, "<span class='shadowling'>You instantly rearrange <b>[target]</b>'s memories, hyptonitizing them into a thrall.</span>")
	to_chat(target, "<span class='userdanger'><font size=3>An agonizing spike of pain drives into your mind, and--</font></span>")
	target.mind.special_role = "thrall"
	SSticker.mode.add_thrall(target.mind)


/obj/effect/proc_holder/spell/self/shadowling_phase_shift //Permanent version of shadow walk with no drawback. Toggleable.
	name = "Phase Shift"
	desc = "Phases you into the space between worlds at will, allowing you to move through walls and become invisible."
	panel = "Ascendant"
	charge_max = 15
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/self/shadowling_phase_shift/cast(mob/living/simple_animal/ascendant_shadowling/user)
	user.incorporeal_move = !user.incorporeal_move
	if(user.incorporeal_move)
		user.visible_message("<span class='danger'>[user] suddenly vanishes!</span>", \
		"<span class='shadowling'>You begin phasing through planes of existence. Use the ability again to return.</span>")
		user.density = 0
		user.alpha = 0
	else
		user.visible_message("<span class='danger'>[user] suddenly appears from nowhere!</span>", \
		"<span class='shadowling'>You return from the space between worlds.</span>")
		user.density = 1
		user.alpha = 255


/obj/effect/proc_holder/spell/aoe_turf/ascendant_storm //Releases bolts of lightning to everyone nearby
	name = "Lightning Storm"
	desc = "Shocks everyone nearby."
	panel = "Ascendant"
	range = 6
	charge_max = 100
	clothes_req = 0
	action_icon_state = "lightning_storm"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	sound = 'sound/magic/lightningbolt.ogg'

/obj/effect/proc_holder/spell/aoe_turf/ascendant_storm/cast(list/targets,mob/living/simple_animal/ascendant_shadowling/user = usr)
	if(user.incorporeal_move)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast()
		return
	user.visible_message("<span class='warning'><b>A massive ball of lightning appears in [user]'s hands and flares out!</b></span>", \
						"<span class='shadowling'>You conjure a ball of lightning and release it.</span>")

	for(var/turf/T in targets)
		for(var/mob/living/carbon/human/target in T.contents)
			if(is_shadow_or_thrall(target))
				continue
			to_chat(target, "<span class='userdanger'>You are struck by a bolt of lightning!</span>")
			playsound(target, 'sound/magic/LightningShock.ogg', 50, 1)
			target.Knockdown(8)
			user.Beam(target,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)


/obj/effect/proc_holder/spell/self/shadowling_hivemind_ascendant //Large, all-caps text in shadowling chat
	name = "Ascendant Commune"
	desc = "Allows you to LOUDLY communicate with all other shadowlings and thralls."
	panel = "Ascendant"
	charge_max = 0
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/self/shadowling_hivemind_ascendant/cast(mob/living/carbon/human/user)
	var/text = stripped_input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", "")
	if(!text)
		return
	text = "<font size=4><span class='shadowling'><b>\[Ascendant\]<i> [user.real_name]</i>: [text]</b></span></font>"
	for(var/mob/M in GLOB.mob_list)
		if(is_shadow_or_thrall(M))
			to_chat(M, text)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [text]")
	log_say("[user.real_name]/[user.key] : [text]")
