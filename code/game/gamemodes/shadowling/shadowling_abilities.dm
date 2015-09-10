#define EMPOWERED_THRALL_LIMIT 5

/obj/effect/proc_holder/spell/proc/shadowling_check(var/mob/living/carbon/human/H)
	if(!H || !istype(H)) return
	if(H.dna.species.id == "shadowling" && is_shadow(H)) return 1
	if(H.dna.species.id == "l_shadowling" && is_thrall(H)) return 1
	if(!is_shadow_or_thrall(usr)) usr << "<span class='warning'>You can't wrap your head around how to do this.</span>"
	else if(is_thrall(usr)) usr << "<span class='warning'>You aren't powerful enough to do this.</span>"
	else if(is_shadow(usr)) usr << "<span class='warning'>Your telepathic ability is suppressed. Hatch or regenerate first.</span>"
	return 0


/obj/effect/proc_holder/spell/targeted/glare //Stuns and mutes a human target for 10 seconds
	name = "Glare"
	desc = "Stuns and mutes a target for a decent duration."
	panel = "Shadowling Abilities"
	charge_max = 300
	clothes_req = 0
	action_icon_state = "glare"

/obj/effect/proc_holder/spell/targeted/glare/cast(list/targets)
	for(var/mob/living/carbon/human/target in targets)
		if(!ishuman(target))
			charge_counter = charge_max
			return
		if(!shadowling_check(usr))
			charge_counter = charge_max
			return
		if(target.stat)
			charge_counter = charge_max
			return
		if(is_shadow_or_thrall(target))
			usr << "<span class='danger'>You don't see why you would want to paralyze an ally.</span>"
			charge_counter = charge_max
			return
		var/mob/living/carbon/human/M = target
		usr.visible_message("<span class='warning'><b>[usr]'s eyes flash a blinding red!</b></span>")
		target.visible_message("<span class='danger'>[target] freezes in place, their eyes glazing over...</span>")
		if(in_range(target, usr))
			target << "<span class='userdanger'>Your gaze is forcibly drawn into [usr]'s eyes, and you are mesmerized by the heavenly lights...</span>"
		else //Only alludes to the shadowling if the target is close by
			target << "<span class='userdanger'>Red lights suddenly dance in your vision, and you are mesmerized by their heavenly beauty...</span>"
		target.Stun(10)
		M.silent += 10


/obj/effect/proc_holder/spell/aoe_turf/veil //Puts out most nearby lights except for flares and yellow slime cores
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	panel = "Shadowling Abilities"
	charge_max = 250 //Short cooldown because people can just turn the lights back on
	clothes_req = 0
	range = 5
	action_icon_state = "veil"
	var/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime)

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
	I.SetLuminosity(0)
	return I.luminosity

/obj/effect/proc_holder/spell/aoe_turf/veil/proc/extinguishMob(mob/living/H)
	var/blacklistLuminosity = 0
	for(var/obj/item/F in H)
		blacklistLuminosity += extinguishItem(F)
	H.SetLuminosity(blacklistLuminosity) //I hate lightcode for making me do it this way

/obj/effect/proc_holder/spell/aoe_turf/veil/cast(list/targets)
	if(!shadowling_check(usr))
		charge_counter = charge_max
		return
	usr << "<span class='shadowling'>You silently disable all nearby lights.</span>"
	for(var/turf/T in targets)
		for(var/obj/item/F in T.contents)
			extinguishItem(F)
		for(var/obj/machinery/light/L in T.contents)
			L.on = 0
			L.visible_message("<span class='warning'>[L] flickers and falls dark.</span>")
			L.update(0)
		for(var/obj/machinery/computer/C in T.contents)
			C.SetLuminosity(0)
			C.visible_message("<span class='warning'>[C] grows dim, its screen barely readable.</span>")
		for(var/obj/effect/glowshroom/G in orange(2, usr)) //Very small radius
			G.visible_message("<span class='warning'>[G] withers away!</span>")
			qdel(G)
		for(var/mob/living/H in T.contents)
			extinguishMob(H)
		for(var/mob/living/silicon/robot/borgie in T.contents)
			borgie.update_headlamp(1)


/obj/effect/proc_holder/spell/targeted/shadow_walk //Grants the shadowling invisibility and phasing for 4 seconds
	name = "Shadow Walk"
	desc = "Phases you into the space between worlds for a short time, allowing movement through walls and invisbility."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "shadow_walk"
	sound = 'sound/effects/bamf.ogg'

