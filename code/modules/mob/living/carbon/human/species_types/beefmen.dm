// GLOBAL_LIST_INIT(color_list_beefman, list("Very Rare" = "c62461", "Rare" = "c91745", "Medium Rare" = "e73f4e", "Medium" = "fd7f8b", "Medium Well" = "e7a5ab", "Well Done" = "b9a6a8" ))
	//message_admins("DEBUG3")

#define isbeefman(A) (is_species(A,/datum/species/beefman))


// TO DO:
//
// Death Sound
//
/datum/species/
	var/bruising_desc = "bruising"
	var/burns_desc = "burns"
	var/cellulardamage_desc = "cellular damage"

/datum/species/beefman
	name = "Beefman"
	id = "beefman"
	say_mod = "gurgles"
	sexes = FALSE
	default_color = "e73f4e"
	species_traits = list( NOEYESPRITES, NO_UNDERWEAR, DYNCOLORS, AGENDER, EYECOLOR) // EYECOLOR
	mutant_bodyparts = list("beefmouth", "beefeyes")
	inherent_traits = list(TRAIT_RESISTCOLD, TRAIT_EASYDISMEMBER, TRAIT_COLDBLOODED, TRAIT_SLEEPIMMUNE ) // , TRAIT_LIMBATTACHMENT)
	default_features = list("beefcolor" = "e73f4e","beefmouth" = "Smile 1", "beefeyes" = "Olives")
	offset_features = list(OFFSET_UNIFORM = list(0,2), OFFSET_ID = list(0,2), OFFSET_GLOVES = list(0,-4), OFFSET_GLASSES = list(0,3), OFFSET_EARS = list(0,3), OFFSET_SHOES = list(0,0), \
						   OFFSET_S_STORE = list(0,2), OFFSET_FACEMASK = list(0,3), OFFSET_HEAD = list(0,3), OFFSET_FACE = list(0,3), OFFSET_BELT = list(0,3), OFFSET_BACK = list(0,2), \
						   OFFSET_SUIT = list(0,2), OFFSET_NECK = list(0,3))

	skinned_type = /obj/item/reagent_containers/food/snacks/meatball // NO SKIN //  /obj/item/stack/sheet/animalhide/human
	meat = /obj/item/reagent_containers/food/snacks/meat/slab //What the species drops on gibbing
	toxic_food = DAIRY | PINEAPPLE //NONE
	disliked_food = VEGETABLES | FRUIT // | FRIED// GROSS | RAW
	liked_food = RAW | MEAT // JUNKFOOD | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	attack_verb = "meat"
	speedmod = -0.2	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	armor = -2		// overall defense for the race... or less defense, if it's negative.
	punchdamagelow = 1       //lowest possible punch damage. if this is set to 0, punches will always miss
	punchdamagehigh = 5 // 10      //highest possible punch damage
	siemens_coeff = 0.7 // Due to lack of density.   //base electrocution coefficient
	inert_mutation = MUTATE // in DNA.dm
	deathsound = 'sound/Fulpsounds/beef_die.ogg'
	attack_sound = 'sound/Fulpsounds/beef_hit.ogg'
	special_step_sounds = list('sound/Fulpsounds/footstep_splat1.ogg','sound/Fulpsounds/footstep_splat2.ogg','sound/Fulpsounds/footstep_splat3.ogg','sound/Fulpsounds/footstep_splat4.ogg')//Sounds to override barefeet walkng
	grab_sound = 'sound/Fulpsounds/beef_grab.ogg'//Special sound for grabbing

	var/dehydrate = 0
	    // list( /datum/brain_trauma/mild/phobia/strangers, /datum/brain_trauma/mild/phobia/doctors, /datum/brain_trauma/mild/phobia/authority )

	// Take care of your meat, everybody
	bruising_desc = "tenderizing"
	burns_desc = "searing"
	cellulardamage_desc = "meat degradation"


/proc/proof_beefman_features(var/list/inFeatures)
	// Missing Defaults in DNA? Randomize!
	if (inFeatures["beefcolor"] == null || inFeatures["beefcolor"] == "")
		inFeatures["beefcolor"] = GLOB.color_list_beefman[pick(GLOB.color_list_beefman)]
	if (inFeatures["beefeyes"] == null || inFeatures["beefeyes"] == "")
		inFeatures["beefeyes"] = pick(GLOB.eyes_beefman)
	if (inFeatures["beefmouth"] == null || inFeatures["beefmouth"] == "")
		inFeatures["beefmouth"] = pick(GLOB.mouths_beefman)

