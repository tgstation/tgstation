#define INJECTOR_TIMEOUT 100
#define NUMBER_OF_BUFFERS 3
#define SCRAMBLE_TIMEOUT 600
#define JOKER_TIMEOUT 12000				//20 minutes
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
	name = "DNA Console"
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
	///Amount of UI/UEs we can store
	var/list/genetic_makeup_buffer[NUMBER_OF_BUFFERS]
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

	var/rad_pulse_index = 0
	var/rad_pulse_timer = 0

	var/can_use_scanner = FALSE
	var/is_viable_occupant = FALSE
	var/is_scramble_ready = FALSE
	var/is_joker_ready = FALSE
	var/is_injector_ready = FALSE
	var/is_pulsing_rads = FALSE
	var/time_to_scramble = 0
	var/time_to_joker = 0
	var/time_to_injector = 0
	var/time_to_pulse = 0
	var/obj/machinery/dna_scannernew/connected_scanner = null
	var/mob/living/carbon/scanner_occupant = null
	var/list/tgui_occupant_mutations = list()
	var/list/tgui_scanner_mutations = list()
	var/list/tgui_diskette_mutations = list()
	var/list/tgui_scanner_chromosomes = list()
	var/list/tgui_genetic_makeup = list()
	var/list/tgui_advinjector_mutations = list()

