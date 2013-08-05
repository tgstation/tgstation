// READ: Don't use the apostrophe in name or desc. Causes script errors.

var/list/powerinstances

/datum/power			//Could be used by other antags too
	var/name = "Power"
	var/desc = "Placeholder"
	var/helptext = ""
	var/isVerb = 1 	// Is it an active power, or passive?
	var/verbpath // Path to a verb that contains the effects.

/datum/power/changeling
	var/allowduringlesserform = 0
	var/genomecost = 500000 // Cost for the changling to evolve this power.

/datum/power/changeling/absorb_dna
	name = "Absorb DNA"
	desc = "Permits us to siphon the DNA from a human. They become one with us, and the new energy lets us change our abilities."
	genomecost = 0
	verbpath = /mob/living/carbon/proc/changeling_absorb_dna

/datum/power/changeling/extractdna
	name = "Extract DNA Strand"
	desc = "We stealthily sting a target and extract the DNA from them."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	genomecost = 0
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_extract_dna_sting

/datum/power/changeling/transform
	name = "Transform"
	desc = "We take on the appearance and voice of one we have absorbed."
	genomecost = 0
	verbpath = /mob/living/carbon/proc/changeling_transform

/datum/power/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We become weakened to a death-like state, where we will rise again from death."
	helptext = "Can be used before or after death. Duration varies greatly. Can be used in lesser form."
	genomecost = 0
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_fakedeath

// Hivemind
/datum/power/changeling/hive_upload
	name = "Hive Channel"
	desc = "We can channel a DNA into the airwaves, allowing our fellow changelings to absorb it and transform into it as if they acquired the DNA themselves."
	helptext = "Allows other changelings to absorb the DNA you channel from the airwaves. Will not help them towards their absorb objectives."
	genomecost = 0
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_hiveupload

/datum/power/changeling/hive_download
	name = "Hive Absorb"
	desc = "We can absorb a single DNA from the airwaves, allowing us to use more disguises with help from our fellow changelings."
	helptext = "Allows you to absorb a single DNA and use it. Does not count towards your absorb objective."
	genomecost = 0
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_hivedownload

/datum/power/changeling/lesser_form
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser. We become a monkey."
	genomecost = 1
	verbpath = /mob/living/carbon/proc/changeling_lesser_form

/datum/power/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice."
	helptext = "Will turn your voice into the name that you enter. We must constantly expend chemicals to maintain our form like this"
	genomecost = 1
	verbpath = /mob/living/carbon/proc/changeling_mimicvoice

/datum/power/changeling/transformation_sting
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform into another."
	helptext = "Does not provide a warning to others. The victim will transform much like a changeling would."
	genomecost = 1
	verbpath = /mob/living/carbon/proc/changeling_transformation_sting

/datum/power/changeling/Epinephrine
	name = "Epinephrine Sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Removes all stuns instantly, and adds a short-term reduction in further stuns. Can be used while unconscious."
	genomecost = 1
	verbpath = /mob/living/carbon/proc/changeling_unstun

/datum/power/changeling/EngorgedGlands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store an extra 25 units of chemicals, and doubles production rate."
	genomecost = 1
	isVerb = 0
	verbpath = /mob/proc/changeling_advglands

/datum/power/changeling/DigitalCamouflage
	name = "Digital Camouflage"
	desc = "We evolve the ability to distort our form and proprotions, defeating common altgorthms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill.  However, humans looking at us will find us... uncanny."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_digitalcamo

/datum/power/changeling/fleshmend
	name = "Fleshmend"
	desc = "We evolve the ability to rapidly regenerate, restoring the health of the body we use."
	helptext = "Heals a moderate amount of damage every tick. Can be used while unconscious."
	genomecost = 1
	verbpath = /mob/living/carbon/proc/changeling_fleshmend

/datum/power/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, genetic disabilities, and removing toxins and radiation."
	helptext = "Can be used while unconscious."
	genomecost = 1
	verbpath = /mob/living/carbon/proc/changeling_panacea

/datum/power/changeling/shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal chords shift, allowing us to briefly emit a noise that deafens and confuses the weak-minded."
	helptext = "The high-frequency sounds cannot be heard by humans, but will blow out lights nearby. Cyborgs will have their sensors overloaded and become stunned."
	genomecost = 1
	verbpath = /mob/living/carbon/proc/changeling_shriek

/datum/power/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating arachnids which will grow into deadly beasts."
	helptext = "The spiders are thoughtless creatures, and may attack their creators when fully grown. Requires at least 5 DNA absorptions."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_spiders

