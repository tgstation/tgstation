/datum
	var/var_edited = FALSE //Warrenty void if seal is broken
	var/fingerprintslast = null

/datum/proc/can_vv_get(var_name)
	return TRUE

/datum/proc/vv_edit_var(var_name, var_value) //called whenever a var is edited
	switch(var_name)
		if ("vars")
			return FALSE
		if ("var_edited")
			return FALSE
	var_edited = TRUE
	vars[var_name] = var_value

/datum/proc/vv_get_var(var_name)
	switch(var_name)
		if ("vars")
			return debug_variable(var_name, list(), 0, src)
	return debug_variable(var_name, vars[var_name], 0, src)

//please call . = ..() first and append to the result, that way parent items are always at the top and child items are further down
//add seperaters by doing . += "---"
/datum/proc/vv_get_dropdown()
	. = list()
	. += "---"
	.["Call Proc"] = "?_src_=vars;proc_call=\ref[src]"
	.["Mark Object"] = "?_src_=vars;mark_object=\ref[src]"
	.["Delete"] = "?_src_=vars;delete=\ref[src]"


/datum/proc/on_reagent_change()
	return


/client/proc/debug_variables(datum/D in world)
	set category = "Debug"
	set name = "View Variables"
	//set src in world
	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!usr.client || !usr.client.holder)
		to_chat(usr, "<span class='danger'>You need to be an administrator to access this.</span>")
		return

	if(!D)
		return

	var/islist = islist(D)
	if (!islist && !istype(D))
		return

	var/title = ""
	var/refid = "\ref[D]"
	var/icon/sprite
	var/hash

	var/type = /list
	if (!islist)
		type = D.type



	if(istype(D, /atom))
		var/atom/AT = D
		if(AT.icon && AT.icon_state)
			sprite = new /icon(AT.icon, AT.icon_state)
			hash = md5(AT.icon)
			hash = md5(hash + AT.icon_state)
			usr << browse_rsc(sprite, "vv[hash].png")

	title = "[D] (\ref[D]) = [type]"

	var/sprite_text
	if(sprite)
		sprite_text = "<img src='vv[hash].png'></td><td>"
	var/list/atomsnowflake = list()

	if(istype(D, /atom))
		var/atom/A = D
		if(isliving(A))
			atomsnowflake += "<a href='?_src_=vars;rename=[refid]'><b>[D]</b></a>"
			if(A.dir)
				atomsnowflake += "<br><font size='1'><a href='?_src_=vars;rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=[refid];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=[refid];rotatedir=right'>>></a></font>"
			var/mob/living/M = A
			atomsnowflake += {"
				<br><font size='1'><a href='?_src_=vars;datumedit=[refid];varnameedit=ckey'>[M.ckey ? M.ckey : "No ckey"]</a> / <a href='?_src_=vars;datumedit=[refid];varnameedit=real_name'>[M.real_name ? M.real_name : "No real name"]</a></font>
				<br><font size='1'>
					BRUTE:<font size='1'><a href='?_src_=vars;mobToDamage=[refid];adjustDamage=brute'>[M.getBruteLoss()]</a>
					FIRE:<font size='1'><a href='?_src_=vars;mobToDamage=[refid];adjustDamage=fire'>[M.getFireLoss()]</a>
					TOXIN:<font size='1'><a href='?_src_=vars;mobToDamage=[refid];adjustDamage=toxin'>[M.getToxLoss()]</a>
					OXY:<font size='1'><a href='?_src_=vars;mobToDamage=[refid];adjustDamage=oxygen'>[M.getOxyLoss()]</a>
					CLONE:<font size='1'><a href='?_src_=vars;mobToDamage=[refid];adjustDamage=clone'>[M.getCloneLoss()]</a>
					BRAIN:<font size='1'><a href='?_src_=vars;mobToDamage=[refid];adjustDamage=brain'>[M.getBrainLoss()]</a>
					STAMINA:<font size='1'><a href='?_src_=vars;mobToDamage=[refid];adjustDamage=stamina'>[M.getStaminaLoss()]</a>
				</font>
			"}
		else
			atomsnowflake += "<a href='?_src_=vars;datumedit=[refid];varnameedit=name'><b>[D]</b></a>"
			if(A.dir)
				atomsnowflake += "<br><font size='1'><a href='?_src_=vars;rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=[refid];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=[refid];rotatedir=right'>>></a></font>"
	else
		atomsnowflake += "<b>[D]</b>"

	var/formatted_type = "[type]"
	if(length(formatted_type) > 25)
		var/middle_point = length(formatted_type) / 2
		var/splitpoint = findtext(formatted_type,"/",middle_point)
		if(splitpoint)
			formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
		else
			formatted_type = "Type too long" //No suitable splitpoint (/) found.

	var/marked
	if(holder.marked_datum && holder.marked_datum == D)
		marked = "<br><font size='1' color='red'><b>Marked Object</b></font>"
	var/varedited_line = ""
	if(!islist && D.var_edited)
		varedited_line = "<br><font size='1' color='red'><b>Var Edited</b></font>"

	var/list/dropdownoptions = list()
	if (islist)
		dropdownoptions = list(
			"---",
			"Add Item" = "?_src_=vars;listadd=[refid]",
			"Remove Nulls" = "?_src_=vars;listnulls=[refid]",
			"Remove Dupes" = "?_src_=vars;listdupes=[refid]",
			"Set len" = "?_src_=vars;listlen=[refid]",
			"Shuffle" = "?_src_=vars;listshuffle=[refid]"
			)
	else
		dropdownoptions = D.vv_get_dropdown()
	var/list/dropdownoptions_html = list()

	for (var/name in dropdownoptions)
		var/link = dropdownoptions[name]
		if (link)
			dropdownoptions_html += "<option value='[link]'>[name]</option>"
		else
			dropdownoptions_html += "<option value>[name]</option>"

	var/list/names = list()
	if (!islist)
		for (var/V in D.vars)
			names += V
	sleep(1)//For some reason, without this sleep, VVing will cause client to disconnect on certain objects.

	var/list/variable_html = list()
	if (islist)
		var/list/L = D
		for (var/i in 1 to L.len)
			var/key = L[i]
			var/value
			if (IS_NORMAL_LIST(L) && !isnum(key))
				value = L[key]
			variable_html += debug_variable(i, value, 0, D)
	else

		names = sortList(names)
		for (var/V in names)
			if(D.can_vv_get(V))
				variable_html += D.vv_get_var(V)

	var/html = {"
<html>
	<head>
		<title>[title]</title>
		<style>
			body {
				font-family: Verdana, sans-serif;
				font-size: 9pt;
			}
			.value {
				font-family: "Courier New", monospace;
				font-size: 8pt;
			}
		</style>
	</head>
	<body onload='selectTextField(); updateSearch()' onkeydown='return checkreload()' onkeyup='updateSearch()'>
		<script type="text/javascript">
			function checkreload() {
				if(event.keyCode == 116){	//F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false)
					return false;
				}
				return true;
			}
			function updateSearch(){
				var filter_text = document.getElementById('filter');
				var filter = filter_text.value.toLowerCase();
				if(event.keyCode == 13){	//Enter / return
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for ( var i = 0; i < lis.length; ++i )
					{
						try{
							var li = lis\[i\];
							if ( li.style.backgroundColor == "#ffee88" )
							{
								alist = lis\[i\].getElementsByTagName("a")
								if(alist.length > 0){
									location.href=alist\[0\].href;
								}
							}
						}catch(err) {   }
					}
					return
				}
				if(event.keyCode == 38){	//Up arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for ( var i = 0; i < lis.length; ++i )
					{
						try{
							var li = lis\[i\];
							if ( li.style.backgroundColor == "#ffee88" )
							{
								if( (i-1) >= 0){
									var li_new = lis\[i-1\];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						}catch(err) {  }
					}
					return
				}
				if(event.keyCode == 40){	//Down arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for ( var i = 0; i < lis.length; ++i )
					{
						try{
							var li = lis\[i\];
							if ( li.style.backgroundColor == "#ffee88" )
							{
								if( (i+1) < lis.length){
									var li_new = lis\[i+1\];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						}catch(err) {  }
					}
					return
				}

				//This part here resets everything to how it was at the start so the filter is applied to the complete list. Screw efficiency, it's client-side anyway and it only looks through 200 or so variables at maximum anyway (mobs).
				if(complete_list != null && complete_list != ""){
					var vars_ol1 = document.getElementById("vars");
					vars_ol1.innerHTML = complete_list
				}
				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);
				if(filter == ""){
					return;
				}else{
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for ( var i = 0; i < lis.length; ++i )
					{
						try{
							var li = lis\[i\];
							if ( li.innerText.toLowerCase().indexOf(filter) == -1 )
							{
								vars_ol.removeChild(li);
								i--;
							}
						}catch(err) {   }
					}
				}
				var lis_new = vars_ol.getElementsByTagName("li");
				for ( var j = 0; j < lis_new.length; ++j )
				{
					var li1 = lis\[j\];
					if (j == 0){
						li1.style.backgroundColor = "#ffee88";
					}else{
						li1.style.backgroundColor = "white";
					}
				}
			}
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if (lastsearch) {
					filter_text.value = lastsearch;
					updateSearch();
				}
			}
			function loadPage(list) {
				if(list.options\[list.selectedIndex\].value == ""){
					return;
				}
				location.href=list.options\[list.selectedIndex\].value;
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i\];
					while (c.charAt(0)==' ') c = c.substring(1,c.length);
					if (c.indexOf(name)==0) return c.substring(name.length,c.length);
				}
				return "";
			}

		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[atomsnowflake.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							[marked]
							[varedited_line]
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='?_src_=vars;datumrefresh=[refid]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="loadPage(this.form.elements\[0\])"
									target="_parent._top"
									onmouseclick="this.focus()"
									style="background-color:#ffffff">
									<option value selected>Select option</option>
									[dropdownoptions_html.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var vars_ol = document.getElementById("vars");
			var complete_list = vars_ol.innerHTML;
		</script>
	</body>
</html>
"}

	usr << browse(html, "window=variables[refid];size=475x650")


#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/proc/debug_variable(name, value, level, datum/DA = null, sanitize = TRUE)
	var/header
	if(DA)
		if (islist(DA))
			var/index = name
			if (value)
				name = DA[name] //name is really the index until this line
			else
				value = DA[name]
			header = "<li style='backgroundColor:white'>(<a href='?_src_=vars;listedit=\ref[DA];index=[index]'>E</a>) (<a href='?_src_=vars;listchange=\ref[DA];index=[index]'>C</a>) (<a href='?_src_=vars;listremove=\ref[DA];index=[index]'>-</a>) "
		else
			header = "<li style='backgroundColor:white'>(<a href='?_src_=vars;datumedit=\ref[DA];varnameedit=[name]'>E</a>) (<a href='?_src_=vars;datumchange=\ref[DA];varnamechange=[name]'>C</a>) (<a href='?_src_=vars;datummass=\ref[DA];varnamemass=[name]'>M</a>) "
	else
		header = "<li>"

	var/item
	if (isnull(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>null</span>"

	else if (istext(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>\"[VV_HTML_ENCODE(value)]\"</span>"

	else if (isicon(value))
		#ifdef VARSICON
		var/icon/I = new/icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp\ref[I][rnd].png"
		usr << browse_rsc(I, rname)
		item = "[VV_HTML_ENCODE(name)] = (<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
		#else
		item = "[VV_HTML_ENCODE(name)] = /icon (<span class='value'>[value]</span>)"
		#endif

/*		else if (istype(value, /image))
		#ifdef VARSICON
		var/rnd = rand(1, 10000)
		var/image/I = value

		src << browse_rsc(I.icon, "tmp\ref[value][rnd].png")
		html += "[name] = <img src=\"tmp\ref[value][rnd].png\">"
		#else
		html += "[name] = /image (<span class='value'>[value]</span>)"
		#endif
*/
	else if (isfile(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>'[value]'</span>"

	//else if (istype(value, /client))
	//	var/client/C = value
	//	item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] \ref[value]</a> = [C] [C.type]"

	else if (istype(value, /datum))
		var/datum/D = value
		if ("[D]" != "[D.type]") //if the thing as a name var, lets use it.
			item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] \ref[value]</a> = [D] [D.type]"
		else
			item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] \ref[value]</a> = [D.type]"

	else if (islist(value))
		var/list/L = value
		var/list/items = list()

		if (L.len > 0 && !(name == "underlays" || name == "overlays" || L.len > (IS_NORMAL_LIST(L) ? 50 : 150)))
			for (var/i in 1 to L.len)
				var/key = L[i]
				var/val
				if (IS_NORMAL_LIST(L) && !isnum(key))
					val = L[key]
				if (!val)
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] = /list ([L.len])</a><ul>[items.Join()]</ul>"
		else
			item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] = /list ([L.len])</a>"

	else
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>[VV_HTML_ENCODE(value)]</span>"

	return "[header][item]</li>"

#undef VV_HTML_ENCODE

/client/proc/view_var_Topic(href, href_list, hsrc)
	if( (usr.client != src) || !src.holder )
		return
	if(href_list["Vars"])
		debug_variables(locate(href_list["Vars"]))

	else if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(!DAT) //can't be an istype() because /client etc aren't datums
			return
		src.debug_variables(DAT)

	else if(href_list["mob_player_panel"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["mob_player_panel"]) in GLOB.mob_list
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.holder.show_player_panel(M)
		href_list["datumrefresh"] = href_list["mob_player_panel"]

	else if(href_list["godmode"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["godmode"]) in GLOB.mob_list
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_godmode(M)
		href_list["datumrefresh"] = href_list["godmode"]

	else if(href_list["mark_object"])
		if(!check_rights(0))
			return

		var/datum/D = locate(href_list["mark_object"])
		if(!istype(D))
			to_chat(usr, "This can only be done to instances of type /datum")
			return

		src.holder.marked_datum = D
		href_list["datumrefresh"] = href_list["mark_object"]

	else if(href_list["proc_call"])
		if(!check_rights(0))
			return

		var/T = locate(href_list["proc_call"])

		if(T)
			callproc_datum(T)

	else if(href_list["delete"])
		if(!check_rights(R_DEBUG, 0))
			return

		var/datum/D = locate(href_list["delete"])
		if(!D)
			to_chat(usr, "Unable to locate item!")
		admin_delete(D)
		href_list["datumrefresh"] = href_list["delete"]

	else if(href_list["regenerateicons"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["regenerateicons"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		M.regenerate_icons()

//Needs +VAREDIT past this point

	else if(check_rights(R_VAREDIT))


	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).

		if(href_list["rename"])
			if(!check_rights(0))
				return

			var/mob/M = locate(href_list["rename"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			var/new_name = stripped_input(usr,"What would you like to name this mob?","Input a name",M.real_name,MAX_NAME_LEN)
			if( !new_name || !M )
				return

			message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
			M.fully_replace_character_name(M.real_name,new_name)
			href_list["datumrefresh"] = href_list["rename"]

		else if(href_list["varnameedit"] && href_list["datumedit"])
			if(!check_rights(0))
				return

			var/D = locate(href_list["datumedit"])
			if(!istype(D, /datum))
				to_chat(usr, "This can only be used on datums")
				return

			modify_variables(D, href_list["varnameedit"], 1)

		else if(href_list["varnamechange"] && href_list["datumchange"])
			if(!check_rights(0))
				return

			var/D = locate(href_list["datumchange"])
			if(!istype(D, /datum))
				to_chat(usr, "This can only be used on datums")
				return

			modify_variables(D, href_list["varnamechange"], 0)

		else if(href_list["varnamemass"] && href_list["datummass"])
			if(!check_rights(0))
				return

			var/datum/D = locate(href_list["datummass"])
			if(!istype(D))
				to_chat(usr, "This can only be used on instances of type /datum")
				return

			cmd_mass_modify_object_variables(D, href_list["varnamemass"])

		else if(href_list["listedit"] && href_list["index"])
			var/index = text2num(href_list["index"])
			if (!index)
				return

			var/list/L = locate(href_list["listedit"])
			if (!istype(L))
				to_chat(usr, "This can only be used on instances of type /list")
				return

			mod_list(L, null, "list", "contents", index, autodetect_class = TRUE)

		else if(href_list["listchange"] && href_list["index"])
			var/index = text2num(href_list["index"])
			if (!index)
				return

			var/list/L = locate(href_list["listchange"])
			if (!istype(L))
				to_chat(usr, "This can only be used on instances of type /list")
				return

			mod_list(L, null, "list", "contents", index, autodetect_class = FALSE)

		else if(href_list["listremove"] && href_list["index"])
			var/index = text2num(href_list["index"])
			if (!index)
				return

			var/list/L = locate(href_list["listremove"])
			if (!istype(L))
				to_chat(usr, "This can only be used on instances of type /list")
				return

			var/variable = L[index]
			var/prompt = alert("Do you want to remove item number [index] from list?", "Confirm", "Yes", "No")
			if (prompt != "Yes")
				return
			L.Cut(index, index+1)
			log_world("### ListVarEdit by [src]: /list's contents: REMOVED=[html_encode("[variable]")]")
			log_admin("[key_name(src)] modified list's contents: REMOVED=[variable]")
			message_admins("[key_name_admin(src)] modified list's contents: REMOVED=[variable]")

		else if(href_list["listadd"])
			var/list/L = locate(href_list["listadd"])
			if (!istype(L))
				to_chat(usr, "This can only be used on instances of type /list")
				return

			mod_list_add(L, null, "list", "contents")

		else if(href_list["listdupes"])
			var/list/L = locate(href_list["listdupes"])
			if (!istype(L))
				to_chat(usr, "This can only be used on instances of type /list")
				return

			uniqueList_inplace(L)
			log_world("### ListVarEdit by [src]: /list contents: CLEAR DUPES")
			log_admin("[key_name(src)] modified list's contents: CLEAR DUPES")
			message_admins("[key_name_admin(src)] modified list's contents: CLEAR DUPES")

		else if(href_list["listnulls"])
			var/list/L = locate(href_list["listnulls"])
			if (!istype(L))
				to_chat(usr, "This can only be used on instances of type /list")
				return

			listclearnulls(L)
			log_world("### ListVarEdit by [src]: /list contents: CLEAR NULLS")
			log_admin("[key_name(src)] modified list's contents: CLEAR NULLS")
			message_admins("[key_name_admin(src)] modified list's contents: CLEAR NULLS")

		else if(href_list["listlen"])
			var/list/L = locate(href_list["listlen"])
			if (!istype(L))
				to_chat(usr, "This can only be used on instances of type /list")
				return
			var/value = vv_get_value(VV_NUM)
			if (value["class"] != VV_NUM)
				return

			L.len = value["value"]
			log_world("### ListVarEdit by [src]: /list len: [L.len]")
			log_admin("[key_name(src)] modified list's len: [L.len]")
			message_admins("[key_name_admin(src)] modified list's len: [L.len]")

		else if(href_list["listshuffle"])
			var/list/L = locate(href_list["listshuffle"])
			if (!istype(L))
				to_chat(usr, "This can only be used on instances of type /list")
				return

			shuffle_inplace(L)
			log_world("### ListVarEdit by [src]: /list contents: SHUFFLE")
			log_admin("[key_name(src)] modified list's contents: SHUFFLE")
			message_admins("[key_name_admin(src)] modified list's contents: SHUFFLE")

		else if(href_list["give_spell"])
			if(!check_rights(0))
				return

			var/mob/M = locate(href_list["give_spell"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			src.give_spell(M)
			href_list["datumrefresh"] = href_list["give_spell"]

		else if(href_list["remove_spell"])
			if(!check_rights(0))
				return

			var/mob/M = locate(href_list["remove_spell"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			remove_spell(M)
			href_list["datumrefresh"] = href_list["remove_spell"]

		else if(href_list["give_disease"])
			if(!check_rights(0))
				return

			var/mob/M = locate(href_list["give_disease"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			src.give_disease(M)
			href_list["datumrefresh"] = href_list["give_spell"]

		else if(href_list["gib"])
			if(!check_rights(R_FUN))
				return

			var/mob/M = locate(href_list["gib"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			src.cmd_admin_gib(M)

		else if(href_list["build_mode"])
			if(!check_rights(R_BUILDMODE))
				return

			var/mob/M = locate(href_list["build_mode"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			togglebuildmode(M)
			href_list["datumrefresh"] = href_list["build_mode"]

		else if(href_list["drop_everything"])
			if(!check_rights(0))
				return

			var/mob/M = locate(href_list["drop_everything"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			if(usr.client)
				usr.client.cmd_admin_drop_everything(M)

		else if(href_list["direct_control"])
			if(!check_rights(0))
				return

			var/mob/M = locate(href_list["direct_control"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			if(usr.client)
				usr.client.cmd_assume_direct_control(M)

		else if(href_list["offer_control"])
			if(!check_rights(0))
				return

			var/mob/M = locate(href_list["offer_control"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return
			offer_control(M)

		else if(href_list["delall"])
			if(!check_rights(R_DEBUG|R_SERVER))
				return

			var/obj/O = locate(href_list["delall"])
			if(!isobj(O))
				to_chat(usr, "This can only be used on instances of type /obj")
				return

			var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
			if(action_type == "Cancel" || !action_type)
				return

			if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
				return

			if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
				return

			var/O_type = O.type
			switch(action_type)
				if("Strict type")
					var/i = 0
					for(var/obj/Obj in world)
						if(Obj.type == O_type)
							i++
							qdel(Obj)
						CHECK_TICK
					if(!i)
						to_chat(usr, "No objects of this type exist")
						return
					log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
					message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) </span>")
				if("Type and subtypes")
					var/i = 0
					for(var/obj/Obj in world)
						if(istype(Obj,O_type))
							i++
							qdel(Obj)
						CHECK_TICK
					if(!i)
						to_chat(usr, "No objects of this type exist")
						return
					log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
					message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) </span>")

		else if(href_list["addreagent"])
			if(!check_rights(0))
				return

			var/atom/A = locate(href_list["addreagent"])

			if(!A.reagents)
				var/amount = input(usr, "Specify the reagent size of [A]", "Set Reagent Size", 50) as num
				if(amount)
					A.create_reagents(amount)

			if(A.reagents)
				var/chosen_id
				var/list/reagent_options = sortList(GLOB.chemical_reagents_list)
				switch(alert(usr, "Choose a method.", "Add Reagents", "Enter ID", "Choose ID"))
					if("Enter ID")
						var/valid_id
						while(!valid_id)
							chosen_id = stripped_input(usr, "Enter the ID of the reagent you want to add.")
							if(!chosen_id) //Get me out of here!
								break
							for(var/ID in reagent_options)
								if(ID == chosen_id)
									valid_id = 1
							if(!valid_id)
								to_chat(usr, "<span class='warning'>A reagent with that ID doesn't exist!</span>")
					if("Choose ID")
						chosen_id = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in reagent_options
				if(chosen_id)
					var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", A.reagents.maximum_volume) as num
					if(amount)
						A.reagents.add_reagent(chosen_id, amount)
						log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to \the [A]")
						message_admins("<span class='notice'>[key_name(usr)] has added [amount] units of [chosen_id] to \the [A]</span>")

			href_list["datumrefresh"] = href_list["addreagent"]

		else if(href_list["explode"])
			if(!check_rights(R_FUN))
				return

			var/atom/A = locate(href_list["explode"])
			if(!isobj(A) && !ismob(A) && !isturf(A))
				to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
				return

			src.cmd_admin_explosion(A)
			href_list["datumrefresh"] = href_list["explode"]

		else if(href_list["emp"])
			if(!check_rights(R_FUN))
				return

			var/atom/A = locate(href_list["emp"])
			if(!isobj(A) && !ismob(A) && !isturf(A))
				to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
				return

			src.cmd_admin_emp(A)
			href_list["datumrefresh"] = href_list["emp"]

		else if(href_list["rotatedatum"])
			if(!check_rights(0))
				return

			var/atom/A = locate(href_list["rotatedatum"])
			if(!istype(A))
				to_chat(usr, "This can only be done to instances of type /atom")
				return

			switch(href_list["rotatedir"])
				if("right")
					A.setDir(turn(A.dir, -45))
				if("left")
					A.setDir(turn(A.dir, 45))
			href_list["datumrefresh"] = href_list["rotatedatum"]

		else if(href_list["editorgans"])
			if(!check_rights(0))
				return

			var/mob/living/carbon/C = locate(href_list["editorgans"]) in GLOB.mob_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			manipulate_organs(C)
			href_list["datumrefresh"] = href_list["editorgans"]

		else if(href_list["hallucinate"])
			if(!check_rights(0))
				return

			var/mob/living/carbon/C = locate(href_list["hallucinate"]) in GLOB.mob_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			var/list/hallucinations = subtypesof(/datum/hallucination)
			var/result = input(usr, "Choose the hallucination to apply","Send Hallucination") as null|anything in hallucinations
			if(!usr)
				return
			if(QDELETED(C))
				to_chat(usr, "Mob doesn't exist anymore")
				return

			if(result)
				new result(C, TRUE)

		else if(href_list["makehuman"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/monkey/Mo = locate(href_list["makehuman"]) in GLOB.mob_list
			if(!istype(Mo))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/monkey")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!Mo)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("humanone"=href_list["makehuman"]))

		else if(href_list["makemonkey"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["makemonkey"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

		else if(href_list["makerobot"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["makerobot"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("makerobot"=href_list["makerobot"]))

		else if(href_list["makealien"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["makealien"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("makealien"=href_list["makealien"]))

		else if(href_list["makeslime"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["makeslime"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("makeslime"=href_list["makeslime"]))

		else if(href_list["makeai"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/H = locate(href_list["makeai"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("makeai"=href_list["makeai"]))

		else if(href_list["setspecies"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["setspecies"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return

			var/result = input(usr, "Please choose a new species","Species") as null|anything in GLOB.species_list

			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			if(result)
				var/newtype = GLOB.species_list[result]
				admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [H] to [result]")
				H.set_species(newtype)

		else if(href_list["editbodypart"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/C = locate(href_list["editbodypart"]) in GLOB.mob_list
			if(!istype(C))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
				return

			var/edit_action = input(usr, "What would you like to do?","Modify Body Part") as null|anything in list("add","remove", "augment")
			if(!edit_action)
				return
			var/list/limb_list = list("head", "l_arm", "r_arm", "l_leg", "r_leg")
			if(edit_action == "augment")
				limb_list += "chest"
			var/result = input(usr, "Please choose which body part to [edit_action]","[capitalize(edit_action)] Body Part") as null|anything in limb_list

			if(!C)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			if(result)
				var/obj/item/bodypart/BP = C.get_bodypart(result)
				switch(edit_action)
					if("remove")
						if(BP)
							BP.drop_limb()
						else
							to_chat(usr, "[C] doesn't have such bodypart.")
					if("add")
						if(BP)
							to_chat(usr, "[C] already has such bodypart.")
						else
							if(!C.regenerate_limb(result))
								to_chat(usr, "[C] cannot have such bodypart.")
					if("augment")
						if(ishuman(C))
							if(BP)
								BP.change_bodypart_status(BODYPART_ROBOTIC, TRUE, TRUE)
							else
								to_chat(usr, "[C] doesn't have such bodypart.")
						else
							to_chat(usr, "Only humans can be augmented.")
			admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [C]")


		else if(href_list["purrbation"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/human/H = locate(href_list["purrbation"]) in GLOB.mob_list
			if(!istype(H))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
				return
			if(!ishumanbasic(H))
				to_chat(usr, "This can only be done to the basic human species at the moment.")
				return

			if(!H)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			var/success = purrbation_toggle(H)
			if(success)
				to_chat(usr, "Put [H] on purrbation.")
				log_admin("[key_name(usr)] has put [key_name(H)] on purrbation.")
				var/msg = "<span class='notice'>[key_name_admin(usr)] has put [key_name(H)] on purrbation.</span>"
				message_admins(msg)
				admin_ticket_log(H, msg)

			else
				to_chat(usr, "Removed [H] from purrbation.")
				log_admin("[key_name(usr)] has removed [key_name(H)] from purrbation.")
				var/msg = "<span class='notice'>[key_name_admin(usr)] has removed [key_name(H)] from purrbation.</span>"
				message_admins(msg)
				admin_ticket_log(H, msg)

		else if(href_list["adjustDamage"] && href_list["mobToDamage"])
			if(!check_rights(0))
				return

			var/mob/living/L = locate(href_list["mobToDamage"]) in GLOB.mob_list
			if(!istype(L))
				return

			var/Text = href_list["adjustDamage"]

			var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

			if(!L)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			switch(Text)
				if("brute")
					L.adjustBruteLoss(amount)
				if("fire")
					L.adjustFireLoss(amount)
				if("toxin")
					L.adjustToxLoss(amount)
				if("oxygen")
					L.adjustOxyLoss(amount)
				if("brain")
					L.adjustBrainLoss(amount)
				if("clone")
					L.adjustCloneLoss(amount)
				if("stamina")
					L.adjustStaminaLoss(amount)
				else
					to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
					return

			if(amount != 0)
				log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [L] ")
				var/msg = "<span class='notice'>[key_name(usr)] dealt [amount] amount of [Text] damage to [L] </span>"
				message_admins(msg)
				admin_ticket_log(L, msg)
				href_list["datumrefresh"] = href_list["mobToDamage"]

