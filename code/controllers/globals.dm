GLOBAL_REAL(GLOB, /datum/controller/global_vars)

/datum/controller/global_vars
	name = "Global Variables"

	var/list/gvars_datum_protected_varlist
	var/list/gvars_datum_in_built_vars
	var/list/gvars_datum_init_order

/datum/controller/global_vars/New()
	if(GLOB)
		CRASH("Multiple instances of global variable controller created")
	GLOB = src

	var/datum/controller/exclude_these = new
	gvars_datum_in_built_vars = exclude_these.vars + list("gvars_datum_protected_varlist", "gvars_datum_in_built_vars", "gvars_datum_init_order")
	qdel(exclude_these)

	Initialize()

/datum/controller/global_vars/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE

	stack_trace("Some fucker deleted the global holder!")
	
	QDEL_NULL(statclick)
	gvars_datum_protected_varlist.Cut()
	gvars_datum_in_built_vars.Cut()
	
	GLOB = null

	return ..()

/datum/controller/global_vars/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Initializing...", src)
	
	var/static/num_globals
	if(!num_globals)
		num_globals = vars.len - gvars_datum_in_built_vars.len
	stat("Globals:", statclick.update("Count: [num_globals]"))

/datum/controller/global_vars/vv_get_var(var_name)
	if(var_name in gvars_datum_protected_varlist)
		return debug_variable(var_name, "SECRET", 0, src)
	return ..()

/datum/controller/global_vars/vv_edit_var(var_name, var_value)
	if((var_name in gvars_datum_protected_varlist))
		return FALSE
	return ..()

/datum/controller/global_vars/Initialize()
	gvars_datum_init_order = list()
	gvars_datum_protected_varlist = list("gvars_datum_protected_varlist")
	for(var/I in vars - gvars_datum_in_built_vars)
		var/start_tick = world.time
		call(src, "InitGlobal[I]")()
		var/end_tick = world.time
		if(end_tick - start_tick)
			warning("Global [I] slept during initialization!")
