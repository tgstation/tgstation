#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/// Get displayed variable in VV variable list
/proc/debug_variable(name, value, level, datum/D, sanitize = TRUE) //if D is a list, name will be index, and value will be assoc value.
	var/header
	if(D)
		if(islist(D))
			var/index = name
			if (value)
				name = D[name] //name is really the index until this line
			else
				value = D[name]
			header = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(D, VV_HK_LIST_EDIT, "E", index)]) ([VV_HREF_TARGET_1V(D, VV_HK_LIST_CHANGE, "C", index)]) ([VV_HREF_TARGET_1V(D, VV_HK_LIST_REMOVE, "-", index)]) "
		else
			header = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(D, VV_HK_BASIC_EDIT, "E", name)]) ([VV_HREF_TARGET_1V(D, VV_HK_BASIC_CHANGE, "C", name)]) ([VV_HREF_TARGET_1V(D, VV_HK_BASIC_MASSEDIT, "M", name)]) "
	else
		header = "<li>"

	var/item
	var/name_part = VV_HTML_ENCODE(name)
	if(level > 0 || islist(D)) //handling keys in assoc lists
		if(istype(name,/datum))
			name_part = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(name)]'>[VV_HTML_ENCODE(name)] [REF(name)]</a>"
		else if(islist(name))
			var/list/L = name
			name_part = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(name)]'> /list ([length(L)]) [REF(name)]</a>"

	if (isnull(value))
		item = "[name_part] = <span class='value'>null</span>"

	else if (istext(value))
		item = "[name_part] = <span class='value'>\"[VV_HTML_ENCODE(value)]\"</span>"

	else if (isicon(value))
		#ifdef VARSICON
		var/icon/I = icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp[REF(I)][rnd].png"
		usr << browse_rsc(I, rname)
		item = "[name_part] = (<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
		#else
		item = "[name_part] = /icon (<span class='value'>[value]</span>)"
		#endif

	else if (isfile(value))
		item = "[name_part] = <span class='value'>'[value]'</span>"

	else if(istype(value,/matrix)) // Needs to be before datum
		var/matrix/M = value
		item = {"[name_part] = <span class='value'>
			<table class='matrixbrak'><tbody><tr><td class='lbrak'>&nbsp;</td><td>
			<table class='matrix'>
			<tbody>
				<tr><td>[M.a]</td><td>[M.d]</td><td>0</td></tr>
				<tr><td>[M.b]</td><td>[M.e]</td><td>0</td></tr>
				<tr><td>[M.c]</td><td>[M.f]</td><td>1</td></tr>
			</tbody>
			</table></td><td class='rbrak'>&nbsp;</td></tr></tbody></table></span>"} //TODO link to modify_transform wrapper for all matrices
	else if (istype(value, /datum))
		var/datum/DV = value
		if ("[DV]" != "[DV.type]") //if the thing as a name var, lets use it.
			item = "[name_part] = <a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[DV] [DV.type] [REF(value)]</a>"
		else
			item = "[name_part] = <a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[DV.type] [REF(value)]</a>"
		if(istype(value,/datum/weakref))
			var/datum/weakref/R = value
			item += " <a href='?_src_=vars;[HrefToken()];Vars=[REF(R.reference)]'>(Resolve)</a>"

	else if (islist(value))
		var/list/L = value
		var/list/items = list()

		if (L.len > 0 && !(name == "underlays" || name == "overlays" || L.len > (IS_NORMAL_LIST(L) ? VV_NORMAL_LIST_NO_EXPAND_THRESHOLD : VV_SPECIAL_LIST_NO_EXPAND_THRESHOLD)))
			for (var/i in 1 to L.len)
				var/key = L[i]
				var/val
				if (IS_NORMAL_LIST(L) && !isnum(key))
					val = L[key]
				if (isnull(val)) // we still want to display non-null false values, such as 0 or ""
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			item = "[name_part] = <a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>/list ([L.len])</a><ul>[items.Join()]</ul>"
		else
			item = "[name_part] = <a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>/list ([L.len])</a>"

	else if (name in GLOB.bitfields)
		var/list/flags = list()
		for (var/i in GLOB.bitfields[name])
			if (value & GLOB.bitfields[name][i])
				flags += i
			item = "[name_part] = [VV_HTML_ENCODE(jointext(flags, ", "))]"
	else
		item = "[name_part] = <span class='value'>[VV_HTML_ENCODE(value)]</span>"

	return "[header][item]</li>"

#undef VV_HTML_ENCODE