/obj/machinery/computer/scan_consolenew/process()
	. = ..()

	if((rad_pulse_index > 0) && (rad_pulse_timer <= world.time))
		rad_pulse()
		return

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/chromosome))
		if(LAZYLEN(stored_chromosomes) < max_chromosomes)
			I.forceMove(src)
			stored_chromosomes += I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
		else
			to_chat(user, "<span class='warning'>You cannot store any more chromosomes!</span>")
		return
	if (istype(I, /obj/item/disk/data)) //INSERT SOME DISKETTES
		if (!user.transferItemToLoc(I,src))
			return
		if(diskette)
			diskette.forceMove(drop_location())
			diskette = null
		diskette = I
		to_chat(user, "<span class='notice'>You insert [I].</span>")
		updateUsrDialog()
		return
	if(istype(I, /obj/item/dnainjector/activator))
		var/obj/item/dnainjector/activator/A = I
		if(A.used)
			to_chat(user,"<span class='notice'>Recycled [I].</span>")
			if(A.research)
				if(prob(60))
					var/c_typepath = generate_chromosome()
					var/obj/item/chromosome/CM = new c_typepath (drop_location())
					if(LAZYLEN(stored_chromosomes) < max_chromosomes)
						CM.forceMove(src)
						stored_chromosomes += CM
						to_chat(user,"<span class='notice'>[capitalize(CM.name)] added to storage.</span>")
					else
						to_chat(user, "<span class='warning'>You cannot store any more chromosomes!</span>")
						to_chat(user, "<span class='notice'>[capitalize(CM.name)] added on top of the console.</span>")
				else
					to_chat(user, "<span class='notice'>There was not enough genetic data to extract a viable chromosome.</span>")
			qdel(I)
			return
	else
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

	build_genetic_makeup_list()

	is_scramble_ready = (scrambleready < world.time)
	time_to_scramble = round((scrambleready - world.time)/10)

	is_joker_ready = (jokerready < world.time)
	time_to_joker = round((jokerready - world.time)/10)

	is_injector_ready = (injectorready < world.time)
	time_to_injector = round((injectorready - world.time)/10)

	is_pulsing_rads = ((rad_pulse_index > 0) && (rad_pulse_timer > world.time))
	time_to_pulse = round((rad_pulse_timer - world.time)/10)

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
		data["RadStrength"] = radstrength
		data["RadDuration"] = radduration
		data["StdDevStr"] = radstrength*RADIATION_STRENGTH_MULTIPLIER
		switch(RADIATION_ACCURACY_MULTIPLIER/(radduration + (connected_scanner.precision_coeff ** 2)))	//hardcoded values from a z-table for a normal distribution
			if(0 to 0.25)
				data["StdDevAcc"] = ">95 %"
			if(0.25 to 0.5)
				data["StdDevAcc"] = "68-95 %"
			if(0.5 to 0.75)
				data["StdDevAcc"] = "55-68 %"
			else
				data["StdDevAcc"] = "<38 %"

	data["IsViableSubject"] = is_viable_occupant
	if(is_viable_occupant)
		data["SubjectName"] = scanner_occupant.name
		data["SubjectStatus"] = scanner_occupant.stat
		data["SubjectHealth"] = scanner_occupant.health
		data["SubjectRads"] = scanner_occupant.radiation/(RAD_MOB_SAFE/100)
		data["SubjectEnzymes"] = scanner_occupant.dna.unique_enzymes

		var/text_sequence = scanner_occupant.dna.uni_identity
		var/list/list_sequence = list()

		for(var/i in 1 to LAZYLEN(text_sequence))
			list_sequence += text_sequence[i];

		data["SubjectUNI"] = text_sequence
		data["SubjectUNIList"] = list_sequence
		data["SubjectMutations"] = tgui_occupant_mutations
	else
		data["SubjectName"] = null
		data["SubjectStatus"] = null
		data["SubjectHealth"] = null
		data["SubjectRads"] = null
		data["SubjectEnzymes"] = null
		data["SubjectMutations"] = null

	data["HasDelayedAction"] = (delayed_action != null)
	data["IsScrambleReady"] = is_scramble_ready
	data["IsJokerReady"] = is_joker_ready
	data["IsInjectorReady"] = is_injector_ready
	data["ScrambleSeconds"] = time_to_scramble
	data["JokerSeconds"] = time_to_joker
	data["InjectorSeconds"] = time_to_injector
	data["IsPulsingRads"] = is_pulsing_rads
	data["RadPulseSeconds"] = time_to_pulse

	if(diskette != null)
		data["HasDisk"] = TRUE
		data["DiskCapacity"] = diskette.max_mutations - LAZYLEN(diskette.mutations)
		data["DiskReadOnly"] = diskette.read_only
		data["DiskMutations"] = tgui_diskette_mutations
		data["DiskHasMakeup"] = (LAZYLEN(diskette.genetic_makeup_buffer) > 0)
		data["DiskMakeupBuffer"] = diskette.genetic_makeup_buffer.Copy()
	else
		data["HasDisk"] = FALSE
		data["DiskCapacity"] = 0
		data["DiskReadOnly"] = TRUE
		data["DiskMutations"] = null
		data["DiskHasMakeup"] = FALSE
		data["DiskMakeupBuffer"] = null

	data["MutationCapacity"] = max_storage - LAZYLEN(stored_mutations)
	data["MutationStorage"] = tgui_scanner_mutations
	data["ChromoCapacity"] = max_chromosomes - LAZYLEN(stored_chromosomes)
	data["ChromoStorage"] = tgui_scanner_chromosomes
	data["MakeupCapcity"] = NUMBER_OF_BUFFERS
	data["MakeupStorage"] = tgui_genetic_makeup

	data["AdvInjectors"] = tgui_advinjector_mutations
	data["MaxAdvInjectors"] = max_injector_selections

	data["CONSCIOUS"] = CONSCIOUS
	data["UNCONSCIOUS"] = UNCONSCIOUS
	data["GENES"] = genes
	data["REVERSEGENES"] = reversegenes
	data["CHROMOSONE_NEVER"] = CHROMOSOME_NEVER
	data["CHROMOSOME_NONE"] = CHROMOSOME_NONE
	data["CHROMOSOME_USED"] = CHROMOSOME_USED
	data["MUT_NORMAL"] = MUT_NORMAL
	data["MUT_EXTRA"] = MUT_EXTRA
	data["MUT_OTHER"] = MUT_OTHER
	data["RADIATION_DURATION_MAX"] = RADIATION_DURATION_MAX
	data["RADIATION_STRENGTH_MAX"] = RADIATION_STRENGTH_MAX
	data["DNA_BLOCK_SIZE"] = DNA_BLOCK_SIZE

	return data

