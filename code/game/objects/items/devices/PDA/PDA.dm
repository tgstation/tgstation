
//The advanced pea-green monochrome lcd of tomorrow.

GLOBAL_LIST_EMPTY(PDAs)

#define PDA_SCANNER_NONE 0
#define PDA_SCANNER_MEDICAL 1
#define PDA_SCANNER_FORENSICS 2 //unused
#define PDA_SCANNER_REAGENT 3
#define PDA_SCANNER_GAS 5
#define PDA_SPAM_DELAY     2 MINUTES

/obj/item/pda
	name = "\improper standard PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	inhand_icon_state = "electronic"
	worn_icon_state = "pda"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	greyscale_config = /datum/greyscale_config/pda
	greyscale_colors = "#999875#a92323"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	actions_types = list(/datum/action/item_action/toggle_light)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 2.3
	light_power = 0.6
	light_color = "#FFCC66"
	light_on = FALSE
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100, /datum/material/plastic=100)

	/// String name of owner
	var/owner = null
	/// Typepath of the default cartridge to use
	var/default_cartridge = 0
	/// Current cartridge
	var/obj/item/cartridge/cartridge = null
	/// Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.
	var/ui_mode = PDA_UI_HUB
	/// Icon to be overlayed for message alerts. Taken from the pda icon file.
	var/icon_alert = "pda-r"
	/// Icon to be overlayed when an active pAI is slotted in.
	var/icon_pai = "pai_overlay"
	/// Same as above but for an inactive pAI.
	var/icon_inactive_pai = "pai_off_overlay"
	/**
	 * This int tells DM which font is currently selected and lets DM know when the last font has been selected
	 * so that it can cycle back to the first font when "toggle font" is pressed again.
	 */
	var/font_index = 0
	/// The currently selected font.
	var/font_mode = "font-family:monospace;"
	/// The currently selected background color.
	var/background_color = "#808000"

	#define FONT_MONO "font-family:monospace;"
	#define FONT_SHARE "font-family:\"Share Tech Mono\", monospace;letter-spacing:0px;"
	#define FONT_ORBITRON "font-family:\"Orbitron\", monospace;letter-spacing:0px; font-size:15px"
	#define FONT_VT "font-family:\"VT323\", monospace;letter-spacing:1px;"
	#define MODE_MONO 0
	#define MODE_SHARE 1
	#define MODE_ORBITRON 2
	#define MODE_VT 3

	//Secondary variables
	var/scanmode = PDA_SCANNER_NONE
	var/silent = FALSE //To beep or not to beep, that is the question
	var/toff = FALSE //If TRUE, messenger disabled
	var/tnote = null //Current Texts
	var/last_text //No text spamming
	var/last_everyone //No text for everyone spamming
	var/last_noise //Also no honk spamming that's bad too
	var/ttone = "beep" //The ringtone!
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/notescanned = FALSE // True if what is in the notekeeper was from a paper.
	var/hidden = FALSE // Is the PDA hidden from the PDA list?
	var/emped = FALSE
	var/equipped = FALSE  //used here to determine if this is the first time its been picked up
	var/allow_emojis = FALSE //if the pda can send emojis and actually have them parsed as such
	var/sort_by_job = FALSE // If this is TRUE, will sort PDA list by job.

	var/obj/item/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above
	///account id of the ID held
	var/account_id

	var/obj/item/paicard/pai = null // A slot for a personal AI device

	var/datum/picture/picture //Scanned photo

	var/list/contained_item = list(/obj/item/pen, /obj/item/toy/crayon, /obj/item/lipstick, /obj/item/flashlight/pen, /obj/item/clothing/mask/cigarette)
	//This is the typepath to load "into" the pda
	var/obj/item/insert_type = /obj/item/pen
	//This is the currently inserted item
	var/obj/item/inserted_item
	var/underline_flag = TRUE //flag for underline

/obj/item/pda/suicide_act(mob/living/carbon/user)
	var/deathMessage = msg_input(user)
	if (!deathMessage)
		deathMessage = "i ded"
	user.visible_message(span_suicide("[user] is sending a message to the Grim Reaper! It looks like [user.p_theyre()] trying to commit suicide!"))
	tnote += "<i><b>&rarr; To The Grim Reaper:</b></i><br>[deathMessage]<br>"//records a message in their PDA as being sent to the grim reaper
	return BRUTELOSS

/obj/item/pda/examine(mob/user)
	. = ..()
	if(!id && !inserted_item)
		return

	if(id)
		. += span_notice("Alt-click to remove the ID.") //won't name ID on examine in case it's stolen

	if(inserted_item && (!isturf(loc)))
		. += span_notice("Ctrl-click to remove [inserted_item].") //traitor pens are disguised so we're fine naming them on examine

	if((!isnull(cartridge)))
		. += span_notice("Ctrl+Shift-click to remove the cartridge.") //won't name cart on examine in case it's Detomatix

/obj/item/pda/Initialize(mapload)
	. = ..()

	GLOB.PDAs += src
	if(default_cartridge)
		cartridge = SSwardrobe.provide_type(default_cartridge, src)
		cartridge.host_pda = src
	if(insert_type)
		inserted_item = SSwardrobe.provide_type(insert_type, src)
	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, .proc/on_light_eater)

	update_appearance()

/obj/item/pda/Destroy()
	GLOB.PDAs -= src
	if(istype(id))
		QDEL_NULL(id)
	if(istype(cartridge))
		QDEL_NULL(cartridge)
	if(istype(pai))
		QDEL_NULL(pai)
	if(istype(inserted_item))
		QDEL_NULL(inserted_item)
	return ..()

/obj/item/pda/equipped(mob/user, slot)
	. = ..()
	if(!equipped)
		if(user.client)
			background_color = user.client.prefs.read_preference(/datum/preference/color/pda_color)
			switch(user.client.prefs.read_preference(/datum/preference/choiced/pda_style))
				if(MONO)
					font_index = MODE_MONO
					font_mode = FONT_MONO
				if(SHARE)
					font_index = MODE_SHARE
					font_mode = FONT_SHARE
				if(ORBITRON)
					font_index = MODE_ORBITRON
					font_mode = FONT_ORBITRON
				if(VT)
					font_index = MODE_VT
					font_mode = FONT_VT
				else
					font_index = MODE_MONO
					font_mode = FONT_MONO
			equipped = TRUE

/obj/item/pda/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cartridge)
		cartridge.host_pda = null
		cartridge = null
	if(gone == inserted_item)
		inserted_item = null

