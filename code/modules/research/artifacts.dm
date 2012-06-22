//Part of ISaidNo's public release around July 2011(ish), multiple changes
//many thanks

/obj/machinery/artifact
	name = "alien artifact"
	desc = "A large alien device."
	icon = 'anomaly.dmi'
	icon_state = "ano0"
	anchored = 0
	density = 1
	var/display_id = ""        // Artifact ID to display once successfully scanned
	var/activated = 0          // Whether or not the artifact has been unlocked.
	var/charged = 1            // Whether the artifact is ready to have it's effect.
	var/chargetime = 0         // How much time until the artifact is charged.
	var/recharge = 5           // How long does it take this artifact to recharge?
	var/origin = null          // Used in the randomisation/research of the artifact.
	var/trigger = "touch"      // What activates it?
	var/triggerX = "none"      // Used for more varied triggers
	var/effecttype = "healing" // What does it do?
	var/effectmode = "aura"    // How does it carry out the effect?
	var/aurarange = 4          // How far the artifact will extend an aura effect.

	New()
		..()
		// Origin and appearance randomisation
		// cael - need some more icons
		src.origin = pick("ancient","martian","wizard","eldritch","precursor")
		switch(src.origin)
			if("ancient") src.icon_state = pick("ano2")
			if("martian") src.icon_state = pick("ano4")
			if("wizard") src.icon_state = pick("ano0","ano1")
			if("eldritch") src.icon_state = pick("ano3")
			if("precursor") src.icon_state = pick("ano5")
		// Low-ish random chance to not look like it's origin
		if(prob(20)) src.icon_state = pick("ano0","ano1","ano2","ano3","ano4","ano5")
		// Power randomisation
		src.trigger = pick("force","energy","chemical","heat","touch")
		if (src.trigger == "chemical") src.triggerX = pick("hydrogen","corrosive","volatile","toxic")
		// Ancient Artifacts focus on robotic/technological effects
		// Martian Artifacts focus on biological effects
		// Wizard Artifacts focus on weird shit
		// Eldritch Artifacts are 100% bad news
		// Precursor Artifacts do everything
		switch(src.origin)
			if("ancient") src.effecttype = pick("roboheal","robohurt","cellcharge","celldrain")
			if("martian") src.effecttype = pick("healing","injure","stun","planthelper")
			if("wizard") src.effecttype = pick("stun","forcefield","teleport")
			if("eldritch") src.effecttype = pick("injure","stun","robohurt","celldrain")
			if("precursor") src.effecttype = pick("healing","injure","stun","roboheal","robohurt","cellcharge","celldrain","planthelper","forcefield","teleport")
		// Select range based on the power
		var/canworldpulse = 1
		switch(src.effecttype)
			if("healing") src.effectmode = pick("aura","pulse","contact")
			if("injure") src.effectmode = pick("aura","pulse","contact")
			if("stun") src.effectmode = pick("aura","pulse","contact")
			if("roboheal") src.effectmode = pick("aura","pulse","contact")
			if("robohurt") src.effectmode = pick("aura","pulse","contact")
			if("cellcharge") src.effectmode = pick("aura","pulse")
			if("celldrain") src.effectmode = pick("aura","pulse")
			if("planthelper")
				src.effectmode = pick("aura","pulse")
				canworldpulse = 0
			if("forcefield")
				src.effectmode = "contact"
				canworldpulse = 0
			if("teleport") src.effectmode = pick("pulse","contact")
		// Recharge timer & range setup
		if (src.effectmode == "aura") src.aurarange = rand(1,4)
		if (src.effectmode == "contact")
			src.recharge = rand(5,15)
		if (src.effectmode == "pulse")
			src.aurarange = rand(2,14)
			src.recharge = rand(5,20)
		if (canworldpulse == 1 && prob(1))
			src.effectmode = "worldpulse"
			src.recharge = rand(40,120)

		display_id += pick("kappa","sigma","antaeres","beta","lorard","omicron","iota","upsilon","omega","gamma","delta")
		display_id += "-"
		display_id += num2text(rand(100,999))

	attack_hand(var/mob/user as mob)
		if (istype(user, /mob/living/silicon/ai) || istype(user, /mob/dead/)) return
		if (istype(user, /mob/living/silicon/robot))
			if (get_dist(user, src) > 1)
				user << "\red You can't reach [src] from here."
				return
		if(istype(user:gloves,/obj/item/clothing/gloves))
			return ..()
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<b>[]</b> touches [].", user, src), 1)
		src.add_fingerprint(user)
		src.Artifact_Contact(user)

	attackby(obj/item/weapon/W as obj, mob/living/user as mob)
		/*if (istype(W, /obj/item/weapon/cargotele))
			W:cargoteleport(src, user)
			return*/
		if (src.trigger == "chemical" && istype(W, /obj/item/weapon/reagent_containers/))
			switch(src.triggerX)
				if("hydrogen")
					if (W.reagents.has_reagent("hydrogen", 1) || W.reagents.has_reagent("water", 1)) src.Artifact_Activate()
				if("corrosive")
					if (W.reagents.has_reagent("acid", 1) || W.reagents.has_reagent("pacid", 1) || W.reagents.has_reagent("diethylamine", 1)) src.Artifact_Activate()
				if("volatile")
					if (W.reagents.has_reagent("plasma", 1) || W.reagents.has_reagent("thermite", 1)) src.Artifact_Activate()
				if("toxic")
					if (W.reagents.has_reagent("toxin", 1) || W.reagents.has_reagent("cyanide", 1) || W.reagents.has_reagent("amanitin", 1) || W.reagents.has_reagent("neurotoxin", 1)) src.Artifact_Activate()
		..()
		if (src.trigger == "force" && W.force >= 30 && !src.activated) src.Artifact_Activate()
		if (src.trigger == "energy")
			if (istype(W,/obj/item/weapon/melee/baton) && W:status) src.Artifact_Activate()
			if (istype(W,/obj/item/weapon/melee/energy)) src.Artifact_Activate()
			if (istype(W,/obj/item/weapon/melee/cultblade)) src.Artifact_Activate()
			if (istype(W,/obj/item/weapon/gun/energy/)) src.Artifact_Activate()
			if (istype(W,/obj/item/device/multitool)) src.Artifact_Activate()
			if (istype(W,/obj/item/weapon/card/emag)) src.Artifact_Activate()
		if (src.trigger == "heat")
			if (istype(W,/obj/item/weapon/match) && W:lit) src.Artifact_Activate()
			if (istype(W, /obj/item/weapon/weldingtool) && W:welding) src.Artifact_Activate()
			if (istype(W, /obj/item/weapon/lighter) && W:lit) src.Artifact_Activate()

	//Bump(atom/A)

	Bumped(M as mob|obj)
		if (istype(M,/obj/item/weapon/) && src.trigger == "force" && M:throwforce >= 30) src.Artifact_Activate()

	bullet_act(var/obj/item/projectile/P)
		if (src.trigger == "force")
			if(istype(P,/obj/item/projectile/bullet)) src.Artifact_Activate()
			else if(istype(P,/obj/item/projectile/hivebotbullet)) src.Artifact_Activate()
		if (src.trigger == "energy")
			if(istype(P,/obj/item/projectile/beam)) src.Artifact_Activate()
			else if(istype(P,/obj/item/projectile/ion)) src.Artifact_Activate()
			else if(istype(P,/obj/item/projectile/energy)) src.Artifact_Activate()
			else if(istype(P,/obj/item/projectile/bluetag)) src.Artifact_Activate()
			else if(istype(P,/obj/item/projectile/redtag)) src.Artifact_Activate()
		if (src.trigger == "heat")
			if(istype(P,/obj/item/projectile/temp)) src.Artifact_Activate()

	ex_act(severity)
		switch(severity)
			if(1.0) del src
			if(2.0)
				if (prob(50)) del src
				if (src.trigger == "force") src.Artifact_Activate()
				if (src.trigger == "heat") src.Artifact_Activate()
			if(3.0)
				if (src.trigger == "force") src.Artifact_Activate()
				if (src.trigger == "heat") src.Artifact_Activate()
		return

	temperature_expose(null, temp, volume)
		if (src.trigger == "heat") src.Artifact_Activate()

	process()
		if (!src.activated) return
		if (src.chargetime > 0)
			src.chargetime--
		else src.charged = 1
		if (src.effectmode == "aura")
			switch(src.effecttype)
				if("healing")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
							continue
						if(prob(10)) M << "\blue You feel a soothing energy radiating from something nearby."
						M.adjustBruteLoss(-1)
						M.adjustFireLoss(-1)
						M.adjustToxLoss(-1)
						M.adjustOxyLoss(-1)
						M.adjustBrainLoss(-1)
						M.updatehealth()
				if("injure")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
							continue
						if(prob(10)) M << "\red You feel a painful force radiating from something nearby."
						M.adjustBruteLoss(1)
						M.adjustFireLoss(1)
						M.adjustToxLoss(1)
						M.adjustOxyLoss(1)
						M.adjustBrainLoss(1)
						M.updatehealth()
				if("stun")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
							continue
						if(prob(10)) M << "\red Energy radiating from the [src] is making you feel numb."
						if(prob(20))
							M << "\red Your body goes numb for a moment."
							M.stunned += 2
							M.weakened += 2
							M.stuttering += 2
				if("roboheal")
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						if(prob(10)) M << "\blue SYSTEM ALERT: Beneficial energy field detected!"
						M.adjustBruteLoss(-1)
						M.adjustFireLoss(-1)
						M.updatehealth()
				if("robohurt")
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						if(prob(10)) M << "\red SYSTEM ALERT: Harmful energy field detected!"
						M.adjustBruteLoss(1)
						M.adjustFireLoss(1)
						M.updatehealth()
				if("cellcharge")
					for (var/obj/machinery/power/apc/C in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge += 10
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge += 20
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge += 10
							if(prob(10)) M << "\blue SYSTEM ALERT: Energy boosting field detected!"
				if("celldrain")
					for (var/obj/machinery/power/apc/C in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge -= 10
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge -= 20
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge -= 10
							if(prob(10)) M << "\red SYSTEM ALERT: Energy draining field detected!"
				if("planthelper")
					for (var/obj/machinery/hydroponics/H in range(src.aurarange,src))
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
		if (src.effectmode == "pulse")
			if (!src.charged) return
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<b>[]</b> emits a pulse of energy!", src), 1)
			switch(src.effecttype)
				if("healing")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
							continue
						M << "\blue A wave of energy invigorates you."
						M.adjustBruteLoss(5)
						M.adjustFireLoss(5)
						M.adjustToxLoss(5)
						M.adjustOxyLoss(5)
						M.adjustBrainLoss(5)
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("injure")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
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
					src.charged = 0
					src.chargetime = src.recharge
				if("stun")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
							continue
						M << "\red A wave of energy overwhelms your senses!"
						M.paralysis += 3
						M.stunned += 4
						M.weakened += 4
						M.stuttering += 4
					src.charged = 0
					src.chargetime = src.recharge
				if("roboheal")
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						M << "\blue SYSTEM ALERT: Structural damage has been repaired by energy pulse!"
						M.adjustBruteLoss(-10)
						M.adjustFireLoss(-10)
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("robohurt")
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						M << "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!"
						M.adjustBruteLoss(10)
						M.adjustFireLoss(10)
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("cellcharge")
					for (var/obj/machinery/power/apc/C in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge += 250
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge += 400
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge += 250
							M << "\blue SYSTEM ALERT: Large energy boost detected!"
					src.charged = 0
					src.chargetime = src.recharge
				if("celldrain")
					for (var/obj/machinery/power/apc/C in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge -= 500
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge -= 400
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge -= 500
							M << "\red SYSTEM ALERT: Severe energy drain detected!"
					src.charged = 0
					src.chargetime = src.recharge
				if("planthelper")
					//makes weeds and shrooms and stuff more potent too
					for (var/obj/machinery/hydroponics/H in range(src.aurarange,src))
						if(H.planted)
							H.dead = 0
							H.waterlevel = 200
							H.nutrilevel = 200
							H.toxic = 0
							H.health = 100
							H.pestlevel = 0
							H.weedlevel = 0
							H.lastcycle = H.cycledelay
				if("teleport")
					for (var/mob/living/M in range(src.aurarange,src))
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
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
							sparks.set_up(3, 0, get_turf(src)) //no idea what the 0 is
							sparks.start()
					src.charged = 0
					src.chargetime = src.recharge
		if (src.effectmode == "worldpulse")
			if (!src.charged) return
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<b>[]</b> emits a powerful burst of energy!", src), 1)
			switch(src.effecttype)
				if("healing")
					for (var/mob/living/carbon/M in world)
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
							continue
						M << "\blue Waves of soothing energy wash over you."
						M.adjustBruteLoss(-3)
						M.adjustFireLoss(-3)
						M.adjustToxLoss(-3)
						M.adjustOxyLoss(-3)
						M.adjustBrainLoss(-3)
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("injure")
					for (var/mob/living/carbon/M in world)
						M << "\red A wave of painful energy strikes you!"
						M.adjustBruteLoss(3)
						M.adjustFireLoss(3)
						M.adjustToxLoss(3)
						M.adjustOxyLoss(3)
						M.adjustBrainLoss(3)
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("stun")
					for (var/mob/living/carbon/M in world)
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
							continue
						M << "\red A powerful force causes you to black out momentarily."
						M.paralysis += 5
						M.stunned += 8
						M.weakened += 8
						M.stuttering += 8
					src.charged = 0
					src.chargetime = src.recharge
				if("roboheal")
					for (var/mob/living/silicon/robot/M in world)
						M << "\blue SYSTEM ALERT: Structural damage has been repaired by energy pulse!"
						M.adjustBruteLoss(-5)
						M.adjustFireLoss(-5)
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("robohurt")
					for (var/mob/living/silicon/robot/M in world)
						M << "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!"
						M.adjustBruteLoss(5)
						M.adjustFireLoss(5)
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("cellcharge")
					for (var/obj/machinery/power/apc/C in world)
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge += 100
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge += 250
					for (var/mob/living/silicon/robot/M in world)
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge += 100
							M << "\blue SYSTEM ALERT: Energy boost detected!"
					src.charged = 0
					src.chargetime = src.recharge
				if("celldrain")
					for (var/obj/machinery/power/apc/C in world)
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge -= 250
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge -= 250
					for (var/mob/living/silicon/robot/M in world)
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge -= 250
							M << "\red SYSTEM ALERT: Energy drain detected!"
					src.charged = 0
					src.chargetime = src.recharge
				if("teleport")
					for (var/mob/living/M in world)
						if(istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
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
							sparks.set_up(3, 0, get_turf(src)) //no idea what the 0 is
							sparks.start()
					src.charged = 0
					src.chargetime = src.recharge

/obj/machinery/artifact/proc/Artifact_Activate()
	src.activated = 1
	for(var/mob/O in viewers(src, null))
		O.show_message(text("<b>[]</b> activates!", src), 1)

/obj/machinery/artifact/proc/Artifact_Contact(var/mob/user as mob)
	// Trigger Code
	if (istype (user,/mob/living/carbon/) && src.trigger == "touch" && !src.activated) src.Artifact_Activate()
	else if (src.trigger != "touch" && !src.activated) user << "Nothing happens."
	// Effect Code
	if (src.effectmode == "contact" && src.activated && src.charged)
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
						for(var/datum/organ/wound/W in affecting.wounds)
							W.stopbleeding()
							W.is_healing = 1
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
						//
						src.charged = 0
						src.chargetime = src.recharge
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
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("stun")
				if (istype(user, /mob/living/carbon/))
					user << "\red A powerful force overwhelms your consciousness."
					user.paralysis += 30
					user.stunned += 45
					user.weakened += 45
					user.stuttering += 45
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("roboheal")
				if (istype(user, /mob/living/silicon/robot))
					user << "\blue Your systems report damaged components mending by themselves!"
					user.adjustBruteLoss(-30)
					user.adjustFireLoss(-30)
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("robohurt")
				if (istype(user, /mob/living/silicon/robot))
					user << "\red Your systems report severe damage has been inflicted!"
					user.adjustBruteLoss(40)
					user.adjustFireLoss(40)
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("forcefield")
				var/obj/effect/energy_field/E = new /obj/effect/energy_field(locate(src.x + 2,src.y,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x + 2,src.y + 1,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x + 2,src.y + 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x + 2,src.y - 1,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x + 2,src.y - 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x - 2,src.y,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x - 2,src.y + 1,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x - 2,src.y + 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x - 2,src.y - 1,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x - 2,src.y - 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x,src.y + 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x + 1,src.y + 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x - 1,src.y + 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x,src.y - 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x + 1,src.y - 2,src.z))
				E.strength = 1
				E = new /obj/effect/energy_field(locate(src.x - 1,src.y - 2,src.z))
				E.strength = 1
				src.charged = 0
				src.chargetime = src.recharge
				spawn (src.recharge)
					for(var/obj/effect/energy_field/F in range(5,src))
						del F
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

	else if (src.effectmode == "contact" && src.activated && !src.charged) user << "The artifact feels warm, but nothing interesting happens."

// this was used in QM for a time but it fell into disuse and wasn't removed, the purpose being to check if an artifact
// was benevolent or malicious, to determine whether QMs would be paid or punished for shipping it

/proc/artifact_checkgood(var/obj/machinery/artifact/A)
	switch(A.effecttype)
		if("healing") return 1
		if("injure") return 0
		if("stun") return 0
		if("roboheal") return 1
		if("robohurt") return 0
		if("cellcharge") return 1
		if("celldrain") return 1
		if("planthelper") return 1
		if("forcefield") return 1
		if("teleport") return 0