/obj/machinery/computer/scan_consolenew/ui_act(action, params)
	if(..())
		return

	add_fingerprint(usr)
	usr.set_machine(src)

	switch(action)
		if("connect_scanner")
			connect_to_scanner()
			return
		if("toggle_door")
			if(scanner_operational())
				connected_scanner.toggle_open(usr)
			return
		if("toggle_lock")
			if(scanner_operational())
				connected_scanner.locked = !connected_scanner.locked
			return
		if("scramble_dna")
			if(can_modify_occupant() && (scrambleready < world.time))
				scanner_occupant.dna.remove_all_mutations(list(MUT_NORMAL, MUT_EXTRA))
				scanner_occupant.dna.generate_dna_blocks()
				scrambleready = world.time + SCRAMBLE_TIMEOUT
				to_chat(usr,"<span class'notice'>DNA scrambled.</span>")
				scanner_occupant.radiation += RADIATION_STRENGTH_MULTIPLIER*50/(connected_scanner.damage_coeff ** 2)
		if("check_discovery")
			if(!(scanner_occupant == connected_scanner.occupant) || !can_modify_occupant())
				return
			check_discovery(params["alias"])
		if("pulse_gene") // params.pos and params.gene and params.alias
			// Check for cheese
			// can_modify_occupant() also checks that there is an operational and
			// connected DNA Scanner, which is important for later code.
			if(!(scanner_occupant == connected_scanner.occupant) || !can_modify_occupant())
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

			if((newgene == "J") && (jokerready < world.time))
				var/truegenes = GET_SEQUENCE(path)
				newgene = truegenes[genepos]
				jokerready = world.time + JOKER_TIMEOUT - (JOKER_UPGRADE * (connected_scanner.precision_coeff-1))

			// Copy genome into scanner occupant and do some basic mutation checks as we've increased rads
			sequence = copytext_char(sequence, 1, genepos) + newgene + copytext_char(sequence, genepos + 1)
			scanner_occupant.dna.mutation_index[path] = sequence
			scanner_occupant.radiation += RADIATION_STRENGTH_MULTIPLIER/connected_scanner.damage_coeff
			scanner_occupant.domutcheck()

			// Check if we cracked this new mutation
			check_discovery(alias)
		if("apply_chromo")
			// Check for cheese
			if(!(scanner_occupant == connected_scanner.occupant) || !can_modify_occupant())
				return

			var/bref = params["mutref"]

			// Make sure they have the mutation
			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(!HM)
				return

			// Look through our stored chromos and compare names to find a
			// stored chromo we can apply.
			for(var/obj/item/chromosome/CM in stored_chromosomes)
				if(CM.can_apply(HM) && (CM.name == params["chromo"]))
					stored_chromosomes -= CM
					CM.apply(HM)
		if("print_injector")
			// Because printing mutators and activators share a bunch of code,
			// it makes sense to keep them both together and set unique vars
			// later in the code

			// As a side note, because mutations can contain unique metadata,
			// this system uses BYOND Atom Refs to safely and accurately
			// identify mutations from big ol' lists.

			// Make sure the injector is actually ready.
			if(world.time < injectorready)
				return

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(!HM)
				return

			var/obj/item/dnainjector/activator/I = new /obj/item/dnainjector/activator(loc)
			I.add_mutations += new HM.type(copymut = HM)

			var/is_activator = text2num(params["is_activator"])

			if(is_activator)
				I.name = "[HM.name] activator"
				I.research = TRUE
				if(scanner_operational())
					I.damage_coeff = connected_scanner.damage_coeff*4
					injectorready = world.time + INJECTOR_TIMEOUT * (1 - 0.1 * connected_scanner.precision_coeff)
				else
					injectorready = world.time + INJECTOR_TIMEOUT
			else
				I.name = "[HM.name] mutator"
				I.doitanyway = TRUE
				if(scanner_operational())
					I.damage_coeff = connected_scanner.damage_coeff
					injectorready = world.time + INJECTOR_TIMEOUT * 5 * (1 - 0.1 * connected_scanner.precision_coeff)
				else
					injectorready = world.time + INJECTOR_TIMEOUT * 5
		if("save_console")
			// Can only be done from the scanner occupant / genetic sequencer
			if(!can_modify_occupant())
				return

			if(LAZYLEN(stored_mutations) >= max_storage)
				to_chat(usr,"<span class='warning'>Mutation storage is full.</span>")
				return

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(!HM)
				return

			var/datum/mutation/human/A = new HM.type()
			A.copy_mutation(HM)
			stored_mutations += A
			to_chat(usr,"<span class='notice'>Mutation succesfully stored.</span>")
			return
		if("save_disk")
			if(!diskette)
				return

			if(LAZYLEN(diskette.mutations) >= diskette.max_mutations)
				to_chat(usr,"<span class='warning'>Disk storage is full.</span>")
				return

			if(diskette.read_only)
				to_chat(usr,"<span class='warning'>Disk is set to read only mode.</span>")
				return

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(!HM)
				return

			var/datum/mutation/human/A = new HM.type()
			A.copy_mutation(HM)
			diskette.mutations += A
			to_chat(usr,"<span class='notice'>Mutation succesfully stored to disk.</span>")
		if("nullify")
			if(!can_modify_occupant())
				return

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(!HM)
				return

			// Nullify should only be used on scrambled or "extra" mutations.
			if(!HM.scrambled && !(HM.class == MUT_EXTRA))
				return

			scanner_occupant.dna.remove_mutation(HM.type)
		if("delete_console_mut")
			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(HM)
				stored_mutations.Remove(HM)
				qdel(HM)
		if("delete_disk_mut")
			if(!diskette)
				return

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(HM)
				diskette.mutations.Remove(HM)
				qdel(HM)
		if("eject_chromo")
			var/chromname = params["chromo"]
			for(var/obj/item/chromosome/CM in stored_chromosomes)
				if(chromname == CM.name)
					CM.forceMove(drop_location())
					adjust_item_drop_location(CM)
					stored_chromosomes -= CM
					return
		if("combine_console")
			if(LAZYLEN(stored_mutations) >= max_storage)
				to_chat(usr,"<span class='warning'>Mutation storage is full.</span>")
				return

			if(!stored_research)
				return

			var/result_path = get_mixed_mutation(params["srctype"], params["desttype"])

			if(!result_path)
				return

			stored_mutations += new result_path()
			to_chat(usr, "<span class='boldnotice'>Success! New mutation has been added to storage</span>")

			if(result_path in stored_research.discovered_mutations)
				return

			stored_research.discovered_mutations += result_path
		if("combine_disk")
			if(!diskette)
				return

			if(LAZYLEN(diskette.mutations) >= diskette.max_mutations)
				to_chat(usr,"<span class='warning'>Disk storage is full.</span>")
				return

			if(diskette.read_only)
				to_chat(usr,"<span class='warning'>Disk is set to read only mode.</span>")
				return

			if(!stored_research)
				return

			var/result_path = get_mixed_mutation(params["srctype"], params["desttype"])

			if(!result_path)
				return

			diskette.mutations += new result_path()
			to_chat(usr, "<span class='boldnotice'>Success! New mutation has been added to the disk.</span>")

			if(result_path in stored_research.discovered_mutations)
				return

			stored_research.discovered_mutations += result_path
		if("set_pulse_strength")
			var/value = round(text2num(params["val"]))
			radstrength = WRAP(value, 1, RADIATION_STRENGTH_MAX+1)
			return
		if("set_pulse_duration")
			var/value = round(text2num(params["val"]))
			radduration = WRAP(value, 1, RADIATION_DURATION_MAX+1)
			return
		if("save_makeup_disk")
			if(!diskette)
				return

			if(diskette.read_only)
				to_chat(usr,"<span class='warning'>Disk is set to read only mode.</span>")
				return

			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)

			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			if(istype(buffer_slot))
				diskette.genetic_makeup_buffer = buffer_slot.Copy()
		if("load_makeup_disk")
			if(!diskette)
				return

			if(istype(diskette.genetic_makeup_buffer))
				var/buffer_index = text2num(params["index"])
				buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
				genetic_makeup_buffer[buffer_index] = diskette.genetic_makeup_buffer.Copy()
				return
		if("del_makeup_disk")
			if(!diskette)
				return

			if(diskette.read_only)
				to_chat(usr,"<span class='warning'>Disk is set to read only mode.</span>")
				return

			diskette.genetic_makeup_buffer = null
		if("set_makeup_label")
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)

			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			if(istype(buffer_slot))
				buffer_slot[buffer_index]["label"] = params["label"]
		if("save_makeup_console")
			if(!can_modify_occupant())
				return

			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			genetic_makeup_buffer[buffer_index] = list(
				"label"="Slot [buffer_index]:[scanner_occupant.real_name]",
				"UI"=scanner_occupant.dna.uni_identity,
				"UE"=scanner_occupant.dna.unique_enzymes,
				"name"=scanner_occupant.real_name,
				"blood_type"=scanner_occupant.dna.blood_type)
		if("del_makeup_console")
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]
			if(istype(buffer_slot))
				genetic_makeup_buffer[buffer_index] = null
		if("eject_disk")
			if(diskette)
				diskette.forceMove(drop_location())
				diskette = null
		if("makeup_injector")
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			if(!istype(buffer_slot))
				return

			var/type = params["type"]
			var/obj/item/dnainjector/timed/I

			switch(type)
				if("ui")
					if(buffer_slot["UI"])
						I = new /obj/item/dnainjector/timed(loc)
						I.fields = list("UI"=buffer_slot["UI"])
						if(scanner_operational())
							I.damage_coeff = connected_scanner.damage_coeff
						return
				if("ue")
					if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
						I = new /obj/item/dnainjector/timed(loc)
						I.fields = list("name"=buffer_slot["name"], "UE"=buffer_slot["UE"], "blood_type"=buffer_slot["blood_type"])
						if(scanner_operational())
							I.damage_coeff  = connected_scanner.damage_coeff
						return
				if("mixed")
					if(buffer_slot["UI"] && buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
						I = new /obj/item/dnainjector/timed(loc)
						I.fields = list("UI"=buffer_slot["UI"],"name"=buffer_slot["name"], "UE"=buffer_slot["UE"], "blood_type"=buffer_slot["blood_type"])
						if(scanner_operational())
							I.damage_coeff = connected_scanner.damage_coeff
						return
			if(I)
				injectorready = world.time + INJECTOR_TIMEOUT
		if("makeup_apply")
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			if(!istype(buffer_slot))
				return

			var/type = params["type"]

			if((type != "ui") && (type != "ue") && (type != "mixed"))
				return

			apply_genetic_makeup(type, buffer_slot)

		if("makeup_delay")
			var/buffer_index = text2num(params["index"])
			buffer_index = clamp(buffer_index, 1, NUMBER_OF_BUFFERS)
			var/list/buffer_slot = genetic_makeup_buffer[buffer_index]

			if(!istype(buffer_slot))
				return

			var/type = params["type"]

			if((type != "ui") && (type != "ue") && (type != "mixed"))
				return

			delayed_action = list("type" = type, "buffer_slot" = buffer_slot)
		if("makeup_pulse")
			if(!can_modify_occupant())
				return

			var/len = length_char(scanner_occupant.dna.uni_identity)
			rad_pulse_timer = world.time + (radduration*10)
			rad_pulse_index = WRAP(text2num(params["index"]), 1, len+1)
		if("cancel_delay")
			delayed_action = null
		if("new_adv_inj")
			if(!(LAZYLEN(injector_selection) < max_injector_selections))
				return

			var/inj_name = params["name"]

			inj_name = trim(sanitize(inj_name))

			if(!inj_name || (inj_name in injector_selection))
				return

			injector_selection[inj_name] = list()
		if("del_adv_inj")
			var/inj_name = params["name"]

			if(!inj_name || !(inj_name in injector_selection))
				return

			injector_selection.Remove(inj_name)
		if("print_adv_inj")
			// Because printing mutators and activators share a bunch of code,
			// it makes sense to keep them both together and set unique vars
			// later in the code

			// As a side note, because mutations can contain unique metadata,
			// this system uses BYOND Atom Refs to safely and accurately
			// identify mutations from big ol' lists.

			// Make sure the injector is actually ready.
			if(world.time < injectorready)
				return

			var/inj_name = params["name"]

			if(!inj_name || !(inj_name in injector_selection))
				return

			var/list/injector = injector_selection[inj_name]

			var/obj/item/dnainjector/activator/I = new /obj/item/dnainjector/activator(loc)

			for(var/A in injector)
				var/datum/mutation/human/HM = A
				I.add_mutations += new HM.type(copymut=HM)
			I.doitanyway = TRUE
			I.name = "Advanced [inj_name] injector"

			if(scanner_operational())
				I.damage_coeff = connected_scanner.damage_coeff
				injectorready = world.time + INJECTOR_TIMEOUT * 8 * (1 - 0.1 * connected_scanner.precision_coeff)
			else
				injectorready = world.time + INJECTOR_TIMEOUT * 8
		if("add_adv_mut")
			// Can only be done from the scanner occupant / genetic sequencer
			if(!can_modify_occupant())
				return

			var/adv_inj = params["advinj"]

			if(!(adv_inj in injector_selection))
				return

			if(LAZYLEN(injector_selection[adv_inj]) >= max_injector_mutations)
				to_chat(usr,"<span class='warning'>Advanced injector mutation storage is full.</span>")
				return

			var/bref = params["mutref"]
			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(!HM)
				return

			var/instability_total = HM.instability

			for(var/datum/mutation/human/I in injector_selection[adv_inj])
				instability_total += I.instability * GET_MUTATION_STABILIZER(I)

			if(instability_total > max_injector_instability)
				to_chat(usr,"<span class='warning'>Advanced injector mutations too instable.</span>")
				return

			var/datum/mutation/human/A = new HM.type()
			A.copy_mutation(HM)
			injector_selection[adv_inj] += A
			to_chat(usr,"<span class='notice'>Mutation succesfully added to advanced injector.</span>")
			return
		if("del_adv_mut")
			var/adv_inj = params["advinj"]

			if(!(adv_inj in injector_selection))
				return

			var/bref = params["mutref"]

			var/datum/mutation/human/HM = get_mut_by_ref(bref)

			if(HM)
				injector_selection[adv_inj].Remove(HM)
				qdel(HM)
	return

/obj/machinery/computer/scan_consolenew/proc/apply_genetic_makeup(type, buffer_slot)
	if(!can_modify_occupant())
		return

	var/rad_increase = rand(100/(connected_scanner.damage_coeff ** 2),250/(connected_scanner.damage_coeff ** 2))

	switch(type)
		if("ui")
			if(buffer_slot["UI"])
				scanner_occupant.dna.uni_identity = buffer_slot["UI"]
				scanner_occupant.updateappearance(mutations_overlay_update=1)
			scanner_occupant.radiation += rad_increase
			return
		if("ue")
			if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
				scanner_occupant.real_name = buffer_slot["name"]
				scanner_occupant.name = buffer_slot["name"]
				scanner_occupant.dna.unique_enzymes = buffer_slot["UE"]
				scanner_occupant.dna.blood_type = buffer_slot["blood_type"]
			scanner_occupant.radiation += rad_increase
			return
		if("mixed")
			if(buffer_slot["UI"])
				scanner_occupant.dna.uni_identity = buffer_slot["UI"]
				scanner_occupant.updateappearance(mutations_overlay_update=1)
			if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
				scanner_occupant.real_name = buffer_slot["name"]
				scanner_occupant.name = buffer_slot["name"]
				scanner_occupant.dna.unique_enzymes = buffer_slot["UE"]
				scanner_occupant.dna.blood_type = buffer_slot["blood_type"]
			scanner_occupant.radiation += rad_increase
			return

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
				connected_scanner.linked_console = src
				return
			else
				broken_scanner = test_scanner

	// Ultimately, if we have a broken scanner, we'll attempt to connect to it as
	// a fallback case, but the code above will prefer a working scanner
	if(!isnull(broken_scanner))
		connected_scanner = broken_scanner
		connected_scanner.linked_console = src

// Called by DNA Scanners when they close
/obj/machinery/computer/scan_consolenew/proc/on_scanner_close()
	if(!can_modify_occupant())
		return

	scanner_occupant = connected_scanner.occupant

	if(delayed_action)
		to_chat(connected_scanner.occupant, "<span class='notice'>[src] activates!</span>")
		var/type = delayed_action["type"]
		var/buffer_slot = delayed_action["buffer_slot"]
		apply_genetic_makeup(type, buffer_slot)
		delayed_action = null

// Called by DNA Scanners when they open
/obj/machinery/computer/scan_consolenew/proc/on_scanner_open()
	rad_pulse_index = 0
	rad_pulse_timer = 0
	scanner_occupant = null

/obj/machinery/computer/scan_consolenew/proc/build_genetic_makeup_list()
	if(tgui_genetic_makeup)
		tgui_genetic_makeup.Cut()
	else
		tgui_genetic_makeup = list()

	for(var/i=1, i <= NUMBER_OF_BUFFERS, i++)
		if(genetic_makeup_buffer[i])
			tgui_genetic_makeup["[i]"] = genetic_makeup_buffer[i].Copy()
		else
			tgui_genetic_makeup["[i]"] = null

/obj/machinery/computer/scan_consolenew/proc/build_mutation_list()
	if(!can_modify_occupant())
		tgui_occupant_mutations = null
		return

	if(tgui_occupant_mutations)
		tgui_occupant_mutations.Cut()
	else
		tgui_occupant_mutations = list()

	if(tgui_diskette_mutations)
		tgui_diskette_mutations.Cut()
	else
		tgui_diskette_mutations = list()

	tgui_scanner_mutations.Cut()
	tgui_scanner_chromosomes.Cut()
	tgui_advinjector_mutations.Cut()

	var/index = 1
	if(can_modify_occupant())
		// Start cataloguing all "default" mutations that the occupant has by default
		for(var/mutation_type in scanner_occupant.dna.mutation_index)
			var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation_type)

			var/list/mutation_data = list()
			var/text_sequence = scanner_occupant.dna.mutation_index[mutation_type]
			var/list/list_sequence = list()

			for(var/i in 1 to LAZYLEN(text_sequence))
				list_sequence += text_sequence[i];

			var/discovered = (stored_research && (mutation_type in stored_research.discovered_mutations))

			mutation_data["Alias"] = HM.alias
			mutation_data["Sequence"] = text_sequence
			mutation_data["SeqList"] = list_sequence
			mutation_data["Discovered"] = discovered

			if(discovered)
				mutation_data["Name"] = HM.name
				mutation_data["Description"] = HM.desc
				mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)

			var/mut_class = MUT_NORMAL
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

			if (mut_class == MUT_EXTRA)
				mutation_data["Image"] = "dna_extra.gif"
			else if(stored_research && (mutation_type in stored_research.discovered_mutations))
				mutation_data["Image"] = "dna_discovered.gif"
			else
				mutation_data["Image"] = "dna_undiscovered.gif"

			tgui_occupant_mutations["[index]"] = mutation_data
			index++

		// Now get additional/"extra" mutations that they shouldn't have by default
		for(var/datum/mutation/human/HM in scanner_occupant.dna.mutations)
			// If it's in the mutation index array, we've already catalogued this
			// mutation and can safely skip over it.
			if(HM.type in scanner_occupant.dna.mutation_index)
				break

			var/list/mutation_data = list()
			var/text_sequence = GET_SEQUENCE(HM.type)
			var/list/list_sequence = list()

			for(var/i in 1 to LAZYLEN(text_sequence))
				list_sequence += text_sequence[i];

			var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(HM.type)

			mutation_data["Alias"] = A.alias
			mutation_data["Sequence"] = text_sequence
			mutation_data["SeqList"] = list_sequence
			mutation_data["Discovered"] = TRUE

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

			tgui_occupant_mutations["[index]"] = mutation_data
			index++

	index = 1
	for(var/datum/mutation/human/HM in stored_mutations)
		var/list/mutation_data = list()

		var/text_sequence = GET_SEQUENCE(HM.type)
		var/list/list_sequence = list()

		for(var/i in 1 to LAZYLEN(text_sequence))
			list_sequence += text_sequence[i];

		var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(HM.type)

		mutation_data["Alias"] = A.alias
		mutation_data["SeqList"] = list_sequence
		mutation_data["Name"] = HM.name
		mutation_data["Description"] = HM.desc
		mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)
		mutation_data["ByondRef"] = REF(HM)
		mutation_data["Type"] = HM.type

		mutation_data["CanChromo"] = HM.can_chromosome
		if(HM.can_chromosome)
			mutation_data["ValidChromos"] = jointext(HM.valid_chrom_list, ", ")
			mutation_data["AppliedChromo"] = HM.chromosome_name
			mutation_data["ValidStoredChromos"] = build_chrom_list(HM)

		tgui_scanner_mutations["[index]"] = mutation_data
		index++

	index = 1
	for(var/obj/item/chromosome/CM in stored_chromosomes)
		var/list/chromo_data = list()

		chromo_data["Name"] = CM.name
		chromo_data["Description"] = CM.desc

		tgui_scanner_chromosomes["[index]"] = chromo_data
		index++

	index = 1

	if(diskette)
		for(var/datum/mutation/human/HM in diskette.mutations)
			var/list/mutation_data = list()

			var/text_sequence = GET_SEQUENCE(HM.type)
			var/list/list_sequence = list()

			for(var/i in 1 to LAZYLEN(text_sequence))
				list_sequence += text_sequence[i];

			var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(HM.type)

			mutation_data["Alias"] = A.alias
			mutation_data["SeqList"] = list_sequence
			mutation_data["Name"] = HM.name
			mutation_data["Description"] = HM.desc
			mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)
			mutation_data["ByondRef"] = REF(HM)
			mutation_data["Type"] = HM.type

			mutation_data["CanChromo"] = HM.can_chromosome
			if(HM.can_chromosome)
				mutation_data["ValidChromos"] = jointext(HM.valid_chrom_list, ", ")
				mutation_data["AppliedChromo"] = HM.chromosome_name
				mutation_data["ValidStoredChromos"] = build_chrom_list(HM)

			tgui_diskette_mutations["[index]"] = mutation_data
			index += 1

	index = 1

	if(LAZYLEN(injector_selection))
		for(var/I in injector_selection)
			tgui_advinjector_mutations["[I]"] = list()
			for(var/datum/mutation/human/HM in injector_selection[I])
				var/list/mutation_data = list()

				var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(HM.type)

				mutation_data["Alias"] = A.alias
				mutation_data["Name"] = HM.name
				mutation_data["Description"] = HM.desc
				mutation_data["Instability"] = HM.instability * GET_MUTATION_STABILIZER(HM)
				mutation_data["ByondRef"] = REF(HM)
				mutation_data["Type"] = HM.type

				if(HM.can_chromosome)
					mutation_data["AppliedChromo"] = HM.chromosome_name

				tgui_advinjector_mutations["[I]"]["[index]"] = mutation_data
				index += 1


