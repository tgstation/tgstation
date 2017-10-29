//In here: Hatch and Ascendance
/obj/effect/proc_holder/spell/self/shadowling_hatch
	name = "Hatch"
	desc = "Casts off your disguise."
	panel = "Shadowling Evolution"
	charge_max = 3000
	human_req = 1
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "hatch"



/obj/effect/proc_holder/spell/self/shadowling_hatch/cast(list/targets,mob/user = usr)
	if(user.stat || !ishuman(user) || !user || !is_shadow(user || isinspace(user)))
		return
	var/mob/living/carbon/human/H = user
	var/hatch_or_no = alert(H,"Are you sure you want to hatch? You cannot undo this!",,"Yes","No")
	switch(hatch_or_no)
		if("No")
			to_chat(H, "<span class='warning'>You decide against hatching for now.")
			charge_counter = charge_max
			return
		if("Yes")
			H.SetStun(INFINITY) //This is bad but hulks can't be stunned with the actual procs. I'm sorry.
			H.visible_message("<span class='warning'>[H]'s things suddenly slip off. They hunch over and vomit up a copious amount of purple goo which begins to shape around them!</span>", \
							"<span class='shadowling'>You remove any equipment which would hinder your hatching and begin regurgitating the resin which will protect you.</span>")

			var/temp_flags = H.status_flags
			H.status_flags |= GODMODE //Can't die while hatching

			H.unequip_everything()

			sleep(50)

			var/turf/shadowturf = get_turf(user)
			for(var/turf/open/floor/F in orange(1, user))
				new /obj/structure/alien/resin/wall/shadowling(F)

			for(var/obj/structure/alien/resin/wall/shadowling/R in shadowturf) //extremely hacky
				qdel(R)
				new /obj/structure/alien/weeds/node(shadowturf) //Dim lighting in the chrysalis -- removes itself afterwards

			H.visible_message("<span class='warning'>A chrysalis forms around [H], sealing them inside.</span>", \
							"<span class='shadowling'>You create your chrysalis and begin to contort within.</span>")

			sleep(100)
			H.visible_message("<span class='warning'><b>The skin on [H]'s back begins to split apart. Black spines slowly emerge from the divide.</b></span>", \
							"<span class='shadowling'>Spines pierce your back. Your claws break apart your fingers. You feel excruciating pain as your true form begins its exit.</span>")

			sleep(90)
			H.visible_message("<span class='warning'><b>[H], skin shifting, begins tearing at the walls around them.</b></span>", \
							"<span class='shadowling'>Your false skin slips away. You begin tearing at the fragile membrane protecting you.</span>")

			sleep(80)
			playsound(H.loc, 'sound/weapons/slash.ogg', 25, 1)
			to_chat(H, "<i><b>You rip and slice.</b></i>")
			sleep(10)
			playsound(H.loc, 'sound/weapons/slashmiss.ogg', 25, 1)
			to_chat(H, "<i><b>The chrysalis falls like water before you.</b></i>")
			sleep(10)
			playsound(H.loc, 'sound/weapons/slice.ogg', 25, 1)
			to_chat(H, "<i><b>You are free!</b></i>")
			H.status_flags = temp_flags
			sleep(10)
			playsound(H.loc, 'sound/effects/ghost.ogg', 100, 1)
			var/newNameId = pick(GLOB.nightmare_names)
			var/oldName = H.real_name
			GLOB.nightmare_names.Remove(newNameId)
			H.real_name = newNameId
			H.name = user.real_name
			H.SetStun(0)
			to_chat(H, "<i><b><font size=3>YOU LIVE!!!</i></b></font>")

			var/hatchannounce = "<font size=3><span class='shadowling'><b>[oldName] has hatched into the Shadowling [newNameId]!</b></span></font>"
			for(var/mob/M in GLOB.mob_list)
				if(is_shadow_or_thrall(M))
					to_chat(M, hatchannounce)
				if(M in GLOB.dead_mob_list)
					to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [hatchannounce]")

			for(var/obj/structure/alien/resin/wall/shadowling/W in orange(1, H))
				playsound(W, 'sound/effects/splat.ogg', 50, 1)
				qdel(W)
			for(var/obj/structure/alien/weeds/node/N in shadowturf)
				qdel(N)
			H.visible_message("<span class='warning'>The chrysalis explodes in a shower of purple flesh and fluid!</span>")
			H.underwear = "Nude"
			H.undershirt = "Nude"
			H.socks = "Nude"
			H.faction |= "faithless"
			H.shadow_walk = TRUE

			H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(H), slot_head)
			H.set_species(/datum/species/shadow/ling) //can't be a shadowling without being a shadowling

			H.mind.RemoveSpell(src)

			sleep(10)
			to_chat(H, "<span class='shadowling'><b><i>Your powers are awoken. You may now live to your fullest extent. Remember your goal. Cooperate with your thralls and allies.</b></i></span>")
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/enthrall(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/sling/glare(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/veil(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/flashfreeze(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/collective_mind(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_regenarmor(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_extend_shuttle(null))



/obj/effect/proc_holder/spell/self/shadowling_ascend
	name = "Ascend"
	desc = "Enters your true form."
	panel = "Shadowling Evolution"
	charge_max = 3000
	clothes_req = 0
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "ascend"

/obj/effect/proc_holder/spell/self/shadowling_ascend/cast(list/targets,mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!shadowling_check(H))
		return
	var/hatch_or_no = alert(H,"It is time to ascend. Are you sure about this?",,"Yes","No")
	switch(hatch_or_no)
		if("No")
			to_chat(H, "<span class='warning'>You decide against ascending for now.")
			charge_counter = charge_max
			return
		if("Yes")
			H.notransform = 1
			H.visible_message("<span class='warning'>[H]'s things suddenly slip off. They gently rise into the air, red light glowing in their eyes.</span>", \
							"<span class='shadowling'>You rise into the air and get ready for your transformation.</span>")

			for(var/obj/item/I in H) //drops all items
				H.unequip_everything(I)

				sleep(50)

				H.visible_message("<span class='warning'>[H]'s skin begins to crack and harden.</span>", \
								"<span class='shadowling'>Your flesh begins creating a shield around yourself.</span>")

				sleep(100)
				H.visible_message("<span class='warning'>The small horns on [H]'s head slowly grow and elongate.</span>", \
								  "<span class='shadowling'>Your body continues to mutate. Your telepathic abilities grow.</span>") //y-your horns are so big, senpai...!~

				sleep(90)
				H.visible_message("<span class='warning'>[H]'s body begins to violently stretch and contort.</span>", \
								  "<span class='shadowling'>You begin to rend apart the final barriers to godhood.</span>")

				sleep(40)
				to_chat(H, "<i><b>Yes!</b></i>")
				sleep(10)
				to_chat(H, "<i><b><span class='big'>YES!!</span></b></i>")
				sleep(10)
				to_chat(H, "<i><b><span class='reallybig'>YE--</span></b></i>")
				sleep(1)
				for(var/mob/living/M in orange(7, H))
					M.Knockdown(10)
					to_chat(M, "<span class='userdanger'>An immense pressure slams you onto the ground!</span>")
				to_chat(world, "<font size=5><span class='shadowling'><b>\"VYSHA NERADA YEKHEZET U'RUU!!\"</font></span>")
				for(var/mob/M in GLOB.player_list)
					M.playsound_local(get_turf(M), 'sound/hallucinations/veryfar_noise.ogg', 150, 1, pressure_affected = FALSE)
				for(var/obj/machinery/power/apc/A in GLOB.apcs_list)
					A.overload_lighting()
				var/mob/A = new /mob/living/simple_animal/ascendant_shadowling(H.loc)
				for(var/obj/effect/proc_holder/spell/S in H.mind.spell_list)
					if(S == src) continue
					H.mind.RemoveSpell(S)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/sling/annihilate(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/sling/hypnosis(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_phase_shift(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/ascendant_storm(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_hivemind_ascendant(null))
				H.mind.transfer_to(A)
				A.name = H.real_name
				if(A.real_name)
					A.real_name = H.real_name
				H.invisibility = 60 //This is pretty bad, but is also necessary for the shuttle call to function properly
				H.loc = A
				if(!SSticker.mode.shadowling_ascended)
					set_security_level(3)
					SSshuttle.emergencyCallTime = 1800
					SSshuttle.emergency.request(null, 0.3)
					SSshuttle.emergencyNoRecall = TRUE
				SSticker.mode.shadowling_ascended = 1
				A.mind.RemoveSpell(src)
				qdel(H)