/datum/power/changeling/lsd_sting
	name = "Hallucination Sting"
	desc = "We evolve the ability to sting a target with a powerful hallucinogenic chemical."
	helptext = "The target does not notice they have been stung.  The effect occurs after 30 to 60 seconds."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_lsd_sting

/datum/power/changeling/blind_sting
	name = "Blind Sting"
	desc = "We silently sting a human, completely blinding them for a short time."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_blind_sting

/datum/power/changeling/cryo_sting
	name = "Cryogenic Sting"
	desc = "We silently sting a human with a cocktail of chemicals, slowing their metabolism."
	helptext = "Does not provide a warning to a victim, though they will likely realize they are suddenly freezing."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_cryo_sting

/datum/power/changeling/mute_sting
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to a victim that they have been stung, until they try to speak and cannot."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /mob/living/carbon/proc/changeling_mute_sting


// Modularchangling, totally stolen from the new player panel.  YAYY
/datum/changeling/proc/EvolutionMenu()//The new one
	set name = "-Evolution Menu-"//Dashes are so it's listed before all the other abilities.
	set category = "Changeling"
	set desc = "Choose our method of subjugation."

	if(!usr || !usr.mind || !usr.mind.changeling)	return
	src = usr.mind.changeling

	if(!powerinstances)
		powerinstances = init_subtypes(/datum/power/changeling)

	var/dat = "<html><head><title>Changling Evolution Menu</title></head>"

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
					Current ability choices remaining: [geneticpoints]<br>
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
	for(var/datum/power/changeling/P in powerinstances)
		var/ownsthis = 0

		if(P.genomecost == 0) //Let's skip the crap we start with. Keeps the evolution menu uncluttered.
			continue

		if(P in purchasedpowers)
			ownsthis = 1


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
					<b id='search[i]'>Evolve [P][ownsthis ? " - Purchased" : ((P.genomecost > 1) ? " - Cost: [P.genomecost]" : "")]</b>
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

	usr << browse(dat, "window=powers;size=600x700")//900x480


/datum/changeling/Topic(href, href_list)
	..()
	if(!ismob(usr))
		return

	if(href_list["P"])
		var/datum/mind/M = usr.mind
		if(!istype(M))
			return
		purchasePower(M, href_list["P"])
		call(/datum/changeling/proc/EvolutionMenu)()

	if(href_list["readapt"])
		var/datum/mind/M = usr.mind
		if(!istype(M))
			return
		lingRespec(M)
		call(/datum/changeling/proc/EvolutionMenu)()
		return

/////

/datum/changeling/proc/purchasePower(var/datum/mind/M, var/pname, var/remake_verbs = 1)
	if(!M || !M.changeling || !istype(M.current, /mob/living/carbon))
		return

	var/mob/living/carbon/C = M.current
	var/datum/power/changeling/thepower = pname

	for (var/datum/power/changeling/P in powerinstances)
		if(P.name == pname)
			thepower = P
			break

	if(thepower == null)
		C << "This is awkward. Changeling power purchase failed, please report this bug to a coder!"
		return

	if(thepower in purchasedpowers)
		C << "We have already evolved this ability!"
		return

	if(geneticpoints < thepower.genomecost)
		C << "We have reached our capacity for abilities."
		return

	if(C.status_flags & FAKEDEATH)//To avoid potential exploits by buying new powers while in stasis, which clears your verblist.
		C << "We lack the energy to evolve new abilities right now."
		return

	geneticpoints -= thepower.genomecost

	purchasedpowers += thepower

	if(!thepower.isVerb && thepower.verbpath)
		call(C, thepower.verbpath)()
	else if(remake_verbs)
		C.make_changeling()

/////

/datum/changeling/proc/lingRespec(var/datum/mind/M)
	if(!M || !M.changeling || !istype(M.current, /mob/living/carbon))
		return

	if(canrespec)
		usr << "We have removed our evolutions from this form, and are now ready to readapt."

		var/mob/living/carbon/C = M.current

		C.remove_changeling_powers()//Revokes our verb powers.
		clearlist(purchasedpowers)


		//Resets our stats, to account for purchased passives.
		C.digitalcamo = 0
		geneticpoints = initial(geneticpoints)
		sting_range = initial(sting_range)
		chem_storage = initial(chem_storage)
		chem_recharge_rate = initial(chem_recharge_rate)
		chem_charges = min(chem_charges, chem_storage)
		mimicing = ""

		canrespec = 0

		C.make_changeling()//Remake our verbs; rebuys the 0 cost skills.
	else
		usr << "You lack the power to readapt your evolutions!"

	return 1