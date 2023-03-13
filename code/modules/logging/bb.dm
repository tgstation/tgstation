/// Convert almost anything to a JSON-safe value.
///
/// Inputs **must not** be self-referential.
/// Associative lists with non-{number, string} keys are discarded.
/proc/_bb_jsonify(data as anything)
	if(islist(data))
		. = list()

		for(var/key in data)
			var/value

			try
				value = data[key]
			catch
				// Expected, indicates a flat list

			if(!isnull(value))
				if(!istext(key) && !isnum(key))
					// We can't store non-numeric/non-string keys in JSON maps.
					// Skip this one.
					continue

				.[key] = _bb_jsonify(data[key])
			else if(!isnull(key))
				. += list(_bb_jsonify(key))
	else if(istext(data))
		. = data
	else if(isnum(data))
		. = round(data, 0.1)
	else if(isdatum(data))
		var/datum/data_datum = data

		. = data_datum.bb_snapshot()

/// Converts anything into a string using `bb_name`. For unstructured viewers
/// (such as `_bb_format`), inline structures are typically replaced with names
/// generated from this function.
///
/// The following rules are followed:
/// - Associative lists: the string literal "<map>"
/// - Array lists: the name of each item in the list joined by a comma:
///   "[a, b, c, d, e]"
/// - Datums: `bb_name` called on that datum.
/// - Text: the value verbatim.
/// - Numbers: the value rounded to the tenth decimal place, as a string.
/// - Null: the string literal "null".
/// - Anything else: the string literal "unknown".
/proc/_bb_nameof(data as anything)
	if(islist(data))
		var/list/formatted_parts = list()

		for(var/key in data)
			var/map_value

			try
				map_value = data[key]
			catch
				// Expected, indicates a flat list

			if(!isnull(map_value))
				return "<map>"
			else
				formatted_parts += _bb_nameof(key)

		return "\[[formatted_parts.Join(", ")]\]"
	else if(isdatum(data))
		var/datum/data_datum = data

		return data_datum.bb_name()
	else if(isnum(data))
		return "[round(data, 0.1)]"
	else if(istext(data))
		return data
	else if(isnull(data))
		return "null"

	return "unknown"

/// Replaces strings grouped `{like this}` with
/// `_bb_nameof(src.raw_context["like this"])`.
///
/// Set `raw_context` to your context object before calling `Replace`, and to
/// null after calling `Replace`.
/regex/bb_log_group
	var/static/list/raw_context

/// See `/regex/bb_log_group`.
/regex/bb_log_group/proc/replace_handler(match as text, context_name as text)
	REGEX_REPLACE_HANDLER

	var/context_object = raw_context[context_name]

	if(isnull(context_object))
		return "(missing [context_name])"

	return _bb_nameof(context_object)

/// Implementation detail of `BB_LOG`, which you should use instead of directly
/// calling this proc.
/proc/_bb_log_impl(category as text, source as text, format_string as text, list/raw_context)
	var/static/regex/bb_log_group/log_group_regexp = new(@"\{([^\}]*)\}", "g")
	var/static/log_counter = 0

	log_counter += 1

	log_group_regexp.raw_context = raw_context
	var/rendered = log_group_regexp.Replace(format_string, /regex/bb_log_group/proc/replace_handler)
	log_group_regexp.raw_context = null

	var/timestamp = "[time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss", 0)].[world.timeofday % 10]"

	var/json_log_entry = list(
		id = log_counter,
		timestamp = timestamp,
		rendered = rendered,
		category = category,
		source = source,
		format_string = format_string,
		context = _bb_jsonify(raw_context)
	)

	// For the rendered log, guess a location from any of the context arguments.
	var/guessed_loc = "unknown location"

	for(var/context_name in raw_context)
		var/atom/atom = raw_context[context_name]

		if(!atom)
			continue

		var/turf/turf = get_turf(atom)

		if(!turf || turf.z == 0)
			continue

		var/area/area = turf.loc

		guessed_loc = "[area ? area.name : "unknown area"] ([turf.x], [turf.y], [turf.z])"

		break


	rustg_file_append("[json_encode(json_log_entry)]\n", "[GLOB.log_directory]/bb.context.log")
	rustg_file_append("\[[timestamp]\]\[#[log_counter]\] [uppertext(category)]: [rendered] ([guessed_loc])\n", "[GLOB.log_directory]/bb.rendered.log")

