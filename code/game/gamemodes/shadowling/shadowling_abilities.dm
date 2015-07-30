/obj/effect/proc_holder/spell/targeted/glare
	name = "Glare"
	desc = "Stuns and mutes a target for a decent duration."
	panel = "Shadowling Abilities"
	charge_max = 300
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/glare/cast(list/targets)
	for(var/mob/living/carbon/human/target in targets)
		if(!ishuman(target))
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



/obj/effect/proc_holder/spell/aoe_turf/veil
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	panel = "Shadowling Abilities"
	charge_max = 250 //Short cooldown because people can just turn the lights back on
	clothes_req = 0
	range = 5
	var/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime)

/obj/effect/proc_holder/spell/aoe_turf/veil/proc/extinguishItem(obj/item/I) //WARNING NOT SUFFICIENT TO EXTINGUISH AN ITEM HELD BY A MOB
	if(istype(I, /obj/item/device/flashlight))
		var/obj/item/device/flashlight/F = I
		if(F.on)
			if(is_type_in_list(I, blacklisted_lights))
				I.visible_message("<span class='danger'>[I] dims slightly, before the shadows around it scatter.</span>")
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
	usr << "<span class='shadowling'>You silently disable all nearby lights.</span>"
	for(var/turf/T in targets)
		for(var/obj/item/F in T.contents)
			extinguishItem(F)
		for(var/obj/machinery/light/L in T.contents)
			L.on = 0
			L.visible_message("<span class='danger'>[L] flickers and falls dark.</span>")
			L.update(0)
		for(var/obj/machinery/computer/C in T.contents)
			C.SetLuminosity(0)
			C.visible_message("<span class='danger'>[C] grows dim, its screen barely readable.</span>")
		for(var/obj/effect/glowshroom/G in orange(2, usr)) //Very small radius
			G.visible_message("<span class='warning'>\The [G] withers away!</span>")
			qdel(G)
		for(var/mob/living/H in T.contents)
			extinguishMob(H)
		for(var/mob/living/silicon/robot/borgie in T.contents)
			borgie.update_headlamp(1, charge_max) //Shut down a borg's lamp for the entire cooldown of the ability! Plenty of time to escape or beat it to death.