/datum/species/beefman/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)


	// Missing Defaults in DNA? Randomize!
	proof_beefman_features(C.dna.features)

	.=..()

	if(ishuman(C)) // Taken DIRECTLY from ethereal!
		var/mob/living/carbon/human/H = C

		set_beef_color(H)

		// 2) BODYPARTS
		C.part_default_head = /obj/item/bodypart/head/beef
		C.part_default_chest = /obj/item/bodypart/chest/beef
		C.part_default_l_arm = /obj/item/bodypart/l_arm/beef
		C.part_default_r_arm = /obj/item/bodypart/r_arm/beef
		C.part_default_l_leg = /obj/item/bodypart/l_leg/beef
		C.part_default_r_leg = /obj/item/bodypart/r_leg/beef
		C.ReassignForeignBodyparts()


	// Speak Russian
	C.grant_language(/datum/language/russian) // Don't remove on loss. You simply know it.

	// Be Spooked but Educated
	//C.gain_trauma(pick(startTraumas))
	if (SStraumas.phobia_types && SStraumas.phobia_types.len) // NOTE: ONLY if phobias have been defined! For some reason, sometimes this gets FUCKED??
		C.gain_trauma(/datum/brain_trauma/mild/phobia/strangers)
		C.gain_trauma(/datum/brain_trauma/mild/hallucinations)
		C.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor)

/datum/species/proc/set_beef_color(mob/living/carbon/human/H)
	return // Do Nothing
/datum/species/beefman/set_beef_color(mob/living/carbon/human/H)
	// Called on Assign, or on Color Change (or any time proof_beefman_features() is used, such as in bs_veil.dm)
	fixed_mut_color = H.dna.features["beefcolor"]
	default_color = fixed_mut_color



/mob/living/carbon/proc/ReassignForeignBodyparts() //This proc hurts me so much, it used to be worse, this really should be a list or something
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	if (head?.type != part_default_head)  // <----- I think :? is used for procs instead of .? ...but apparently BYOND does that swap for you. //(!istype(get_bodypart(BODY_ZONE_HEAD), part_default_head))
		qdel(head)
		var/obj/item/bodypart/limb = new part_default_head
		limb.replace_limb(src,TRUE)
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if (chest?.type != part_default_chest)
		qdel(chest)
		var/obj/item/bodypart/limb = new part_default_chest
		limb.replace_limb(src,TRUE)
	var/obj/item/bodypart/l_arm = get_bodypart(BODY_ZONE_L_ARM)
	if (l_arm?.type != part_default_l_arm)
		qdel(l_arm)
		var/obj/item/bodypart/limb = new part_default_l_arm
		limb.replace_limb(src,TRUE)
	var/obj/item/bodypart/r_arm = get_bodypart(BODY_ZONE_R_ARM)
	if (r_arm?.type != part_default_r_arm)
		qdel(r_arm)
		var/obj/item/bodypart/limb = new part_default_r_arm
		limb.replace_limb(src,TRUE)
	var/obj/item/bodypart/l_leg = get_bodypart(BODY_ZONE_L_LEG)
	if (l_leg?.type != part_default_l_leg)
		qdel(l_leg)
		var/obj/item/bodypart/limb = new part_default_l_leg
		limb.replace_limb(src,TRUE)
	var/obj/item/bodypart/r_leg = get_bodypart(BODY_ZONE_R_LEG)
	if (r_leg?.type != part_default_r_leg)
		qdel(r_leg)
		var/obj/item/bodypart/limb = new part_default_r_leg
		limb.replace_limb(src,TRUE)

/datum/species/beefman/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	..()

	// 2) BODYPARTS
	C.part_default_head = /obj/item/bodypart/head
	C.part_default_chest = /obj/item/bodypart/chest
	C.part_default_l_arm = /obj/item/bodypart/l_arm
	C.part_default_r_arm = /obj/item/bodypart/r_arm
	C.part_default_l_leg = /obj/item/bodypart/l_leg
	C.part_default_r_leg = /obj/item/bodypart/r_leg
	C.ReassignForeignBodyparts()

	// Resolve Trauma
	C.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor)
	C.cure_trauma_type(/datum/brain_trauma/mild/phobia/strangers)
	C.cure_trauma_type(/datum/brain_trauma/mild/hallucinations)



/datum/species/beefman/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_beefman_name(gender)
	return capitalize(beefman_name(gender))


///datum/species/beefman/spec_life(mob/living/carbon/human/H)	// This is your life ticker.
	//..()
	// 		** BLEED YOUR JUICES **         // BODYTEMP_NORMAL = 310.15    // AC set to 293

	// Step 1) Being burned keeps the juices in.
	//var/searJuices = H.getFireLoss_nonProsthetic() / 10

	// Step 2) Bleed out those juices by warmth, minus burn damage.
	//--H.bleed_rate = clamp((H.bodytemperature - 285) / 20 - searJuices, 0, 5) // Every 20 points above 285 increases bleed rate. Don't worry, you're cold blooded.	DEAD CODE MUST REWORK

	// Step 3) If we're salted, we'll bleed more (it gets reset next tick)
	/*if (dehydrate > 0)			DEAD CODE MUST REWORK TO FIT WOUNDS PR SOMEHOW
		H.bleed_rate += 2
		dehydrate -= 0.5

	// Replenish Blood Faster! (But only if you actually make blood)
	if (dehydrate <= 0 && H.bleed_rate <= 0 && H.blood_volume < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(H, TRAIT_NOMARROW))
		H.blood_volume += 2*/