/obj/machinery/computer/scan_consolenew/proc/build_chrom_list(mutation)
	var/list/chromosomes = list()

	for(var/obj/item/chromosome/CM in stored_chromosomes)
		if(CM.can_apply(mutation))
			chromosomes += CM.name

	return chromosomes

/obj/machinery/computer/scan_consolenew/proc/check_discovery(alias)
	if(!(scanner_occupant == connected_scanner.occupant) || !can_modify_occupant())
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

/obj/machinery/computer/scan_consolenew/proc/get_mut_by_ref(ref)
	var/mutation

	if(can_modify_occupant())
		mutation = (locate(ref) in scanner_occupant.dna.mutations)
		if(mutation)
			return mutation

	mutation = (locate(ref) in stored_mutations)
	if(mutation)
		return mutation

	if(diskette)
		mutation = (locate(ref) in diskette.mutations)
		if(mutation)
			return mutation

	if(injector_selection)
		for(var/I in injector_selection)
			mutation = (locate(ref) in injector_selection["[I]"])
			if(mutation)
				return mutation

	return null

/obj/machinery/computer/scan_consolenew/proc/randomize_radiation_accuracy(position, radduration, number_of_blocks)
	var/val = round(gaussian(0, RADIATION_ACCURACY_MULTIPLIER/radduration) + position, 1)
	return WRAP(val, 1, number_of_blocks+1)

