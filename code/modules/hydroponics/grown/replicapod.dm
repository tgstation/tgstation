// A very special plant, deserving its own file.

// Yes, i'm talking about cabbage, baby! No, just kidding, but cabbages are the precursor to replica pods, so they are here as well.
/obj/item/seeds/cabbage
	name = "cabbage seed pack"
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
	growing_icon = 'icons/obj/service/hydroponics/growing_vegetables.dmi'
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
	name = "replica pod seed pack"
	desc = "These seeds grow into replica pods. They say these are used to harvest humans."
	icon_state = "seed-replicapod"
	plant_icon_offset = 2
	species = "replicapod"
	plantname = "Replica Pod"
	product = null // the human mob is spawned in harvest()
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

/obj/item/seeds/replicapod/Initialize(mapload)
	. = ..()
	create_reagents(volume, INJECTABLE | DRAWABLE)

/obj/item/seeds/replicapod/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_update))

/// Handles reagents getting added to this seed.
/obj/item/seeds/replicapod/proc/on_reagent_update(datum/reagents/reagents)
	SIGNAL_HANDLER

	var/datum/reagent/blood/blood = reagents.has_reagent(/datum/reagent/blood)
	if(!blood)
		return

	if(!blood.data["mind"] || !blood.data["cloneable"])
		visible_message(span_warning("The [src] rejects the sample!"))
		return

	mind = blood.data["mind"]
	ckey = blood.data["ckey"]
	realName = blood.data["real_name"]
	blood_gender = blood.data["gender"]
	blood_type = blood.data["blood_type"]
	features = blood.data["features"]
	factions = blood.data["factions"]
	quirks = blood.data["quirks"]
	sampleDNA = blood.data["blood_DNA"]
	contains_sample = TRUE
	visible_message(span_notice("The [src] is injected with a fresh blood sample."))
	investigate_log("[key_name(mind)]'s cloning record was added to [src]", INVESTIGATE_BOTANY)

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

/obj/item/seeds/replicapod/get_unique_analyzer_data()
	if(contains_sample)
		return list("Blood DNA" = sampleDNA)
	return null

/obj/item/seeds/replicapod/harvest(mob/user) //now that one is fun -- Urist
	var/obj/machinery/hydroponics/parent = loc
	var/make_podman = FALSE
	var/ckey_holder = null
	var/list/result = list()
	if(CONFIG_GET(flag/revival_pod_plants))
		if(ckey)
			for(var/mob/corpse as anything in GLOB.player_list)
				if (corpse.ckey != ckey || HAS_TRAIT(corpse, TRAIT_SUICIDED))
					continue

				if(isobserver(corpse))
					var/mob/dead/observer/ghost = corpse
					if(ghost.can_reenter_corpse)
						make_podman = TRUE
				else if(corpse.stat == DEAD && !HAS_TRAIT(corpse, TRAIT_MIND_TEMPORARILY_GONE))
					make_podman = TRUE

				break

		else if (mind)
			// If the player has ghosted from his corpse before blood was drawn, his ckey is no longer attached to the mob, so we need to match up the cloned player through the mind key
			for(var/mob/corpse in GLOB.player_list)
				if (!corpse.mind || !corpse.ckey || !corpse.client)
					continue

				if (ckey(corpse.mind.key) != ckey(mind.key))
					continue

				if (corpse.stat != DEAD || HAS_TRAIT(corpse, TRAIT_SUICIDED))
					continue

				if(isobserver(corpse))
					var/mob/dead/observer/ghost = corpse
					if(!ghost.can_reenter_corpse)
						break

				make_podman = TRUE
				ckey_holder = corpse.ckey
				break

	// No podman player, give one or two seeds.
	if(!make_podman)
		// Prevent accidental harvesting. Make sure the user REALLY wants to do this if there's a chance of this coming from a living creature.
		if(user.client && (mind || ckey))
			var/choice = tgui_alert(user, "The pod is currently devoid of soul. There is a possibility that a soul could claim this creature, or you could harvest it for seeds.", "Harvest Seeds?", list("Harvest Seeds", "Cancel"))
			if(choice != "Harvest Seeds")
				return result

		// If this plant has already been harvested, return early.
		// parent.update_tray() qdels this seed.
		if(QDELETED(src))
			to_chat(user, text = "This pod has already had its seeds harvested!", type = MESSAGE_TYPE_INFO)
			return result

		// Make sure they can still interact with the parent hydroponics tray.
		if(!user.can_perform_action(parent))
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
		podman.PossessByPlayer(ckey)
	else
		podman.PossessByPlayer(ckey_holder)

	podman.gender = blood_gender
	podman.faction |= factions
	if(!features[FEATURE_MUTANT_COLOR])
		features[FEATURE_MUTANT_COLOR] = "#59CE00"
	if(!features[FEATURE_POD_HAIR])
		features[FEATURE_POD_HAIR] = pick(SSaccessories.pod_hair_list)

	for(var/V in quirks)
		new V(podman)
	podman.hardset_dna(null, null, null, podman.real_name, blood_type, new /datum/species/pod, features) // Discard SE's and UI's, podman cloning is inaccurate, and always make them a podman
	podman.set_cloned_appearance()

	//Get the most plentiful reagent, if there's none: get water
	var/list/most_plentiful_reagent = list(/datum/reagent/water = 0)
	for(var/reagent in reagents_add)
		if(reagents_add[reagent] > most_plentiful_reagent[most_plentiful_reagent[1]])
			most_plentiful_reagent.Cut()
			most_plentiful_reagent[reagent] = reagents_add[reagent]

	var/datum/reagent/new_blood_reagent = most_plentiful_reagent[1]
	// Try to find a corresponding blood type for this reagent
	var/datum/blood_type/new_blood_type = get_blood_type(new_blood_reagent)
	if(isnull(new_blood_type)) // this blood type doesn't exist yet in the global list, so make a new one
		new_blood_type = new /datum/blood_type/random_chemical(new_blood_reagent)
		GLOB.blood_types[new_blood_type::id] = new_blood_type
	podman.set_blood_type(new_blood_type)

	investigate_log("[key_name(mind)] cloned as a podman via [src] in [parent]", INVESTIGATE_BOTANY)
	parent.update_tray(user, 1)
	return result
