/// Base timeout for creating mutation activators
#define MIN_ACTIVATOR_TIMEOUT 5 SECONDS
/// Base cooldown multiplier for activator upgrades
#define ACTIVATOR_COOLDOWN_MULTIPLIER 0.25
/// Base timeout for creating mutation injectors
#define MIN_INJECTOR_TIMEOUT 10 SECONDS
/// Base cooldown multiplier for injecotr upgrades
#define INJECTOR_COOLDOWN_MULTIPLIER 0.15

/// Base timeout for creating advanced injectors
#define MIN_ADVANCED_TIMEOUT 15 SECONDS
/// Base cooldown multiplier for advanced injector upgrades
#define ADVANCED_COOLDOWN_MULTIPLIER 0.1

/// Used for other things like UI/UE/Initial CD
#define MISC_INJECTOR_TIMEOUT 60 SECONDS

/// Maximum number of genetic makeup storage slots in DNA Console
#define NUMBER_OF_BUFFERS 3
/// Timeout for DNA Scramble in DNA Consoles
#define SCRAMBLE_TIMEOUT 600
/// Timeout for using the Joker feature to solve a gene in DNA Console
#define JOKER_TIMEOUT 12000
/// How much time DNA Scanner upgrade tiers remove from JOKER_TIMEOUT
#define JOKER_UPGRADE 3000

/// Maximum value for genetic damage strength when pulsing enzymes
#define GENETIC_DAMAGE_STRENGTH_MAX 15
/// Larger multipliers will affect the range of values when pulsing enzymes
#define GENETIC_DAMAGE_STRENGTH_MULTIPLIER 1

/// Maximum value for the genetic damage pulse duration when pulsing enzymes
#define GENETIC_DAMAGE_DURATION_MAX 30
/// Large values reduce pulse accuracy and may pulse other enzymes than selected
#define GENETIC_DAMAGE_ACCURACY_MULTIPLIER 3

/// Special status indicating a scanner occupant is transforming eg. from monkey to human
#define STATUS_TRANSFORMING 4

/// Multiplier for how much genetic damage received from DNA Console functionality
#define GENETIC_DAMAGE_IRGENETIC_DAMAGE_MULTIPLIER 1

/// Flag for the mutation ref search system. Search will include scanner occupant
#define SEARCH_OCCUPANT 1
/// Flag for the mutation ref search system. Search will include console storage
#define SEARCH_STORED 2
/// Flag for the mutation ref search system. Search will include diskette storage
#define SEARCH_DISKETTE 4
/// Flag for the mutation ref search system. Search will include advanced injector mutations
#define SEARCH_ADV_INJ 8

/// The base cooldown of the ability to copy enzymes and genetic makeup to people.
#define ENZYME_COPY_BASE_COOLDOWN (60 SECONDS)

#define GENETIC_DAMAGE_PULSE_UNIQUE_IDENTITY "ui"
#define GENETIC_DAMAGE_PULSE_UNIQUE_FEATURES "uf"

/// Input from tgui interface. X the gene out.
#define CLEAR_GENE 0
/// Input from tgui interface. Progress to the next gene.
#define NEXT_GENE 1
/// Input from tgui interface. Progress to previous gene.
#define PREV_GENE 2

/obj/machinery/computer/scan_consolenew
	name = "DNA Console"
	desc = "From here you can research mysteries of the DNA!"
	icon_screen = "dna"
	icon_keyboard = "med_key"
	density = TRUE
	circuit = /obj/item/circuitboard/computer/scan_consolenew
	interaction_flags_click = ALLOW_SILICON_REACH
	light_color = LIGHT_COLOR_BLUE

	/// Link to the techweb's stored research. Used to retrieve stored mutations
	var/datum/techweb/stored_research
	/// Duration for enzyme genetic damage pulses
	var/pulse_duration = 2
	/// Strength for enzyme genetic damage pulses
	var/pulse_strength = 1
	/// Maximum number of enzymes we can store
	var/list/genetic_makeup_buffer[NUMBER_OF_BUFFERS]
	/// List of all mutations stored on the DNA Console
	var/list/stored_mutations = list()
	/// List of all chromosomes stored in the DNA Console
	var/list/stored_chromosomes = list()
	/// Assoc list of all advanced injectors. Keys are injector names. Values are lists of mutations.
	var/list/list/injector_selection = list()
	/// Maximum number of advanced injectors that DNA Consoles store
	var/max_injector_selections = 2
	/// Maximum number of mutation that an advanced injector can store
	var/max_injector_mutations = 10
	/// Maximum total instability of all combined mutations allowed on an advanced injector
	var/max_injector_instability = 50

	/// World time when injectors are ready to be printed
	var/injector_ready = 0
	/// World time when JOKER algorithm can be used in DNA Consoles
	var/joker_ready = 0
	/// World time when Scramble can be used in DNA Consoles
	var/scramble_ready = 0

	/// Currently stored genetic data diskette
	var/obj/item/disk/data/diskette = null

	/// Current delayed action, used for delayed enzyme transfer on scanner door close
	var/list/delayed_action = null

	/// Index of the enzyme being modified during delayed enzyme pulse operations
	var/genetic_damage_pulse_index = 0
	/// World time when the enzyme pulse should complete
	var/genetic_damage_pulse_timer = 0
	/// Which dna string to edit with the pulse
	var/genetic_damage_pulse_type
	/// Cooldown for the genetic makeup transfer actions.
	COOLDOWN_DECLARE(enzyme_copy_timer)

	/// Used for setting tgui data - Whether the connected DNA Scanner is usable
	var/can_use_scanner = FALSE
	/// Used for setting tgui data - Whether the current DNA Scanner occupant is viable for genetic modification
	var/is_viable_occupant = FALSE
	/// Used for setting tgui data - Whether Scramble DNA is ready
	var/is_scramble_ready = FALSE
	/// Used for setting tgui data - Whether JOKER algorithm is ready
	var/is_joker_ready = FALSE
	/// Used for setting tgui data - Whether injectors are ready to be printed
	var/is_injector_ready = FALSE
	/// Used for setting tgui data - Is CRISPR ready?
	var/is_crispr_ready = FALSE
	/// Used for setting tgui data - Wheher an enzyme pulse operation is ongoing
	var/is_pulsing = FALSE
	/// Used for setting tgui data - Time until scramble is ready
	var/time_to_scramble = 0
	/// Used for setting tgui data - Time until joker is ready
	var/time_to_joker = 0
	/// Used for setting tgui data - Time until injectors are ready
	var/time_to_injector = 0
	/// Used for setting tgui data - Time until the enzyme pulse is complete
	var/time_to_pulse = 0

	/// Currently connected DNA Scanner
	var/obj/machinery/dna_scannernew/connected_scanner = null
	/// Current DNA Scanner occupant
	var/mob/living/carbon/scanner_occupant = null

	/// Used for setting tgui data - List of occupant mutations
	var/list/tgui_occupant_mutations = list()
	/// Used for setting tgui data - List of DNA Console stored mutations
	var/list/tgui_console_mutations = list()
	/// Used for setting tgui data - List of diskette stored mutations
	var/list/tgui_diskette_mutations = list()
	/// Used for setting tgui data - List of DNA Console chromosomes
	var/list/tgui_console_chromosomes = list()
	/// Used for setting tgui data - List of occupant mutations
	var/list/tgui_genetic_makeup = list()
	/// Used for setting tgui data - List of occupant mutations
	var/list/tgui_advinjector_mutations = list()


	/// State of tgui view, i.e. which tab is currently active, or which genome we're currently looking at.
	var/list/list/tgui_view_state = list()

	///Counter for CRISPR charges
	var/crispr_charges = 0

/obj/machinery/computer/scan_consolenew/process()
	. = ..()

	// This is for pulsing the UI element with genetic damage as part of genetic makeup
	// If genetic_damage_pulse_index > 0 then it means we're attempting a pulse
	if((genetic_damage_pulse_index > 0) && (genetic_damage_pulse_timer <= world.time) && (genetic_damage_pulse_type == GENETIC_DAMAGE_PULSE_UNIQUE_IDENTITY || genetic_damage_pulse_type == GENETIC_DAMAGE_PULSE_UNIQUE_FEATURES))
		genetic_damage_pulse()
		return

/obj/machinery/computer/scan_consolenew/attackby(obj/item/item, mob/user, params)
	// Store chromosomes in the console if there's room
	if (istype(item, /obj/item/chromosome))
		item.forceMove(src)
		stored_chromosomes += item
		to_chat(user, span_notice("You insert [item]."))
		return

	// Insert data disk if console disk slot is empty
	// Swap data disk if there is one already a disk in the console
	if (istype(item, /obj/item/disk/data)) //INSERT SOME DISKETTES
		// Insert disk into DNA Console
		if (!user.transferItemToLoc(item,src))
			return
		// If insertion was successful and there's already a diskette in the console, eject the old one.
		if(diskette)
			eject_disk(user)
		// Set the new diskette.
		diskette = item
		to_chat(user, span_notice("You insert [item]."))
		return

	// Recycle non-activator used injectors
	// Turn activator used injectors (aka research injectors) to chromosomes
	if(istype(item, /obj/item/dnainjector/activator))
		var/obj/item/dnainjector/activator/activator = item
		if(activator.used)
			if(activator.research && activator.filled)
				if(prob(60))
					var/c_typepath = generate_chromosome()
					var/obj/item/chromosome/CM = new c_typepath (src)
					stored_chromosomes += CM
					to_chat(user,span_notice("[capitalize(CM.name)] added to storage."))
				else
					to_chat(user, span_notice("There was not enough genetic data to extract a viable chromosome."))
			if(activator.crispr_charge)
				crispr_charges++
				to_chat(user, span_notice("CRISPR charge added."))
			qdel(item)
			to_chat(user,span_notice("Recycled [item]."))
			return
		else
			//recycle unused activators
			qdel(item)
			to_chat(user, span_notice("Recycled unused [item]."))
			return
	return ..()

/obj/machinery/computer/scan_consolenew/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		stored_research = tool.buffer
	return TRUE

/obj/machinery/computer/scan_consolenew/click_alt(mob/user)
	eject_disk(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/computer/scan_consolenew/Initialize(mapload)
	. = ..()

	// Connect with a nearby DNA Scanner on init
	connect_to_scanner()

	// Set appropriate ready timers and limits for machines functions
	injector_ready = world.time + MISC_INJECTOR_TIMEOUT
	scramble_ready = world.time + SCRAMBLE_TIMEOUT
	joker_ready = world.time + JOKER_TIMEOUT
	COOLDOWN_START(src, enzyme_copy_timer, ENZYME_COPY_BASE_COOLDOWN)

	// Set the default tgui state
	set_default_state()

/obj/machinery/computer/scan_consolenew/post_machine_initialize()
	. = ..()
	// Link machine with research techweb. Used for discovering and accessing
	// already discovered mutations
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)


