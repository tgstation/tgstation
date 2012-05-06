
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

		var/icon/sprite

		if(istype(D,/atom))
			var/atom/AT = D
			if(AT.icon && AT.icon_state)
				sprite = new /icon(AT.icon, AT.icon_state)
				usr << browse_rsc(sprite, "view_vars_sprite.png")

		title = "[D] (\ref[D]) = [D.type]"

		body += {"<script type="text/javascript">

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

						if(filter.value == ""){
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

		body += "<body onload='selectTextField(); updateSearch()' onkeyup='updateSearch()'>"

		body += "<div align='center'><table width='100%'><tr><td width='50%'>"

		if(sprite)
			body += "<table align='center' width='100%'><tr><td><img src='view_vars_sprite.png'></td><td>"
		else
			body += "<table align='center' width='100%'><tr><td>"

		body += "<div align='center'>"

		if(istype(D,/atom))
			var/atom/A = D
			if(ismob(A))
				body += "<a href='byond://?src=\ref[src];rename=\ref[D]'><b>[D]</b></a>"
				if(A.dir)
					body += "<br><font size='1'><a href='byond://?src=\ref[src];rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='byond://?src=\ref[src];rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
				var/mob/M = A
				body += "<br><font size='1'><a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=ckey'>[M.ckey ? M.ckey : "No ckey"]</a> / <a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=real_name'>[M.real_name ? M.real_name : "No real name"]</a></font>"
				body += {"
				<br><font size='1'>
				BRUTE:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["brute"]'>[M.getBruteLoss()]</a>
				FIRE:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["fire"]'>[M.getFireLoss()]</a>
				TOXIN:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["toxin"]'>[M.getToxLoss()]</a>
				OXY:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["oxygen"]'>[M.getOxyLoss()]</a>
				CLONE:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["clone"]'>[M.getCloneLoss()]</a>
				BRAIN:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["brain"]'>[M.getBrainLoss()]</a>
				</font>


				"}
			else
				body += "<a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=name'><b>[D]</b></a>"
				if(A.dir)
					body += "<br><font size='1'><a href='byond://?src=\ref[src];rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='byond://?src=\ref[src];rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
		else
			body += "<b>[D]</b>"

		body += "</div>"

		body += "</tr></td></table>"

		var/formatted_type = text("[D.type]")
		if(length(formatted_type) > 25)
			var/middle_point = length(formatted_type) / 2
			var/splitpoint = findtext(formatted_type,"/",middle_point)
			if(splitpoint)
				formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
			else
				formatted_type = "Type too long" //No suitable splitpoint (/) found.

		body += "<div align='center'><b><font size='1'>[formatted_type]</font></b>"

		if(src.holder && src.holder.marked_datum && src.holder.marked_datum == D)
			body += "<br><font size='1' color='red'><b>Marked Object</b></font>"

		body += "</div>"

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
		if(ismob(D))
			body += "<option value='byond://?src=\ref[src];mob_player_panel=\ref[D]'>Show player panel</option>"

		body += "<option value>---</option>"

		if(ismob(D))
			body += "<option value='byond://?src=\ref[src];give_spell=\ref[D]'>Give Spell</option>"
			body += "<option value='byond://?src=\ref[src];ninja=\ref[D]'>Make Space Ninja</option>"
			body += "<option value='byond://?src=\ref[src];godmode=\ref[D]'>Toggle Godmode</option>"
			body += "<option value='byond://?src=\ref[src];build_mode=\ref[D]'>Toggle Build Mode</option>"
			body += "<option value='byond://?src=\ref[src];direct_control=\ref[D]'>Assume Direct Control</option>"
			body += "<option value='byond://?src=\ref[src];drop_everything=\ref[D]'>Drop Everything</option>"
			if(ishuman(D))
				body += "<option value>---</option>"
				body += "<option value='byond://?src=\ref[src];makeai=\ref[D]'>Make AI</option>"
				body += "<option value='byond://?src=\ref[src];makeaisilent=\ref[D]'>Make AI (Silently)</option>"
				body += "<option value='byond://?src=\ref[src];makerobot=\ref[D]'>Make cyborg</option>"
				body += "<option value='byond://?src=\ref[src];makemonkey=\ref[D]'>Make monkey</option>"
				body += "<option value='byond://?src=\ref[src];makealien=\ref[D]'>Make alien</option>"
				body += "<option value='byond://?src=\ref[src];makemetroid=\ref[D]'>Make metroid</option>"
			body += "<option value>---</option>"
			body += "<option value='byond://?src=\ref[src];gib=\ref[D]'>Gib</option>"
		if(isobj(D))
			body += "<option value='byond://?src=\ref[src];delall=\ref[D]'>Delete all of type</option>"
		if(isobj(D) || ismob(D) || isturf(D))
			body += "<option value='byond://?src=\ref[src];explode=\ref[D]'>Trigger explosion</option>"
			body += "<option value='byond://?src=\ref[src];emp=\ref[D]'>Trigger EM pulse</option>"

		body += "</select></form>"

		body += "</div></td></tr></table></div><hr>"

		body += "<font size='1'><b>E</b> - Edit, tries to determine the variable type by itself.<br>"
		body += "<b>C</b> - Change, asks you for the var type first.<br>"
		body += "<b>M</b> - Mass modify: changes this variable for all objects of this type.</font><br>"

		body += "<hr><table width='100%'><tr><td width='20%'><div align='center'><b>Search:</b></div></td><td width='80%'><input type='text' id='filter' name='filter_text' value='' style='width:100%;'></td></tr></table><hr>"

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

		html += {"
			<script type='text/javascript'>
				var vars_ol = document.getElementById("vars");
				var complete_list = vars_ol.innerHTML;
			</script>
		"}

		html += "</body></html>"

		usr << browse(html, "window=variables\ref[D];size=475x650")

		return

	proc/debug_variable(name, value, level, var/datum/DA = null)
		var/html = ""

		if(DA)
			html += "<li style='backgroundColor:white'>(<a href='byond://?src=\ref[src];datumedit=\ref[DA];varnameedit=[name]'>E</a>) (<a href='byond://?src=\ref[src];datumchange=\ref[DA];varnamechange=[name]'>C</a>) (<a href='byond://?src=\ref[src];datummass=\ref[DA];varnamemass=[name]'>M</a>) "
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
				if(0)   //(L.vars.len > 0)
					html += "<ol>"
					html += "</ol>"
				else
					html += "<ul>"
					var/index = 1
					for (var/entry in L)
						if(istext(entry))
							html += debug_variable(entry, L[entry], level + 1)
						//html += debug_variable("[index]", L[index], level + 1)
						else
							html += debug_variable(index, L[index], level + 1)
						index++
					html += "</ul>"

		else
			html += "[name] = <span class='value'>[value]</span>"

		html += "</li>"

		return html

	Topic(href, href_list, hsrc)

		if (href_list["Vars"])
			debug_variables(locate(href_list["Vars"]))

		//~CARN: for renaming mobs (updates their real_name and their ID/PDA if applicable).
		else if (href_list["rename"])
			var/new_name = input(usr,"What would you like to name this mob?","Input a name") as text|null
			if(!new_name)	return
			var/mob/M = locate(href_list["rename"])
			if(!istype(M))	return

			message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].", 1)
			if(istype(M, /mob/living/carbon/human))
				for(var/obj/item/weapon/card/id/ID in M.contents)
					if(ID.registered_name == M.real_name)
						ID.name = "[new_name]'s ID Card ([ID.assignment])"
						ID.registered_name = new_name
						break
				for(var/obj/item/device/pda/PDA in M.contents)
					if(PDA.owner == M.real_name)
						PDA.name = "PDA-[new_name] ([PDA.ownjob])"
						PDA.owner = new_name
						break
			M.real_name = new_name
			M.name = new_name
			M.original_name = new_name
			href_list["datumrefresh"] = href_list["rename"]

		else if (href_list["varnameedit"])
			if(!href_list["datumedit"] || !href_list["varnameedit"])
				usr << "Varedit error: Not all information has been sent Contact a coder."
				return
			var/DAT = locate(href_list["datumedit"])
			if(!DAT)
				usr << "Item not found"
				return
			if(!istype(DAT,/datum) && !istype(DAT,/client))
				usr << "Can't edit an item of this type. Type must be /datum or /client, so anything except simple variables."
				return
			modify_variables(DAT, href_list["varnameedit"], 1)
		else if (href_list["varnamechange"])
			if(!href_list["datumchange"] || !href_list["varnamechange"])
				usr << "Varedit error: Not all information has been sent. Contact a coder."
				return
			var/DAT = locate(href_list["datumchange"])
			if(!DAT)
				usr << "Item not found"
				return
			if(!istype(DAT,/datum) && !istype(DAT,/client))
				usr << "Can't edit an item of this type. Type must be /datum or /client, so anything except simple variables."
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
				usr << "Can't mass edit an item of this type. Type must be /atom, so an object, turf, mob or area. You cannot mass edit clients!"
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
		else if (href_list["give_spell"])
			if(!href_list["give_spell"])
				return
			var/mob/MOB = locate(href_list["give_spell"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.give_spell(MOB)
			href_list["datumrefresh"] = href_list["give_spell"]
		else if (href_list["ninja"])
			if(!href_list["ninja"])
				return
			var/mob/MOB = locate(href_list["ninja"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.cmd_admin_ninjafy(MOB)
			href_list["datumrefresh"] = href_list["ninja"]
		else if (href_list["godmode"])
			if(!href_list["godmode"])
				return
			var/mob/MOB = locate(href_list["godmode"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.cmd_admin_godmode(MOB)
			href_list["datumrefresh"] = href_list["godmode"]
		else if (href_list["gib"])
			if(!href_list["gib"])
				return
			var/mob/MOB = locate(href_list["gib"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.cmd_admin_gib(MOB)

		else if (href_list["build_mode"])
			if(!href_list["build_mode"])
				return
			var/mob/MOB = locate(href_list["build_mode"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			togglebuildmode(MOB)
			href_list["datumrefresh"] = href_list["build_mode"]

		else if (href_list["drop_everything"])
			if(!href_list["drop_everything"])
				return
			var/mob/MOB = locate(href_list["drop_everything"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return

			if(usr.client)
				usr.client.cmd_admin_drop_everything(MOB)

		else if (href_list["direct_control"])
			if(!href_list["direct_control"])
				return
			var/mob/MOB = locate(href_list["direct_control"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return

			if(usr.client)
				usr.client.cmd_assume_direct_control(MOB)

		else if (href_list["delall"])
			if(!href_list["delall"])
				return
			var/atom/A = locate(href_list["delall"])
			if(!A)
				return
			if(!isobj(A))
				usr << "This can only be used on objects (of type /obj)"
				return
			if(!A.type)
				return
			var/action_type = alert("Strict type ([A.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(alert("Are you really sure you want to delete all objects of type [A.type]?",,"Yes","No") != "Yes")
				return
			if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
				return
			var/a_type = A.type
			if(action_type == "Strict type")
				var/i = 0
				for(var/obj/O in world)
					if(O.type == a_type)
						i++
						del(O)
				if(!i)
					usr << "No objects of this type exist"
					return
				log_admin("[key_name(usr)] deleted all objects of scrict type [a_type] ([i] objects deleted) ")
				message_admins("\blue [key_name(usr)] deleted all objects of scrict type [a_type] ([i] objects deleted) ", 1)
			else if(action_type == "Type and subtypes")
				var/i = 0
				for(var/obj/O in world)
					if(istype(O,a_type))
						i++
						del(O)
				if(!i)
					usr << "No objects of this type exist"
					return
				log_admin("[key_name(usr)] deleted all objects of scrict type with subtypes [a_type] ([i] objects deleted) ")
				message_admins("\blue [key_name(usr)] deleted all objects of type with subtypes [a_type] ([i] objects deleted) ", 1)

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
		else if (href_list["rotatedatum"])
			if(!href_list["rotatedir"])
				return
			var/atom/A = locate(href_list["rotatedatum"])
			if(!A)
				return
			if(!istype(A,/atom))
				usr << "This can only be done to objects of type /atom"
				return
			if(!src.holder)
				return
			switch(href_list["rotatedir"])
				if("right")
					A.dir = turn(A.dir, -45)
				if("left")
					A.dir = turn(A.dir, 45)
			href_list["datumrefresh"] = href_list["rotatedatum"]
		else if (href_list["makemonkey"])
			var/mob/M = locate(href_list["makemonkey"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))
		else if (href_list["makerobot"])
			var/mob/M = locate(href_list["makerobot"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makerobot"=href_list["makerobot"]))
		else if (href_list["makealien"])
			var/mob/M = locate(href_list["makealien"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makealien"=href_list["makealien"]))
		else if (href_list["makemetroid"])
			var/mob/M = locate(href_list["makemetroid"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makemetroid"=href_list["makemetroid"]))
		else if (href_list["makeai"])
			var/mob/M = locate(href_list["makeai"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makeai"=href_list["makeai"]))
		else if (href_list["makeaisilent"])
			var/mob/M = locate(href_list["makeaisilent"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makeaisilent"=href_list["makeaisilent"]))
		else if (href_list["adjustDamage"] && href_list["mobToDamage"])
			var/mob/M = locate(href_list["mobToDamage"])
			var/Text = locate(href_list["adjustDamage"])

			var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num
			if(Text == "brute")
				M.adjustBruteLoss(amount)
			else if(Text == "fire")
				M.adjustFireLoss(amount)
			else if(Text == "toxin")
				M.adjustToxLoss(amount)
			else if(Text == "oxygen")
				M.adjustOxyLoss(amount)
			else if(Text == "brain")
				M.adjustBrainLoss(amount)
			else if(Text == "clone")
				M.adjustCloneLoss(amount)
			else
				usr << "You caused an error. DEBUG: Text:[Text] Mob:[M]"
				return

			if(amount != 0)
				log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [M] ")
				message_admins("\blue [key_name(usr)] dealt [amount] amount of [Text] damage to [M] ", 1)
				href_list["datumrefresh"] = href_list["mobToDamage"]
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