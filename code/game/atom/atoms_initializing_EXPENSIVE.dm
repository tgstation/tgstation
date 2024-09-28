/// Init this specific atom
/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, from_template = FALSE, list/arguments)

	var/the_type = A.type

	if(QDELING(A))
		// Check init_start_time to not worry about atoms created before the atoms SS that are cleaned up before this
		if (A.gc_destroyed > init_start_time)
			BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	// This is handled and battle tested by dreamchecker. Limit to UNIT_TESTS just in case that ever fails.
	#ifdef UNIT_TESTS
	var/start_tick = world.time
	#endif

	var/result = A.Initialize(arglist(arguments))

	#ifdef UNIT_TESTS
	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT
	#endif

	var/qdeleted = FALSE

	switch(result)
		if (INITIALIZE_HINT_NORMAL)
			EMPTY_BLOCK_GUARD // Pass
		if(INITIALIZE_HINT_LATELOAD)
			if(arguments[1]) //mapload
				late_loaders += A
			else
				A.LateInitialize()
		if(INITIALIZE_HINT_QDEL)
			qdel(A)
			qdeleted = TRUE
		else
			BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A) //possible harddel
		qdeleted = TRUE
	else if(!(A.flags_1 & INITIALIZED_1))
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT
	else
		SEND_SIGNAL(A, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ATOM_AFTER_POST_INIT, A)
		var/atom/location = A.loc
		if(location)
			/// Sends a signal that the new atom `src`, has been created at `loc`
			SEND_SIGNAL(location, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, A, arguments[1])
		if(created_atoms && from_template && ispath(the_type, /atom/movable))//we only want to populate the list with movables
			created_atoms += A.get_all_contents()

	return qdeleted || QDELING(A)

/**
 * Called when an atom is created in byond (built in engine proc)
 *
 * Not a lot happens here in SS13 code, as we offload most of the work to the
 * [Initialization][/atom/proc/Initialize] proc, mostly we run the preloader
 * if the preloader is being used and then call [InitAtom][/datum/controller/subsystem/atoms/proc/InitAtom] of which the ultimate
 * result is that the Initialize proc is called.
 *
 */
/atom/New(loc, ...)
	//atom creation method that preloads variables at creation
	if(GLOB.use_preloader && src.type == GLOB._preloader_path)//in case the instantiated atom is creating other atoms in New()
		world.preloader_load(src)

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, FALSE, args))
			//we were deleted
			return

/**
 * The primary method that objects are setup in SS13 with
 *
 * we don't use New as we have better control over when this is called and we can choose
 * to delay calls or hook other logic in and so forth
 *
 * During roundstart map parsing, atoms are queued for initialization in the base atom/New(),
 * After the map has loaded, then Initialize is called on all atoms one by one. NB: this
 * is also true for loading map templates as well, so they don't Initialize until all objects
 * in the map file are parsed and present in the world
 *
 * If you're creating an object at any point after SSInit has run then this proc will be
 * immediately be called from New.
 *
 * mapload: This parameter is true if the atom being loaded is either being initialized during
 * the Atom subsystem initialization, or if the atom is being loaded from the map template.
 * If the item is being created at runtime any time after the Atom subsystem is initialized then
 * it's false.
 *
 * The mapload argument occupies the same position as loc when Initialize() is called by New().
 * loc will no longer be needed after it passed New(), and thus it is being overwritten
 * with mapload at the end of atom/New() before this proc (atom/Initialize()) is called.
 *
 * You must always call the parent of this proc, otherwise failures will occur as the item
 * will not be seen as initialized (this can lead to all sorts of strange behaviour, like
 * the item being completely unclickable)
 *
 * You must not sleep in this proc, or any subprocs
 *
 * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
 * there are no other arguments
 *
 * Must return an [initialization hint][INITIALIZE_HINT_NORMAL] or a runtime will occur.
 *
 * Note: the following functions don't call the base for optimization and must copypasta handling:
 * * [/turf/proc/Initialize]
 * * [/turf/open/space/proc/Initialize]
 */
/atom/proc/Initialize(mapload, ...)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	SET_PLANE_IMPLICIT(src, plane)

	if(greyscale_config && greyscale_colors) //we'll check again at item/init for inhand/belt/worn configs.
		update_greyscale()

	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_system == COMPLEX_LIGHT && light_power && light_range)
		update_light()

	SETUP_SMOOTHING()

	if(uses_integrity)
		atom_integrity = max_integrity
	TEST_ONLY_ASSERT((!armor || istype(armor)), "[type] has an armor that contains an invalid value at initialize")

	// apply materials properly from the default custom_materials value
	// This MUST come after atom_integrity is set above, as if old materials get removed,
	// atom_integrity is checked against max_integrity and can BREAK the atom.
	// The integrity to max_integrity ratio is still preserved.
	if(custom_materials)
		initialize_materials(custom_materials)

	if(ispath(ai_controller))
		ai_controller = new ai_controller(src)

	return INITIALIZE_HINT_NORMAL

/**
 * Late Initialization, for code that should run after all atoms have run Initialization
 *
 * To have your LateIntialize proc be called, your atoms [Initialization][/atom/proc/Initialize]
 *  proc must return the hint
 * [INITIALIZE_HINT_LATELOAD] otherwise it will never be called.
 *
 * useful for doing things like finding other machines on GLOB.machines because you can guarantee
 * that all atoms will actually exist in the "WORLD" at this time and that all their Initialization
 * code has been run
 */
/atom/proc/LateInitialize()
	set waitfor = FALSE
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("[src] ([type]) called LateInitialize but has nothing on it!")
