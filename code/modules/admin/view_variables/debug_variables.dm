#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/// Get displayed variable in VV variable list
/proc/debug_variable(name, value, level, datum/owner, sanitize = TRUE, display_flags = NONE) //if D is a list, name will be index, and value will be assoc value.
	if(owner)
		if(islist(owner))
			var/list/list_owner = owner
			var/index = name
			if (value)
				name = list_owner[name] //name is really the index until this line
			else
				value = list_owner[name]
			. = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(owner, VV_HK_LIST_EDIT, "E", index)]) ([VV_HREF_TARGET_1V(owner, VV_HK_LIST_CHANGE, "C", index)]) ([VV_HREF_TARGET_1V(owner, VV_HK_LIST_REMOVE, "-", index)]) "
		else
			. = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_EDIT, "E", name)]) ([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_CHANGE, "C", name)]) ([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_MASSEDIT, "M", name)]) "
	else
		. = "<li>"

	var/name_part = VV_HTML_ENCODE(name)
	if(level > 0 || islist(owner)) //handling keys in assoc lists
		if(istype(name,/datum))
			name_part = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(name)]'>[VV_HTML_ENCODE(name)] [REF(name)]</a>"
		else if(islist(name))
			var/list/list_value = name
			name_part = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(name)]'> /list ([length(list_value)]) [REF(name)]</a>"

	. = "[.][name_part] = "

	var/item = _debug_variable_value(name, value, level, owner, sanitize, display_flags)

	return "[.][item]</li>"

// This is split into a separate proc mostly to make errors that happen not break things too much
/proc/_debug_variable_value(name, value, level, datum/owner, sanitize, display_flags)
	if(isappearance(value))
		value = get_vv_appearance(value)

	. = "<font color='red'>DISPLAY_ERROR:</font> ([value] [REF(value)])" // Make sure this line can never runtime

	if(isnull(value))
		return "<span class='value'>null</span>"

	if(istext(value))
		return "<span class='value'>\"[VV_HTML_ENCODE(value)]\"</span>"

	if(isicon(value))
		#ifdef VARSICON
		var/icon/icon_value = icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp[REF(icon_value)][rnd].png"
		usr << browse_rsc(icon_value, rname)
		return "(<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
		#else
		return "/icon (<span class='value'>[value]</span>)"
		#endif

	if(isfilter(value))
		var/datum/filter_value = value
		return "/filter (<span class='value'>[filter_value.type] [REF(filter_value)]</span>)"

	if(isfile(value))
		return "<span class='value'>'[value]'</span>"

	if(isdatum(value))
		var/datum/datum_value = value
		return datum_value.debug_variable_value(name, level, owner, sanitize, display_flags)

	if(islist(value) || (name in GLOB.vv_special_lists)) // Some special lists aren't detectable as a list through istype
		var/list/list_value = value
		var/list/items = list()

		// This is because some lists either don't count as lists or a locate on their ref will return null
		var/link_vars = "Vars=[REF(value)]"
		if(name in GLOB.vv_special_lists)
			link_vars = "Vars=[REF(owner)];special_varname=[name]"

		if (!(display_flags & VV_ALWAYS_CONTRACT_LIST) && list_value.len > 0 && list_value.len <= (IS_NORMAL_LIST(list_value) ? VV_NORMAL_LIST_NO_EXPAND_THRESHOLD : VV_SPECIAL_LIST_NO_EXPAND_THRESHOLD))
			for (var/i in 1 to list_value.len)
				var/key = list_value[i]
				var/val
				if (IS_NORMAL_LIST(list_value) && !isnum(key))
					val = list_value[key]
				if (isnull(val)) // we still want to display non-null false values, such as 0 or ""
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			return "<a href='?_src_=vars;[HrefToken()];[link_vars]'>/list ([list_value.len])</a><ul>[items.Join()]</ul>"
		else
			return "<a href='?_src_=vars;[HrefToken()];[link_vars]'>/list ([list_value.len])</a>"

	if(name in GLOB.bitfields)
		var/list/flags = list()
		for (var/i in GLOB.bitfields[name])
			if (value & GLOB.bitfields[name][i])
				flags += i
		if(length(flags))
			return "[VV_HTML_ENCODE(jointext(flags, ", "))]"
		else
			return "NONE"
	else
		return "<span class='value'>[VV_HTML_ENCODE(value)]</span>"

/datum/proc/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	if("[src]" != "[type]") // If we have a name var, let's use it.
		return "<a href='?_src_=vars;[HrefToken()];Vars=[REF(src)]'>[src] [type] [REF(src)]</a>"
	else
		return "<a href='?_src_=vars;[HrefToken()];Vars=[REF(src)]'>[type] [REF(src)]</a>"

/datum/weakref/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	. = ..()
	return "[.] <a href='?_src_=vars;[HrefToken()];Vars=[reference]'>(Resolve)</a>"

/matrix/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	return {"<span class='value'>
			<table class='matrixbrak'><tbody><tr><td class='lbrak'>&nbsp;</td><td>
			<table class='matrix'>
			<tbody>
				<tr><td>[a]</td><td>[d]</td><td>0</td></tr>
				<tr><td>[b]</td><td>[e]</td><td>0</td></tr>
				<tr><td>[c]</td><td>[f]</td><td>1</td></tr>
			</tbody>
			</table></td><td class='rbrak'>&nbsp;</td></tr></tbody></table></span>"} //TODO link to modify_transform wrapper for all matrices

#undef VV_HTML_ENCODE
