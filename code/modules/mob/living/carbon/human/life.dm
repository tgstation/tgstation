//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

#define HUMAN_MAX_OXYLOSS 6 //Defines how much oxyloss humans can get per tick. No air applies this value.

/mob/living/carbon/human
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0

	var/temperature_alert = 0

		// used to do some stuff only on every X life tick
	var/life_tick = 0
	var/isbreathing = 1
	var/holdbreath = 0
	var/lyingcheck = 0
	var/buckle_check = 0

/mob/living/carbon/human/Life()
	set invisibility = 0
	set background = 1

	if (monkeyizing)
		return

	if(!loc)			// Fixing a null error that occurs when the mob isn't found in the world -- TLE
		return

	..()

	//Being buckled to a chair or bed
	check_if_buckled()
	handle_clothing()

	// TODO: this check and the lyingcheck variable should probably be removed in favor of the visual_lying check
	if((lyingcheck != lying) || (buckle_check != (buckled ? 1 : 0)))		//This is a fix for falling down / standing up not updating icons.  Instead of going through and changing every
		spawn(5)
			update_clothing()		//instance in the code where lying is modified, I've just added a new variable "lyingcheck" which will be compared
		lyingcheck = lying		//to lying, so if lying ever changes, update_clothing() will run like normal.

	if(stat == 2)
		if(!lying && !buckled)
			lying = 1
			update_clothing()
		return

	life_tick++

	var/datum/gas_mixture/environment = loc.return_air()

	// clean all symptoms, they must be set again in this cycle
	src.disease_symptoms = 0

	if (stat != 2) //still breathing


		//First, resolve location and get a breath

		if(air_master.current_cycle%4==2)
			//Only try to take a breath every 4 seconds, unless suffocating
			spawn(0) breathe()

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		src.handle_shock()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Update Mind
	update_mind()

	//Disease Check
	handle_virus_updates()

	//Changeling things
	handle_changeling()

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	//Mutations and radiation
	handle_mutations_and_radiation()

	//Chemicals in the body
	handle_chemicals_in_body()

	//stuff in the stomach
	handle_stomach()

	//Disabilities
	handle_disabilities()

	//Random events (vomiting etc)
	handle_random_events()

	//Status updates, death etc.
	UpdateLuminosity()
	handle_regular_status_updates()

	handle_pain()

	// Some mobs heal slowly, others die slowly
	handle_health_updates()

	if(client)
		handle_regular_hud_updates()

	//Being buckled to a chair or bed
	check_if_buckled()

	// Yup.
	update_canmove()

	clamp_values()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(isturf(loc) && rand(1,1000) == 1) //0.1% chance of playing a scary sound to someone who's in complete darkness
		var/turf/currentTurf = get_turf(src)
		if(!max(currentTurf.ul_GetRed(), currentTurf.ul_GetGreen(), currentTurf.ul_GetBlue()))
			playsound_local(src,pick(scarySounds),50, 1, -1)

	src.moved_recently = max(0, moved_recently-1)

