
/datum/artifact_effect
	var/artifact_id = ""       // Display ID of the spawning artifact
	var/trigger = "touch"      // What activates it?
	var/triggerX = "none"      // Used for more varied triggers
	var/effecttype = "healing" // What does it do?
	var/effectmode = "aura"    // How does it carry out the effect?
	var/aurarange = 4          // How far the artifact will extend an aura effect.
	var/list/created_field

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
	for(var/obj/effect/energy_field/F in created_field)
		created_field.Remove(F)
		del F

/datum/artifact_effect/proc/DoEffect(var/atom/originator)
	if (src.effectmode == "contact")
		var/mob/user = originator
		if(!user)
			return
		switch(src.effecttype)
			if("healing")
				if (istype(user, /mob/living/carbon/human/))
					user << "\blue You feel a soothing energy invigorate you."

					var/mob/living/carbon/human/H = user
					for(var/A in H.organs)
						var/datum/organ/external/affecting = null
						if(!H.organs[A])    continue
						affecting = H.organs[A]
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
						H.update_body()
						H.update_face()
						H.UpdateDamageIcon()
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
					user.adjustOxyLoss(25)
					user.adjustToxLoss(25)
					user.adjustBruteLoss(25)
					user.adjustFireLoss(25)
					user.adjustBrainLoss(25)
					user.radiation += 25
					user.nutrition -= min(50, user.nutrition)
					user.stunned += 6
					user.weakened += 6
					return 1
				else user << "Nothing happens."
			/*if("stun")
				if (istype(user, /mob/living/carbon/))
					user << "\red A powerful force overwhelms your consciousness."
					user.paralysis += 30
					user.stunned += 45
					user.weakened += 45
					user.stuttering += 45
					return 1
				else user << "Nothing happens."*/
			if("roboheal")
				if (istype(user, /mob/living/silicon/robot))
					user << "\blue Your systems report damaged components mending by themselves!"
					user.adjustBruteLoss(-30)
					user.adjustFireLoss(-30)
					return 1
				else user << "Nothing happens."
			if("robohurt")
				if (istype(user, /mob/living/silicon/robot))
					user << "\red Your systems report severe damage has been inflicted!"
					user.adjustBruteLoss(40)
					user.adjustFireLoss(40)
					return 1
				else user << "Nothing happens."
			if("forcefield")
				var/obj/effect/energy_field/E = new /obj/effect/energy_field(locate(user.x + 2,user.y,user.z))
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x + 2,user.y + 1,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x + 2,user.y + 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x + 2,user.y - 1,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x + 2,user.y - 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x - 2,user.y,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x - 2,user.y + 1,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x - 2,user.y + 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x - 2,user.y - 1,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x - 2,user.y - 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x,user.y + 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x + 1,user.y + 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x - 1,user.y + 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x,user.y - 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x + 1,user.y - 2,user.z))
				created_field.Add(E)
				E.strength = 1
				E.invisibility = 0
				E = new /obj/effect/energy_field(locate(user.x - 1,user.y - 2,user.z))
				created_field.Add(E)
				E.strength = 1
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
					user.loc = pick(randomturfs)
					var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(src)) //no idea what the 0 is
					sparks.start()
				return 1
	else if (src.effectmode == "aura")
		switch(src.effecttype)
			if("healing")
				for (var/mob/living/carbon/human/M in range(src.aurarange,originator))
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
				for (var/mob/living/carbon/human/M in range(src.aurarange,originator))
					if(istype(ishuman(M) && M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					if(prob(10)) M << "\red You feel a painful force radiating from something nearby."
					M.adjustBruteLoss(1)
					M.adjustFireLoss(1)
					M.adjustToxLoss(1)
					M.adjustOxyLoss(1)
					M.adjustBrainLoss(1)
					M.updatehealth()
				return 1
			/*if("stun")
				for (var/mob/living/carbon/human/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					if(prob(10)) M << "\red Energy radiating from the [originator] is making you feel numb."
					if(prob(20))
						M << "\red Your body goes numb for a moment."
						M.stunned += 2
						M.weakened += 2
						M.stuttering += 2
				return 1*/
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
						B.charge -= 10
				for (var/obj/machinery/power/smes/S in range (src.aurarange,originator)) S.charge -= 20
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge -= 10
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
	else if (src.effectmode == "pulse")
		for(var/mob/O in viewers(originator, null))
			O.show_message(text("<b>[]</b> emits a pulse of energy!", originator), 1)
		switch(src.effecttype)
			if("healing")
				for (var/mob/living/carbon/human/M in range(src.aurarange,originator))
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
				for (var/mob/living/carbon/human/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					M << "\red A wave of energy causes you great pain!"
					M.adjustBruteLoss(5)
					M.adjustFireLoss(5)
					M.adjustToxLoss(5)
					M.adjustOxyLoss(5)
					M.adjustBrainLoss(5)
					M.stunned += 3
					M.weakened += 3
					M.updatehealth()
				return 1
			/*if("stun")
				for (var/mob/living/carbon/human/M in range(src.aurarange,originator))
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					M << "\red A wave of energy overwhelms your senses!"
					M.paralysis += 3
					M.stunned += 4
					M.weakened += 4
					M.stuttering += 4
				return 1*/
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
						B.charge -= 500
				for (var/obj/machinery/power/smes/S in range (src.aurarange,originator)) S.charge -= 400
				for (var/mob/living/silicon/robot/M in range(src.aurarange,originator))
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge -= 500
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
						M.loc = pick(randomturfs)
						var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
						sparks.set_up(3, 0, get_turf(originator)) //no idea what the 0 is
						sparks.start()
				return 1
	else if (src.effectmode == "worldpulse")
		for(var/mob/O in viewers(originator, null))
			O.show_message(text("<b>[]</b> emits a powerful burst of energy!", originator), 1)
		switch(src.effecttype)
			if("healing")
				for (var/mob/living/carbon/human/M in world)
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
				for (var/mob/living/carbon/human/M in world)
					M << "\red A wave of painful energy strikes you!"
					M.adjustBruteLoss(3)
					M.adjustFireLoss(3)
					M.adjustToxLoss(3)
					M.adjustOxyLoss(3)
					M.adjustBrainLoss(3)
					M.updatehealth()
				return 1
			/*if("stun")
				for (var/mob/living/carbon/human/M in world)
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					M << "\red A powerful force causes you to black out momentarily."
					M.paralysis += 5
					M.stunned += 8
					M.weakened += 8
					M.stuttering += 8
				return 1*/
			if("roboheal")
				for (var/mob/living/silicon/robot/M in world)
					M << "\blue SYSTEM ALERT: Structural damage has been repaired by energy pulse!"
					M.adjustBruteLoss(-5)
					M.adjustFireLoss(-5)
					M.updatehealth()
				return 1
			if("robohurt")
				for (var/mob/living/silicon/robot/M in world)
					M << "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!"
					M.adjustBruteLoss(5)
					M.adjustFireLoss(5)
					M.updatehealth()
				return 1
			if("cellcharge")
				for (var/obj/machinery/power/apc/C in world)
					for (var/obj/item/weapon/cell/B in C.contents)
						B.charge += 100
				for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge += 250
				for (var/mob/living/silicon/robot/M in world)
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge += 100
						M << "\blue SYSTEM ALERT: Energy boost detected!"
				return 1
			if("celldrain")
				for (var/obj/machinery/power/apc/C in world)
					for (var/obj/item/weapon/cell/B in C.contents)
						B.charge -= 250
				for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge -= 250
				for (var/mob/living/silicon/robot/M in world)
					for (var/obj/item/weapon/cell/D in M.contents)
						D.charge -= 250
						M << "\red SYSTEM ALERT: Energy drain detected!"
				return 1
			if("teleport")
				for (var/mob/living/M in world)
					if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
						continue
					var/list/randomturfs = new/list()
					for(var/turf/T in orange(M, 15))
						if(!istype(T, /turf/simulated/floor) || T.density)
							continue
						randomturfs.Add(T)
					if(randomturfs.len > 0)
						M << "\red You are displaced by a strange force!"
						M.loc = pick(randomturfs)
						var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
						sparks.set_up(3, 0, get_turf(originator)) //no idea what the 0 is
						sparks.start()
				return 1