/obj/effect/proc_holder/spell/targeted/shadow_walk/cast(list/targets)
	for(var/mob/living/user in targets)
		if(!shadowling_check(usr))
			charge_counter = charge_max
			return
		playMagSound()
		user.visible_message("<span class='warning'>[user] vanishes in a puff of black mist!</span>", "<span class='shadowling'>You enter the space between worlds as a tunnel.</span>")
		user.SetStunned(0)
		user.SetWeakened(0)
		user.incorporeal_move = 1
		user.alpha = 0
		if(user.buckled)
			user.buckled.unbuckle_mob()
		sleep(40) //4 seconds
		user.visible_message("<span class='warning'>[user] suddenly manifests!</span>", "<span class='shadowling'>The pressure becomes too much and you exit the rift.</span>")
		user.incorporeal_move = 0
		user.alpha = 255


/obj/effect/proc_holder/spell/aoe_turf/flashfreeze //Stuns and freezes nearby people - a bit more effective than a changeling's cryosting
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage."
	panel = "Shadowling Abilities"
	range = 5
	charge_max = 1200
	clothes_req = 0
	action_icon_state = "icy_veins"
	sound = 'sound/effects/ghost2.ogg'

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze/cast(list/targets)
	if(!shadowling_check(usr))
		charge_counter = charge_max
		return
	usr << "<span class='shadowling'>You freeze the nearby air.</span>"
	playMagSound()
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			if(is_shadow_or_thrall(M))
				if(M == usr) //No message for the user, of course
					continue
				else
					M << "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>"
					continue
			M << "<span class='userdanger'>A wave of shockingly cold air engulfs you!</span>"
			M.Stun(2)
			if(M.bodytemperature)
				M.bodytemperature -= 200 //Extreme amount of initial cold
			if(M.reagents)
				M.reagents.add_reagent("frostoil", 15) //Half of a cryosting


/obj/effect/proc_holder/spell/targeted/enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	panel = "Shadowling Abilities"
	charge_max = 0
	clothes_req = 0
	range = 1 //Adjacent to user
	action_icon_state = "enthrall"
	var/enthralling = 0

/obj/effect/proc_holder/spell/targeted/enthrall/cast(list/targets)
	var/mob/living/carbon/human/user = usr
	listclearnulls(ticker.mode.thralls)
	if(!(usr.mind in ticker.mode.shadows)) return
	if(user.dna.species.id != "shadowling")
		if(ticker.mode.thralls.len >= 5)
			user << "<span class='warning'>With your telepathic abilities suppressed, your human form will not allow you to enthrall any others. Hatch first.</span>"
			charge_counter = charge_max
			return
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(usr, target))
			usr << "<span class='warning'>You need to be closer to enthrall [target].</span>"
			charge_counter = charge_max
			return
		if(!target.key || !target.mind)
			usr << "<span class='warning'>The target has no mind.</span>"
			charge_counter = charge_max
			return
		if(target.stat)
			usr << "<span class='warning'>The target must be conscious.</span>"
			charge_counter = charge_max
			return
		if(is_shadow_or_thrall(target))
			usr << "<span class='warning'>You can not enthrall allies.</span>"
			charge_counter = charge_max
			return
		if(!ishuman(target))
			usr << "<span class='warning'>You can only enthrall humans.</span>"
			charge_counter = charge_max
			return
		if(enthralling)
			usr << "<span class='warning'>You are already enthralling!</span>"
			charge_counter = charge_max
			return
		if(!target.client)
			usr << "<span class='warning'>[target]'s mind is vacant of activity.</span>"
		enthralling = 1
		usr << "<span class='danger'>This target is valid. You begin the enthralling.</span>"
		target << "<span class='userdanger'>[usr] stares at you. You feel your head begin to pulse.</span>"

		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					usr << "<span class='notice'>You begin allocating energy for the enthralling.</span>"
					usr.visible_message("<span class='warning'>[usr]'s eyes begin to throb a piercing red.</span>")
				if(2)
					usr << "<span class='notice'>You begin the enthralling of [target].</span>"
					usr.visible_message("<span class='danger'>[usr] leans over [target], their eyes glowing a deep crimson, and stares into their face.</span>")
					target << "<span class='boldannounce'>Your gaze is forcibly drawn into a blinding red light. You fall to the floor as conscious thought is wiped away.</span>"
					target.Weaken(12)
					sleep(20)
					if(isloyal(target))
						usr << "<span class='notice'>They are enslaved by Nanotrasen. You begin to shut down the nanobot implant - this will take some time.</span>"
						usr.visible_message("<span class='danger'>[usr] halts for a moment, then begins passing its hand over [target]'s body.</span>")
						target << "<span class='boldannounce'>You feel your loyalties begin to weaken!</span>"
						sleep(150) //15 seconds - not spawn() so the enthralling takes longer
						usr << "<span class='notice'>The nanobots composing the loyalty implant have been rendered inert. Now to continue.</span>"
						usr.visible_message("<span class='danger'>[usr] halts thier hand and resumes staring into [target]'s face.</span>")
						for(var/obj/item/weapon/implant/loyalty/L in target)
							if(L && L.implanted)
								qdel(L)
								target << "<span class='boldannounce'>Your unwavering loyalty to Nanotrasen unexpectedly falters, dims, dies.</span>"
				if(3)
					usr << "<span class='notice'>You begin rearranging [target]'s memories.</span>"
					usr.visible_message("<span class='danger'>[usr]'s eyes flare brightly.</span>")
					target << "<span class='boldannounce'>Your head cries out. The veil of reality begins to crumple and something evil bleeds through.</span>" //Ow the edge
			if(!do_mob(usr, target, 100)) //around 30 seconds total for enthralling, 45 for someone with a loyalty implant
				usr << "<span class='warning'>The enthralling has been interrupted - your target's mind returns to its previous state.</span>"
				target << "<span class='userdanger'>A spike of pain drives into your head, wiping your memory. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>"
				enthralling = 0
				return

		enthralling = 0
		usr << "<span class='shadowling'>You have enthralled <b>[target]</b>!</span>"
		target.visible_message("<span class='big'>[target] looks to have experienced a revelation!</span>", \
							   "<span class='warning'>False faces all d<b>ark not real not real not--</b></span>")
		target.setOxyLoss(0) //In case the shadowling was choking them out
		ticker.mode.add_thrall(target.mind)
		target.mind.special_role = "thrall"


