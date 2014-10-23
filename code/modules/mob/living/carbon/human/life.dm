//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32


var/global/list/unconscious_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage6"),\
	"7" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage7"),\
	"8" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage8"),\
	"9" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage9"),\
	"10" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage10"))
var/global/list/oxyloss_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay6"),\
	"7" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay7"))
var/global/list/brutefireloss_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay6"))
var/global/list/organ_damage_overlays = list(
	"l_hand_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_min", "layer" = 21),\
	"l_hand_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_mid", "layer" = 21),\
	"l_hand_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_max", "layer" = 21),\
	"l_hand_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_gone", "layer" = 21),\
	"r_hand_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_min", "layer" = 21),\
	"r_hand_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_mid", "layer" = 21),\
	"r_hand_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_max", "layer" = 21),\
	"r_hand_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_gone", "layer" = 21),\
	"l_arm_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_min", "layer" = 21),\
	"l_arm_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_mid", "layer" = 21),\
	"l_arm_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_max", "layer" = 21),\
	"l_arm_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_gone", "layer" = 21),\
	"r_arm_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_min", "layer" = 21),\
	"r_arm_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_mid", "layer" = 21),\
	"r_arm_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_max", "layer" = 21),\
	"r_arm_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_gone", "layer" = 21),\
	"l_leg_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_min", "layer" = 21),\
	"l_leg_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_mid", "layer" = 21),\
	"l_leg_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_max", "layer" = 21),\
	"l_leg_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_gone", "layer" = 21),\
	"r_leg_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_min", "layer" = 21),\
	"r_leg_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_mid", "layer" = 21),\
	"r_leg_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_max", "layer" = 21),\
	"r_leg_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_gone", "layer" = 21),\
	"r_foot_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_min", "layer" = 21),\
	"r_foot_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_mid", "layer" = 21),\
	"r_foot_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_max", "layer" = 21),\
	"r_foot_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_gone", "layer" = 21),\
	"l_foot_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_min", "layer" = 21),\
	"l_foot_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_mid", "layer" = 21),\
	"l_foot_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_max", "layer" = 21),\
	"l_foot_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_gone", "layer" = 21),\
	"chest_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_min", "layer" = 21),\
	"chest_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_mid", "layer" = 21),\
	"chest_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_max", "layer" = 21),\
	"chest_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_gone", "layer" = 21),\
	"head_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_min", "layer" = 21),\
	"head_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_mid", "layer" = 21),\
	"head_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_max", "layer" = 21),\
	"head_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_gone", "layer" = 21),\
	"groin_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_min", "layer" = 21),\
	"groin_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_mid", "layer" = 21),\
	"groin_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_max", "layer" = 21),\
	"groin_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_gone", "layer" = 21))
/mob/living/carbon/human
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/prev_gender = null // Debug for plural genders
	var/temperature_alert = 0
	var/in_stasis = 0
	var/do_deferred_species_setup=0
	var/exposedtimenow = 0
	var/firstexposed = 0

// Doing this during species init breaks shit.
/mob/living/carbon/human/proc/DeferredSpeciesSetup()
	var/mut_update=0
	if(species.default_mutations.len>0)
		for(var/mutation in species.default_mutations)
			if(!(mutation in mutations))
				mutations.Add(mutation)
				mut_update=1
	if(species.default_blocks.len>0)
		for(var/block in species.default_blocks)
			if(!dna.GetSEState(block))
				dna.SetSEState(block,1)
				mut_update=1
	if(mut_update)
		domutcheck(src,null,MUTCHK_FORCED)
		update_mutations()

/mob/living/carbon/human/Life()
	set invisibility = 0
	//set background = 1

	if (monkeyizing)	return
	if(!loc)			return	// Fixing a null error that occurs when the mob isn't found in the world -- TLE

	..()

	if(do_deferred_species_setup)
		DeferredSpeciesSetup()
		do_deferred_species_setup=0

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//TODO: seperate this out
	// update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++
	var/datum/gas_mixture/environment = loc.return_air()

	in_stasis = istype(loc, /obj/structure/closet/body_bag/cryobag) && loc:opened == 0
	if(in_stasis) loc:used++

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !in_stasis)
		if(air_master.current_cycle%4==2 || failed_last_breath) 	//First, resolve location and get a breath
			breathe() 				//Only try to take a breath every 4 ticks, unless suffocating

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		if(check_mutations)
			testing("Updating [src.real_name]'s mutations: "+english_list(mutations))
			domutcheck(src,null,MUTCHK_FORCED)
			update_mutations()
			check_mutations=0

		//Updates the number of stored chemicals for powers
		handle_changeling()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//Organ failure.
		handle_organs()

		//Random events (vomiting etc)
		handle_random_events()

		handle_virus_updates()

		//stuff in the stomach
		handle_stomach()

		handle_shock()

		handle_pain()

		handle_medical_side_effects()

	handle_stasis_bag()

	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000))	//We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		return											//We go ahead and process them 5 times for HUD images and other stuff though.

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	//Check if we're on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()		//Optimized a bit
	update_canmove()

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	handle_regular_hud_updates()

	pulse = handle_pulse()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(mind && mind.vampire)
		handle_vampire()



/mob/living/carbon/human/calculate_affecting_pressure(var/pressure)
	..()
	var/pressure_difference = abs( pressure - ONE_ATMOSPHERE )

	var/pressure_adjustment_coefficient = 1	//Determins how much the clothing you are wearing protects you in percent.
	if(wear_suit && (wear_suit.flags & STOPSPRESSUREDMAGE))
		pressure_adjustment_coefficient -= PRESSURE_SUIT_REDUCTION_COEFFICIENT
	if(head && (head.flags & STOPSPRESSUREDMAGE))
		pressure_adjustment_coefficient -= PRESSURE_HEAD_REDUCTION_COEFFICIENT
	pressure_adjustment_coefficient = max(pressure_adjustment_coefficient,0) //So it isn't less than 0
	pressure_difference = pressure_difference * pressure_adjustment_coefficient
	if(pressure > ONE_ATMOSPHERE)
		return ONE_ATMOSPHERE + pressure_difference
	else
		return ONE_ATMOSPHERE - pressure_difference

