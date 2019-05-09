//Use this file to for things related to round start or new spawn initializations.

//for debugging purposes -falaskian
/*var/global/debug_time_check_start = 0
var/global/debug_time_check = 0
var/global/debug_check_count = 1
/proc/falaskian_debug(reset = 0)
	if(reset)
		debug_check_count = 1
		debug_time_check_start = 0
		debug_time_check = 0
	if(debug_time_check_start == 0)
		debug_time_check_start = world.timeofday
	debug_time_check = world.timeofday
	to_chat(world,"DEBUG: [debug_check_count], [(debug_time_check-debug_time_check_start)/10] seconds.")
	debug_check_count++*/

proc/Initialize_Falaskians_Shit()
	initialize_discord_channel_list()
	save_perseus_manager_whitelist()
	SaveStation()
	load_chaos_assistant_chance()
	GLOB.reinforced_glass_recipes += new/datum/stack_recipe("reinforced delivery window", /obj/structure/window/reinforced/fulltile/delivery/unanchored, 5, time = 0, on_floor = TRUE, window_checks = TRUE)
	GLOB.cable_coil_recipes += new/datum/stack_recipe("noose", /obj/structure/chair/noose, 10, time = 0, on_floor = TRUE)
	new_player_cam = new()

/datum/config_entry/string/discordurl

/client/verb/discord()
	set name = "discord"
	set desc = "Join the discord."
	set hidden = 1
	var/discordurl = CONFIG_GET(string/discordurl)
	if (discordurl)
		if(alert("This will open the discord invitation in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(discordurl)
	else
		src << sound('sound/items/bikehorn.ogg')
		to_chat(src, "<span class='danger'>The discord URL is not set in the server configuration.</span>")

/datum/config_entry/flag/show_round_time_on_hub
GLOBAL_LIST_EMPTY(hub_features)
/world/proc/update_status()
	var/theservername = CONFIG_GET(string/servername)
	if (!theservername)
		theservername = "Space Station 13"
	var/dat = "<b>[theservername]</B> "
	var/theforumurl = CONFIG_GET(string/forumurl)
	var/thediscordlink = CONFIG_GET(string/discordurl)
	if(theforumurl || thediscordlink)
		dat += "("
		if(theforumurl)
			dat += "<a href=\"[theforumurl]\">Forums</a>"
		if(theforumurl && thediscordlink)
			dat += "|"
		if(thediscordlink)
			dat += "<a href=\"[thediscordlink]\">Discord</a>"
		dat += ")<br>"
	if(SSmapping && SSmapping.config.map_name)
		dat += "Map: [SSmapping.config.map_name]"
	if(SSticker)
		if(SSticker.current_state < GAME_STATE_PLAYING)
			dat += "<br>New Round Starting."
		else if (SSticker.current_state > GAME_STATE_PLAYING)
			dat += "<br>New round soon."
		else if(CONFIG_GET(flag/show_round_time_on_hub))
			var/worldtime = max(world.time-SSticker.round_start_time,0)
			var/hours = 0
			var/minutes = 0
			var/timeout = 24
			while(worldtime >= 36000 && timeout > 0)
				timeout--
				hours++
				worldtime -= 36000
			timeout = 59
			while(worldtime >= 600 && timeout > 0)
				timeout--
				minutes++
				worldtime -= 600
			if(minutes >= 300)
				minutes++
			if(length("[minutes]") < 2)
				minutes = "0[minutes]"
			dat += "<br>Round Time: [hours]:[minutes]"
	else
		dat += "<br>Restarting."
	if(GLOB)
		if(!GLOB.hub_features.len)
			GLOB.hub_features = file2list("config/hub_features.txt")
		if(GLOB.hub_features.len)
			dat += "<br>"
			var/linecount = 1
			for(var/line in GLOB.hub_features)
				dat += "[line]"
				if(linecount < GLOB.hub_features.len)
					dat += "<br>"
				linecount++
	world.status = dat

//modifying a player after hes equipped when spawning in as crew member.
/datum/outfit
	var/ignore_special_events = 0
/datum/outfit/proc/update_toolbox_inventory(mob/living/carbon/human/H)
	var/themonth = text2num(time2text(world.timeofday,"MM"))
	var/theday = text2num(time2text(world.timeofday,"DD"))
	//var/theyear = text2num(time2text(world.timeofday,"YYYY"))
	if(!istype(H))
		return
	if(!H.wear_mask && H.ckey == "landrydragon")
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime(H),slot_wear_mask)
	if(H.ckey == "iksxde")
		H.equip_to_slot_or_del(new /obj/item/bughunter(H), slot_back)
	if(H.ckey == "nibberfa0t1337")
		H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/condiment/saltshaker(H), slot_back)
	//st patricks day
	if(themonth == 3 && theday == 17 && !ignore_special_events)
		if(H.w_uniform)
			H.w_uniform.name = "Green [H.w_uniform.name]"
			H.w_uniform.icon_state = "green"
			H.w_uniform.item_state = "g_suit"
			H.w_uniform.item_color = "green"
			H.regenerate_icons()

