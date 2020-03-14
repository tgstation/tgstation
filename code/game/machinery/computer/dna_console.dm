#define INJECTOR_TIMEOUT 100
#define NUMBER_OF_BUFFERS 3
#define SCRAMBLE_TIMEOUT 600
#define JOKER_TIMEOUT 12000					//20 minutes
#define JOKER_UPGRADE 3000

#define RADIATION_STRENGTH_MAX 15
#define RADIATION_STRENGTH_MULTIPLIER 1			//larger has more range

#define RADIATION_DURATION_MAX 30
#define RADIATION_ACCURACY_MULTIPLIER 3			//larger is less accurate


#define RADIATION_IRRADIATION_MULTIPLIER 1		//multiplier for how much radiation a test subject receives

#define SCANNER_ACTION_SE 1
#define SCANNER_ACTION_UI 2
#define SCANNER_ACTION_UE 3
#define SCANNER_ACTION_MIXED 4

/obj/machinery/computer/scan_consolenew
	name = "scan_consolenew"
	desc = "Scan DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	density = TRUE
	circuit = /obj/item/circuitboard/computer/scan_consolenew

	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 400
	light_color = LIGHT_COLOR_BLUE

	var/datum/techweb/stored_research
	var/max_storage = 6
	var/combine
	var/radduration = 2
	var/radstrength = 1
	var/max_chromosomes = 6
	///Amount of mutations we can store
	var/list/buffer[NUMBER_OF_BUFFERS]
	///mutations we have stored
	var/list/stored_mutations = list()
	///chromosomes we have stored
	var/list/stored_chromosomes = list()
	///combinations of injectors for the 'injector selection'. format is list("Elsa" = list(Cryokinesis, Geladikinesis), "The Hulk" = list(Hulk, Gigantism), etc) Glowy and the gang being an initialized datum
	var/list/injector_selection = list()
	///max amount of selections you can make
	var/max_injector_selections = 2
	///hard-cap on the advanced dna injector
	var/max_injector_mutations = 10
	///the max instability of the advanced injector.
	var/max_injector_instability = 50

	var/list/genes = list("A","T","G","C","X")
	var/list/reversegenes = list("X","C","G","T","A")

	var/injectorready = 0	//world timer cooldown var
	var/jokerready = 0
	var/scrambleready = 0

	var/obj/item/disk/data/diskette = null
	var/list/delayed_action = null

	var/can_use_scanner = FALSE
	var/is_viable_occupant = FALSE
	var/is_scramble_ready = FALSE
	var/obj/machinery/dna_scannernew/connected_scanner = null
	var/mob/living/carbon/scanner_occupant = null
	var/list/occupant_mutations = list()

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I, mob/user, params)
		return ..()

/obj/machinery/computer/scan_consolenew/Initialize()
	. = ..()

	connect_to_scanner()

	// Set appropriate ready timers and limits for machines functions
	injectorready = world.time + INJECTOR_TIMEOUT
	scrambleready = world.time + SCRAMBLE_TIMEOUT
	jokerready = world.time + JOKER_TIMEOUT

	// Bring the machine up to date with discovered mutations
	stored_research = SSresearch.science_tech

/obj/machinery/computer/scan_consolenew/examine(mob/user)
	. = ..()
	// Do some additional logic to state whether and when the JOKER option is available.
	if(jokerready < world.time)
		. += "<span class='notice'>JOKER algorithm available.</span>"
	else
		. += "<span class='notice'>JOKER algorithm available in about [round(0.00166666667 * (jokerready - world.time))] minutes.</span>"

/obj/machinery/computer/scan_consolenew/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	. = ..()

	// Check for connected AND operational scanner.
	if(scanner_operational())
		can_use_scanner = TRUE
		// Check for a viable occupant in the scanner.
		if(can_modify_occupant())
			is_viable_occupant = TRUE
			scanner_occupant = connected_scanner.occupant
			build_mutation_list()
		else
			is_viable_occupant = FALSE
			scanner_occupant = null
	else
		can_use_scanner = FALSE
		connected_scanner = null
		is_viable_occupant = FALSE
		scanner_occupant = null

	is_scramble_ready = (scrambleready < world.time)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "scan_consolenew", name, 660, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/scan_consolenew/ui_data(mob/user)
	var/list/data = list()

	data["IsScannerConnected"] = can_use_scanner
	if(can_use_scanner)
		data["ScannerOpen"] = connected_scanner.state_open
		data["ScannerLocked"] = connected_scanner.locked

	data["IsViableSubject"] = is_viable_occupant
	if(is_viable_occupant)
		data["SubjectName"] = scanner_occupant.name
		data["SubjectStatus"] = scanner_occupant.stat
		data["SubjectHealth"] = scanner_occupant.health
		data["SubjectRads"] = scanner_occupant.radiation/(RAD_MOB_SAFE/100)
		data["SubjectEnzymes"] = scanner_occupant.dna.unique_enzymes
		data["SubjectMutations"] = occupant_mutations
	else
		data["SubjectName"] = null
		data["SubjectStatus"] = null
		data["SubjectHealth"] = null
		data["SubjectRads"] = null
		data["SubjectEnzymes"] = null
		data["SubjectMutations"] = null

	data["IsScrambleReady"] = is_scramble_ready

	data["CONSCIOUS"] = CONSCIOUS
	data["UNCONSCIOUS"] = UNCONSCIOUS
	data["GENES"] = genes
	data["REVERSEGENES"] = reversegenes

	return data