/// Create a JSON-safe[1] contextual logging object from this datum at the
/// current timestamp.
///
/// Any encoded information should be useful to an administrator (read: useful
/// context).
///
/// [1]: Must be able to be safely passed to `_bb_jsonify`. This includes
/// numbers, strings, lists, datums, maps with string or number indices, or
/// arrays of any of these.
/datum/proc/bb_snapshot()
	. = list()

	.["$kind"] = "datum"
	.["$ref"] = REF(src)
	.["type"] = type

/// Create a contextual logging name from this datum.
///
/// This must always return a string.
/datum/proc/bb_name()
	. = type

/atom/bb_snapshot()
	. = list()

	.["$kind"] = "atom"
	.["$ref"] = REF(src)
	.["type"] = type
	.["name"] = name

	if(z != 0)
		.["pos"] = list(x, y, z)

	var/area = get_area_name(src)

	if(!isnull(area))
		.["area_name"] = area

/atom/bb_name()
	. = name

/atom/movable/bb_snapshot()
	. = ..()

	.["$kind"] = "atom/movable"

	if(throwforce != 0)
		.["throwforce"] = throwforce

/obj/bb_snapshot()
	. = ..()

	.["$kind"] = "obj"

	if(force != 0)
		.["force"] = force

/client/bb_name()
	. = ckey

/mob/bb_name()
	var/mob_name = name == real_name ? name : "[real_name] (as [name])"
	var/client_name = isnull(client) ? "*no key*" : client.ckey

	. = "[client_name]/[mob_name]"

/mob/bb_snapshot()
	. = list()

	.["$kind"] = "mob"
	.["$ref"] = REF(src)
	.["type"] = type
	.["name"] = name
	.["real_name"] = real_name

	if(client)
		.["ckey"] = client.ckey

	if(z != 0)
		.["pos"] = list(x, y, z)

	var/area = get_area_name(src)

	if(!isnull(area))
		.["area_name"] = area

/mob/living/bb_snapshot()
	. = ..()

	.["$kind"] = "mob/living"
	.["health"] = round(health, 0.1)
	.["staminaloss"] = round(staminaloss, 0.1)

	if(combat_mode)
		.["combat_mode"] = combat_mode

/mob/living/carbon/human/bb_snapshot()
	. = ..()

	.["$kind"] = "mob/living/human"
	.["species"] = dna.species.name

/datum/reagent/bb_name()
	. = "[round(volume, 1)]u [name] ([round(purity, 0.01) * 100]% pure, pH [round(ph, 0.1)])"

/datum/reagent/bb_snapshot()
	. = list()

	.["$kind"] = "reagent"
	.["$ref"] = REF(src)
	.["name"] = name
	.["ph"] = round(ph, 0.1)
	.["purity"] = round(purity, 0.1)
	.["volume"] = round(volume, 0.1)

	if(istype(src, /datum/reagent/toxin))
		.["toxic"] = TRUE

/datum/reagents/bb_name()
	var/list/reagent_names = list()

	for(var/datum/reagent/reagent in reagent_list)
		reagent_names += reagent.bb_name()

	. = "reagents [reagent_names.Join(", ")]"

/datum/reagents/bb_snapshot()
	. = list()

	for(var/datum/reagent/reagent in reagent_list)
		. += reagent.bb_snapshot()

/datum/wound/bb_snapshot()
	. = ..()

	if(!isnull(limp_slowdown))
		.["limp_slowdown"] = round(limp_slowdown, 0.1)

	if (!isnull(limp_chance))
		.["limp_chance"] = round(limp_chance, 0.1)

	if (!isnull(blood_flow))
		.["blood_flow"] = round(blood_flow, 0.1)

	if (!isnull(disabling))
		.["disabling"] = disabling