/obj/item/pda/proc/update_label()
	name = "PDA-[owner] ([ownjob])" //Name generalisation

/obj/item/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/pda/get_id_examine_strings(mob/user)
	. = ..()
	if(id)
		. += "\The [src] is displaying [id]."
		. += id.get_id_examine_strings(user)

/obj/item/pda/GetID()
	return id

/obj/item/pda/RemoveID()
	return do_remove_id()

/obj/item/pda/InsertID(obj/item/inserting_item)
	var/obj/item/card/inserting_id = inserting_item.RemoveID()
	if(!inserting_id)
		return
	insert_id(inserting_id)
	if(id == inserting_id)
		return TRUE
	return FALSE

/obj/item/pda/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	if(!init_icon)
		return
	if(id)
		. += mutable_appearance(init_icon, "id_overlay")
	if(inserted_item)
		. += mutable_appearance(init_icon, "insert_overlay")
	if(light_on)
		. += mutable_appearance(init_icon, "light_overlay")
	if(pai)
		if(pai.pai)
			. += mutable_appearance(init_icon, icon_pai)
		else
			. += mutable_appearance(init_icon, icon_inactive_pai)

/obj/item/pda/MouseDrop(mob/over, src_location, over_location)
	var/mob/M = usr
	if((M == over) && usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return attack_self(M)
	return ..()


/obj/item/pda/attack_self_tk(mob/user)
	to_chat(user, span_warning("The PDA's capacitive touch screen doesn't seem to respond!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/item/pda/interact(mob/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	if(HAS_TRAIT(src, TRAIT_PDA_MESSAGE_MENU_RIGGED) && ui_mode == PDA_UI_MESSENGER)
		explode(user, from_message_menu = TRUE)
		return

	..()

	var/datum/asset/spritesheet/assets = get_asset_datum(/datum/asset/spritesheet/simple/pda)
	assets.send(user)

	var/datum/asset/spritesheet/emoji_s = get_asset_datum(/datum/asset/spritesheet/chat)
	emoji_s.send(user) //Already sent by chat but no harm doing this

	user.set_machine(src)

	var/dat = "<!DOCTYPE html><html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Personal Data Assistant</title><link href=\"https://fonts.googleapis.com/css?family=Orbitron|Share+Tech+Mono|VT323\" rel=\"stylesheet\"></head><body bgcolor=\"" + background_color + "\"><style>body{" + font_mode + "}ul,ol{list-style-type: none;}a, a:link, a:visited, a:active, a:hover { color: #000000;text-decoration:none; }img {border-style:none;}a img{padding-right: 9px;}</style>"
	dat += assets.css_tag()
	dat += emoji_s.css_tag()

	dat += "<a href='byond://?src=[REF(src)];choice=Refresh'>[PDAIMG(refresh)]Refresh</a>"

	if ((!isnull(cartridge)) && ui_mode == PDA_UI_HUB)
		dat += " | <a href='byond://?src=[REF(src)];choice=Eject'>[PDAIMG(eject)]Eject [cartridge]</a>"
	if (ui_mode != PDA_UI_HUB)
		dat += " | <a href='byond://?src=[REF(src)];choice=Return'>[PDAIMG(menu)]Return</a>"

	else
		dat += "<div align=\"center\">"
		dat += "<br><a href='byond://?src=[REF(src)];choice=Toggle_Font'>Toggle Font</a>"
		dat += " | <a href='byond://?src=[REF(src)];choice=Change_Color'>Change Color</a>"
		dat += " | <a href='byond://?src=[REF(src)];choice=Toggle_Underline'>Toggle Underline</a>" //underline button

		dat += "</div>"

	dat += "<br>"

	if (!owner)
		dat += "Warning: No owner information entered.  Please swipe card.<br><br>"
		dat += "<a href='byond://?src=[REF(src)];choice=Refresh'>[PDAIMG(refresh)]Retry</a>"
	else
		switch (ui_mode)
			if (PDA_UI_HUB)
				dat += "<h2>PERSONAL DATA ASSISTANT v.1.2</h2>"
				dat += "Owner: [owner], [ownjob]<br>"
				dat += text("ID: <a href='?src=[REF(src)];choice=Authenticate'>[id ? "[id.registered_name], [id.assignment]" : "----------"]")
				dat += text("<br><a href='?src=[REF(src)];choice=UpdateInfo'>[id ? "Update PDA Info" : ""]</A><br><br>")

				dat += "[station_time_timestamp()]<br>" //:[world.time / 100 % 6][world.time / 100 % 10]"
				dat += "[time2text(world.realtime, "MMM DD")] [GLOB.year_integer+540]<br>"
				dat += "It has been [ROUND_TIME] since the emergency shuttle was last called."


				dat += "<br><br>"

				dat += "<h4>General Functions</h4>"
				dat += "<ul>"
				dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_NOTEKEEPER]'>[PDAIMG(notes)]Notekeeper</a></li>"
				dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_MESSENGER]'>[PDAIMG(mail)]Messenger</a></li>"
				dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_SKILL_TRACKER]'>[PDAIMG(skills)]Skill Tracker</a></li>"

				if (cartridge)
					if (cartridge.access & CART_CLOWN)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Honk'>[PDAIMG(honk)]Honk Synthesizer</a></li>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=Trombone'>[PDAIMG(honk)]Sad Trombone</a></li>"
					if (cartridge.access & CART_MANIFEST)
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_CREW_MANIFEST]'>[PDAIMG(notes)]View Crew Manifest</a></li>"
					if(cartridge.access & CART_STATUS_DISPLAY)
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_STATUS_DISPLAY]'>[PDAIMG(status)]Set Status Display</a></li>"
					dat += "</ul>"
					if (cartridge.access & CART_ENGINE)
						dat += "<h4>Engineering Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_POWER_MONITOR]'>[PDAIMG(power)]Power Monitor</a></li>"
						dat += "</ul>"
					if (cartridge.access & CART_MEDICAL)
						dat += "<h4>Medical Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_MED_RECORDS]'>[PDAIMG(medical)]Medical Records</a></li>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=Medical Scan'>[PDAIMG(scanner)][scanmode == 1 ? "Disable" : "Enable"] Medical Scanner</a></li>"
						dat += "</ul>"
					if (cartridge.access & CART_SECURITY)
						dat += "<h4>Security Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_SEC_RECORDS]'>[PDAIMG(cuffs)]Security Records</A></li>"
						dat += "</ul>"
					if(cartridge.access & CART_QUARTERMASTER)
						dat += "<h4>Quartermaster Functions:</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_SUPPLY_RECORDS]'>[PDAIMG(crate)]Supply Records</A></li>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_SILO_LOGS]'>[PDAIMG(crate)]Ore Silo Logs</a></li>"
						dat += "</ul>"
				dat += "</ul>"

				dat += "<h4>Utilities</h4>"
				dat += "<ul>"
				if (cartridge)
					if(!isnull(cartridge.bot_access))
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_BOTS_ACCESS]'>[PDAIMG(medbot)]Bots Access</a></li>"
					if (cartridge.access & CART_JANITOR)
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_JANNIE_LOCATOR]'>[PDAIMG(bucket)]Custodial Locator</a></li>"
					if(cartridge.access & CART_MIME)
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_EMOJI_GUIDE]'>[PDAIMG(emoji)]Emoji Guidebook</a></li>"
					if (istype(cartridge.radio))
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_SIGNALER]'>[PDAIMG(signaler)]Signaler System</a></li>"
					if (cartridge.access & CART_NEWSCASTER)
						dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_NEWSCASTER]'>[PDAIMG(notes)]Newscaster Access </a></li>"
					if (cartridge.access & CART_REAGENT_SCANNER)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Reagent Scan'>[PDAIMG(reagent)][scanmode == 3 ? "Disable" : "Enable"] Reagent Scanner</a></li>"
					if (cartridge.access & CART_ATMOS)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Gas Scan'>[PDAIMG(reagent)][scanmode == 5 ? "Disable" : "Enable"] Gas Scanner</a></li>"
					if (cartridge.access & CART_REMOTE_DOOR)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Toggle Door'>[PDAIMG(rdoor)]Toggle Remote Door</a></li>"
					if (cartridge.access & CART_DRONEPHONE)
						dat += "<li><a href='byond://?src=[REF(src)];choice=Drone Phone'>[PDAIMG(dronephone)]Drone Phone</a></li>"
					if (cartridge.access & CART_DRONEACCESS)
						var/blacklist_state = GLOB.drone_machine_blacklist_enabled
						dat += "<li><a href='byond://?src=[REF(src)];drone_blacklist=[!blacklist_state];choice=Drone Access'>[PDAIMG(droneblacklist)][blacklist_state ? "Disable" : "Enable"] Drone Blacklist</a></li>"
				dat += "<li><a href='byond://?src=[REF(src)];choice=[PDA_UI_ATMOS_SCAN]'>[PDAIMG(atmos)]Atmospheric Scan</a></li>"
				dat += "<li><a href='byond://?src=[REF(src)];choice=Light'>[PDAIMG(flashlight)][light_on ? "Disable" : "Enable"] Flashlight</a></li>"
				if (pai)
					if(pai.loc != src)
						pai = null
						update_appearance()
					else
						dat += "<li><a href='byond://?src=[REF(src)];choice=pai;option=1'>pAI Device Configuration</a></li>"
						dat += "<li><a href='byond://?src=[REF(src)];choice=pai;option=2'>Eject pAI Device</a></li>"
				dat += "</ul>"

			if (PDA_UI_NOTEKEEPER)
				dat += "<h4>[PDAIMG(notes)] Notekeeper V2.2</h4>"
				dat += "<a href='byond://?src=[REF(src)];choice=Edit'>Edit</a><br>"
				if(notescanned)
					dat += "(This is a scanned image, editing it may cause some text formatting to change.)<br>"
				dat += "<HR><font face=\"[PEN_FONT]\">[(!notehtml ? note : notehtml)]</font>"

			if (PDA_UI_MESSENGER)
				dat += "<h4>[PDAIMG(mail)] SpaceMessenger V3.9.6</h4>"
				dat += "<a href='byond://?src=[REF(src)];choice=Toggle Ringer'>[PDAIMG(bell)]Ringer: [silent == 1 ? "Off" : "On"]</a> | "
				dat += "<a href='byond://?src=[REF(src)];choice=Toggle Messenger'>[PDAIMG(mail)]Send / Receive: [toff == 1 ? "Off" : "On"]</a> | "
				dat += "<a href='byond://?src=[REF(src)];choice=Ringtone'>[PDAIMG(bell)]Set Ringtone</a> | "
				dat += "<a href='byond://?src=[REF(src)];choice=[PDA_UI_READ_MESSAGES]'>[PDAIMG(mail)]Messages</a><br>"
				dat += "<a href='byond://?src=[REF(src)];choice=Sorting Mode'>Sorted by: [sort_by_job ? "Job" : "Name"]</a>"

				if(cartridge)
					dat += cartridge.message_header()

				dat += "<h4>[PDAIMG(menu)] Detected PDAs</h4>"

				dat += "<ul>"
				var/count = 0

				if (!toff)
					for (var/obj/item/pda/P in get_viewable_pdas(sort_by_job))
						if (P == src)
							continue
						dat += "<li><a href='byond://?src=[REF(src)];choice=Message;target=[REF(P)]'>[P.owner] ([P.ownjob])</a>"
						if(cartridge)
							dat += cartridge.message_special(P)
						dat += "</li>"
						count++
				dat += "</ul>"
				if (count == 0)
					dat += "None detected.<br>"
				else if(cartridge?.spam_enabled)
					dat += "<a href='byond://?src=[REF(src)];choice=MessageAll'>Send To All</a>"
			if(PDA_UI_SKILL_TRACKER)
				dat += "<h4>[PDAIMG(mail)] ExperTrak® Skill Tracker V4.26.2</h4>"
				dat += "<i>Thank you for choosing ExperTrak® brand software! ExperTrak® inc. is proud to be a Nanotrasen employee expertise and effectiveness department subsidary!</i>"
				dat += "<br><br>This software is designed to track and monitor your skill development as a Nanotrasen employee. Your job performance across different fields has been quantified and categorized below.<br>"
				var/datum/mind/targetmind = user.mind
				if(targetmind)
					for (var/type in GLOB.skill_types)
						var/datum/skill/S = GetSkillRef(type)
						var/lvl_num = targetmind.get_skill_level(type)
						var/lvl_name = uppertext(targetmind.get_skill_level_name(type))
						var/exp = targetmind.get_skill_exp(type)
						var/xp_prog_to_level = targetmind.exp_needed_to_level_up(type)
						var/xp_req_to_level = 0
						if (xp_prog_to_level && lvl_num < length(SKILL_EXP_LIST)) // is it even possible to level up?
							xp_req_to_level = SKILL_EXP_LIST[lvl_num+1] - SKILL_EXP_LIST[lvl_num]
						dat += "<HR><b>[S.name]</b>"
						dat += "<br><i>[S.desc]</i>"
						dat += "<ul><li>EMPLOYEE SKILL LEVEL: <b>[lvl_name]</b>"
						if (exp && xp_req_to_level)
							var/progress_percent = (xp_req_to_level-xp_prog_to_level)/xp_req_to_level
							var/overall_percent = exp / SKILL_EXP_LIST[length(SKILL_EXP_LIST)]
							dat += "<br>PROGRESS TO NEXT SKILL LEVEL:"
							dat += "<br>" + num2loadingbar(progress_percent) + "([progress_percent*100])%"
							dat += "<br>OVERALL DEVELOPMENT PROGRESS:"
							dat += "<br>" + num2loadingbar(overall_percent) + "([overall_percent*100])%"
						if (lvl_num >= length(SKILL_EXP_LIST) && !(type in targetmind.skills_rewarded))
							dat += "<br><a href='byond://?src=[REF(src)];choice=SkillReward;skill=[type]'>Contact the Professional [S.title] Association</a>"
						dat += "</li></ul>"
			if(PDA_UI_READ_MESSAGES)
				if(icon_alert && !istext(icon_alert))
					cut_overlay(icon_alert)
					icon_alert = initial(icon_alert)

				dat += "<h4>[PDAIMG(mail)] SpaceMessenger V3.9.6</h4>"
				dat += "<a href='byond://?src=[REF(src)];choice=Clear'>[PDAIMG(blank)]Clear Messages</a>"

				dat += "<h4>[PDAIMG(mail)] Messages</h4>"

				dat += tnote
				dat += "<br>"

			if (PDA_UI_ATMOS_SCAN)
				dat += "<h4>[PDAIMG(atmos)] Atmospheric Readings</h4>"

				var/turf/T = user.loc
				if (isnull(T))
					dat += "Unable to obtain a reading.<br>"
				else
					var/datum/gas_mixture/environment = T.return_air()
					var/list/env_gases = environment.gases

					var/pressure = environment.return_pressure()
					var/total_moles = environment.total_moles()

					dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

					if (total_moles)
						for(var/id in env_gases)
							var/gas_level = env_gases[id][MOLES]/total_moles
							if(gas_level > 0)
								dat += "[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_level*100, 0.01)]%<br>"

					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"
				dat += "<br>"
			else//Else it links to the cart menu proc. Although, it really uses menu hub 4--menu 4 doesn't really exist as it simply redirects to hub.
				dat += cartridge.generate_menu()

	dat += "</body></html>"

	if (underline_flag)
		dat = replacetext(dat, "text-decoration:none", "text-decoration:underline")
	if (!underline_flag)
		dat = replacetext(dat, "text-decoration:underline", "text-decoration:none")

	user << browse(dat, "window=pda;size=400x450;border=1;can_resize=1;can_minimize=0")
	onclose(user, "pda", src)

