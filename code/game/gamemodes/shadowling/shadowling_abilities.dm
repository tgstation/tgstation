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

		usr.visible_message("<span class='warning'><b>[usr]'s eyes flash a blinding red!</b></span>")
		target.visible_message("<span class='danger'>[target] freezes in place, their eyes glazing over...</span>")
		if(in_range(target, usr))
			target << "<span class='userdanger'>Your gaze is forcibly drawn into [usr]'s eyes, and you are mesmerized by the heavenly lights...</span>"
		else //Only alludes to the shadowling if the target is close by
			target << "<span class='userdanger'>Red lights suddenly dance in your vision, and you are mesmerized by the heavenly lights...</span>"
		target.Stun(10)
		if(target.reagents)
			target.reagents.add_reagent("mutetoxin", 4) //This is really bad but it's the only way it works.



/obj/effect/proc_holder/spell/aoe_turf/veil
	name = "Veil"
	desc = "Extinguishes all electronic lights in a decent radius."
	panel = "Shadowling Abilities"
	charge_max = 250 //Short cooldown because people can just turn the lights back on
	clothes_req = 0
	range = 5

/obj/effect/proc_holder/spell/aoe_turf/veil/cast(list/targets)
	usr << "<span class='deadsay'>You silently disable all nearby lights.</span>"
	var/list/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime)
	for(var/turf/T in targets)
		for(var/obj/item/device/flashlight/F in T.contents)
			if(is_type_in_list(F, blacklisted_lights))
				F.visible_message("<span class='danger'>[F] goes slightly dim for a moment.</span>")
				return
			F.on = 0
			F.visible_message("<span class='danger'>[F] gutters and falls dark.</span>")
			F.update_brightness()
		for(var/obj/machinery/light/L in T.contents)
			L.on = 0
			L.visible_message("<span class='danger'>[L] flickers and falls dark.</span>")
			L.update(0)
		for(var/obj/item/device/pda/P in T.contents)
			P.fon = 0
			P.SetLuminosity(0)
		for(var/obj/effect/glowshroom/G in orange(2, usr)) //Very small radius
			G.visible_message("<span class='warning'>\The [G] withers away!</span>")
			qdel(G)
		for(var/mob/living/carbon/human/H in T.contents)
			for(var/obj/item/device/flashlight/F in H)
				if(is_type_in_list(F, blacklisted_lights))
					F.visible_message("<span class='danger'>[F] goes slightly dim for a moment.</span>")
					return
				F.on = 0
				F.visible_message("<span class='danger'>[F] gutters and falls dark.</span>")
				F.update_brightness()
			for(var/obj/item/device/pda/P in H)
				P.fon = 0
				P.SetLuminosity(0) //failsafe
			if(H != usr)
				H << "<span class='boldannounce'>You feel a chill and are plunged into darkness.</span>"
			H.SetLuminosity(0) //This is required with the object-based lighting



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
		user.visible_message("<span class='danger'>[user] vanishes into thin air!</span>", "<span class='deadsay'>You enter the space between worlds as a passageway.</span>")
		user.SetStunned(0)
		user.SetWeakened(0)
		user.incorporeal_move = 1
		user.alpha = 0
		if(user.buckled)
			user.buckled.unbuckle_mob()
		sleep(40) //4 seconds
		user.visible_message("<span class='danger'>[user] appears out of nowhere!</span>", "<span class='deadsay'>The pressure becomes too much and you vacate the interdimensional darkness.</span>")
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
	usr << "<span class='deadsay'>You freeze the nearby air.</span>"
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
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(usr, target))
			usr << "<span class='warning'>You need to be closer to enthrall [target].</span>"
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
		if(is_shadow_or_thrall(target))
			usr << "<span class='warning'>You can not enthrall allies.</span>"
			charge_counter = charge_max
			return
		if(!ishuman(target))
			usr << "<span class='warning'>You can only enthrall humans.</span>"
			charge_counter = charge_max
			return
		if(enthralling)
			usr << "<span class='danger'>You are already enthralling!</span>"
			charge_counter = charge_max
			return
		enthralling = 1
		usr << "<span class='danger'>This target is valid. You begin the enthralling.</span>"
		target << "<span class='userdanger'>[usr] focuses in concentration. Your head begins to ache.</span>"

		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					usr << "<span class='notice'>You begin allocating energy for the enthralling.</span>"
					usr.visible_message("<span class='danger'>[usr]'s eyes begin to throb a piercing red.</span>")
				if(2)
					usr << "<span class='notice'>You begin the enthralling of [target].</span>"
					usr.visible_message("<span class='danger'>[usr] leans over [target], their eyes glowing a deep crimson, and stares into their face.</span>")
					target << "<span class='danger'>Your gaze is forcibly drawn into a blinding red light. You fall to the floor as conscious thought is wiped away.</span>"
					target.Weaken(12)
					sleep(20)
					if(isloyal(target))
						usr << "<span class='notice'>They are enslaved by Nanotrasen. You begin to shut down the nanobot implant - this will take some time.</span>"
						usr.visible_message("<span class='danger'>[usr] halts for a moment, then begins passing its hand over [target]'s body.</span>")
						target << "<span class='danger'>You feel your loyalties begin to weaken!</span>"
						sleep(150) //15 seconds - not spawn() so the enthralling takes longer
						usr << "<span class='notice'>The nanobots composing the loyalty implant have been rendered inert. Now to continue.</span>"
						usr.visible_message("<span class='danger'>[usr] halts thier hand and resumes staring into [target]'s face.</span>")
						for(var/obj/item/weapon/implant/loyalty/L in target)
							if(L && L.implanted)
								qdel(L)
								target << "<span class='danger'>Your unwavering loyalty to Nanotrasen falters, dims, dies.</span>"
				if(3)
					usr << "<span class='notice'>You begin rearranging [target]'s memories.</span>"
					usr.visible_message("<span class='danger'>[usr]'s eyes flare brightly, and a horrible grin begins to spread across [target]'s face...</span>")
					target << "<span class='danger'>Your head cries out. The veil of reality begins to crumple and something evil bleeds through.</span>" //Ow the edge
			if(!do_mob(usr, target, 100)) //around 30 seconds total for enthralling, 45 for someone with a loyalty implant
				usr << "<span class='danger'>The enthralling has been interrupted - your target's mind returns to its previous state.</span>"
				target << "<span class='warning'>Your thoughts become coherent once more. Already you can barely remember what's happened to you.</span>"
				enthralling = 0
				return

		enthralling = 0
		usr << "<span class='notice'>You have enthralled <b>[target]</b>!</span>"
		target << "<span class='deadsay'><b>You see the Truth. Reality has been torn away and you realize what a fool you've been.</b></span>"
		target << "<span class='deadsay'><b>The shadowlings are your masters.</b> Serve them above all else and ensure they complete their goals.</span>"
		target << "<span class='deadsay'>You may not harm other thralls or the shadowlings. However, you do not need to obey other thralls.</span>"
		target << "<span class='deadsay'>You can communicate with the other enlightened ones by using the Hivemind Commune ability.</span>"
		target.adjustOxyLoss(-200) //In case the shadowling was choking them out
		ticker.mode.add_thrall(target.mind)
		target.mind.special_role = "Thrall"