//switching off human mood because its gay as fuck -falaskian
/datum/config_entry/flag/disable_human_mood
	config_entry_value = 1

/client
	var/list/shared_ips = list()
	var/list/shared_ids = list()

//giving detective back his telescopic baton
/datum/outfit/job/detective/New()
	backpack_contents.Remove(/obj/item/melee/classic_baton)
	backpack_contents[/obj/item/melee/classic_baton/telescopic] = 1
	. = ..()

/datum/outfit/job/warden/New()
	suit_store = /obj/item/gun/energy/laser/scatter/shotty
	. = ..()

/obj/structure/closet/secure_closet/warden/PopulateContents()
	. = ..()
	for(var/obj/item/gun/ballistic/shotgun/automatic/combat/compact/C in src)
		qdel(C)

/proc/generate_plasmaman_name()
	var/list/elements = list("Helium", "Lithium", "Beryllium", "Sodium", "Magnesium", "Aluminum", "Potassium",\
		"Calcium", "Scandium", "Titanium", "Vanadium", "Chromium", "Gallium", "Germanium", "Selenium", "Rubidium", "Strontium",\
		"Yttrium", "Zirconium", "Niobium", "Molybdenum", "Technetium", "Ruthenium", "Rhodium", "Palladium", "Cadmium", "Indium",\
		"Tellurium", "Cesium", "Barium", "Lanthanum", "Cerium", "Praseodymium", "Neodymium", "Promethium", "Samarium", "Europium",\
		"Gadolinium", "Terbium", "Dysprosium", "Holmium", "Erbium", "Thulium", "Ytterbium", "Lutetium", "Hafnium", "Rhenium", "Osmium",\
		"Iridium", "Platinum", "Thallium", "Polonium", "Francium", "Radium", "Actinium", "Thorium", "Protactinium", "Uranium",\
		"Neptunium", "Plutonium", "Americium", "Curium", "Berkelium", "Californium", "Einsteinium", "Fermium", "Nobelium",\
		"Lawrencium", "Rutherfordium", "Dubnium", "Seaborgium", "Bohrium", "Hassium", "Meitnerium")
	return "[pick(elements)] \Roman[rand(1,25)]"

//machine circuitboards remembering variables from the machine.
/obj/machinery/proc/upload_to_circuit_memory()
	if(circuit)
		for(var/V in savable_data)
			if(V in vars)
				circuit.saved_data[V] = vars[V]

/obj/machinery/proc/download_from_circuit_memory()
	if(circuit)
		for(var/V in savable_data)
			if((V in vars) && (V in circuit.saved_data))
				vars[V] = circuit.saved_data[V]

/obj/item/circuitboard
	var/list/saved_data = list()

/obj/machinery
	var/list/savable_data = list()

/obj/machinery/computer/rdconsole
	savable_data = list("locked")

//*********
//Omnilathe
//*********
//Science protolathe converts to an omni lathe depending on a config entry

/datum/config_entry/number/omnilathe
/obj/machinery/rnd/production/protolathe/department/science/Initialize(roundstart)
	if(roundstart && CONFIG_GET(number/omnilathe))
		name = "protolathe"
		allowed_department_flags = ALL
		department_tag = "Unidentified"
		circuit = /obj/item/circuitboard/machine/protolathe
		container_type = OPENCONTAINER
		requires_console = TRUE
		consoleless_interface = FALSE
	return ..()