/obj/machinery/computer/scan_consolenew/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	// Most of ui_interact is spent setting variables for passing to the tgui
	//  interface.
	// We can also do some general state processing here too as it's a good
	//  indication that a player is using the console.

	var/scanner_op = scanner_operational()
	var/can_modify_occ = can_modify_occupant()

	// Check for connected AND operational scanner.
	if(scanner_op)
		can_use_scanner = TRUE
	else
		can_use_scanner = FALSE
		set_connected_scanner(null)
		is_viable_occupant = FALSE

	// Check for a viable occupant in the scanner.
	if(can_modify_occ)
		is_viable_occupant = TRUE
	else
		is_viable_occupant = FALSE


	// Populates various buffers for passing to tgui
	build_mutation_list(can_modify_occ)
	build_genetic_makeup_list()

	// Populate variables for passing to tgui interface
	is_scramble_ready = (scramble_ready < world.time)
	time_to_scramble = round((scramble_ready - world.time)/10)

	is_joker_ready = (joker_ready < world.time)
	time_to_joker = round((joker_ready - world.time)/10)

	is_injector_ready = (injector_ready < world.time)
	time_to_injector = round((injector_ready - world.time)/10)

	is_pulsing = ((genetic_damage_pulse_index > 0) && (genetic_damage_pulse_timer > world.time))
	time_to_pulse = round((genetic_damage_pulse_timer - world.time)/10)

	is_crispr_ready = (crispr_charges > 0)

	// Attempt to update tgui ui, open and update if needed.
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DnaConsole")
		ui.open()

/obj/machinery/computer/scan_consolenew/ui_assets()
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/genetics)

/obj/machinery/computer/scan_consolenew/ui_data(mob/user)
	var/list/data = list()

	data["view"] = tgui_view_state
	data["storage"] = list()

	// This block of code generates the huge data structure passed to the tgui
	// interface for displaying all the various bits of console/scanner data
	// Should all be very self-explanatory
	data["isScannerConnected"] = can_use_scanner
	if(can_use_scanner)
		data["scannerOpen"] = connected_scanner.state_open
		data["scannerLocked"] = connected_scanner.locked
		data["pulseStrength"] = pulse_strength
		data["pulseDuration"] = pulse_duration
		data["stdDevStr"] = pulse_strength * GENETIC_DAMAGE_STRENGTH_MULTIPLIER
		switch(GENETIC_DAMAGE_ACCURACY_MULTIPLIER / (pulse_duration + (connected_scanner.precision_coeff ** 2))) //hardcoded values from a z-table for a normal distribution
			if(0 to 0.25)
				data["stdDevAcc"] = ">95 %"
			if(0.25 to 0.5)
				data["stdDevAcc"] = "68-95 %"
			if(0.5 to 0.75)
				data["stdDevAcc"] = "55-68 %"
			else
				data["stdDevAcc"] = "<38 %"

	data["isViableSubject"] = is_viable_occupant
	if(is_viable_occupant)
		data["subjectName"] = scanner_occupant.name
		if(scanner_occupant.transformation_timer)
			data["subjectStatus"] = STATUS_TRANSFORMING
		else
			data["subjectStatus"] = scanner_occupant.stat
		data["subjectHealth"] = scanner_occupant.health
		data["subjectEnzymes"] = scanner_occupant.dna.unique_enzymes
		data["isMonkey"] = ismonkey(scanner_occupant)
		data["subjectUNI"] = scanner_occupant.dna.unique_identity
		data["subjectUF"] = scanner_occupant.dna.unique_features
		data["storage"]["occupant"] = tgui_occupant_mutations

		var/datum/status_effect/genetic_damage/genetic_damage = scanner_occupant.has_status_effect(/datum/status_effect/genetic_damage)
		data["subjectDamage"] = genetic_damage ? round((genetic_damage.total_damage / genetic_damage.minimum_before_tox_damage) * 100, 0.1) : 0
	else
		data["subjectName"] = null
		data["subjectStatus"] = null
		data["subjectHealth"] = null
		data["subjectDamage"] = null
		data["subjectEnzymes"] = null
		data["storage"]["occupant"] = null

	data["hasDelayedAction"] = (delayed_action != null)
	data["isScrambleReady"] = is_scramble_ready
	data["isJokerReady"] = is_joker_ready
	data["isInjectorReady"] = is_injector_ready
	data["isCrisprReady"] = is_crispr_ready
	data["crisprCharges"] = crispr_charges
	data["scrambleSeconds"] = time_to_scramble
	data["jokerSeconds"] = time_to_joker
	data["injectorSeconds"] = time_to_injector
	data["isPulsing"] = is_pulsing
	data["timeToPulse"] = time_to_pulse
	data["geneticMakeupCooldown"] = COOLDOWN_TIMELEFT(src, enzyme_copy_timer) / 10

	if(diskette != null)
		data["hasDisk"] = TRUE
		data["diskCapacity"] = diskette.max_mutations - LAZYLEN(diskette.mutations)
		data["diskReadOnly"] = diskette.read_only
		//data["diskMutations"] = tgui_diskette_mutations
		data["storage"]["disk"] = tgui_diskette_mutations
		data["diskHasMakeup"] = (LAZYLEN(diskette.genetic_makeup_buffer) > 0)
		data["diskMakeupBuffer"] = diskette.genetic_makeup_buffer.Copy()
	else
		data["hasDisk"] = FALSE
		data["diskCapacity"] = 0
		data["diskReadOnly"] = TRUE
		//data["diskMutations"] = null
		data["storage"]["disk"] = null
		data["diskHasMakeup"] = FALSE
		data["diskMakeupBuffer"] = null

	//data["mutationStorage"] = tgui_console_mutations
	data["storage"]["console"] = tgui_console_mutations
	data["chromoStorage"] = tgui_console_chromosomes
	data["makeupCapacity"] = NUMBER_OF_BUFFERS
	data["makeupStorage"] = tgui_genetic_makeup

	//data["advInjectors"] = tgui_advinjector_mutations
	data["storage"]["injector"] = tgui_advinjector_mutations
	data["maxAdvInjectors"] = max_injector_selections

	return data