/obj/item/pda/Topic(href, href_list)
	..()
	var/mob/living/U = usr
	//Looking for master was kind of pointless since PDAs don't appear to have one.

	if(!href_list["close"] && usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		add_fingerprint(U)
		U.set_machine(src)

		var/choice = text2num(href_list["choice"]) || href_list["choice"]
		switch(choice)

//BASIC FUNCTIONS===================================

			if("Refresh")//Refresh, goes to the end of the proc.
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)

			if ("Toggle_Font")
				//CODE REVISION 2
				font_index = (font_index + 1) % 4

				switch(font_index)
					if (MODE_MONO)
						font_mode = FONT_MONO
					if (MODE_SHARE)
						font_mode = FONT_SHARE
					if (MODE_ORBITRON)
						font_mode = FONT_ORBITRON
					if (MODE_VT)
						font_mode = FONT_VT
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if ("Change_Color")
				var/new_color = input("Please enter a color name or hex value (Default is \'#808000\').",background_color)as color
				background_color = new_color

			if ("Toggle_Underline")
				underline_flag = !underline_flag
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)

			if("Return")//Return
				ui_mode = round(ui_mode/PDA_UI_RETURN_DIVIDER)
				if(ISINRANGE(ui_mode, PDA_UI_REDIRECT_HUB_MIN, PDA_UI_REDIRECT_HUB_MAX))//Fix for cartridges. Redirects to hub.
					ui_mode = PDA_UI_HUB
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if ("Authenticate")//Checks for ID
				id_check(U)
			if("UpdateInfo")
				ownjob = id.assignment
				update_label()
				if(!silent)
					playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, src, 'sound/machines/terminal_success.ogg', 15, TRUE), 1.3 SECONDS)
			if("Eject")//Ejects the cart, only done from hub.
				eject_cart(U)
				if(!silent)
					playsound(src, 'sound/machines/terminal_eject.ogg', 50, TRUE)