/obj/machinery/rnd/production/techfab/department/science/Initialize(roundstart)
	if(roundstart && CONFIG_GET(number/omnilathe))
		name = "technology fabricator"
		desc = "Produces researched prototypes with raw materials and energy."
		icon_state = "protolathe"
		allowed_department_flags = ALL
		department_tag = "Unidentified"
		circuit = /obj/item/circuitboard/machine/techfab
		container_type = OPENCONTAINER
	return ..()

/obj/machinery/rnd/production/circuit_imprinter/department/science/Initialize(roundstart)
	if(roundstart && CONFIG_GET(number/omnilathe))
		name = "circuit imprinter"
		desc = "Manufactures circuit boards for the construction of machines."
		icon_state = "circuit_imprinter"
		container_type = OPENCONTAINER
		circuit = /obj/item/circuitboard/machine/circuit_imprinter
		requires_console = TRUE
		consoleless_interface = FALSE
		allowed_department_flags = ALL
		department_tag = "Unidentified"
	return ..()

//To ask the player to adminhelp if they are griefed
/client/proc/inform_to_adminhelp_death()
	spawn(30)
		var/informed = alert(src,"If you feel this death was illegitimate. Please adminhelp and an admin will investigate this death for you.","You Have Died","No thanks","Admin PM now")
		if(informed != "Admin PM now")
			return
		var/adminhelptext = input(src,"Enter admin help message.","Admin Help","I have died, is this death legit?") as text
		if(adminhelptext)
			adminhelp(adminhelptext)

//fixing the in_range() bug
/proc/toolbox_in_range(atom/source, atom/user)
	var/turf/sourceloc = source.loc
	var/turf/userloc = user.loc
	if(!istype(sourceloc))
		sourceloc = get_turf(source)
	if(!istype(userloc))
		userloc = get_turf(user)
	if((sourceloc.z == userloc.z) && (get_dist(sourceloc, userloc) <= 1))
		return 1
	return 0

//borgs can now unbuckle.
/atom/movable/attack_robot(mob/living/user)
	if(can_buckle && has_buckled_mobs())
		return attack_hand(user)
	else
		return ..()

//give acting captain
/mob/living/carbon/human/proc/give_acting_captaincy()
	var/obj/item/card/id/id = wear_id.GetID()
	if(istype(id) && id.access)
		if(!(ACCESS_CAPTAIN in id.access))
			id.access += ACCESS_CAPTAIN
			to_chat(src,"<span class='big bold'><font color='blue'>You are the acting captain.</font><span>")
			to_chat(src,"<B>You have been given access to the Captain's Office on your ID. It is recommended that you head over to the Captain's Office and secure the Captain's personal belongings.</B>")
			for(var/mob/M in GLOB.player_list)
				if(istype(M,/mob/dead/new_player) || M == src)
					continue
				to_chat(M,"<span class='big bold'><font color='blue'>[real_name] is the acting captain!</font><span>")
				CHECK_TICK

/proc/create_acting_captain()
	var/list/chain_of_command = list(
		"Head of Personnel",
		"Head of Security",
		"Chief Engineer",
		"Research Director",
		"Chief Medical Officer")
	var/heads_found = 0
	for(var/mob/living/M in GLOB.player_list)
		if(!M.mind)
			continue
		if(M.mind && M.mind.assigned_role in chain_of_command)
			heads_found = 1
			chain_of_command[M.mind.assigned_role] = M
	if(heads_found)
		for(var/job in chain_of_command)
			if(istype(chain_of_command[job],/mob/living/carbon/human))
				var/mob/living/carbon/human/H = chain_of_command[job]
				H.give_acting_captaincy()
				return 1
	return 0

/proc/create_latejoin_acting_captain(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!SSjob || !SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		return
	if(!H.mind || !(H.mind.assigned_role in GLOB.command_positions))
		return
	var/foundexistinghead = 0
	for(var/command_position in GLOB.command_positions)
		if(command_position == H.mind.assigned_role)
			continue
		var/datum/job/j = SSjob.GetJob(command_position)
		if(!j)
			continue
		if(j.current_positions >= 1)
			foundexistinghead = 1
			break
	if(!foundexistinghead)
		H.give_acting_captaincy()