/obj/machinery/computer/scan_consolenew/ui_act(action, list/params)
	var/static/list/gene_letters = list("A", "T", "C", "G");
	var/static/gene_letter_count = length(gene_letters)

	. = ..()
	if(.)
		return

	. = TRUE

	add_fingerprint(usr)

	switch(action)
		// Connect this DNA Console to a nearby DNA Scanner
		// Usually only activate as an option if there is no connected scanner
		if("connect_scanner")
			connect_to_scanner()
			return

		// Toggle the door open/closed status on attached DNA Scanner
		if("toggle_door")
			// GUARD CHECK - Scanner still connected and operational?
			if(!scanner_operational())
				return

			connected_scanner.toggle_open(usr)
			return

		// Toggle the door bolts on the attached DNA Scanner
		if("toggle_lock")
			// GUARD CHECK - Scanner still connected and operational?
			if(!scanner_operational())
				return

			connected_scanner.locked = !connected_scanner.locked
			return

		// Scramble scanner occupant's DNA
		if("scramble_dna")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			// GUARD CHECK - Is scramble DNA actually ready?
			if(!can_modify_occupant() || !(scramble_ready < world.time))
				return

			scanner_occupant.dna.remove_all_mutations(list(MUT_NORMAL, MUT_EXTRA))
			scanner_occupant.dna.generate_dna_blocks()
			scramble_ready = world.time + SCRAMBLE_TIMEOUT
			to_chat(usr,span_notice("DNA scrambled."))
			scanner_occupant.apply_status_effect(/datum/status_effect/genetic_damage, GENETIC_DAMAGE_STRENGTH_MULTIPLIER*50/(connected_scanner.damage_coeff ** 2))
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Check whether a specific mutation is eligible for discovery within the
		//  scanner occupant
		// This is additionally done when a mutation's tab is selected in the tgui
		//  interface. This is because some mutations, such as Monkified on monkeys,
		//  are infact completed by default but not yet discovered. Likewise, all
		//  mutations can have their sequence completed while Monkified is still an
		//  active mutation and thus won't immediately be discovered but could be
		//  discovered when Monkified is removed
		// ---------------------------------------------------------------------- //
		// params["alias"] - Alias of a mutation. The alias is the "hidden" name of
		//                   the mutation, for example "Mutation 5" or "Mutation 33"
		if("check_discovery")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			// GUARD CHECK - Have we somehow cheekily swapped occupants? This is
			//  unexpected.
			if(!(scanner_occupant == connected_scanner.occupant))
				return

			check_discovery(params["alias"])
			return

		// Check all mutations of the occupant and check if any are discovered.
		// This is called when the Genetic Sequencer is selected. It'll do things
		//  like immediately discover Monkified without needing to click through
		//  the mutation tabs and handle cases where mutations are solved but not
		//  discovered due to the Monkified mutation being active then removed.
		if("all_check_discovery")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			// GUARD CHECK - Have we somehow cheekily swapped occupants? This is
			//  unexpected.
			if(!(scanner_occupant == connected_scanner.occupant))
				return

			// Go over all standard mutations and check if they've been discovered.
			for(var/mutation_type in scanner_occupant.dna.mutation_index)
				var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation_type)
				check_discovery(HM.alias)

			return

		// Set a gene in a mutation's genetic sequence. Will also check for mutations
		//  discovery as part of the process.
		// ---------------------------------------------------------------------- //
		// params["alias"] - Alias of a mutation. The alias is the "hidden" name of
		//  the mutation, for example "Mutation 5" or "Mutation 33"
		// params["pulseAction"] - The action to perform on this gene.
		// params["pos"] - The BYOND index of the letter in the gene sequence to be
		//  changed.
		if("pulse_gene")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			// GUARD CHECK - Have we somehow cheekily swapped occupants? This is
			//  unexpected.
			if(!(scanner_occupant == connected_scanner.occupant))
				return

			// GUARD CHECK - Is the occupant currently undergoing some form of
			//  transformation? If so, we don't want to be pulsing genes.
			if(scanner_occupant.transformation_timer)
				to_chat(usr,span_warning("Gene pulse failed: The scanner occupant undergoing a transformation."))
				return

			// Resolve mutation's BYOND path from the alias
			var/alias = params["alias"]
			var/path = GET_MUTATION_TYPE_FROM_ALIAS(alias)

			// Make sure the occupant still has this mutation
			if(!(path in scanner_occupant.dna.mutation_index))
				return

			// Resolve BYOND path to genome sequence of scanner occupant
			var/sequence = GET_GENE_STRING(path, scanner_occupant.dna)

			var/newgene
			var/pulse_action = params["pulseAction"]
			var/genepos = text2num(params["pos"])

			if(genepos > length(sequence))
				CRASH("Unexpected input for \[\"pos\"\] param sent to [type] tgui interface. Consult tgui logs for error.")

			switch(pulse_action)
				// X out the gene.
				if(CLEAR_GENE)
					newgene = "X"
					var/defaultseq = scanner_occupant.dna.default_mutation_genes[path]
					scanner_occupant.dna.default_mutation_genes[path] = copytext(defaultseq, 1, genepos) + "X" + copytext(defaultseq, genepos + 1)
				// Either try to apply a joker if selected in the interface, or iterate the next gene.
				if(NEXT_GENE)
					if((tgui_view_state["jokerActive"]) && (joker_ready < world.time))
						var/truegenes = GET_SEQUENCE(path)
						newgene = truegenes[genepos]
						joker_ready = world.time + JOKER_TIMEOUT - (JOKER_UPGRADE * (connected_scanner.precision_coeff-1))
						tgui_view_state["jokerActive"] = FALSE
					else
						var/current_letter = gene_letters.Find(sequence[genepos])
						newgene = (current_letter == gene_letter_count) ? gene_letters[1] : gene_letters[current_letter + 1]
				// Iterate previous gene.
				if(PREV_GENE)
					var/current_letter = gene_letters.Find(sequence[genepos]) || 1
					newgene = (current_letter == 1) ? gene_letters[gene_letter_count] : gene_letters[current_letter - 1]
				// Unknown input.
				else
					CRASH("Unexpected input for \[\"pulseAction\"\] param sent to [type] tgui interface. Consult tgui logs for error.")

			// Copy genome to scanner occupant and do some basic mutation checks as
			//  we've increased the occupant genetic damage
			scanner_occupant.dna.mutation_index[path] = copytext(sequence, 1, genepos) + newgene + copytext(sequence, genepos + 1)
			scanner_occupant.apply_status_effect(/datum/status_effect/genetic_damage, GENETIC_DAMAGE_STRENGTH_MULTIPLIER/connected_scanner.damage_coeff)
			scanner_occupant.domutcheck()

			// GUARD CHECK - Modifying genetics can lead to edge cases where the
			//  scanner occupant is qdel'd and replaced with a different entity.
			//  Examples of this include adding/removing the Monkified mutation which
			//  qdels the previous entity and creates a brand new one in its place.
			// We should redo all of our occupant modification checks again, although
			//  it is less than ideal.
			if(!can_modify_occupant())
				return

			// Check if we cracked a mutation
			check_discovery(alias)
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Apply a chromosome to a specific mutation.
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to apply the chromo to
		// params["chromo"] - Name of the chromosome to apply to the mutation
		if("apply_chromo")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			// GUARD CHECK - Have we somehow cheekily swapped occupants? This is
			//  unexpected.
			if(!(scanner_occupant == connected_scanner.occupant))
				return

			var/bref = params["mutref"]

			// GUARD CHECK - Only search occupant for this specific ref, since your
			//  can only apply chromosomes to mutations occupants.
			var/datum/mutation/human/HM = get_mut_by_ref(bref, SEARCH_OCCUPANT)

			// GUARD CHECK - This should not be possible. Unexpected result
			if(!HM)
				return

			// Look through our stored chromos and compare names to find a
			// stored chromo we can apply.
			for(var/obj/item/chromosome/CM in stored_chromosomes)
				if(CM.can_apply(HM) && (CM.name == params["chromo"]))
					stored_chromosomes -= CM
					CM.apply(HM)
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Attempt overwriting Base DNA : The pairs are instead the top row vs the top row of the new code.
		// So AA means the AT pair stays the same, AT means AT becomes TA. This requires both knowing the
		// solved full DNA of the subject mutation and the full DNA of the replacement genes. Applies probable disease
		// of probable strengths as well. If you mess it up, you might end up getting undesirable genes, including
		// unstable DNA. This could lead to permanent monkey. When you get it right, some will be swapped out, on a
		// probability scale.
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to swap out
		// params["source"] - The source the request came from.
		// Expected results:
		//   "occupant" - From genetic sequencer
		//   "console" - From DNA Console storage
		//   "disk" - From inserted diskette
		if("crispr")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			// GUARD CHECK - Have we somehow cheekily swapped occupants? This is
			//  unexpected.
			if(scanner_occupant != connected_scanner.occupant)
				return

			//GUARD CHECK
			//Make sure there's charges available.
			if(crispr_charges < 1)
				return
			var/search_flags = 0

			// Only continue if applying to occupant - all replacements in-vitro.
			switch(params["source"])
				if("occupant")
					if(can_modify_occupant())
						search_flags |= SEARCH_OCCUPANT
				if("console")
					search_flags |= SEARCH_STORED
					return
				if("disk")
					search_flags |= SEARCH_DISKETTE
					return

			//Currently selected mutation
			var/bref = params["mutref"]

			//Valid gene-pairs
			var/at_str = "AT"
			var/cg_str = "CG"

			// GUARD CHECK - Only search occupant for this specific ref, since you
			//  can only CRISPR existing mutations in a target
			var/datum/mutation/human/target_mutation = get_mut_by_ref(bref, search_flags)

			// Prompt for modifier string
			var/new_sequence_input = tgui_input_text(usr, "Enter a replacement sequence", "Inherent Gene Replacement", 32, encode = FALSE)
			// Drop out if the string is the wrong length
			if(length(new_sequence_input) != 32)
				return

			//Generate the original and new gene sequences from the CRISPR string
			//vars to hold the 2 sequences
			var/old_sequence
			var/new_sequence

			//Unzip the modification string
			for(var/i = 1 to length(new_sequence_input))
				var/char = new_sequence_input[i]
				var/pair_str
				var/new_pair
				//figure out which pair type the character belongs to
				pair_str = ((at_str[1] == char || at_str[2] == char) ? at_str : ((cg_str[1] == char || cg_str[2] == char) ? cg_str : null))
				//Valid pair from character
				new_pair = (pair_str ? char + (pair_str[1] == char ? pair_str[2] : pair_str[1]) : null)
				// every second letter in the sequence represents a valid pair of the new sequence, otherwise it belongs to old
				if(new_pair)
					if(i%2 == 0)
						new_sequence+=new_pair
					else
						old_sequence+=new_pair
				else
					return //drop out, no pair

			//decrement CRISPR charge
			crispr_charges--

			//Apply sequence
			if(new_sequence)
				//to hold the found mutation, if found
				var/datum/mutation/human/matched_mutation = null
				//Go through all sequences for matching gene, and set the mutation
				for (var/M in subtypesof(/datum/mutation/human))
					var/true_sequence = GET_SEQUENCE(M)
					if (new_sequence == true_sequence)
						matched_mutation = M
				//First check is for the more-likely, weaker random virus. Second is for a tougher one. There's a chance both checks fail and you get nothing.
				//This change was to bring it more in line with what I originally imagined, that the virus risk was from the virus misbehaving somehow - it
				//should be a "sometimes" thing, not an "always" thing, but risky enough to force the need for precautions to isolate the subject
				if(prob(60))
					var/datum/disease/advance/random/random_disease = new /datum/disease/advance/random(2,2)
					scanner_occupant.ContactContractDisease(random_disease)
				else if (prob(30))
					var/datum/disease/advance/random/random_disease = new /datum/disease/advance/random(3,4)
					scanner_occupant.ContactContractDisease(random_disease)
				//Instantiate list to hold resulting mutation_index
				var/mutation_data[0]
				//Start with the bad mutation, overwrite with the desired mutation if it passes the check
				//assures BAD END is the natural state if things go wrong
				//I think this should be like with viruses, probability cascade or switch/case on random?
				var/result_mutation = /datum/mutation/human/acidflesh
				//If we found the replacement mutation
				if(matched_mutation)
					//and the old sequence matches the real sequence of the old mutation
					if(old_sequence == GET_SEQUENCE(target_mutation.type))
						//Set the replacement mutation to the desired mutation
						result_mutation = matched_mutation
				//Remove the current active mutations - let's say doing this triggers DNA repair or something
				//This is admittedly because I couldn't figure out how to only remove the targeted mutation
				//Not touching MUT_EXTRA will hopefully leave the added mutations alone
				scanner_occupant.dna.remove_all_mutations(list(MUT_NORMAL))
				//Add the resulting mutation to the active mutations
				scanner_occupant.dna.add_mutation(result_mutation,MUT_NORMAL, 0)
				//Rebuild the mutation_index into mutation_data, replacing the sequence entry with the solved
				//entry for the result mutation
				for(var/mutation_type in scanner_occupant.dna.mutation_index)
					if(mutation_type == target_mutation.type)
						mutation_data[result_mutation] = new_sequence
					else
						mutation_data[mutation_type]=scanner_occupant.dna.mutation_index[mutation_type]
				//Overwrite the mutation_index list with the rebuild mutation_data
				scanner_occupant.dna.mutation_index = mutation_data
				//Not sure what this does but it seems to be a sanity check and this needs a sanity check
				scanner_occupant.domutcheck()

			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)

			return


		// Print any type of standard injector, limited right now to activators that
		//  activate a dormant mutation and mutators that forcibly create a new
		//  MUT_EXTRA mutation
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to create an injector of
		// params["is_activator"] - Is this an "Activator" style injector, also
		//  referred to as a "Research" type. Expects a string with 0 or 1, which
		//  then gets converted to a number.
		// params["source"] - The source the request came from.
		// Expected results:
		//   "occupant" - From genetic sequencer
		//   "console" - From DNA Console storage
		//   "disk" - From inserted diskette
		if("print_injector")
			// Because printing mutators and activators share a bunch of code,
			//  it makes sense to keep them both together and set unique vars
			//  later in the code

			// As a side note, because mutations can contain unique metadata,
			//  this system uses BYOND Atom Refs to safely and accurately
			//  identify mutations from big ol' lists

			// GUARD CHECK - Is the injector actually ready?
			if(world.time < injector_ready)
				return

			var/search_flags = 0

			switch(params["source"])
				if("occupant")
					// GUARD CHECK - Make sure we can modify the occupant before we
					//  attempt to search them for any given mutation refs. This could
					//  lead to no search flags being passed to get_mut_by_ref and this
					//  is intended functionality to prevent any cheese or abuse
					if(can_modify_occupant())
						search_flags |= SEARCH_OCCUPANT
				if("console")
					search_flags |= SEARCH_STORED
				if("disk")
					search_flags |= SEARCH_DISKETTE

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref, search_flags)

			// GUARD CHECK - This should not be possible. Unexpected result
			if(!HM)
				return

			// Create a new DNA Injector and add the appropriate mutations to it
			var/obj/item/dnainjector/activator/I = new /obj/item/dnainjector/activator(loc)
			I.add_mutations += new HM.type(copymut = HM)

			var/is_activator = text2num(params["is_activator"])

			// Activators are also called "research" injectors and are used to create
			//  chromosomes by recycling at the DNA Console
			if(is_activator)
				I.name = "[HM.name] activator"
				I.research = TRUE
				// If there's an operational connected scanner, we can use its upgrades
				//  to improve our injector's genetic damage generation
				var/cd_reduction_mult = 1 + ACTIVATOR_COOLDOWN_MULTIPLIER
				var/base_cd_time = max(MIN_ACTIVATOR_TIMEOUT, abs(HM.instability) SECONDS)

				if(scanner_operational())
					I.damage_coeff = connected_scanner.damage_coeff*4
					// T1: 1.25 - 0.25: 1: 100%
					// T4: 1.25 - 1: 0.25 = 25%
					// 25% reduction per tier
					cd_reduction_mult -= ACTIVATOR_COOLDOWN_MULTIPLIER * (connected_scanner.precision_coeff)

				injector_ready = world.time + (base_cd_time * cd_reduction_mult)
			else
				I.name = "[HM.name] mutator"
				I.force_mutate = TRUE
				// If there's an operational connected scanner, we can use its upgrades
				//  to improve our injector's genetic damage generation
				var/cd_reduction_mult = 1 + INJECTOR_COOLDOWN_MULTIPLIER
				var/base_cd_time = max(MIN_INJECTOR_TIMEOUT, abs(HM.instability) * 1 SECONDS)

				if(scanner_operational())
					I.damage_coeff = connected_scanner.damage_coeff*4
					// T1: 1.15 - 0.15: 1: 100%
					// T4: 1.15 - 0.60: 0.55: 55%
					// 15% reduction per tier
					cd_reduction_mult -= (INJECTOR_COOLDOWN_MULTIPLIER * connected_scanner.precision_coeff)

				injector_ready = world.time + (base_cd_time * cd_reduction_mult)
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Save a mutation to the console's storage buffer.
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to store
		// params["source"] - The source the request came from.
		// Expected results:
		//   "occupant" - From genetic sequencer
		//   "disk" - From inserted diskette
		if("save_console")
			var/search_flags = 0

			switch(params["source"])
				if("occupant")
					// GUARD CHECK - Make sure we can modify the occupant before we
					//  attempt to search them for any given mutation refs. This could
					//  lead to no search flags being passed to get_mut_by_ref and this
					//  is intended functionality to prevent any cheese or abuse
					if(can_modify_occupant())
						search_flags |= SEARCH_OCCUPANT
				if("disk")
					search_flags |= SEARCH_DISKETTE

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref, search_flags)

			// GUARD CHECK - This should not be possible. Unexpected result
			if(!HM)
				return

			// Saving temporary or unobtainable mutations leads to gratuitous abuse
			if(HM.class == MUT_OTHER)
				say("ERROR: This mutation is anomalous, and cannot be saved.")
				return

			var/datum/mutation/human/A = new HM.type(MUT_EXTRA, null, HM)
			stored_mutations += A
			to_chat(usr,span_notice("Mutation successfully stored."))
			return

		// Save a mutation to the diskette's storage buffer.
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to store
		// params["source"] - The source the request came from
		// Expected results:
		//   "occupant" - From genetic sequencer
		//   "console" - From DNA Console storage
		if("save_disk")
			// GUARD CHECK - This code shouldn't even be callable without a diskette
			//  inserted. Unexpected result
			if(!diskette)
				return

			// GUARD CHECK - Make sure the disk is not full
			if(LAZYLEN(diskette.mutations) >= diskette.max_mutations)
				to_chat(usr,span_warning("Disk storage is full."))
				return

			// GUARD CHECK - Make sure the disk isn't set to read only, as we're
			//  attempting to write to it
			if(diskette.read_only)
				to_chat(usr,span_warning("Disk is set to read only mode."))
				return

			var/search_flags = 0

			switch(params["source"])
				if("occupant")
					// GUARD CHECK - Make sure we can modify the occupant before we
					//  attempt to search them for any given mutation refs. This could
					//  lead to no search flags being passed to get_mut_by_ref and this
					//  is intended functionality to prevent any cheese or abuse
					if(can_modify_occupant())
						search_flags |= SEARCH_OCCUPANT
				if("console")
					search_flags |= SEARCH_STORED

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref, search_flags)

			// GUARD CHECK - This should not be possible. Unexpected result
			if(!HM)
				return

			var/datum/mutation/human/A = new HM.type(MUT_EXTRA, null, HM)
			diskette.mutations += A
			to_chat(usr,span_notice("Mutation successfully stored to disk."))
			return

		// Completely removes a MUT_EXTRA mutation or mutation with corrupt gene
		//  sequence from the scanner occupant
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to nullify
		if("nullify")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref, SEARCH_OCCUPANT)

			// GUARD CHECK - This should not be possible. Unexpected result
			if(!HM)
				return

			// GUARD CHECK - Nullify should only be used on scrambled or "extra"
			//  mutations.
			if(!HM.scrambled && !(HM.class == MUT_EXTRA))
				return

			scanner_occupant.dna.remove_mutation(HM.type)
			return

		// Deletes saved mutation from console buffer.
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to delete
		if("delete_console_mut")
			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref, SEARCH_STORED)

			if(HM)
				stored_mutations.Remove(HM)
				qdel(HM)

			return

		// Deletes saved mutation from disk buffer.
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to delete
		if("delete_disk_mut")
			// GUARD CHECK - This code shouldn't even be callable without a diskette
			//  inserted. Unexpected result
			if(!diskette)
				return

			// GUARD CHECK - Make sure the disk isn't set to read only, as we're
			//  attempting to write to it (via deletion)
			if(diskette.read_only)
				to_chat(usr,span_warning("Disk is set to read only mode."))
				return

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref, SEARCH_DISKETTE)

			if(HM)
				diskette.mutations.Remove(HM)
				qdel(HM)

			return

		// Ejects a stored chromosome from the DNA Console
		// ---------------------------------------------------------------------- //
		// params["chromo"] - Text string of the chromosome name
		if("eject_chromo")
			var/chromname = params["chromo"]

			for(var/obj/item/chromosome/CM in stored_chromosomes)
				if(chromname == CM.name)
					CM.forceMove(drop_location())
					adjust_item_drop_location(CM)
					stored_chromosomes -= CM
					return

			return

		// Combines two mutations from the console to try and create a new mutation
		// ---------------------------------------------------------------------- //
		// params["firstref"] - ATOM Ref of first mutation for combination
		// params["secondref"] - ATOM Ref of second mutation for combination
		//  mutation
		if("combine_console")
			// GUARD CHECK - We're running a research-type operation. If, for some
			//  reason, somehow the DNA Console has been disconnected from the research
			//  network - Or was never in it to begin with - don't proceed
			if(!stored_research)
				return

			var/first_bref = params["firstref"]
			var/second_bref = params["secondref"]

			// GUARD CHECK - Find the source and destination mutations on the console
			// and make sure they actually exist.
			var/datum/mutation/human/source_mut = get_mut_by_ref(first_bref, SEARCH_STORED | SEARCH_DISKETTE)
			if(!source_mut)
				return

			var/datum/mutation/human/dest_mut = get_mut_by_ref(second_bref, SEARCH_STORED | SEARCH_DISKETTE)
			if(!dest_mut)
				return

			// Attempt to mix the two mutations to get a new type
			var/result_path = get_mixed_mutation(source_mut.type, dest_mut.type)

			if(!result_path)
				return

			// If we got a new type, add it to our storage
			stored_mutations += new result_path()
			to_chat(usr, span_boldnotice("Success! New mutation has been added to console storage."))

			// If it's already discovered, end here. Otherwise, add it to the list of
			//  discovered mutations.
			// We've already checked for stored_research earlier
			if(result_path in stored_research.discovered_mutations)
				return

			var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(result_path)
			stored_research.discovered_mutations += result_path
			say("Successfully mutated [HM.name].")
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Combines two mutations from the disk to try and create a new mutation
		// ---------------------------------------------------------------------- //
		// params["firstref"] - ATOM Ref of first mutation for combination
		// params["secondref"] - ATOM Ref of second mutation for combination
		//  mutation
		if("combine_disk")
			// GUARD CHECK - This code shouldn't even be callable without a diskette
			//  inserted. Unexpected result
			if(!diskette)
				return

			// GUARD CHECK - Make sure the disk is not full.
			if(LAZYLEN(diskette.mutations) >= diskette.max_mutations)
				to_chat(usr,span_warning("Disk storage is full."))
				return

			// GUARD CHECK - Make sure the disk isn't set to read only, as we're
			//  attempting to write to it
			if(diskette.read_only)
				to_chat(usr,span_warning("Disk is set to read only mode."))
				return

			// GUARD CHECK - We're running a research-type operation. If, for some
			// reason, somehow the DNA Console has been disconnected from the research
			// network - Or was never in it to begin with - don't proceed
			if(!stored_research)
				return

			var/first_bref = params["firstref"]
			var/second_bref = params["secondref"]

			// GUARD CHECK - Find the source and destination mutations on the console
			// and make sure they actually exist.
			var/datum/mutation/human/source_mut = get_mut_by_ref(first_bref, SEARCH_STORED | SEARCH_DISKETTE)
			if(!source_mut)
				return

			var/datum/mutation/human/dest_mut = get_mut_by_ref(second_bref, SEARCH_STORED | SEARCH_DISKETTE)
			if(!dest_mut)
				return

			// Attempt to mix the two mutations to get a new type
			var/result_path = get_mixed_mutation(source_mut.type, dest_mut.type)

			if(!result_path)
				return

			// If we got a new type, add it to our storage
			diskette.mutations += new result_path()
			to_chat(usr, span_boldnotice("Success! New mutation has been added to the disk."))

			// If it's already discovered, end here. Otherwise, add it to the list of
			//  discovered mutations
			// We've already checked for stored_research earlier
			if(result_path in stored_research.discovered_mutations)
				return

			var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(result_path)
			stored_research.discovered_mutations += result_path
			say("Successfully mutated [HM.name].")
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Sets the Genetic Makeup pulse strength.
		// ---------------------------------------------------------------------- //
		// params["val"] - New strength value as text string, converted to number
		//  later on in code
		if("set_pulse_strength")
			var/value = round(text2num(params["val"]))
			pulse_strength = WRAP(value, 1, GENETIC_DAMAGE_STRENGTH_MAX+1)
			return

		// Sets the Genetic Makeup pulse duration
		// ---------------------------------------------------------------------- //
		// params["val"] - New strength value as text string, converted to number
		//  later on in code
		if("set_pulse_duration")
			var/value = round(text2num(params["val"]))
			pulse_duration = WRAP(value, 1, GENETIC_DAMAGE_DURATION_MAX+1)
			return

		// Saves Genetic Makeup information to disk
		// ---------------------------------------------------------------------- //
		// params["index"] - The BYOND index of the console genetic makeup buffer to
		//  copy to disk
		if("save_makeup_disk")
			// GUARD CHECK - This code shouldn't even be callable without a diskette
			//  inserted. Unexpected result
			if(!diskette)
				return

			// GUARD CHECK - Make sure the disk isn't set to read only, as we're
			//  attempting to write to it
			if(diskette.read_only)
				to_chat(usr,span_warning("Disk is set to read only mode."))
				return

			// Convert the index to a number and clamp within the array range
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)

			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			// GUARD CHECK - This should not be possible to activate on a buffer slot
			//  that doesn't have any genetic data. Unexpected result
			if(!istype(buffer_slot))
				return

			diskette.genetic_makeup_buffer = buffer_slot.Copy()
			return

		// Loads Genetic Makeup from disk to a console buffer
		// ---------------------------------------------------------------------- //
		// params["index"] - The BYOND index of the console genetic makeup buffer to
		//  copy to. Expected as text string, converted to number later
		if("load_makeup_disk")
			// GUARD CHECK - This code shouldn't even be callable without a diskette
			//  inserted. Unexpected result
			if(!diskette)
				return

			// GUARD CHECK - This should not be possible to activate on a diskette
			//  that doesn't have any genetic data. Unexpected result
			if(LAZYLEN(diskette.genetic_makeup_buffer) == 0)
				return

			// Convert the index to a number and clamp within the array range, then
			//  copy the data from the disk to that buffer
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			genetic_makeup_buffer[buffer_index] = diskette.genetic_makeup_buffer.Copy()
			return

		// Deletes genetic makeup buffer from the inserted diskette
		if("del_makeup_disk")
			// GUARD CHECK - This code shouldn't even be callable without a diskette
			//  inserted. Unexpected result
			if(!diskette)
				return

			// GUARD CHECK - Make sure the disk isn't set to read only, as we're
			//  attempting to write (via deletion) to it
			if(diskette.read_only)
				to_chat(usr,span_warning("Disk is set to read only mode."))
				return

			diskette.genetic_makeup_buffer.Cut()
			return

		// Saves the scanner occupant's genetic makeup to a given console buffer
		// ---------------------------------------------------------------------- //
		// params["index"] - The BYOND index of the console genetic makeup buffer to
		//  save the new genetic data to. Expected as text string, converted to
		//  number later
		if("save_makeup_console")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			// Convert the index to a number and clamp within the array range, then
			//  copy the data from the disk to that buffer
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)

			// Set the new information
			genetic_makeup_buffer[buffer_index] = list(
				"label"="Slot [buffer_index]:[scanner_occupant.real_name]",
				"UI"=scanner_occupant.dna.unique_identity,
				"UE"=scanner_occupant.dna.unique_enzymes,
				"UF"=scanner_occupant.dna.unique_features,
				"name"=scanner_occupant.real_name,
				"blood_type"=scanner_occupant.dna.blood_type)

			return

		// Deleted genetic makeup data from a console buffer slot
		// ---------------------------------------------------------------------- //
		// params["index"] - The BYOND index of the console genetic makeup buffer to
		//  delete the genetic data from. Expected as text string, converted to
		//  number later
		if("del_makeup_console")
			// Convert the index to a number and clamp within the array range, then
			//  copy the data from the disk to that buffer
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			// GUARD CHECK - This shouldn't be possible to execute this on a null
			//  buffer. Unexpected resut
			if(!istype(buffer_slot))
				return

			genetic_makeup_buffer[buffer_index] = null
			return

		// Eject stored diskette from console
		if("eject_disk")
			eject_disk(usr)
			return

		// Create a Genetic Makeup injector. These injectors are timed and thus are
		//  only temporary
		// ---------------------------------------------------------------------- //
		// params["index"] - The BYOND index of the console genetic makeup buffer to
		//  create the makeup injector from. Expected as text string, converted to
		//  number later
		// params["type"] - Type of injector to create
		//  Expected results:
		//   "ue" - Unique Enzyme, changes name and blood type
		//  "ui" - Unique Identity, changes looks
		//  "uf" - Unique Features, changes mutant bodyparts and mutcolors
		//  "mixed" - Combination of both ue and ui
		if("makeup_injector")
			if(!COOLDOWN_FINISHED(src, enzyme_copy_timer))
				return
			// Convert the index to a number and clamp within the array range, then
			//  copy the data from the disk to that buffer
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			// GUARD CHECK - This shouldn't be possible to execute this on a null
			//  buffer. Unexpected resut
			if(!istype(buffer_slot))
				return

			var/type = params["type"]
			var/obj/item/dnainjector/timed/I

			switch(type)
				if("ui")
					// GUARD CHECK - There's currently no way to save partial genetic data.
					//  However, if this is the case, we can't make a complete injector and
					//  this catches that edge case
					if(!buffer_slot["UI"])
						to_chat(usr,span_warning("Genetic data corrupted, unable to create injector."))
						return

					I = new /obj/item/dnainjector/timed(loc)
					I.fields = list("UI"=buffer_slot["UI"])

					// If there is a connected scanner, we can use its upgrades to reduce
					//  the genetic damage generated by this injector
					if(scanner_operational())
						I.damage_coeff = connected_scanner.damage_coeff
				if("ue")
					// GUARD CHECK - There's currently no way to save partial genetic data.
					//  However, if this is the case, we can't make a complete injector and
					//  this catches that edge case
					if(!buffer_slot["name"] || !buffer_slot["UE"] || !buffer_slot["blood_type"])
						to_chat(usr,span_warning("Genetic data corrupted, unable to create injector."))
						return

					I = new /obj/item/dnainjector/timed(loc)
					I.fields = list("name"=buffer_slot["name"], "UE"=buffer_slot["UE"], "blood_type"=buffer_slot["blood_type"])

					// If there is a connected scanner, we can use its upgrades to reduce
					//  the genetic damage generated by this injector
					if(scanner_operational())
						I.damage_coeff = connected_scanner.damage_coeff
				if("uf")
					// GUARD CHECK - There's currently no way to save partial genetic data.
					//  However, if this is the case, we can't make a complete injector and
					//  this catches that edge case
					if(!buffer_slot["name"] || !buffer_slot["UF"] || !buffer_slot["blood_type"])
						to_chat(usr,"<span class='warning'>Genetic data corrupted, unable to create injector.</span>")
						return

					I = new /obj/item/dnainjector/timed(loc)
					I.fields = list("name"=buffer_slot["name"], "UF"=buffer_slot["UF"])

					// If there is a connected scanner, we can use its upgrades to reduce
					//  the genetic damage generated by this injector
					if(scanner_operational())
						I.damage_coeff = connected_scanner.damage_coeff
				if("mixed")
					// GUARD CHECK - There's currently no way to save partial genetic data.
					//  However, if this is the case, we can't make a complete injector and
					//  this catches that edge case
					if(!buffer_slot["UI"] || !buffer_slot["name"] || !buffer_slot["UE"] || !buffer_slot["UF"] || !buffer_slot["blood_type"])
						to_chat(usr,span_warning("Genetic data corrupted, unable to create injector."))
						return

					I = new /obj/item/dnainjector/timed(loc)
					I.fields = list("UI"=buffer_slot["UI"],"name"=buffer_slot["name"], "UE"=buffer_slot["UE"], "UF"=buffer_slot["UF"], "blood_type"=buffer_slot["blood_type"])

					// If there is a connected scanner, we can use its upgrades to reduce
					//  the genetic damage generated by this injector
					if(scanner_operational())
						I.damage_coeff = connected_scanner.damage_coeff

			// If we successfully created an injector, don't forget to set the new
			//  ready timer.
			if(I)
				injector_ready = world.time + MISC_INJECTOR_TIMEOUT
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Applies a genetic makeup buffer to the scanner occupant
		// ---------------------------------------------------------------------- //
		// params["index"] - The BYOND index of the console genetic makeup buffer to
		//  apply to the scanner occupant. Expected as text string, converted to
		//  number later
		// params["type"] - Type of genetic makeup copy to implement
		//  Expected results:
		//   "ue" - Unique Enzyme, changes name and blood type
		//  "ui" - Unique Identity, changes looks
		//  "uf" - Unique Features, changes mutant bodyparts and mutcolors
		//  "mixed" - Combination of ue, ui, and uf
		if("makeup_apply")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			if(!COOLDOWN_FINISHED(src, enzyme_copy_timer))
				return

			// Convert the index to a number and clamp within the array range, then
			//  copy the data from the disk to that buffer
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			// GUARD CHECK - This shouldn't be possible to execute this on a null
			//  buffer. Unexpected resut
			if(!istype(buffer_slot))
				return

			var/type = params["type"]

			apply_genetic_makeup(type, buffer_slot)
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Applies a genetic makeup buffer to the next scanner occupant. This sets
		//  some code that will run when the connected DNA Scanner door is next
		//  closed
		// This allows people to self-modify their genetic makeup, as tgui
		//  interfaces can not be accessed while inside the DNA Scanner and genetic
		//  makeup injectors are only temporary
		// ---------------------------------------------------------------------- //
		// params["index"] - The BYOND index of the console genetic makeup buffer to
		//  apply to the scanner occupant. Expected as text string, converted to
		//  number later
		// params["type"] - Type of genetic makeup copy to implement
		//  Expected results:
		//   "ue" - Unique Enzyme, changes name and blood type
		//  "ui" - Unique Identity, changes looks
		//  "uf" - Unique Features, changes mutant bodyparts and mutcolors
		//  "mixed" - Combination of ue, ui, and uf
		if("makeup_delay")
			// Convert the index to a number and clamp within the array range, then
			//  copy the data from the disk to that buffer
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			// GUARD CHECK - This shouldn't be possible to execute this on a null
			//  buffer. Unexpected resut
			if(!istype(buffer_slot))
				return

			var/type = params["type"]

			// Set the delayed action. The next time the scanner door is closed,
			//  unless this is cancelled in the UI, the action will happen
			delayed_action = list("type" = type, "buffer_slot" = buffer_slot)
			return

		// Attempts to modify the indexed element of the Unique Identity string
		// This is a time delayed action that is handled in process()
		// ---------------------------------------------------------------------- //
		// params["type"] - Type of genetic makeup string to edit
		//  Expected results:
		//  "ui" - Unique Identity, changes looks
		//  "uf" - Unique Features, changes mutant bodyparts and mutcolors
		// params["index"] - The BYOND index of the Unique Identity string to
		//  attempt to modify
		if("makeup_pulse")
			// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
			//  operational guard checks.
			if(!can_modify_occupant())
				return

			// Set the appropriate timer, string, and index to pulse. This is then managed
			//  later on in process()
			var/type = params["type"]
			genetic_damage_pulse_type = type
			var/len
			switch(type)
				if("ui")
					len = length(scanner_occupant.dna.unique_identity)
				if("uf")
					len = length(scanner_occupant.dna.unique_features)
			genetic_damage_pulse_timer = world.time + (pulse_duration*10)
			genetic_damage_pulse_index = WRAP(text2num(params["index"]), 1, len+1)
			begin_processing()
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Cancels the delayed action - In this context it is not the genetic damage
		//  pulse from "makeup_pulse", which can not be cancelled. It is instead
		//  the delayed genetic transfer from "makeup_delay"
		if("cancel_delay")
			delayed_action = null
			return

		// Creates a new advanced injector storage buffer in the console
		// ---------------------------------------------------------------------- //
		// params["name"] - The name to apply to the new injector
		if("new_adv_inj")
			// GUARD CHECK - Make sure we can make a new injector. This code should
			//  not be called if we're already maxed out and this is an Unexpected
			//  result
			if(!(LAZYLEN(injector_selection) < max_injector_selections))
				return

			// GUARD CHECK - Sanitise and trim the proposed name. This prevents HTML
			//  injection and equivalent as tgui input is not stripped
			var/inj_name = params["name"]
			inj_name = trim(sanitize(inj_name))

			// GUARD CHECK - If the name is null or blank, or the name is already in
			//  the list of advanced injectors, we want to reject it as we can't have
			//  duplicate named advanced injectors
			if(!inj_name || (inj_name in injector_selection))
				return

			injector_selection[inj_name] = list()
			return

		// Deleted an advanced injector storage buffer from the console
		// ---------------------------------------------------------------------- //
		// params["name"] - The name of the injector to delete
		if("del_adv_inj")
			var/inj_name = params["name"]

			// GUARD CHECK - If the name is null or blank, reject.
			// GUARD CHECK - If the name isn't in the list of advanced injectors, we
			//  want to reject this as it shouldn't be possible ever do this.
			// Unexpected result
			if(!inj_name || !(inj_name in injector_selection))
				return

			injector_selection.Remove(inj_name)
			return

		// Creates an injector from an advanced injector buffer
		// ---------------------------------------------------------------------- //
		// params["name"] - The name of the injector to print
		if("print_adv_inj")
			// As a side note, because mutations can contain unique metadata,
			// this system uses BYOND Atom Refs to safely and accurately
			// identify mutations from big ol' lists.

				// GUARD CHECK - Is the injector actually ready?
			if(world.time < injector_ready)
				return

			var/inj_name = params["name"]

			// GUARD CHECK - If the name is null or blank, reject.
			// GUARD CHECK - If the name isn't in the list of advanced injectors, we
			//  want to reject this as it shouldn't be possible ever do this.
			// Unexpected result
			if(!inj_name || !(inj_name in injector_selection))
				return

			var/list/injector = injector_selection[inj_name]
			var/obj/item/dnainjector/activator/I = new /obj/item/dnainjector/activator(loc)

			// Run through each mutation in our Advanced Injector and add them to a
			//  new injector
			var/total_stability
			for(var/A in injector)
				var/datum/mutation/human/HM = A
				I.add_mutations += new HM.type(copymut=HM)
				total_stability += HM.instability

			// Force apply any mutations, this is functionality similar to mutators
			I.force_mutate = TRUE
			I.name = "Advanced [inj_name] injector"

			// If there's an operational connected scanner, we can use its upgrades
			//  to improve our injector's genetic damage generation
			var/cd_reduction_mult = 1 + ADVANCED_COOLDOWN_MULTIPLIER
			var/base_cd_time = max(MIN_ADVANCED_TIMEOUT, abs(total_stability) SECONDS)

			if(scanner_operational())
				I.damage_coeff = connected_scanner.damage_coeff*4
				// T1: 1.1 - 0.1: 1: 100%
				// T4: 1.1 - 0.4: 0.7 = 70%
				// 10% reduction per tier
				cd_reduction_mult -= ADVANCED_COOLDOWN_MULTIPLIER * (connected_scanner.precision_coeff)

			injector_ready = world.time + (base_cd_time * cd_reduction_mult)
			return

		// Adds a mutation to an advanced injector
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to add to the injector
		// params["advinj"] - Name of the advanced injector to add the mutation to
		if("add_advinj_mut")
			if(!scanner_operational())
				return
			var/adv_inj = params["advinj"]

			// GUARD CHECK - Make sure our advanced injector actually exists. This
			//  should not be possible. Unexpected result
			if(!(adv_inj in injector_selection))
				return

			// GUARD CHECK - Make sure we limit the number of mutations appropriately
			if(LAZYLEN(injector_selection[adv_inj]) >= max_injector_mutations)
				to_chat(usr,span_warning("Advanced injector mutation storage is full."))
				return

			var/mut_source = params["source"]
			var/search_flag = 0

			switch(mut_source)
				if("disk")
					search_flag = SEARCH_DISKETTE
				if("occupant")
					search_flag = SEARCH_OCCUPANT
				if("console")
					search_flag = SEARCH_STORED

			if(!search_flag)
				return

			var/bref = params["mutref"]
			if(search_flag & SEARCH_OCCUPANT)
				if(!can_modify_occupant())
					return
			// We've already made sure we can modify the occupant, so this is safe to
			//  call
			var/datum/mutation/human/HM = get_mut_by_ref(bref, search_flag)

			// GUARD CHECK - This should not be possible. Unexpected result
			if(!HM)
				return

			// We want to make sure we stick within the instability limit.
			// We start with the instability of the mutation we're intending to add.
			var/instability_total = HM.instability

			// We then add the instabilities of all other mutations in the injector,
			//  remembering to apply the Stabilizer chromosome modifiers
			for(var/datum/mutation/human/I in injector_selection[adv_inj])
				instability_total += I.instability * GET_MUTATION_STABILIZER(I)

			// If this would take us over the max instability, we inform the user.
			if(instability_total > max_injector_instability)
				to_chat(usr,span_warning("Extra mutation would make the advanced injector too instable."))
				return

			// If we've got here, all our checks are passed and we can successfully
			//  add the mutation to the advanced injector.
			var/datum/mutation/human/A = new HM.type()
			A.copy_mutation(HM)
			injector_selection[adv_inj] += A
			to_chat(usr,span_notice("Mutation successfully added to advanced injector."))
			if(connected_scanner)
				connected_scanner.use_energy(connected_scanner.active_power_usage)
			else
				use_energy(active_power_usage)
			return

		// Deletes a mutation from an advanced injector
		// ---------------------------------------------------------------------- //
		// params["mutref"] - ATOM Ref of specific mutation to del from the injector
		if("delete_injector_mut")
			var/bref = params["mutref"]

			var/datum/mutation/human/HM = get_mut_by_ref(bref, SEARCH_ADV_INJ)

			// GUARD CHECK - This should not be possible. Unexpected result
			if(!HM)
				return

			// Check Advanced Injectors to find and remove the mutation
			for(var/I in injector_selection)
				if(injector_selection["[I]"].Remove(HM))
					qdel(HM)
					return

			return

		// Sets a new tgui view state
		// ---------------------------------------------------------------------- //
		// params["id"] - Key for the state to set
		// params[...] - Every other element is used to set state variables
		if("set_view")
			for (var/key in params)
				if(key == "src")
					continue
				tgui_view_state[key] = params[key]
			return TRUE
	return FALSE