/obj/effect/proc_holder/spell/targeted/shadowling_hivemind //Lets a shadowling talk to its allies
	name = "Hivemind Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Shadowling Abilities"
	charge_max = 0
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/targeted/shadowling_hivemind/cast(list/targets)
	for(var/mob/living/user in targets)
		if(!is_shadow(user))
			user << "<span class='warning'><b>As you attempt to commune with the others, an agonizing spike of pain drives itself into your head!</b></span>"
			user.apply_damage(10, BRUTE, "head")
			return
		var/text = stripped_input(user, "What do you want to say your thralls and fellow shadowlings?.", "Hive Chat", "")
		if(!text)
			return
		for(var/mob/M in mob_list)
			if(is_shadow_or_thrall(M) || (M in dead_mob_list))
				M << "<span class='shadowling'><b>\[Shadowling\]</b><i> [usr.real_name]</i>: [text]</span>"


/obj/effect/proc_holder/spell/targeted/shadowling_regenarmor //Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor
	name = "Regenerate Chitin"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "regen_armor"

/obj/effect/proc_holder/spell/targeted/shadowling_regenarmor/cast(list/targets)
	for(var/mob/living/user in targets)
		user.visible_message("<span class='warning'>[user]'s skin suddenly bubbles and shifts around their body!</span>", \
							 "<span class='shadowling'>You regenerate your protective armor and cleanse your form of defects.</span>")
		user.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(usr), slot_w_uniform)
		user.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(usr), slot_shoes)
		user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(usr), slot_wear_suit)
		user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(usr), slot_head)
		user.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(usr), slot_gloves)
		user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(usr), slot_wear_mask)
		user.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/shadowling(usr), slot_glasses)
		hardset_dna(user, null, null, null, null, /datum/species/shadow/ling)


/obj/effect/proc_holder/spell/targeted/collective_mind //Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	panel = "Shadowling Abilities"
	charge_max = 300 //30 second cooldown to prevent spam
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "collective_mind"
	var/blind_smoke_acquired
	var/screech_acquired
	var/drainLifeAcquired
	var/reviveThrallAcquired

