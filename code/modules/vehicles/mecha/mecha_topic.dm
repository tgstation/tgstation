
////////////////////////////////////
///// Rendering stats window ///////
////////////////////////////////////

/obj/vehicle/sealed/mecha/proc/get_stats_html(mob/user)
	. = {"<html>
			<head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<title>[name] data</title>
				<style>
					body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
					hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
					a {padding:2px 5px;;color:#0f0;}
					.wr {margin-bottom: 5px;}
					.header {cursor:pointer;}
					.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
					.links a {margin-bottom: 2px;padding-top:3px;}
					.visible {display: block;}
					.hidden {display: none;}
				</style>
				<script language='javascript' type='text/javascript'>
					[js_byjax]
					[js_dropdowns]
					[get_ssticker_function()]

					window.onload = function() {
						dropdowns();
						SSticker();
					}
				</script>
			</head>
			<body>
				<div id='content'>
					[get_stats_part(user)]
				</div></div>
				<div id='eq_list'>
					[get_equipment_list()]
				</div>
				<hr>
				<div id='commands'>
					[get_commands()]
				</div>
				<div id='equipment_menu'>
					[get_equipment_menu()]
				</div>
			</body>
		</html>"}

//Returns the autoupdate javascript script functions for the mecha ui.
/obj/vehicle/sealed/mecha/proc/get_ssticker_function()
	. = {"
		function SSticker() {
			setInterval(function(){
				window.location='byond://?src=[REF(src)]&update_content=1';
			}, 1000);
		}
	"}

///Returns the status of the mech.
/obj/vehicle/sealed/mecha/proc/get_stats_part(mob/user)
	var/integrity = atom_integrity/max_integrity*100
	var/cell_charge = get_charge()
	var/datum/gas_mixture/int_tank_air = 0
	var/tank_pressure = 0
	var/tank_temperature = 0
	var/cabin_pressure = 0
	if (internal_tank)
		int_tank_air = internal_tank.return_air()
		tank_pressure = internal_tank ? round(int_tank_air.return_pressure(),0.01) : "None"
		tank_temperature = internal_tank ? int_tank_air.temperature : "Unknown"
		cabin_pressure = round(return_pressure(),0.01)
	. = {"[report_internal_damage()]
		[integrity<30?"[span_userdanger("DAMAGE LEVEL CRITICAL")]<br>":null]
		<b>Integrity: </b> [integrity]%<br>
		<b>Power cell charge: </b>[isnull(cell_charge)?"No power cell installed":"[cell.percent()]%"]<br>
		<b>Air source: </b>[internal_tank?"[use_internal_tank?"Internal Airtank":"Environment"]":"Environment"]<br>
		<b>Airtank pressure: </b>[internal_tank?"[tank_pressure]kPa":"N/A"]<br>
		<b>Airtank temperature: </b>[internal_tank?"[tank_temperature]&deg;K|[tank_temperature - T0C]&deg;C":"N/A"]<br>
		<b>Cabin pressure: </b>[internal_tank?"[cabin_pressure>WARNING_HIGH_PRESSURE ? span_danger("[cabin_pressure]"): cabin_pressure]kPa":"N/A"]<br>
		<b>Cabin temperature: </b> [internal_tank?"[return_temperature()]&deg;K|[return_temperature() - T0C]&deg;C":"N/A"]<br>
		[dna_lock?"<b>DNA-locked:</b><br> <span style='font-size:10px;letter-spacing:-1px;'>[dna_lock]</span> \[<a href='?src=[REF(src)];reset_dna=1'>Reset</a>\]<br>":""]<br>"}
	. += "[get_actions(user)]<br>"

///Returns HTML for mech actions. Ideally, this proc would be empty for the base mecha. Segmented for easy refactoring.
/obj/vehicle/sealed/mecha/proc/get_actions(mob/user)
	. = ""
	. += "[LAZYACCESSASSOC(occupant_actions, user, /datum/action/vehicle/sealed/mecha/mech_defense_mode) ? "<b>Defense Mode: </b> [defense_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[LAZYACCESSASSOC(occupant_actions, user, /datum/action/vehicle/sealed/mecha/mech_overload_mode) ? "<b>Leg Actuators Overload: </b> [leg_overload_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[LAZYACCESSASSOC(occupant_actions, user, /datum/action/vehicle/sealed/mecha/mech_smoke) ? "<b>Smoke Charges remaining: </b> [smoke_charges]<br>" : ""]"
	. += "[LAZYACCESSASSOC(occupant_actions, user, /datum/action/vehicle/sealed/mecha/mech_zoom) ? "<b>Zoom: </b> [zoom_mode ? "Enabled" : "Disabled"]<br>" : ""]"
	. += "[LAZYACCESSASSOC(occupant_actions, user, /datum/action/vehicle/sealed/mecha/mech_switch_damtype) ? "<b>Damtype: </b> [damtype]<br>" : ""]"
	. += "[LAZYACCESSASSOC(occupant_actions, user, /datum/action/vehicle/sealed/mecha/mech_toggle_phasing) ? "<b>Phase Modulator: </b> [phasing ? "Enabled" : "Disabled"]<br>" : ""]"

///HTML for internal damage.
/obj/vehicle/sealed/mecha/proc/report_internal_damage()
	. = ""
	var/list/dam_reports = list(
		"[MECHA_INT_FIRE]" = span_userdanger("INTERNAL FIRE"),
		"[MECHA_INT_TEMP_CONTROL]" = span_userdanger("LIFE SUPPORT SYSTEM MALFUNCTION"),
		"[MECHA_INT_TANK_BREACH]" = span_userdanger("GAS TANK BREACH"),
		"[MECHA_INT_CONTROL_LOST]" = "[span_userdanger("COORDINATION SYSTEM CALIBRATION FAILURE")] - <a href='?src=[REF(src)];repair_int_control_lost=1'>Recalibrate</a>",
		"[MECHA_INT_SHORT_CIRCUIT]" = span_userdanger("SHORT CIRCUIT")
								)
	for(var/tflag in dam_reports)
		var/intdamflag = text2num(tflag)
		if(internal_damage & intdamflag)
			. += dam_reports[tflag]
			. += "<br />"
	if(return_pressure() > WARNING_HIGH_PRESSURE)
		. += "[span_userdanger("DANGEROUSLY HIGH CABIN PRESSURE")]<br />"

///HTML for list of equipment.
/obj/vehicle/sealed/mecha/proc/get_equipment_list() //outputs mecha equipment list in html
	if(!LAZYLEN(equipment))
		return
	. = "<b>Equipment:</b><div style=\"margin-left: 15px;\">"
	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		. += "<div id='[REF(MT)]'>[MT.get_equip_info()]</div>"
	. += "</div>"

///HTML for commands.
/obj/vehicle/sealed/mecha/proc/get_commands()
	. = {"
	<div class='wr'>
		<div class='header'>Electronics</div>
		<div class='links'>
			<b>Radio settings:</b><br>
			Microphone:
			[radio? "<a href='?src=[REF(src)];rmictoggle=1'>\
			<span id=\"rmicstate\">[radio.get_broadcasting()?"Engaged":"Disengaged"]</span></a>":"Error"]<br>
			Speaker:
			[radio? "<a href='?src=[REF(src)];rspktoggle=1'><span id=\"rspkstate\">\
			[radio.get_listening()?"Engaged":"Disengaged"]</span></a>":"Error"]<br>
			Frequency:
			[radio? "<a href='?src=[REF(src)];rfreq=-10'>-</a>":"-"]
			[radio? "<a href='?src=[REF(src)];rfreq=-2'>-</a>":"-"]
			<span id=\"rfreq\">[radio?"[format_frequency(radio.get_frequency())]":"Error"]</span>
			[radio? "<a href='?src=[REF(src)];rfreq=2'>+</a>":"+"]
			[radio? "<a href='?src=[REF(src)];rfreq=10'>+</a>":"+"]<br>
		</div>
	</div>
	<div class='wr'>
		<div class='header'>Permissions & Logging</div>
		<div class='links'>
			<a href='?src=[REF(src)];toggle_id_upload=1'><span id='t_id_upload'>[(mecha_flags & ADDING_ACCESS_POSSIBLE)?"L":"Unl"]ock ID upload panel</span></a><br>
			<a href='?src=[REF(src)];toggle_maint_access=1'><span id='t_maint_access'>[(mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE)?"Forbid":"Permit"] maintenance protocols</span></a><br>
			[internal_tank?"<a href='?src=[REF(src)];toggle_port_connection=1'><span id='t_port_connection'>[internal_tank.connected_port?"Disconnect from":"Connect to"] gas port</span></a><br>":""]
			<a href='?src=[REF(src)];dna_lock=1'>DNA-lock</a><br>
			<a href='?src=[REF(src)];change_name=1'>Change exosuit name</a>
		</div>
	</div>"}


/obj/vehicle/sealed/mecha/proc/get_equipment_menu() //outputs mecha html equipment menu
	. = {"
	<div class='wr'>
	<div class='header'>Equipment</div>
	<div class='links'>"}
	for(var/e in equipment)
		var/obj/item/mecha_parts/mecha_equipment/equipment = e
		. += "[equipment.name] [equipment.detachable ? "<a href='?src=[REF(equipment)];detach=1'>Detach</a><br>" : "\[Non-removable\]<br>"]"
	. += {"<b>Available equipment slots:</b> [max_equip-LAZYLEN(equipment)]
	</div>
	</div>"}

/obj/vehicle/sealed/mecha/proc/output_access_dialog(obj/item/card/id/id_card, mob/user)
	if(!id_card || !user)
		return
	. = {"<html>
			<head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<style>
					h1 {font-size:15px;margin-bottom:4px;}
					body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
					a {color:#0f0;}
				</style>
			</head>
			<body>
				<h1>Following keycodes are present in this system:</h1>"}
	for(var/a in operation_req_access)
		. += "[SSid_access.get_access_desc(a)] - <a href='?src=[REF(src)];del_req_access=[a];user=[REF(user)];id_card=[REF(id_card)]'>Delete</a><br>"
	. += "<hr><h1>Following keycodes were detected on portable device:</h1>"
	for(var/a in id_card.access)
		if(a in operation_req_access)
			continue
		var/a_name = SSid_access.get_access_desc(a)
		if(!a_name)
			continue //there's some strange access without a name
		. += "[a_name] - <a href='?src=[REF(src)];add_req_access=[a];user=[REF(user)];id_card=[REF(id_card)]'>Add</a><br>"
	. +={"<hr><a href='?src=[REF(src)];finish_req_access=1;user=[REF(user)]'>Lock ID panel</a><br>
		[span_danger("(Warning! The ID upload panel can be unlocked only through Exosuit Interface.)")]
		</body>
		</html>"}
	user << browse(., "window=exosuit_add_access")
	onclose(user, "exosuit_add_access")


/obj/vehicle/sealed/mecha/proc/output_maintenance_dialog(obj/item/card/id/id_card,mob/user)
	if(!id_card || !user)
		return
	. = {"<html>
			<head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<style>
					body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
					a {padding:2px 5px; background:#32CD32;color:#000;display:block;margin:2px;text-align:center;text-decoration:none;}
				</style>
			</head>
			<body>
				[(mecha_flags & ADDING_ACCESS_POSSIBLE)?"<a href='?src=[REF(src)];req_access=1;id_card=[REF(id_card)];user=[REF(user)]'>Edit operation keycodes</a>":null]
				[(mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE)?"<a href='?src=[REF(src)];maint_access=1;id_card=[REF(id_card)];user=[REF(user)]'>[(construction_state > MECHA_LOCKED) ? "Terminate" : "Initiate"] maintenance protocol</a>":null]
				[(construction_state == MECHA_OPEN_HATCH) ?"--------------------</br>":null]
				[(construction_state == MECHA_OPEN_HATCH) ?"[cell?"<a href='?src=[REF(src)];drop_cell=1;id_card=[REF(id_card)];user=[REF(user)]'>Drop power cell</a>":"No cell installed</br>"]":null]
				[(construction_state == MECHA_OPEN_HATCH) ?"[scanmod?"<a href='?src=[REF(src)];drop_scanmod=1;id_card=[REF(id_card)];user=[REF(user)]'>Drop scanning module</a>":"No scanning module installed</br>"]":null]
				[(construction_state == MECHA_OPEN_HATCH) ?"[capacitor?"<a href='?src=[REF(src)];drop_cap=1;id_card=[REF(id_card)];user=[REF(user)]'>Drop capacitor</a>":"No capacitor installed</br>"]":null]
				[(construction_state == MECHA_OPEN_HATCH) ?"--------------------</br>":null]
				[(construction_state > MECHA_LOCKED) ?"<a href='?src=[REF(src)];set_internal_tank_valve=1;user=[REF(user)]'>Set Cabin Air Pressure</a>":null]
			</body>
		</html>"}
	user << browse(., "window=exosuit_maint_console")
	onclose(user, "exosuit_maint_console")




/////////////////
///// Topic /////
/////////////////

/obj/vehicle/sealed/mecha/Topic(href, href_list)
	..()

	if(!usr)
		return

	if(href_list["close"])
		return

	if(usr.incapacitated())
		return

	if(in_range(src, usr))
		//Start of ID requirements.
		if(href_list["id_card"])
			var/obj/item/card/id/id_card
			id_card = locate(href_list["id_card"])
			if(!istype(id_card))
				return

			if(href_list["req_access"])
				if(!(mecha_flags & ADDING_ACCESS_POSSIBLE))
					return
				output_access_dialog(id_card,usr)
				return

			if(href_list["maint_access"])
				if(!(mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE))
					return
				if(construction_state == MECHA_LOCKED)
					construction_state = MECHA_SECURE_BOLTS
					to_chat(usr, span_notice("The securing bolts are now exposed."))
				else if(construction_state == MECHA_SECURE_BOLTS)
					construction_state = MECHA_LOCKED
					to_chat(usr, span_notice("The securing bolts are now hidden."))
				output_maintenance_dialog(id_card,usr)
				return
			if(href_list["drop_cell"])
				if(construction_state == MECHA_OPEN_HATCH)
					cell.forceMove(get_turf(src))
					cell = null
				output_maintenance_dialog(id_card,usr)
				return
			if(href_list["drop_scanmod"])
				if(construction_state == MECHA_OPEN_HATCH)
					scanmod.forceMove(get_turf(src))
					scanmod = null
				output_maintenance_dialog(id_card,usr)
				return
			if(href_list["drop_cap"])
				if(construction_state == MECHA_OPEN_HATCH)
					capacitor.forceMove(get_turf(src))
					capacitor = null
				output_maintenance_dialog(id_card,usr)
				return

			if(href_list["add_req_access"])
				if(!(mecha_flags & ADDING_ACCESS_POSSIBLE))
					return
				operation_req_access += text2num(href_list["add_req_access"])
				output_access_dialog(id_card,usr)
				return

			if(href_list["del_req_access"])
				if(!(mecha_flags & ADDING_ACCESS_POSSIBLE))
					return
				operation_req_access -= text2num(href_list["del_req_access"])
				output_access_dialog(id_card, usr)
				return
			return //Here end everything requiring an ID.

		//Here ID access stuff goes to die.
		if(href_list["finish_req_access"])
			mecha_flags &= ~ADDING_ACCESS_POSSIBLE
			usr << browse(null,"window=exosuit_add_access")
			return

		//Set pressure.
		if(href_list["set_internal_tank_valve"] && construction_state)
			var/new_pressure = input(usr,"Input new output pressure","Pressure setting",internal_tank_valve) as num|null
			if(isnull(new_pressure) || usr.incapacitated() || !construction_state)
				return
			internal_tank_valve = new_pressure
			to_chat(usr, span_notice("The internal pressure valve has been set to [internal_tank_valve]kPa."))
			return

	//Start of all internal topic stuff.
	if(!locate(usr) in occupants)
		return

	if(href_list["update_content"])
		send_byjax(usr,"exosuit.browser","content", get_stats_part())
		return

	//Selects the mech equipment/weapon.
	if(href_list["select_equip"])
		var/obj/item/mecha_parts/mecha_equipment/equip = locate(href_list["select_equip"]) in src
		if(!equip || !equip.selectable)
			return
		selected = equip
		to_chat(occupants, "[icon2html(src, occupants)][span_notice("You switch to [equip].")]")
		visible_message(span_notice("[src] raises [equip]."))
		send_byjax(usr, "exosuit.browser", "eq_list", get_equipment_list())
		playsound(src,'sound/machines/piston_raise.ogg', 40, TRUE)
		return

	//Toggles radio broadcasting
	if(href_list["rmictoggle"])
		radio.set_broadcasting(!radio.get_broadcasting())
		send_byjax(usr,"exosuit.browser","rmicstate",(radio.get_broadcasting()?"Engaged":"Disengaged"))
		return

	//Toggles radio listening
	if(href_list["rspktoggle"])
		radio.set_listening(!radio.get_listening())
		send_byjax(usr,"exosuit.browser","rspkstate",(radio.get_listening()?"Engaged":"Disengaged"))
		return

	//Changes radio freqency.
	if(href_list["rfreq"])
		var/new_frequency = radio.get_frequency() + text2num(href_list["rfreq"])
		radio.set_frequency(sanitize_frequency(new_frequency, radio.freerange))
		send_byjax(usr,"exosuit.browser","rfreq","[format_frequency(radio.get_frequency())]")
		return

	//Changes the exosuit name.
	if(href_list["change_name"])
		var/userinput = tgui_input_text(usr, "Choose a new exosuit name", "Rename exosuit", max_length = MAX_NAME_LEN)
		if(!userinput || !locate(usr) in occupants || usr.incapacitated())
			return
		name = userinput
		return

	//Toggles ID upload.
	if (href_list["toggle_id_upload"])
		mecha_flags ^= ADDING_ACCESS_POSSIBLE
		send_byjax(usr,"exosuit.browser","t_id_upload","[(mecha_flags & ADDING_ACCESS_POSSIBLE)?"L":"Unl"]ock ID upload panel")
		return

	//Toggles main access.
	if(href_list["toggle_maint_access"])
		if(construction_state)
			to_chat(occupants, "[icon2html(src, occupants)][span_danger("Maintenance protocols in effect")]")
			return
		mecha_flags ^= ADDING_MAINT_ACCESS_POSSIBLE
		send_byjax(usr,"exosuit.browser","t_maint_access","[(mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE)?"Forbid":"Permit"] maintenance protocols")
		return

	//Toggles connection port.
	if (href_list["toggle_port_connection"])
		if(internal_tank.connected_port)
			if(internal_tank.disconnect())
				to_chat(occupants, "[icon2html(src, occupants)][span_notice("Disconnected from the air system port.")]")
				log_message("Disconnected from gas port.", LOG_MECHA)
			else
				to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to disconnect from the air system port!")]")
				return
		else
			var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate() in loc
			if(internal_tank.connect(possible_port))
				to_chat(occupants, "[icon2html(src, occupants)][span_notice("Connected to the air system port.")]")
				log_message("Connected to gas port.", LOG_MECHA)
			else
				to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to connect with air system port!")]")
				return
		send_byjax(occupants,"exosuit.browser","t_port_connection","[internal_tank.connected_port?"Disconnect from":"Connect to"] gas port")
		return

	//Turns on the DNA lock
	if(href_list["dna_lock"])
		var/mob/living/carbon/user = usr
		if(!istype(user) || !user.dna)
			to_chat(user, "[icon2html(src, occupants)][span_notice("You can't create a DNA lock with no DNA!.")]")
			return
		dna_lock = user.dna.unique_enzymes
		to_chat(user, "[icon2html(src, occupants)][span_notice("You feel a prick as the needle takes your DNA sample.")]")
		return

	//Resets the DNA lock
	if(href_list["reset_dna"])
		dna_lock = null
		return

	//Repairs internal damage
	if(href_list["repair_int_control_lost"])
		to_chat(occupants, "[icon2html(src, occupants)][span_notice("Recalibrating coordination system...")]")
		log_message("Recalibration of coordination system started.", LOG_MECHA)
		addtimer(CALLBACK(src, .proc/stationary_repair, loc), 100, TIMER_UNIQUE)

///Repairs internal damage if the mech hasn't moved.
/obj/vehicle/sealed/mecha/proc/stationary_repair(location)
	if(location == loc)
		clear_internal_damage(MECHA_INT_CONTROL_LOST)
		to_chat(occupants, "[icon2html(src, occupants)][span_notice("Recalibration successful.")]")
		log_message("Recalibration of coordination system finished with 0 errors.", LOG_MECHA)
	else
		to_chat(occupants, "[icon2html(src, occupants)][span_warning("Recalibration failed!")]")
		log_message("Recalibration of coordination system failed with 1 error.", LOG_MECHA, color="red")