// TO-DO // Drop lots of meat on gib?
/datum/species/beefman/spec_death(gibbed, mob/living/carbon/human/H)
	return ..()

/datum/species/beefman/before_equip_job(datum/job/J, mob/living/carbon/human/H)

	// Pre-Equip: Give us a sash so we don't end up with a Uniform!

	var/obj/item/clothing/under/bodysash/newSash
	switch(J.title)
		// Assistant
		if("Assistant")
			newSash = new /obj/item/clothing/under/bodysash()
		// Security
		if("Security Officer", "Warden", "Detective", "Head of Security", "Deputy")
			newSash = new /obj/item/clothing/under/bodysash/security()
		// Medical
		if("Medical Doctor", "Chemist", "Geneticist", "Virologist", "Chief Medical Officer", "Paramedic")
			newSash = new /obj/item/clothing/under/bodysash/medical()
		// Science
		if("Scientist", "Roboticist", "Research Director")
			newSash = new /obj/item/clothing/under/bodysash/science()
		// Cargo
		if("Cargo Technician", "Quartermaster", "Shaft Miner")
			newSash = new /obj/item/clothing/under/bodysash/cargo()
		// Engineer
		if("Station Engineer", "Atmospheric Technician", "Chief Engineer")
			newSash = new /obj/item/clothing/under/bodysash/engineer()
		// Command
		if("Captain", "Head of Personnel")
			newSash = new /obj/item/clothing/under/bodysash/command()
		// Clown
		if("Clown")
			newSash = new /obj/item/clothing/under/bodysash/clown()
		// Mime
		if("Mime")
			newSash = new /obj/item/clothing/under/bodysash/mime()
		// Civilian
		else
			newSash = new /obj/item/clothing/under/bodysash/civilian()
	// Destroy Original Uniform (there probably isn't one though)
	if (H.w_uniform)
		qdel(H.w_uniform)
	// Equip New
	H.equip_to_slot_or_del(newSash, ITEM_SLOT_ICLOTHING, TRUE) // TRUE is whether or not this is "INITIAL", as in startup
	return ..()

/datum/species/beefman/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	..() //  H.update_mutant_bodyparts()   <--- SWAIN NOTE base does that only

	// DO NOT DO THESE DURING GAIN/LOSS (we only want to assign them once on round start)

	// 		JOB GEAR

	// Remove coat! We don't wear that as a Beefboi
	if (H.wear_suit)
		qdel(H.wear_suit)


/datum/species/beefman/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..() // Let species run its thing by default, TRUST ME
	// Salt HURTS
	if(chem.type == /datum/reagent/saltpetre || chem.type == /datum/reagent/consumable/sodiumchloride)
		H.adjustToxLoss(0.5, 0) // adjustFireLoss
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		if (prob(5) || dehydrate == 0)
			to_chat(H, "<span class='alert'>Your beefy mouth tastes dry.<span>")
		dehydrate ++
		return TRUE
	// Regain BLOOD
	else if(istype(chem, /datum/reagent/consumable/nutriment) || istype(chem, /datum/reagent/iron))
		if (H.blood_volume < BLOOD_VOLUME_NORMAL)
			H.blood_volume += 2
			H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
			return TRUE

// TO-DO // Weak to salt etc!
/datum/species/beefman/check_species_weakness(obj/item, mob/living/attacker)
	return ..() // 0  //This is not a boolean, it's the multiplier for the damage that the user takes from the item.It is added onto the check_weakness value of the mob, and then the force of the item is multiplied by this value



////////
//LIFE//
////////

/datum/species/beefman/handle_digestion(mob/living/carbon/human/H)
	..()

// TO-DO // Do funny stuff with Radiation
/datum/species/beefman/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = ..()



//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/beefman/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	// Bleed On
	/*if (user != target && user.bleed_rate)	DEAD CODE MUST REWORK TO FIT WOUNDS PR SOMEHOW
		target.add_mob_blood(user)*/
	return ..()

/datum/species/beefman/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	// Bleed On
	/*if (user != target && user.bleed_rate)	DEAD CODE MUST REWORK TO FIT WOUNDS PR SOMEHOW
		target.add_mob_blood(user) //  from atoms.dm, this is how you bloody something!
		*/
	return ..()