/obj/effect/proc_holder/spell/targeted/collective_mind/cast(list/targets)
	for(var/mob/living/user in targets)
		if(!shadowling_check(usr))
			charge_counter = charge_max
			return
		var/thralls = 0
		var/victory_threshold = 15
		var/mob/M

		user << "<span class='shadowling'><b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b></span>"

		for(M in living_mob_list)
			if(is_thrall(M))
				thralls++
				M << "<span class='shadowling'>You feel hooks sink into your mind and pull.</span>"

		if(!do_after(user, 30, target = user))
			user << "<span class='warning'>Your concentration has been broken. The mental hooks you have sent out now retract into your mind.</span>"
			return

		if(thralls >= 3 && !blind_smoke_acquired)
			blind_smoke_acquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. It will create a choking cloud that will blind any non-thralls who enter. \
			</i></span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/blindness_smoke

		if(thralls >= 5 && !drainLifeAcquired)
			drainLifeAcquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Drain Life</b> ability. You can now drain the health of nearby humans to heal yourself.</i></span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/drain_life

		if(thralls >= 7 && !screech_acquired)
			screech_acquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms.</span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/unearthly_screech

		if(thralls >= 9 && !reviveThrallAcquired)
			reviveThrallAcquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. This will, after a short time, bring a dead thrall completely back to life \
			with no bodily defects.</i></span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/revive_thrall

		if(thralls < victory_threshold)
			user << "<span class='shadowling'>You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present.</span>"

		else if(thralls >= victory_threshold)
			usr << "<span class='shadowling'><b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i></span>"
			usr << "<span class='shadowling'><b>You may find Ascendance in the Shadowling Evolution tab.</b></span>"
			for(M in living_mob_list)
				if(is_shadow(M))
					var/obj/effect/proc_holder/spell/targeted/collective_mind/CM
					if(CM in M.mind.spell_list)
						M.mind.spell_list -= CM
						qdel(CM)
					M.mind.remove_spell(/obj/effect/proc_holder/spell/targeted/shadowling_hatch)
					M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_ascend(null))
					if(M == usr)
						M << "<span class='shadowling'><i>You project this power to the rest of the shadowlings.</i></span>"
					else
						M << "<span class='shadowling'><b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b></span>" //Tells all the other shadowlings


/obj/effect/proc_holder/spell/targeted/blindness_smoke //Spawns a cloud of smoke that blinds non-thralls/shadows and grants slight healing to shadowlings and their allies
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "black_smoke"
	sound = 'sound/effects/bamf.ogg'

/obj/effect/proc_holder/spell/targeted/blindness_smoke/cast(list/targets) //Extremely hacky
	for(var/mob/living/user in targets)
		if(!shadowling_check(usr))
			charge_counter = charge_max
			return
		playMagSound()
		user.visible_message("<span class='warning'>[user] bends over and coughs out a cloud of black smoke!</span>")
		user << "<span class='shadowling'>You regurgitate a vast cloud of blinding smoke.</span>"
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B = new /obj/item/weapon/reagent_containers/glass/beaker/large(user.loc) //hacky
		B.reagents.clear_reagents() //Just in case!
		B.icon_state = null //Invisible
		B.reagents.add_reagent("blindness_smoke", 10)
		var/datum/effect/effect/system/smoke_spread/chem/S = new
		S.attach(B)
		if(S)
			S.set_up(B.reagents, 10, 0, B.loc)
			S.start()
			sleep(10)
			S.start()
		qdel(B)

datum/reagent/shadowling_blindness_smoke //Reagent used for above spell
	name = "odd black liquid"
	id = "blindness_smoke"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 100 //lel

/datum/reagent/shadowling_blindness_smoke/on_mob_life(mob/living/M)
	if(!M) M = holder.my_atom
	if(!is_shadow_or_thrall(M))
		M << "<span class='warning'><b>You breathe in the black smoke, and your eyes burn horribly!</b></span>"
		M.eye_blind = 5
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at their eyes!")
			M.Stun(3)
	else
		M << "<span class='notice'><b>You breathe in the black smoke, and you feel revitalized!</b></span>"
		M.heal_organ_damage(2,2)
		M.adjustOxyLoss(-2)
		M.adjustToxLoss(-2)
	..()
	return


