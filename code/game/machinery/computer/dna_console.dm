#define INJECTOR_TIMEOUT 100
#define REJUVENATORS_INJECT 15
#define REJUVENATORS_MAX 90
#define NUMBER_OF_BUFFERS 3

#define RADIATION_STRENGTH_MAX 15
#define RADIATION_STRENGTH_MULTIPLIER 1			//larger has a more range

#define RADIATION_DURATION_MAX 30
#define RADIATION_ACCURACY_MULTIPLIER 3			//larger is less accurate

#define RADIATION_IRRADIATION_MULTIPLIER 1		//multiplier for how much radiation a test subject receives

#define SCANNER_ACTION_SE 1
#define SCANNER_ACTION_UI 2
#define SCANNER_ACTION_UE 3
#define SCANNER_ACTION_MIXED 4

/obj/machinery/computer/scan_consolenew
	name = "\improper DNA scanner access console"
	desc = "Scan DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	density = TRUE
	circuit = /obj/item/circuitboard/computer/scan_consolenew
	var/radduration = 2
	var/radstrength = 1

	var/list/buffer[NUMBER_OF_BUFFERS]

	var/injectorready = 0	//world timer cooldown var
	var/current_screen = "mainmenu"
	var/obj/machinery/dna_scannernew/connected = null
	var/obj/item/disk/data/diskette = null
	var/list/delayed_action = null
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 400

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			if (!user.transferItemToLoc(I,src))
				return
			src.diskette = I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
			src.updateUsrDialog()
			return
	else
		return ..()

/obj/machinery/computer/scan_consolenew/Initialize()
	. = ..()
	for(var/direction in GLOB.cardinals)
		connected = locate(/obj/machinery/dna_scannernew, get_step(src, direction))
		if(!isnull(connected))
			break
	injectorready = world.time + INJECTOR_TIMEOUT