/**
 * Applies the enzyme buffer to the current scanner occupant
 *
 * Applies the type of a specific genetic makeup buffer to the current scanner
	* occupant
	*
 * Arguments:
 * * type - "ui"/"ue"/"mixed" - Which part of the enzyme buffer to apply
 * * buffer_slot - Index of the enzyme buffer to apply
 */
/obj/machinery/computer/scan_consolenew/proc/apply_genetic_makeup(type, buffer_slot)
	// Note - This proc is only called from code that has already performed the
	//  necessary occupant guard checks. If you call this code yourself, please
	//  apply can_modify_occupant() or equivalent checks first.

	// Pre-calc the damage increase since we'll be using it in all the possible
	//  operations
	var/damage_increase = rand(100/(connected_scanner.damage_coeff ** 2),250/(connected_scanner.damage_coeff ** 2))

	switch(type)
		if("ui")
			// GUARD CHECK - There's currently no way to save partial genetic data.
			//  However, if this is the case, we can't make a complete injector and
			//  this catches that edge case
			if(!buffer_slot["UI"])
				to_chat(usr,span_warning("Genetic data corrupted, unable to apply genetic data."))
				return FALSE
			COOLDOWN_START(src, enzyme_copy_timer, ENZYME_COPY_BASE_COOLDOWN)
			scanner_occupant.dna.unique_identity = buffer_slot["UI"]
			scanner_occupant.updateappearance(mutations_overlay_update=1)
			scanner_occupant.apply_status_effect(/datum/status_effect/genetic_damage, damage_increase)
			scanner_occupant.domutcheck()
			return TRUE
		if("uf")
			// GUARD CHECK - There's currently no way to save partial genetic data.
			//  However, if this is the case, we can't make a complete injector and
			//  this catches that edge case
			if(!buffer_slot["UF"])
				to_chat(usr,"<span class='warning'>Genetic data corrupted, unable to apply genetic data.</span>")
				return FALSE
			COOLDOWN_START(src, enzyme_copy_timer, ENZYME_COPY_BASE_COOLDOWN)
			scanner_occupant.dna.unique_features = buffer_slot["UF"]
			scanner_occupant.updateappearance(mutcolor_update=1, mutations_overlay_update=1)
			scanner_occupant.apply_status_effect(/datum/status_effect/genetic_damage, damage_increase)
			scanner_occupant.domutcheck()
			return TRUE
		if("ue")
			// GUARD CHECK - There's currently no way to save partial genetic data.
			//  However, if this is the case, we can't make a complete injector and
			//  this catches that edge case
			if(!buffer_slot["name"] || !buffer_slot["UE"] || !buffer_slot["blood_type"])
				to_chat(usr,span_warning("Genetic data corrupted, unable to apply genetic data."))
				return FALSE
			COOLDOWN_START(src, enzyme_copy_timer, ENZYME_COPY_BASE_COOLDOWN)
			scanner_occupant.real_name = buffer_slot["name"]
			scanner_occupant.name = buffer_slot["name"]
			scanner_occupant.dna.unique_enzymes = buffer_slot["UE"]
			scanner_occupant.dna.blood_type = buffer_slot["blood_type"]
			scanner_occupant.apply_status_effect(/datum/status_effect/genetic_damage, damage_increase)
			scanner_occupant.domutcheck()
			return TRUE
		if("mixed")
			// GUARD CHECK - There's currently no way to save partial genetic data.
			//  However, if this is the case, we can't make a complete injector and
			//  this catches that edge case
			if(!buffer_slot["UI"] || !buffer_slot["name"] || !buffer_slot["UE"] || !buffer_slot["UF"] || !buffer_slot["blood_type"])
				to_chat(usr,span_warning("Genetic data corrupted, unable to apply genetic data."))
				return FALSE
			COOLDOWN_START(src, enzyme_copy_timer, ENZYME_COPY_BASE_COOLDOWN)
			scanner_occupant.dna.unique_identity = buffer_slot["UI"]
			scanner_occupant.dna.unique_features = buffer_slot["UF"]
			scanner_occupant.updateappearance(mutcolor_update=1, mutations_overlay_update=1)
			scanner_occupant.real_name = buffer_slot["name"]
			scanner_occupant.name = buffer_slot["name"]
			scanner_occupant.dna.unique_enzymes = buffer_slot["UE"]
			scanner_occupant.dna.blood_type = buffer_slot["blood_type"]
			scanner_occupant.apply_status_effect(/datum/status_effect/genetic_damage, damage_increase)
			scanner_occupant.domutcheck()
			return TRUE

	return FALSE