/obj/effect/proc_holder/spell/targeted/shadow_walk
	name = "Shadow Walk"
	desc = "Phases you into the space between worlds for a short time, allowing movement through walls and invisbility."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadow_walk/cast(list/targets)
	for(var/mob/living/user in targets)
		playsound(user.loc, 'sound/effects/bamf.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] vanishes in a puff of black mist!</span>", "<span class='shadowling'>You enter the space between worlds as a passageway.</span>")
		user.SetStunned(0)
		user.SetWeakened(0)
		user.incorporeal_move = 1
		user.alpha = 0
		if(user.buckled)
			user.buckled.unbuckle_mob()
		sleep(40) //4 seconds
		user.visible_message("<span class='warning'>[user] suddenly manifests!</span>", "<span class='shadowling'>The pressure becomes too much and you vacate the interdimensional darkness.</span>")
		user.incorporeal_move = 0
		user.alpha = 255



/obj/effect/proc_holder/spell/aoe_turf/flashfreeze
	name = "Flash Freeze"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage."
	panel = "Shadowling Abilities"
	range = 5
	charge_max = 1200
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze/cast(list/targets)
	usr << "<span class='shadowling'>You freeze the nearby air.</span>"
	playsound(usr.loc, 'sound/effects/ghost2.ogg', 50, 1)

	for(var/turf/T in targets)
		for(var/mob/living/carbon/human/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == usr) //No message for the user, of course
					continue
				else
					target << "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>"
					continue
			target << "<span class='userdanger'>You are hit by a blast of paralyzingly cold air and feel goosebumps break out across your body!</span>"
			target.Stun(2)
			if(target.bodytemperature)
				target.bodytemperature -= 200 //Extreme amount of initial cold
			if(target.reagents)
				target.reagents.add_reagent("frostoil", 15) //Half of a cryosting



//Enthrall is the single most important spell
/obj/effect/proc_holder/spell/targeted/enthrall
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	panel = "Shadowling Abilities"
	charge_max = 450
	clothes_req = 0
	range = 1 //Adjacent to user
	var/enthralling = 0

/obj/effect/proc_holder/spell/targeted/enthrall/cast(list/targets)
	var/mob/living/carbon/human/user = usr
	listclearnulls(ticker.mode.thralls)
	if(ticker.mode.thralls.len >= 5 && (user.dna.species.id != "shadowling"))
		user << "<span class='warning'>With your telepathic abilities suppressed, your human form will not allow you to enthrall any others. Hatch first.</span>"
		charge_counter = charge_max
		return
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(usr, target))
			usr << "<span class='warning'>You need to be closer to enthrall [target].</span>"
			charge_counter = charge_max
			return
		if(!target.key)
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
			usr << "<span class='warning'>[target]'s mind is vacant of activity. Still, you may rearrange their memories in the case of their return.</span>"
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
								target << "<span class='boldannounce'>Your unwavering loyalty to Nanotrasen unexpectedly falters, dims, dies. You feel a sense of liberation which is quickly stifled by terror.</span>"
				if(3)
					usr << "<span class='notice'>You begin rearranging [target]'s memories.</span>"
					usr.visible_message("<span class='danger'>[usr]'s eyes flare brightly, their unflinching gaze staring constantly at [target].</span>")
					target << "<span class='boldannounce'>Your head cries out. The veil of reality begins to crumple and something evil bleeds through.</span>" //Ow the edge
			if(!do_mob(usr, target, 100)) //around 30 seconds total for enthralling, 45 for someone with a loyalty implant
				usr << "<span class='warning'>The enthralling has been interrupted - your target's mind returns to its previous state.</span>"
				target << "<span class='userdanger'>A spike of pain drives into your head. You aren't sure what's happened, but you feel a faint sense of revulsion.</span>"
				enthralling = 0
				return

		enthralling = 0
		usr << "<span class='shadowling'>You have enthralled <b>[target]</b>!</span>"
		target.visible_message("<span class='big'>[target]'s expression appears as if they have experienced a revelation!</span>", \
		"<span class='shadowling'><b>You see the Truth. Reality has been torn away and you realize what a fool you've been.</b></span>")
		target << "<span class='shadowling'><b>The shadowlings are your masters.</b> Serve them above all else and ensure they complete their goals.</span>"
		target << "<span class='shadowling'>You may not harm other thralls or the shadowlings. However, you do not need to obey other thralls.</span>"
		target << "<span class='shadowling'>You can communicate with the other enlightened ones by using the Hivemind Commune ability.</span>"
		target.setOxyLoss(0) //In case the shadowling was choking them out
		ticker.mode.add_thrall(target.mind)
		target.mind.special_role = "Thrall"



/obj/effect/proc_holder/spell/targeted/shadowling_hivemind
	name = "Hivemind Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Shadowling Abilities"
	charge_max = 0
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowling_hivemind/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = stripped_input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", "")
		if(!text)
			return
		for(var/mob/M in mob_list)
			if(is_shadow_or_thrall(M) || (M in dead_mob_list))
				M << "<span class='shadowling'><b>\[Hive Chat\]</b><i> [usr.real_name]</i>: [text]</span>"



/obj/effect/proc_holder/spell/targeted/shadowling_regenarmor
	name = "Regenerate Chitin"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowling_regenarmor/cast(list/targets)
	for(var/mob/living/user in targets)
		user.visible_message("<span class='warning'>[user]'s skin suddenly bubbles and begins to shift around their body!</span>", \
							 "<span class='shadowling'>You regenerate your protective armor and cleanse your form of defects.</span>")
		user.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(usr), slot_w_uniform)
		user.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(usr), slot_shoes)
		user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(usr), slot_wear_suit)
		user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(usr), slot_head)
		user.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(usr), slot_gloves)
		user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(usr), slot_wear_mask)
		user.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/shadowling(usr), slot_glasses)
		hardset_dna(user, null, null, null, null, /datum/species/shadow/ling) //can't be a shadowling without being a shadowling



/obj/effect/proc_holder/spell/targeted/collective_mind
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	panel = "Shadowling Abilities"
	charge_max = 300 //30 second cooldown to prevent spam
	clothes_req = 0
	range = -1
	include_user = 1
	var/blind_smoke_acquired
	var/screech_acquired
	var/drainLifeAcquired
	var/reviveThrallAcquired

