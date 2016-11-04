/datum/admins/proc/player_panel_new()//The new one
	if(!check_rights())
		return
	var/dat = "<html><head><title>Player Panel</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,job,name,real_name,image,key,ip,antagonist,ref){

					clearAll();

					var span = document.getElementById(id);
					var ckey = key.toLowerCase().replace(/\[^a-z@0-9\]+/g,"");

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" ("+ip+")</b></font>"

					body += "</td><td align='center'>";

					body += "<a href='?_src_=holder;adminplayeropts="+ref+"'>PP</a> - "
					body += "<a href='?_src_=holder;shownoteckey="+ckey+"'>N</a> - "
					body += "<a href='?_src_=vars;Vars="+ref+"'>VV</a> - "
					body += "<a href='?_src_=holder;traitor="+ref+"'>TP</a> - "
					body += "<a href='?priv_msg="+ckey+"'>PM</a> - "
					body += "<a href='?_src_=holder;subtlemessage="+ref+"'>SM</a> - "
					body += "<a href='?_src_=holder;adminplayerobservefollow="+ref+"'>FLW</a><br>"
					if(antagonist > 0)
						body += "<font size='2'><a href='?_src_=holder;secrets=check_antagonist'><font color='red'><b>Antagonist</b></font></a></font>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Player panel</b></font><br>
					Hover over a line to see more information - <a href='?_src_=holder;check_antagonist=1'>Check antagonists</a> - Kick <a href='?_src_=holder;kick_all_from_lobby=1;afkonly=0'>everyone</a>/<a href='?_src_=holder;kick_all_from_lobby=1;afkonly=1'>AFKers</a> in lobby
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sortmobs()
	var/i = 1
	for(var/mob/M in mobs)
		if(M.ckey)

			var/color = "#e6e6e6"
			if(i%2 == 0)
				color = "#f2f2f2"
			var/is_antagonist = is_special_character(M)

			var/M_job = ""

			if(isliving(M))

				if(iscarbon(M)) //Carbon stuff
					if(ishuman(M))
						M_job = M.job
					else if(ismonkey(M))
						M_job = "Monkey"
					else if(isalien(M)) //aliens
						if(islarva(M))
							M_job = "Alien larva"
						else
							M_job = "Alien"
					else
						M_job = "Carbon-based"

				else if(issilicon(M)) //silicon
					if(isAI(M))
						M_job = "AI"
					else if(ispAI(M))
						M_job = "pAI"
					else if(iscyborg(M))
						M_job = "Cyborg"
					else
						M_job = "Silicon-based"

				else if(isanimal(M)) //simple animals
					if(iscorgi(M))
						M_job = "Corgi"
					else if(isslime(M))
						M_job = "slime"
					else
						M_job = "Animal"

				else
					M_job = "Living"

			else if(isnewplayer(M))
				M_job = "New player"

			else if(isobserver(M))
				var/mob/dead/observer/O = M
				if(O.started_as_observer)//Did they get BTFO or are they just not trying?
					M_job = "Observer"
				else
					M_job = "Ghost"

			var/M_name = html_encode(M.name)
			var/M_rname = html_encode(M.real_name)
			var/M_key = html_encode(M.key)

			//output for each mob
			dat += {"

				<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
					<td align='center' bgcolor='[color]'>
						<span id='notice_span[i]'></span>
						<a id='link[i]'
						onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","--unused--","[M_key]","[M.lastKnownIP]",[is_antagonist],"\ref[M]")'
						>
						<b id='search[i]'>[M_name] - [M_rname] - [M_key] ([M_job])</b>
						</a>
						<br><span id='item[i]'></span>
					</td>
				</tr>

			"}

			i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(dat, "window=players;size=600x480")

/datum/admins/proc/check_antagonists()
	if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
		var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
		if(ticker.mode.replacementmode)
			dat += "Former Game Mode: <B>[ticker.mode.name]</B><BR>"
			dat += "Replacement Game Mode: <B>[ticker.mode.replacementmode.name]</B><BR>"
		else
			dat += "Current Game Mode: <B>[ticker.mode.name]</B><BR>"
		dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero("[world.time / 600 % 60]", 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"
		dat += "<B>Emergency shuttle</B><BR>"
		if(EMERGENCY_IDLE_OR_RECALLED)
			dat += "<a href='?_src_=holder;call_shuttle=1'>Call Shuttle</a><br>"
		else
			var/timeleft = SSshuttle.emergency.timeLeft()
			if(SSshuttle.emergency.mode == SHUTTLE_CALL)
				dat += "ETA: <a href='?_src_=holder;edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
				dat += "<a href='?_src_=holder;call_shuttle=2'>Send Back</a><br>"
			else
				dat += "ETA: <a href='?_src_=holder;edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
		dat += "<B>Continuous Round Status</B><BR>"
		dat += "<a href='?_src_=holder;toggle_continuous=1'>[config.continuous[ticker.mode.config_tag] ? "Continue if antagonists die" : "End on antagonist death"]</a>"
		if(config.continuous[ticker.mode.config_tag])
			dat += ", <a href='?_src_=holder;toggle_midround_antag=1'>[config.midround_antag[ticker.mode.config_tag] ? "creating replacement antagonists" : "not creating new antagonists"]</a><BR>"
		else
			dat += "<BR>"
		if(config.midround_antag[ticker.mode.config_tag])
			dat += "Time limit: <a href='?_src_=holder;alter_midround_time_limit=1'>[config.midround_antag_time_check] minutes into round</a><BR>"
			dat += "Living crew limit: <a href='?_src_=holder;alter_midround_life_limit=1'>[config.midround_antag_life_check * 100]% of crew alive</a><BR>"
			dat += "If limits past: <a href='?_src_=holder;toggle_noncontinuous_behavior=1'>[ticker.mode.round_ends_with_antag_death ? "End The Round" : "Continue As Extended"]</a><BR>"

		dat += "<BR>"
		dat += "<a href='?_src_=holder;end_round=\ref[usr]'>End Round Now</a><br>"
		dat += "<a href='?_src_=holder;delay_round_end=1'>[ticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		if(ticker.mode.syndicates.len)
			dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.syndicates)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
				else
					dat += "<tr><td><i><a href='?_src_=vars;Vars=\ref[N]'>[N.name]([N.key])</a> Nuclear Operative Body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
			dat += "</table><br><table><tr><td><B>Nuclear Disk(s)</B></td></tr>"
			for(var/obj/item/weapon/disk/nuclear/N in poi_list)
				dat += "<tr><td>[N.name], "
				var/atom/disk_loc = N.loc
				while(!isturf(disk_loc))
					if(ismob(disk_loc))
						var/mob/M = disk_loc
						dat += "carried by <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a> "
					if(isobj(disk_loc))
						var/obj/O = disk_loc
						dat += "in \a [O.name] "
					disk_loc = disk_loc.loc
				dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td></tr>"
			dat += "</table>"

		if(ticker.mode.head_revolutionaries.len || ticker.mode.revolutionaries.len)
			dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.head_revolutionaries)
				var/mob/M = N.current
				if(!M)
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[N]'>[N.name]([N.key])</a><i>Head Revolutionary body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
			for(var/datum/mind/N in ticker.mode.revolutionaries)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
			dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
			for(var/datum/mind/N in ticker.mode.get_living_heads())
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td>"
					var/turf/mob_loc = get_turf(M)
					dat += "<td>[mob_loc.loc]</td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[N]'>[N.name]([N.key])</a><i>Head body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
			dat += "</table>"

		for(var/datum/gang/G in ticker.mode.gangs)
			dat += "<br><table cellspacing=5><tr><td><B>[G.name] Gang: <a href='?_src_=holder;gangpoints=\ref[G]'>[G.points] Influence</a> | [round((G.territory.len/start_state.num_territories)*100, 1)]% Control</B></td><td></td></tr>"
			for(var/datum/mind/N in G.bosses)
				var/mob/M = N.current
				if(!M)
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[N]'>[N.name]([N.key])</a><i>Gang Boss body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Boss)</b>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
			for(var/datum/mind/N in G.gangsters)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td></tr>"
			dat += "</table>"

		if(ticker.mode.changelings.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Changelings</B></td><td></td><td></td></tr>"
			for(var/datum/mind/changeling in ticker.mode.changelings)
				var/mob/M = changeling.current
				if(M)
					dat += "<tr><td>[M.mind.changeling.changelingID] as <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[changeling]'>[changeling.name]([changeling.key])</a><i>Changeling body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[changeling.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(ticker.mode.wizards.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Wizards</B></td><td></td><td></td></tr>"
			for(var/datum/mind/wizard in ticker.mode.wizards)
				var/mob/M = wizard.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[wizard]'>[wizard.name]([wizard.key])</a><i>Wizard body destroyed!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[wizard.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(ticker.mode.apprentices.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Apprentice</B></td><td></td><td></td></tr>"
			for(var/datum/mind/apprentice in ticker.mode.apprentices)
				var/mob/M = apprentice.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[apprentice]'>[apprentice.name]([apprentice.key])</a><i>Apprentice body destroyed!!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[apprentice.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(ticker.mode.cult.len)
			dat += "<br><table cellspacing=5><tr><td><B>Cultists</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.cult)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
			dat += "</table>"

		if(ticker.mode.servants_of_ratvar.len)
			dat += "<br><table cellspacing=5><tr><td><B>Servants of Ratvar</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.servants_of_ratvar)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(ghost)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
			dat += "</table>"

		if(ticker.mode.traitors.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Traitors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/traitor in ticker.mode.traitors)
				var/mob/M = traitor.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[traitor]'>[traitor.name]([traitor.key])</a><i>Traitor body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[traitor.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(ticker.mode.abductors.len)
			dat += "<br><table cellspacing=5><tr><td><B>Abductors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/abductor in ticker.mode.abductors)
				var/mob/M = abductor.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[abductor]'>[abductor.name]([abductor.key])</a><i>Abductor body destroyed!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[abductor.key]'>PM</A></td>"
			dat += "</table>"
			dat += "<br><table cellspacing=5><tr><td><B>Abductees</B></td><td></td><td></td></tr>"
			for(var/obj/machinery/abductor/experiment/E in machines)
				for(var/datum/mind/abductee in E.abductee_minds)
					var/mob/M = abductee.current
					if(M)
						dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
						dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
						dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td>"
						dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
					else
						dat += "<tr><td><a href='?_src_=vars;Vars=\ref[abductee]'>[abductee.name]([abductee.key])</a><i>Abductee body destroyed!</i></td>"
						dat += "<td><A href='?priv_msg=[abductee.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(ticker.mode.devils.len)
			dat += "<br><table cellspacing=5><tr><td><B>devils</B></td><td></td><td></td></tr>"
			for(var/X in ticker.mode.devils)
				var/datum/mind/devil = X
				var/mob/M = devil.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name] : [devil.devilinfo.truename]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
					dat += "<td><A HREF='?_src_=holder;admincheckdevilinfo=\ref[M]'>Show all devil info</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[devil]'>[devil.name] :  [devil.devilinfo.truename] ([devil.key])</a><i>devil body destroyed!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[devil.key]'>PM</A></td>"
			dat += "</table>"

		if(ticker.mode.sintouched.len)
			dat += "<br><table cellspacing=5><tr><td><B>sintouched</B></td><td></td><td></td></tr>"
			for(var/X in ticker.mode.sintouched)
				var/datum/mind/sintouched = X
				var/mob/M = sintouched.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[sintouched]'>[sintouched.name]([sintouched.key])</a><i>sintouched body destroyed!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[sintouched.key]'>PM</A></td>"
			dat += "</table>"

		var/list/blob_minds = list()
		for(var/mob/camera/blob/B in mob_list)
			blob_minds |= B.mind

		if(istype(ticker.mode, /datum/game_mode/blob) || blob_minds.len)
			dat += "<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>"
			if(istype(ticker.mode,/datum/game_mode/blob))
				var/datum/game_mode/blob/mode = ticker.mode
				blob_minds |= mode.blob_overminds
				dat += "<tr><td><i>Progress: [blobs_legit.len]/[mode.blobwincount]</i></td></tr>"

			for(var/datum/mind/blob in blob_minds)
				var/mob/M = blob.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[blob]'>[blob.name]([blob.key])</a><i>Blob not found!</i></td>"
					dat += "<td><A href='?priv_msg=[blob.key]'>PM</A></td></tr>"
			dat += "</table>"


		if(istype(ticker.mode, /datum/game_mode/monkey))
			var/datum/game_mode/monkey/mode = ticker.mode
			dat += "<br><table cellspacing=5><tr><td><B>Monkey</B></td><td></td><td></td></tr>"

			for(var/datum/mind/eek in mode.ape_infectees)
				var/mob/M = eek.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;Vars=\ref[eek]'>[eek.name]([eek.key])</a><i>Monkey not found!</i></td>"
					dat += "<td><A href='?priv_msg=[eek.key]'>PM</A></td></tr>"
			dat += "</table>"


		dat += "</body></html>"
		usr << browse(dat, "window=roundstatus;size=420x500")
	else
		alert("The game hasn't started yet!")
