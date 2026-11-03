GLOBAL_DATUM(rogue_mechanics, /datum/rogue_mechanics)

/proc/rogue_mechanics()
	if(!GLOB.rogue_mechanics)
		GLOB.rogue_mechanics = new
	return GLOB.rogue_mechanics

/proc/rogue_formula_value(id, list/values)
	var/datum/rogue_formula/formula = rogue_mechanics().formulas[id]
	if(!formula)
		CRASH("Unknown rogue formula [id]")
	return formula.evaluate(values)

/proc/rogue_value(id)
	var/datum/rogue_formula/value = rogue_mechanics().formulas[id]
	if(!value?.is_value)
		CRASH("Unknown rogue value [id]")
	return value.number

/proc/rogue_value_or(id, fallback)
	var/datum/rogue_formula/value = rogue_mechanics().formulas[id]
	return value?.is_value ? value.number : fallback

/datum/rogue_mechanics
	var/list/categories = list()
	var/list/tables = list()
	var/list/formulas = list()
	var/list/problems = list()
	var/loaded_at

/datum/rogue_mechanics/New()
	for(var/category_type in subtypesof(/datum/rogue_mechanics_category))
		var/datum/rogue_mechanics_category/category = new category_type
		categories[category.name] = category
	for(var/id in GLOB.rogue_formula_definitions)
		var/list/definition = GLOB.rogue_formula_definitions[id]
		formulas[id] = new /datum/rogue_formula(id, definition[1], definition[2], definition[3])
	declare_values()
	for(var/special_type in subtypesof(/datum/special_intent))
		var/datum/special_intent/special = new special_type
		for(var/tunable in special.tunables)
			var/id = "[special.value_key()]_[tunable]"
			formulas[id] = new /datum/rogue_formula(id, "[special.vars[tunable] || 0]", "[special.name]: [tunable]. Times are in deciseconds.", null, TRUE)
		qdel(special)
	for(var/pattern_type in subtypesof(/datum/cleave_pattern))
		var/datum/cleave_pattern/pattern = new pattern_type
		formulas[pattern.value_key()] = new /datum/rogue_formula(pattern.value_key(), "[pattern.max_targets]", "Most extra targets of a cleave: [pattern.desc]", null, TRUE)
		qdel(pattern)
	load()

/// The open value files of config/redtard/mechanics/values/, one per block, compiled into the build: their numbers are the
/// defaults. A file literal cannot be built from a name, so a new file of the folder is listed here too (CI checks both agree).
/proc/rogue_value_files()
	return list(
		"alchemy.txt" = 'config/redtard/mechanics/values/alchemy.txt',
		"burial.txt" = 'config/redtard/mechanics/values/burial.txt',
		"combat.txt" = 'config/redtard/mechanics/values/combat.txt',
		"crafting.txt" = 'config/redtard/mechanics/values/crafting.txt',
		"faith.txt" = 'config/redtard/mechanics/values/faith.txt',
		"farming.txt" = 'config/redtard/mechanics/values/farming.txt',
		"flora.txt" = 'config/redtard/mechanics/values/flora.txt',
		"husbandry.txt" = 'config/redtard/mechanics/values/husbandry.txt',
		"library.txt" = 'config/redtard/mechanics/values/library.txt',
		"machines.txt" = 'config/redtard/mechanics/values/machines.txt',
		"pve.txt" = 'config/redtard/mechanics/values/pve.txt',
		"races.txt" = 'config/redtard/mechanics/values/races.txt',
		"specials.txt" = 'config/redtard/mechanics/values/specials.txt',
		"structures.txt" = 'config/redtard/mechanics/values/structures.txt',
		"survival.txt" = 'config/redtard/mechanics/values/survival.txt',
		"trade.txt" = 'config/redtard/mechanics/values/trade.txt',
		"treasury.txt" = 'config/redtard/mechanics/values/treasury.txt',
		"triumphs.txt" = 'config/redtard/mechanics/values/triumphs.txt',
	)