/obj/effect/proc_holder/spell/targeted/collective_mind/cast(list/targets)
	for(var/mob/living/user in targets)
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
			user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/drainLife

		if(thralls >= 7 && !screech_acquired)
			screech_acquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms.</span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/unearthly_screech

		if(thralls >= 9 && !reviveThrallAcquired)
			reviveThrallAcquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. This will, after a short time, bring a dead thrall completely back to life \
			with no bodily defects.</i></span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/reviveThrall

		if(thralls < victory_threshold)
			user << "<span class='shadowling'>You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present.</span>"

		else if(thralls >= victory_threshold)
			usr << "<span class='shadowling'><b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i></span>"
			usr << "<span class='shadowling'><b>You may find Ascendance in the Shadowling Evolution tab.</b></span>"
			for(M in living_mob_list)
				if(is_shadow(M))
					M.mind.spell_list -= /obj/effect/proc_holder/spell/targeted/collective_mind
					M.mind.current.verbs -= /mob/living/carbon/human/proc/shadowling_hatch //In case a shadowling hasn't hatched
					M.mind.current.verbs += /mob/living/carbon/human/proc/shadowling_ascendance
					if(M == usr)
						M << "<span class='shadowling'><i>You project this power to the rest of the shadowlings.</i></span>"
					else
						M << "<span class='shadowling'><b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b></span>" //Tells all the other shadowlings



/obj/effect/proc_holder/spell/targeted/blindness_smoke
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/blindness_smoke/cast(list/targets) //Extremely hacky
	for(var/mob/living/user in targets)
		user.visible_message("<span class='warning'>[user] suddenly bends over and coughs out a cloud of black smoke, which begins to spread rapidly!</span>")
		user << "<span class='shadowling'>You regurgitate a vast cloud of blinding smoke.</span>"
		playsound(user, 'sound/effects/bamf.ogg', 50, 1)
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B = new /obj/item/weapon/reagent_containers/glass/beaker/large(user.loc)
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

datum/reagent/shadowling_blindness_smoke //Blinds non-shadowlings, heals shadowlings/thralls
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



/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	panel = "Shadowling Abilities"
	range = 7
	charge_max = 300
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech/cast(list/targets)
	usr.audible_message("<span class='warning'><b>[usr] lets out a horrible scream!</b></span>")
	playsound(usr.loc, 'sound/effects/screech.ogg', 100, 1)

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
				S << "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSOR OVERLOAD \[$(!@#</b></span>"
				S << 'sound/misc/interference.ogg'
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				var/datum/effect/effect/system/spark_spread/sp = new /datum/effect/effect/system/spark_spread
				sp.set_up(5, 1, S)
				sp.start()
				S.Weaken(6)
		for(var/obj/structure/window/W in T.contents)
			W.hit(rand(80, 100))



/obj/effect/proc_holder/spell/aoe_turf/drainLife
	name = "Drain Life"
	desc = "Damages nearby humans, draining their life and healing your own wounds."
	panel = "Shadowling Abilities"
	range = 3
	charge_max = 100
	clothes_req = 0
	var/targetsDrained
	var/list/nearbyTargets

/obj/effect/proc_holder/spell/aoe_turf/drainLife/cast(list/targets, mob/living/carbon/human/U = usr)
	targetsDrained = 0
	nearbyTargets = list()
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
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



/obj/effect/proc_holder/spell/targeted/reviveThrall
	name = "Black Recuperation"
	desc = "Brings a dead thrall back to life."
	panel = "Shadowling Abilities"
	range = 1
	charge_max = 3000
	clothes_req = 0
	include_user = 0
	var/list/thralls_in_world = list()