/obj/effect/proc_holder/spell/targeted/shadowling_hivemind
	name = "Hivemind Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Shadowling Abilities"
	charge_max = 25
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
	var/drain_thrall_acquired
	var/thrall_swap_acquired

/obj/effect/proc_holder/spell/targeted/collective_mind/cast(list/targets)
	for(var/mob/living/user in targets)
		var/thralls = 0
		var/victory_threshold = 15
		var/mob/M

		user << "<span class='shadowling'><b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b></span>"

		for(M in living_mob_list)
			if(is_thrall(M))
				thralls++
				M << "<span class='deadsay'>You feel hooks sink into your mind and pull.</span>"

		if(!do_after(user, 30))
			user << "<span class='warning'>Your concentration has been broken. The mental hooks you have sent out now retract into your mind.</span>"
			return

		if(thralls >= 3 && !blind_smoke_acquired)
			blind_smoke_acquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. It will create a choking cloud that will blind any non-thralls who enter. \
			</i></span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/blindness_smoke

		if(thralls >= 5 && !drain_thrall_acquired)
			drain_thrall_acquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Drain Thrall</b> ability. You can now drain nearby thralls to heal yourself.</i></span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/drain_thralls

		if(thralls >= 7 && !screech_acquired)
			screech_acquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies.</span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/unearthly_screech

		if(thralls >= 9 && !thrall_swap_acquired)
			thrall_swap_acquired = 1
			user << "<span class='shadowling'><i>The power of your thralls has granted you the <b>Spatial Relocation</b> ability. This will, allow you to instantly swap places with one of your thralls in \
			addition to shattering nearby lights.</i></span>"
			user.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/spatial_relocation

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
						return
					M << "<span class='shadowling'><b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend.</span>" //Tells all the other shadowlings



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
		user << "<span class='deadsay'>You regurgitate a vast cloud of blinding smoke.</span>"
		playsound(user, 'sound/effects/bamf.ogg', 50, 1)
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B = new /obj/item/weapon/reagent_containers/glass/beaker/large(user.loc)
		B.reagents.clear_reagents() //Just in case!
		B.icon_state = null //Invisible
		B.reagents.add_reagent("blindness_smoke", 10)
		var/datum/effect/effect/system/smoke_spread/chem/S = new
		S.attach(B)
		if(S)
			S.set_up(10, 0, B.loc, null, 0, B.reagents)
			S.start()
			sleep(10)
			S.start()
		qdel(B)