//MENU FUNCTIONS===================================

			if(PDA_UI_HUB)
				ui_mode = PDA_UI_HUB
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if(PDA_UI_NOTEKEEPER)
				ui_mode = PDA_UI_NOTEKEEPER
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if(PDA_UI_MESSENGER)
				if(HAS_TRAIT(src, TRAIT_PDA_MESSAGE_MENU_RIGGED))
					explode(U, from_message_menu = TRUE)
					return
				ui_mode = PDA_UI_MESSENGER
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if(PDA_UI_READ_MESSAGES)
				ui_mode = PDA_UI_READ_MESSAGES
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if(PDA_UI_ATMOS_SCAN)
				ui_mode = PDA_UI_ATMOS_SCAN
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)


//MAIN FUNCTIONS===================================

			if("Light")
				toggle_light(U)
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if("Medical Scan")
				if(scanmode == PDA_SCANNER_MEDICAL)
					scanmode = PDA_SCANNER_NONE
				else if((!isnull(cartridge)) && (cartridge.access & CART_MEDICAL))
					scanmode = PDA_SCANNER_MEDICAL
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if("Reagent Scan")
				if(scanmode == PDA_SCANNER_REAGENT)
					scanmode = PDA_SCANNER_NONE
				else if((!isnull(cartridge)) && (cartridge.access & CART_REAGENT_SCANNER))
					scanmode = PDA_SCANNER_REAGENT
			if("Honk")
				if ( !(last_noise && world.time < last_noise + 20) )
					playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
					last_noise = world.time
			if("Trombone")
				if ( !(last_noise && world.time < last_noise + 20) )
					playsound(src, 'sound/misc/sadtrombone.ogg', 50, TRUE)
					last_noise = world.time
			if("Gas Scan")
				if(scanmode == PDA_SCANNER_GAS)
					scanmode = PDA_SCANNER_NONE
				else if((!isnull(cartridge)) && (cartridge.access & CART_ATMOS))
					scanmode = PDA_SCANNER_GAS
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			if("Drone Phone")
				var/alert_s = tgui_input_list(U, "Alert severity level", "Ping Drones", list("Low","Medium","High","Critical"))
				if(isnull(alert_s))
					return
				var/area/A = get_area(U)
				if(A && !QDELETED(U))
					var/msg = span_boldnotice("NON-DRONE PING: [U.name]: [alert_s] priority alert in [A.name]!")
					_alert_drones(msg, TRUE, U)
					to_chat(U, msg)
					if(!silent)
						playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)
			if("Drone Access")
				var/mob/living/simple_animal/drone/drone_user = U
				if(isdrone(U) && drone_user.shy)
					to_chat(U, span_warning("Your laws prevent this action."))
					return
				var/new_state = text2num(href_list["drone_blacklist"])
				GLOB.drone_machine_blacklist_enabled = new_state
				if(!silent)
					playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)


