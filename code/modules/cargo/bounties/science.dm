
/datum/bounty/item/science/relic
	name = "E.X.P.E.R.I-MENTORially Discovered Devices"
	description = "Psst, hey. Don't tell the assistants, but we're undercutting them on the value of those 'strange objects' they've been finding. Fish one up and send us a discovered one by using the E.X.P.E.R.I-MENTOR."
	reward = CARGO_CRATE_VALUE * 8
	wanted_types = list(/obj/item/relic = TRUE)

/datum/bounty/item/science/relic/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/relic/experiment = O
	if(experiment.activated)
		return TRUE
	return

/datum/bounty/item/science/bepis_disc
	name = "Reformatted Tech Disk"
	description = "It turns out the diskettes the BEPIS prints experimental nodes on are extremely space-efficient. Send us one of your spares when you're done with it."
	reward = CARGO_CRATE_VALUE * 8
	wanted_types = list(
		/obj/item/disk/design_disk/bepis/remove_tech = TRUE,
		/obj/item/disk/design_disk/bepis = TRUE,
	)

/datum/bounty/item/science/genetics
	name = "Genetics Disability Mutator"
	description = "Understanding the humanoid genome is the first step to curing many spaceborn genetic defects, and exceeding our basest limits."
	reward = CARGO_CRATE_VALUE * 2
	wanted_types = list(/obj/item/dnainjector = TRUE)
	///What's the instability
	var/desired_instability = 0

/datum/bounty/item/science/genetics/New()
	. = ..()
	desired_instability = rand(10,40)
	reward += desired_instability * (CARGO_CRATE_VALUE * 0.2)
	description += " We want a DNA injector whose total instability is higher than [desired_instability] points."

/datum/bounty/item/science/genetics/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/dnainjector/mutator = O
	if(mutator.used)
		return FALSE
	var/inst_total = 0
	for(var/pot_mut in mutator.add_mutations)
		var/datum/mutation/human/mutation = pot_mut
		if(initial(mutation.quality) != POSITIVE)
			continue
		inst_total += mutation.instability
	if(inst_total >= desired_instability)
		return TRUE
	return FALSE

//******Modular Computer Bounties******
/datum/bounty/item/science/ntnet
	name = "Modular Tablets"
	description = "Turns out that NTNet wasn't actually a fad after all, who knew. Send some fully functional PDAs to help get us up to speed on the latest technology."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 4
	wanted_types = list(/obj/item/modular_computer/pda = TRUE)
	var/require_powered = TRUE

/datum/bounty/item/science/ntnet/applies_to(obj/O)
	if(!..())
		return FALSE
	if(require_powered)
		var/obj/item/modular_computer/computer = O
		if(!istype(computer) || !computer.enabled)
			return FALSE
	return TRUE

/datum/bounty/item/science/ntnet/laptops
	name = "Modular Laptops"
	description = "Central command brass need something more powerful than a tablet, but more portable than a console. Help these old fogeys out by shipping us some working laptops. Send them turned on."
	reward = CARGO_CRATE_VALUE * 3
	required_count = 2
	wanted_types = list(/obj/item/modular_computer/laptop = TRUE)

/datum/bounty/item/science/ntnet/console
	name = "Modular Computer Console"
	description = "Our big data division needs more powerful hardware to play 'Outbomb Cuban Pe-', err, to closely monitor threats in your sector. Send us a working modular computer console."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 1
	wanted_types = list(/obj/machinery/modular_computer = TRUE)
	require_powered = FALSE

/datum/bounty/item/science/ntnet/console/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/machinery/modular_computer/computer = O
	if(!istype(computer) || !computer.cpu)
		return FALSE
	return TRUE


//******Anomaly Cores******
/datum/bounty/item/science/ref_anomaly
	name = "Refined Bluespace Core"
	description = "We need a bluespace core to assemble a bag of holding. Ship us one, please."
	reward = CARGO_CRATE_VALUE * 20
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bluespace = TRUE)

/datum/bounty/item/science/ref_anomaly/can_get(obj/O)
	var/anomaly_type = wanted_types[1]
	if(SSresearch.created_anomaly_types[anomaly_type] >= SSresearch.anomaly_hard_limit_by_type[anomaly_type])
		return FALSE
	return TRUE

/datum/bounty/item/science/ref_anomaly/flux
	name = "Refined Flux Core"
	description = "We're trying to make a tesla cannon to handle some moths. Ship us a flux core, please."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/flux = TRUE)

/datum/bounty/item/science/ref_anomaly/pyro
	name = "Refined Pyroclastic Core"
	description = "We need to study a refined pyroclastic core, please send one."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/pyro = TRUE)

/datum/bounty/item/science/ref_anomaly/grav
	name = "Refined Gravitational Core"
	description = "Central R&D is trying to discover a way to make mechs float, send over a gravitational core."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/grav = TRUE)

/datum/bounty/item/science/ref_anomaly/vortex
	name = "Refined Vortex Core"
	description = "We're going to throw a vortex core into a wormhole to see what happens. Send one."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/vortex = TRUE)

/datum/bounty/item/science/ref_anomaly/hallucination
	name = "Refined Hallucination Core"
	description = "We're making a better version of space drugs, send us a core to help us replicate its effects."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/hallucination = TRUE)

/datum/bounty/item/science/ref_anomaly/bioscrambler
	name = "Refined Bioscrambler Core"
	description = "Our janitor lizard lost all their limbs, send us a bioscrambler core to replace them."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bioscrambler = TRUE)

/datum/bounty/item/science/ref_anomaly/dimensional
	name = "Refined Dimensional Core"
	description = "We're trying to save money on our annual renovations at CentCom. Send us a dimensional core."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/dimensional = TRUE)
