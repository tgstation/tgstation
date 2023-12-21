/datum/symptom/robotic_adaptation
	name = "Biometallic Replication"
	desc = "The virus can manipulate metal and silicate compounds, becoming able to infect robotic beings. The virus also provides a suitable substrate for nanites in otherwise inhospitable hosts"
	illness = "Robotic evolution"
	stealth = 0
	resistance = 1
	stage_speed = 4 //while the reference material has low speed, this virus will take a good while to completely convert someone
	transmittable = -1
	level = 8
	severity = 0
	symptom_delay_min = 10
	symptom_delay_max = 30
	//var/prefixes = list("Ratvarian ", "Keter ", "Clockwork ", "Robo")
	var/bodies = list("Robot")
	//var/suffixes = list("-217")
	var/replaceorgans = FALSE
	var/replacebody = FALSE
	var/robustbits = FALSE
	threshold_descs = list(
		"Stage Speed 4" = "The virus will replace the host's organic organs with mundane, biometallic versions.",
		"Resistance 4" = "The virus will eventually convert the host's entire body to biometallic materials, and maintain its cellular integrity.",
		"Stage Speed 10" = "Biometallic mass created by the virus will be superior to typical organic mass."
	)
/datum/symptom/robotic_adaptation/OnAdd(datum/disease/advance/advanced_disease)
	advanced_disease.infectable_biotypes |= MOB_ROBOTIC

/datum/symptom/robotic_adaptation/Start(datum/disease/advance/advanced_disease)
	. = ..()
	if(advanced_disease.totalStageSpeed() >= 4)
		replaceorgans = TRUE
	if(advanced_disease.totalResistance() >= 4)
		replacebody = TRUE
	if(advanced_disease.totalStageSpeed() >= 10)
		robustbits = TRUE //note that having this symptom means most healing symptoms won't work on you


/datum/symptom/robotic_adaptation/Activate(datum/disease/advance/advanced_disease)
	if(!..())
		return
	var/mob/living/carbon/human/Host = advanced_disease.affected_mob
	switch(advanced_disease.stage)
		if(3, 4)
			if(replaceorgans)
				to_chat(Host, "<span class='warning'><b>[pick("You feel a grinding pain in your abdomen.", "You exhale a jet of steam.")]</span>")
		if(5)
			if(replaceorgans || replacebody)
				if(Replace(Host))
					return
				if(replacebody)
					Host.adjustCloneLoss(-20) //repair mechanical integrity
	return