/datum/species/beefman/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	// Targeting Self? With "DISARM"
	if (user == target)
		var/target_zone = user.zone_selected
		var/list/allowedList = list ( BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG )
		var/obj/item/bodypart/affecting = user.get_bodypart(check_zone(user.zone_selected)) //stabbing yourself always hits the right target

		if ((target_zone in allowedList) && affecting)

			if (user.handcuffed)
				to_chat(user, "<span class='alert'>You can't get a good enough grip with your hands bound.</span>")
				return FALSE

			// Robot Arms Fail
			if (affecting.status != BODYPART_ORGANIC)
				to_chat(user, "That thing is on there good. It's not coming off with a gentle tug.")
				return FALSE

			// Pry it off...
			user.visible_message("[user] grabs onto [p_their()] own [affecting.name] and pulls.", \
					 	 "<span class='notice'>You grab hold of your [affecting.name] and yank hard.</span>")
			if (!do_mob(user,target))
				return TRUE

			user.visible_message("[user]'s [affecting.name] comes right off in their hand.", "<span class='notice'>Your [affecting.name] pops right off.</span>")
			playsound(get_turf(user), 'sound/Fulpsounds/beef_hit.ogg', 40, 1)

			// Destroy Limb, Drop Meat, Pick Up
			var/obj/item/I = affecting.drop_limb() //  <--- This will return a meat vis drop_meat(), even if only Beefman limbs return anything. If this was another species' limb, it just comes off.
			if (istype(I, /obj/item/reagent_containers/food/snacks/meat/slab))
				user.put_in_hands(I)

			return TRUE
	return ..()

/datum/species/beefman/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	// Bleed On
	/*if (user != target && user.bleed_rate)	DEAD CODE MUST REWORK TO FIT WOUNDS PR SOMEHOW
		target.add_mob_blood(user) //  from atoms.dm, this is how you bloody something!
		*/
	return ..()

/datum/species/beefman/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)

	// MEAT LIMBS: If our limb is missing, and we're using meat, stick it in!
	if (H.stat < DEAD && !affecting && intent == INTENT_DISARM && istype(I, /obj/item/reagent_containers/food/snacks/meat/slab))// /obj/item/bodypart))
		var/target_zone = user.zone_selected
		var/list/allowedList = list ( BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG )

		if ((target_zone in allowedList))
			if (user == H)
				user.visible_message("[user] begins mashing [I] into [H]'s torso.", \
						 	 "<span class='notice'>You begin mashing [I] into your torso.</span>")
			else
				user.visible_message("[user] begins mashing [I] into [H]'s torso.", \
						 	 "<span class='notice'>You begin mashing [I] into [H]'s torso.</span>")

			// Leave Melee Chain (so deleting the meat doesn't throw an error) <--- aka, deleting the meat that called this very proc.
			spawn(1)
				if (!do_mob(user,H))
					return TRUE
				// Attach the part!
				var/obj/item/bodypart/newBP = H.newBodyPart(target_zone, FALSE)
				H.visible_message("The meat sprouts digits and becomes [H]'s new [newBP.name]!", "<span class='notice'>The meat sprouts digits and becomes your new [newBP.name]!</span>")
				newBP.attach_limb(H)
				newBP.give_meat(H, I)
				playsound(get_turf(H), 'sound/Fulpsounds/beef_grab.ogg', 50, 1)

			return TRUE // True CANCELS the sequence.

	return ..() // TRUE FALSE

			//// OUTSIDE PROCS ////

// taken from _HELPERS/mobs.dm
/proc/random_unique_beefman_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(beefman_name(gender))

		if(!findname(.))
			break

// taken from _HELPERS/names.dm
/proc/beefman_name(gender)
	return "[pick(GLOB.experiment_names)] \Roman[rand(1,49)] '[pick(GLOB.russian_names)]'"



















			// INTEGRATION //

// NOTE: the proc for a bodypart appearing on a mob is get_limb_icon() in bodypart.dm    !! We tracked it from limb_augmentation.dm -> carbon/update_icons.dm -> bodyparts.dm


// Return what the robot part should look like on the current mob.
/obj/item/bodypart/proc/ReturnLocalAugmentIcon()
	// Default: No Owner  --> use default
	if (!owner)
		return icon_greyscale_robotic

	// Return Part
	var/obj/item/bodypart/bpType
	if (body_zone == BODY_ZONE_HEAD)
		bpType = owner.part_default_head
	if (body_zone == BODY_ZONE_CHEST)
		bpType = owner.part_default_chest
	if (body_zone == BODY_ZONE_L_ARM)
		bpType = owner.part_default_l_arm
	if (body_zone == BODY_ZONE_R_ARM)
		bpType = owner.part_default_r_arm
	if (body_zone == BODY_ZONE_L_LEG)
		bpType = owner.part_default_l_leg
	if (body_zone == BODY_ZONE_R_LEG)
		bpType = owner.part_default_r_leg

	if (bpType)
		return initial(bpType.icon_greyscale_robotic)

	// Fail? Default
	return icon_greyscale_robotic