/datum/reagent/shadowling_blindness_smoke //Blinds non-shadowlings, heals shadowlings/thralls
	name = "!(%@ ERROR )!@$"
	id = "blindness_smoke"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 100 //lel

/datum/reagent/shadowling_blindness_smoke/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!is_shadow_or_thrall(M))
		M << "<span class='warning'><b>You breathe in the black smoke, and your eyes burn horribly!</b></span>"
		M.eye_blind = 5
		if(prob(25))
			M.visible_message("<b>[M]</b> screams and claws at their eyes!")
			M.Stun(2)
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
				S << "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSOR INTERFERENCE DETECTED</b></span>"
				S << 'sound/misc/interference.ogg'
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				var/datum/effect/effect/system/spark_spread/sp = new /datum/effect/effect/system/spark_spread
				sp.set_up(5, 1, S)
				sp.start()
				S.Weaken(6)
		for(var/obj/structure/window/W in T.contents)
			W.hit(rand(50,100))



/obj/effect/proc_holder/spell/aoe_turf/drain_thralls
	name = "Drain Thralls"
	desc = "Damages nearby thralls, draining their life and healing yourself."
	panel = "Shadowling Abilities"
	range = 3
	charge_max = 100
	clothes_req = 0
	var/thralls_drained = 0
	var/list/nearby_thralls = list()

/obj/effect/proc_holder/spell/aoe_turf/drain_thralls/cast(list/targets)
	thralls_drained = 0
	nearby_thralls = list()
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			if(is_thrall(M))
				thralls_drained++
				nearby_thralls.Add(M)
				M << "<span class='warning'>You feel a curious draining sensation and a wave of exhaustion washes over you.</span>"
		for(var/mob/living/carbon/M in nearby_thralls)
			nearby_thralls.Remove(M) //To prevent someone dying like a zillion times
			M.take_organ_damage(25/thralls_drained,25/thralls_drained) //For every nearby thrall, the damage to each is reduced - 1 thrall = 50 for him, 2 thralls = 25 for each, etc.
			usr << "<span class='deadsay'>You draw the life from [M] to heal your wounds.</span>"
	if(thralls_drained)
		var/mob/living/carbon/U = usr
		U.heal_organ_damage(25, 25)
	else
		charge_counter = charge_max
		usr << "<span class='warning'>There were no nearby thralls for you to drain.</span>"