/// Declares every value of the open value files, the one place a number is written. The build compiles the files in, so
/// their numbers are the defaults even where the config folder lacks them; a private file only changes them. The `#` lines
/// right above an entry, back to a blank line, are its description.
/datum/rogue_mechanics/proc/declare_values()
	var/list/files = rogue_value_files()
	for(var/file_name in files)
		var/list/description = list()
		for(var/raw_line in splittext(replacetext(file2text(files[file_name]), ascii2text(ROGUE_MECHANICS_CARRIAGE_RETURN), ""), "\n"))
			var/line = trim(raw_line)
			if(!length(line))
				description.Cut()
				continue
			if(line[1] == ROGUE_MECHANICS_COMMENT)
				description += trim(copytext(line, 2))
				continue
			var/split_at = findtext(line, "=")
			if(!split_at)
				continue
			var/id = LOWER_TEXT(trim(copytext(line, 1, split_at)))
			var/datum/rogue_formula/formula = formulas[id]
			// Formulas and values share one namespace: a value of a formula's name would replace the formula.
			if(formula && !formula.is_value)
				stack_trace("Rogue mechanics: \"[id]\" is both a formula and a value; the value is dropped.")
			else
				var/datum/rogue_formula/value = new(id, trim(copytext(line, split_at + 1)), jointext(description, " "), null, TRUE)
				value.source_file = file_name
				formulas[id] = value
			description.Cut()

/datum/rogue_mechanics/proc/directory()
	return "[config?.directory || "config"]/[ROGUE_MECHANICS_SUBDIR]"

/datum/rogue_mechanics/proc/private_directory()
	return "[config?.directory || "config"]/[ROGUE_PRIVATE_MECHANICS_SUBDIR]"

/datum/rogue_mechanics/proc/has_private_directory()
	return fexists("[private_directory()]/")

/datum/rogue_mechanics/proc/file_path(file_name)
	var/private_path = "[private_directory()]/[file_name]"
	return fexists(private_path) ? private_path : "[directory()]/[file_name]"

/datum/rogue_mechanics/proc/save_path(file_name)
	return "[has_private_directory() ? private_directory() : directory()]/[file_name]"

/datum/rogue_mechanics/proc/load()
	problems = list()
	tables = list()
	for(var/name in categories)
		var/datum/rogue_mechanics_category/category = categories[name]
		tables[name] = read_category(category)
	read_formulas()
	loaded_at = world.time
	for(var/problem in problems)
		log_config("Rogue mechanics: [problem]")

/datum/rogue_mechanics/proc/read_lines(file_name)
	var/path = file_path(file_name)
	if(!fexists(path))
		return null
	return splittext(replacetext(file2text(path), ascii2text(ROGUE_MECHANICS_CARRIAGE_RETURN), ""), "\n")

/datum/rogue_mechanics/proc/read_category(datum/rogue_mechanics_category/category)
	var/list/table = list()
	var/list/lines = read_lines(category.file)
	if(isnull(lines))
		return table
	var/list/current
	var/current_id
	for(var/line_number in 1 to length(lines))
		var/line = trim(lines[line_number])
		if(!length(line) || line[1] == ROGUE_MECHANICS_COMMENT)
			continue
		var/where = "[category.file]:[line_number]"
		if(line[1] == "\[")
			current = null
			current_id = trim(copytext(line, 2, findtext(line, "]")))
			var/path = category.path_of(current_id)
			if(!path)
				problems += "[where]: no [category.root]/[current_id]"
				continue
			current = table[path]
			if(!current)
				current = list()
				table[path] = current
			continue
		var/split_at = findtext(line, "=")
		if(!split_at)
			problems += "[where]: expected \"field = value\""
			continue
		if(isnull(current))
			continue
		var/field = LOWER_TEXT(trim(copytext(line, 1, split_at)))
		var/list/spec = category.fields[field]
		if(!spec)
			problems += "[where]: [current_id] has no field \"[field]\" (fields: [jointext(category.fields, ", ")])"
			continue
		var/parsed = rogue_mechanics_parse(trim(copytext(line, split_at + 1)), spec[ROGUE_FIELD_KIND])
		if(istext(parsed))
			problems += "[where]: [current_id].[field]: [parsed]"
			continue
		var/list/wrapped = parsed
		current[field] = wrapped[1]
	return table

/datum/rogue_mechanics/proc/read_formulas()
	for(var/id in formulas)
		var/datum/rogue_formula/formula = formulas[id]
		formula.reset()
	read_formula_file(ROGUE_MECHANICS_FORMULAS_FILE)
	for(var/file_name in rogue_value_files())
		read_formula_file("[ROGUE_MECHANICS_VALUES_DIR]/[file_name]")

