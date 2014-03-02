var/list/sting_paths
// totally stolen from the new player panel.  YAYY

/obj/effect/proc_holder/changeling/evolution_menu
	name = "-Evolution Menu-" //Dashes are so it's listed before all the other abilities.
	desc = "Choose our method of subjugation."
	dna_cost = 0

/obj/effect/proc_holder/changeling/evolution_menu/Click()
	if(!usr || !usr.mind || !usr.mind.changeling)
		return
	var/datum/changeling/changeling = usr.mind.changeling

	if(!sting_paths)
		sting_paths = init_paths(/obj/effect/proc_holder/changeling)

	var/dat = create_menu(changeling)
	usr << browse(dat, "window=powers;size=600x700")//900x480


/obj/effect/proc_holder/changeling/evolution_menu/proc/create_menu(var/datum/changeling/changeling)
	var/dat
	dat +="<html><head><title>Changling Evolution Menu</title></head>"

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

				function expand(id,name,desc,helptext,power,ownsthis){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+desc+"</b></font> <BR>"

					body += "<font size='2'><font color = 'red'><b>"+helptext+"</b></font> <BR>"

					if(!ownsthis)
					{
						body += "<a href='?src=\ref[src];P="+power+"'>Evolve</a>"
					}
					body += "</td><td align='center'>";

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
					<font size='5'><b>Changeling Evolution Menu</b></font><br>
					Hover over a power to see more information<br>
					Current ability choices remaining: [changeling.geneticpoints]<br>
					By rendering a lifeform to a husk, we gain enough power to alter and adapt our evolutions.<br>
					(<a href='?src=\ref[src];readapt=1'>Readapt</a>)<br>
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

	var/i = 1
	for(var/path in sting_paths)

		var/obj/effect/proc_holder/changeling/P = new path()
		if(P.dna_cost <= 0) //Let's skip the crap we start with. Keeps the evolution menu uncluttered.
			continue

		var/ownsthis = changeling.has_sting(P)

		var/color
		if(ownsthis)
			if(i%2 == 0)
				color = "#d8ebd8"
			else
				color = "#c3dec3"
		else
			if(i%2 == 0)
				color = "#f2f2f2"
			else
				color = "#e6e6e6"


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P]",[ownsthis])'
					>
					<b id='search[i]'>Evolve [P][ownsthis ? " - Purchased" : ((P.dna_cost > 1) ? " - Cost: [P.dna_cost]" : "")]</b>
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
	return dat


/obj/effect/proc_holder/changeling/evolution_menu/Topic(href, href_list)
	..()
	if(!(iscarbon(usr) && usr.mind && usr.mind.changeling))
		return

	if(href_list["P"])
		usr.mind.changeling.purchasePower(usr, href_list["P"])
	else if(href_list["readapt"])
		usr.mind.changeling.lingRespec(usr)
	var/dat = create_menu(usr.mind.changeling)
	usr << browse(dat, "window=powers;size=600x700")
/////

/datum/changeling/proc/purchasePower(var/mob/living/carbon/user, var/sting_name)

	var/obj/effect/proc_holder/changeling/thepower = null

	if(!sting_paths)
		sting_paths = init_paths(/obj/effect/proc_holder/changeling)
	for(var/path in sting_paths)
		var/obj/effect/proc_holder/changeling/S = new path()
		if(S.name == sting_name)
			thepower = S

	if(thepower == null)
		user << "This is awkward. Changeling power purchase failed, please report this bug to a coder!"
		return

	if(has_sting(thepower))
		user << "We have already evolved this ability!"
		return

	if(geneticpoints < thepower.dna_cost)
		user << "We have reached our capacity for abilities."
		return

	if(user.status_flags & FAKEDEATH)//To avoid potential exploits by buying new powers while in stasis, which clears your verblist.
		user << "We lack the energy to evolve new abilities right now."
		return

	geneticpoints -= thepower.dna_cost
	purchasedpowers += thepower
	thepower.on_purchase(user)

//Reselect powers
/datum/changeling/proc/lingRespec(var/mob/user)
	if(canrespec)
		user << "We have removed our evolutions from this form, and are now ready to readapt."
		user.remove_changeling_powers(1)
		canrespec = 0
		user.make_changeling()
		return 1
	else
		user << "You lack the power to readapt your evolutions!"
		return 0

/mob/proc/make_changeling()
	if(!mind)
		return
	if(!ishuman(src) && !ismonkey(src))
		return
	if(!mind.changeling)
		mind.changeling = new /datum/changeling(gender)
	if(!sting_paths)
		sting_paths = init_paths(/obj/effect/proc_holder/changeling)
	if(mind.changeling.purchasedpowers)
		remove_changeling_powers(1)
	// purchase free powers.
	for(var/path in sting_paths)
		var/obj/effect/proc_holder/changeling/S = new path()
		if(!S.dna_cost)
			if(!mind.changeling.has_sting(S))
				mind.changeling.purchasedpowers+=S
				S.on_purchase(src)

	var/mob/living/carbon/C = src		//only carbons have dna now, so we have to typecaste
	mind.changeling.absorbed_dna |= C.dna
	return 1

/datum/changeling/proc/reset()
	chosen_sting = null
	geneticpoints = initial(geneticpoints)
	sting_range = initial(sting_range)
	chem_storage = initial(chem_storage)
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_charges = min(chem_charges, chem_storage)
	mimicing = ""

/mob/proc/remove_changeling_powers(var/keep_free_powers=0)
	if(ishuman(src) || ismonkey(src))
		if(mind && mind.changeling)
			digitalcamo = 0
			mind.changeling.reset()
			for(var/obj/effect/proc_holder/changeling/p in mind.changeling.purchasedpowers)
				if(!(p.dna_cost == 0 && keep_free_powers))
					mind.changeling.purchasedpowers -= p
		if(hud_used)
			hud_used.lingstingdisplay.icon_state = null
			hud_used.lingstingdisplay.invisibility = 101

/datum/changeling/proc/has_sting(obj/effect/proc_holder/changeling/power)
	for(var/obj/effect/proc_holder/changeling/P in purchasedpowers)
		if(power.name == P.name)
			return 1
	return 0
