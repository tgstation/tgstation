
// reference: /client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)

client
	proc/debug_variables(datum/D in world)
		set category = "Debug"
		set name = "View Variables"
		//set src in world


		var/title = ""
		var/body = ""

		if(!D)	return
		if(istype(D, /atom))
			var/atom/A = D
			title = "[A.name] (\ref[A]) = [A.type]"

			#ifdef VARSICON
			if (A.icon)
				body += debug_variable("icon", new/icon(A.icon, A.icon_state, A.dir), 0)
			#endif
		title = "[D] (\ref[D]) = [D.type]"

		body += {"<script type="text/javascript">
					function updateSearch(){
						var filter_text = document.getElementById('filter');
						var filter = filter_text.value;

						if(filter.value == ""){
							return;
						}else{
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.innerHTML.indexOf(filter) == -1 )
									{
										vars_ol.removeChild(li);
										i--;
										//return
									}
								}catch(err) {   }
							}
						}

					}

					function selectTextField(){
						var filter_text = document.getElementById('filter');
						filter_text.focus();
						filter_text.select();

					}

					function loadPage(list) {

						if(list.options\[list.selectedIndex\].value == ""){
							return;
						}

						location.href=list.options\[list.selectedIndex\].value;

					}
				</script> "}

		body += "<body onload='selectTextField()'>"

		body += "<div align='center'><table width='100%'><tr><td width='50%'><div align='center'><b>"

		if(istype(D,/atom))
			body += "<a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=name'>[D]</a>"
		else
			body += "[D]"

		body += "<br><font size='1'>[D.type]</font></b>"

		if(src.holder && src.holder.marked_datum && src.holder.marked_datum == D)
			body += "<br><font size='1' color='red'><b>Marked Object</b></font>"

		body += "</div></td>"

		body += "<td width='50%'><div align='center'><a href='byond://?src=\ref[src];datumrefresh=\ref[D]'>Refresh</a>"

		//if(ismob(D))
		//	body += "<br><a href='byond://?src=\ref[src];mob_player_panel=\ref[D]'>Show player panel</a></div></td></tr></table></div><hr>"

		body += {"	<form>
					<select name="file" size="1"
					onchange="loadPage(this.form.elements\[0\])"
					target="_parent._top"
					onmouseclick="this.focus()"
					style="background-color:#ffffff">
				"}

		body += {"	<option value>Select option</option>
  					<option value> </option>
				"}


		body += "<option value='byond://?src=\ref[src];mark_object=\ref[D]'>Mark Object</option>"

		body += "<option value>---</option>"
		if(ismob(D))
			body += "<option value='byond://?src=\ref[src];mob_player_panel=\ref[D]'>Show player panel</option>"
		if(isobj(D) || ismob(D) || isturf(D))
			body += "<option value='byond://?src=\ref[src];explode=\ref[D]'>Trigger explosion</option>"
			body += "<option value='byond://?src=\ref[src];emp=\ref[D]'>Trigger EM pulse</option>"

		body += "</select></form>"

		body += "</div></td></tr></table></div><hr>"

		body += "<font size='1'><b>E</b> - Edit, tries to determine the variable type by itself.<br>"
		body += "<b>C</b> - Change, asks you for the var type first.<br>"
		body += "<b>M</b> - Mass modify: changes this variable for all objects of this type.</font><br>"

		body += "<hr><table width='100%'><tr><td width='20%'><div align='center'><b>Search:</b></div></td><td width='80%'><input type='text' onkeyup='updateSearch()' id='filter' name='filter_text' value='' style='width:100%;'></td></tr></table><hr>"

		body += "<ol id='vars'>"

		var/list/names = list()
		for (var/V in D.vars)
			names += V

		names = sortList(names)

		for (var/V in names)
			body += debug_variable(V, D.vars[V], 0, D)

		body += "</ol>"

		var/html = "<html><head>"
		if (title)
			html += "<title>[title]</title>"
		html += {"<style>
	body
	{
		font-family: Verdana, sans-serif;
		font-size: 9pt;
	}
	.value
	{
		font-family: "Courier New", monospace;
		font-size: 8pt;
	}
	</style>"}
		html += "</head><body>"
		html += body
		html += "</body></html>"

		usr << browse(html, "window=variables\ref[D];size=475x650")

		return

	proc/debug_variable(name, value, level, var/datum/DA = null)
		var/html = ""

		if(DA)
			html += "<li>(<a href='byond://?src=\ref[src];datumedit=\ref[DA];varnameedit=[name]'>E</a>) (<a href='byond://?src=\ref[src];datumchange=\ref[DA];varnamechange=[name]'>C</a>) (<a href='byond://?src=\ref[src];datummass=\ref[DA];varnamemass=[name]'>M</a>) "
		else
			html += "<li>"

		if (isnull(value))
			html += "[name] = <span class='value'>null</span>"

		else if (istext(value))
			html += "[name] = <span class='value'>\"[value]\"</span>"

		else if (isicon(value))
			#ifdef VARSICON
			var/icon/I = new/icon(value)
			var/rnd = rand(1,10000)
			var/rname = "tmp\ref[I][rnd].png"
			usr << browse_rsc(I, rname)
			html += "[name] = (<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
			#else
			html += "[name] = /icon (<span class='value'>[value]</span>)"
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
			html += "[name] = <span class='value'>'[value]'</span>"

		else if (istype(value, /datum))
			var/datum/D = value
			html += "<a href='byond://?src=\ref[src];Vars=\ref[value]'>[name] \ref[value]</a> = [D.type]"

		else if (istype(value, /client))
			var/client/C = value
			html += "<a href='byond://?src=\ref[src];Vars=\ref[value]'>[name] \ref[value]</a> = [C] [C.type]"
	//
		else if (istype(value, /list))
			var/list/L = value
			html += "[name] = /list ([L.len])"

			if (L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > 500))
				// not sure if this is completely right...
				if (0) // (L.vars.len > 0)
					html += "<ol>"
					for (var/entry in L)
						html += debug_variable(entry, L[entry], level + 1)
					html += "</ol>"
				else
					html += "<ul>"
					for (var/index = 1, index <= L.len, index++)
						html += debug_variable("[index]", L[index], level + 1)
					html += "</ul>"
		else
			html += "[name] = <span class='value'>[value]</span>"

		html += "</li>"

		return html

	Topic(href, href_list, hsrc)

		if (href_list["Vars"])
			debug_variables(locate(href_list["Vars"]))
		else if (href_list["varnameedit"])
			if(!href_list["datumedit"] || !href_list["varnameedit"])
				usr << "Varedit error: Not all information has been sent Contact a coder."
				return
			var/datum/DAT = locate(href_list["datumedit"])
			if(!DAT)
				usr << "Item not found"
				return
			if(!istype(DAT,/datum))
				usr << "Can't edit an item of this type. Type must be /datum, so anything except simple variables. [DAT]"
				return
			modify_variables(DAT, href_list["varnameedit"], 1)
		else if (href_list["varnamechange"])
			if(!href_list["datumchange"] || !href_list["varnamechange"])
				usr << "Varedit error: Not all information has been sent. Contact a coder."
				return
			var/datum/DAT = locate(href_list["datumchange"])
			if(!DAT)
				usr << "Item not found"
				return
			if(!istype(DAT,/datum))
				usr << "Can't edit an item of this type. Type must be /datum, so anything except simple variables. [DAT]"
				return
			modify_variables(DAT, href_list["varnamechange"], 0)
		else if (href_list["varnamemass"])
			if(!href_list["datummass"] || !href_list["varnamemass"])
				usr << "Varedit error: Not all information has been sent. Contact a coder."
				return
			var/atom/A = locate(href_list["datummass"])
			if(!A)
				usr << "Item not found"
				return
			if(!istype(A,/atom))
				usr << "Can't edit an item of this type. Type must be /atom, so an object, turf, mob or area. [A]"
				return
			cmd_mass_modify_object_variables(A, href_list["varnamemass"])
		else if (href_list["mob_player_panel"])
			if(!href_list["mob_player_panel"])
				return
			var/mob/MOB = locate(href_list["mob_player_panel"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.holder.show_player_panel(MOB)
			href_list["datumrefresh"] = href_list["mob_player_panel"]
		else if (href_list["explode"])
			if(!href_list["explode"])
				return
			var/atom/A = locate(href_list["explode"])
			if(!A)
				return
			if(!isobj(A) && !ismob(A) && !isturf(A))
				return
			src.cmd_admin_explosion(A)
			href_list["datumrefresh"] = href_list["explode"]
		else if (href_list["emp"])
			if(!href_list["emp"])
				return
			var/atom/A = locate(href_list["emp"])
			if(!A)
				return
			if(!isobj(A) && !ismob(A) && !isturf(A))
				return
			src.cmd_admin_emp(A)
			href_list["datumrefresh"] = href_list["emp"]
		else if (href_list["mark_object"])
			if(!href_list["mark_object"])
				return
			var/datum/D = locate(href_list["mark_object"])
			if(!D)
				return
			if(!src.holder)
				return
			src.holder.marked_datum = D
			href_list["datumrefresh"] = href_list["mark_object"]
		else
			..()


		if (href_list["datumrefresh"])
			if(!href_list["datumrefresh"])
				return
			var/datum/DAT = locate(href_list["datumrefresh"])
			if(!DAT)
				return
			if(!istype(DAT,/datum))
				return
			src.debug_variables(DAT)


/mob/proc/Delete(atom/A in view())
	set category = "Debug"
	switch (alert("Are you sure you wish to delete \the [A.name] at ([A.x],[A.y],[A.z]) ?", "Admin Delete Object","Yes","No"))
		if("Yes")
			log_admin("[usr.key] deleted [A.name] at ([A.x],[A.y],[A.z])")