//NOTEKEEPER FUNCTIONS===================================

			if ("Edit")
				var/n = tgui_input_text(U, "Please enter message", name, note, multiline = TRUE)
				if (in_range(src, U) && loc == U)
					if (ui_mode == PDA_UI_NOTEKEEPER && n)
						note = n
						notehtml = parsemarkdown(n, U)
						notescanned = FALSE
				else
					U << browse(null, "window=pda")
					return

//MESSENGER FUNCTIONS===================================

			if("Toggle Messenger")
				toff = !toff
			if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
				silent = !silent
			if("Clear")//Clears messages
				tnote = null
			if("Ringtone")
				var/t = tgui_input_text(U, "Enter a new ringtone", "PDA Ringtone", ttone, 20)
				if(in_range(src, U) && loc == U && t)
					if(SEND_SIGNAL(src, COMSIG_PDA_CHANGE_RINGTONE, U, t) & COMPONENT_STOP_RINGTONE_CHANGE)
						U << browse(null, "window=pda")
						return
					else
						ttone = t
				else
					U << browse(null, "window=pda")
					return
			if("Message")
				create_message(U, locate(href_list["target"]) in GLOB.PDAs)
			if("Mess_us_up")
				if(!HAS_TRAIT(src, TRAIT_PDA_CAN_EXPLODE)) //in case someone ever tries to call this with forged hrefs
					return
				explode(U, locate(href_list["target"]))

			if("Sorting Mode")
				sort_by_job = !sort_by_job

			if("MessageAll")
				if(cartridge?.spam_enabled)
					send_to_all(U)

			if("cart")
				if(cartridge)
					cartridge.special(U, href_list)
				else
					U << browse(null, "window=pda")
					return

//SYNDICATE FUNCTIONS===================================

			if("Toggle Door")
				if(cartridge && cartridge.access & CART_REMOTE_DOOR)
					for(var/obj/machinery/door/poddoor/M in GLOB.machines)
						if(M.id == cartridge.remote_door_id)
							if(M.density)
								M.open()
							else
								M.close()

//pAI FUNCTIONS===================================

			if("pai")
				switch(href_list["option"])
					if("1") // Configure pAI device
						pai.attack_self(U)
					if("2") // Eject pAI device
						usr.put_in_hands(pai)
						pai.slotted = FALSE
						to_chat(usr, span_notice("You remove the pAI from the [name]."))

//SKILL FUNCTIONS===================================

			if("SkillReward")
				var/type = text2path(href_list["skill"])
				var/datum/skill/S = GetSkillRef(type)
				var/datum/mind/mind = U.mind
				var/new_level = mind.get_skill_level(type)
				S.try_skill_reward(mind, new_level)

//LINK FUNCTIONS===================================

			else
				ui_mode = max(choice, PDA_UI_HUB)

	else//If not in range, can't interact or not using the pda.
		U.unset_machine()
		U << browse(null, "window=pda")
		return

//EXTRA FUNCTIONS===================================

	if (ui_mode == PDA_UI_MESSENGER || ui_mode == PDA_UI_READ_MESSAGES)//To clear message overlays.
		update_appearance()

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(src, 'sound/items/bikehorn.ogg', 30, TRUE)

	if(U.machine == src && href_list["skiprefresh"]!="1")//Final safety.
		attack_self(U)//It auto-closes the menu prior if the user is not in range and so on.
	else
		U.unset_machine()
		U << browse(null, "window=pda")
	return

/obj/item/pda/proc/remove_id(mob/user)
	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	do_remove_id(user)


/obj/item/pda/proc/do_remove_id(mob/user)
	if(!id)
		return
	if(user)
		user.put_in_hands(id)
		to_chat(user, span_notice("You remove the ID from the [name]."))
	else
		id.forceMove(get_turf(src))

	. = id
	id = null
	updateSelfDialog()
	update_appearance()
	playsound(src, 'sound/machines/terminal_eject.ogg', 50, TRUE)

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_id == src)
			H.sec_hud_set_ID()

	update_slot_icon()


/obj/item/pda/proc/msg_input(mob/living/U = usr, rigged = FALSE)
	var/t = tgui_input_text(U, "Enter a message", "PDA Messaging")
	if (!t || toff)
		return
	if(!U.canUseTopic(src, BE_CLOSE))
		return
	if(emped)
		t = Gibberish(t, TRUE)
	return t

/**
 * Prompts the user to input and send a message to another PDA.
 * the everyone arg is used for mass messaging from lawyer and captain carts.
 * rigged for PDA bombs. fakename and fakejob for forged messages (also PDA bombs).
 */