/mob/living/carbon/human

	proc/handle_disabilities()
		if (disabilities & EPILEPSY)
			if ((prob(1) && paralysis < 1))
				src << "\red You have a seizure!"
				for(var/mob/O in viewers(src, null))
					if(O == src)
						continue
					O.show_message(text("\red <B>[src] starts having a seizure!"), 1)
				Paralyse(10)
				make_jittery(1000)

		// If we have the gene for being crazy, have random events.
		if(dna.GetSEState(HALLUCINATIONBLOCK))
			if(prob(1) && hallucination < 1)
				hallucination += 20

		if (disabilities & COUGHING)
			if ((prob(5) && paralysis <= 1))
				drop_item()
				spawn( 0 )
					emote("cough")
					return
		if (disabilities & TOURETTES)
			if ((prob(10) && paralysis <= 1))
				Stun(10)
				spawn( 0 )
					switch(rand(1, 3))
						if(1)
							emote("twitch")
						if(2 to 3)
							say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
					var/old_x = pixel_x
					var/old_y = pixel_y
					pixel_x += rand(-2,2)
					pixel_y += rand(-1,1)
					sleep(2)
					pixel_x = old_x
					pixel_y = old_y
					return
		if (getBrainLoss() >= 60 && stat != 2)
			if (prob(3))
				switch(pick(1,2,3))
					if(1)
						say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", "without oxigen blob don't evoluate?", "CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", "can u give me [pick("telikesis","halk","eppilapse")]?", "THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", "I WANNA PET TEH monkeyS", "stop grifing me!!!!", "SOTP IT#"))
					if(2)
						say(pick( \
							"FUS RO DAH", \
							"fucking 4rries!", \
							"stat me", \
							">my face", \
							"roll it easy!", \
							"waaaaaagh!!!", \
							"red wonz go fasta", \
							"FOR TEH EMPRAH", \
							"lol2cat", \
							"dem dwarfs man, dem dwarfs", \
							"SPESS MAHREENS", \
							"hwee did eet fhor khayosss", \
							"lifelike texture ;_;", \
							"luv can bloooom", \
							"PACKETS!!!", \
							"SARAH HALE DID IT!!!", \
							"Don't tell Chase", \
							"not so tough now huh", \
							"WERE NOT BAY!!", \
							"BLAME HOSHI!!!"))
					if(3)
						emote("drool")

		if(species.name == "Tajaran")
			if(prob(1)) // WAS: 3
				vomit(1) // Hairball

		if(stat != 2)
			var/rn = rand(0, 200)
			if(getBrainLoss() >= 5)
				if(0 <= rn && rn <= 3)
					custom_pain("Your head feels numb and painful.")
			if(getBrainLoss() >= 15)
				if(4 <= rn && rn <= 6) if(eye_blurry <= 0)
					src << "\red It becomes hard to see for some reason."
					eye_blurry = 10
			if(getBrainLoss() >= 35)
				if(7 <= rn && rn <= 9) if(hand && equipped())
					src << "\red Your hand won't respond properly, you drop what you're holding."
					drop_item()
			if(getBrainLoss() >= 50)
				if(10 <= rn && rn <= 12) if(!lying)
					src << "\red Your legs won't respond properly, you fall down."
					resting = 1

	proc/handle_stasis_bag()
		// Handle side effects from stasis bag
		if(in_stasis)
			// First off, there's no oxygen supply, so the mob will slowly take brain damage
			adjustBrainLoss(0.1)

			// Next, the method to induce stasis has some adverse side-effects, manifesting
			// as cloneloss
			adjustCloneLoss(0.1)

	proc/handle_mutations_and_radiation()
		if(getFireLoss())
			if((M_RESIST_HEAT in mutations) || (prob(1)))
				heal_organ_damage(0,1)


		for(var/datum/dna/gene/gene in dna_genes)
			if(!gene.block)
				continue
			if(gene.is_active(src))
				gene.OnMobLife(src)

		if (radiation)
			if (radiation > 100)
				radiation = 100
				Weaken(10)
				src << "\red You feel weak."
				emote("collapse")

			if (radiation < 0)
				radiation = 0

			else
				if(species.flags & RAD_ABSORB)
					var/rads = radiation/25
					radiation -= rads
					nutrition += rads
					adjustBruteLoss(-(rads))
					adjustOxyLoss(-(rads))
					adjustToxLoss(-(rads))
					updatehealth()
					return

				var/damage = 0
				switch(radiation)
					if(1 to 49)
						radiation--
						if(prob(25))
							adjustToxLoss(1)
							damage = 1
							updatehealth()

					if(50 to 74)
						radiation -= 2
						damage = 1
						adjustToxLoss(1)
						if(prob(5))
							radiation -= 5
							Weaken(3)
							src << "\red You feel weak."
							emote("collapse")
						updatehealth()

					if(75 to 100)
						radiation -= 3
						adjustToxLoss(3)
						damage = 1
						if(prob(1))
							src << "\red You mutate!"
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						updatehealth()

				if(damage && organs.len)
					var/datum/organ/external/O = pick(organs)
					if(istype(O)) O.add_autopsy_data("Radiation Poisoning", damage)

	proc/breathe()
		if(reagents.has_reagent("lexorin")) return
		if(M_NO_BREATH in mutations) return // No breath mutation means no breathing.
		if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return
		if(species && species.flags & NO_BREATHE) return

		var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]
		L.process()

		var/datum/gas_mixture/environment = loc.return_air()
		var/datum/gas_mixture/breath
		// HACK NEED CHANGING LATER
		if(health < config.health_threshold_crit)
			losebreath++
		if(losebreath>0) //Suffocating so do not take a breath
			losebreath--
			if (prob(10)) //Gasp per 10 ticks? Sounds about right.
				spawn emote("gasp")
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)
		else
			//First, check for air from internal atmosphere (using an air tank and mask generally)
			breath = get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
			//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

			//No breath from internal atmosphere so get breath from location
			if(!breath)
				if(isobj(loc))
					var/obj/location_as_object = loc
					breath = location_as_object.handle_internal_lifeform(src, BREATH_MOLES)
				else if(isturf(loc))
					var/breath_moles = 0
					/*if(environment.return_pressure() > ONE_ATMOSPHERE)
						// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
						breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
					else*/
						// Not enough air around, take a percentage of what's there to model this properly
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

					breath = loc.remove_air(breath_moles)

					if(!is_lung_ruptured())
						if(!breath || breath.total_moles < BREATH_MOLES / 5 || breath.total_moles > BREATH_MOLES * 5)
							if(prob(5))
								rupture_lung()

					// Handle filtering
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

						for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
							if(smoke.reagents.total_volume)
								smoke.reagents.reaction(src, INGEST)
								spawn(5)
									if(smoke)
										smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
								break // If they breathe in the nasty stuff once, no need to continue checking

			else //Still give containing object the chance to interact
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)

		handle_breath(breath)

		if(species.name=="Plasmaman")

			// Check if we're wearing our biosuit and mask.
			if (!istype(wear_suit,/obj/item/clothing/suit/space/plasmaman) || !istype(head,/obj/item/clothing/head/helmet/space/plasmaman))
				//testing("Plasmaman [src] leakin'.  coverflags=[cover_flags]")
				// OH FUCK HE LEAKIN'.
				// This was OP.
				//environment.adjust(tx = environment.total_moles()*BREATH_PERCENTAGE) // About one breath's worth. (I know we aren't breathing it out, but this should be about the right amount)
				if(!on_fire)
					src << "<span class='warning'>Your body reacts with the atmosphere and bursts into flame!</span>"
				adjust_fire_stacks(0.5)
				IgniteMob()
			else
				if(fire_stacks)
					var/obj/item/clothing/suit/space/plasmaman/PS=wear_suit
					PS.Extinguish(src)

		if(breath)
			loc.assume_air(breath)

			//spread some viruses while we are at it
			if (virus2.len > 0)
				if (prob(10) && get_infection_chance(src))
