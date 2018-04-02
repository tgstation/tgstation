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

/world/proc/update_status()
	var/s = ""
	var/theservername = CONFIG_GET(string/servername)
	if (!theservername)
		theservername = "Tool Box Station"
	s += "<b>[theservername]</b>"
	s += " ("
	s += "<a href=\"http://toolboxrp.free-forum.net/\">" //Change this to wherever you want the hub to link to.
	s += "Forums"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += "|"
	s += "<a href=\"https://discord.gg/SwXyqCn\">Discord</a>"
	s += ")"

	var/list/features = list()

	if(SSticker)
		if(GLOB.master_mode)
			features += "Game Mode: [GLOB.master_mode]"
	else
		features += "<b>STARTING</b>"

	if (!GLOB.enter_allowed)
		features += "-closed"

	features += "-Light RP - The Brink of Chaos"
	features += "-High Security Standard"
	features += "-Active Staff & Development"

	if (features)
		s += ":<br>[jointext(features, "<br>")]"

	status = s

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