/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech //Damages nearby windows, confuses nearby carbons, and outright stuns silly cones
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	panel = "Shadowling Abilities"
	range = 7
	charge_max = 300
	clothes_req = 0
	action_icon_state = "screech"
	sound = 'sound/effects/screech.ogg'

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech/cast(list/targets)
	if(!shadowling_check(usr))
		charge_counter = charge_max
		return
	usr.audible_message("<span class='warning'><b>[usr] lets out a horrible scream!</b></span>")
	playMagSound()
	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == usr) //No message for the user, of course
					continue
				else
					continue
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				M << "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>"
				M.confused += 10
				M.setEarDamage(M.ear_damage + 3)
			else if(issilicon(target))
				var/mob/living/silicon/S = target
				S << "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>"
				S << 'sound/misc/interference.ogg'
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				var/datum/effect/effect/system/spark_spread/sp = new /datum/effect/effect/system/spark_spread
				sp.set_up(5, 1, S)
				sp.start()
				S.Weaken(6)
		for(var/obj/structure/window/W in T.contents)
			W.hit(rand(80, 100))


/obj/effect/proc_holder/spell/aoe_turf/drain_life //Deals stamina and oxygen damage to nearby humans and heals the shadowling. On a short cooldown because of the small range and situational usefulness
	name = "Drain Life"
	desc = "Damages nearby humans, draining their life and healing your own wounds."
	panel = "Shadowling Abilities"
	range = 3
	charge_max = 100
	clothes_req = 0
	action_icon_state = "drain_life"
	var/targetsDrained
	var/list/nearbyTargets

/obj/effect/proc_holder/spell/aoe_turf/drain_life/cast(list/targets, mob/living/carbon/human/U = usr)
	if(!shadowling_check(usr))
		charge_counter = charge_max
		return
	targetsDrained = 0
	nearbyTargets = list()
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			if(M == src) continue
			targetsDrained++
			nearbyTargets.Add(M)
	if(!targetsDrained)
		charge_counter = charge_max
		usr << "<span class='warning'>There were no nearby humans for you to drain.</span>"
		return
	for(var/mob/living/carbon/M in nearbyTargets)
		U.heal_organ_damage(10, 10)
		U.adjustToxLoss(-10)
		U.adjustOxyLoss(-10)
		U.adjustStaminaLoss(-20)
		U.AdjustWeakened(-1)
		U.AdjustStunned(-1)
		M.adjustOxyLoss(20)
		M.adjustStaminaLoss(20)
		M << "<span class='boldannounce'>You feel a wave of exhaustion and a curious draining sensation directed towards [usr]!</span>"
	usr << "<span class='shadowling'>You draw life from those around you to heal your wounds.</span>"


/obj/effect/proc_holder/spell/targeted/revive_thrall //Completely revives a dead thrall
	name = "Black Recuperation"
	desc = "Revives or empowers a thrall."
	panel = "Shadowling Abilities"
	range = 1
	charge_max = 600
	clothes_req = 0
	include_user = 0
	action_icon_state = "revive_thrall"

