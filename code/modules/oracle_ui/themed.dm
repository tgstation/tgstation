/datum/oracle_ui/themed
	var/theme = ""
	var/content_root = ""
	var/current_page = "index.html"
	var/root_template = ""

/datum/oracle_ui/themed/New(atom/n_datasource, n_width = 512, n_height = 512, n_content_root = "")
	root_template = get_themed_file("index.html")
	content_root = n_content_root
	return ..(n_datasource, n_width, n_height, get_asset_datum(/datum/asset/simple/oui_theme_nano))

/datum/oracle_ui/themed/process()
	if(auto_check_view)
		check_view_all()
	if(auto_refresh)
		soft_update_fields()

GLOBAL_LIST_EMPTY(oui_template_variables)
GLOBAL_LIST_EMPTY(oui_file_cache)

/datum/oracle_ui/themed/proc/get_file(path)
	if(GLOB.oui_file_cache[path])
		return GLOB.oui_file_cache[path]
	else if(fexists(path))
		var/data = file2text(path)
		GLOB.oui_file_cache[path] = data
		return data
	else
		var/errormsg = "MISSING PATH '[path]'"
#ifndef UNIT_TESTS
		log_world(errormsg) //Because Travis absolutely hates these procs
#endif
		return errormsg

/datum/oracle_ui/themed/proc/get_content_file(filename)
	return get_file("./html/oracle_ui/content/[content_root]/[filename]")

/datum/oracle_ui/themed/proc/get_themed_file(filename)
	return get_file("./html/oracle_ui/themes/[theme]/[filename]")

/datum/oracle_ui/themed/proc/process_template(template, variables)
	var/regex/pattern = regex("\\@\\{(\\w+)\\}","gi")
	GLOB.oui_template_variables = variables
	var/replaced = pattern.Replace(template, /proc/oui_process_template_replace)
	GLOB.oui_template_variables = null
	return replaced

/proc/oui_process_template_replace(match, group1)
	var/value = GLOB.oui_template_variables[group1]
	return "[value]"

/datum/oracle_ui/themed/proc/get_inner_content(mob/target)
	var/list/data = call(datasource, "oui_data")(target)
	return process_template(get_content_file(current_page), data)

/datum/oracle_ui/themed/get_content(mob/target)
	var/list/template_data = list("title" = datasource.name, "body" = get_inner_content(target))
	return process_template(root_template, template_data)

/datum/oracle_ui/themed/proc/soft_update_fields()
	for(var/viewer in viewers)
		var/json = json_encode(call(datasource, "oui_data")(viewer))
		call_js(viewer, "updateFields", list(json))

/datum/oracle_ui/themed/proc/soft_update_all()
	for(var/viewer in viewers)
		call_js(viewer, "replaceContent", list(get_inner_content(viewer)))

/datum/oracle_ui/themed/proc/change_page(newpage)
	if(newpage == current_page)
		return
	current_page = newpage
	render_all()

/datum/oracle_ui/themed/proc/act(label, mob/user, action, list/parameters = list(), class = "", disabled = FALSE)
	if(disabled)
		return "<a class=\"disabled\">[label]</a>"
	else
		return "<a class=\"[class]\" href=\"" + href(user, action, parameters) + "\">[label]</a>"

/datum/oracle_ui/themed/nano
	theme = "nano"