/**
 * Checks if there is a connected DNA Scanner that is operational
 */
/obj/machinery/computer/scan_consolenew/proc/scanner_operational()
	return connected_scanner?.is_operational

/**
 * Checks if there is a valid DNA Scanner occupant for genetic modification
 *
	* Checks if there is a valid subject in the DNA Scanner that can be genetically
	* modified. Will set the scanner occupant var as part of this check.
	* Requires that the scanner can be operated and will return early if it can't
 */
/obj/machinery/computer/scan_consolenew/proc/can_modify_occupant()
	// GUARD CHECK - We always want to perform the scanner operational check as
	//  part of checking if we can modify the occupant.
	// We can never modify the occupant of a broken scanner.
	if(!scanner_operational())
		return FALSE

	if(!connected_scanner.occupant)
		return FALSE

	scanner_occupant = connected_scanner.occupant

		// Check validity of occupent for DNA Modification
		// DNA Modification:
		//   requires DNA
		//    this DNA can not be bad
		//   is done via genetic damage bursts, so genetic damage immune carbons are not viable
		// And the DNA Scanner itself must have a valid scan level
	if(scanner_occupant.has_dna() && !HAS_TRAIT(scanner_occupant, TRAIT_GENELESS) && !HAS_TRAIT(scanner_occupant, TRAIT_BADDNA) || (connected_scanner.scan_level == 3))
		return TRUE

	return FALSE