/obj/machinery/computer/scan_consolenew/ui_interact(mob/user, last_change)
	. = ..()
	if(!user)
		return
	var/datum/browser/popup = new(user, "scannernew", "DNA Modifier Console", 800, 630) // Set up the popup browser window
	if(!(in_range(src, user) || issilicon(user)))
		popup.close()
		return
	popup.add_stylesheet("scannernew", 'html/browser/scannernew.css')

	var/mob/living/carbon/viable_occupant
	var/list/occupant_status = list("<div class='line'><div class='statusLabel'>Subject Status:</div><div class='statusValue'>")
	var/scanner_status
	var/list/temp_html = list()
	if(connected && connected.is_operational())
		if(connected.occupant)	//set occupant_status message
			viable_occupant = connected.occupant
			if(viable_occupant.has_dna() && !viable_occupant.has_trait(TRAIT_RADIMMUNE) && !viable_occupant.has_trait(TRAIT_NOCLONE) || (connected.scan_level == 3)) //occupant is viable for dna modification
				occupant_status += "[viable_occupant.name] => "
				switch(viable_occupant.stat)
					if(CONSCIOUS)
						occupant_status += "<span class='good'>Conscious</span>"
					if(UNCONSCIOUS)
						occupant_status += "<span class='average'>Unconscious</span>"
					else
						occupant_status += "<span class='bad'>DEAD</span>"
				occupant_status += "</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [viable_occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[viable_occupant.health] %</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Radiation Level:</div><div class='progressBar'><div style='width: [viable_occupant.radiation/(RAD_MOB_SAFE/100)]%;' class='progressFill bad'></div></div><div class='statusValue'>[viable_occupant.radiation/(RAD_MOB_SAFE/100)] %</div></div>"
				var/rejuvenators = viable_occupant.reagents.get_reagent_amount("potass_iodide")
				occupant_status += "<div class='line'><div class='statusLabel'>Rejuvenators:</div><div class='progressBar'><div style='width: [round((rejuvenators / REJUVENATORS_MAX) * 100)]%;' class='progressFill highlight'></div></div><div class='statusValue'>[rejuvenators] units</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Unique Enzymes :</div><div class='statusValue'><span class='highlight'>[viable_occupant.dna.unique_enzymes]</span></div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Last Operation:</div><div class='statusValue'>[last_change ? last_change : "----"]</div></div>"
			else
				viable_occupant = null
				occupant_status += "<span class='bad'>Invalid DNA structure</span></div></div>"
		else
			occupant_status += "<span class='bad'>No subject detected</span></div></div>"

		if(connected.state_open)
			scanner_status = "Open"
		else
			scanner_status = "Closed"
			if(connected.locked)
				scanner_status += "<span class='bad'>(Locked)</span>"
			else
				scanner_status += "<span class='good'>(Unlocked)</span>"


	else
		occupant_status += "<span class='bad'>----</span></div></div>"
		scanner_status += "<span class='bad'>Error: No scanner detected</span>"

	var/list/status = list("<div class='statusDisplay'>")
	status += "<div class='line'><div class='statusLabel'>Scanner:</div><div class='statusValue'>[scanner_status]</div></div>"
	status += occupant_status


	status += "<div class='line'><h3>Radiation Emitter Status</h3></div>"
	var/stddev = radstrength*RADIATION_STRENGTH_MULTIPLIER
	status += "<div class='line'><div class='statusLabel'>Output Level:</div><div class='statusValue'>[radstrength]</div></div>"
	status += "<div class='line'><div class='statusLabel'>&nbsp;&nbsp;\> Mutation:</div><div class='statusValue'>(-[stddev] to +[stddev] = 68 %) (-[2*stddev] to +[2*stddev] = 95 %)</div></div>"
	if(connected)
		stddev = RADIATION_ACCURACY_MULTIPLIER/(radduration + (connected.precision_coeff ** 2))
	else
		stddev = RADIATION_ACCURACY_MULTIPLIER/radduration
	var/chance_to_hit
	switch(stddev)	//hardcoded values from a z-table for a normal distribution
		if(0 to 0.25)
			chance_to_hit = ">95 %"
		if(0.25 to 0.5)
			chance_to_hit = "68-95 %"
		if(0.5 to 0.75)
			chance_to_hit = "55-68 %"
		else
			chance_to_hit = "<38 %"
	status += "<div class='line'><div class='statusLabel'>Pulse Duration:</div><div class='statusValue'>[radduration]</div></div>"
	status += "<div class='line'><div class='statusLabel'>&nbsp;&nbsp;\> Accuracy:</div><div class='statusValue'>[chance_to_hit]</div></div>"
	status += "<br></div>" // Close statusDisplay div
	var/list/buttons = list("<a href='?src=[REF(src)];'>Scan</a>")
	if(connected)
		buttons += "<a href='?src=[REF(src)];task=toggleopen;'>[connected.state_open ? "Close" : "Open"] Scanner</a>"
		if (connected.state_open)
			buttons += "<span class='linkOff'>[connected.locked ? "Unlock" : "Lock"] Scanner</span>"
		else
			buttons += "<a href='?src=[REF(src)];task=togglelock;'>[connected.locked ? "Unlock" : "Lock"] Scanner</a>"
	else
		buttons += "<span class='linkOff'>Open Scanner</span> <span class='linkOff'>Lock Scanner</span>"
	if(viable_occupant)
		buttons += "<a href='?src=[REF(src)];task=rejuv'>Inject Rejuvenators</a>"
	else
		buttons += "<span class='linkOff'>Inject Rejuvenators</span>"
	if(diskette)
		buttons += "<a href='?src=[REF(src)];task=ejectdisk'>Eject Disk</a>"
	else
		buttons += "<span class='linkOff'>Eject Disk</span>"
	if(current_screen == "buffer")
		buttons += "<a href='?src=[REF(src)];task=screen;text=mainmenu;'>Radiation Emitter Menu</a>"
	else
		buttons += "<a href='?src=[REF(src)];task=screen;text=buffer;'>Buffer Menu</a>"

	switch(current_screen)
		if("working")
			temp_html += status
			temp_html += "<h1>System Busy</h1>"
			temp_html += "Working ... Please wait ([DisplayTimeText(radduration*10)])"
		if("buffer")
			temp_html += status
			temp_html += buttons
			temp_html += "<h1>Buffer Menu</h1>"

			if(istype(buffer))
				for(var/i=1, i<=buffer.len, i++)
					temp_html += "<br>Slot [i]: "
					var/list/buffer_slot = buffer[i]
					if( !buffer_slot || !buffer_slot.len || !buffer_slot["name"] || !((buffer_slot["UI"] && buffer_slot["UE"]) || buffer_slot["SE"]) )
						temp_html += "<br>\tNo Data"
						if(viable_occupant)
							temp_html += "<br><a href='?src=[REF(src)];task=setbuffer;num=[i];'>Save to Buffer</a>"
						else
							temp_html += "<br><span class='linkOff'>Save to Buffer</span>"
						temp_html += "<span class='linkOff'>Clear Buffer</span>"
						if(diskette)
							temp_html += "<a href='?src=[REF(src)];task=loaddisk;num=[i];'>Load from Disk</a>"
						else
							temp_html += "<span class='linkOff'>Load from Disk</span>"
						temp_html += "<span class='linkOff'>Save to Disk</span>"
					else
						var/ui = buffer_slot["UI"]
						var/se = buffer_slot["SE"]
						var/ue = buffer_slot["UE"]
						var/name = buffer_slot["name"]
						var/label = buffer_slot["label"]
						var/blood_type = buffer_slot["blood_type"]
						temp_html += "<br>\t<a href='?src=[REF(src)];task=setbufferlabel;num=[i];'>Label</a>: [label ? label : name]"
						temp_html += "<br>\tSubject: [name]"
						if(ue && name && blood_type)
							temp_html += "<br>\tBlood Type: [blood_type]"
							temp_html += "<br>\tUE: [ue] "
							if(viable_occupant)
								temp_html += "<a href='?src=[REF(src)];task=transferbuffer;num=[i];text=ue'>Occupant</a>"
							else
								temp_html += "<span class='linkOff'>Occupant</span>"
							temp_html += "<a href='?src=[REF(src)];task=setdelayed;num=[i];delayaction=[SCANNER_ACTION_UE]'>Occupant:Delayed</a>"
							if(injectorready < world.time)
								temp_html += "<a href='?src=[REF(src)];task=injector;num=[i];text=ue'>Injector</a>"
							else
								temp_html += "<span class='linkOff'>Injector</span>"
						else
							temp_html += "<br>\tBlood Type: No Data"
							temp_html += "<br>\tUE: No Data"
						if(ui)
							temp_html += "<br>\tUI: [ui] "
							if(viable_occupant)
								temp_html += "<a href='?src=[REF(src)];task=transferbuffer;num=[i];text=ui'>Occupant</a>"
							else
								temp_html += "<span class='linkOff'>Occupant</span>"
							temp_html += "<a href='?src=[REF(src)];task=setdelayed;num=[i];delayaction=[SCANNER_ACTION_UI]'>Occupant:Delayed</a>"
							if(injectorready < world.time)
								temp_html += "<a href='?src=[REF(src)];task=injector;num=[i];text=ui'>Injector</a>"
							else
								temp_html += "<span class='linkOff'>Injector</span>"
						else
							temp_html += "<br>\tUI: No Data"
						if(ue && name && blood_type && ui)
							temp_html += "<br>\tUI+UE: [ui]/[ue] "
							if(viable_occupant)
								temp_html += "<a href='?src=[REF(src)];task=transferbuffer;num=[i];text=mixed'>Occupant</a>"
							else
								temp_html += "<span class='linkOff'>Occupant</span>"
							temp_html += "<a href='?src=[REF(src)];task=setdelayed;num=[i];delayaction=[SCANNER_ACTION_MIXED]'>Occupant:Delayed</a>"
							if(injectorready < world.time)
								temp_html += "<a href='?src=[REF(src)];task=injector;num=[i];text=mixed'>UI+UE Injector</a>"
							else
								temp_html += "<span class='linkOff'>UI+UE Injector</span>"
						if(se)
							temp_html += "<br>\tSE: [se] "
							if(viable_occupant)
								temp_html += "<a href='?src=[REF(src)];task=transferbuffer;num=[i];text=se'>Occupant</a>"
							else
								temp_html += "<span class='linkOff'>Occupant</span>"
							temp_html += "<a href='?src=[REF(src)];task=setdelayed;num=[i];delayaction=[SCANNER_ACTION_SE]'>Occupant:Delayed</a>"
							if(injectorready < world.time )
								temp_html += "<a href='?src=[REF(src)];task=injector;num=[i];text=se'>Injector</a>"
							else
								temp_html += "<span class='linkOff'>Injector</span>"
						else
							temp_html += "<br>\tSE: No Data"
						if(viable_occupant)
							temp_html += "<br><a href='?src=[REF(src)];task=setbuffer;num=[i];'>Save to Buffer</a>"
						else
							temp_html += "<br><span class='linkOff'>Save to Buffer</span>"
						temp_html += "<a href='?src=[REF(src)];task=clearbuffer;num=[i];'>Clear Buffer</a>"
						if(diskette)
							temp_html += "<a href='?src=[REF(src)];task=loaddisk;num=[i];'>Load from Disk</a>"
						else
							temp_html += "<span class='linkOff'>Load from Disk</span>"
						if(diskette && !diskette.read_only)
							temp_html += "<a href='?src=[REF(src)];task=savedisk;num=[i];'>Save to Disk</a>"
						else
							temp_html += "<span class='linkOff'>Save to Disk</span>"
		else
			temp_html += status
			temp_html += buttons
			temp_html += "<h1>Radiation Emitter Menu</h1>"

			temp_html += "<a href='?src=[REF(src)];task=setstrength;num=[radstrength-1];'>--</a> <a href='?src=[REF(src)];task=setstrength;'>Output Level</a> <a href='?src=[REF(src)];task=setstrength;num=[radstrength+1];'>++</a>"
			temp_html += "<br><a href='?src=[REF(src)];task=setduration;num=[radduration-1];'>--</a> <a href='?src=[REF(src)];task=setduration;'>Pulse Duration</a> <a href='?src=[REF(src)];task=setduration;num=[radduration+1];'>++</a>"

			temp_html += "<h3>Irradiate Subject</h3>"
			temp_html += "<div class='line'><div class='statusLabel'>Unique Identifier:</div><div class='statusValue'><div class='clearBoth'>"

			var/max_line_len = 7*DNA_BLOCK_SIZE
			if(viable_occupant)
				temp_html += "<div class='dnaBlockNumber'>1</div>"
				var/len = length(viable_occupant.dna.uni_identity)
				for(var/i=1, i<=len, i++)
					temp_html += "<a class='dnaBlock' href='?src=[REF(src)];task=pulseui;num=[i];'>[copytext(viable_occupant.dna.uni_identity,i,i+1)]</a>"
					if ((i % max_line_len) == 0)
						temp_html += "</div><div class='clearBoth'>"
					if((i % DNA_BLOCK_SIZE) == 0 && i < len)
						temp_html += "<div class='dnaBlockNumber'>[(i / DNA_BLOCK_SIZE) + 1]</div>"
			else
				temp_html += "----"
			temp_html += "</div></div></div><br>"

			temp_html += "<br><div class='line'><div class='statusLabel'>Structural Enzymes:</div><div class='statusValue'><div class='clearBoth'>"
			if(viable_occupant)
				temp_html += "<div class='dnaBlockNumber'>1</div>"
				var/len = length(viable_occupant.dna.struc_enzymes)
				for(var/i=1, i<=len, i++)
					temp_html += "<a class='dnaBlock' href='?src=[REF(src)];task=pulsese;num=[i];'>[copytext(viable_occupant.dna.struc_enzymes,i,i+1)]</a>"
					if ((i % max_line_len) == 0)
						temp_html += "</div><div class='clearBoth'>"
					if((i % DNA_BLOCK_SIZE) == 0 && i < len)
						temp_html += "<div class='dnaBlockNumber'>[(i / DNA_BLOCK_SIZE) + 1]</div>"
			else
				temp_html += "----"
			temp_html += "</div></div></div>"

	popup.set_content(temp_html.Join())
	popup.open()