/obj/effect/proc_holder/spell/targeted/reviveThrall/Topic(href, href_list)
	if(href_list["reenter"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.reenter_corpse(ghost)

/obj/effect/proc_holder/spell/targeted/reviveThrall/cast(list/targets)
	for(var/mob/living/carbon/human/thrallToRevive in targets)
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
		var/mob/dead/observer/ghost = thrallToRevive.get_ghost()
		if(ghost)
			ghost << "<span class='ghostalert'>Your masters are resuscitating you! Re-enter your corpse if you wish to be brought to life.</span> <a href=?src=\ref[src];reenter=1>(Click to re-enter)</a>"
			ghost << 'sound/effects/genetics.ogg'
		if(!do_mob(usr, thrallToRevive, 100))
			usr << "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>"
			charge_counter= charge_max
			return
		usr << "<span class='shadowling'><b><i>You release a massive surge of energy into [thrallToRevive]!</b></i></span>"
		usr.visible_message("<span class='boldannounce'><i>Red lightning surges from [usr]'s hands into [thrallToRevive]'s chest!</i></span>")
		playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', 50, 1)
		playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
		sleep(20)
		thrallToRevive.revive()
		thrallToRevive.visible_message("<span class='boldannounce'>[thrallToRevive] draws in a huge breath, blinding violet light shining from their eyes.</span>", \
									   "<span class='shadowling'><b><i>You have returned. One of your masters has brought you from the darkness beyond.</b></i></span>")
		thrallToRevive.Weaken(4)
		thrallToRevive.emote("gasp")
		playsound(thrallToRevive, "bodyfall", 50, 1)

// ASCENDANT ABILITIES BEYOND THIS POINT //

/obj/effect/proc_holder/spell/targeted/annihilate
	name = "Annihilate"
	desc = "Gibs a human after a short time."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/annihilate/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		usr << "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>"
		charge_counter = charge_max
		return

	for(var/mob/living/carbon/human/boom in targets)
		if(is_shadow_or_thrall(boom))
			usr << "<span class='warning'>Making an ally explode seems unwise.<span>"
			charge_counter = charge_max
			return
		usr.visible_message("<span class='danger'>[usr]'s eyes flare as they gesture at [boom]!</span>", \
							"<span class='shadowling'>You direct a lance of telekinetic energy at [boom].</span>")
		boom << "<span class='userdanger'><font size=3>You feel an immense pressure building all across your body!</span></font>"
		boom.Stun(10)
		boom.audible_message("<b>[boom]</b> screams!")
		sleep(20)
		playsound(boom, 'sound/effects/splat.ogg', 100, 1)
		boom.visible_message("<span class='userdanger'>[boom] explodes!</span>")
		boom.gib()



/obj/effect/proc_holder/spell/targeted/hypnosis
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = 0

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
		if(!target.ckey)
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
		target << "<span class='shadowling'><b>And you see the Truth. Reality has been torn away and you realize what a fool you've been.</b></span>"
		target << "<span class='shadowling'><b>The shadowlings are your masters.</b> Serve them above all else and ensure they complete their goals.</span>"
		target << "<span class='shadowling'>You may not harm other thralls or the shadowlings. However, you do not need to obey other thralls.</span>"
		target << "<span class='shadowling'>You can communicate with the other enlightened ones by using the Hivemind Commune ability.</span>"
		ticker.mode.add_thrall(target.mind)
		target.mind.special_role = "Thrall"
		var/datum/mind/thrall_mind = target.mind
		thrall_mind.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind



/obj/effect/proc_holder/spell/targeted/shadowling_phase_shift
	name = "Phase Shift"
	desc = "Phases you into the space between worlds at will, allowing you to move through walls and become invisible."
	panel = "Ascendant"
	range = -1
	include_user = 1
	charge_max = 15
	clothes_req = 0

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



/obj/effect/proc_holder/spell/aoe_turf/glacial_blast
	name = "Glacial Blast"
	desc = "Extremely empowered version of Flash Freeze."
	panel = "Ascendant"
	range = 5
	charge_max = 100
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/glacial_blast/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		usr << "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>"
		return

	usr << "<span class='shadowling'>You freeze the nearby air.</span>"
	playsound(usr.loc, 'sound/effects/ghost2.ogg', 100, 1)

	for(var/turf/T in targets)
		for(var/mob/living/carbon/human/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == usr) //No message for the user, of course
					continue
				else
					target << "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>"
					continue
			target << "<span class='userdanger'>You are hit by a blast of cold unlike anything you have ever felt. Your limbs instantly lock in place and you feel ice burns across your body!</span>"
			target.Weaken(15)
			if(target.bodytemperature)
				target.bodytemperature -= INFINITY //:^)
			target.take_organ_damage(0,80)



/obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant
	name = "Ascendant Commune"
	desc = "Allows you to LOUDLY communicate with all other shadowlings and thralls."
	panel = "Ascendant"
	charge_max = 0
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = stripped_input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", "")
		if(!text)
			return
		text = "<font size=4>[text]</font>"
		for(var/mob/M in mob_list)
			if(is_shadow_or_thrall(M) || (M in dead_mob_list))
				M << "<span class='shadowling'><b>\[Hive Chat\]<i> [usr.real_name] (ASCENDANT)</i>: [text]</b></span>" //Bigger text for ascendants.



/obj/effect/proc_holder/spell/targeted/shadowlingAscendantTransmit
	name = "Ascendant Broadcast"
	desc = "Sends a message to the whole wide world."
	panel = "Ascendant"
	charge_max = 200
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowlingAscendantTransmit/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = stripped_input(user, "What do you want to say to everything on and near [world.name]?.", "Transmit to World", "")
		if(!text)
			return
		world << "<font size=4><span class='shadowling'><b>\"[text]\"</font></span>"
