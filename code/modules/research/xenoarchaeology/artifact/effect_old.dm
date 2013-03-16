//

/datum/artifact_effect
	var/artifact_id = ""       // Display ID of the spawning artifact
	var/trigger = "touch"      // What activates it?
	var/triggerX = "none"      // Used for more varied triggers
	var/effecttype = "healing" // What does it do?
	var/effectmode = "aura"    // How does it carry out the effect?
	var/aurarange = 4          // How far the artifact will extend an aura effect.
	var/list/created_field
	var/archived_loc

/datum/artifact_effect/New()
	//
	created_field = new()

/datum/artifact_effect/proc/GetOriginString(var/origin)

/datum/artifact_effect/proc/GetEffectString(var/effect)

/datum/artifact_effect/proc/GetTriggerString(var/trigger)

/datum/artifact_effect/proc/GetRangeString(var/range)
	switch(effectmode)
		if("aura") return "Constant Short-Range Energy Field"
		if("pulse")
			if(aurarange > 7) return "Long Range Energy Pulses"
			else return "Medium Range Energy Pulses"
		if("worldpulse") return "Extreme Range Energy Pulses"
		if("contact") return "Requires contact with subject"
		else return "Unknown Range"

/datum/artifact_effect/proc/HaltEffect()
	for(var/obj/effect/energy_field/F in created_field)
		created_field.Remove(F)
		del F

/datum/artifact_effect/proc/UpdateEffect(var/atom/originator)
	/*for(var/obj/effect/energy_field/F in created_field)
		created_field.Remove(F)
		del F*/
	if(originator.loc != archived_loc)
		archived_loc = originator.loc
		update_move(originator)

	for(var/obj/effect/energy_field/E in created_field)
		if(E.strength < 5)
			E.Strengthen(0.2)

