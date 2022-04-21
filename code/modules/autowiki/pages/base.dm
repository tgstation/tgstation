/// A representation of an automated wiki page.
/datum/autowiki
	/// The page on the wiki to be replaced.
	/// This should never be a user-facing page, like "Guide to circuits".
	/// It should always be a template that only Autowiki should touch.
	/// For example: "Template:Autowiki/CircuitInfo".
	var/page

/// Override and return the new text of the page.
/// This proc can be impure, usually to call `upload_file`.
/datum/autowiki/proc/generate()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] does not implement generate()!")

/// Generates an auto formatted template user.
/// Your autowiki should ideally be a *lot* of these.
/// It lets wiki editors edit it much easier later, without having to enter repo.
/// Parameters will be passed in by name. That means your template should expect
/// something that looks like `{{ Autowiki_Circuit|name=Combiner|description=This combines }}`
/// Lists, which must be array-like (no keys), will be turned into a flat list with their key and a number,
/// such that list("food" = list("fruit", "candy")) -> food1=fruit|food2=candy
/datum/autowiki/proc/include_template(name, parameters)
	var/template_text = "{{[name]"

	var/list/prepared_parameters = list()
	for (var/key in parameters)
		var/value = parameters[key]
		if (islist(value))
			for (var/index in 1 to length(value))
				prepared_parameters["[key][index]"] = "[value[index]]"
		else
			prepared_parameters[key] = value

	for (var/parameter_name in prepared_parameters)
		template_text += "|[parameter_name]="
		template_text += "[prepared_parameters[parameter_name]]"

	template_text += "}}"

	return template_text

/// Takes an icon and uploads it to Autowiki-name.png.
/// Do your best to make sure this is unique, so it doesn't clash with other autowiki icons.
/datum/autowiki/proc/upload_icon(icon/icon, name)
	// Fuck you
	if (IsAdminAdvancedProcCall())
		return

	fcopy(icon, "data/autowiki_files/[name].png")

/// Escape a parameter such that it can be correctly put inside a wiki output
/datum/autowiki/proc/escape_value(parameter)
	// | is a special character in MediaWiki, and must be escaped by...using another template.
	return replacetextEx(parameter, "|", "{{!}}")