/obj/machinery/computer/scan_consolenew/Topic(href, href_list)
	if(..())
		return
	if(!isturf(usr.loc))
		return
	if(!((isturf(loc) && in_range(src, usr)) || issilicon(usr)))
		return
	if(current_screen == "working")
		return

	add_fingerprint(usr)
	usr.set_machine(src)

	var/mob/living/carbon/viable_occupant = get_viable_occupant()

	//Basic Tasks///////////////////////////////////////////
	var/num = round(text2num(href_list["num"]))
	var/last_change
	switch(href_list["task"])
		if("togglelock")
			if(connected)
				connected.locked = !connected.locked
		if("toggleopen")
			if(connected)
				connected.toggle_open(usr)
		if("setduration")
			if(!num)
				num = round(input(usr, "Choose pulse duration:", "Input an Integer", null) as num|null)
			if(num)
				radduration = WRAP(num, 1, RADIATION_DURATION_MAX+1)
		if("setstrength")
			if(!num)
				num = round(input(usr, "Choose pulse strength:", "Input an Integer", null) as num|null)
			if(num)
				radstrength = WRAP(num, 1, RADIATION_STRENGTH_MAX+1)
		if("screen")
			current_screen = href_list["text"]
		if("rejuv")
			if(viable_occupant && viable_occupant.reagents)
				var/potassiodide_amount = viable_occupant.reagents.get_reagent_amount("potass_iodide")
				var/can_add = max(min(REJUVENATORS_MAX - potassiodide_amount, REJUVENATORS_INJECT), 0)
				viable_occupant.reagents.add_reagent("potass_iodide", can_add)
		if("setbufferlabel")
			var/text = sanitize(input(usr, "Input a new label:", "Input an Text", null) as text|null)
			if(num && text)
				num = CLAMP(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))
					buffer_slot["label"] = text
		if("setbuffer")
			if(num && viable_occupant)
				num = CLAMP(num, 1, NUMBER_OF_BUFFERS)
				buffer[num] = list(
					"label"="Buffer[num]:[viable_occupant.real_name]",
					"UI"=viable_occupant.dna.uni_identity,
					"SE"=viable_occupant.dna.struc_enzymes,
					"UE"=viable_occupant.dna.unique_enzymes,
					"name"=viable_occupant.real_name,
					"blood_type"=viable_occupant.dna.blood_type
					)
		if("clearbuffer")
			if(num)
				num = CLAMP(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))
					buffer_slot.Cut()
		if("transferbuffer")
			if(num && viable_occupant)
				switch(href_list["text"])                                                                            //Numbers are this high because other way upgrading laser is just not worth the hassle, and i cant think of anything better to inmrove
					if("se")
						apply_buffer(SCANNER_ACTION_SE,num)
					if("ui")
						apply_buffer(SCANNER_ACTION_UI,num)
					if("ue")
						apply_buffer(SCANNER_ACTION_UE,num)
					if("mixed")
						apply_buffer(SCANNER_ACTION_MIXED,num)
		if("injector")
			if(num && injectorready < world.time)
				num = CLAMP(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))
					var/obj/item/dnainjector/timed/I
					switch(href_list["text"])
						if("se")
							if(buffer_slot["SE"])
								I = new /obj/item/dnainjector/timed(loc)
								var/powers = 0
								for(var/datum/mutation/human/HM in GLOB.good_mutations + GLOB.bad_mutations + GLOB.not_good_mutations)
									if(HM.check_block_string(buffer_slot["SE"]))
										I.add_mutations.Add(HM)
										if(HM in GLOB.good_mutations)
											powers += 1
										if(HM in GLOB.bad_mutations + GLOB.not_good_mutations)
											powers -= 1 //To prevent just unlocking everything to get all powers to a syringe for max tech
									else
										I.remove_mutations.Add(HM)
								var/time_coeff
								for(var/datum/mutation/human/HM in I.add_mutations)
									if(!time_coeff)
										time_coeff = HM.time_coeff
										continue
									time_coeff = min(time_coeff,HM.time_coeff)
								if(connected)
									I.duration = I.duration * time_coeff * connected.damage_coeff
									I.damage_coeff  = connected.damage_coeff
						if("ui")
							if(buffer_slot["UI"])
								I = new /obj/item/dnainjector/timed(loc)
								I.fields = list("UI"=buffer_slot["UI"])
								if(connected)
									I.damage_coeff = connected.damage_coeff
						if("ue")
							if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
								I = new /obj/item/dnainjector/timed(loc)
								I.fields = list("name"=buffer_slot["name"], "UE"=buffer_slot["UE"], "blood_type"=buffer_slot["blood_type"])
								if(connected)
									I.damage_coeff  = connected.damage_coeff
						if("mixed")
							if(buffer_slot["UI"] && buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
								I = new /obj/item/dnainjector/timed(loc)
								I.fields = list("UI"=buffer_slot["UI"],"name"=buffer_slot["name"], "UE"=buffer_slot["UE"], "blood_type"=buffer_slot["blood_type"])
								if(connected)
									I.damage_coeff = connected.damage_coeff
					if(I)
						injectorready = world.time + INJECTOR_TIMEOUT
		if("loaddisk")
			if(num && diskette && diskette.fields)
				num = CLAMP(num, 1, NUMBER_OF_BUFFERS)
				buffer[num] = diskette.fields.Copy()
		if("savedisk")
			if(num && diskette && !diskette.read_only)
				num = CLAMP(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))
					diskette.name = "data disk \[[buffer_slot["label"]]\]"
					diskette.fields = buffer_slot.Copy()
		if("ejectdisk")
			if(diskette)
				diskette.forceMove(drop_location())
				diskette = null
		if("setdelayed")
			if(num)
				delayed_action = list("action"=text2num(href_list["delayaction"]),"buffer"=num)
		if("pulseui","pulsese")
			if(num && viable_occupant && connected)
				radduration = WRAP(radduration, 1, RADIATION_DURATION_MAX+1)
				radstrength = WRAP(radstrength, 1, RADIATION_STRENGTH_MAX+1)

				var/locked_state = connected.locked
				connected.locked = TRUE

				current_screen = "working"
				ui_interact(usr)

				sleep(radduration*10)
				current_screen = "mainmenu"

				if(viable_occupant && connected && connected.occupant==viable_occupant)
					viable_occupant.radiation += (RADIATION_IRRADIATION_MULTIPLIER*radduration*radstrength)/(connected.damage_coeff ** 2) //Read comment in "transferbuffer" section above for explanation
					switch(href_list["task"])                                                                                             //Same thing as there but values are even lower, on best part they are about 0.0*, effectively no damage
						if("pulseui")
							var/len = length(viable_occupant.dna.uni_identity)
							num = WRAP(num, 1, len+1)
							num = randomize_radiation_accuracy(num, radduration + (connected.precision_coeff ** 2), len) //Each manipulator level above 1 makes randomization as accurate as selected time + manipulator lvl^2
                                                                                                                         //Value is this high for the same reason as with laser - not worth the hassle of upgrading if the bonus is low
							var/block = round((num-1)/DNA_BLOCK_SIZE)+1
							var/subblock = num - block*DNA_BLOCK_SIZE
							last_change = "UI #[block]-[subblock]; "

							var/hex = copytext(viable_occupant.dna.uni_identity, num, num+1)
							last_change += "[hex]"
							hex = scramble(hex, radstrength, radduration)
							last_change += "->[hex]"

							viable_occupant.dna.uni_identity = copytext(viable_occupant.dna.uni_identity, 1, num) + hex + copytext(viable_occupant.dna.uni_identity, num+1, 0)
							viable_occupant.updateappearance(mutations_overlay_update=1)
						if("pulsese")
							var/len = length(viable_occupant.dna.struc_enzymes)
							num = WRAP(num, 1, len+1)
							num = randomize_radiation_accuracy(num, radduration + (connected.precision_coeff ** 2), len)

							var/block = round((num-1)/DNA_BLOCK_SIZE)+1
							var/subblock = num - block*DNA_BLOCK_SIZE
							last_change = "SE #[block]-[subblock]; "

							var/hex = copytext(viable_occupant.dna.struc_enzymes, num, num+1)
							last_change += "[hex]"
							hex = scramble(hex, radstrength, radduration)
							last_change += "->[hex]"

							viable_occupant.dna.struc_enzymes = copytext(viable_occupant.dna.struc_enzymes, 1, num) + hex + copytext(viable_occupant.dna.struc_enzymes, num+1, 0)
							viable_occupant.domutcheck()
				else
					current_screen = "mainmenu"

				if(connected)
					connected.locked = locked_state

	ui_interact(usr,last_change)