/**
 * Checks for adjacent DNA scanners and connects when it finds a viable one
 *
	* Seearches cardinal directions in order. Stops when it finds a viable DNA Scanner.
	* Will connect to a broken scanner if no functional scanner is available.
	* Links itself to the DNA Scanner to receive door open and close events.
 */
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
			if(test_scanner.is_operational)
				set_connected_scanner(test_scanner)
				return
			else
				broken_scanner = test_scanner

	// Ultimately, if we have a broken scanner, we'll attempt to connect to it as
	// a fallback case, but the code above will prefer a working scanner
	if(!isnull(broken_scanner))
		set_connected_scanner(broken_scanner)

/**
 * Called by connected DNA Scanners when their doors close.
 *
	* Sets the new scanner occupant and completes delayed enzyme transfer if one
	* is queued.
 */
/obj/machinery/computer/scan_consolenew/proc/on_scanner_close()
	// Set the appropriate occupant now the scanner is closed
	if(connected_scanner.occupant)
		scanner_occupant = connected_scanner.occupant
	else
		scanner_occupant = null

	// If we have a delayed action - In this case the only delayed action is
	//  applying a genetic makeup buffer the next time the DNA Scanner is closed -
	//  we want to perform it.
	// GUARD CHECK - Make sure we can modify the occupant, apply_genetic_makeup()
	//  assumes we've already done this.
	if(delayed_action && can_modify_occupant() && COOLDOWN_FINISHED(src, enzyme_copy_timer))
		var/type = delayed_action["type"]
		var/buffer_slot = delayed_action["buffer_slot"]
		if(apply_genetic_makeup(type, buffer_slot))
			to_chat(connected_scanner.occupant, span_notice("[src] activates!"))
		delayed_action = null

