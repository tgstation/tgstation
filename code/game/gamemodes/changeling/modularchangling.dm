
var/list/powers = typesof(/obj/effect/proc_holder/power) //needed for the badmin verb for now
var/list/obj/effect/proc_holder/power/powerinstances = list()

/obj/effect/proc_holder/power
	name = "Power"
	desc = "Placeholder"
	density = 0
	opacity = 0

	var/helptext = ""

	var/allowduringlesserform = 0
	var/isVerb = 1 // Is it an active power, or passive?
	var/verbpath = null // Path to a verb that contains the effects.
	var/genomecost = 500000 // Cost for the changling to evolve this power.

/obj/effect/proc_holder/power/absorb_dna
	name = "Absorb DNA"
	desc = "Permits us to syphon the DNA from a human.  They become one with us, and we become stronger."
	genomecost = 0

	verbpath = /client/proc/changeling_absorb_dna



/obj/effect/proc_holder/power/transform
	name = "Transform"
	desc = "We take on the apperance and voice of one we have absorbed."
	genomecost = 0

	verbpath = /client/proc/changeling_transform



/obj/effect/proc_holder/power/lesser_form
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser.  We become a monkey."
	genomecost = 1

	verbpath = /client/proc/changeling_lesser_form



/obj/effect/proc_holder/power/changeling_greater_form
	name = "Greater Form"
	desc = "We become the pinnicle of evolution.  We will show the humans what happens when they leave their isle of ignorance."
	genomecost = 250

//	verbpath = /client/proc/changeling_greater_form

/obj/effect/proc_holder/power/fakedeath
	name = "Fake Death"
	desc = "We fake our death while we heal."
	genomecost = 0
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_fakedeath



/obj/effect/proc_holder/power/deaf_sting
	name = "Deaf Sting"
	desc = "We silently sting a human, completely deafening them for a short time."
	genomecost = 1
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_deaf_sting



/obj/effect/proc_holder/power/blind_sting
	name = "Blind Sting"
	desc = "We silently sting a human, completely blinding them for a short time."
	genomecost = 2
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_blind_sting



/obj/effect/proc_holder/power/paralysis_sting
	name = "Paralysis Sting"
	desc = "We silently sting a human, paralyzing them for a short time.  We must be wary, they can still whisper."
	genomecost = 5


	verbpath = /client/proc/changeling_paralysis_sting



/obj/effect/proc_holder/power/silence_sting
	name = "Silence Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to a victim that they&apos;ve been stung, until they try to speak and can&apos;t."  // Man, fuck javascript.  &apos; == '
	genomecost = 2
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_silence_sting



/obj/effect/proc_holder/power/transformation_sting
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform into another."
	genomecost = 2

	verbpath = /client/proc/changeling_transformation_sting



/obj/effect/proc_holder/power/unfat_sting
	name = "Unfat Sting"
	desc = "We silently sting a human, forcing them to rapidly metobolize their fat."
	genomecost = 1


	verbpath = /client/proc/changeling_unfat_sting

/obj/effect/proc_holder/power/boost_range
	name = "Boost Range"
	desc = "We evolve the ability to shoot our stingers at humans, with some preperation."
	genomecost = 2
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_boost_range



/obj/effect/proc_holder/power/Epinephrine
	name = "Epinephrine sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Gives the ability to instantly recover from stuns.  High chemical cost."
	genomecost = 4

	verbpath = /client/proc/changeling_unstun


/obj/effect/proc_holder/power/ChemicalSynth
	name = "Rapid Chemical Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 4
	isVerb = 0

	verbpath = /client/proc/changeling_fastchemical



/obj/effect/proc_holder/power/EngorgedGlands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store an extra 25 units of chemicals."
	genomecost = 4
	isVerb = 0


	verbpath = /client/proc/changeling_engorgedglands



/obj/effect/proc_holder/power/DigitalCamoflague
	name = "Digital Camoflauge"
	desc = "We evolve the ability to distort our form and proprtions, defeating common altgorthms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill.  However, humans looking at us will find us.. uncanny.  We must constantly expend chemicals to maintain our form like this."
	genomecost = 4
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_digitalcamo



/obj/effect/proc_holder/power/DeathSting
	name = "Death Sting"
	desc = "We silently sting a human, filling him with potent chemicals. His rapid death is all but assured."
	genomecost = 10

	verbpath = /client/proc/changeling_DEATHsting



/obj/effect/proc_holder/power/rapidregeneration
	name = "Rapid Regeneration"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	helptext = "Heals a moderate amount of damage every tick."
	genomecost = 8

	verbpath = /client/proc/changeling_rapidregen

/obj/effect/proc_holder/power/LSDSting
	name = "Hallucination Sting"
	desc = "We evolve the ability to sting a target with a powerful hallunicationary chemical."
	helptext = "The target does not notice they&apos;ve been stung.  The effect occurs after 30 to 60 seconds."
	genomecost = 3

	verbpath = /client/proc/changeling_lsdsting






// Modularchangling, totally stolen from the new player panel.  YAYY
/datum/changeling/proc/EvolutionMenu()//The new one
	set category = "Changeling"
	set desc = "Level up!"
	if (!usr.changeling)
		return

	src = usr.changeling

	if(!powerinstances.len)
		for(var/P in powers)
			var/obj/effect/proc_holder/power/nP = new P
			if (nP.desc == "Placeholder")
				del(nP)
				continue
			powerinstances += nP

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
					<font size='5'><b>Changling Evolution Menu</b></font><br>
					Hover over a power to see more information<br>
					Current genomes left to evolve with: [usr.changeling.geneticpoints]
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
	for(var/obj/effect/proc_holder/power/P in powerinstances)
		var/ownsthis = 0

		if(P in usr.changeling.purchasedpowers)
			ownsthis = 1


		var/color = "#e6e6e6"
		if(i%2 == 0)
			color = "#f2f2f2"


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P]",[ownsthis])'
					>
					<b id='search[i]'>Evolve [P] - Cost: [ownsthis ? "Purchased" : P.genomecost]</b>
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

	usr << browse(dat, "window=powers;size=900x480")


/datum/changeling/Topic(href, href_list)
	..()

	if(href_list["P"])
		usr.changeling.purchasePower(href_list["P"])
		call(/datum/changeling/proc/EvolutionMenu)()



/datum/changeling/proc/purchasePower(var/obj/effect/proc_holder/power/Pname)
	if (!usr.changeling)
		return

	var/obj/effect/proc_holder/power/Thepower = null

	for (var/obj/effect/proc_holder/power/P in powerinstances)
		if(P.name == Pname)
			Thepower = P
			break

	if(Thepower == null)
		usr << "This is awkward.  Changeling power purchase failed, please report this bug to a coder!"
		return

	if(Thepower in usr.changeling.purchasedpowers)
		usr << "We have already evolved this ability!"
		return


	if(usr.changeling.geneticpoints < Thepower.genomecost)
		usr << "We cannot evolve this... yet.  We must acquire more DNA."
		return

	usr.changeling.geneticpoints -= Thepower.genomecost

	usr.changeling.purchasedpowers += Thepower

	if(!Thepower.isVerb)
		call(Thepower.verbpath)()

	else
		if(usr.changeling.changeling_level == 1)
			usr.make_lesser_changeling()
		else
			usr.make_changeling()

