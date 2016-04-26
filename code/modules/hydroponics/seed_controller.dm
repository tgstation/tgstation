// Attempts to offload processing for the spreading plants from the MC.
// Processes vines/spreading plants.

#define PLANTS_PER_TICK 500 // Cap on number of plant segments processed.
#define PLANT_TICK_TIME 50  // Number of ticks between the plant processor cycling.

// Debug for testing seed genes.
/client/proc/show_plant_genes()
	set category = "Debug"
	set name = "Show Plant Genes"
	set desc = "Prints the round's plant gene masks."

	if(!holder)	return

	if(!plant_controller || !plant_controller.gene_tag_masks)
		to_chat(usr, "Gene masks not set.")
		return

	for(var/mask in plant_controller.gene_tag_masks)
		to_chat(usr, "[mask]: [plant_controller.gene_tag_masks[mask]]")

var/global/datum/controller/plants/plant_controller // Set in New().

/datum/controller/plants

	var/plants_per_tick = PLANTS_PER_TICK
	var/plant_tick_time = PLANT_TICK_TIME
	var/list/plant_queue = list()           // All queued plants.
	var/list/datum/seed/seeds = list()      // All seed data stored here.
	var/list/gene_tag_masks = list()        // Gene obfuscation for delicious trial and error goodness.

/datum/controller/plants/New()
	if(plant_controller && plant_controller != src)
		log_debug("Rebuilding plant controller.")
		qdel(plant_controller)
	plant_controller = src
	setup()
	process()

// Predefined/roundstart varieties use a string key to make it
// easier to grab the new variety when mutating. Post-roundstart
// and mutant varieties use their uid converted to a string instead.
// Looks like shit but it's sort of necessary.
/datum/controller/plants/proc/setup()
	// Populate the global seed datum list.
	for(var/type in typesof(/datum/seed)-/datum/seed)
		var/datum/seed/S = new type
		seeds[S.name] = S
		S.uid = "[seeds.len]"
		S.roundstart = 1

	// Make sure any seed packets that were mapped in are updated
	// correctly (since the seed datums did not exist a tick ago).
	for(var/obj/item/seeds/S in world)
		S.update_seed()

	//Might as well mask the gene types while we're at it.
	var/list/gene_tags = list(GENE_PHYTOCHEMISTRY, GENE_MORPHOLOGY, GENE_BIOLUMINESCENCE, GENE_ECOLOGY, GENE_ECOPHYSIOLOGY, GENE_METABOLISM, GENE_NUTRITION, GENE_DEVELOPMENT)
	var/list/used_masks = list()

	while(gene_tags && gene_tags.len)
		var/gene_tag = pick(gene_tags)
		var/gene_mask = "[num2hex(rand(0,255))]"

		while(gene_mask in used_masks)
			gene_mask = "[num2hex(rand(0,255))]"

		used_masks += gene_mask
		gene_tags -= gene_tag
		gene_tag_masks[gene_tag] = gene_mask

// Proc for creating a random seed type.
/datum/controller/plants/proc/create_random_seed(var/survive_on_station)
	var/datum/seed/seed = new()
	seed.randomize()
	seed.uid = plant_controller.seeds.len + 1
	seed.name = "[seed.uid]"
	seeds[seed.name] = seed

	if(survive_on_station)
		if(seed.consume_gasses)
			seed.consume_gasses["plasma"] = null //PHORON DOES NOT EXIST
			seed.consume_gasses["carbon_dioxide"] = null
		if(seed.chems && !isnull(seed.chems["pacid"]))
			seed.chems["pacid"] = null // Eating through the hull will make these plants completely inviable, albeit very dangerous.
			seed.chems -= null // Setting to null does not actually remove the entry, which is weird.
		seed.ideal_heat = initial(seed.ideal_heat)
		seed.heat_tolerance = initial(seed.heat_tolerance)
		seed.ideal_light = initial(seed.ideal_light)
		seed.light_tolerance = initial(seed.light_tolerance)
		seed.lowkpa_tolerance = initial(seed.lowkpa_tolerance)
		seed.highkpa_tolerance = initial(seed.highkpa_tolerance)
	return seed

/datum/controller/plants/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		var/processed = 0
		while(1)
			if(!processing)
				sleep(plant_tick_time)
			else
				processed = 0
				if(plant_queue.len)
					var/target_to_process = min(plant_queue.len,plants_per_tick)
					for(var/x=0;x<target_to_process;x++)
						if(!plant_queue.len)
							break
						var/obj/effect/plantsegment/plant = pick(plant_queue)
						plant_queue -= plant
						if(!istype(plant))
							continue
						plant.process()
						processed++
						sleep(1) // Stagger processing out so previous tick can resolve (overlapping plant segments etc)
				sleep(max(1,(plant_tick_time-processed)))

/datum/controller/plants/proc/add_plant(var/obj/effect/plantsegment/plant)
	plant_queue |= plant

/datum/controller/plants/proc/remove_plant(var/obj/effect/plantsegment/plant)
	plant_queue -= plant
