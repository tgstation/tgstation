//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_regular_hud_updates()
	if(!client)
		return 0

	sight &= ~BLIND

	regular_hud_updates()

	update_action_buttons()

	if(stat == UNCONSCIOUS && health <= config.health_threshold_crit)
		var/severity = 0
		switch(health)
			if(-20 to -10) severity = 1
			if(-30 to -20) severity = 2
			if(-40 to -30) severity = 3
			if(-50 to -40) severity = 4
			if(-60 to -50) severity = 5
			if(-70 to -60) severity = 6
			if(-80 to -70) severity = 7
			if(-90 to -80) severity = 8
			if(-95 to -90) severity = 9
			if(-INFINITY to -95) severity = 10
		overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
	else
		clear_fullscreen("crit")
		if(oxyloss)
			var/severity = 0
			switch(oxyloss)
				if(10 to 20) severity = 1
				if(20 to 25) severity = 2
				if(25 to 30) severity = 3
				if(30 to 35) severity = 4
				if(35 to 40) severity = 5
				if(40 to 45) severity = 6
				if(45 to INFINITY) severity = 7
			overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
		else
			clear_fullscreen("oxy")
		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/severity = 0
			switch(hurtdamage)
				if(5 to 15) severity = 1
				if(15 to 30) severity = 2
				if(30 to 45) severity = 3
				if(45 to 70) severity = 4
				if(70 to 85) severity = 5
				if(85 to INFINITY) severity = 6
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")
			//damageoverlay.overlays += I
	if(stat == DEAD)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		if(!druggy)
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if(healths)
			healths.icon_state = "health7" //DEAD healthmeter
		return
	else
		sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)

		var/datum/organ/internal/eyes/E = src.internal_organs_by_name["eyes"]
		if(E)
			see_in_dark = E.see_in_dark //species.darksight
		else
			see_in_dark = species.darksight
			// You should really be blind but w/e.

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
					see_in_dark = max(see_in_dark, G.see_in_dark)
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

			if(ticker && ticker.hardcore_mode) //Hardcore mode: flashing nutrition indicator when starving!
				if(nutrition < STARVATION_MIN)
					nutrition_icon.icon_state = "nutrition5"

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
			if(has_reagent_in_blood("capsaicin"))
				bodytemp.icon_state = "temp4"
			else if(has_reagent_in_blood("frostoil"))
				bodytemp.icon_state = "temp-4"
			else if(!(get_thermal_loss(loc.return_air()) > 0.1) || bodytemperature > T0C + 50)
				switch(bodytemperature) //310.055 optimal body temp
					if(370 to INFINITY)		bodytemp.icon_state = "temp4"
					if(350 to 370)			bodytemp.icon_state = "temp3"
					if(335 to 350)			bodytemp.icon_state = "temp2"
					if(320 to 335)			bodytemp.icon_state = "temp1"
					if(305 to 320)			bodytemp.icon_state = "temp0"
					if(303 to 305)			bodytemp.icon_state = "temp-1"
					if(300 to 303)			bodytemp.icon_state = "temp-2"
					if(290 to 295)			bodytemp.icon_state = "temp-3"
					if(0   to 290)			bodytemp.icon_state = "temp-4"
			else if(is_vessel_dilated() && undergoing_hypothermia() == MODERATE_HYPOTHERMIA)
				bodytemp.icon_state = "temp4" // yes, this is intentional - this is the cause of "paradoxical undressing", ie feeling 2hot when hypothermic
			else
				switch(get_thermal_loss(loc.return_air())) // How many degrees of celsius we are losing per tick.
					if(0.1 to 0.15)
						bodytemp.icon_state = "temp-1"
					if(0.15 to 0.2)
						bodytemp.icon_state = "temp-2"
					if(0.2 to 0.4)
						bodytemp.icon_state = "temp-3"
					if(0.4 to INFINITY)
						bodytemp.icon_state = "temp-4"

		if(disabilities & NEARSIGHTED)	//This looks meh but saves a lot of memory by not requiring to add var/prescription
			if(glasses)	//To every /obj/item
				var/obj/item/clothing/glasses/G = glasses
				if(!G.prescription)
					overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
				else
					clear_fullscreen("nearsighted")
			else
				overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		else
			clear_fullscreen("nearsighted")
		if(eye_blind || blinded)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		else
			clear_fullscreen("blind")
		if(eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
		else
			clear_fullscreen("blurry")
		if(druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
		else
			clear_fullscreen("high")

		var/masked = 0
		if(istype(head, /obj/item/clothing/head/welding) || istype(head, /obj/item/clothing/head/helmet/space/unathi))
			var/obj/item/clothing/head/welding/O = head
			if(!O.up && tinted_weldhelh)
				overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
				masked = 1
			else
				clear_fullscreen("tint")
		else
			clear_fullscreen("tint")

		if(!masked && istype(glasses, /obj/item/clothing/glasses/welding) && !istype(glasses, /obj/item/clothing/glasses/welding/superior))
			var/obj/item/clothing/glasses/welding/O = glasses
			if(!O.up && tinted_weldhelh)
				overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
			else
				clear_fullscreen("tint")

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