/obj/effect/proc_holder/spell/targeted/revive_thrall/cast(list/targets)
	if(!shadowling_check(usr))
		charge_counter = charge_max
		return
	for(var/mob/living/carbon/human/thrallToRevive in targets)
		var/choice = alert(usr,"Empower a living thrall or revive a dead one?",,"Empower","Revive","Cancel")
		switch(choice)
			if("Empower")
				if(!is_thrall(thrallToRevive))
					usr << "<span class='warning'>[thrallToRevive] is not a thrall.</span>"
					charge_counter = charge_max
					return
				if(thrallToRevive.stat != CONSCIOUS)
					usr << "<span class='warning'>[thrallToRevive] must be conscious to become empowered.</span>"
					charge_counter = charge_max
					return
				var/empowered_thralls = 0
				for(var/datum/mind/M in ticker.mode.thralls)
					if(!ishuman(M.current))
						return
					var/mob/living/carbon/human/H = M.current
					if(H.dna.species.id == "l_shadowling")
						empowered_thralls++
				if(empowered_thralls >= EMPOWERED_THRALL_LIMIT)
					usr << "<span class='warning'>You cannot spare this much energy. There are too many empowered thralls.</span>"
					charge_counter = charge_max
					return
				usr.visible_message("<span class='danger'>[usr] places their hands over [thrallToRevive]'s face, red light shining from beneath.</span>", \
									"<span class='shadowling'>You place your hands on [thrallToRevive]'s face and begin gathering energy...</span>")
				thrallToRevive << "<span class='userdanger'>[usr] places their hands over your face. You feel energy gathering. Stand still...</span>"
				if(!do_mob(usr, thrallToRevive, 80))
					usr << "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>"
					charge_counter = charge_max
					return
				usr << "<span class='shadowling'><b><i>You release a massive surge of power into [thrallToRevive]!</b></i></span>"
				usr.visible_message("<span class='boldannounce'><i>Red lightning surges into [thrallToRevive]'s face!</i></span>")
				playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', 50, 1)
				playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
				usr.Beam(thrallToRevive,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
				thrallToRevive.Weaken(5)
				thrallToRevive.visible_message("<span class='warning'><b>[thrallToRevive] collapses, their skin and face distorting!</span>", \
											   "<span class='userdanger'><i>AAAAAAAAAAAAAAAAAAAGH-</i></span>")
				sleep(20)
				thrallToRevive.visible_message("<span class='warning'>[thrallToRevive] slowly rises, no longer recognizable as human.</span>", \
											   "<span class='shadowling'><b>You feel new power flow into you. You have been gifted by your masters. You now closely resemble them. You are empowered in \
											    darkness but wither slowly in light. In addition, Lesser Glare and Guise have been upgraded into their true forms.</b></span>")
				hardset_dna(thrallToRevive, null, null, null, null, /datum/species/shadow/ling/lesser)
				thrallToRevive.mind.remove_spell(/obj/effect/proc_holder/spell/targeted/lesser_glare)
				thrallToRevive.mind.remove_spell(/obj/effect/proc_holder/spell/targeted/lesser_shadow_walk)
				thrallToRevive.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/glare(null))
				thrallToRevive.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadow_walk(null))
			if("Revive")
				if(!is_thrall(thrallToRevive))
					usr << "<span class='warning'>[thrallToRevive] is not a thrall.</span>"
					charge_counter = charge_max
					return
				if(thrallToRevive.stat != DEAD)
					usr << "<span class='warning'>[thrallToRevive] is not dead.</span>"
					charge_counter = charge_max
					return
				usr.visible_message("<span class='danger'>[usr] kneels over [thrallToRevive], placing their hands on \his chest.</span>", \
									"<span class='shadowling'>You crouch over the body of your thrall and begin gathering energy...</span>")
				thrallToRevive.notify_ghost_cloning("Your masters are resuscitating you! Re-enter your corpse if you wish to be brought to life.")
				if(!do_mob(usr, thrallToRevive, 30))
					usr << "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>"
					charge_counter = charge_max
					return
				usr << "<span class='shadowling'><b><i>You release a massive surge of power into [thrallToRevive]!</b></i></span>"
				usr.visible_message("<span class='boldannounce'><i>Red lightning surges from [usr]'s hands into [thrallToRevive]'s chest!</i></span>")
				playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', 50, 1)
				playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
				usr.Beam(thrallToRevive,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
				sleep(10)
				thrallToRevive.revive()
				thrallToRevive.visible_message("<span class='boldannounce'>[thrallToRevive] heaves in breath, dim red light shining in their eyes.</span>", \
											   "<span class='shadowling'><b><i>You have returned. One of your masters has brought you from the darkness beyond.</b></i></span>")
				thrallToRevive.Weaken(4)
				thrallToRevive.emote("gasp")
				playsound(thrallToRevive, "bodyfall", 50, 1)
			else
				charge_counter = charge_max
				return


// THRALL ABILITIES BEYOND THIS POINT //


/obj/effect/proc_holder/spell/targeted/lesser_glare //Thrall version of Glare - same effects but for 3 seconds
	name = "Lesser Glare"
	desc = "Stuns and mutes a target for a short duration."
	panel = "Thrall Abilities"
	charge_max = 450
	clothes_req = 0
	action_icon_state = "glare"

/obj/effect/proc_holder/spell/targeted/lesser_glare/cast(list/targets)
	for(var/mob/living/carbon/human/target in targets)
		if(!ishuman(target) || !target)
			charge_counter = charge_max
			return
		if(target.stat)
			charge_counter = charge_max
			return
		if(is_shadow_or_thrall(target))
			usr << "<span class='danger'>You don't see why you would want to paralyze an ally.</span>"
			charge_counter = charge_max
			return
		var/mob/living/carbon/human/M = target
		usr.visible_message("<span class='warning'><b>[usr]'s eyes flash a bright red!</b></span>")
		target.visible_message("<span class='danger'>[target] freezes in place, their eyes clouding...</span>")
		if(in_range(target, usr))
			target << "<span class='userdanger'>Your gaze is forcibly drawn into [usr]'s eyes, and you are starstruck by the heavenly lights...</span>"
		else //Only alludes to the shadowling if the target is close by
			target << "<span class='userdanger'>Red lights suddenly dance in your vision, and you are starstruck by their heavenly beauty...</span>"
		target.Stun(3) //Roughly 30% as long as the normal one
		M.silent += 3


/obj/effect/proc_holder/spell/targeted/lesser_shadow_walk //Thrall version of Shadow Walk, only works in darkness, doesn't grant phasing, but gives near-invisibility
	name = "Guise"
	desc = "Wraps your form in shadows, making you harder to see."
	panel = "Thrall Abilities"
	charge_max = 1200
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/targeted/lesser_shadow_walk/cast(list/targets)
	for(var/mob/living/user in targets)
		user.visible_message("<span class='warning'>[user] suddenly fades away!</span>", "<span class='shadowling'>You veil yourself in darkness, making you harder to see.</span>")
		user.alpha = 10
		sleep(40)
		user.visible_message("<span class='warning'>[user] appears from nowhere!</span>", "<span class='shadowling'>Your shadowy guise slips away.</span>")
		user.alpha = initial(user.alpha)


/obj/effect/proc_holder/spell/targeted/thrall_vision //Toggleable night vision for thralls
	name = "Darksight"
	desc = "Gives you night vision."
	panel = "Thrall Abilities"
	charge_max = 0
	range = -1
	include_user = 1
	clothes_req = 0
	action_icon_state = "darksight"
	var/active = 0

/obj/effect/proc_holder/spell/targeted/thrall_vision/cast(list/targets)
	for(var/mob/living/user in targets)
		if(!istype(user) || !ishuman(user)) return
		var/mob/living/carbon/human/H = user
		active = !active
		if(active)
			user << "<span class='notice'>You shift the nerves in your eyes, allowing you to see in the dark.</span>"
			H.see_in_dark = 8
			H.dna.species.invis_sight = SEE_INVISIBLE_MINIMUM
		else
			user << "<span class='notice'>You return your vision to normal.</span>"
			H.see_in_dark = 0
			H.dna.species.invis_sight = initial(H.dna.species.invis_sight)


/obj/effect/proc_holder/spell/targeted/lesser_shadowling_hivemind //Lets a thrall talk with their allies
	name = "Lesser Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Thrall Abilities"
	charge_max = 50
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/targeted/lesser_shadowling_hivemind/cast(list/targets)
	for(var/mob/living/user in targets)
		if(!is_shadow_or_thrall(user))
			user << "<span class='warning'><b>As you attempt to commune with the others, an agonizing spike of pain drives itself into your head!</b></span>"
			user.apply_damage(10, BRUTE, "head")
			return
		var/text = stripped_input(user, "What do you want to say your masters and fellow thralls?.", "Lesser Commune", "")
		if(!text)
			return
		for(var/mob/M in mob_list)
			if(is_shadow_or_thrall(M) || (M in dead_mob_list))
				M << "<span class='shadowling'><b>\[Thrall\]</b><i> [usr.real_name]</i>: [text]</span>"


// ASCENDANT ABILITIES BEYOND THIS POINT //


/obj/effect/proc_holder/spell/targeted/annihilate //Gibs someone instantly.
	name = "Annihilate"
	desc = "Gibs someone instantly."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = 0
	action_icon_state = "annihilate"
	sound = 'sound/magic/Staff_Chaos.ogg'

/obj/effect/proc_holder/spell/targeted/annihilate/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		usr << "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>"
		charge_counter = charge_max
		return

	for(var/mob/living/boom in targets)
		if(is_shadow_or_thrall(boom))
			usr << "<span class='warning'>Making an ally explode seems unwise.<span>"
			charge_counter = charge_max
			return
		usr.visible_message("<span class='danger'>[usr]'s markings flare as they gesture at [boom]!</span>", \
							"<span class='shadowling'>You direct a lance of telekinetic energy into [boom].</span>")
		playMagSound()
		sleep(4)
		if(iscarbon(boom))
			playsound(boom, 'sound/magic/Disintegrate.ogg', 100, 1)
		boom.visible_message("<span class='userdanger'>[boom] explodes!</span>")
		boom.gib()


/obj/effect/proc_holder/spell/targeted/hypnosis //Enthralls someone instantly. Nonlethal alternative to Annihilate
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = 0
	action_icon_state = "enthrall"

/obj/effect/proc_holder/spell/targeted/hypnosis/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		charge_counter = charge_max
		usr << "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>"
		return

	for(var/mob/living/carbon/human/target in targets)
		if(is_shadow_or_thrall(target))
			usr << "<span class='warning'>You cannot enthrall an ally.<span>"
			charge_counter = charge_max
			return
		if(!target.ckey || !target.mind)
			usr << "<span class='warning'>The target has no mind.</span>"
			charge_counter = charge_max
			return
		if(target.stat)
			usr << "<span class='warning'>The target must be conscious.</span>"
			charge_counter = charge_max
			return
		if(!ishuman(target))
			usr << "<span class='warning'>You can only enthrall humans.</span>"
			charge_counter = charge_max
			return

		usr << "<span class='shadowling'>You instantly rearrange <b>[target]</b>'s memories, hyptonitizing them into a thrall.</span>"
		target << "<span class='userdanger'><font size=3>An agonizing spike of pain drives into your mind, and--</font></span>"
		ticker.mode.add_thrall(target.mind)
		target.mind.special_role = "thrall"
		var/datum/mind/thrall_mind = target.mind
		thrall_mind.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind


/obj/effect/proc_holder/spell/targeted/shadowling_phase_shift //Permanent version of shadow walk with no drawback. Toggleable.
	name = "Phase Shift"
	desc = "Phases you into the space between worlds at will, allowing you to move through walls and become invisible."
	panel = "Ascendant"
	range = -1
	include_user = 1
	charge_max = 15
	clothes_req = 0
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/targeted/shadowling_phase_shift/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	for(SHA in targets)
		SHA.phasing = !SHA.phasing
		if(SHA.phasing)
			SHA.visible_message("<span class='danger'>[SHA] suddenly vanishes!</span>", \
			"<span class='shadowling'>You begin phasing through planes of existence. Use the ability again to return.</span>")
			SHA.incorporeal_move = 1
			SHA.alpha = 0
		else
			SHA.visible_message("<span class='danger'>[SHA] suddenly appears from nowhere!</span>", \
			"<span class='shadowling'>You return from the space between worlds.</span>")
			SHA.incorporeal_move = 0
			SHA.alpha = 255


/obj/effect/proc_holder/spell/aoe_turf/ascendant_storm //Releases bolts of lightning to everyone nearby
	name = "Lightning Storm"
	desc = "Shocks everyone nearby."
	panel = "Ascendant"
	range = 6
	charge_max = 100
	clothes_req = 0
	action_icon_state = "lightning_storm"
	sound = 'sound/magic/lightningbolt.ogg'

/obj/effect/proc_holder/spell/aoe_turf/ascendant_storm/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		usr << "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>"
		charge_counter = charge_max
		return
	playMagSound()
	usr.visible_message("<span class='warning'><b>A massive ball of lightning appears in [usr]'s hands and flares out!</b></span>", \
						"<span class='shadowling'>You conjure a ball of lightning and release it.</span>")

	for(var/turf/T in targets)
		for(var/mob/living/carbon/human/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == usr) //No message for the user, of course
					continue
			target << "<span class='userdanger'>You are struck by a bolt of lightning!</span>"
			playsound(target, 'sound/magic/LightningShock.ogg', 50, 1)
			target.Weaken(8)
			target.take_organ_damage(0,50)
			usr.Beam(target,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)


/obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant //Large, all-caps text in shadowling chat
	name = "Ascendant Commune"
	desc = "Allows you to LOUDLY communicate with all other shadowlings and thralls."
	panel = "Ascendant"
	charge_max = 0
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = stripped_input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", "")
		if(!text)
			return
		text = "<font size=4>[text]</font>"
		for(var/mob/M in mob_list)
			if(is_shadow_or_thrall(M) || (M in dead_mob_list))
				M << "<span class='shadowling'><b>\[Ascendant\]<i> [usr.real_name]</i>: [text]</b></span>" //Bigger text for ascendants.


/obj/effect/proc_holder/spell/targeted/ascendant_transmit //Sends a message to the entire world. If this gets abused too much it can be removed safely
	name = "Ascendant Broadcast"
	desc = "Sends a message to the whole wide world."
	panel = "Ascendant"
	charge_max = 200
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "transmit"

/obj/effect/proc_holder/spell/targeted/ascendant_transmit/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = stripped_input(user, "What do you want to say to everything on and near [station_name()]?.", "Transmit to World", "")
		if(!text)
			return
		world << "<font size=4><span class='shadowling'><b>\"[text]\"</font></span>"