/obj/machinery/computer/scan_consolenew/ui_act(action, params)
	//to_chat(usr,"<span class'notice'>DEBUG: Called ui_act to [action]</span>")
	if(..())
		return

	add_fingerprint(usr)
	usr.set_machine(src)

	switch(action)
		if("connect_scanner")
			connect_to_scanner()
		if("toggle_door")
			if(scanner_operational())
				connected_scanner.toggle_open(usr)
		if("toggle_lock")
			if(scanner_operational())
				connected_scanner.locked = !connected_scanner.locked
		if("scramble_dna")
			if(can_modify_occupant() && (scrambleready < world.time))
				scanner_occupant.dna.remove_all_mutations(list(MUT_NORMAL, MUT_EXTRA))
				scanner_occupant.dna.generate_dna_blocks()
				scrambleready = world.time + SCRAMBLE_TIMEOUT
				to_chat(usr,"<span class'notice'>DNA scrambled.</span>")
				scanner_occupant.radiation += RADIATION_STRENGTH_MULTIPLIER*50/(connected_scanner.damage_coeff ** 2)
		if("checkdisc")
			if(!scanner_operational() || !(scanner_occupant == connected_scanner.occupant) || !can_modify_occupant())
				return
			check_discovery(params["alias"])
		if("pulsegene") // params.pos and params.gene and params.alias
			// Check for cheese
			if(!scanner_operational() || !(scanner_occupant == connected_scanner.occupant) || !can_modify_occupant())
				return

			// Resolve mutation path
			var/alias = params["alias"]
			var/path = GET_MUTATION_TYPE_FROM_ALIAS(alias)

			// Make sure the person still has this mutation
			if(!(path in scanner_occupant.dna.mutation_index))
				return

			// Resolve path to genome sequence of scanner occupant
			var/sequence = GET_GENE_STRING(path, scanner_occupant.dna)
			var/newgene = params["gene"]
			var/genepos = text2num(params["pos"])

			// Copy genome into scanner occupant and do some basic mutation checks as we've increased rads
			sequence = copytext_char(sequence, 1, genepos) + newgene + copytext_char(sequence, genepos + 1)
			scanner_occupant.dna.mutation_index[path] = sequence
			scanner_occupant.radiation += RADIATION_STRENGTH_MULTIPLIER/connected_scanner.damage_coeff
			scanner_occupant.domutcheck()

			// Check if we cracked a new mutation
			check_discovery(alias)
		if("DEBUG")
			to_chat(usr,"<span class'notice'>DEBUG: --------</span>")
			for(var/i in params)
				to_chat(usr,"<span class'notice'>DEBUG: [i] = [params[i]]</span>")

	return TRUE


// Simple helper proc
// Checks if there is a connected DNA Scanner that is operational
/obj/machinery/computer/scan_consolenew/proc/scanner_operational()
	if(!connected_scanner)
		return FALSE

	return (connected_scanner && connected_scanner.is_operational())

// Simple helper proc
// Checks if there is a valid subject in the DNA Scanner that can be genetically modified
// Requires that the scanner can be operated and will return early if it can't be
/obj/machinery/computer/scan_consolenew/proc/can_modify_occupant()
	if(!scanner_operational() || !connected_scanner.occupant)
		return FALSE

	var/mob/living/carbon/test_occupant = connected_scanner.occupant

		// Check validity of occupent for DNA Modification
		// DNA Modification:
		//   requires DNA
		//	   this DNA can not be bad
		//   is done via radiation bursts, so radiation immune carbons are not viable
		// And the DNA Scanner itself must have a valid scan level
	if(test_occupant.has_dna() && !HAS_TRAIT(test_occupant, TRAIT_RADIMMUNE) && !HAS_TRAIT(test_occupant, TRAIT_BADDNA) || (connected_scanner.scan_level == 3))
		return TRUE

	return FALSE