/// Lines of formulas.txt (values FALSE), or of the value file file_name of config/redtard/mechanics/values/ (values TRUE).
/datum/rogue_mechanics/proc/formula_lines(values, header, file_name)
	var/list/lines = list(header, "")
	for(var/id in formulas)
		var/datum/rogue_formula/formula = formulas[id]
		if(formula.is_value != values || (values && (formula.source_file || ROGUE_MECHANICS_TYPE_VALUES_FILE) != file_name))
			continue
		lines += values ? "# [formula.desc]" : "# [formula.desc] Inputs: [jointext(formula.known_inputs, ", ")]."
		lines += "[id] = [formula.text]"
		lines += ""
	return lines

/datum/rogue_mechanics/proc/read_formula_file(file_name)
	var/list/lines = read_lines(file_name)
	if(isnull(lines))
		return
	for(var/line_number in 1 to length(lines))
		var/line = trim(lines[line_number])
		if(!length(line) || line[1] == ROGUE_MECHANICS_COMMENT)
			continue
		var/where = "[file_name]:[line_number]"
		var/split_at = findtext(line, "=")
		if(!split_at)
			problems += "[where]: expected \"name = expression\""
			continue
		var/id = LOWER_TEXT(trim(copytext(line, 1, split_at)))
		var/datum/rogue_formula/formula = formulas[id]
		if(!formula)
			problems += "[where]: no formula \"[id]\" (formulas: [jointext(formulas, ", ")])"
			continue
		var/failure = formula.set_text(trim(copytext(line, split_at + 1)))
		if(failure)
			formula.error = failure
			problems += "[where]: [id] kept its default: [failure]"

/datum/rogue_mechanics/proc/values_for(category_name, path)
	var/list/table = tables[category_name]
	return table ? table[path] : null

/datum/rogue_mechanics/proc/apply_to(category_name, datum/target)
	var/list/values = values_for(category_name, target.type)
	if(!values)
		return
	var/datum/rogue_mechanics_category/category = categories[category_name]
	category.apply(target, values)

/datum/rogue_mechanics/proc/reload()
	load()
	for(var/path in GLOB.rogue_armor_cache)
		apply_to("armor", GLOB.rogue_armor_cache[path])
	for(var/path in GLOB.rogue_intents)
		apply_to("intents", GLOB.rogue_intents[path])
	var/list/item_table = tables["items"]
	var/changed = 0
	if(length(item_table))
		for(var/obj/item/thing in world)
			if(item_table[thing.type])
				apply_to("items", thing)
				changed++
			CHECK_TICK
	return changed

/datum/rogue_mechanics/proc/export(target_directory)
	var/list/written = list()
	for(var/name in categories)
		var/datum/rogue_mechanics_category/category = categories[name]
		var/list/lines = list("# [category.desc]", "# Fields: [jointext(category.fields, ", ")]", "")
		for(var/path in category.exported_types())
			var/datum/sample = rogue_mechanics_is_item_path(path) ? new path(null) : new path
			lines += "\[[category.id_of(path)]\]"
			for(var/field in category.fields)
				if(category.has_field(sample, field))
					lines += "[field] = [category.field_text(sample, field)]"
			lines += ""
			qdel(sample)
			CHECK_TICK
		rustg_file_write(jointext(lines, "\n"), "[target_directory]/[category.file]")
		written += category.file
	rustg_file_write(jointext(formula_lines(FALSE, ROGUE_MECHANICS_FORMULAS_HEADER), "\n"), "[target_directory]/[ROGUE_MECHANICS_FORMULAS_FILE]")
	written += ROGUE_MECHANICS_FORMULAS_FILE
	for(var/file_name in rogue_value_files())
		var/value_file = "[ROGUE_MECHANICS_VALUES_DIR]/[file_name]"
		rustg_file_write(jointext(formula_lines(TRUE, ROGUE_MECHANICS_VALUES_HEADER, file_name), "\n"), "[target_directory]/[value_file]")
		written += value_file
	return written

/proc/rogue_mechanics_is_item_path(path)
	return ispath(path, /obj/item)
