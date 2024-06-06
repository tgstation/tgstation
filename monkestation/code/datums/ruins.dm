GLOBAL_LIST_INIT(ruin_config, load_ruin_config())
#define RUIN_CONFIG_FILE "config/monkestation/ruins.toml"

/datum/map_template/ruin/New()
	. = ..()
	var/list/this_ruin_config = GLOB.ruin_config[type]
	if(this_ruin_config)
		var/overrides = 0
		for(var/variable in this_ruin_config)
			if(!(variable in vars))
				stack_trace("Invalid ruin configuration variable [variable] in ruin ([type]) variable changes.")
				continue
			vars[variable] = this_ruin_config[variable]
			overrides += 1
		log_config("Applied [overrides] var overrides for [type] from ruin config.")

/proc/load_ruin_config()
	. = list()
	if(!fexists(RUIN_CONFIG_FILE))
		log_config("No ruin config file found, using empty config.")
		return
	var/list/ruin_config = rustg_read_toml_file(RUIN_CONFIG_FILE)
	if(!length(ruin_config))
		log_config("ruin token config file is empty, using empty config.")
		return
	for(var/ruin_config_id in ruin_config)
		var/ruin_path = text2path(ruin_config_id)
		if(!ispath(ruin_path, /datum/map_template/ruin))
			continue
		.[ruin_path] = ruin_config[ruin_config_id]

#undef RUIN_CONFIG_FILE