/obj/item/pda/proc/send_message(mob/living/user, list/obj/item/pda/targets, everyone = FALSE, rigged = FALSE, fakename, fakejob)
	var/message = msg_input(user, rigged)
	if(!message || !targets.len)
		return FALSE
	if((last_text && world.time < last_text + 10) || (everyone && last_everyone && world.time < last_everyone + PDA_SPAM_DELAY))
		return FALSE

	var/turf/position = get_turf(src)
	for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
		var/turf/jammer_turf = get_turf(jammer)
		if(position?.z == jammer_turf.z && (get_dist(position, jammer_turf) <= jammer.range))
			return FALSE

	var/list/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered_for_pdas(message)
	if (filter_result)
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		return FALSE

	var/list/soft_filter_result = CAN_BYPASS_FILTER(user) ? null : is_soft_ic_filtered_for_pdas(message)
	if (soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to send it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term in PDA messages. Message: \"[html_encode(message)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term in PDA messages. Message: \"[message]\"")

	if(prob(1))
		message += "\nSent from my PDA"
	// Send the signal
	var/list/string_targets = list()
	for (var/obj/item/pda/P in targets)
		if (P.owner && P.ownjob)  // != src is checked by the UI
			string_targets += STRINGIFY_PDA_TARGET(P.owner, P.ownjob)
	for (var/obj/machinery/computer/message_monitor/M in targets)
		// In case of "Reply" to a message from a console, this will make the
		// message be logged successfully. If the console is impersonating
		// someone by matching their name and job, the reply will reach the
		// impersonated PDA.
		string_targets += STRINGIFY_PDA_TARGET(M.customsender, M.customjob)
	if (!string_targets.len)
		return FALSE

	var/datum/signal/subspace/messaging/pda/signal = new(src, list(
		"name" = "[fakename || owner]",
		"job" = "[fakejob || ownjob]",
		"message" = message,
		"targets" = string_targets,
		"emojis" = allow_emojis,
		"rigged" = rigged,
	))
	if(rigged) //Will skip the message server and go straight to the hub so it can't be cheesed by disabling the message server machine
		signal.data["rigged_user"] = REF(user) // Used for bomb logging
		signal.server_type = /obj/machinery/telecomms/hub
		signal.data["reject"] = FALSE // Do not refuse the message
	if (picture)
		signal.data["photo"] = picture
	signal.send_to_receivers()

	// If it didn't reach, note that fact
	if (!signal.data["done"])
		to_chat(user, span_notice("ERROR: Server isn't responding."))
		if(!silent)
			playsound(src, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return FALSE

	var/target_text = signal.format_target()
	if(allow_emojis)
		message = emoji_parse(message)//already sent- this just shows the sent emoji as one to the sender in the to_chat
		signal.data["message"] = emoji_parse(signal.data["message"])

	// Log it in our logs
	tnote += "<i><b>&rarr; To [target_text]:</b></i><br>[signal.format_message()]<br>"
	// Show it to ghosts
	var/ghost_message = span_name("[owner] </span><span class='game say'>[rigged ? "Rigged" : ""] PDA Message</span> --> [span_name("[target_text]")]: <span class='message'>[signal.format_message()]")
	for(var/mob/M in GLOB.player_list)
		if(isobserver(M) && (M.client?.prefs.chat_toggles & CHAT_GHOSTPDA))
			to_chat(M, "[FOLLOW_LINK(M, user)] [ghost_message]")
	// Log in the talk log
	user.log_talk(message, LOG_PDA, tag="[rigged ? "Rigged" : ""] PDA: [initial(name)] to [target_text]")
	if(rigged)
		log_bomber(user, "sent a rigged PDA message (Name: [fakename || owner]. Job: [fakejob || ownjob]) to [english_list(string_targets)] [!is_special_character(user) ? "(SENT BY NON-ANTAG)" : ""]")
	to_chat(user, span_info("PDA message sent to [target_text]: \"[message]\""))
	if(!silent)
		playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)
	// Reset the photo
	picture = null
	last_text = world.time
	if (everyone)
		last_everyone = world.time
	return TRUE

/obj/item/pda/proc/receive_message(datum/signal/subspace/messaging/pda/signal)
	var/ref_target = signal.data["rigged"] ? signal.data["rigged_user"] : REF(signal.source)
	tnote += "<i><b>&larr; From <a href='byond://?src=[REF(src)];choice=[signal.data["rigged"] ? "Mess_us_up" : "Message"];target=[ref_target]'>[signal.data["name"]]</a> ([signal.data["job"]]):</b></i><br>[signal.format_message()]<br>"

	if (!silent)
		if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
			playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
		else
			playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
		audible_message("<span class='infoplain'>[icon2html(src, hearers(src))] *[ttone]*</span>", null, 3)
	//Search for holder of the PDA.
	var/mob/living/L = null
	if(loc && isliving(loc))
		L = loc
	//Maybe they are a pAI!
	else
		L = get(src, /mob/living/silicon)

	if(L && (L.stat == CONSCIOUS || L.stat == SOFT_CRIT))
		var/reply = "(<a href='byond://?src=[REF(src)];choice=[signal.data["rigged"] ? "Mess_us_up" : "Message"];skiprefresh=1;target=[REF(signal.source)]'>Reply</a>)"
		var/hrefstart
		var/hrefend
		if (isAI(L))
			hrefstart = "<a href='?src=[REF(L)];track=[html_encode(signal.data["name"])]'>"
			hrefend = "</a>"

		if(signal.data["automated"])
			reply = "\[Automated Message\]"

		var/inbound_message = signal.format_message()
		if(signal.data["emojis"] == TRUE)//so will not parse emojis as such from pdas that don't send emojis
			inbound_message = emoji_parse(inbound_message)

		to_chat(L, "<span class='infoplain'>[icon2html(src)] <b>PDA message from [hrefstart][signal.data["name"]] ([signal.data["job"]])[hrefend], </b>[inbound_message] [reply]</span>")

	update_appearance()
	if(istext(icon_alert))
		icon_alert = mutable_appearance(initial(icon), icon_alert)
		add_overlay(icon_alert)

/obj/item/pda/proc/send_to_all(mob/living/U)
	if (last_everyone && world.time < last_everyone + PDA_SPAM_DELAY)
		to_chat(U,span_warning("Send To All function is still on cooldown."))
		return
	send_message(U,get_viewable_pdas(), TRUE)

/obj/item/pda/proc/create_message(mob/living/U, obj/item/pda/P)
	send_message(U,list(P))

/obj/item/pda/AltClick(mob/user)
	..()

	if(id)
		remove_id(user)
	else
		remove_pen(user)

/obj/item/pda/CtrlClick(mob/user)
	..()

	if(isturf(loc)) //stops the user from dragging the PDA by ctrl-clicking it.
		return

	remove_pen(user)

/obj/item/pda/CtrlShiftClick(mob/user)
	..()
	eject_cart(user)

/obj/item/pda/verb/verb_toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	toggle_light(usr)