/**
 * Called by connected DNA Scanners when their doors open.
 *
	* Clears enzyme pulse operations, stops processing and nulls the current
	* scanner occupant var.
 */
/obj/machinery/computer/scan_consolenew/proc/on_scanner_open()
	// If we had a genetic damage pulse action ongoing, we want to stop this.
	// Imagine it being like a microwave stopping when you open the door.
	genetic_damage_pulse_index = 0
	genetic_damage_pulse_timer = 0
	end_processing()
	scanner_occupant = null

/**
 * Builds the genetic makeup list which will be sent to tgui interface.
 */
/obj/machinery/computer/scan_consolenew/proc/build_genetic_makeup_list()
	// No code will ever null this list, we can safely Cut it.
	tgui_genetic_makeup.Cut()

	for(var/i in 1 to NUMBER_OF_BUFFERS)
		if(genetic_makeup_buffer[i])
			tgui_genetic_makeup["[i]"] = genetic_makeup_buffer[i].Copy()
		else
			tgui_genetic_makeup["[i]"] = null

/**
 * Builds the genetic makeup list which will be sent to tgui interface.
	*
	* Will iterate over the connected scanner occupant, DNA Console, inserted
	* diskette and chromosomes and any advanced injectors, building the main data
	* structures which get passed to the tgui interface.
 */
/obj/machinery/computer/scan_consolenew/proc/build_mutation_list(can_modify_occ)
	// No code will ever null these lists. We can safely Cut them.
	tgui_occupant_mutations.Cut()
	tgui_diskette_mutations.Cut()
	tgui_console_mutations.Cut()
	tgui_console_chromosomes.Cut()
	tgui_advinjector_mutations.Cut()

	// ------------------------------------------------------------------------ //
	// GUARD CHECK - Can we genetically modify the occupant? This check will have
	//  previously included checks to make sure the DNA Scanner is still
	//  operational
	if(can_modify_occ)
		// ---------------------------------------------------------------------- //
		// Start cataloguing all mutations that the occupant has by default
		for(var/mutation_type in scanner_occupant.dna.mutation_index)
			var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation_type)

			var/list/mutation_data = list()
			var/text_sequence = scanner_occupant.dna.mutation_index[mutation_type]
			var/default_sequence = scanner_occupant.dna.default_mutation_genes[mutation_type]
			var/discovered = (stored_research && (mutation_type in stored_research.discovered_mutations))

			mutation_data["Alias"] = HM.alias
			mutation_data["Sequence"] = text_sequence
			mutation_data["DefaultSeq"] = default_sequence
			mutation_data["Discovered"] = discovered
			mutation_data["Source"] = "occupant"

			// We only want to pass this information along to the tgui interface if
			//  the mutation has been discovered. Prevents people being able to cheese
			//  or "hack" their way to figuring out what undiscovered mutations are
			if(discovered)
				mutation_data["Name"] = HM.name
				mutation_data["Description"] = HM.desc
				mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)
				mutation_data["Quality"] = HM.quality

			// Assume the mutation is normal unless assigned otherwise.
			var/mut_class = MUT_NORMAL

			// Check if the mutation is currently activated. If it is, we can add even
			//  MORE information to send to tgui.
			var/datum/mutation/human/A = scanner_occupant.dna.get_mutation(mutation_type)
			if(A)
				mutation_data["Active"] = TRUE
				mutation_data["Scrambled"] = A.scrambled
				mutation_data["Class"] = A.class
				mut_class = A.class
				mutation_data["CanChromo"] = A.can_chromosome
				mutation_data["ByondRef"] = REF(A)
				mutation_data["Type"] = A.type
				if(A.can_chromosome)
					mutation_data["ValidChromos"] = jointext(A.valid_chrom_list, ", ")
					mutation_data["AppliedChromo"] = A.chromosome_name
					mutation_data["ValidStoredChromos"] = build_chrom_list(A)
			else
				mutation_data["Active"] = FALSE
				mutation_data["Scrambled"] = FALSE
				mutation_data["Class"] = MUT_NORMAL

			// Technically NONE of these mutations should be MUT_EXTRA but this will
			//  catch any weird edge cases
			// Assign icons by priority - MUT_EXTRA will ALSO be discovered, so it
			//  has a higher priority for icon/image assignment
			if (mut_class == MUT_EXTRA)
				mutation_data["Image"] = "dna_extra.gif"
			else if(discovered)
				mutation_data["Image"] = "dna_discovered.gif"
			else
				mutation_data["Image"] = "dna_undiscovered.gif"

			tgui_occupant_mutations += list(mutation_data)

		// ---------------------------------------------------------------------- //
		// Now get additional/"extra" mutations that they shouldn't have by default
		for(var/datum/mutation/human/HM in scanner_occupant.dna.mutations)
			// If it's in the mutation index array, we've already catalogued this
			//  mutation and can safely skip over it. It really shouldn't be, but this
			//  will catch any weird edge cases
			if(HM.type in scanner_occupant.dna.mutation_index)
				continue

			var/list/mutation_data = list()
			var/text_sequence = GET_SEQUENCE(HM.type)

			// These will all be active mutations. They're added by injector and their
			//  sequencing code can't be changed. They can only be nullified, which
			//  completely removes them.
			var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(HM.type)

			mutation_data["Alias"] = A.alias
			mutation_data["Sequence"] = text_sequence
			mutation_data["Discovered"] = TRUE
			mutation_data["Quality"] = HM.quality
			mutation_data["Source"] = "occupant"

			mutation_data["Name"] = HM.name
			mutation_data["Description"] = HM.desc
			mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)

			mutation_data["Active"] = TRUE
			mutation_data["Scrambled"] = HM.scrambled
			mutation_data["Class"] = HM.class
			mutation_data["CanChromo"] = HM.can_chromosome
			mutation_data["ByondRef"] = REF(HM)
			mutation_data["Type"] = HM.type

			if(HM.can_chromosome)
				mutation_data["ValidChromos"] = jointext(HM.valid_chrom_list, ", ")
				mutation_data["AppliedChromo"] = HM.chromosome_name
				mutation_data["ValidStoredChromos"] = build_chrom_list(HM)

			// Nothing in this list should be undiscovered. Technically nothing
			// should be anything but EXTRA. But we're just handling some edge cases.
			if (HM.class == MUT_EXTRA)
				mutation_data["Image"] = "dna_extra.gif"
			else
				mutation_data["Image"] = "dna_discovered.gif"

			tgui_occupant_mutations += list(mutation_data)

	// ------------------------------------------------------------------------ //
	// Build the list of mutations stored within the DNA Console
	for(var/datum/mutation/human/HM in stored_mutations)
		var/list/mutation_data = list()

		var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(HM.type)

		mutation_data["Alias"] = A.alias
		mutation_data["Name"] = HM.name
		mutation_data["Source"] = "console"
		mutation_data["Active"] = TRUE
		mutation_data["Description"] = HM.desc
		mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)
		mutation_data["ByondRef"] = REF(HM)
		mutation_data["Type"] = HM.type

		mutation_data["CanChromo"] = HM.can_chromosome
		if(HM.can_chromosome)
			mutation_data["ValidChromos"] = jointext(HM.valid_chrom_list, ", ")
			mutation_data["AppliedChromo"] = HM.chromosome_name
			mutation_data["ValidStoredChromos"] = build_chrom_list(HM)

		tgui_console_mutations += list(mutation_data)

	// ------------------------------------------------------------------------ //
	// Build the list of chromosomes stored within the DNA Console
	var/chrom_index = 1
	for(var/obj/item/chromosome/CM in stored_chromosomes)
		var/list/chromo_data = list()

		chromo_data["Name"] = CM.name
		chromo_data["Description"] = CM.desc
		chromo_data["Index"] = chrom_index

		tgui_console_chromosomes += list(chromo_data)
		++chrom_index

	// ------------------------------------------------------------------------ //
	// Build the list of mutations stored on any inserted diskettes
	if(diskette)
		for(var/datum/mutation/human/HM in diskette.mutations)
			var/list/mutation_data = list()

			var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(HM.type)

			mutation_data["Alias"] = A.alias
			mutation_data["Name"] = HM.name
			mutation_data["Active"] = TRUE
			//mutation_data["Sequence"] = GET_SEQUENCE(HM.type)
			mutation_data["Source"] = "disk"
			mutation_data["Description"] = HM.desc
			mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)
			mutation_data["ByondRef"] = REF(HM)
			mutation_data["Type"] = HM.type

			mutation_data["CanChromo"] = HM.can_chromosome
			if(HM.can_chromosome)
				mutation_data["ValidChromos"] = jointext(HM.valid_chrom_list, ", ")
				mutation_data["AppliedChromo"] = HM.chromosome_name
				mutation_data["ValidStoredChromos"] = build_chrom_list(HM)

			tgui_diskette_mutations += list(mutation_data)

	// ------------------------------------------------------------------------ //
	// Build the list of mutations stored within any Advanced Injectors
	if(LAZYLEN(injector_selection))
		for(var/I in injector_selection)
			var/list/mutations = list()
			for(var/datum/mutation/human/HM in injector_selection[I])
				var/list/mutation_data = list()

				var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(HM.type)

				mutation_data["Alias"] = A.alias
				mutation_data["Name"] = HM.name
				mutation_data["Active"] = TRUE
				//mutation_data["Sequence"] = GET_SEQUENCE(HM.type)
				mutation_data["Source"] = "injector"
				mutation_data["Description"] = HM.desc
				mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)
				mutation_data["ByondRef"] = REF(HM)
				mutation_data["Type"] = HM.type

				if(HM.can_chromosome)
					mutation_data["AppliedChromo"] = HM.chromosome_name

				mutations += list(mutation_data)
			tgui_advinjector_mutations += list(list(
				"name" = "[I]",
				"mutations" = mutations,
			))