/obj/machinery/computer/scan_consolenew/proc/scramble(input,rs,rd) //hexadecimal genetics. dont confuse with scramble button
	var/length = length(input)
	var/ran = gaussian(0, rs*RADIATION_STRENGTH_MULTIPLIER)
	if(ran == 0)
		ran = pick(-1,1)	//hacky, statistically should almost never happen. 0-chance makes people mad though
	else if(ran < 0)
		ran = round(ran)	//negative, so floor it
	else
		ran = -round(-ran)	//positive, so ceiling it
	return num2hex(WRAP(hex2num(input)+ran, 0, 16**length), length)

/obj/machinery/computer/scan_consolenew/proc/rad_pulse()
	if(!can_modify_occupant())
		rad_pulse_index = 0
		rad_pulse_timer = 0
		return

	var/len = length_char(scanner_occupant.dna.uni_identity)
	var/num = randomize_radiation_accuracy(rad_pulse_index, radduration + (connected_scanner.precision_coeff ** 2), len) //Each manipulator level above 1 makes randomization as accurate as selected time + manipulator lvl^2																																																		 //Value is this high for the same reason as with laser - not worth the hassle of upgrading if the bonus is low
	var/hex = copytext_char(scanner_occupant.dna.uni_identity, num, num+1)
	hex = scramble(hex, radstrength, radduration)

	scanner_occupant.dna.uni_identity = copytext_char(scanner_occupant.dna.uni_identity, 1, num) + hex + copytext_char(scanner_occupant.dna.uni_identity, num + 1)
	scanner_occupant.updateappearance(mutations_overlay_update=1)

	rad_pulse_index = 0
	return


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