// Simple helper proc
// Checks for adjacent DNA scanners and connects when it finds a viable one
/obj/machinery/computer/scan_consolenew/proc/connect_to_scanner()
	var/obj/machinery/dna_scannernew/test_scanner = null
	var/obj/machinery/dna_scannernew/broken_scanner = null

	// Look in each cardinal direction and try and find a DNA Scanner
	//   If you find a DNA Scanner, check to see if it broken or working
	//   If it's working, set the current scanner and return early
	//   If it's not working, remember it anyway as a broken scanner
	for(var/direction in GLOB.cardinals)
		test_scanner = locate(/obj/machinery/dna_scannernew, get_step(src, direction))
		if(!isnull(test_scanner))
			if(test_scanner.is_operational())
				connected_scanner = test_scanner
				return
			else
				broken_scanner = test_scanner

	// Ultimately, if we have a broken scanner, we'll attempt to connect to it as
	// a fallback case, but the code above will prefer a working scanner
	if(!isnull(broken_scanner))
		connected_scanner = broken_scanner

// Called by DNA Scanners when they close
/obj/machinery/computer/scan_consolenew/proc/on_scanner_close()
	if(can_modify_occupant())
		to_chat(connected_scanner.occupant, "<span class='notice'>[src] activates!</span>")

/obj/machinery/computer/scan_consolenew/proc/build_mutation_list()
	if(!can_modify_occupant())
		occupant_mutations = null
		return

	if(occupant_mutations)
		occupant_mutations.Cut()
	else
		occupant_mutations = list()

	for(var/mutation_type in scanner_occupant.dna.mutation_index)
		var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation_type)

		var/list/mutation_data = list()
		var/text_sequence = scanner_occupant.dna.mutation_index[mutation_type]
		var/list/list_sequence = list()

		for(var/i in 1 to LAZYLEN(text_sequence))
			list_sequence += text_sequence[i];

		var/mutation_index = scanner_occupant.dna.mutation_index.Find(mutation_type)

		mutation_data["Type"] = HM.type
		mutation_data["Name"] = HM.name
		mutation_data["Alias"] = HM.alias
		mutation_data["Sequence"] = text_sequence
		mutation_data["SeqList"] = list_sequence
		mutation_data["Description"] = HM.desc
		mutation_data["Instability"] = HM.instability
		mutation_data["Discovered"] = (stored_research && (mutation_type in stored_research.discovered_mutations))

		var/datum/mutation/human/A = scanner_occupant.dna.get_mutation(mutation_type)
		if(A)
			mutation_data["Active"] = TRUE
			mutation_data["Scrambled"] = A.scrambled
		else
			mutation_data["Active"] = FALSE
			mutation_data["Scrambled"] = FALSE

		if(mutation_index > DNA_MUTATION_BLOCKS)
			mutation_data["Image"] = "dna_extra.gif"
		else if(stored_research && (mutation_type in stored_research.discovered_mutations))
			mutation_data["Image"] = "dna_discovered.gif"
		else
			mutation_data["Image"] = "dna_undiscovered.gif"

		occupant_mutations["[mutation_index]"] = mutation_data

/obj/machinery/computer/scan_consolenew/proc/check_discovery(alias)
	if(!scanner_operational() || !(scanner_occupant == connected_scanner.occupant) || !can_modify_occupant())
		return

	var/path = GET_MUTATION_TYPE_FROM_ALIAS(alias)
	var/datum/mutation/human/M = scanner_occupant.dna.get_mutation(path)
	if(!M)
		return FALSE
	if(M.scrambled)
		return FALSE
	if(stored_research && !(path in stored_research.discovered_mutations))
		stored_research.discovered_mutations += path
		return TRUE

	return FALSE

/////////////////////////// DNA MACHINES
#undef INJECTOR_TIMEOUT
#undef NUMBER_OF_BUFFERS

#undef RADIATION_STRENGTH_MAX
#undef RADIATION_STRENGTH_MULTIPLIER

#undef RADIATION_DURATION_MAX
#undef RADIATION_ACCURACY_MULTIPLIER

#undef RADIATION_IRRADIATION_MULTIPLIER

#undef SCANNER_ACTION_SE
#undef SCANNER_ACTION_UI
#undef SCANNER_ACTION_UE
#undef SCANNER_ACTION_MIXED

//#undef BAD_MUTATION_DIFFICULTY
//#undef GOOD_MUTATION_DIFFICULTY
//#undef OP_MUTATION_DIFFICULTY