//					log_debug("[src] : Exhaling some viruses")
					for(var/mob/living/carbon/M in view(1,src))
						src.spread_disease_to(M)


	proc/get_breath_from_internal(volume_needed)
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

	// USED IN DEATHWHISPERS
	proc/isInCrit()
		// Health is in deep shit and we're not already dead
		return health <= config.health_threshold_crit && stat != 2

	proc/handle_breath(var/datum/gas_mixture/breath)
		if(status_flags & GODMODE)
			return 0

		if(!breath || (breath.total_moles() == 0) || suiciding)
			if(reagents.has_reagent("inaprovaline"))
				return 0
			if(suiciding)
				adjustOxyLoss(2)//If you are suiciding, you should die a little bit faster
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

	proc/handle_environment(datum/gas_mixture/environment)
		if(!environment)
			return
		var/loc_temp = T0C
		if(istype(loc, /obj/mecha))
			var/obj/mecha/M = loc
			loc_temp =  M.return_temperature()
		//else if(istype(get_turf(src), /turf/space))
		if(istype(loc, /obj/spacepod))
			var/obj/spacepod/S = loc
			loc_temp = S.return_temperature()
		else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			loc_temp = loc:air_contents.temperature
		else
			loc_temp = environment.temperature

		//world << "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Thermal protection: [get_thermal_protection()] - Fire protection: [thermal_protection + add_fire_protection(loc_temp)] - Heat capacity: [environment_heat_capacity] - Location: [loc] - src: [src]"

		//Body temperature is adjusted in two steps. Firstly your body tries to stabilize itself a bit.
		if(stat != 2)
			stabilize_temperature_from_calories()