/obj/machinery/computer/scan_consolenew/proc/scramble(input,rs,rd)
	var/length = length(input)
	var/ran = gaussian(0, rs*RADIATION_STRENGTH_MULTIPLIER)
	if(ran == 0)
		ran = pick(-1,1)	//hacky, statistically should almost never happen. 0-change makes people mad though
	else if(ran < 0)
		ran = round(ran)	//negative, so floor it
	else
		ran = -round(-ran)	//positive, so ceiling it
	return num2hex(WRAP(hex2num(input)+ran, 0, 16**length), length)

/obj/machinery/computer/scan_consolenew/proc/randomize_radiation_accuracy(position, radduration, number_of_blocks)
	var/val = round(gaussian(0, RADIATION_ACCURACY_MULTIPLIER/radduration) + position, 1)
	return WRAP(val, 1, number_of_blocks+1)

/obj/machinery/computer/scan_consolenew/proc/get_viable_occupant()
	var/mob/living/carbon/viable_occupant = null
	if(connected)
		viable_occupant = connected.occupant
		if(!istype(viable_occupant) || !viable_occupant.dna || viable_occupant.has_trait(TRAIT_RADIMMUNE) || viable_occupant.has_trait(TRAIT_NOCLONE))
			viable_occupant = null
	return viable_occupant