/**
 * Takes any given chromosome and calculates chromosome compatibility
	*
	* Will iterate over the stored chromosomes in the DNA Console and will check
	* whether it can be applied to the supplied mutation. Then returns a list of
	* names of chromosomes that were compatible.
	*
	* Arguments:
 * * mutation - The mutation to check chromosome compatibility with
 */
/obj/machinery/computer/scan_consolenew/proc/build_chrom_list(mutation)
	var/list/chromosomes = list()

	for(var/obj/item/chromosome/CM in stored_chromosomes)
		if(CM.can_apply(mutation))
			chromosomes += CM.name

	return chromosomes

/**
 * Checks whether a mutation alias has been discovered
	*
	* Checks whether a given mutation's genetic sequence has been completed and
	* discovers it if appropriate
	*
	* Arguments:
 * * alias - Alias of the mutation to check (ie "Mutation 51" or "Mutation 12")
 */
/obj/machinery/computer/scan_consolenew/proc/check_discovery(alias)
	// Note - All code paths that call this have already done checks on the
	//  current occupant to prevent cheese and other abuses. If you call this
	//  proc please also do the following checks first:
	// if(!can_modify_occupant())
	//   return
	// if(!(scanner_occupant == connected_scanner.occupant))
	//   return

	// Turn the alias ("Mutation 1", "Mutation 35") into a mutation path
	var/path = GET_MUTATION_TYPE_FROM_ALIAS(alias)

	// Check to see if this mutation is in the active mutation list. If it isn't,
	//  then the mutation isn't eligible for discovery. If it is but is scrambled,
	//  then the mutation isn't eligible for discovery. Finally, check if the
	//  mutation is in discovered mutations - If it isn't, add it to discover.
	var/datum/mutation/human/M = scanner_occupant.dna.get_mutation(path)
	if(!M)
		return FALSE
	if(M.scrambled)
		return FALSE
	if(stored_research && !(path in stored_research.discovered_mutations))
		var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(path)
		stored_research.discovered_mutations += path
		say("Successfully discovered [HM.name].")
		return TRUE

	return FALSE

/**
 * Find a mutation from various storage locations via ATOM ref
	*
	* Takes an ATOM Ref and searches the appropriate mutation buffers and storage
	* vars to try and find the associated mutation.
	*
	* Arguments:
 * * ref - ATOM ref of the mutation to locate
	* * target_flags - Flags for storage mediums to search, see #defines
 */
/obj/machinery/computer/scan_consolenew/proc/get_mut_by_ref(ref, target_flags)
	var/mutation

	// Assume the occupant is valid and the check has been carried out before
	// calling this proc with the relevant flags.
	if(target_flags & SEARCH_OCCUPANT)
		mutation = (locate(ref) in scanner_occupant.dna.mutations)
		if(mutation)
			return mutation

	if(target_flags & SEARCH_STORED)
		mutation = (locate(ref) in stored_mutations)
		if(mutation)
			return mutation

	if(diskette && (target_flags & SEARCH_DISKETTE))
		mutation = (locate(ref) in diskette.mutations)
		if(mutation)
			return mutation

	if(injector_selection && (target_flags & SEARCH_ADV_INJ))
		for(var/I in injector_selection)
			mutation = (locate(ref) in injector_selection["[I]"])
			if(mutation)
				return mutation

	return null

/**
 * Creates a randomised accuracy value for the enzyme pulse functionality.
	*
	* Donor code from previous DNA Console iteration.
	*
	* Arguments:
 * * position - Index of the intended enzyme element to pulse
	* * pulse_duration - Duration of intended genetic damage pulse
	* * number_of_blocks - Number of individual data blocks in the pulsed enzyme
 */
/obj/machinery/computer/scan_consolenew/proc/randomize_GENETIC_DAMAGE_accuracy(position, pulse_duration, number_of_blocks)
	var/val = round(gaussian(0, GENETIC_DAMAGE_ACCURACY_MULTIPLIER/pulse_duration) + position, 1)
	return WRAP(val, 1, number_of_blocks+1)

/**
 * Scrambles an enzyme element value for the enzyme pulse functionality.
	*
	* Donor code from previous DNA Console iteration.
	*
	* Arguments:
 * * input - Enzyme identity element to scramble, expected hex value
	* * rs - Strength of genetic damage pulse, increases the range of possible outcomes
 */
/obj/machinery/computer/scan_consolenew/proc/scramble(input,rs)
	var/length = length(input)
	var/ran = gaussian(0, rs*GENETIC_DAMAGE_STRENGTH_MULTIPLIER)
	if(ran == 0)
		ran = pick(-1,1) //hacky, statistically should almost never happen. 0-chance makes people mad though
	else if(ran < 0)
		ran = round(ran) //negative, so floor it
	else
		ran = -round(-ran) //positive, so ceiling it
	return num2hex(WRAP(hex2num(input)+ran, 0, 16**length), length)

	/**
	  * Performs the enzyme genetic damage pulse.
		*
		* Donor code from previous DNA Console iteration. Called from process() when
		* there is a genetic damage pulse in progress. Ends processing.
	  */
/obj/machinery/computer/scan_consolenew/proc/genetic_damage_pulse()
	// GUARD CHECK - Can we genetically modify the occupant? Includes scanner
	//  operational guard checks.
	// If we can't, abort the procedure.
	if(!can_modify_occupant() || (genetic_damage_pulse_type != GENETIC_DAMAGE_PULSE_UNIQUE_IDENTITY && genetic_damage_pulse_type != GENETIC_DAMAGE_PULSE_UNIQUE_FEATURES))
		genetic_damage_pulse_index = 0
		end_processing()
		return

	var/len
	switch(genetic_damage_pulse_type)
		if(GENETIC_DAMAGE_PULSE_UNIQUE_IDENTITY)
			len = length(scanner_occupant.dna.unique_identity)
		if(GENETIC_DAMAGE_PULSE_UNIQUE_FEATURES)
			len = length(scanner_occupant.dna.unique_features)

	var/num = randomize_GENETIC_DAMAGE_accuracy(genetic_damage_pulse_index, pulse_duration + (connected_scanner.precision_coeff ** 2), len) //Each manipulator level above 1 makes randomization as accurate as selected time + manipulator lvl^2  //Value is this high for the same reason as with laser - not worth the hassle of upgrading if the bonus is low

	var/hex
	switch(genetic_damage_pulse_type)
		if(GENETIC_DAMAGE_PULSE_UNIQUE_IDENTITY)
			hex = copytext(scanner_occupant.dna.unique_identity, num, num+1)
		if(GENETIC_DAMAGE_PULSE_UNIQUE_FEATURES)
			hex = copytext(scanner_occupant.dna.unique_features, num, num+1)

	hex = scramble(hex, pulse_strength, pulse_duration)

	switch(genetic_damage_pulse_type)
		if(GENETIC_DAMAGE_PULSE_UNIQUE_IDENTITY)
			scanner_occupant.dna.unique_identity = copytext(scanner_occupant.dna.unique_identity, 1, num) + hex + copytext(scanner_occupant.dna.unique_identity, num + 1)
		if(GENETIC_DAMAGE_PULSE_UNIQUE_FEATURES)
			scanner_occupant.dna.unique_features = copytext(scanner_occupant.dna.unique_features, 1, num) + hex + copytext(scanner_occupant.dna.unique_features, num + 1)
	scanner_occupant.updateappearance(mutcolor_update=1, mutations_overlay_update=1)

	genetic_damage_pulse_index = 0
	genetic_damage_pulse_type = null
	end_processing()
	return

/**
 * Sets the default state for the tgui interface.
 */
/obj/machinery/computer/scan_consolenew/proc/set_default_state()
	tgui_view_state["consoleMode"] = "storage"
	tgui_view_state["storageMode"] = "console"
	tgui_view_state["storageConsSubMode"] = "mutations"
	tgui_view_state["storageDiskSubMode"] = "mutations"

/**
 * Ejects the DNA Disk from the console.
	*
	* Will insert into the user's hand if possible, otherwise will drop it at the
	* console's location.
	*
	* Arguments:
 * * user - The mob that is attempting to eject the diskette.
 */
/obj/machinery/computer/scan_consolenew/proc/eject_disk(mob/user)
	// Check for diskette.
	if(!diskette)
		return

	to_chat(user, span_notice("You eject [diskette] from [src]."))

	// Reset the state to console storage.
	tgui_view_state["storageMode"] = "console"

	// If the disk shouldn't pop into the user's hand for any reason, drop it on the console instead.
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(diskette))
		diskette.forceMove(drop_location())
	diskette = null

/obj/machinery/computer/scan_consolenew/proc/set_connected_scanner(new_scanner)
	if(connected_scanner)
		UnregisterSignal(connected_scanner, COMSIG_QDELETING)
		if(connected_scanner.linked_console == src)
			connected_scanner.set_linked_console(null)
	connected_scanner = new_scanner
	if(connected_scanner)
		RegisterSignal(connected_scanner, COMSIG_QDELETING, PROC_REF(react_to_scanner_del))
		connected_scanner.set_linked_console(src)

/obj/machinery/computer/scan_consolenew/proc/react_to_scanner_del(datum/source)
	SIGNAL_HANDLER
	set_connected_scanner(null)

#undef MIN_ACTIVATOR_TIMEOUT
#undef ACTIVATOR_COOLDOWN_MULTIPLIER
#undef MIN_INJECTOR_TIMEOUT
#undef INJECTOR_COOLDOWN_MULTIPLIER

#undef MIN_ADVANCED_TIMEOUT
#undef ADVANCED_COOLDOWN_MULTIPLIER

#undef MISC_INJECTOR_TIMEOUT

#undef GENETIC_DAMAGE_PULSE_UNIQUE_IDENTITY
#undef GENETIC_DAMAGE_PULSE_UNIQUE_FEATURES

#undef ENZYME_COPY_BASE_COOLDOWN
#undef NUMBER_OF_BUFFERS
#undef SCRAMBLE_TIMEOUT
#undef JOKER_TIMEOUT
#undef JOKER_UPGRADE

#undef GENETIC_DAMAGE_STRENGTH_MAX
#undef GENETIC_DAMAGE_STRENGTH_MULTIPLIER

#undef GENETIC_DAMAGE_DURATION_MAX
#undef GENETIC_DAMAGE_ACCURACY_MULTIPLIER

#undef GENETIC_DAMAGE_IRGENETIC_DAMAGE_MULTIPLIER

#undef STATUS_TRANSFORMING

#undef SEARCH_OCCUPANT
#undef SEARCH_STORED
#undef SEARCH_DISKETTE
#undef SEARCH_ADV_INJ

#undef CLEAR_GENE
#undef NEXT_GENE
#undef PREV_GENE
