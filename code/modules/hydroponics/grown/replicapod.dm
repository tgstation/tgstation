// A very special plant, deserving it's own file.

// Yes, i'm talking about cabbage, baby! No, just kidding, but cabbages are the precursor to replica pods, so they are here as well.
/obj/item/seeds/cabbage
	name = "pack of cabbage seeds"
	desc = "These seeds grow into cabbages."
	icon_state = "seed-cabbage"
	species = "cabbage"
	plantname = "Cabbages"
	product = /obj/item/food/grown/cabbage
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	instability = 10
	growthstages = 1
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/replicapod)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	seed_flags = null

/obj/item/food/grown/cabbage
	seed = /obj/item/seeds/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	foodtypes = VEGETABLES
	wine_power = 20

///The actual replica pods themselves!
/obj/item/seeds/replicapod
	name = "pack of replica pod seeds"
	desc = "These seeds grow into replica pods. They say these are used to harvest humans."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Replica Pod"
	product = /mob/living/carbon/human //verrry special -- Urist
	lifespan = 50
	endurance = 8
	maturation = 10
	production = 1
	yield = 1 //seeds if there isn't a dna inside
	instability = 15 //allows it to gain reagent genes from nearby plants
	potency = 30
	var/volume = 5
	var/ckey
	var/realName
	var/datum/mind/mind
	var/blood_gender
	var/blood_type
	var/list/features
	var/factions
	var/list/quirks
	var/sampleDNA
	var/contains_sample = FALSE
	var/being_harvested = FALSE

/obj/item/seeds/replicapod/Initialize(mapload)
	. = ..()

	create_reagents(volume, INJECTABLE|DRAWABLE)

/obj/item/seeds/replicapod/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_NEW_REAGENT), .proc/on_reagent_add)
	RegisterSignal(reagents, COMSIG_REAGENTS_DEL_REAGENT, .proc/on_reagent_del)
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, .proc/on_reagents_del)

/// Handles the seeds' reagents datum getting deleted.
/obj/item/seeds/replicapod/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_PARENT_QDELETING))
	return NONE

/// Handles reagents getting added to this seed.
/obj/item/seeds/replicapod/proc/on_reagent_add(datum/reagents/reagents)
	SIGNAL_HANDLER
	var/datum/reagent/blood/B = reagents.has_reagent(/datum/reagent/blood)
	if(!B)
		return

	if(B.data["mind"] && B.data["cloneable"])
		mind = B.data["mind"]
		ckey = B.data["ckey"]
		realName = B.data["real_name"]
		blood_gender = B.data["gender"]
		blood_type = B.data["blood_type"]
		features = B.data["features"]
		factions = B.data["factions"]
		quirks = B.data["quirks"]
		sampleDNA = B.data["blood_DNA"]
		contains_sample = TRUE
		visible_message(span_notice("The [src] is injected with a fresh blood sample."))
		log_cloning("[key_name(mind)]'s cloning record was added to [src] at [AREACOORD(src)].")
	else
		visible_message(span_warning("The [src] rejects the sample!"))
	return NONE

/// Handles reagents being deleted from these seeds.
/obj/item/seeds/replicapod/proc/on_reagent_del(changetype)
	SIGNAL_HANDLER
	if(reagents.has_reagent(/datum/reagent/blood))
		return

	mind = null
	ckey = null
	realName = null
	blood_gender = null
	blood_type = null
	features = null
	factions = null
	sampleDNA = null
	contains_sample = FALSE
	return NONE

/obj/item/seeds/replicapod/get_unique_analyzer_text()
	if(contains_sample)
		return "It contains a blood sample with blood DNA (UE) \"[sampleDNA]\"." //blood DNA (UE) shows in medical records and is readable by forensics scanners
	else
		return null

/obj/item/seeds/replicapod/harvest(mob/user) //now that one is fun -- Urist
	var/obj/machinery/hydroponics/parent = loc
	var/make_podman = FALSE
	var/ckey_holder = null
	var/list/result = list()
	if(CONFIG_GET(flag/revival_pod_plants))
		if(ckey)
			for(var/mob/M in GLOB.player_list)
				if(isobserver(M))
					var/mob/dead/observer/O = M
					if(O.ckey == ckey && O.can_reenter_corpse)
						make_podman = TRUE
						break
				else
					if(M.ckey == ckey && M.stat == DEAD && !M.suiciding)
						make_podman = TRUE
						break
		else //If the player has ghosted from his corpse before blood was drawn, his ckey is no longer attached to the mob, so we need to match up the cloned player through the mind key
			for(var/mob/M in GLOB.player_list)
				if(mind && M.mind && ckey(M.mind.key) == ckey(mind.key) && M.ckey && M.client && M.stat == DEAD && !M.suiciding)
					if(isobserver(M))
						var/mob/dead/observer/O = M
						if(!O.can_reenter_corpse)
							break
					make_podman = TRUE
					ckey_holder = M.ckey
					break

	// No podman player, give one or two seeds.
	if(!make_podman)
		// Prevent accidental harvesting. Make sure the user REALLY wants to do this if there's a chance of this coming from a living creature.
		if(mind || ckey)
			var/choice = tgui_alert(usr,"The pod is currently devoid of soul. There is a possibility that a soul could claim this creature, or you could harvest it for seeds.", "Harvest Seeds?", list("Harvest Seeds", "Cancel"))
			if(choice == "Cancel")
				return result

		// If this plant has already been harvested, return early.
		// parent.update_tray() qdels this seed.
		if(QDELETED(src))
			to_chat(user, text = "This pod has already had its seeds harvested!", type = MESSAGE_TYPE_INFO)
			return result

		// Make sure they can still interact with the parent hydroponics tray.
		if(!user.canUseTopic(parent, BE_CLOSE))
			to_chat(user, text = "You are no longer able to harvest the seeds from [parent]!", type = MESSAGE_TYPE_INFO)
			return result

		var/seed_count = 1
		if(prob(getYield() * 20))
			seed_count++
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
		for(var/i  in 1 to seed_count)
			var/obj/item/seeds/replicapod/harvestseeds = src.Copy()
			result.Add(harvestseeds)
			harvestseeds.forceMove(output_loc)
		parent.update_tray(user, seed_count)
		return result

	// Congratulations! %Do you want to build a pod man?%
	var/mob/living/carbon/human/podman = new /mob/living/carbon/human(parent.loc)

	if(realName)
		podman.real_name = realName
	else
		podman.real_name = "Pod Person ([rand(1,999)])"
	mind.transfer_to(podman)
	if(ckey)
		podman.ckey = ckey
	else
		podman.ckey = ckey_holder
	podman.gender = blood_gender
	podman.faction |= factions
	if(!features["mcolor"])
		features["mcolor"] = "#59CE00"
	for(var/V in quirks)
		new V(podman)
	podman.hardset_dna(null,null,null,podman.real_name,blood_type, new /datum/species/pod,features)//Discard SE's and UI's, podman cloning is inaccurate, and always make them a podman
	podman.set_cloned_appearance()
	podman.dna.species.exotic_blood = max(reagents_add) || /datum/reagent/water
	log_cloning("[key_name(mind)] cloned as a podman via [src] in [parent] at [AREACOORD(parent)].")
	parent.update_tray(user, 1)
	return result
