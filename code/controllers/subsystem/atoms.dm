var/datum/controller/subsystem/atoms/SSatoms

#define INITIALIZATION_INSSATOMS 0	//New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 1	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 2	//New should call Initialize(FALSE)

/datum/controller/subsystem/atoms
	name = "Atoms"
	init_order = 11
	flags = SS_NO_FIRE

	var/initialized = INITIALIZATION_INSSATOMS
	var/old_initialized

	var/list/blueprints_cache = list()
	var/list/recipes_cache	

/datum/controller/subsystem/atoms/New()
	NEW_SS_GLOBAL(SSatoms)

/datum/controller/subsystem/atoms/Initialize(timeofday)
	fire_overlay.appearance_flags = RESET_COLOR
	setupGenetics() //to set the mutations' place in structural enzymes, so monkey.initialize() knows where to put the monkey mutation.
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	InitConstruction()
	return ..()

/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms = null)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	var/list/late_loaders

	initialized = INITIALIZATION_INNEW_MAPLOAD

	if(atoms)
		for(var/I in atoms)
			var/atom/A = I
			if(!A.initialized)	//this check is to make sure we don't call it twice on an object that was created in a previous Initialize call
				if(QDELETED(A))
					stack_trace("Found new qdeletion in type [A.type]!")
					continue
				var/start_tick = world.time
				if(A.Initialize(TRUE))
					LAZYADD(late_loaders, A)
				if(start_tick != world.time)
					WARNING("[A]: [A.type] slept during it's Initialize!")
				CHECK_TICK
		testing("Initialized [atoms.len] atoms")
	else
		#ifdef TESTING
		var/count = 0
		#endif
		for(var/atom/A in world)
			if(!A.initialized)	//this check is to make sure we don't call it twice on an object that was created in a previous Initialize call
				if(QDELETED(A))
					stack_trace("Found new qdeletion in type [A.type]!")
					continue
				var/start_tick = world.time
				if(A.Initialize(TRUE))
					LAZYADD(late_loaders, A)
				#ifdef TESTING
				else
					++count
				#endif TESTING
				if(start_tick != world.time)
					WARNING("[A]: [A.type] slept during it's Initialize!")
				CHECK_TICK
		testing("Roundstart initialized [count] atoms")

	initialized = INITIALIZATION_INNEW_REGULAR

	if(late_loaders)
		for(var/I in late_loaders)
			var/atom/A = I
			var/start_tick = world.time
			A.Initialize(FALSE)
			if(start_tick != world.time)
				WARNING("[A]: [A.type] slept during it's Initialize!")
			CHECK_TICK
		testing("Late-initialized [late_loaders.len] atoms")

/datum/controller/subsystem/atoms/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/atoms/proc/map_loader_stop()
	initialized = old_initialized

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSatoms.old_initialized

	blueprints_cache = SSatoms.blueprints_cache
	recipes_cache = SSatoms.recipes_cache

	flags |= SS_NO_INIT

/datum/controller/subsystem/atoms/proc/setupGenetics()
	var/list/avnums = new /list(DNA_STRUC_ENZYMES_BLOCKS)
	for(var/i=1, i<=DNA_STRUC_ENZYMES_BLOCKS, i++)
		avnums[i] = i
		CHECK_TICK

	for(var/A in subtypesof(/datum/mutation/human))
		var/datum/mutation/human/B = new A()
		if(B.dna_block == NON_SCANNABLE)
			continue
		B.dna_block = pick_n_take(avnums)
		if(B.quality == POSITIVE)
			good_mutations |= B
		else if(B.quality == NEGATIVE)
			bad_mutations |= B
		else if(B.quality == MINOR_NEGATIVE)
			not_good_mutations |= B
		CHECK_TICK


//This just builds the stack recipes list
//We need to link and verify blueprints before we cache them and for that we need an instance
//So we won't do that here
/datum/controller/subsystem/atoms/proc/InitConstruction()
	var/list/recipes = list()
	recipes_cache = recipes
	var/list/objs = typesof(/obj)
	for(var/I in objs)
		var/obj/construction_blueprint_getter_type = I;
		var/construction_blueprint_get_type = initial(construction_blueprint_getter_type.construction_blueprint);
		if(construction_blueprint_get_type)
			var/datum/construction_blueprint/CBP = new construction_blueprint_get_type;
			if(CBP.owner_type != I && (CBP.root_only || CBP.build_root_only))
				continue
			var/list/BP = CBP.GetBlueprint(I)
			if(BP.len)
				var/datum/construction_state/first/F = BP[1]
				if(istype(F))
					var/obj/item/stack/mat_type = F.required_type_to_construct
					if(ispath(mat_type, /obj/item/stack))
						mat_type = initial(mat_type.merge_type)
						var/list/t_recipes = recipes[mat_type]
						if(!t_recipes)
							t_recipes = list()
							recipes[mat_type] = t_recipes
						//TODO: Handle these snowflakes
						var/is_glass = ispath(mat_type, /obj/item/stack/sheet/glass) || ispath(mat_type, /obj/item/stack/sheet/rglass)
						var/obj/O = I
						var/bp_name = initial(O.bp_name)
						if(!bp_name)
							bp_name = initial(O.name)
						t_recipes += new /datum/stack_recipe(bp_name, I, F.required_amount_to_construct, time = F.construction_delay, one_per_turf = F.one_per_turf, on_floor = F.on_floor, window_checks = is_glass)
		CHECK_TICK
	testing("Compiled [recipes.len] stack construction recipes")
