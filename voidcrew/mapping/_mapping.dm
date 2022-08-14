/**
 * We are modularly making stuff we don't want, early return.
 * We can manually re-add whatever we need here as well.
 */
/datum/controller/subsystem/mapping
	var/list/maplist = list()
	var/list/ship_purchase_list = list()
	var/list/nt_ship_list = list()
	var/list/syn_ship_list = list()

/datum/controller/subsystem/mapping/loadWorld()
	return

/datum/controller/subsystem/mapping/generate_z_level_linkages()
	return

/datum/controller/subsystem/mapping/setup_map_transitions()
	return

///generates the list of GLOB.the_station_areas - We don't have a station, maybe we can make use of this one day for ships.
/datum/controller/subsystem/mapping/generate_station_area_list()
	return

#define CHECK_STRING_EXISTS(X) if(!istext(data[X])) { log_world("[##X] missing from json!"); continue; }
#define CHECK_LIST_EXISTS(X) if(!islist(data[X])) { log_world("[##X] missing from json!"); continue; }
/datum/controller/subsystem/mapping/proc/load_ship_templates()
	maplist = list()
	nt_ship_list = list()
	syn_ship_list = list()
	ship_purchase_list = list()
	var/list/filelist = flist("_maps/configs/")
	for(var/filename in filelist)
		var/file = file("_maps/configs/" + filename)
		if(!file)
			log_world("Could not open map config: [filename]")
			continue
		file = file2text(file)
		if(!file)
			log_world("map config is not text: [filename]")
			continue

		var/list/data = json_decode(file)
		if(!data)
			log_world("map config is not json: [filename]")
			continue

		CHECK_STRING_EXISTS("map_name")
		CHECK_STRING_EXISTS("map_path")
		CHECK_LIST_EXISTS("job_slots")
		var/datum/map_template/shuttle/S = new(data["map_path"], data["map_name"], TRUE)
		S.file_name = data["map_path"]
		S.category = "shiptest"

		if(istext(data["map_short_name"]))
			S.short_name = data["map_short_name"]
		else
			S.short_name = copytext(S.name, 1, 20)
		if(istext(data["prefix"]))
			S.faction_prefix = data["prefix"]
		if(islist(data["namelists"]))
			S.name_categories = data["namelists"]

		if(istext(data["antag_datum"]))
			var/path = "/datum/antagonist/" + data["antag_datum"]
			S.antag_datum = text2path(path)

		S.job_slots = list()
		var/list/job_slot_list = data["job_slots"]
		for(var/job in job_slot_list)
			var/datum/job/job_slot
			var/value = job_slot_list[job]
			var/slots
			if(isnum(value))
				job_slot = SSjob.GetJob(job)
				slots = value
			else if(islist(value))
				var/datum/outfit/job_outfit = text2path(value["outfit"])
				if(isnull(job_outfit))
					stack_trace("Invalid job outfit! [value["outfit"]] on [S.name]'s config! Defaulting to assistant clothing.")
					job_outfit = /datum/outfit/job/assistant
				job_slot = new /datum/job(job, job_outfit)
				job_slot.wiki_page = value["wiki_page"]
				job_slot.exp_requirements = value["exp_requirements"]
				job_slot.officer = value["officer"]
				slots = value["slots"]

			if(!job_slot || !slots)
				stack_trace("Invalid job slot entry! [job]: [value] on [S.name]'s config! Excluding job.")
				continue

			S.job_slots[job_slot] = slots

		S.disable_passwords = data["disable_passwords"] ? TRUE : FALSE
		if(isnum(data["cost"]))
			S.cost = data["cost"]
			ship_purchase_list["[S.faction_prefix] [S.name] ([S.cost] [CONFIG_GET(string/metacurrency_name)]s)"] = S // VOIDCREW
		if(isnum(data["limit"]))
			S.limit = data["limit"]
		shuttle_templates[S.file_name] = S
		map_templates[S.file_name] = S
		if(isnum(data["roundstart"]) && data["roundstart"])
			maplist[S.name] = S
		switch(S.faction_prefix)
			if("NT-C")
				nt_ship_list[S.name] = S
			if("SYN-C")
				syn_ship_list[S.name] = S
#undef CHECK_STRING_EXISTS
#undef CHECK_LIST_EXISTS
