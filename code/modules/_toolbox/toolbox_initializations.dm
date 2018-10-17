//Use this file to for things related to round start or new spawn initializations.

proc/Initialize_Falaskians_Shit()
	SaveStation()
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
	if(SSticker)
		if(SSticker.current_state < GAME_STATE_PLAYING)
			dat += "New Round Starting."
		else if (SSticker.current_state > GAME_STATE_PLAYING)
			dat += "New round soon."
		else
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
			dat += "Round Time: [hours]:[minutes]"
	else
		dat += "Restarting."
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
/datum/outfit/proc/update_toolbox_inventory(mob/living/carbon/human/H)
	var/themonth = text2num(time2text(world.timeofday,"MM"))
	var/theday = text2num(time2text(world.timeofday,"DD"))
	//var/theyear = text2num(time2text(world.timeofday,"YYYY"))
	if(!istype(H))
		return
	if(!H.wear_mask && H.ckey == "landrydragon")
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime(H),slot_wear_mask)
	//st patricks day
	if(themonth == 3 && theday == 17)
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