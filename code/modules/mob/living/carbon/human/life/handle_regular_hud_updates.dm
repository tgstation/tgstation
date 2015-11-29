//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_regular_hud_updates()
	if(!client)
		return 0

	sight &= ~BLIND

	regular_hud_updates()

	client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask/*, global_hud.nvg*/)

	update_action_buttons()

	if(damageoverlay.overlays)
		damageoverlay.overlays = list()

	if(stat == UNCONSCIOUS)
		//Critical damage passage overlay
		if(health <= 0)
			//var/image/I
			switch(health)
				if(-20 to -10)
					damageoverlay.overlays += unconscious_overlays["1"]
				if(-30 to -20)
					damageoverlay.overlays += unconscious_overlays["2"]
				if(-40 to -30)
					damageoverlay.overlays += unconscious_overlays["3"]
				if(-50 to -40)
					damageoverlay.overlays += unconscious_overlays["4"]
				if(-60 to -50)
					damageoverlay.overlays += unconscious_overlays["5"]
				if(-70 to -60)
					damageoverlay.overlays += unconscious_overlays["6"]
				if(-80 to -70)
					damageoverlay.overlays += unconscious_overlays["7"]
				if(-90 to -80)
					damageoverlay.overlays += unconscious_overlays["8"]
				if(-95 to -90)
					damageoverlay.overlays += unconscious_overlays["9"]
				if(-INFINITY to -95)
					damageoverlay.overlays += unconscious_overlays["10"]
	else
		//Oxygen damage overlay
		if(oxyloss)
			//var/image/I
			switch(oxyloss)
				if(10 to 20)
					damageoverlay.overlays += oxyloss_overlays["1"]
				if(20 to 25)
					damageoverlay.overlays += oxyloss_overlays["2"]
				if(25 to 30)
					damageoverlay.overlays += oxyloss_overlays["3"]
				if(30 to 35)
					damageoverlay.overlays += oxyloss_overlays["4"]
				if(35 to 40)
					damageoverlay.overlays += oxyloss_overlays["5"]
				if(40 to 45)
					damageoverlay.overlays += oxyloss_overlays["6"]
				if(45 to INFINITY)
					damageoverlay.overlays += oxyloss_overlays["7"]
			//damageoverlay.overlays += I

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 //We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			//var/image/I
			switch(hurtdamage)
				if(10 to 25)
					damageoverlay.overlays += brutefireloss_overlays["1"]
				if(25 to 40)
					damageoverlay.overlays += brutefireloss_overlays["2"]
				if(40 to 55)
					damageoverlay.overlays += brutefireloss_overlays["3"]
				if(55 to 70)
					damageoverlay.overlays += brutefireloss_overlays["4"]
				if(70 to 85)
					damageoverlay.overlays += brutefireloss_overlays["5"]
				if(85 to INFINITY)
					damageoverlay.overlays += brutefireloss_overlays["6"]
			//damageoverlay.overlays += I
	if(stat == DEAD)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		if(!druggy)
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if(healths)
			healths.icon_state = "health7" //DEAD healthmeter
	else
		sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = species.darksight
		see_invisible = see_in_dark > 2 ? SEE_INVISIBLE_LEVEL_ONE : SEE_INVISIBLE_LIVING
		if(dna)
			switch(dna.mutantrace)
				if("slime")
					see_in_dark = 3
					see_invisible = SEE_INVISIBLE_LEVEL_ONE
				if("shadow")
					see_in_dark = 8
					see_invisible = SEE_INVISIBLE_LEVEL_ONE
		if(M_XRAY in mutations)
			sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			see_in_dark = 8
			if(!druggy)
				see_invisible = SEE_INVISIBLE_LEVEL_TWO

		if(seer == 1)
			var/obj/effect/rune/R = locate() in loc
			if(R && R.word1 == cultwords["see"] && R.word2 == cultwords["hell"] && R.word3 == cultwords["join"])
				see_invisible = SEE_INVISIBLE_OBSERVER
			else
				see_invisible = SEE_INVISIBLE_LIVING
				seer = 0

		if(glasses)
			var/obj/item/clothing/glasses/G = glasses
			if(istype(G))
				if(G.see_in_dark)
					see_in_dark = G.see_in_dark
				see_in_dark += G.darkness_view
				if(G.vision_flags) //MESONS
					sight |= G.vision_flags
					if(!druggy)
						see_invisible = SEE_INVISIBLE_MINIMUM
				if(G.see_invisible)
					see_invisible = G.see_invisible

			/* HUD shit goes here, as long as it doesn't modify sight flags
			 * The purpose of this is to stop xray and w/e from preventing you from using huds -- Love, Doohl
			 */

			if(istype(glasses, /obj/item/clothing/glasses/sunglasses/sechud))
				var/obj/item/clothing/glasses/sunglasses/sechud/O = glasses
				if(O.hud)
					O.hud.process_hud(src)
				if(!druggy)
					see_invisible = SEE_INVISIBLE_LIVING
			else if(istype(glasses, /obj/item/clothing/glasses/hud))
				var/obj/item/clothing/glasses/hud/O = glasses
				O.process_hud(src)
				if(!druggy)
					see_invisible = SEE_INVISIBLE_LIVING

		else if(!seer)
			see_invisible = SEE_INVISIBLE_LIVING

		if(healths)
			healths.overlays.len = 0
			if (analgesic)
				healths.icon_state = "health_health_numb"
			else
				var/ruptured = is_lung_ruptured()
				if(hal_screwyhud)
					for(var/i = 1; i <= 3; i++)
						healths.overlays.Add(pick(organ_damage_overlays))
				else
					for(var/datum/organ/external/e in organs)
						if(istype(e, /datum/organ/external/chest))
							if(ruptured)
								healths.overlays.Add(organ_damage_overlays["[e.name]_max"])
								continue
						var/total_damage = e.brute_dam + e.burn_dam
						if(e.status & ORGAN_BROKEN)
							healths.overlays.Add(organ_damage_overlays["[e.name]_gone"])
						else
							switch(total_damage)
								if(30 to INFINITY)
									healths.overlays.Add(organ_damage_overlays["[e.name]_max"])
								if(15 to 30)
									healths.overlays.Add(organ_damage_overlays["[e.name]_mid"])
								if(5 to 15)
									healths.overlays.Add(organ_damage_overlays["[e.name]_min"])
				switch(hal_screwyhud)
					if(1)
						healths.icon_state = "health6"
					if(2)
						healths.icon_state = "health7"
					else
						switch(health - halloss)
						//switch(100 - ((species && species.flags & NO_PAIN) ? 0 : traumatic_shock))
							if(100 to INFINITY)		healths.icon_state = "health0"
							if(80 to 100)			healths.icon_state = "health1"
							if(60 to 80)			healths.icon_state = "health2"
							if(40 to 60)			healths.icon_state = "health3"
							if(20 to 40)			healths.icon_state = "health4"
							if(0 to 20)				healths.icon_state = "health5"
							else					healths.icon_state = "health6"

		if(nutrition_icon)
			switch(nutrition)
				if(450 to INFINITY)				nutrition_icon.icon_state = "nutrition0"
				if(350 to 450)					nutrition_icon.icon_state = "nutrition1"
				if(250 to 350)					nutrition_icon.icon_state = "nutrition2"
				if(150 to 250)					nutrition_icon.icon_state = "nutrition3"
				else							nutrition_icon.icon_state = "nutrition4"

		if(pressure)
			pressure.icon_state = "pressure[pressure_alert]"

		if(pullin)
			if(pulling)								pullin.icon_state = "pull1"
			else									pullin.icon_state = "pull0"