/mob/living/carbon/human/species/beefman
	race = /datum/species/beefman

/obj/item/bodypart/
	var/icon/icon_greyscale = 'icons/mob/human_parts_greyscale.dmi' // Keep an eye on _DEFINES/mobs.dm to see if DEFAULT_BODYPART_ICON_ORGANIC / _ROBOTIC change.
	var/icon/icon_greyscale_robotic = 'icons/mob/augmentation/augments.dmi'
	var/obj/item/reagent_containers/food/snacks/meat/slab/myMeatType = /obj/item/reagent_containers/food/snacks/meat/slab // For remembering what kind of meat this was made of. Default is base meat slab.
	var/amCondemned = FALSE // I'm about to be destroyed. Don't add blood to me, and throw null error crap next tick.

	//var/species_id_original = "human" 	// So we know to whom we originally belonged. This swaps freely until the DROP LOCK below is set.
	var/organicDropLocked = FALSE   	// When set to TRUE, that means this part has been CLAIMED by the race that dropped it.
	var/prevOrganicState				// Remember each organic icon as you build it; if this limb drops, its stuck with that forever.
	var/prevOrganicState_Aux			// The hand sprite
	var/prevOrganicIcon

/obj/item/bodypart/add_mob_blood(mob/living/M) // Cancel adding blood if I'm deletin (throws errors)
	if (!amCondemned)
		..()

/mob/living/carbon
	// Type References for Bodyparts
	var/obj/item/bodypart/head/part_default_head = /obj/item/bodypart/head
	var/obj/item/bodypart/chest/part_default_chest = /obj/item/bodypart/chest
	var/obj/item/bodypart/l_arm/part_default_l_arm = /obj/item/bodypart/l_arm
	var/obj/item/bodypart/r_arm/part_default_r_arm = /obj/item/bodypart/r_arm
	var/obj/item/bodypart/l_leg/part_default_l_leg = /obj/item/bodypart/l_leg
	var/obj/item/bodypart/r_leg/part_default_r_leg = /obj/item/bodypart/r_leg


		// MEAT-TO-LIMB
		// 1) Save Meat's type
		// 2) Get all original Reagent TYPES from "list_reagents" on the meat itself - these reagents (TYPEPATHS) have the starter values. Save those values.
		// 3) Sort through thisMeat.reagents.reagent_list, which has ALL CURRENT reagents (ACTUAL DATUMS) inside the meat. Add up all those values.
		// 3) Percent = Compare the STARTER VALUES in list_reagents against the CURRENT VALUES in thisMeat.reagents.reagent_list/
		// 4) Inject ALL OTHER CHEMS into bloodstream

		// LIMB-TO-MEAT
		// 1) Create new meat
		// 2) Sort through all reagent datums in newMeat.list_reagents and adjust each version in newMeat.reagents.reagent_list/(REAGENT)/.volume
		// 3) Apply a small part of my body's metabolic reagents to the meat. Check how Feed does this.

// Meat has been assigned to this NEW limb! Give it meat and damage me as needed.
/obj/item/bodypart/proc/give_meat(mob/living/carbon/human/H, obj/item/reagent_containers/food/snacks/meat/slab/inMeatObj)
	// Assign Type
	myMeatType = inMeatObj.type

		// Adjust Health (did you eat some of this?)

	// Get Original Amount
	var/amountOriginal
	for (var/R in inMeatObj.list_reagents) // <---- List of TYPES and the starting AMOUNTS
		amountOriginal += inMeatObj.list_reagents[R]
	// Get Current Amount (of original reagents only)
	var/amountCurrent
	for (var/datum/reagent/R in inMeatObj.reagents.reagent_list) // <---- Actual REAGENT DATUMS and their VOLUMES
		// This datum exists in the original list?
		if (locate(R.type) in inMeatObj.list_reagents)
			amountCurrent += R.volume
			// Remove it from Meat (all others are about to be injected)
			inMeatObj.reagents.remove_reagent(R.type, R.volume)
	inMeatObj.reagents.update_total()
	// Set Health:
	var/percentDamage = 1 - amountCurrent / amountOriginal
	receive_damage(brute = max_damage * percentDamage)
	if (percentDamage >= 0.9)
		to_chat(owner, "<span class='alert'>It's almost completely useless. That [inMeatObj.name] was no good!</span>")
	else if (percentDamage > 0.5)
		to_chat(owner, "<span class='alert'>It's riddled with [inMeatObj.bitecount > 0 ? "bite marks":"gaping holes"].</span>")
	else if (percentDamage > 0)
		to_chat(owner, "<span class='alert'>It looks a little [inMeatObj.bitecount > 0 ? "eaten away":"torn up"], but it'll do.</span>")

	// Apply meat's Reagents to Me
	if(inMeatObj.reagents && inMeatObj.reagents.total_volume)
		//inMeatObj.reagents.reaction(owner, INJECT, inMeatObj.reagents.total_volume) // Run Reaction: what happens when what they have mixes with what I have?	DEAD CODE MUST REWORK
		inMeatObj.reagents.trans_to(owner, inMeatObj.reagents.total_volume)	// Run transfer of 1 unit of reagent from them to me.

	qdel(inMeatObj)


