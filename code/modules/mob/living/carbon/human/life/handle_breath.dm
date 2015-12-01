//Refer to life.dm for caller

/mob/living/carbon/human/proc/breathe()
	if(flags & INVULNERABLE)
		return
	if(reagents.has_reagent("lexorin"))
		return
	if(M_NO_BREATH in mutations)
		return //No breath mutation means no breathing.
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) //This is an annoying hack given that cryo cells are supposed to be oxygenated, but fuck it
		return
	if(species && species.flags & NO_BREATHE)
		return

	var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]
	if(L)
		L.process() //Ideally lungs would handle breathing, but right now we're just sanitizing

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath
	//HACK NEED CHANGING LATER
	if(health < config.health_threshold_crit)
		losebreath++
	if(losebreath > 0) //Suffocating so do not take a breath
		losebreath--
		if(prob(10)) //Gasp per 10 ticks? Sounds about right.
			spawn()
				emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
		//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(head && (head.flags & BLOCK_BREATHING)) //Worn items which block breathing are handled first
				//
			else if(wear_mask && (wear_mask.flags & BLOCK_BREATHING))
				//
			else if(isobj(loc))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_MOLES)
			else if(isturf(loc))
				var/breath_moles = 0
				/*if(environment.return_pressure() > ONE_ATMOSPHERE)
					//Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
					breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else*/
					//Not enough air around, take a percentage of what's there to model this properly
				breath_moles = environment.total_moles() * BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)

				if(!is_lung_ruptured())
					if(!breath || breath.total_moles < BREATH_MOLES / 5 || breath.total_moles > BREATH_MOLES * 5)
						if(prob(5)) //5 % chance for a lung rupture if air intake is less of a fifth, or more than five times the threshold
							rupture_lung()

				//Handle filtering
				var/block = 0
				if(wear_mask)
					if(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1
				if(glasses)
					if(glasses.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1
				if(head)
					if(head.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1

				if(!block)

					for(var/obj/effect/effect/smoke/chem/smoke in view(1, src)) //If there is smoke within one tile
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src, INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10) //I dunno, maybe the reagents enter the blood stream through the lungs?
							break //If they breathe in the nasty stuff once, no need to continue checking

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)

	if(species.name == "Plasmaman") //For plasmamen only, fuck species modularity

		//Check if we're wearing our biosuit and mask.
		if(!(istype(wear_suit, /obj/item/clothing/suit/space/plasmaman) || istype(wear_suit,/obj/item/clothing/suit/space/bomberman)) || !(istype(head,/obj/item/clothing/head/helmet/space/plasmaman) || istype(head,/obj/item/clothing/head/helmet/space/bomberman)))
			//testing("Plasmaman [src] leakin'.  coverflags=[cover_flags]")
			//OH FUCK HE LEAKIN'.
			//This was OP.
			//environment.adjust(tx = environment.total_moles()*BREATH_PERCENTAGE) //About one breath's worth. (I know we aren't breathing it out, but this should be about the right amount)
			if(environment)
				if(environment.oxygen && environment.total_moles() && (environment.oxygen / environment.total_moles()) >= OXYCONCEN_PLASMEN_IGNITION) //How's the concentration doing?
					if(!on_fire)
						to_chat(src, "<span class='warning'>Your body reacts with the atmosphere and bursts into flame!</span>")
					adjust_fire_stacks(0.5)
					IgniteMob()
		else
			if(fire_stacks)
				var/obj/item/clothing/suit/space/plasmaman/PS=wear_suit
				PS.Extinguish(src)

	if(breath)
		loc.assume_air(breath)

		//Spread some viruses while we are at it
		if(virus2 && virus2.len > 0)
			if(prob(10) && get_infection_chance(src))
//					log_debug("[src] : Exhaling some viruses")
				for(var/mob/living/carbon/M in view(1,src))
					src.spread_disease_to(M)

/mob/living/carbon/human/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if(!contents.Find(internal))
			internal = null
		if(!wear_mask || !(wear_mask.flags & MASKINTERNALS))
			internal = null
		if(internal)
			return internal.remove_air_volume(volume_needed)
		else if(internals)
			internals.icon_state = "internal0"
	return null

/mob/living/carbon/human/proc/handle_breath(var/datum/gas_mixture/breath)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return 0

	if(!breath || (breath.total_moles() == 0) || suiciding)
		if(reagents.has_reagent("inaprovaline"))
			return 0
		if(suiciding)
			adjustOxyLoss(2) //If you are suiciding, you should die a little bit faster
			failed_last_breath = 1
			oxygen_alert = max(oxygen_alert, 1)
			return 0
		if(health > config.health_threshold_crit)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			failed_last_breath = 1
		else
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
			failed_last_breath = 1

		oxygen_alert = max(oxygen_alert, 1)

		return 0

	return species.handle_breath(breath, src)