//			if(rest) //Not used with new UI
//				if(resting || lying || sleeping)		rest.icon_state = "rest1"
//				else									rest.icon_state = "rest0"
		if(toxin)
			if(hal_screwyhud == 4 || toxins_alert)	toxin.icon_state = "tox1"
			else									toxin.icon_state = "tox0"
		if(oxygen)
			if(hal_screwyhud == 3 || oxygen_alert)	oxygen.icon_state = "oxy1"
			else									oxygen.icon_state = "oxy0"
		if(fire)
			if(fire_alert)							fire.icon_state = "fire[fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
			else									fire.icon_state = "fire0"

		if(bodytemp)
			switch(bodytemperature) //310.055 optimal body temp
				if(370 to INFINITY)		bodytemp.icon_state = "temp4"
				if(350 to 370)			bodytemp.icon_state = "temp3"
				if(335 to 350)			bodytemp.icon_state = "temp2"
				if(320 to 335)			bodytemp.icon_state = "temp1"
				if(300 to 320)			bodytemp.icon_state = "temp0"
				if(295 to 300)			bodytemp.icon_state = "temp-1"
				if(280 to 295)			bodytemp.icon_state = "temp-2"
				if(260 to 280)			bodytemp.icon_state = "temp-3"
				else					bodytemp.icon_state = "temp-4"

		if(blind)
			if(blinded)
				blind.layer = 18
			else
				blind.layer = 0

		if(disabilities & NEARSIGHTED)	//This looks meh but saves a lot of memory by not requiring to add var/prescription
			if(glasses)	//To every /obj/item
				var/obj/item/clothing/glasses/G = glasses
				if(!G.prescription)
					client.screen += global_hud.vimpaired
			else
				client.screen += global_hud.vimpaired

		if(eye_blurry)
			if(!istype(global_hud.blurry,/obj/screen))
				global_hud.blurry = getFromPool(/obj/screen)
				global_hud.blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
				global_hud.blurry.icon_state = "blurry"
				global_hud.blurry.layer = 17
				global_hud.blurry.mouse_opacity = 0
			client.screen += global_hud.blurry

		if(druggy)
			if(!istype(global_hud.druggy,/obj/screen))
				global_hud.druggy = getFromPool(/obj/screen)
				global_hud.druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
				global_hud.druggy.icon_state = "druggy"
				global_hud.druggy.layer = 17
				global_hud.druggy.mouse_opacity = 0
			client.screen += global_hud.druggy

		var/masked = 0

		if(istype(head, /obj/item/clothing/head/welding) || istype(head, /obj/item/clothing/head/helmet/space/unathi))
			var/obj/item/clothing/head/welding/O = head
			if(!O.up && tinted_weldhelh)
				client.screen += global_hud.darkMask
				masked = 1

		if(!masked && istype(glasses, /obj/item/clothing/glasses/welding) && !istype(glasses, /obj/item/clothing/glasses/welding/superior))
			var/obj/item/clothing/glasses/welding/O = glasses
			if(!O.up && tinted_weldhelh)
				client.screen += global_hud.darkMask

		if(machine)
			if(!machine.check_eye(src))
				reset_view(null)
			if(iscamera(client.eye))
				var/obj/machinery/camera/C = client.eye
				sight = 0
				if(C.isXRay())
					sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS

		else
			var/isRemoteObserve = 0
			if((M_REMOTE_VIEW in mutations) && remoteview_target)
				isRemoteObserve = 1
				//Is he unconscious or dead?
				if(remoteview_target.stat!=CONSCIOUS)
					to_chat(src, "<span class='warning'>Your psy-connection grows too faint to maintain!</span>")
					isRemoteObserve = 0

				//Does he have psy resist?
				if(M_PSY_RESIST in remoteview_target.mutations)
					to_chat(src, "<span class='warning'>Your mind is shut out!</span>")
					isRemoteObserve = 0

				//Not on the station or mining?
				var/turf/temp_turf = get_turf(remoteview_target)

				if(temp_turf && (temp_turf.z != 1 && temp_turf.z != 5) || remoteview_target.stat!=CONSCIOUS)
					to_chat(src, "<span class='warning'>Your psy-connection grows too faint to maintain!</span>")
					isRemoteObserve = 0
			if(!isRemoteObserve && client && !client.adminobs && !isTeleViewing(client.eye))
				remoteview_target = null
				reset_view(null)
	return 1