/obj/item/bodypart/proc/drop_meat(mob/inOwner)

	//Checks tile for cloning pod, if found then limb stays limb. Stops cloner from breaking beefmen making them useless after being cloned.
	//var/turf/T = get_turf(src)
	//for(var/obj/machinery/M in T)
	//	if(istype(M,/obj/machinery/clonepod))
	//		return FALSE

	// Not Organic? ABORT! Robotic stays robotic, desnt delete and turn to meat.
	if (status != BODYPART_ORGANIC)
		return FALSE

	// If not 0% health, let's do it!
	var/percentHealth = 1 - (brute_dam + burn_dam) / max_damage
	if (myMeatType != null && percentHealth > 0)

		// Create Meat
		var/obj/item/reagent_containers/food/snacks/meat/slab/newMeat =	new myMeatType(src.loc)///obj/item/reagent_containers/food/snacks/meat/slab(src.loc)

		// Adjust Reagents by Health Percent
		for (var/datum/reagent/R in newMeat.reagents.reagent_list)
			R.volume *= percentHealth
		newMeat.reagents.update_total()

		// Apply my Reagents to Meat
		if(inOwner.reagents && inOwner.reagents.total_volume)
			//inOwner.reagents.reaction(newMeat, INJECT, 20 / inOwner.reagents.total_volume) // Run Reaction: what happens when what they have mixes with what I have?	DEAD CODE MUST REWORK
			inOwner.reagents.trans_to(newMeat, 20)	// Run transfer of 1 unit of reagent from them to me.

		. = newMeat // Return MEAT

	qdel(src)
	//QDEL_IN(src,1) // Delete later. If we do it now, we screw up the "attack chain" that called this meat to attack the Beefman's stump.

/obj/item/bodypart/head/beef
	icon = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale_robotic = 'icons/Fulpicons/fulp_bodyparts_robotic.dmi'
	heavy_brute_msg = "mincemeat"
	heavy_burn_msg = "burned to a crisp"
/obj/item/bodypart/head/beef/drop_limb(special) // from dismemberment.dm
	amCondemned = TRUE
	var/mob/owner_cache = owner
	..() // Create Meat, Remove Limb
	return drop_meat(owner_cache)

/obj/item/bodypart/chest/beef
	icon = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale_robotic = 'icons/Fulpicons/fulp_bodyparts_robotic.dmi'
	heavy_brute_msg = "mincemeat"
	heavy_burn_msg = "burned to a crisp"
/obj/item/bodypart/chest/beef/drop_limb(special) // from dismemberment.dm
	amCondemned = TRUE
	var/mob/owner_cache = owner
	..() // Create Meat, Remove Limb
	return drop_meat(owner_cache)

/obj/item/bodypart/r_arm/beef
	icon = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale_robotic = 'icons/Fulpicons/fulp_bodyparts_robotic.dmi'
	heavy_brute_msg = "mincemeat"
	heavy_burn_msg = "burned to a crisp"
/obj/item/bodypart/r_arm/beef/drop_limb(special) // from dismemberment.dm
	amCondemned = TRUE
	var/mob/owner_cache = owner
	..() // Create Meat, Remove Limb
	return drop_meat(owner_cache)

/obj/item/bodypart/l_arm/beef
	icon = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale_robotic = 'icons/Fulpicons/fulp_bodyparts_robotic.dmi'
	heavy_brute_msg = "mincemeat"
	heavy_burn_msg = "burned to a crisp"
/obj/item/bodypart/l_arm/beef/drop_limb(special) // from dismemberment.dm
	amCondemned = TRUE
	var/mob/owner_cache = owner
	..() // Create Meat, Remove Limb
	return drop_meat(owner_cache)

/obj/item/bodypart/r_leg/beef
	icon = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale_robotic = 'icons/Fulpicons/fulp_bodyparts_robotic.dmi'
	heavy_brute_msg = "mincemeat"
	heavy_burn_msg = "burned to a crisp"
/obj/item/bodypart/r_leg/beef/drop_limb(special) // from dismemberment.dm
	amCondemned = TRUE
	var/mob/owner_cache = owner
	..() // Create Meat, Remove Limb
	return drop_meat(owner_cache)