/obj/item/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Eject ID"
	set src in usr

	if(id)
		remove_id(usr)
	else
		to_chat(usr, span_warning("This PDA does not have an ID in it!"))

/obj/item/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove Pen"
	set src in usr

	remove_pen(usr)

/obj/item/pda/verb/verb_eject_cart()
	set category = "Object"
	set name = "Eject Cartridge"
	set src in usr

	eject_cart(usr)

/obj/item/pda/proc/toggle_light(mob/user)
	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(light_on)
		set_light_on(FALSE)
	else if(light_range)
		set_light_on(TRUE)
	update_appearance()
	update_action_buttons(force = TRUE)

/// Special light eater handling
/obj/item/pda/proc/on_light_eater(obj/item/pda/source, datum/light_eater)
	SIGNAL_HANDLER
	set_light_on(FALSE)
	set_light_range(0) //We won't be turning on again.
	update_appearance()
	visible_message(span_danger("The light in [src] shorts out!"))
	return COMPONENT_BLOCK_LIGHT_EATER

/obj/item/pda/proc/remove_pen(mob/user)

	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)) //TK doesn't work even with this removed but here for readability
		return

	if(inserted_item)
		to_chat(user, span_notice("You remove [inserted_item] from [src]."))
		user.put_in_hands(inserted_item) //Don't need to manage the pen ref, handled on Exited()
		update_appearance()
		playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)
	else
		to_chat(user, span_warning("This PDA does not have a pen in it!"))

/obj/item/pda/proc/eject_cart(mob/user)
	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)) //TK disabled to stop cartridge teleporting into hand
		return
	if (!isnull(cartridge))
		to_chat(user, span_notice("You eject [cartridge] from [src]."))
		user.put_in_hands(cartridge) //We don't manage reference clearing here, dealt with in Exited()
		scanmode = PDA_SCANNER_NONE
		updateSelfDialog()
		update_appearance()

//trying to insert or remove an id
/obj/item/pda/proc/id_check(mob/user, obj/item/card/id/I)
	if(!I)
		if(id && (src in user.contents))
			remove_id(user)
			return TRUE
		else
			var/obj/item/card/id/C = user.get_active_held_item()
			if(istype(C))
				I = C

	if(I?.registered_name)
		if(!user.transferItemToLoc(I, src))
			return FALSE
		insert_id(I, user)
		update_appearance()
		playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)
	return TRUE


/obj/item/pda/proc/insert_id(obj/item/card/id/inserting_id, mob/user)
	var/obj/old_id = id
	id = inserting_id
	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.wear_id == src)
			human_wearer.sec_hud_set_ID()
	if(old_id)
		if(user)
			user.put_in_hands(old_id)
		else
			old_id.forceMove(get_turf(src))

	update_slot_icon()


/obj/item/pda/pre_attack(obj/target, mob/living/user, params)
	if(!ismachinery(target))
		return ..()
	var/obj/machinery/target_machine = target
	if(!target_machine.panel_open && !istype(target, /obj/machinery/computer))
		return ..()
	if(!istype(cartridge, /obj/item/cartridge/virus/clown))
		return ..()
	var/obj/item/cartridge/virus/installed_cartridge = cartridge

	if(installed_cartridge.charges <=0)
		to_chat(user, span_notice("Out of charges."))
		return ..()
	to_chat(user, span_notice("You upload the virus to the airlock controller!"))
	var/sig_list
	if(istype(target,/obj/machinery/door/airlock))
		sig_list += list(COMSIG_AIRLOCK_OPEN, COMSIG_AIRLOCK_CLOSE)
	else
		sig_list += list(COMSIG_ATOM_ATTACK_HAND)
	target.AddComponent(/datum/component/sound_player, 30, list('sound/items/bikehorn.ogg'), rand(15,20), sig_list)
	installed_cartridge.charges--
	return TRUE


// access to status display signals
/obj/item/pda/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/cartridge))
		if(!user.transferItemToLoc(C, src))
			return
		eject_cart(user)
		cartridge = C
		cartridge.host_pda = src
		to_chat(user, span_notice("You insert [cartridge] into [src]."))
		updateSelfDialog()
		update_appearance()
		playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)

	else if(istype(C, /obj/item/card/id))
		var/obj/item/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, span_warning("\The [src] rejects the ID!"))
			if(!silent)
				playsound(src, 'sound/machines/terminal_error.ogg', 50, TRUE)
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			update_label()
			to_chat(user, span_notice("Card scanned."))
			if(!silent)
				playsound(src, 'sound/machines/terminal_success.ogg', 50, TRUE)
		else
			if(!id_check(user, idcard))
				return
			to_chat(user, span_notice("You put the ID into \the [src]'s slot."))
			updateSelfDialog()//Update self dialog on success.

			return //Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(C, /obj/item/paicard) && !pai)
		if(!user.transferItemToLoc(C, src))
			return
		pai = C
		pai.slotted = TRUE
		to_chat(user, span_notice("You slot \the [C] into [src]."))
		update_appearance()
		updateUsrDialog()
	else if(is_type_in_list(C, contained_item)) //Checks if there is a pen
		if(inserted_item)
			to_chat(user, span_warning("There is already \a [inserted_item] in \the [src]!"))
		else
			if(!user.transferItemToLoc(C, src))
				return
			to_chat(user, span_notice("You slide \the [C] into \the [src]."))
			inserted_item = C
			update_appearance()
			playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)
	else if(istype(C, /obj/item/photo))
		var/obj/item/photo/P = C
		picture = P.picture
		to_chat(user, span_notice("You scan \the [C]."))
	// Check to see if we have an ID inside, and a valid input for money
	else if(id && iscash(C))
		id.attackby(C, user) // If we do, try and put that attacking object in
	else
		return ..()

/obj/item/pda/attack(mob/living/carbon/C, mob/living/user)
	if(istype(C))
		switch(scanmode)

			if(PDA_SCANNER_MEDICAL)
				C.visible_message(span_notice("[user] analyzes [C]'s vitals."))
				healthscan(user, C, 1)
				add_fingerprint(user)