/datum/artifact_effect/proc/DoEffect(var/atom/originator)
	archived_loc = originator.loc
	if (src.effectmode == "contact")
		var/mob/living/user = originator
		if(!user)
			return
		switch(src.effecttype)
			if("healing")
				//caeltodo
				if (istype(user, /mob/living/carbon/human/))
					user << "\blue You feel a soothing energy invigorate you."

					var/mob/living/carbon/human/H = user
					for(var/datum/organ/external/affecting in H.organs)
						if(!affecting)    continue
						if(!istype(affecting, /datum/organ/external))    continue
						affecting.heal_damage(25, 25)    //fixes getting hit after ingestion, killing you when game updates organ health
						//user:heal_organ_damage(25, 25)
						//
						user.adjustOxyLoss(-25)
						user.adjustToxLoss(-25)
						user.adjustBruteLoss(-25)
						user.adjustFireLoss(-25)
						user.adjustBrainLoss(-25)
						user.radiation -= min(user.radiation, 25)
						user.nutrition += 50
						H.bodytemperature = initial(H.bodytemperature)
						//
						H.vessel.add_reagent("blood",50)
						spawn(1)
							H.fixblood()
						H.regenerate_icons()
					return 1
					//
				if (istype(user, /mob/living/carbon/monkey/))
					user << "\blue You feel a soothing energy invigorate you."
					user.adjustOxyLoss(-25)
					user.adjustToxLoss(-25)
					user.adjustBruteLoss(-25)
					user.adjustFireLoss(-25)
					user.adjustBrainLoss(-25)
					return 1
				else user << "Nothing happens."
			if("injure")
				if (istype(user, /mob/living/carbon/))
					user << "\red A painful discharge of energy strikes you!"
					user.adjustOxyLoss(rand(5,25))
					user.adjustToxLoss(rand(5,25))
					user.adjustBruteLoss(rand(5,25))
					user.adjustFireLoss(rand(5,25))
					user.adjustBrainLoss(rand(5,25))
					user.radiation += 25
					user.nutrition -= min(50, user.nutrition)
					user.make_dizzy(6)
					user.weakened += 6
					return 1
				else user << "Nothing happens."
			if("stun")
				if (istype(user, /mob/living/carbon/))
					user << "\red A powerful force overwhelms your consciousness."
					user.weakened += 45
					user.stuttering += 45
					if(prob(50))
						user.stunned += rand(1,10)
					return 1
				else user << "Nothing happens."
			if("roboheal")
				if (istype(user, /mob/living/silicon/robot))
					user << "\blue Your systems report damaged components mending by themselves!"
					user.adjustBruteLoss(rand(-10,-30))
					user.adjustFireLoss(rand(-10,-30))
					return 1
				else user << "Nothing happens."
			if("robohurt")
				if (istype(user, /mob/living/silicon/robot))
					user << "\red Your systems report severe damage has been inflicted!"
					user.adjustBruteLoss(rand(10,50))
					user.adjustFireLoss(rand(10,50))
					return 1
				else user << "Nothing happens."
			if("forcefield")
				while(created_field.len < 16)
					var/obj/effect/energy_field/E = new (locate(user.x,user.y,user.z))
					created_field.Add(E)
					E.strength = 1
					E.density = 1
					E.anchored = 1
					E.invisibility = 0
				return 1
			if("teleport")
				var/list/randomturfs = new/list()
				for(var/turf/T in orange(user, 50))
					if(!istype(T, /turf/simulated/floor) || T.density)
						continue
					randomturfs.Add(T)
				if(randomturfs.len > 0)
					user << "\red You are suddenly zapped away elsewhere!"
					if (user.buckled)
						user.buckled.unbuckle()
					user.loc = pick(randomturfs)
					var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(originator)) //no idea what the 0 is
					sparks.start()
				return 1
			if("sleepy")
				user << pick("\blue You feel like taking a nap.","\blue You feel a yawn coming on.","\blue You feel a little tired.")
				user.drowsyness = min(user.drowsyness + rand(5,25), 50)
				user.eye_blurry = min(user.eye_blurry + rand(1,3), 50)
				return 1
	else if (src.effectmode == "aura")
		switch(src.effecttype)
			//caeltodo
			if("healing")
				for (var/mob/living/carbon/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					if(prob(10)) M << "\blue You feel a soothing energy radiating from something nearby."
					M.adjustBruteLoss(-1)
					M.adjustFireLoss(-1)
					M.adjustToxLoss(-1)
					M.adjustOxyLoss(-1)
					M.adjustBrainLoss(-1)
					M.updatehealth()
				return 1
			if("injure")
				for (var/mob/living/carbon/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					if(prob(10)) M << "\red You feel a painful force radiating from something nearby."
					M.adjustBruteLoss(1)
					M.adjustFireLoss(1)
					M.adjustToxLoss(1)
					M.adjustOxyLoss(1)
					M.adjustBrainLoss(1)
					M.updatehealth()
				return 1
			if("stun")
				for (var/mob/living/carbon/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					if(prob(10)) M << "\red Energy radiating from the [originator] is making you feel numb."
					if(prob(20))
						M << "\red Your body goes numb for a moment."
						M.stunned += 2
						M.weakened += 2
						M.stuttering += 2
				return 1
			if("roboheal")
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					if(prob(10)) M << "\blue SYSTEM ALERT: Beneficial energy field detected!"
					M.adjustBruteLoss(-1)
					M.adjustFireLoss(-1)
					M.updatehealth()
				return 1
			if("robohurt")
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					if(prob(10)) M << "\red SYSTEM ALERT: Harmful energy field detected!"
					M.adjustBruteLoss(1)
					M.adjustFireLoss(1)
					M.updatehealth()
				return 1
			if("cellcharge")
				for (var/obj/machinery/power/apc/C in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/B in C.contents)
						B.charge += 10
				for (var/obj/machinery/power/smes/S in range (src.aurarange,originator)) S.charge += 20
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge += 10
						if(prob(10)) M << "\blue SYSTEM ALERT: Energy boosting field detected!"
				return 1
			if("celldrain")
				for (var/obj/machinery/power/apc/C in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/B in C.contents)
						B.charge = max(B.charge-10,0)
				for (var/obj/machinery/power/smes/S in range (src.aurarange,originator))
					S.charge = max(S.charge-20,0)
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge = max(D.charge-10,0)
						if(prob(10)) M << "\red SYSTEM ALERT: Energy draining field detected!"
				return 1
			if("planthelper")
				for (var/obj/machinery/hydroponics/H in range(src.aurarange,originator))
					//makes weeds and shrooms and stuff more potent too
					if(H.planted)
						H.waterlevel += 2
						H.nutrilevel += 2
						if(H.toxic > 0)
							H.toxic -= 1
						H.health += 1
						if(H.pestlevel > 0)
							H.pestlevel -= 1
						if(H.weedlevel > 0)
							H.weedlevel -= 1
						H.lastcycle += 5
				return 1
			if("sleepy")
				for (var/mob/living/carbon/M in range(src.aurarange,originator))
					if(prob(10))
						M << pick("\blue You feel like taking a nap.","\blue You feel a yawn coming on.","\blue You feel a little tired.")
					M.drowsyness = min(M.drowsyness + 1, 25)
					M.eye_blurry = min(M.eye_blurry + 1, 25)
				return 1
	else if (src.effectmode == "pulse")
		for(var/mob/O in viewers(originator, null))
			O.show_message(text("<b>[]</b> emits a pulse of energy!", originator), 1)
		switch(src.effecttype)
			//caeltodo
			if("healing")
				for (var/mob/living/carbon/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					M << "\blue A wave of energy invigorates you."
					M.adjustBruteLoss(-5)
					M.adjustFireLoss(-5)
					M.adjustToxLoss(-5)
					M.adjustOxyLoss(-5)
					M.adjustBrainLoss(-5)
					M.updatehealth()
				return 1
			if("injure")
				for (var/mob/living/carbon/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					M << "\red A wave of energy causes you great pain!"
					M.adjustBruteLoss(5)
					M.adjustFireLoss(5)
					M.adjustToxLoss(5)
					M.adjustOxyLoss(5)
					M.adjustBrainLoss(5)
					M.make_dizzy(6)
					M.weakened += 3
					M.updatehealth()
				return 1
			if("stun")
				for (var/mob/living/carbon/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					M << "\red A wave of energy overwhelms your senses!"
					M.paralysis += 3
					M.weakened += 4
					M.stuttering += 4
				return 1
			if("roboheal")
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					M << "\blue SYSTEM ALERT: Structural damage has been repaired by energy pulse!"
					M.adjustBruteLoss(-10)
					M.adjustFireLoss(-10)
					M.updatehealth()
				return 1
			if("robohurt")
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					M << "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!"
					M.adjustBruteLoss(10)
					M.adjustFireLoss(10)
					M.updatehealth()
				return 1
			if("cellcharge")
				for (var/obj/machinery/power/apc/C in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/B in C.contents)
						B.charge += 250
				for (var/obj/machinery/power/smes/S in range (src.aurarange,originator)) S.charge += 400
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge += 250
						M << "\blue SYSTEM ALERT: Large energy boost detected!"
				return 1
			if("celldrain")
				for (var/obj/machinery/power/apc/C in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/B in C.contents)
						B.charge = max(B.charge-500,0)
				for (var/obj/machinery/power/smes/S in range (src.aurarange,originator))
					S.charge = max(S.charge-400,0)
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge = max(D.charge-500,0)
						M << "\red SYSTEM ALERT: Severe energy drain detected!"
				return 1
			if("planthelper")
				//makes weeds and shrooms and stuff more potent too
				for (var/obj/machinery/hydroponics/H in range(src.aurarange,originator))
					if(H.planted)
						H.dead = 0
						H.waterlevel = 200
						H.nutrilevel = 200
						H.toxic = 0
						H.health = 100
						H.pestlevel = 0
						H.weedlevel = 0
						H.lastcycle = H.cycledelay
				return 1
			if("teleport")
				for (var/mob/living/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					var/list/randomturfs = new/list()
					for(var/turf/T in orange(M, 30))
						if(!istype(T, /turf/simulated/floor) || T.density)
							continue
						randomturfs.Add(T)
					if(randomturfs.len > 0)
						M << "\red You are displaced by a strange force!"
						if(M.buckled)
							M.buckled.unbuckle()
						M.loc = pick(randomturfs)
						var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
						sparks.set_up(3, 0, get_turf(originator)) //no idea what the 0 is
						sparks.start()
				return 1
			if("dnaswitch")
				for(var/mob/living/H in range(src.aurarange,originator))
					if(ishuman(H) && istype(H:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(H:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue

					if(prob(30))
						H << pick("\green You feel a little different.","\green You feel strange.","\green You feel different.")
					//todo
					if (H.gender == FEMALE)
						H.gender = MALE
					else
						H.gender = FEMALE
					/*H.dna.ready_dna(H)
					H.update_body()
					H.update_face()*/
				return 1
			if("emp")
				empulse(get_turf(originator), aurarange/2, aurarange)
				return 1
			if("sleepy")
				for (var/mob/living/carbon/M in range(src.aurarange,originator))
					if(prob(30))
						M << pick("\blue You feel like taking a nap.","\blue You feel a yawn coming on.","\blue You feel a little tired.")
					if(prob(50))
						M.drowsyness = min(M.drowsyness + rand(1,5), 25)
					if(prob(50))
						M.eye_blurry = min(M.eye_blurry + rand(1,5), 25)
				return 1
	else if (src.effectmode == "worldpulse")
		for(var/mob/O in viewers(originator, null))
			O.show_message(text("<b>[]</b> emits a powerful burst of energy!", originator), 1)
		switch(src.effecttype)
			if("healing")
				for (var/mob/living/carbon/M in range(200, originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					M << "\blue Waves of soothing energy wash over you."
					M.adjustBruteLoss(-3)
					M.adjustFireLoss(-3)
					M.adjustToxLoss(-3)
					M.adjustOxyLoss(-3)
					M.adjustBrainLoss(-3)
					M.updatehealth()
				return 1
			if("injure")
				for (var/mob/living/carbon/human/M in range(200, originator))
					M << "\red A wave of painful energy strikes you!"
					M.adjustBruteLoss(3)
					M.adjustFireLoss(3)
					M.adjustToxLoss(3)
					M.adjustOxyLoss(3)
					M.adjustBrainLoss(3)
					M.updatehealth()
				return 1
			if("stun")
				for (var/mob/living/carbon/M in range(200, originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					M << "\red A powerful force causes you to black out momentarily."
					M.paralysis += 5
					M.weakened += 8
					M.stuttering += 8
				return 1
			if("roboheal")
				for (var/mob/living/silicon/robot/M in range(200, originator))
					M << "\blue SYSTEM ALERT: Structural damage has been repaired by energy pulse!"
					M.adjustBruteLoss(-5)
					M.adjustFireLoss(-5)
					M.updatehealth()
				return 1
			if("robohurt")
				for (var/mob/living/silicon/robot/M in range(200, originator))
					M << "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!"
					M.adjustBruteLoss(5)
					M.adjustFireLoss(5)
					M.updatehealth()
				return 1
			if("cellcharge")
				for (var/obj/machinery/power/apc/C in range(200, originator))
					for (var/obj/item/weapon/cell/B in C.contents)
						B.charge += 100
				for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge += 250
				for (var/mob/living/silicon/robot/M in world)
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge += 100
						M << "\blue SYSTEM ALERT: Energy boost detected!"
				return 1
			if("celldrain")
				for (var/obj/machinery/power/apc/C in range(200, originator))
					for (var/obj/item/weapon/cell/B in C.contents)
						B.charge = max(B.charge-250,0)
				for (var/obj/machinery/power/smes/S in range (src.aurarange,src))
					S.charge = max(S.charge-250,0)
				for (var/mob/living/silicon/robot/M in world)
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge = max(D.charge-250,0)
						M << "\red SYSTEM ALERT: Energy drain detected!"
				return 1
			if("teleport")
				for (var/mob/living/M in range(200, originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					var/list/randomturfs = new/list()
					for(var/turf/T in orange(M, 15))
						if(!istype(T, /turf/simulated/floor) || T.density)
							continue
						randomturfs.Add(T)
					if(randomturfs.len > 0)
						M << "\red You are displaced by a strange force!"
						if(M.buckled)
							M.buckled.unbuckle()
						M.loc = pick(randomturfs)
						var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
						sparks.set_up(3, 0, get_turf(originator)) //no idea what the 0 is
						sparks.start()
				return 1
			if("dnaswitch")
				for(var/mob/living/H in range(200, originator))
					if(ishuman(H) && istype(H:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(H:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue

					if(prob(30))
						H << pick("\green You feel a little different.","\green You feel strange.","\green You feel different.")
					//todo
					if (H.gender == FEMALE)
						H.gender = MALE
					else
						H.gender = FEMALE
					/*H.dna.ready_dna(H)
					H.update_body()
					H.update_face()*/
				return 1
			if("sleepy")
				for(var/mob/living/H in range(200, originator))
					H.drowsyness = min(H.drowsyness + rand(5,15), 50)
					H.eye_blurry = min(H.eye_blurry + rand(5,15), 50)
				return 1

//initially for the force field artifact
/datum/artifact_effect/proc/update_move(var/atom/originator)
	switch(effecttype)
		if("forcefield")
			while(created_field.len < 16)
				//for now, just instantly respawn the fields when they get destroyed
				var/obj/effect/energy_field/E = new (locate(originator.x,originator.y,originator))
				created_field.Add(E)
				E.strength = 1
				E.density = 1
				E.anchored = 1
				E.invisibility = 0

			var/obj/effect/energy_field/E = created_field[1]
			E.loc = locate(originator.x + 2,originator.y + 2,originator.z)
			E = created_field[2]
			E.loc = locate(originator.x + 2,originator.y + 1,originator.z)
			E = created_field[3]
			E.loc = locate(originator.x + 2,originator.y,originator.z)
			E = created_field[4]
			E.loc = locate(originator.x + 2,originator.y - 1,originator.z)
			E = created_field[5]
			E.loc = locate(originator.x + 2,originator.y - 2,originator.z)
			E = created_field[6]
			E.loc = locate(originator.x + 1,originator.y + 2,originator.z)
			E = created_field[7]
			E.loc = locate(originator.x + 1,originator.y - 2,originator.z)
			E = created_field[8]
			E.loc = locate(originator.x,originator.y + 2,originator.z)
			E = created_field[9]
			E.loc = locate(originator.x,originator.y - 2,originator.z)
			E = created_field[10]
			E.loc = locate(originator.x - 1,originator.y + 2,originator.z)
			E = created_field[11]
			E.loc = locate(originator.x - 1,originator.y - 2,originator.z)
			E = created_field[12]
			E.loc = locate(originator.x - 2,originator.y + 2,originator.z)
			E = created_field[13]
			E.loc = locate(originator.x - 2,originator.y + 1,originator.z)
			E = created_field[14]
			E.loc = locate(originator.x - 2,originator.y,originator.z)
			E = created_field[15]
			E.loc = locate(originator.x - 2,originator.y - 1,originator.z)
			E = created_field[16]
			E.loc = locate(originator.x - 2,originator.y - 2,originator.z)