/obj/item/bodypart/l_leg/beef
	icon = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale = 'icons/Fulpicons/fulp_bodyparts.dmi'
	icon_greyscale_robotic = 'icons/Fulpicons/fulp_bodyparts_robotic.dmi'
	heavy_brute_msg = "mincemeat"
	heavy_burn_msg = "burned to a crisp"
/obj/item/bodypart/l_leg/beef/drop_limb(special) // from dismemberment.dm
	amCondemned = TRUE
	var/mob/owner_cache = owner
	..() // Create Meat, Remove Limb
	return drop_meat(owner_cache)


















// SPRITE PARTS //

//GLOBAL_LIST_INIT(eyes_beefman, list( "Peppercorns", "Capers", "Olives" ))
//GLOBAL_LIST_INIT(mouths_beefman, list( "Smile1", "Smile2", "Frown1", "Frown2", "Grit1", "Grit2" ))
/datum/sprite_accessory/beef/
	icon = 'icons/Fulpicons/fulp_bodyparts.dmi'

	// please make sure they're sorted alphabetically and, where needed, categorized
	// try to capitalize the names please~
	// try to spell
	// you do not need to define _s or _l sub-states, game automatically does this for you

/datum/sprite_accessory/beef/eyes
	color_src = EYECOLOR	//Currently only used by mutantparts so don't worry about hair and stuff. This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
/datum/sprite_accessory/beef/eyes/peppercorns
	name = "Peppercorns"
	icon_state = "peppercorns"
/datum/sprite_accessory/beef/eyes/olives
	name = "Olives"
	icon_state = "olives"
/datum/sprite_accessory/beef/eyes/capers
	name = "Capers"
	icon_state = "capers"
/datum/sprite_accessory/beef/eyes/cloves
	name = "Cloves"
	icon_state = "cloves"

/datum/sprite_accessory/beef/mouth
	use_static = TRUE
	color_src = 0
/datum/sprite_accessory/beef/mouth/smile1
	name = "Smile 1"
	icon_state = "smile1"
/datum/sprite_accessory/beef/mouth/smile2
	name = "Smile 2"
	icon_state = "smile2"
/datum/sprite_accessory/beef/mouth/frown1
	name = "Frown 1"
	icon_state = "frown1"
/datum/sprite_accessory/beef/mouth/frown2
	name = "Frown 2"
	icon_state = "frown2"
/datum/sprite_accessory/beef/mouth/grit1
	name = "Grit 1"
	icon_state = "grit1"
/datum/sprite_accessory/beef/mouth/grit2
	name = "Grit 2"
	icon_state = "grit2"



/// found in cargo.dm etc. in modules/clothing/under/job

/obj/item/clothing/under/bodysash/
	name = "body sash"
	desc = "A simple body sash, slung from shoulder to hip."
	icon = 'icons/Fulpicons/fulpclothing.dmi' // item icon
	worn_icon =  'icons/Fulpicons/fulpclothing_worn.dmi' // mob worn icon
	icon_state = "assistant" // Inventory Icon
	//item_color = "assistant" // The worn item Icon
	body_parts_covered = CHEST // |GROIN|ARMS
	lefthand_file = 'icons/Fulpicons/fulpclothing_hold_left.dmi'
	righthand_file = 'icons/Fulpicons/fulpclothing_hold_right.dmi'
	inhand_icon_state = "sash" // In-hand Icon

/obj/item/clothing/under/bodysash/security
	name = "security sash"
	icon_state = "security"
	//item_color = "security" // The worn item state
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small
/obj/item/clothing/under/bodysash/medical
	name = "medical sash"
	icon_state = "medical"
	//item_color = "medical" // The worn item state
/obj/item/clothing/under/bodysash/science
	name = "science sash"
	icon_state = "science"
	//item_color = "science" // The worn item state
/obj/item/clothing/under/bodysash/cargo
	name = "cargo sash"
	icon_state = "cargo"
	//item_color = "cargo" // The worn item state
/obj/item/clothing/under/bodysash/engineer
	name = "engineer sash"
	icon_state = "engineer"
	//item_color = "engineer" // The worn item state
/obj/item/clothing/under/bodysash/civilian
	name = "civilian sash"
	icon_state = "civilian"
	//item_color = "civilian" // The worn item state
/obj/item/clothing/under/bodysash/command
	name = "command sash"
	icon_state = "command"
	//item_color = "command" // The worn item state
/obj/item/clothing/under/bodysash/clown
	name = "clown sash"
	icon_state = "clown"
	//item_color = "clown" // The worn item state
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small
/obj/item/clothing/under/bodysash/mime
	name = "mime sash"
	icon_state = "mime"
	//item_color = "mime" // The worn item state




////////////	CUSTOM TRAUMAS



