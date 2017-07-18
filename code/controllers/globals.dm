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

	log_world("[vars.len - gvars_datum_in_built_vars.len] global variables")

	Initialize()

/datum/controller/global_vars/Destroy(force)
	stack_trace("Some fucker qdel'd the global holder!")
	if(!force)
		return QDEL_HINT_LETMELIVE
	
	QDEL_NULL(statclick)
	gvars_datum_protected_varlist.Cut()
	gvars_datum_in_built_vars.Cut()
	
	GLOB = null

	return ..()

/datum/controller/global_vars/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Initializing...", src)
	
	stat("Globals:", statclick.update("Edit"))

/datum/controller/global_vars/can_vv_get(var_name)
	if(var_name in gvars_datum_protected_varlist)
		return FALSE
	return ..()

/datum/controller/global_vars/vv_edit_var(var_name, var_value)
	if((var_name in gvars_datum_protected_varlist))
		return FALSE
	return ..()

/datum/controller/global_vars/Initialize()
	gvars_datum_init_order = list()
	gvars_datum_protected_varlist = list("gvars_datum_protected_varlist")
	
	//See https://github.com/tgstation/tgstation/issues/26954
	for(var/I in typesof(/datum/controller/global_vars/proc))
		var/CLEANBOT_RETURNS = "[I]"
		pass(CLEANBOT_RETURNS)
	
	for(var/I in vars - gvars_datum_in_built_vars)
		var/start_tick = world.time
		call(src, "InitGlobal[I]")()
		var/end_tick = world.time
		if(end_tick - start_tick)
			warning("Global [I] slept during initialization!")