/obj/item/pda/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	switch(scanmode)
		if(PDA_SCANNER_REAGENT)
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					to_chat(user, span_notice("[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found."))
					for (var/re in A.reagents.reagent_list)
						to_chat(user, span_notice("\t [re]"))
				else
					to_chat(user, span_notice("No active chemical agents found in [A]."))
			else
				to_chat(user, span_notice("No significant chemical agents found in [A]."))

		if(PDA_SCANNER_GAS)
			A.analyzer_act(user, src)

	if (!scanmode && istype(A, /obj/item/paper) && owner)
		var/obj/item/paper/paper = A
		if (!paper.get_info_length())
			to_chat(user, span_warning("Unable to scan! Paper is blank."))
			return
		notehtml = paper.info
		if(paper.add_info)
			for(var/index in 1 to length(paper.add_info))
				var/list/style = paper.add_info_style[index]
				notehtml += PAPER_MARK_TEXT(paper.add_info[index], style[ADD_INFO_COLOR], style[ADD_INFO_FONT])
		note = replacetext(notehtml, "<BR>", "\[br\]")
		note = replacetext(note, "<li>", "\[*\]")
		note = replacetext(note, "<ul>", "\[list\]")
		note = replacetext(note, "</ul>", "\[/list\]")
		note = html_encode(note)
		notescanned = TRUE
		to_chat(user, span_notice("Paper scanned. Saved to PDA's notekeeper.") )

/**
 * Called when someone replies to a rigged PDA message. It explodes.
 * from_message_menu : whether it's caused by the target opening the message menu too early.
 */
/obj/item/pda/proc/explode(mob/target, mob/bomber, from_message_menu = FALSE)
	var/turf/T = get_turf(src)

	if(from_message_menu)
		log_bomber(null, null, target, "'s PDA exploded as [target.p_they()] tried to open their PDA message menu because of a recent pda bomb.")
	else
		log_bomber(bomber, "successfully PDA-bombed", target, "as [target.p_they()] tried to reply to a rigged PDA message [bomber && !is_special_character(bomber) ? "(SENT BY NON-ANTAG)" : ""]")

	if (ismob(loc))
		var/mob/M = loc
		M.show_message(span_userdanger("Your [src] explodes!"), MSG_VISUAL, span_warning("You hear a loud *pop*!"), MSG_AUDIBLE)
	else
		visible_message(span_danger("[src] explodes!"), span_warning("You hear a loud *pop*!"))

	target.client?.give_award(/datum/award/achievement/misc/clickbait, target)

	if(T)
		T.hotspot_expose(700,125)
		if(istype(cartridge, /obj/item/cartridge/virus/syndicate))
			explosion(src, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 4)
		else
			explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3)
	qdel(src)

//AI verb and proc for sending PDA messages.

/obj/item/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "PDA - Toggle Sender/Receiver"

	if(usr.stat == DEAD)
		return //won't work if dead
	var/mob/living/silicon/S = usr
	if(istype(S) && !isnull(S.aiPDA))
		S.aiPDA.toff = !S.aiPDA.toff
		to_chat(usr, span_notice("PDA sender/receiver toggled [(S.aiPDA.toff ? "Off" : "On")]!"))
	else
		to_chat(usr, "You do not have a PDA. You should make an issue report about this.")

/obj/item/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "PDA - Toggle Ringer"

	if(usr.stat == DEAD)
		return //won't work if dead
	var/mob/living/silicon/S = usr
	if(istype(S) && !isnull(S.aiPDA))
		//0
		S.aiPDA.silent = !S.aiPDA.silent
		to_chat(usr, span_notice("PDA ringer toggled [(S.aiPDA.silent ? "Off" : "On")]!"))
	else
		to_chat(usr, "You do not have a PDA. You should make an issue report about this.")

/mob/living/silicon/proc/cmd_send_pdamesg(mob/user)
	var/list/plist = list()
	var/list/namecounts = list()

	if(aiPDA.toff)
		to_chat(user, span_alert("Turn on your receiver in order to send messages."))
		return

	for (var/obj/item/pda/pda as anything in get_viewable_pdas())
		if (pda == src)
			continue
		else if (pda == aiPDA)
			continue

		plist[avoid_assoc_duplicate_keys(pda.owner, namecounts)] = pda

	var/choice = tgui_input_list(user, "Please select a PDA", "PDA Messenger", sort_list(plist))
	if (isnull(choice))
		return

	var/selected = plist[choice]

	if(aicamera.stored.len)
		var/add_photo = tgui_alert(user,"Do you want to attach a photo?", "PDA Messenger", list("Yes","No"))
		if(add_photo == "Yes")
			var/datum/picture/Pic = aicamera.selectpicture(user)
			aiPDA.picture = Pic

	if(incapacitated())
		return

	aiPDA.create_message(src, selected)

/mob/living/silicon/proc/cmd_show_message_log(mob/user)
	if(incapacitated())
		return
	if(!isnull(aiPDA))
		var/HTML = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>AI PDA Message Log</title></head><body>[aiPDA.tnote]</body></html>"
		user << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")
	else
		to_chat(user, span_warning("You do not have a PDA! You should make an issue report about this."))

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/pda/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_CONTENTS))
		for(var/atom/A in src)
			A.emp_act(severity)
	if (!(. & EMP_PROTECT_SELF))
		emped++
		addtimer(CALLBACK(src, .proc/emp_end), 200 * severity)

/obj/item/pda/proc/emp_end()
	emped--

/proc/get_viewable_pdas(sort_by_job = FALSE)
	. = list()
	// Returns a list of PDAs which can be viewed from another PDA/message monitor.,
	var/sortmode
	if(sort_by_job)
		sortmode = /proc/cmp_pdajob_asc
	else
		sortmode = /proc/cmp_pdaname_asc

	for(var/obj/item/pda/P in sort_list(GLOB.PDAs, sortmode))
		if(!P.owner || P.toff || P.hidden)
			continue
		. += P

/obj/item/pda/proc/pda_no_detonate()
	SIGNAL_HANDLER
	return COMPONENT_PDA_NO_DETONATE

/// Return a list of types you want to pregenerate and use later
/// Do not pass in things that care about their init location, or expect extra input
/// Also as a curtiousy to me, don't pass in any bombs
/obj/item/pda/proc/get_types_to_preload()
	var/list/preload = list()
	preload += default_cartridge
	preload += insert_type
	return preload

/// Callbacks for preloading pdas
/obj/item/pda/proc/display_pda()
	GLOB.PDAs += src

/// See above, we don't want jerry from accounting to try and message nullspace his new bike
/obj/item/pda/proc/cloak_pda()
	GLOB.PDAs -= src

#undef PDA_SCANNER_NONE
#undef PDA_SCANNER_MEDICAL
#undef PDA_SCANNER_FORENSICS
#undef PDA_SCANNER_REAGENT
#undef PDA_SCANNER_GAS
#undef PDA_SPAM_DELAY