/obj/effect/proc_holder/spell/targeted/spatial_relocation
	name = "Spatial Relocation"
	desc = "Swaps places with a thrall and breaks nearby lights."
	panel = "Shadowling Abilities"
	range = -1
	charge_max = 3000
	clothes_req = 0
	include_user = 1
	var/list/thralls_in_world = list()

/obj/effect/proc_holder/spell/targeted/spatial_relocation/cast(list/targets, distanceoverride)
	for(var/mob/living/carbon/human/M in world)
		if(is_thrall(M))
			thralls_in_world += M
	if(!thralls_in_world)
		charge_counter = charge_max
		return
	var/mob/living/carbon/thrall_to_swap = input("Who do you wish to swap places with?", "Available Thralls") as null|anything in (thralls_in_world)
	var/turf/shadowturf = get_turf(usr)
	var/turf/thrallturf = get_turf(thrall_to_swap)
	thrall_to_swap.visible_message("<span class='danger'>[thrall_to_swap] suddenly vanishes in a puff of black smoke!</span>")
	thrall_to_swap << "<span class='warning'><b>You feel a brief sense of nausea before finding yourself in an entirely new place!</b></span>"
	usr.visible_message("<span class='danger'>[usr] suddenly goes transparent and vanishes!</span>")
	usr << "<span class='deadsay'>You experience vertigo as you swap your location with [thrall_to_swap]'s.</span>"
	thrall_to_swap.loc = shadowturf
	usr.loc = thrallturf
	thrall_to_swap.Weaken(4)
	usr.Weaken(4)
	usr.regenerate_icons()
	thrall_to_swap.regenerate_icons()

// ASCENDANT ABILITIES BEYOND THIS POINT //

/obj/effect/proc_holder/spell/targeted/annihilate
	name = "Annihilate"
	desc = "Gibs a human after a short time."
	panel = "Ascendant"
	range = 7
	charge_max = 300
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
	charge_max = 450
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
		target << "<span class='deadsay'><b>And you see the Truth. Reality has been torn away and you realize what a fool you've been.</b></span>"
		target << "<span class='deadsay'><b>The shadowlings are your masters.</b> Serve them above all else and ensure they complete their goals.</span>"
		target << "<span class='deadsay'>You may not harm other thralls or the shadowlings. However, you do not need to obey other thralls.</span>"
		target << "<span class='deadsay'>You can communicate with the other enlightened ones by using the Hivemind Commune ability.</span>"
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
	charge_max = 600
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/glacial_blast/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		usr << "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>"
		return

	usr << "<span class='deadsay'>You freeze the nearby air.</span>"
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



/obj/effect/proc_holder/spell/targeted/vortex
	name = "Vortex"
	desc = "Tears open a hole in reality. Anyone, INCLUDING YOU, walking through it will be trapped there for eternity."
	panel = "Ascendant"
	range = -1
	include_user = 1
	charge_max = 1200
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/vortex/cast(list/targets)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = usr
	if(SHA.phasing)
		usr << "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>"
		return

	for(SHA in targets)
		SHA.visible_message("<span class='userdanger'>[SHA] raises their arms upward as the markings on their body flare a blinding red!</span>", \
						"<span class='shadowling'>You tear open a rift to the black space between worlds. <b><font size=3>It would be wise to avoid it.</font></b></span>")

		new /obj/structure/shadow_vortex(SHA.loc)



/obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant
	name = "Ascendant Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Ascendant"
	charge_max = 20
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant/cast(list/targets)
	for(var/mob/living/user in targets)
		var/text = stripped_input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", "")
		if(!text)
			return
		text = "<font size=3>[text]</font>"
		for(var/mob/M in mob_list)
			if(is_shadow_or_thrall(M) || (M in dead_mob_list))
				M << "<span class='shadowling'><b>\[Hive Chat\]<i> [usr.real_name] (ASCENDANT)</i>: [text]</b></span>" //Bigger text for ascendants.