/datum/brain_trauma/special/bluespace_prophet/phobetor
	name = "Sleepless Dreamer"
	desc = "The patient, after undergoing untold psychological hardship, believes they can travel between the dreamscapes of this dimension."
	scan_desc = "awoken sleeper"
	gain_text = "<span class='notice'>Your mind snaps, and you wake up. You <i>really</i> wake up.</span>"
	lose_text = "<span class='warning'>You succumb once more to the sleepless dream of the unwoken.</span>"

	var/list/created_firsts = list()

/datum/brain_trauma/special/bluespace_prophet/phobetor/on_life()

	var/turf/first_turf
	var/turf/second_turf

	// Make Next Portal
	if(world.time > next_portal)

/*
		// Round One: Pick a Nearby Turf
		var/list/turf/possible_turfs = return_valid_floors_in_range(owner, 6, 0, TRUE) // Source, Range, Has Floor
		if(!LAZYLEN(possible_turfs))
			return
		// First Pick:
		var/turf/first_turf = pick(possible_turfs)
		if(!first_turf)
			return

		// Round Two: Pick an even Further Turf
		possible_turfs = return_valid_floors_in_range(first_turf, 20, 6, TRUE) // Source, Range, Has Floor
		possible_turfs -= first_turf
		if(!LAZYLEN(possible_turfs))
			return
		// Second Pick:
		var/turf/second_turf = pick(possible_turfs)
		if(!second_turf)
			return
*/

		// Round One: Pick a Nearby Turf
		first_turf = return_valid_floor_in_range(owner, 6, 0, TRUE)
		if (!first_turf)
			next_portal = world.time + 10
			return

		// Round Two: Pick an even Further Turf
		second_turf = return_valid_floor_in_range(first_turf, 20, 6, TRUE)
		if (!second_turf)
			next_portal = world.time + 10
			return

		next_portal = world.time + 100


		var/obj/effect/hallucination/simple/phobetor/first = new (first_turf, owner)
		var/obj/effect/hallucination/simple/phobetor/second = new (second_turf, owner)

		first.linked_to = second
		second.linked_to = first
		first.seer = owner
		second.seer = owner
		first.desc += " This one leads to [get_area(second)]."
		second.desc += " This one leads to [get_area(first)]."

		// Remember this Portal...it's gonna get checked for deletion.
		created_firsts += first

	// Delete Next Portal if it's time (it will remove its partner)
	var/obj/effect/hallucination/simple/phobetor/first_on_the_stack = created_firsts[1]
	if (created_firsts.len && world.time >= first_on_the_stack.created_on + first_on_the_stack.exist_length)
		var/targetGate = first_on_the_stack
		created_firsts -= targetGate
		qdel(targetGate)

//Called when removed from a mob
/datum/brain_trauma/special/bluespace_prophet/phobetor/on_lose(silent)
	for (var/BT in created_firsts)
		qdel(BT)


/obj/effect/hallucination/simple/phobetor
	name = "phobetor tear"
	desc = "A subdimensional rip in reality, which gives extra-spacial passage to those who have woken from the sleepless dream."
	/*light_color = "#FF88AA"
	light_range = 2
	light_power = 2*/
	image_icon = 'icons/Fulpicons/fulp_effects.dmi'
	image_state = "phobetor_tear"
	image_layer = ABOVE_LIGHTING_LAYER // Place this above shadows so it always glows.
	var/exist_length = 500
	var/created_on
	use_without_hands = TRUE // A Swain addition.
	var/obj/effect/hallucination/simple/phobetor/linked_to
	var/mob/living/carbon/seer

/obj/effect/hallucination/simple/phobetor/attack_hand(mob/user)
	if(user != seer || !linked_to)
		return
	if (user.loc != src.loc)
		to_chat(user, "Step into the Tear before using it.")
		return
	// Is this, or linked, stream being watched?
	if (check_location_seen(user, get_turf(user)))
		to_chat(user, "<span class='warning'>Not while you're being watched.</span>")
		return
	if (check_location_seen(user, get_turf(linked_to)))
		to_chat(user, "<span class='warning'>Your destination is being watched.</span>")
		return
	to_chat(user, "<span class='notice'>You slip unseen through the Phobetor Tear.</span>")
	user.playsound_local(null, 'sound/magic/wand_teleport.ogg', 30, FALSE, pressure_affected = FALSE)

	//new /obj/effect/temp_visual/bluespace_fissure(get_turf(src))
	//new /obj/effect/temp_visual/bluespace_fissure(get_turf(linked_to))
	user.forceMove(get_turf(linked_to))

/obj/effect/hallucination/simple/phobetor/Initialize()
	. = ..()
	created_on = world.time
	//QDEL_IN(src, 300)

/obj/effect/hallucination/simple/phobetor/Destroy()
	// Remove Linked (if exists)
	if (linked_to)
		linked_to.linked_to = null
		qdel(linked_to)
		// WHY DO THIS?	Because our trauma only gets rid of all the FIRST gates created.
	. = ..()