//		log_debug("Adjusting to atmosphere.")
		//After then, it reacts to the surrounding atmosphere based on your thermal protection
		if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
			if(loc_temp < bodytemperature)
				//Place is colder than we are
				var/thermal_protection = get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
				if(thermal_protection < 1)
					bodytemperature += min((1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX)
			else
				//Place is hotter than we are
				var/thermal_protection = get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
				if(thermal_protection < 1)
					bodytemperature += min((1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

		// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
		if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
			//Body temperature is too hot.
			fire_alert = max(fire_alert, 2)
			if(status_flags & GODMODE)	return 1	//godmode
			if(dna.mutantrace != "slime") //slimes are unaffected by heat
				switch(bodytemperature)
					if(360 to 400)
						apply_damage(HEAT_DAMAGE_LEVEL_1, BURN, used_weapon = "High Body Temperature")
						fire_alert = max(fire_alert, 2)
					if(400 to 1000)
						apply_damage(HEAT_DAMAGE_LEVEL_2, BURN, used_weapon = "High Body Temperature")
						fire_alert = max(fire_alert, 2)
					if(1000 to INFINITY)
						apply_damage(HEAT_DAMAGE_LEVEL_3, BURN, used_weapon = "High Body Temperature")
						fire_alert = max(fire_alert, 2)
			else
				fire_alert = 0

		else if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			fire_alert = max(fire_alert, 1)
			if(status_flags & GODMODE)	return 1	//godmode
			if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
				if(dna.mutantrace == "slime")
					adjustToxLoss(round(BODYTEMP_HEAT_DAMAGE_LIMIT - bodytemperature))
					fire_alert = max(fire_alert, 1)
				else
					switch(bodytemperature)
						if(200 to 260)
							apply_damage(COLD_DAMAGE_LEVEL_1, BURN, used_weapon = "Low Body Temperature")
							fire_alert = max(fire_alert, 1)
						if(120 to 200)
							apply_damage(COLD_DAMAGE_LEVEL_2, BURN, used_weapon = "Low Body Temperature")
							fire_alert = max(fire_alert, 1)
						if(-INFINITY to 120)
							apply_damage(COLD_DAMAGE_LEVEL_3, BURN, used_weapon = "Low Body Temperature")
							fire_alert = max(fire_alert, 1)

		// Account for massive pressure differences.  Done by Polymorph
		// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

		var/pressure = environment.return_pressure()
		var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
		if(status_flags & GODMODE)	return 1	//godmode

		if(adjusted_pressure >= species.hazard_high_pressure)
			adjustBruteLoss( min( ( (adjusted_pressure / species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			pressure_alert = 2
		else if(adjusted_pressure >= species.warning_high_pressure)
			pressure_alert = 1
		else if(adjusted_pressure >= species.warning_low_pressure)
			pressure_alert = 0
		else if(adjusted_pressure >= species.hazard_low_pressure)
			pressure_alert = -1
		else
			if( !(M_RESIST_COLD in mutations))
				adjustBruteLoss( LOW_PRESSURE_DAMAGE )
				if(istype(src.loc, /turf/space)) adjustBruteLoss( LOW_PRESSURE_DAMAGE ) //Space doubles damage
				pressure_alert = -2
			else
				pressure_alert = -1

		if(environment.toxins > MOLES_PLASMA_VISIBLE)
			pl_effects()
		return

///FIRE CODE
	handle_fire()
		if(..())
			return
		var/thermal_protection = get_heat_protection(30000) //If you don't have fire suit level protection, you get a temperature increase
		if((1 - thermal_protection) > 0.0001)
			bodytemperature += BODYTEMP_HEATING_MAX
		return
//END FIRE CODE

	/*
	proc/adjust_body_temperature(current, loc_temp, boost)
		var/temperature = current
		var/difference = abs(current-loc_temp)	//get difference
		var/increments// = difference/10			//find how many increments apart they are
		if(difference > 50)
			increments = difference/5
		else
			increments = difference/10
		var/change = increments*boost	// Get the amount to change by (x per increment)
		var/temp_change
		if(current < loc_temp)
			temperature = min(loc_temp, temperature+change)
		else if(current > loc_temp)
			temperature = max(loc_temp, temperature-change)
		temp_change = (temperature - current)
		return temp_change
	*/

	proc/stabilize_temperature_from_calories()
		var/body_temperature_difference = 310.15 - bodytemperature
		if (abs(body_temperature_difference) < 0.5)
			return //fuck this precision
		switch(bodytemperature)
			if(-INFINITY to 260.15) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
				if(nutrition >= 2) //If we are very, very cold we'll use up quite a bit of nutriment to heat us up.
					nutrition -= 2
				var/recovery_amt = max((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
//				log_debug("Cold. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
				bodytemperature += recovery_amt
			if(260.15 to 360.15)
				var/recovery_amt = body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
//				log_debug("Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
				bodytemperature += recovery_amt
			if(360.15 to INFINITY) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
				//We totally need a sweat system cause it totally makes sense...~
				var/recovery_amt = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers
//				log_debug("Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
				bodytemperature += recovery_amt

	//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, UPPER_TORSO, LOWER_TORSO, etc. See setup.dm for the full list)
	proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
		var/thermal_protection_flags = 0
		//Handle normal clothing
		if(head)
			if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
				thermal_protection_flags |= head.heat_protection
		if(wear_suit)
			if(wear_suit.max_heat_protection_temperature && wear_suit.max_heat_protection_temperature >= temperature)
				thermal_protection_flags |= wear_suit.heat_protection
		if(w_uniform)
			if(w_uniform.max_heat_protection_temperature && w_uniform.max_heat_protection_temperature >= temperature)
				thermal_protection_flags |= w_uniform.heat_protection
		if(shoes)
			if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
				thermal_protection_flags |= shoes.heat_protection
		if(gloves)
			if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
				thermal_protection_flags |= gloves.heat_protection
		if(wear_mask)
			if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
				thermal_protection_flags |= wear_mask.heat_protection

		return thermal_protection_flags

	proc/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
		var/thermal_protection_flags = get_heat_protection_flags(temperature)

		var/thermal_protection = 0.0
		if(M_RESIST_HEAT in mutations)
			return 1
		if(thermal_protection_flags)
			if(thermal_protection_flags & HEAD)
				thermal_protection += THERMAL_PROTECTION_HEAD
			if(thermal_protection_flags & UPPER_TORSO)
				thermal_protection += THERMAL_PROTECTION_UPPER_TORSO
			if(thermal_protection_flags & LOWER_TORSO)
				thermal_protection += THERMAL_PROTECTION_LOWER_TORSO
			if(thermal_protection_flags & LEG_LEFT)
				thermal_protection += THERMAL_PROTECTION_LEG_LEFT
			if(thermal_protection_flags & LEG_RIGHT)
				thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
			if(thermal_protection_flags & FOOT_LEFT)
				thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
			if(thermal_protection_flags & FOOT_RIGHT)
				thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
			if(thermal_protection_flags & ARM_LEFT)
				thermal_protection += THERMAL_PROTECTION_ARM_LEFT
			if(thermal_protection_flags & ARM_RIGHT)
				thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
			if(thermal_protection_flags & HAND_LEFT)
				thermal_protection += THERMAL_PROTECTION_HAND_LEFT
			if(thermal_protection_flags & HAND_RIGHT)
				thermal_protection += THERMAL_PROTECTION_HAND_RIGHT


		return min(1,thermal_protection)

	//See proc/get_heat_protection_flags(temperature) for the description of this proc.
	proc/get_cold_protection_flags(temperature)
		var/thermal_protection_flags = 0
		//Handle normal clothing

		if(head)
			if(head.min_cold_protection_temperature && head.min_cold_protection_temperature <= temperature)
				thermal_protection_flags |= head.cold_protection
		if(wear_suit)
			if(wear_suit.min_cold_protection_temperature && wear_suit.min_cold_protection_temperature <= temperature)
				thermal_protection_flags |= wear_suit.cold_protection
		if(w_uniform)
			if(w_uniform.min_cold_protection_temperature && w_uniform.min_cold_protection_temperature <= temperature)
				thermal_protection_flags |= w_uniform.cold_protection
		if(shoes)
			if(shoes.min_cold_protection_temperature && shoes.min_cold_protection_temperature <= temperature)
				thermal_protection_flags |= shoes.cold_protection
		if(gloves)
			if(gloves.min_cold_protection_temperature && gloves.min_cold_protection_temperature <= temperature)
				thermal_protection_flags |= gloves.cold_protection
		if(wear_mask)
			if(wear_mask.min_cold_protection_temperature && wear_mask.min_cold_protection_temperature <= temperature)
				thermal_protection_flags |= wear_mask.cold_protection

		return thermal_protection_flags

	proc/get_cold_protection(temperature)

		if(M_RESIST_COLD in mutations)
			return 1 //Fully protected from the cold.

		temperature = max(temperature, 2.7) //There is an occasional bug where the temperature is miscalculated in ares with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
		var/thermal_protection_flags = get_cold_protection_flags(temperature)

		var/thermal_protection = 0.0
		if(thermal_protection_flags)
			if(thermal_protection_flags & HEAD)
				thermal_protection += THERMAL_PROTECTION_HEAD
			if(thermal_protection_flags & UPPER_TORSO)
				thermal_protection += THERMAL_PROTECTION_UPPER_TORSO
			if(thermal_protection_flags & LOWER_TORSO)
				thermal_protection += THERMAL_PROTECTION_LOWER_TORSO
			if(thermal_protection_flags & LEG_LEFT)
				thermal_protection += THERMAL_PROTECTION_LEG_LEFT
			if(thermal_protection_flags & LEG_RIGHT)
				thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
			if(thermal_protection_flags & FOOT_LEFT)
				thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
			if(thermal_protection_flags & FOOT_RIGHT)
				thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
			if(thermal_protection_flags & ARM_LEFT)
				thermal_protection += THERMAL_PROTECTION_ARM_LEFT
			if(thermal_protection_flags & ARM_RIGHT)
				thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
			if(thermal_protection_flags & HAND_LEFT)
				thermal_protection += THERMAL_PROTECTION_HAND_LEFT
			if(thermal_protection_flags & HAND_RIGHT)
				thermal_protection += THERMAL_PROTECTION_HAND_RIGHT

		return min(1,thermal_protection)

	/*
	proc/add_fire_protection(var/temp)
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
		if(ears)
			if(ears.protective_temperature > temp)
				fire_prot += (ears.protective_temperature/10)
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

	proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
		if(nodamage)
			return
		//world <<"body_part = [body_part], exposed_temperature = [exposed_temperature], exposed_intensity = [exposed_intensity]"
		var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

		if(exposed_temperature > bodytemperature)
			discomfort *= 4

		if(mutantrace == "plant")
			discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT * 2 //I don't like magic numbers. I'll make mutantraces a datum with vars sometime later. -- Urist
		else
			discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT //Dangercon 2011 - now with less magic numbers!
		//world <<"[discomfort]"

		switch(body_part)
			if(HEAD)
				apply_damage(2.5*discomfort, BURN, "head")
			if(UPPER_TORSO)
				apply_damage(2.5*discomfort, BURN, "chest")
			if(LEGS)
				apply_damage(0.6*discomfort, BURN, "l_leg")
				apply_damage(0.6*discomfort, BURN, "r_leg")
			if(ARMS)
				apply_damage(0.4*discomfort, BURN, "l_arm")
				apply_damage(0.4*discomfort, BURN, "r_arm")
	*/

	proc/get_covered_bodyparts()
		var/covered = 0

		if(head)
			covered |= head.body_parts_covered
		if(wear_suit)
			covered |= wear_suit.body_parts_covered
		if(w_uniform)
			covered |= w_uniform.body_parts_covered
		if(shoes)
			covered |= shoes.body_parts_covered
		if(gloves)
			covered |= gloves.body_parts_covered
		if(wear_mask)
			covered |= wear_mask.body_parts_covered

		return covered

	proc/handle_chemicals_in_body()
		if(reagents)

			var/alien = 0 //Not the best way to handle it, but neater than checking this for every single reagent proc.
			if(species && species.name == "Diona")
				alien = 1
			else if(species && species.name == "Vox")
				alien = 2
			reagents.metabolize(src,alien)

		var/total_plasmaloss = 0
		for(var/obj/item/I in src)
			if(I.contaminated)
				total_plasmaloss += zas_settings.Get(/datum/ZAS_Setting/CONTAMINATION_LOSS)
			I.OnMobLife(src)
		if(status_flags & GODMODE)	return 0	//godmode
		adjustToxLoss(total_plasmaloss)

		if(species.flags & REQUIRE_LIGHT)
			var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
			if(isturf(loc)) //else, there's considered to be no light
				var/turf/T = loc
				var/area/A = T.loc
				if(A)
					if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5 //hardcapped so it's not abused by having a ton of flashlights
					else						light_amount =  5
			nutrition += light_amount
			traumatic_shock -= light_amount

			if(species.flags & IS_PLANT)
				if(nutrition > 500)
					nutrition = 500
				if(light_amount >= 3) //if there's enough light, heal
					adjustBruteLoss(-(light_amount))
					adjustToxLoss(-(light_amount))
					adjustOxyLoss(-(light_amount))
					//TODO: heal wounds, heal broken limbs.

		if(dna && dna.mutantrace == "shadow")
			var/light_amount = 0
			if(isturf(loc))
				var/turf/T = loc
				var/area/A = T.loc
				if(A)
					if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
					else						light_amount =  10
			if(light_amount > 2) //if there's enough light, start dying
				take_overall_damage(1,1)
			else if (light_amount < 2) //heal in the dark
				heal_overall_damage(1,1)

		//The fucking M_FAT mutation is the greatest shit ever. It makes everyone so hot and bothered.
		if(species.flags & CAN_BE_FAT)
			if(M_FAT in mutations)
				if(overeatduration < 100)
					src << "\blue You feel fit again!"
					mutations.Remove(M_FAT)
					update_mutantrace(0)
					update_mutations(0)
					update_inv_w_uniform(0)
					update_inv_wear_suit()
			else
				if(overeatduration > 500)
					src << "\red You suddenly feel blubbery!"
					mutations.Add(M_FAT)
					update_mutantrace(0)
					update_mutations(0)
					update_inv_w_uniform(0)
					update_inv_wear_suit()

		// nutrition decrease
		if (nutrition > 0 && stat != 2)
			nutrition = max (0, nutrition - HUNGER_FACTOR)

		if (nutrition > 450)
			if(overeatduration < 600) //capped so people don't take forever to unfat
				overeatduration++
		else
			if(overeatduration > 1)
				if(M_OBESITY in mutations)
					overeatduration -= 1 // Those with obesity gene take twice as long to unfat
				else
					overeatduration -= 2

		if(species.flags & REQUIRE_LIGHT)
			if(nutrition < 200)
				take_overall_damage(2,0)
				traumatic_shock++

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

		handle_trace_chems()

		var/datum/organ/internal/liver/liver = internal_organs_by_name["liver"]
		if(liver) liver.process()

		var/datum/organ/internal/eyes/eyes = internal_organs_by_name["eyes"]
		if(eyes) eyes.process()

		updatehealth()

		return //TODO: DEFERRED


	proc/handle_regular_status_updates()
		if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
			blinded = 1
			silent = 0
		else				//ALIVE. LIGHTS ARE ON

			// Sobering multiplier.
			// Sober block grants quadruple the alcohol metabolism.
			var/sober_str=!(M_SOBER in mutations)?1:4

			updatehealth()	//TODO
			if(!in_stasis)
				handle_organs()	//Optimized.
				handle_blood()

			if(health <= config.health_threshold_dead || !has_brain())
				death()
				blinded = 1
				silent = 0
				return 1

			// the analgesic effect wears off slowly
			analgesic = max(0, analgesic - 1)

			//UNCONSCIOUS. NO-ONE IS HOME
			if( (getOxyLoss() > 50) || (config.health_threshold_crit > health) )
				Paralyse(3)

				/* Done by handle_breath()
				if( health <= 20 && prob(1) )
					spawn(0)
						emote("gasp")
				if(!reagents.has_reagent("inaprovaline"))
					adjustOxyLoss(1)*/

			if(hallucination)
				if(hallucination >= 20)
					if(prob(3))
						fake_attack(src)
					if(!handling_hal)
						spawn handle_hallucinations() //The not boring kind!

				if(hallucination<=2)
					hallucination = 0
					halloss = 0
				else
					hallucination -= 2

			else
				for(var/atom/a in hallucinations)
					del a

				if(halloss > 100)
					src << "<span class='notice'>You're in too much pain to keep going...</span>"
					for(var/mob/O in oviewers(src, null))
						O.show_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
					Paralyse(10)
					setHalLoss(99)

			if(paralysis)
				AdjustParalysis(-1)
				blinded = 1
				stat = UNCONSCIOUS
				if(halloss > 0)
					adjustHalLoss(-3)
			else if(sleeping)
				handle_dreams()
				adjustHalLoss(-3)
				if (mind)
					if((mind.active && client != null) || immune_to_ssd) //This also checks whether a client is connected, if not, sleep is not reduced.
						sleeping = max(sleeping-1, 0)
				blinded = 1
				stat = UNCONSCIOUS
				if( prob(2) && health && !hal_crit )
					spawn(0)
						emote("snore")
				if(mind)
					if(mind.vampire)
						if(istype(loc, /obj/structure/closet/coffin))
							adjustBruteLoss(-1)
							adjustFireLoss(-1)
							adjustToxLoss(-1)
			else if(resting)
				if(halloss > 0)
					adjustHalLoss(-3)
			//CONSCIOUS
			else
				stat = CONSCIOUS
				if(halloss > 0)
					adjustHalLoss(-1)

			//Eyes
			if(!species.has_organ["eyes"]) // Presumably if a species has no eyes, they see via something else.
				eye_blind =  0
				blinded =    0
				eye_blurry = 0
			else if(!has_eyes())           // Eyes cut out? Permablind.
				eye_blind =  1
				blinded =    1
				eye_blurry = 1
			else if(sdisabilities & BLIND) // Disabled-blind, doesn't get better on its own
				blinded =    1
			else if(eye_blind)		       // Blindness, heals slowly over time
				eye_blind =  max(eye_blind-1,0)
				blinded =    1
			else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold))	//resting your eyes with a blindfold heals blurry eyes faster
				eye_blurry = max(eye_blurry-3, 0)
				blinded =    1
			else if(eye_blurry)	           // Blurry eyes heal slowly
				eye_blurry = max(eye_blurry-1, 0)

			//Ears
			if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
				ear_deaf = max(ear_deaf, 1)
			else if(ear_deaf)			//deafness, heals slowly over time
				ear_deaf = max(ear_deaf-1, 0)
			else if(is_on_ears(/obj/item/clothing/ears/earmuffs))	//resting your ears with earmuffs heals ear damage faster
				ear_damage = max(ear_damage-0.15, 0)
				ear_deaf = max(ear_deaf, 1)
			else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
				ear_damage = max(ear_damage-0.05, 0)

			//Other
			if(stunned)
				AdjustStunned(-1)

			if(weakened)
				weakened = max(weakened-1,0)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times

			if(stuttering)
				stuttering = max(stuttering-1, 0)
			if (src.slurring)
				slurring = max(slurring-(1*sober_str), 0)
			if(silent)
				silent = max(silent-1, 0)

			if(druggy)
				druggy = max(druggy-1, 0)
/*
			// Increase germ_level regularly
			if(prob(40))
				germ_level += 1
			// If you're dirty, your gloves will become dirty, too.
			if(gloves && germ_level > gloves.germ_level && prob(10))
				gloves.germ_level += 1
*/
		return 1

	proc/handle_regular_hud_updates()
		if(!client)	return 0

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
						damageoverlay.overlays += unconscious_overlays["1"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage1")
					if(-30 to -20)
						damageoverlay.overlays +=  unconscious_overlays["2"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage2")
					if(-40 to -30)
						damageoverlay.overlays +=  unconscious_overlays["3"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage3")
					if(-50 to -40)
						damageoverlay.overlays +=  unconscious_overlays["4"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage4")
					if(-60 to -50)
						damageoverlay.overlays +=  unconscious_overlays["5"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage5")
					if(-70 to -60)
						damageoverlay.overlays +=  unconscious_overlays["6"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage6")
					if(-80 to -70)
						damageoverlay.overlays +=  unconscious_overlays["7"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage7")
					if(-90 to -80)
						damageoverlay.overlays +=  unconscious_overlays["8"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage8")
					if(-95 to -90)
						damageoverlay.overlays +=  unconscious_overlays["9"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage9")
					if(-INFINITY to -95)
						damageoverlay.overlays +=  unconscious_overlays["10"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage10")
				//damageoverlay.overlays += I
		else
			//Oxygen damage overlay
			if(oxyloss)
				//var/image/I
				switch(oxyloss)
					if(10 to 20)
						damageoverlay.overlays += oxyloss_overlays["1"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay1")
					if(20 to 25)
						damageoverlay.overlays += oxyloss_overlays["2"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay2")
					if(25 to 30)
						damageoverlay.overlays += oxyloss_overlays["3"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay3")
					if(30 to 35)
						damageoverlay.overlays += oxyloss_overlays["4"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay4")
					if(35 to 40)
						damageoverlay.overlays += oxyloss_overlays["5"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay5")
					if(40 to 45)
						damageoverlay.overlays += oxyloss_overlays["6"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay6")
					if(45 to INFINITY)
						damageoverlay.overlays += oxyloss_overlays["7"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay7")
				//damageoverlay.overlays += I

			//Fire and Brute damage overlay (BSSR)
			var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
			damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
			if(hurtdamage)
				//var/image/I
				switch(hurtdamage)
					if(10 to 25)
						damageoverlay.overlays += brutefireloss_overlays["1"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay1")
					if(25 to 40)
						damageoverlay.overlays += brutefireloss_overlays["2"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay2")
					if(40 to 55)
						damageoverlay.overlays += brutefireloss_overlays["3"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay3")
					if(55 to 70)
						damageoverlay.overlays += brutefireloss_overlays["4"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay4")
					if(70 to 85)
						damageoverlay.overlays += brutefireloss_overlays["5"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay5")
					if(85 to INFINITY)
						damageoverlay.overlays += brutefireloss_overlays["6"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay6")
				//damageoverlay.overlays += I
		if( stat == DEAD )
			sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
			see_in_dark = 8
			if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO
			if(healths)		healths.icon_state = "health7"	//DEAD healthmeter
		else
			sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
			see_in_dark = species.darksight
			see_invisible = see_in_dark>2 ? SEE_INVISIBLE_LEVEL_ONE : SEE_INVISIBLE_LIVING
			if(dna)
				switch(dna.mutantrace)
					if("slime")
						see_in_dark = 3
						see_invisible = SEE_INVISIBLE_LEVEL_ONE
					if("shadow")
						see_in_dark = 8
						see_invisible = SEE_INVISIBLE_LEVEL_ONE
			if(mind && mind.vampire)
				if((VAMP_VISION in mind.vampire.powers) && !(VAMP_FULL in mind.vampire.powers))
					sight |= SEE_MOBS
				if((VAMP_FULL in mind.vampire.powers))
					sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
					see_in_dark = 8
					if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO
			if(M_XRAY in mutations)
				sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
				see_in_dark = 8
				if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO

			if(seer==1)
				var/obj/effect/rune/R = locate() in loc
				if(R && R.word1 == cultwords["see"] && R.word2 == cultwords["hell"] && R.word3 == cultwords["join"])
					see_invisible = SEE_INVISIBLE_OBSERVER
				else
					see_invisible = SEE_INVISIBLE_LIVING
					seer = 0

			if(istype(wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja))
				var/obj/item/clothing/mask/gas/voice/space_ninja/O = wear_mask
				switch(O.mode)
					if(0)
						var/target_list[] = list()
						for(var/mob/living/target in oview(src))
							if( target.mind&&(target.mind.special_role||issilicon(target)) )//They need to have a mind.
								target_list += target
						if(target_list.len)//Everything else is handled by the ninja mask proc.
							O.assess_targets(target_list, src)
						if(!druggy)		see_invisible = SEE_INVISIBLE_LIVING
					if(1)
						see_in_dark = 5
						if(!druggy)		see_invisible = SEE_INVISIBLE_LIVING
					if(2)
						sight |= SEE_MOBS
						if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO
					if(3)
						sight |= SEE_TURFS
						if(!druggy)		see_invisible = SEE_INVISIBLE_LIVING

			if(glasses)
				var/obj/item/clothing/glasses/G = glasses
				if(istype(G))
					see_in_dark += G.darkness_view
					if(G.vision_flags)		// MESONS
						sight |= G.vision_flags
						if(!druggy)
							see_invisible = SEE_INVISIBLE_MINIMUM

	/* HUD shit goes here, as long as it doesn't modify sight flags */
	// The purpose of this is to stop xray and w/e from preventing you from using huds -- Love, Doohl

				if(istype(glasses, /obj/item/clothing/glasses/sunglasses/sechud))
					var/obj/item/clothing/glasses/sunglasses/sechud/O = glasses
					if(O.hud)		O.hud.process_hud(src)
					if(!druggy)		see_invisible = SEE_INVISIBLE_LIVING
				else if(istype(glasses, /obj/item/clothing/glasses/hud))
					var/obj/item/clothing/glasses/hud/O = glasses
					O.process_hud(src)
					if(!druggy)
						see_invisible = SEE_INVISIBLE_LIVING

			else if(!seer)
				see_invisible = SEE_INVISIBLE_LIVING

			if(healths)
				healths.overlays.Cut()
				if (analgesic)
					healths.icon_state = "health_health_numb"
				else
					var/ruptured = is_lung_ruptured()
					if(hal_screwyhud)
						for(var/i = 1; i <=3 ;i++)
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
										testing("[e.name] adding max overlay")
										healths.overlays.Add(organ_damage_overlays["[e.name]_max"])
									if(15 to 30)
										testing("[e.name] adding mid overlay")
										healths.overlays.Add(organ_damage_overlays["[e.name]_mid"])
									if(5 to 15)
										testing("[e.name] adding min overlay")
										healths.overlays.Add(organ_damage_overlays["[e.name]_min"])
					switch(hal_screwyhud)
						if(1)	healths.icon_state = "health6"
						if(2)	healths.icon_state = "health7"
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
//			if(rest)	//Not used with new UI
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
				if(blinded)		blind.layer = 18
				else			blind.layer = 0

			if(disabilities & NEARSIGHTED)	//this looks meh but saves a lot of memory by not requiring to add var/prescription
				if(glasses)					//to every /obj/item
					var/obj/item/clothing/glasses/G = glasses
					if(!G.prescription)
						client.screen += global_hud.vimpaired
				else
					client.screen += global_hud.vimpaired

			if(eye_blurry)			client.screen += global_hud.blurry
			if(druggy)				client.screen += global_hud.druggy

			var/masked = 0

			if( istype(head, /obj/item/clothing/head/welding) || istype(head, /obj/item/clothing/head/helmet/space/unathi))
				var/obj/item/clothing/head/welding/O = head
				if(!O.up && tinted_weldhelh)
					client.screen += global_hud.darkMask
					masked = 1

			if(!masked && istype(glasses, /obj/item/clothing/glasses/welding) && !istype(glasses, /obj/item/clothing/glasses/welding/superior))
				var/obj/item/clothing/glasses/welding/O = glasses
				if(!O.up && tinted_weldhelh)
					client.screen += global_hud.darkMask

			if(machine)
				if(!machine.check_eye(src))		reset_view(null)
			else
				var/isRemoteObserve = 0
				if((M_REMOTE_VIEW in mutations) && remoteview_target)
					isRemoteObserve = 1
					// Is he unconscious or dead?
					if(remoteview_target.stat!=CONSCIOUS)
						src << "\red Your psy-connection grows too faint to maintain!"
						isRemoteObserve = 0

					// Does he have psy resist?
					if(M_PSY_RESIST in remoteview_target.mutations)
						src << "\red Your mind is shut out!"
						isRemoteObserve = 0

					// Not on the station or mining?
					var/turf/temp_turf = get_turf(remoteview_target)
					if((temp_turf.z != 1 && temp_turf.z != 5) || remoteview_target.stat!=CONSCIOUS)
						src << "\red Your psy-connection grows too faint to maintain!"
						isRemoteObserve = 0
				if(!isRemoteObserve && client && !client.adminobs)
					remoteview_target = null
					reset_view(null)
		return 1

	proc/handle_random_events()
		// Puke if toxloss is too high
		if(!stat)
			if (getToxLoss() >= 45 && nutrition > 20)
				vomit()

			// No hair for radroaches
			if(src.radiation >= 50)
				src.h_style = "Bald"
				src.f_style = "Shaved"
				src.update_hair()

		//0.1% chance of playing a scary sound to someone who's in complete darkness
		if(isturf(loc) && rand(1,1000) == 1)
			var/turf/currentTurf = loc
			if(!currentTurf.lighting_lumcount)
				playsound_local(src,pick(scarySounds),50, 1, -1)

	// Separate proc so we can jump out of it when we've succeeded in spreading disease.
	proc/findAirborneVirii()
		if(blood_virus_spreading_disabled)
			return 0
		for(var/obj/effect/decal/cleanable/blood/B in get_turf(src))
			if(B.virus2.len)
				for (var/ID in B.virus2)
					var/datum/disease2/disease/V = B.virus2[ID]
					if (infect_virus2(src,V, notes="(Airborne from blood)"))
						return 1

		for(var/obj/effect/decal/cleanable/mucus/M in get_turf(src))
			if(M.virus2.len)
				for (var/ID in M.virus2)
					var/datum/disease2/disease/V = M.virus2[ID]
					if (infect_virus2(src,V, notes="(Airborne from mucus)"))
						return 1
		return 0
	proc/handle_virus_updates()
		if(status_flags & GODMODE)	return 0	//godmode
		if(bodytemperature > 406)
			for(var/datum/disease/D in viruses)
				D.cure()
			for (var/ID in virus2)
				var/datum/disease2/disease/V = virus2[ID]
				V.cure(src)

		src.findAirborneVirii()

		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(isnull(V)) // Trying to figure out a runtime error that keeps repeating
				CRASH("virus2 nulled before calling activate()")
			else
				V.activate(src)
			// activate may have deleted the virus
			if(!V) continue

			// check if we're immune
			if(V.antigen & src.antibodies)
				V.dead = 1

		return

	proc/handle_stomach()
		spawn(0)
			for(var/mob/living/M in stomach_contents)
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
						if(!(M.status_flags & GODMODE))
							M.adjustBruteLoss(5)
						nutrition += 10

	proc/handle_changeling()
		if(mind && mind.changeling)
			mind.changeling.regenerate()

	handle_shock()
		..()
		if(status_flags & GODMODE)	return 0	//godmode
		if(analgesic || (species && species.flags & NO_PAIN)) return // analgesic avoids all traumatic shock temporarily

		if(health < config.health_threshold_softcrit)// health 0 makes you immediately collapse
			shock_stage = max(shock_stage, 61)

		if(traumatic_shock >= 80)
			shock_stage += 1
		else if(health < config.health_threshold_softcrit)
			shock_stage = max(shock_stage, 61)
		else
			shock_stage = min(shock_stage, 160)
			shock_stage = max(shock_stage-1, 0)
			return

		if(shock_stage == 10)
			src << "<font color='red'><b>"+pick("It hurts so much!", "You really need some painkillers..", "Dear god, the pain!")

		if(shock_stage >= 30)
			if(shock_stage == 30) emote("me",1,"is having trouble keeping their eyes open.")
			eye_blurry = max(2, eye_blurry)
			stuttering = max(stuttering, 5)

		if(shock_stage == 40)
			src << "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")

		if (shock_stage >= 60)
			if(shock_stage == 60) emote("me",1,"'s body becomes limp.")
			if (prob(2))
				src << "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")
				Weaken(20)

		if(shock_stage >= 80)
			if (prob(5))
				src << "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")
				Weaken(20)

		if(shock_stage >= 120)
			if (prob(2))
				src << "<font color='red'><b>"+pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness.")
				Paralyse(5)

		if(shock_stage == 150)
			emote("me",1,"can no longer stand, collapsing!")
			Weaken(20)

		if(shock_stage >= 150)
			Weaken(20)

	proc/handle_pulse()

		if(life_tick % 5) return pulse	//update pulse every 5 life ticks (~1 tick/sec, depending on server load)

		if(species && species.flags & NO_BLOOD) return PULSE_NONE //No blood, no pulse.

		if(stat == DEAD)
			return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

		var/temp = PULSE_NORM

		if(round(vessel.get_reagent_amount("blood")) <= BLOOD_VOLUME_BAD)	//how much blood do we have
			temp = PULSE_THREADY	//not enough :(

		if(status_flags & FAKEDEATH)
			temp = PULSE_NONE		//pretend that we're dead. unlike actual death, can be inflienced by meds

		//handles different chems' influence on pulse
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id in bradycardics)
				if(temp <= PULSE_THREADY && temp >= PULSE_NORM)
					temp--

			if(R.id in tachycardics)
				if(temp <= PULSE_FAST && temp >= PULSE_NONE)
					temp++

			if(R.id in heartstopper) //To avoid using fakedeath
				temp = PULSE_NONE

			if(R.id in cheartstopper)  //Conditional heart-stoppage
				if(R.volume >= R.overdose)
					temp = PULSE_NONE

		return temp

/mob/living/carbon/human/proc/randorgan()
	var/randorgan = pick("head","chest","l_arm","r_arm","l_hand","r_hand","groin","l_leg","r_leg","l_foot","r_foot")
	//var/randorgan = pick("head","chest","groin")
	return randorgan









/*
	Called by life(), instead of having the individual hud items update icons each tick and check for status changes
	we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.
	This proc below is only called when those HUD elements need to change as determined by the mobs hud_updateflag.
*/


/mob/living/carbon/human/proc/handle_hud_list()

	if(hud_updateflag & 1 << HEALTH_HUD)
		var/image/holder = hud_list[HEALTH_HUD]
		if(stat == 2)
			holder.icon_state = "hudhealth-100" 	// X_X
		else
			holder.icon_state = "hud[RoundHealth(health)]"

		hud_list[HEALTH_HUD] = holder

	if(hud_updateflag & 1 << STATUS_HUD)
		var/foundVirus = 0
		for(var/datum/disease/D in viruses)
			if(!D.hidden[SCANNER])
				foundVirus++
		for (var/ID in virus2)
			if (ID in virusDB)
				foundVirus = 1
				break

		var/image/holder = hud_list[STATUS_HUD]
		var/image/holder2 = hud_list[STATUS_HUD_OOC]
		if(stat == 2)
			holder.icon_state = "huddead"
			holder2.icon_state = "huddead"
		else if(status_flags & XENO_HOST)
			holder.icon_state = "hudxeno"
			holder2.icon_state = "hudxeno"
		else if(foundVirus)
			holder.icon_state = "hudill"
		else if(has_brain_worms())
			var/mob/living/simple_animal/borer/B = has_brain_worms()
			if(B.controlling)
				holder.icon_state = "hudbrainworm"
			else
				holder.icon_state = "hudhealthy"
			holder2.icon_state = "hudbrainworm"
		else
			holder.icon_state = "hudhealthy"
			if(virus2.len)
				holder2.icon_state = "hudill"
			else
				holder2.icon_state = "hudhealthy"

		hud_list[STATUS_HUD] = holder
		hud_list[STATUS_HUD_OOC] = holder2

	if(hud_updateflag & 1 << ID_HUD)
		var/image/holder = hud_list[ID_HUD]
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				holder.icon_state = "hud[ckey(I.GetJobName())]"
			else
				holder.icon_state = "hudunknown"
		else
			holder.icon_state = "hudunknown"


		hud_list[ID_HUD] = holder

	if(hud_updateflag & 1 << WANTED_HUD)
		var/image/holder = hud_list[WANTED_HUD]
		holder.icon_state = "hudblank"
		var/perpname = name
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				perpname = I.registered_name

		for(var/datum/data/record/E in data_core.general)
			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						holder.icon_state = "hudwanted"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
						holder.icon_state = "hudprisoner"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Parolled"))
						holder.icon_state = "hudparolled"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
						holder.icon_state = "hudreleased"
						break
		hud_list[WANTED_HUD] = holder

	if(hud_updateflag & 1 << IMPLOYAL_HUD || hud_updateflag & 1 << IMPCHEM_HUD || hud_updateflag & 1 << IMPTRACK_HUD)
		var/image/holder1 = hud_list[IMPTRACK_HUD]
		var/image/holder2 = hud_list[IMPLOYAL_HUD]
		var/image/holder3 = hud_list[IMPCHEM_HUD]

		holder1.icon_state = "hudblank"
		holder2.icon_state = "hudblank"
		holder3.icon_state = "hudblank"

		for(var/obj/item/weapon/implant/I in src)
			if(I.implanted)
				if(istype(I,/obj/item/weapon/implant/tracking))
					holder1.icon_state = "hud_imp_tracking"
				if(istype(I,/obj/item/weapon/implant/loyalty))
					holder2.icon_state = "hud_imp_loyal"
				if(istype(I,/obj/item/weapon/implant/chem))
					holder3.icon_state = "hud_imp_chem"

		hud_list[IMPTRACK_HUD] = holder1
		hud_list[IMPLOYAL_HUD] = holder2
		hud_list[IMPCHEM_HUD] = holder3

	if(hud_updateflag & 1 << SPECIALROLE_HUD)
		var/image/holder = hud_list[SPECIALROLE_HUD]
		holder.icon_state = "hudblank"
		if(mind)

			switch(mind.special_role)
				if("traitor","Syndicate")
					holder.icon_state = "hudsyndicate"
				if("Revolutionary")
					holder.icon_state = "hudrevolutionary"
				if("Head Revolutionary")
					holder.icon_state = "hudheadrevolutionary"
				if("Cultist")
					holder.icon_state = "hudcultist"
				if("Changeling")
					holder.icon_state = "hudchangeling"
				if("Wizard","Fake Wizard")
					holder.icon_state = "hudwizard"
				if("Death Commando")
					holder.icon_state = "huddeathsquad"
				if("Ninja")
					holder.icon_state = "hudninja"
				if("Vampire") // TODO: Check this
					holder.icon_state = "hudvampire"

			hud_list[SPECIALROLE_HUD] = holder
	hud_updateflag = 0

// Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