/obj/machinery/computer/scan_consolenew/proc/apply_buffer(action,buffer_num)
	buffer_num = CLAMP(buffer_num, 1, NUMBER_OF_BUFFERS)
	var/list/buffer_slot = buffer[buffer_num]
	var/mob/living/carbon/viable_occupant = get_viable_occupant()
	if(istype(buffer_slot))
		viable_occupant.radiation += rand(100/(connected.damage_coeff ** 2),250/(connected.damage_coeff ** 2))
		//15 and 40 are just magic numbers that were here before so i didnt touch them, they are initial boundaries of damage
		//Each laser level reduces damage by lvl^2, so no effect on 1 lvl, 4 times less damage on 2 and 9 times less damage on 3
		//Numbers are this high because other way upgrading laser is just not worth the hassle, and i cant think of anything better to inmrove
		switch(action)
			if(SCANNER_ACTION_SE)
				if(buffer_slot["SE"])
					viable_occupant.dna.struc_enzymes = buffer_slot["SE"]
					viable_occupant.domutcheck()
			if(SCANNER_ACTION_UI)
				if(buffer_slot["UI"])
					viable_occupant.dna.uni_identity = buffer_slot["UI"]
					viable_occupant.updateappearance(mutations_overlay_update=1)
			if(SCANNER_ACTION_UE)
				if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
					viable_occupant.real_name = buffer_slot["name"]
					viable_occupant.name = buffer_slot["name"]
					viable_occupant.dna.unique_enzymes = buffer_slot["UE"]
					viable_occupant.dna.blood_type = buffer_slot["blood_type"]
			if(SCANNER_ACTION_MIXED)
				if(buffer_slot["UI"])
					viable_occupant.dna.uni_identity = buffer_slot["UI"]
					viable_occupant.updateappearance(mutations_overlay_update=1)
				if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
					viable_occupant.real_name = buffer_slot["name"]
					viable_occupant.name = buffer_slot["name"]
					viable_occupant.dna.unique_enzymes = buffer_slot["UE"]
					viable_occupant.dna.blood_type = buffer_slot["blood_type"]

/obj/machinery/computer/scan_consolenew/proc/on_scanner_close()
	if(delayed_action && get_viable_occupant())
		to_chat(connected.occupant, "<span class='notice'>[src] activates!</span>")
		apply_buffer(delayed_action["action"],delayed_action["buffer"])
		delayed_action = null //or make it stick + reset button ?

/////////////////////////// DNA MACHINES
#undef INJECTOR_TIMEOUT
#undef REJUVENATORS_INJECT
#undef REJUVENATORS_MAX
#undef NUMBER_OF_BUFFERS

#undef RADIATION_STRENGTH_MAX
#undef RADIATION_STRENGTH_MULTIPLIER

#undef RADIATION_DURATION_MAX
#undef RADIATION_ACCURACY_MULTIPLIER

#undef RADIATION_IRRADIATION_MULTIPLIER

#undef SCANNER_ACTION_SE
#undef SCANNER_ACTION_UI
#undef SCANNER_ACTION_UE
#undef SCANNER_ACTION_MIXED

//#undef BAD_MUTATION_DIFFICULTY
//#undef GOOD_MUTATION_DIFFICULTY
//#undef OP_MUTATION_DIFFICULTY