/mob/living/carbon/human
	proc

		handle_health_updates()
			if (stat != 0)
				if(!lying)
					lying = 1 //Seriously, stay down :x
					update_clothing()



		clamp_values()

			SetStunned(min(stunned, 20))
			SetParalysis(min(paralysis, 20))
			SetWeakened(min(weakened, 20))
			sleeping = max(min(sleeping, 20), 0)
			adjustBruteLoss(0)
			adjustToxLoss(0)
			adjustOxyLoss(0)
			adjustFireLoss(0)


		update_mind()
			if(!mind && client)
				mind = new
				mind.current = src
				mind.assigned_role = job
				if(!mind.assigned_role)
					mind.assigned_role = "Assistant"
				mind.key = key


		handle_disabilities()
			if(mHallucination in mutations)
				hallucination = 100
				halloss = 0

			if(hallucination > 0)
				if(hallucination >= 20 && health > 0)
					if(prob(2)) //Waaay to often.
						fake_attack(src)
				//for(var/atom/a in hallucinations)
				//	a.hallucinate(src)
				if(!handling_hal && hallucination > 20)
					spawn handle_hallucinations() //The not boring kind!
				hallucination = max(hallucination - 2, 0) // A more compact way of doing it. DMTG
				//if(health < 0)
				//	for(var/obj/a in hallucinations)
				//		del a
			else
				//halloss = 0
				for(var/atom/a in hallucinations)
					del a

				if(halloss > 100)
					src << "You're too tired to keep going..."
					for(var/mob/O in viewers(src, null))
						if(O == src)
							continue
						O.show_message(text("\red <B>[src] slumps to the ground panting, too weak to continue fighting."), 1)
					Paralyse(15)
					setHalLoss(99)

			if(mSmallsize in mutations)
				if(!(pass_flags & PASSTABLE))
					pass_flags |= PASSTABLE
			else
				if(pass_flags & PASSTABLE)
					pass_flags &= ~PASSTABLE



			if (mRegen in mutations)
				adjustBruteLoss(-2)
				adjustToxLoss(-2)
				adjustOxyLoss(-2)
				adjustFireLoss(-2)
				updatehealth()

			if(!(/mob/living/carbon/human/proc/morph in src.verbs))
				if(mMorph in mutations)
					src.verbs += /mob/living/carbon/human/proc/morph
			else
				if(!(mMorph in mutations))
					src.verbs -= /mob/living/carbon/human/proc/morph

			if(!(/mob/living/carbon/human/proc/remoteobserve in src.verbs))
				if(mRemote in mutations)
					src.verbs += /mob/living/carbon/human/proc/remoteobserve
			else
				if(!(mRemote in mutations))
					src.verbs -= /mob/living/carbon/human/proc/remoteobserve

			if(!(/mob/living/carbon/human/proc/remotesay in src.verbs))
				if(mRemotetalk in mutations)
					src.verbs += /mob/living/carbon/human/proc/remotesay
			else
				if(!(mRemotetalk in mutations))
					src.verbs -= /mob/living/carbon/human/proc/remotesay


			if (disabilities & 2)
				if ((prob(1) && paralysis < 1 && r_epil < 1))
					src << "\red You have a seizure!"
					for(var/mob/O in viewers(src, null))
						if(O == src)
							continue
						O.show_message(text("\red <B>[src] starts having a seizure!"), 1)
					Paralyse(10)
					make_jittery(1000)
			if (disabilities & 4)
				if ((prob(5) && paralysis <= 1 && r_ch_cou < 1))
					drop_item()
					spawn( 0 )
						emote("cough")
			if (disabilities & 8)
				if ((prob(5) && paralysis <= 1 && r_Tourette < 1))
					Stun(10)
					spawn(0)
						switch(rand(1, 3))
							if(1)
								emote("twitch")
							if(2 to 3)
								say("[prob(50) ? ";" : ""][pick("EELS","MOTORBOATS","MERDE","ANTIDISESTABLISHMENTARIANISM","OGOPOGO","POPEMOBILE","RHOMBUS","TUMESCENCE","ZIGGURAT","DIRIGIBLES","WAFFLES","PICKLES","BIKINI","DUCK","KNICKERBOCKERS","LOQUACIOUS","MACADAMIA","MAHOGANY","KUMQUAT","PERCOLATOR","AUBERGINES","FLANGES","GOURDS","DONUTS","CALLIPYGIAN","DARJEELING","DWARFS","MAGMA","ARMOK","BERR","APPLES","SPACEMEN","NINJAS","PIRATES","BUNION")]!")
						var/old_x = pixel_x
						var/old_y = pixel_y
						pixel_x += rand(-2,2)
						pixel_y += rand(-1,1)
						sleep(2)
						pixel_x = old_x
						pixel_y = old_y
			if (disabilities & 16)
				if (prob(10))//Instant Chad Ore!
					stuttering = max(10, stuttering)

			if (getBrainLoss() >= 60 && stat != 2)
				if (prob(7))
					switch(pick(1,2,3))
						if(1)
							say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", "without oxigen blob don't evoluate?", "CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", "can u give me [pick("telikesis","halk","eppilapse")]?", "THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", "I WANNA PET TEH monkeyS", "stop grifing me!!!!", "SOTP IT#"))
						if(2)
							say(pick("FUS RO DAH","fucking 4rries!", "stat me", ">my face", "roll it easy!", "waaaaaagh!!!", "red wonz go fasta", "FOR TEH EMPRAH", "lol2cat", "dem dwarfs man, dem dwarfs", "SPESS MAHREENS", "hwee did eet fhor khayosss", "lifelike texture ;_;", "luv can bloooom"))
						if(3)
							emote("drool")


		handle_mutations_and_radiation()
			if(getFireLoss())
				if((COLD_RESISTANCE in mutations) || (prob(1) && prob(75)))
					heal_organ_damage(0,1)

			// Make nanoregen heal youu, -3 all damage types
			if(NANOREGEN in augmentations)
				var/healed = 0
				if(getToxLoss())
					adjustToxLoss(-3)
					healed = 1
				if(getOxyLoss())
					adjustOxyLoss(-3)
					healed = 1
				if(getCloneLoss())
					adjustCloneLoss(-3)
					healed = 1
				if(getBruteLoss())
					heal_organ_damage(3,0)
					healed = 1
				if(getFireLoss())
					heal_organ_damage(0,3)
					healed = 1
				if(halloss > 0)
					halloss -= 3
					if(halloss < 0) halloss = 0
					healed = 1
				if(healed)
					if(prob(5))
						src << "\blue You feel your wounds mending..."

			if ((HULK in mutations) && health <= 25)
				mutations.Remove(HULK)
				src << "\red You suddenly feel very weak."
				Weaken(3)
				emote("collapse")

			if (radiation)
				if (radiation > 100)
					radiation = 100
					Weaken(10)
					src << "\red You feel weak."
					emote("collapse")

				if (radiation < 0)
					radiation = 0

				var/damage = 0 // stores how much damage was inflicted

				switch(radiation)
					if(1 to 49)
						radiation--
						if(prob(25))
							damage = 1
							adjustToxLoss(1)
							updatehealth()

					if(50 to 74)
						radiation -= 2
						adjustToxLoss(1)
						damage = 1
						if(prob(5))
							radiation -= 5
							Weaken(3)
							src << "\red You feel weak."
							emote("collapse")
						updatehealth()

					if(75 to 100)
						radiation -= 3
						adjustToxLoss(3)
						damage = 3
						if(prob(1))
							src << "\red You mutate!"
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						updatehealth()

				if(damage)
					var/V = pick(organs)
					var/datum/organ/external/O = organs[V]
					if(istype(O)) O.add_wound("Radiation Poisoning", damage)


			//As close as I could find to where to put it
			grav_delay = max(grav_delay-3,0)

		/** Overview of breathing code:
			- first it's determined whether the human is capable of breathing
			- then it's determined whether the human is holding his breath intentionally
			- the isbreathing variable is set according to this

			- next, we look for any air that the mob could breathe, first internals, then in the air around him
			- if the human isn't breathing, it counts as vacuum
			- then we check if the air we found is breathable, if not, we inflict oxygen damage
		**/
		breathe()

			if(reagents.has_reagent("lexorin")) return
			if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

			var/datum/gas_mixture/environment = loc.return_air()
			var/datum/gas_mixture/breath

			// HACK NEED CHANGING LATER
			if(isbreathing && health < config.health_threshold_crit)
				spawn emote("stopbreath")
				isbreathing = 0

			if(holdbreath)
				isbreathing = 0
			else if(health >= config.health_threshold_crit && !isbreathing)
				if(holdbreath)
					// we're simply holding our breath, see if we can hold it longer
					if(health < 30)
						holdbreath = 0
						isbreathing = 1
						spawn emote("custom h inhales sharply.")
				else
					isbreathing = 1
					emote("breathe")
			else
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)
			if(isbreathing && !being_strangled)
				//First, check for air from internal atmosphere (using an air tank and mask generally)
				breath = get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
				//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

				//No breath from internal atmosphere so get breath from location
				if(!breath)
					if(istype(loc, /obj/))
						var/obj/location_as_object = loc
						breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
					else if(istype(loc, /turf/))
						var/breath_moles = 0
						/*if(environment.return_pressure() > ONE_ATMOSPHERE)
							// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
							breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
						else*/
							// Not enough air around, take a percentage of what's there to model this properly
						breath_moles = environment.total_moles*BREATH_PERCENTAGE

						breath = loc.remove_air(breath_moles)

						// Handle chem smoke effect  -- Doohl

						var/block = 0
						if(wear_mask)
							if(istype(wear_mask, /obj/item/clothing/mask/gas))
								block = 1

						if(!block)

							for(var/obj/effect/effect/chem_smoke/smoke in view(1, src))
								if(smoke.reagents.total_volume)
									smoke.reagents.reaction(src, INGEST)
									spawn(5)
										if(smoke)
											smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
									break // If they breathe in the nasty stuff once, no need to continue checking

					if(istype(wear_mask, /obj/item/clothing/mask/gas))
						var/datum/gas_mixture/filtered = new()
						filtered.toxins = breath.toxins
						filtered.trace_gases = breath.trace_gases.Copy()
						filtered.update_values()
						breath.toxins = 0
						breath.trace_gases = list()
						breath.update_values()
						loc.assume_air(filtered)

				else //Still give containing object the chance to interact
					if(istype(loc, /obj/))
						var/obj/location_as_object = loc
						location_as_object.handle_internal_lifeform(src, 0)

			handle_breath(breath)
			being_strangled = 0

			if(breath)
				loc.assume_air(breath)

		get_breath_from_internal(volume_needed)
			if(internal)
				if (!contents.Find(internal))
					internal = null
				if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
					internal = null
				if(internal)
					return internal.remove_air_volume(volume_needed)
				else if(internals)
					internals.icon_state = "internal0"
			return null

		update_canmove()
			if(stat || sleeping || paralysis || stunned || weakened || resting || buckled || (changeling && changeling.changeling_fakedeath))
				canmove = 0

			else
				lying = 0
				canmove = 1

		handle_breath(datum/gas_mixture/breath)
			if(nodamage || REBREATHER in augmentations || (mNobreath in mutations))
				return

			if(!breath || (breath.total_moles == 0))
				if(reagents.has_reagent("inaprovaline"))
					return
				if(health < config.health_threshold_crit)
					// in crit, we pretend your metabolism has become slower, which
					// will reduce the rate at which you lose health
					adjustOxyLoss(round(HUMAN_MAX_OXYLOSS / 2))
				else
					adjustOxyLoss(HUMAN_MAX_OXYLOSS)

				oxygen_alert = max(oxygen_alert, 1)

				if(isbreathing && prob(20)) spawn(0) emote("gasp")

				return 0

			var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
			//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
			var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
			var/safe_toxins_max = 0.0025
			var/SA_para_min = 1
			var/SA_sleep_min = 5
			var/oxygen_used = 0
			var/breath_pressure = (breath.total_moles*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

			//Partial pressure of the O2 in our breath
			var/O2_pp = (breath.oxygen/breath.total_moles)*breath_pressure
			// Same, but for the toxins
			var/Toxins_pp = (breath.toxins/breath.total_moles)*breath_pressure
			// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
			var/CO2_pp = (breath.carbon_dioxide/breath.total_moles)*breath_pressure // Tweaking to fit the hacky bullshit I've done with atmo -- TLE
			//var/CO2_pp = (breath.carbon_dioxide/breath.total_moles)*0.5 // The default pressure value

			if(O2_pp < safe_oxygen_min) 			// Too little oxygen
				if(prob(20) && isbreathing)
					spawn(0) emote("gasp")
				if(O2_pp > 0)
					var/ratio = safe_oxygen_min/O2_pp
					adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
					oxygen_used = breath.oxygen*ratio/6
				else
					adjustOxyLoss(HUMAN_MAX_OXYLOSS)
				oxygen_alert = max(oxygen_alert, 1)
			/*else if (O2_pp > safe_oxygen_max) 		// Too much oxygen (commented this out for now, I'll deal with pressure damage elsewhere I suppose)
				spawn(0) emote("cough")
				var/ratio = O2_pp/safe_oxygen_max
				oxyloss += 5*ratio
				oxygen_used = breath.oxygen*ratio/6
				oxygen_alert = max(oxygen_alert, 1)*/
			else								// We're in safe limits
				adjustOxyLoss(-5)
				oxygen_used = breath.oxygen/6
				oxygen_alert = 0

			breath.oxygen -= oxygen_used
			breath.carbon_dioxide += oxygen_used

			if(CO2_pp > safe_co2_max)
				if(!co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
					co2overloadtime = world.time
				else if(world.time - co2overloadtime > 120)
					Paralyse(3)
					adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
					if(world.time - co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
						adjustOxyLoss(8)
				if(prob(20) && isbreathing) // Lets give them some chance to know somethings not right though I guess.
					spawn(0) emote("cough")

			else
				co2overloadtime = 0

			if(Toxins_pp > safe_toxins_max) // Too much toxins
				var/ratio = breath.toxins/safe_toxins_max
				adjustToxLoss(min(ratio, 10))	//Limit amount of damage toxin exposure can do per second
				toxins_alert = max(toxins_alert, 1)
			else
				toxins_alert = 0

			if(breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
				for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
					var/SA_pp = (SA.moles/breath.total_moles)*breath_pressure
					if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
						Paralyse(3) // 3 gives them one second to wake up and run away a bit!
						if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
							sleeping = max(src.sleeping+2, 10)
					else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
						if(prob(20) && isbreathing)
							spawn(0) emote(pick("giggle", "laugh"))
					SA.moles = 0 //Hack to stop the damned surgeon from giggling.


			if(breath.temperature > (T0C+66) && !(COLD_RESISTANCE in mutations)) // Hot air hurts :(
				if(prob(20))
					src << "\red You feel a searing heat in your lungs!"
				fire_alert = max(fire_alert, 1)
			else
				fire_alert = 0



			//Temporary fixes to the alerts.

			return 1

		handle_environment(datum/gas_mixture/environment)
			if(!environment)
				return
			var/environment_heat_capacity = environment.heat_capacity()
			var/loc_temp = T0C
			if(istype(loc, /turf/space))
				environment_heat_capacity = loc:heat_capacity
				loc_temp = 2.7
			else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
				loc_temp = loc:air_contents.temperature
			else
				loc_temp = environment.temperature

			var/thermal_protection = get_thermal_protection()

			//world << "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Thermal protection: [get_thermal_protection()] - Fire protection: [thermal_protection + add_fire_protection(loc_temp)]"

			if(stat != 2 && abs(bodytemperature - 310.15) < 50)
				bodytemperature += adjust_body_temperature(bodytemperature, 310.15, thermal_protection)
			if(loc_temp < 310.15) // a cold place -> add in cold protection
				bodytemperature += adjust_body_temperature(bodytemperature, loc_temp, 1/thermal_protection)
			else // a hot place -> add in heat protection
				thermal_protection += add_fire_protection(loc_temp)
				bodytemperature += adjust_body_temperature(bodytemperature, loc_temp, 1/thermal_protection)

			// lets give them a fair bit of leeway so they don't just start dying
			//as that may be realistic but it's no fun
			if((bodytemperature > (T0C + 50)) || (bodytemperature < (T0C + 10)) && (!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))) // Last bit is just disgusting, i know
				if(environment.temperature > (T0C + 50) || (environment.temperature < (T0C + 10)))
					var/transfer_coefficient

					transfer_coefficient = 1
					if(head && (head.body_parts_covered & HEAD) && (environment.temperature < head.protective_temperature))
						transfer_coefficient *= head.heat_transfer_coefficient
					if(wear_mask && (wear_mask.body_parts_covered & HEAD) && (environment.temperature < wear_mask.protective_temperature))
						transfer_coefficient *= wear_mask.heat_transfer_coefficient
					if(wear_suit && (wear_suit.body_parts_covered & HEAD) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient

					handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & UPPER_TORSO) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(w_uniform && (w_uniform.body_parts_covered & UPPER_TORSO) && (environment.temperature < w_uniform.protective_temperature))
						transfer_coefficient *= w_uniform.heat_transfer_coefficient

					handle_temperature_damage(UPPER_TORSO, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & LOWER_TORSO) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(w_uniform && (w_uniform.body_parts_covered & LOWER_TORSO) && (environment.temperature < w_uniform.protective_temperature))
						transfer_coefficient *= w_uniform.heat_transfer_coefficient

					handle_temperature_damage(LOWER_TORSO, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & LEGS) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(w_uniform && (w_uniform.body_parts_covered & LEGS) && (environment.temperature < w_uniform.protective_temperature))
						transfer_coefficient *= w_uniform.heat_transfer_coefficient

					handle_temperature_damage(LEGS, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & ARMS) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(w_uniform && (w_uniform.body_parts_covered & ARMS) && (environment.temperature < w_uniform.protective_temperature))
						transfer_coefficient *= w_uniform.heat_transfer_coefficient

					handle_temperature_damage(ARMS, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & HANDS) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(gloves && (gloves.body_parts_covered & HANDS) && (environment.temperature < gloves.protective_temperature))
						transfer_coefficient *= gloves.heat_transfer_coefficient

					handle_temperature_damage(HANDS, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & FEET) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(shoes && (shoes.body_parts_covered & FEET) && (environment.temperature < shoes.protective_temperature))
						transfer_coefficient *= shoes.heat_transfer_coefficient

					handle_temperature_damage(FEET, environment.temperature, environment_heat_capacity*transfer_coefficient)

			/*if(stat==2) //Why only change body temp when they're dead? That makes no sense!!!!!!
				bodytemperature += 0.8*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)
			*/

			//Account for massive pressure differences.  Done by Polymorph


			var/pressure = environment.return_pressure()
			if(!istype(wear_suit, /obj/item/clothing/suit/space) && !istype(wear_suit, /obj/item/clothing/suit/fire))
					/*if(pressure < 20)
						if(prob(25))
							src << "You feel the splittle on your lips and the fluid on your eyes boiling away, the capillteries in your skin breaking."
						adjustBruteLoss(5)
					*/
				if(pressure > HAZARD_HIGH_PRESSURE)
					adjustBruteLoss(min((10+(round(pressure/(HIGH_STEP_PRESSURE)-2)*5)),MAX_PRESSURE_DAMAGE))

			if(environment.toxins > MOLES_PLASMA_VISIBLE)
				pl_effects()

			return //TODO: DEFERRED

		adjust_body_temperature(current, loc_temp, boost)
			var/temperature = current
			var/difference = abs(current-loc_temp)	//get difference
			var/increments// = difference/10			//find how many increments apart they are
			if(difference > 50)
				increments = difference/5
			else
				increments = difference/10
			var/change = increments*boost	// Get the amount to change by (x per increment)
			var/temp_change
			if(current < loc_temp) //If your body temp is less than loc, then try to heat up
				if(istajaran(src)) //If Tajaran, you heat up faster
					change = change*4
				temperature = min(loc_temp, temperature+change) //Pick the minimum of these two
			else if(current > loc_temp) //If your body temp is more than loc, then try to cool down
				if(istajaran(src)) //If Tajaran, you cool down slower
					change = change*0.5
				if(mutantrace == "lizard") //If Soghun, you cool down faster
					change = change*3
				temperature = max(loc_temp, temperature-change) //Pick the max of these two
			temp_change = (temperature - current) //Work out the actual change of temp
			return temp_change

		get_thermal_protection()
			var/thermal_protection = 1.0
			//Handle normal clothing
			if(head && (head.body_parts_covered & HEAD))
				thermal_protection += 0.5
			if(wear_suit && (wear_suit.body_parts_covered & UPPER_TORSO))
				thermal_protection += 0.5
			if(w_uniform && (w_uniform.body_parts_covered & UPPER_TORSO))
				thermal_protection += 0.5
			if(wear_suit && (wear_suit.body_parts_covered & LEGS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & ARMS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & HANDS))
				thermal_protection += 0.2
			if(shoes && (shoes.body_parts_covered & FEET))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.flags & SUITSPACE))
				thermal_protection += 3
			if(w_uniform && (w_uniform.flags & SUITSPACE))
				thermal_protection += 3
			if(head && (head.flags & HEADSPACE))
				thermal_protection += 1
			if(COLD_RESISTANCE in mutations)
				thermal_protection += 5

			return thermal_protection

		add_fire_protection(var/temp)
			var/fire_prot = 0
			if(head)
				if(head.protective_temperature > temp)
					fire_prot += (head.protective_temperature/10)
			if(wear_mask)
				if(wear_mask.protective_temperature > temp)
					fire_prot += (wear_mask.protective_temperature/10)
			if(glasses)
				if(glasses.protective_temperature > temp)
					fire_prot += (glasses.protective_temperature/10)
			if(l_ear)
				if(l_ear.protective_temperature > temp)
					fire_prot += (l_ear.protective_temperature/10)
			if(r_ear)
				if(r_ear.protective_temperature > temp)
					fire_prot += (r_ear.protective_temperature/10)
			if(wear_suit)
				if(wear_suit.protective_temperature > temp)
					fire_prot += (wear_suit.protective_temperature/10)
			if(w_uniform)
				if(w_uniform.protective_temperature > temp)
					fire_prot += (w_uniform.protective_temperature/10)
			if(gloves)
				if(gloves.protective_temperature > temp)
					fire_prot += (gloves.protective_temperature/10)
			if(shoes)
				if(shoes.protective_temperature > temp)
					fire_prot += (shoes.protective_temperature/10)

			return fire_prot

		handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
			if(nodamage)
				return

			var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

			if(exposed_temperature > bodytemperature)
				discomfort *= 4

			if(mutantrace == "plant")
				discomfort *= 3 //I don't like magic numbers. I'll make mutantraces a datum with vars sometime later. -- Urist
			else
				discomfort *= 1.5 //Dangercon 2011 - Upping damage by use of magic numbers - Errorage

			var/au_msg = "High Temperature"

			switch(body_part)
				if(HEAD)
					apply_damage(2.5*discomfort, BURN, "head", used_weapon = au_msg)
				if(UPPER_TORSO)
					apply_damage(2.5*discomfort, BURN, "chest", used_weapon = au_msg)
				if(LEGS)
					apply_damage(0.6*discomfort, BURN, "l_leg", used_weapon = au_msg)
					apply_damage(0.6*discomfort, BURN, "r_leg", used_weapon = au_msg)
				if(ARMS)
					apply_damage(0.4*discomfort, BURN, "l_arm", used_weapon = au_msg)
					apply_damage(0.4*discomfort, BURN, "r_arm", used_weapon = au_msg)

		handle_chemicals_in_body()
			if(reagents && stat != 2) reagents.metabolize(src)
			if(vessel && stat != 2) vessel.metabolize(src)

			if(mutantrace == "plant") //couldn't think of a better place to place it, since it handles nutrition -- Urist
				var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
				if(istype(loc,/turf)) //else, there's considered to be no light
					var/turf/currentTurf = get_turf(src)
					light_amount = min(10,max(currentTurf.ul_GetRed(), currentTurf.ul_GetGreen(), currentTurf.ul_GetBlue())) - 5 //hardcapped so it's not abused by having a ton of flashlights
				if(nutrition < 500) //so they can't store nutrition to survive without light forever
					nutrition += light_amount
				if(light_amount > 0) //if there's enough light, heal
					heal_overall_damage(1,1)
					adjustToxLoss(-1)
					adjustOxyLoss(-1)

/*			if(overeatduration > 500 && !(FAT in mutations))
				src << "\red You suddenly feel blubbery!"
				mutations.Add(FAT)
				update_body()
			if ((overeatduration < 100 && (FAT in mutations)))
				src << "\blue You feel fit again!"
				mutations.Remove(FAT)
				update_body()
*/
			// nutrition decrease
			if (nutrition > 0 && stat != 2)
				// sleeping slows the metabolism, hunger increases more slowly
				if(stat == 1)
					if(istajaran(src)) //Tajarans get hungry slightly faster
						nutrition = max (0, nutrition - HUNGER_FACTOR*1.25)
					if(mutantrace == "lizard") //Soghuns get hungry much slower
						nutrition = max (0, nutrition - HUNGER_FACTOR*0.5)
					else
						nutrition = max (0, nutrition - HUNGER_FACTOR)
				else
					nutrition = max (0, nutrition - HUNGER_FACTOR / 4)

			if (nutrition > 450)
				if(overeatduration < 600) //capped so people don't take forever to unfat
					overeatduration++
			else
				if(overeatduration > 1)
					overeatduration -= 2 //doubled the unfat rate

			if(mutantrace == "plant")
				if(nutrition < 200)
					take_overall_damage(2,0)

			if (drowsyness)
				drowsyness--
				eye_blurry = max(2, eye_blurry)
				if (prob(5))
					sleeping += 1
					Paralyse(5)

			confused = max(0, confused - 1)
			// decrement dizziness counter, clamped to 0
			if(resting)
				dizziness = max(0, dizziness - 15)
				jitteriness = max(0, jitteriness - 15)
			else
				dizziness = max(0, dizziness - 3)
				jitteriness = max(0, jitteriness - 3)

			if(life_tick % 10 == 0)
				// handle trace chemicals for autopsy
				for(var/V in organs)
					var/datum/organ/O = organs[V]
					for(var/chemID in O.trace_chemicals)
						O.trace_chemicals[chemID] = O.trace_chemicals[chemID] - 1
						if(O.trace_chemicals[chemID] <= 0)
							O.trace_chemicals.Remove(chemID)
			for(var/datum/reagent/A in reagents.reagent_list)
				// add chemistry traces to a random organ
				var/V = pick(organs)
				var/datum/organ/O = organs[V]
				O.trace_chemicals[A.name] = 100


			updatehealth()

			return //TODO: DEFERRED

		handle_organs()
			// take care of organ related updates, such as broken and missing limbs

			var/leg_tally = 2
			for(var/name in organs)
				var/datum/organ/external/E = organs[name]
				E.process()
				if(E.status & ROBOT && prob(E.brute_dam + E.burn_dam))
					if(E.name == "l_hand" || E.name == "l_arm")
						if(hand && equipped())
							drop_item()
							emote("custom v drops what they were holding, their [E.display_name?"[E.display_name]":"[E]"] malfunctioning!")
							var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
							spark_system.set_up(5, 0, src)
							spark_system.attach(src)
							spark_system.start()
							spawn(10)
								del(spark_system)
					else if(E.name == "r_hand" || E.name == "r_arm")
						if(!hand && equipped())
							drop_item()
							emote("custom v drops what they were holding, their [E.display_name?"[E.display_name]":"[E]"] malfunctioning!")
							var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
							spark_system.set_up(5, 0, src)
							spark_system.attach(src)
							spark_system.start()
							spawn(10)
								del(spark_system)
					else if(E.name == "l_leg" || E.name == "l_foot" \
						|| E.name == "r_leg" || E.name == "r_foot" && !lying)
						leg_tally--									// let it fail even if just foot&leg
				if(E.status & BROKEN || E.status & DESTROYED)
					if(E.name == "l_hand" || E.name == "l_arm")
						if(hand && equipped())
							if(E.status & SPLINTED && prob(10))
								drop_item()
								emote("scream")
							else
								drop_item()
								emote("scream")
					else if(E.name == "r_hand" || E.name == "r_arm")
						if(!hand && equipped())
							if(E.status & SPLINTED && prob(10))
								drop_item()
								emote("scream")
							else
								drop_item()
								emote("scream")
					else if(E.name == "l_leg" || E.name == "l_foot" \
						|| E.name == "r_leg" || E.name == "r_foot" && !lying)
						if(!(E.status & SPLINTED))
							leg_tally--									// let it fail even if just foot&leg
			// can't stand
			if(leg_tally == 0 && !paralysis && !(lying || resting))
				emote("scream")
				emote("collapse")
				paralysis = 10


		handle_blood()
			// take care of blood and blood loss

			if(stat < 2)
				var/blood_volume = round(vessel.get_reagent_amount("blood"))
				if(blood_volume < 560 && blood_volume)
					var/datum/reagent/blood/B = locate() in vessel //Grab some blood
					if(B) // Make sure there's some blood at all
						if(B.data["donor"] != src) //If it's not theirs, then we look for theirs
							for(var/datum/reagent/blood/D in vessel)
								if(D.data["donor"] == src)
									B = D
									break

						//At this point, we dun care which blood we are adding to, as long as they get more blood.
						B.volume = max(min(B.volume + 560/blood_volume,560), 0) //Less blood = More blood generated per tick

				if(blood_volume > 448)
					if(pale)
						pale = 0
						update_body()
				else if(blood_volume <= 448 && blood_volume > 336)
					if(!pale)
						pale = 1
						update_body()
						var/word = pick("dizzy","woosey","faint")
						src << "\red You feel [word]"
					if(prob(1))
						var/word = pick("dizzy","woosey","faint")
						src << "\red You feel [word]"
				else if(blood_volume <= 336 && blood_volume > 244)
					if(!pale)
						pale = 1
						update_body()
					eye_blurry += 6
					if(prob(15))
						Paralyse(rand(1,3))
				else if(blood_volume <= 244 && blood_volume > 122)
					if(toxloss <= 100)
						toxloss = 100
				else if(blood_volume <= 122)
					death()


		handle_regular_status_updates()
			// take care of misc. things related to health

			// the analgesic effect wears off slowly
			analgesic = max(0, analgesic - 1)

			handle_organs()
			handle_blood()

			updatehealth()

			if(getOxyLoss() > 50) Paralyse(3)

			if(health < config.health_threshold_dead || brain_op_stage == 4.0)
				death()
			else if(health < config.health_threshold_crit)
				if(health <= 20 && prob(1)) spawn(0) emote("gasp")

				if(!reagents.has_reagent("inaprovaline")) adjustOxyLoss(1)

				if(stat != 2)	stat = 1
				Paralyse(5)

			if (stat != 2) //Alive.
				if (silent)
					silent--

				if (resting || sleeping || paralysis || stunned || weakened || (changeling && changeling.changeling_fakedeath)) //Stunned etc.
					if (stunned > 0)
						AdjustStunned(-1)
						stat = 0
					if (weakened > 0)
						AdjustWeakened(-1)
						lying = 1
						stat = 0

					if(resting)
						lying = 1
						stat = 0

					if (paralysis > 0)
						handle_dreams()
						AdjustParalysis(-1)
						blinded = 1
						lying = 1
						stat = 1

					if (sleeping > 0)
						if(stat == 0 && !resting)
						// BUG: this doesn't seem to happen ever.. probably when you hit sleep willingly,
						// it automatically adjusts your stat without calling this proc

						// show them a message so they know what's going on
							src << "\blue You feel very drowsy.. Your eyelids become heavy..."

						handle_dreams()
						adjustHalLoss(-5)
						blinded = 1
						lying = 1
						stat = 1
						if (prob(10) && health && !hal_crit)
							spawn(0)
								emote("snore")
						if(!sleeping_willingly)
							sleeping--

					var/h = hand
					hand = 0
					drop_item()
					hand = 1
					drop_item()
					hand = h

				else	//Not stunned.
					lying = 0
					stat = 0

			else //Dead.
				lying = 1
				blinded = 1
				stat = 2
				silent = 0

			if (stuttering) stuttering--
			if (slurring) slurring--

			//Carn: marker 4#
			var/datum/organ/external/head/head = organs["head"]
			if(head && !head.disfigured)
				if(head.brute_dam >= 45 || head.burn_dam >= 45)
					emote("scream")
					disfigure_face()
					face_op_stage = 0.0

			var/blood_max = 0
			for(var/name in organs)
				var/datum/organ/external/temp = organs[name]
				if(!(temp.status & BLEEDING) || temp.status & ROBOT)
					continue
				blood_max += 2
				if(temp.status & DESTROYED && !(temp.status & GAUZED))
					blood_max += 10 //Yer missing a fucking limb.
			drip(blood_max)
			if (eye_blind)
				eye_blind--
				blinded = 1

			if (ear_deaf > 0) ear_deaf--
			if (ear_damage < 25)
				ear_damage -= 0.05
				ear_damage = max(ear_damage, 0)

			density = !( lying )

			if ((disabilities & 128 || istype(glasses, /obj/item/clothing/glasses/blindfold)))
				blinded = 1
			if ((disabilities & 32 || istype(l_ear, /obj/item/clothing/ears/earmuffs) || istype(r_ear, /obj/item/clothing/ears/earmuffs)))
				ear_deaf = 1

			if (eye_blurry > 0)
				eye_blurry--
				eye_blurry = max(0, eye_blurry)

			if (druggy > 0)
				druggy--
				druggy = max(0, druggy)

			return 1

		handle_regular_hud_updates()

			if(!client)	return 0

			// Apparently deletes all the hud_ icons
			for(var/image/hud in client.images)
				if(copytext(hud.icon_state,1,4) == "hud") //ugly, but icon comparison is worse, I believe
					client.images -= hud//del(hud)

			// Handle special vision stuff, such as thermals or ghost vision
			// -------------------------------------------------------------
			if (stat == 2 || (XRAY in mutations))
				sight |= SEE_TURFS
				sight |= SEE_MOBS
				sight |= SEE_OBJS
				see_in_dark = 8
				if(!druggy)
					see_invisible = 2

			else if (seer)
				var/obj/effect/rune/R = locate() in loc
				if (istype(R) && R.word1 == wordsee && R.word2 == wordhell && R.word3 == wordjoin)
					see_invisible = 15
				else
					seer = 0
					see_invisible = 0


			else if (istype(wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja))
				switch(wear_mask:mode)
					if(0)
						var/target_list[] = list()
						for(var/mob/living/target in oview(src))
							if( target.mind&&(target.mind.special_role||issilicon(target)) )//They need to have a mind.
								target_list += target
						if(target_list.len)//Everything else is handled by the ninja mask proc.
							wear_mask:assess_targets(target_list, src)
						if (!druggy)
							see_invisible = 0
					if(1)
						see_in_dark = 5
						if(!druggy)
							see_invisible = 0
					if(2)
						sight |= SEE_MOBS
						if(!druggy)
							see_invisible = 2
					if(3)
						sight |= SEE_TURFS
						if(!druggy)
							see_invisible = 0

			else if(istype(glasses, /obj/item/clothing/glasses/meson))
				sight |= SEE_TURFS
				if(!druggy)
					see_invisible = 0

			else if(istype(glasses, /obj/item/clothing/glasses/night))
				see_in_dark = 5
				if(!druggy)
					see_invisible = 0

			else if(istype(glasses, /obj/item/clothing/glasses/thermal))
				sight |= SEE_MOBS
				if(!druggy)
					see_invisible = 2

			else if(istype(glasses, /obj/item/clothing/glasses/material))
				sight |= SEE_OBJS
				if (!druggy)
					see_invisible = 0

			else if(stat != 2)
				sight &= ~SEE_TURFS
				sight &= ~SEE_MOBS
				sight &= ~SEE_OBJS
				if (mutantrace == "lizard" || mutantrace == "metroid")
					see_in_dark = 3
					see_invisible = 1

				else if (istajaran(src))
					see_in_dark = 8

				else if (druggy) // If drugged~
					see_in_dark = 2
					//see_invisible regulated by drugs themselves.
				else
					see_in_dark = 2

				var/seer = 0
				var/obj/effect/rune/R = locate() in loc
				if (istype(R) && R.word1 == wordsee && R.word2 == wordhell && R.word3 == wordjoin)
					seer = 1
				if(!seer)
					see_invisible = 0

			else if(istype(head, /obj/item/clothing/head/helmet/welding))		// wat.  This is never fucking called.
				if(!head:up && tinted_weldhelh)
					see_in_dark = 1



		/* HUD shit goes here, as long as it doesn't modify src.sight flags */
		// The purpose of this is to stop xray and w/e from preventing you from using huds -- Love, Doohl


			// Special on-map HUDs like the medical HUD
			// ----------------------------------------
			if(istype(glasses, /obj/item/clothing/glasses/hud/health))
				glasses:process_hud(src)
				if (!druggy)
					see_invisible = 0

			else if(istype(glasses, /obj/item/clothing/glasses/hud/security))
				glasses:process_hud(src)
				if (!druggy)
					see_invisible = 0

			else if(istype(glasses, /obj/item/clothing/glasses/sunglasses))
				see_in_dark = 1
				if(istype(glasses, /obj/item/clothing/glasses/sunglasses/sechud))
					if(glasses:hud)
						glasses:hud:process_hud(src)
				if (!druggy)
					see_invisible = 0

			// ======================================================
			// HUD icon updates(sleep, rest, health, nutrition, etc.)
			// ======================================================

			// Update the sleep icon
			// -----------------------
			if (src.sleep && !hal_crit)
				src.sleep.icon_state = text("sleep[]", src.sleeping > 0 ? 1 : 0)
				src.sleep.overlays = null
				if(src.sleeping_willingly)
					src.sleep.overlays += icon(src.sleep.icon, "sleep_willing")

			// Update the health display
			// -------------------------
			if (healths)
				if (stat != 2)
					// if the mob is not in crit, do a switch
					if(health - halloss >= config.health_threshold_crit)
						switch(health - halloss)
							if(100 to INFINITY)
								healths.icon_state = "health0"
							if(80 to 100)
								healths.icon_state = "health1"
							if(60 to 80)
								healths.icon_state = "health2"
							if(40 to 60)
								healths.icon_state = "health3"
							if(20 to 40)
								healths.icon_state = "health4"
							else
								healths.icon_state = "health5"
					// if he's in crit, display crit icon
					else
						healths.icon_state = "health6"

				// if he's dead, display death icon
				else
					healths.icon_state = "health7"

				if(hal_screwyhud == 1)
					healths.icon_state = "health6"
				if(hal_screwyhud == 2)
					healths.icon_state = "health7"

			// Update the nutrition icon
			// -------------------------
			if (nutrition_icon)
				switch(nutrition)
					if(450 to INFINITY)
						nutrition_icon.icon_state = "nutrition0"
					if(350 to 450)
						nutrition_icon.icon_state = "nutrition1"
					if(250 to 350)
						nutrition_icon.icon_state = "nutrition2"
					if(150 to 250)
						nutrition_icon.icon_state = "nutrition3"
					else
						nutrition_icon.icon_state = "nutrition4"

			// Update the icon displaying whether we're on internals
			// -----------------------------------------------------
			if (pressure)

				if(istype(wear_suit, /obj/item/clothing/suit/space)||istype(wear_suit, /obj/item/clothing/suit/armor/captain))
					pressure.icon_state = "pressure0"

				else
					var/datum/gas_mixture/environment = loc.return_air()
					if(environment)
						switch(environment.return_pressure())
							if(HAZARD_HIGH_PRESSURE to INFINITY)
								pressure.icon_state = "pressure2"
							if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
								pressure.icon_state = "pressure1"
							if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
								pressure.icon_state = "pressure0"
							if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
								pressure.icon_state = "pressure-1"
							else
								pressure.icon_state = "pressure-2"

			// Update the icon which displays whether we're pulling something
			// --------------------------------------------------------------
			if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"

			// Update the rest icon
			// --------------------
			if(rest)	rest.icon_state = "rest[(resting || lying || sleeping) ? 1 : 0]"

			// Update the air alarms
			// ---------------------
			if (toxin || hal_screwyhud == 4)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
			if (oxygen || hal_screwyhud == 3)	oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
			if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
			//NOTE: INVESTIGATE NUKE BURNINGS
			//NOTE: the alerts dont reset when youre out of danger. dont blame me,
			//blame the person who coded them. Temporary fix added.

			// Update body temperature display
			// -------------------------------
			if(bodytemp)
				switch(bodytemperature) //310.055 optimal body temp
					if(370 to INFINITY)
						bodytemp.icon_state = "temp4"
					if(350 to 370)
						bodytemp.icon_state = "temp3"
					if(335 to 350)
						bodytemp.icon_state = "temp2"
					if(320 to 335)
						bodytemp.icon_state = "temp1"
					if(300 to 320)
						bodytemp.icon_state = "temp0"
					if(295 to 300)
						bodytemp.icon_state = "temp-1"
					if(280 to 295)
						bodytemp.icon_state = "temp-2"
					if(260 to 280)
						bodytemp.icon_state = "temp-3"
					else
						bodytemp.icon_state = "temp-4"

			// ====================================================
			// Update complete screen overlays, like blurred vision
			// ====================================================
			if(!client)	return 0 //Wish we did not need these
			client.screen -= hud_used.blurry
			client.screen -= hud_used.druggy
			client.screen -= hud_used.vimpaired
			client.screen -= hud_used.darkMask

			if ((blind && stat != 2))
				if ((blinded))
					blind.layer = 18
				else
					blind.layer = 0

					if(disabilities & 1)
						if(!glasses)
							client.screen += hud_used.vimpaired
						else if (glasses && istype(glasses,/obj/item/clothing/glasses))
							var/obj/item/clothing/glasses/G = glasses
							if(!G.prescription)
								client.screen += hud_used.vimpaired
						else
							client.screen += hud_used.vimpaired
					else
						if(glasses && istype(glasses,/obj/item/clothing/glasses))
							var/obj/item/clothing/glasses/G = glasses
							if(G.prescription)
								client.screen += hud_used.vimpaired

					if (eye_blurry)
						client.screen += hud_used.blurry

					if (druggy)
						client.screen += hud_used.druggy

					if ((istype(head, /obj/item/clothing/head/helmet/welding)) )
						if(!head:up && tinted_weldhelh)
							client.screen += hud_used.darkMask

					if(eye_stat > 20)
						if((eye_stat > 30))
							client.screen += hud_used.darkMask
						else
							client.screen += hud_used.vimpaired


			// =============================================
			// If we're a machine, check if we can still see
			// =============================================
			if (stat != 2)
				if (machine)
					if (!( machine.check_eye(src) ))
						reset_view(null)
				else if(!(mRemote in mutations) && !client.adminobs)
					reset_view(null)
					if(remoteobserve)
						remoteobserve = null

			return 1

		handle_random_events()
			// Puke if toxloss is too high
			if(!stat)
				if (getToxLoss() >= 45 && nutrition > 20)
					lastpuke ++
					if(lastpuke >= 25) // about 25 second delay I guess
						Stun(5)

						src.vomit()

						// make it so you can only puke so fast
						lastpuke = 0

		handle_virus_updates()
			if(bodytemperature > 406)
				for(var/datum/disease/D in viruses)
					D.cure()

			if(!virus2)
				for(var/obj/effect/decal/cleanable/blood/B in view(1,src))
					if(B.virus2 && get_infection_chance())
						infect_virus2(src,B.virus2)
				for(var/obj/effect/decal/cleanable/mucus/M in view(1,src))
					if(M.virus2 && get_infection_chance())
						infect_virus2(src,M.virus2)
			else
				if(isnull(virus2)) // Trying to figure out a runtime error that keeps repeating
					CRASH("virus2 nulled before calling activate()")
				else
					virus2.activate(src)

				// activate may have deleted the virus
				if(!virus2) return

				// check if we're immune
				if(virus2.antigen & src.antibodies) virus2.dead = 1


			return

		handle_stomach()
			spawn(0)
				for(var/mob/M in stomach_contents)
					if(M.loc != src)
						stomach_contents.Remove(M)
						continue
					if(istype(M, /mob/living/carbon) && stat != 2)
						if(M.stat == 2)
							M.death(1)
							stomach_contents.Remove(M)
							del(M)
							continue
						if(air_master.current_cycle%3==1)
							if(!M.nodamage)
								M.adjustBruteLoss(5)
							nutrition += 10
			if(nutrition <= 150)
				if (prob(1))
					var/list/funny_comments = list(
						"You feel hungry..",
						"You feel thirsty..",
						"Perhaps you should grab a bite to eat..",
						"Your stomach rumbles..",
						"Perhaps you should have a drink...",
						"You feel empty inside..",
						"You feel a bit peckish..",
						"Whatever you last ate didn't do much to fill you up...",
						"Hmm, some pizza would be nice..",
						"You feel the darkness consuming you from within. You think you should find some food to soothe the devil inside you.",
						"Are you on hunger strike or something?",
						"You feel a void forming in yourself..",
						"Your stomach files a complaint with your brain!",
						"You feel a nagging sense of emptiness.."
					)

					src << "\blue [pick(funny_comments)]"

		handle_changeling()
			if (mind)
				if (mind.special_role == "Changeling" && changeling)
					changeling.chem_charges = between(0, ((max((0.9 - (changeling.chem_charges / 50)), 0.1)*changeling.chem_recharge_multiplier) + changeling.chem_charges), changeling.chem_storage)
					if ((changeling.geneticdamage > 0))
						changeling.geneticdamage = changeling.geneticdamage-1

	handle_shock()
		..()

		if(analgesic) return // analgesic avoids all traumatic shock temporarily

		if(health < 0)
			// health 0 makes you immediately collapse
			shock_stage = max(shock_stage, 61)

		if(traumatic_shock >= 80)
			shock_stage += 1
		else
			if(shock_stage > 100) shock_stage = 100
			shock_stage--
			shock_stage = max(shock_stage, 0)
			return

		if (shock_stage > 60)
			if(shock_stage == 61)
				for(var/mob/O in viewers(src, null))
					O.show_message("<b>[src.name]'s</b> body becomes limp.", 1)
			Stun(20)
			lying = 1
			disease_symptoms |= DISEASE_WHISPER

		if (shock_stage > 70) if(shock_stage % 30 == 0)
			Paralyse(rand(15,28))
		if(shock_stage >= 30)
			if(shock_stage == 30) emote("me",1,"is having trouble keeping their eyes open.")
			eye_blurry = max(2, eye_blurry)
			stuttering = max(stuttering, 5)
		// pain messages
		if(shock_stage == 10)
			src << "<font color='red'><b>"+pick("It hurts so much!", "You really need some painkillers..", "Dear god, the pain!")
		else if(shock_stage == 40)
			src << "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")
		else if(shock_stage == 80)
			src << "<font color='red'><b>"+pick("You see a light at the end of the tunnel!", "You feel like you could die any moment now.", "You're about to lose consciousness.")


/mob/living/carbon/human/proc/handle_clothing()
	// Non-visual stuff that was in update_clothing()

	if(buckled)
		if(istype(buckled, /obj/structure/stool/bed/chair))
			lying = 0
		else
			lying = 1

	if(!w_uniform)
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.
		for (var/obj/item/thing in list(r_store, l_store, wear_id, belt))
			if (thing)
				u_equip(thing)
				if (client)
					client.screen -= thing
				if (thing)
					thing.loc = loc
					thing.dropped(src)
					thing.layer = initial(thing.layer)


	name = get_visible_name()