/datum/symptom/robotic_adaptation/proc/Replace(mob/living/carbon/human/Host)
	if(replaceorgans)
		for(var/obj/item/organ/Oldlimb in Host.organs)
			if(Oldlimb.status == ORGAN_ROBOTIC) //they are either part robotic or we already converted them!
				continue
			switch(Oldlimb.slot) //i hate doing it this way, but the cleaner way runtimes and does not work
				if(ORGAN_SLOT_BRAIN)
					Oldlimb.name = "enigmatic gearbox"
					Oldlimb.desc ="An engineer would call this inconcievable wonder of gears and metal a 'black box'"
					Oldlimb.icon_state = "brain-clock"
					Oldlimb.status = ORGAN_ROBOTIC
					Oldlimb.organ_flags = ORGAN_SYNTHETIC
					return TRUE
				if(ORGAN_SLOT_STOMACH)
					if(HAS_TRAIT(Host, TRAIT_NOHUNGER))//for future, we could make this give people who requires no food to maintain its no food policy
						var/obj/item/organ/internal/stomach/battery/clockwork/organ = new()
						//if(robustbits)
							//organ.max_charge = 15000 //no longer exists(old bee code)
						organ.Insert(Host, TRUE, FALSE)
					else
						var/obj/item/organ/internal/stomach/clockwork/organ = new()
						organ.Insert(Host, TRUE, FALSE)
					if(prob(40))
						to_chat(Host, "<span class='userdanger'>You feel a stabbing pain in your abdomen!</span>")
						Host.emote("scream")
					return TRUE
				if(ORGAN_SLOT_EARS)
					var/obj/item/organ/internal/ears/robot/clockwork/organ = new()
					if(robustbits)
						organ.damage_multiplier = 0.5
					organ.Insert(Host, TRUE, FALSE)
					to_chat(Host, "<span class='warning'>Your ears pop.</span>")
					return TRUE
				if(ORGAN_SLOT_EYES)
					var/obj/item/organ/internal/eyes/robotic/clockwork/organ = new()
					if(robustbits)
						organ.flash_protect = 1
					organ.Insert(Host, TRUE, FALSE)
					if(prob(40))
						to_chat(Host, "<span class='userdanger'>You feel a stabbing pain in your eyeballs!</span>")
						Host.emote("scream")
					return TRUE
				if(ORGAN_SLOT_LUNGS)
					var/obj/item/organ/internal/lungs/clockwork/organ = new()
					if(robustbits)
						organ.safe_co2_max = 15
						organ.safe_co2_max = 15
						organ.n2o_para_min = 15
						organ.n2o_sleep_min = 15
						organ.BZ_trip_balls_min = 15
						organ.gas_stimulation_min = 15
					organ.Insert(Host, TRUE, FALSE)
					if(prob(40))
						to_chat(Host, "<span class='userdanger'>You feel a stabbing pain in your chest!</span>")
						Host.emote("scream")
					return TRUE
				if(ORGAN_SLOT_HEART)
					var/obj/item/organ/internal/heart/clockwork/organ = new()
					organ.Insert(Host, TRUE, FALSE)
					to_chat(Host, "<span class='userdanger'>You feel a stabbing pain in your chest!</span>")
					Host.emote("scream")
					return TRUE
				if(ORGAN_SLOT_LIVER)
					var/obj/item/organ/internal/liver/clockwork/organ = new()
					if(robustbits)
						organ.toxTolerance = 7
					organ.Insert(Host, TRUE, FALSE)
					if(prob(40))
						to_chat(Host, "<span class='userdanger'>You feel a stabbing pain in your abdomen!</span>")
						Host.emote("scream")
					return TRUE
				if(ORGAN_SLOT_TONGUE)
					if(robustbits)
						var/obj/item/organ/internal/tongue/robot/clockwork/better/organ = new()
						organ.Insert(Host, TRUE, FALSE)
						return TRUE
					else
						var/obj/item/organ/internal/tongue/robot/clockwork/organ = new()
						organ.Insert(Host, TRUE, FALSE)
						return TRUE
				//if(ORGAN_SLOT_EXTERNAL_TAIL)      //disabled this part, because its not...QUITE working...it might be looping for moths/lizards somehow.
				//	var/obj/item/organ/external/tail/clockwork/organ = new()
				//	to_chat(Host, "<span class='userdanger'>imagine you have a tail or not.</span>")
				//	organ.Insert(Host, TRUE, FALSE)
				//	return TRUE
				//if(ORGAN_SLOT_EXTERNAL_WINGS)
				//	var/obj/item/organ/external/wings/functional/clockwork/organ = new()
				//	to_chat(Host, "<span class='userdanger'>imagine you have wings or not.</span>")
				//	//if(robustbits)
				//		//organ.flight_level = WINGS_FLYING   //old bee code
				//	organ.Insert(Host, TRUE, FALSE)
				//	return TRUE
	if(replacebody)
		for(var/obj/item/bodypart/Oldlimb in Host.bodyparts)
			if(!IS_ORGANIC_LIMB(Oldlimb))
				if(robustbits && Oldlimb.brute_modifier < 3 || Oldlimb.burn_modifier < 2)
					Oldlimb.burn_modifier = max(4, Oldlimb.burn_modifier)
					Oldlimb.brute_modifier = max(5, Oldlimb.brute_modifier)
				continue
			switch(Oldlimb.body_zone)
				if(BODY_ZONE_HEAD)//i wish i knew how to transfer external organs from old limb to new limb, but i dont.
					var/obj/item/bodypart/head/robot/clockwork/newlimb = new()
					if(robustbits)
						newlimb.brute_modifier = 5
						newlimb.burn_modifier = 4
					newlimb.replace_limb(Host, TRUE)
					Host.visible_message("<span_class='userdanger'>Your head feels numb, and cold.</span>")
					qdel(Oldlimb)
					return TRUE
				if(BODY_ZONE_CHEST)//i wish i knew how to transfer external organs from old limb to new limb, but i dont.
					var/obj/item/bodypart/chest/robot/clockwork/newlimb = new()
					if(robustbits)
						newlimb.brute_modifier = 5
						newlimb.burn_modifier = 4
					newlimb.replace_limb(Host, TRUE)
					Host.visible_message("<span_class='userdanger'>Your [Oldlimb] feels numb, and cold.</span>")
					qdel(Oldlimb)
					return TRUE
				if(BODY_ZONE_L_ARM)
					var/obj/item/bodypart/arm/left/robot/clockwork/newlimb = new()
					if(robustbits)
						newlimb.brute_modifier = 5
						newlimb.burn_modifier = 4
					newlimb.replace_limb(Host, TRUE)
					Host.visible_message("<span_class='userdanger'>Your [Oldlimb] feels numb, and cold.</span>")
					qdel(Oldlimb)
					return TRUE
				if(BODY_ZONE_R_ARM)
					var/obj/item/bodypart/arm/right/robot/clockwork/newlimb = new()
					if(robustbits)
						newlimb.brute_modifier = 5
						newlimb.burn_modifier = 4
					newlimb.replace_limb(Host, TRUE)
					Host.visible_message("<span_class='userdanger'>Your [Oldlimb] feels numb, and cold.</span>")
					qdel(Oldlimb)
					return TRUE
				if(BODY_ZONE_L_LEG)
					var/obj/item/bodypart/leg/left/robot/clockwork/newlimb = new()
					if(robustbits)
						newlimb.brute_modifier = 5
						newlimb.burn_modifier = 4
					newlimb.replace_limb(Host, TRUE)
					Host.visible_message("<span_class='userdanger'>Your [Oldlimb] feels numb, and cold.</span>")
					qdel(Oldlimb)
					return TRUE
				if(BODY_ZONE_R_LEG)
					var/obj/item/bodypart/leg/right/robot/clockwork/newlimb = new()
					if(robustbits)
						newlimb.brute_modifier = 5
						newlimb.burn_modifier = 4
					newlimb.replace_limb(Host, TRUE)
					Host.visible_message("<span_class='userdanger'>Your [Oldlimb] feels numb, and cold.</span>")
					qdel(Oldlimb)
					return TRUE
	return FALSE

/datum/symptom/robotic_adaptation/End(datum/disease/advance/advanced_disease)
	if(!..())
		return
	var/mob/living/carbon/human/Host = advanced_disease.affected_mob
	if(advanced_disease.stage >= 5 && (replaceorgans || replacebody)) //sorry. no disease quartets allowed
		to_chat(Host, "<span class='userdanger'>You feel lighter and springier as your innards lose their clockwork facade.</span>")
		Host.dna.species.regenerate_organs(Host, replace_current = TRUE)
		for(var/obj/item/bodypart/Oldlimb in Host.bodyparts)
			if(!IS_ORGANIC_LIMB(Oldlimb))
				Oldlimb.burn_modifier = initial(Oldlimb.burn_modifier)
				Oldlimb.brute_modifier = initial(Oldlimb.brute_modifier)

/datum/symptom/robotic_adaptation/OnRemove(datum/disease/advance/advanced_disease)
	advanced_disease.infectable_biotypes -= MOB_ROBOTIC
