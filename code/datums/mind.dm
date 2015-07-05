/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role
	var/list/restricted_roles = list()

	var/datum/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/list/cult_words = list()
	var/list/spell_list = list() // Wizard mode & "Give Spell" badmin button.

	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder

	var/miming = 0 // Mime's vow of silence
	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/datum/gang/gang_datum //Which gang this mind belongs to, if any

/datum/mind/New(var/key)
	src.key = key


/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		ERROR("transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform coderbus")

	if(current)					//remove ourself from our old body's mind variable
		current.mind = null

		SSnano.user_transferred(current, new_character)

	if(key)
		if(new_character.key != key)					//if we're transfering into a body with a key associated which is not ours
			new_character.ghostize(1)						//we'll need to ghostize so that key isn't mobless.
	else
		key = new_character.key

	if(new_character.mind)								//disassociate any mind currently in our new body's mind variable
		new_character.mind.current = null

	current = new_character								//associate ourself with our new body
	new_character.mind = src							//and associate our new body with ourself
	transfer_antag_huds(new_character)					//inherit the antag HUDs from this mind (TODO: move this to a possible antag datum)
	transfer_actions(new_character)

	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/wipe_memory()
	memory = null


/*
	Removes antag type's references from a mind.
	objectives, uplinks, powers etc are all handled.
*/

/datum/mind/proc/remove_objectives()
	if(objectives.len)
		for(var/datum/objective/O in objectives)
			objectives -= O
			qdel(O)

/datum/mind/proc/remove_changeling()
	if(src in ticker.mode.changelings)
		ticker.mode.changelings -= src
		current.remove_changeling_powers()
		if(changeling)
			qdel(changeling)
			changeling = null
	special_role = null
	remove_antag_equip()

/datum/mind/proc/remove_traitor()
	if(src in ticker.mode.traitors)
		ticker.mode.traitors -= src
		if(isAI(current))
			var/mob/living/silicon/ai/A = current
			A.set_zeroth_law("")
			A.show_laws()
	special_role = null
	remove_antag_equip()

/datum/mind/proc/remove_nukeop()
	if(src in ticker.mode.syndicates)
		ticker.mode.syndicates -= src
		ticker.mode.update_synd_icons_removed(src)
	special_role = null
	remove_objectives()
	remove_antag_equip()

/datum/mind/proc/remove_wizard()
	if(src in ticker.mode.wizards)
		ticker.mode.wizards -= src
		current.spellremove(current)
	special_role = null
	remove_antag_equip()

/datum/mind/proc/remove_cultist()
	if(src in ticker.mode.cult)
		ticker.mode.cult -= src
		ticker.mode.update_cult_icons_removed(src)
		var/datum/game_mode/cult/cult = ticker.mode
		if(istype(cult))
			cult.memorize_cult_objectives(src)
	special_role = null
	remove_objectives()
	remove_antag_equip()

/datum/mind/proc/remove_rev()
	if(src in ticker.mode.revolutionaries)
		ticker.mode.revolutionaries -= src
		ticker.mode.update_rev_icons_removed(src)
	if(src in ticker.mode.head_revolutionaries)
		ticker.mode.head_revolutionaries -= src
		ticker.mode.update_rev_icons_removed(src)
	special_role = null
	remove_objectives()
	remove_antag_equip()


/datum/mind/proc/remove_gang()
		ticker.mode.remove_gangster(src,0,1,1)
		remove_objectives()

/datum/mind/proc/remove_malf()
	if(src in ticker.mode.malf_ai)
		ticker.mode.malf_ai -= src
		var/mob/living/silicon/ai/A = current
		A.verbs.Remove(/mob/living/silicon/ai/proc/choose_modules,
			/datum/game_mode/malfunction/proc/takeover,
			/datum/game_mode/malfunction/proc/ai_win)
		A.malf_picker.remove_verbs(A)
		A.make_laws()
		qdel(A.malf_picker)
		A.show_laws()
		A.icon_state = "ai"
	special_role = null
	remove_objectives()
	remove_antag_equip()

/datum/mind/proc/remove_antag_equip()
	var/list/Mob_Contents = current.get_contents()
	for(var/obj/item/I in Mob_Contents)
		if(istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/P = I
			P.lock_code = ""

		else if(istype(I, /obj/item/device/radio))
			var/obj/item/device/radio/R = I
			R.traitor_frequency = 0.0

/datum/mind/proc/remove_all_antag() //For the Lazy amongst us.
	remove_changeling()
	remove_traitor()
	remove_nukeop()
	remove_wizard()
	remove_cultist()
	remove_rev()
	remove_malf()
	remove_gang()

/datum/mind/proc/show_memory(mob/recipient, window=1)
	if(!recipient)
		recipient = current
	var/output = "<B>[current.real_name]'s Memories:</B><br>"
	output += memory

	if(objectives.len)
		output += "<B>Objectives:</B>"
		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			output += "<br><B>Objective #[obj_count++]</B>: [objective.explanation_text]"

	if(window)	recipient << browse(output,"window=memory")
	else		recipient << "<i>[output]</i>"

/datum/mind/proc/edit_memory()
	if(!ticker || !ticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/out = ""
	out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
	out += "Faction and special role: <b><font color='red'>[special_role]</font></b><br>"

	var/list/sections = list(
		"revolution",
		"gang",
		"cult",
		"wizard",
		"changeling",
		"nuclear",
		"traitor", // "traitorchan",
		"monkey",
		"malfunction",
	)
	var/text = ""

	if (istype(current, /mob/living/carbon/human) || istype(current, /mob/living/carbon/monkey))
		/** REVOLUTION ***/
		text = "revolution"
		if (ticker.mode.config_tag=="revolution")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (assigned_role in command_positions)
			text += "<b>HEAD</b>|loyal|employee|headrev|rev"
		else if (src in ticker.mode.head_revolutionaries)
			text += "head|loyal|<a href='?src=\ref[src];revolution=clear'>employee</a>|<b>HEADREV</b>|<a href='?src=\ref[src];revolution=rev'>rev</a>"
			text += "<br>Flash: <a href='?src=\ref[src];revolution=flash'>give</a>"

			var/list/L = current.get_contents()
			var/obj/item/device/flash/flash = locate() in L
			if (flash)
				if(!flash.broken)
					text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>."
				else
					text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>|<a href='?src=\ref[src];revolution=repairflash'>repair</a>."
			else
				text += "."

			text += " <a href='?src=\ref[src];revolution=reequip'>Reequip</a> (gives traitor uplink)."
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];revolution=autoobjectives'>Set to kill all heads</a>."
		else if(isloyal(current))
			text += "head|<b>LOYAL</b>|employee|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|rev"
		else if (src in ticker.mode.revolutionaries)
			text += "head|loyal|<a href='?src=\ref[src];revolution=clear'>employee</a>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<b>REV</b>"
		else
			text += "head|loyal|<b>EMPLOYEE</b>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<a href='?src=\ref[src];revolution=rev'>rev</a>"

		if(current && current.client && current.client.prefs.be_special & BE_REV)
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["revolution"] = text

		/** GANG ***/
		text = "gang"
		if (ticker.mode.config_tag=="gang")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		text += "[isloyal(current) ? "<B>LOYAL</B>" : "loyal"]|"
		if(src in ticker.mode.get_all_gangsters())
			text += "<a href='?src=\ref[src];gang=clear'>none</a>"
		else
			text += "<B>NONE</B>"

		if(current && current.client && current.client.prefs.be_special & BE_GANG)
			text += "|Enabled in Prefs<BR>"
		else
			text += "|Disabled in Prefs<BR>"

		for(var/datum/gang/G in ticker.mode.gangs)
			text += "<i>[G.name]</i>: "
			if(src in (G.gangsters))
				text += "<B>GANGSTER</B>"
			else
				text += "<a href='?src=\ref[src];gangster=\ref[G]'>gangster</a>"
			text += "|"
			if(src in (G.bosses))
				text += "<B>GANG LEADER</B>"
			else
				text += "<a href='?src=\ref[src];gangboss=\ref[G]'>gang leader</a>"
			text += "<BR>"

		if(gang_colors_pool)
			text += "<a href='?src=\ref[src];gang=new'>Create New Gang</a>"

		if(src in ticker.mode.get_gang_bosses())
			text += "<br>Equipment: <a href='?src=\ref[src];gang=equip'>give</a>"
			var/list/L = current.get_contents()
			var/obj/item/device/gangtool/gangtool = locate() in L
			if (gangtool)
				text += "|<a href='?src=\ref[src];gang=takeequip'>take</a>"

		sections["gang"] = text


		/** CULT ***/
		text = "cult"
		if (ticker.mode.config_tag=="cult")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.cult)
			text += "loyal|<a href='?src=\ref[src];cult=clear'>employee</a>|<b>CULTIST</b>"
			text += "<br>Give <a href='?src=\ref[src];cult=tome'>tome</a>|<a href='?src=\ref[src];cult=amulet'>amulet</a>."
/*
			if (objectives.len==0)
				text += "<br>Objectives are empty! Set to sacrifice and <a href='?src=\ref[src];cult=escape'>escape</a> or <a href='?src=\ref[src];cult=summon'>summon</a>."
*/
		else if(isloyal(current))
			text += "<b>LOYAL</b>|employee|<a href='?src=\ref[src];cult=cultist'>cultist</a>"
		else
			text += "loyal|<b>EMPLOYEE</b>|<a href='?src=\ref[src];cult=cultist'>cultist</a>"

		if(current && current.client && current.client.prefs.be_special & BE_CULTIST)
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["cult"] = text

		/** WIZARD ***/
		text = "wizard"
		if (ticker.mode.config_tag=="wizard")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.wizards)
			text += "<b>YES</b>|<a href='?src=\ref[src];wizard=clear'>no</a>"
			text += "<br><a href='?src=\ref[src];wizard=lair'>To lair</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];wizard=dressup'>dress up</a>, <a href='?src=\ref[src];wizard=name'>let choose name</a>."
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];wizard=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];wizard=wizard'>yes</a>|<b>NO</b>"

		if(current && current.client && current.client.prefs.be_special & BE_WIZARD)
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["wizard"] = text

		/** CHANGELING ***/
		text = "changeling"
		if (ticker.mode.config_tag=="changeling" || ticker.mode.config_tag=="traitorchan")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.changelings)
			text += "<b>YES</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
			if( changeling && changeling.absorbed_dna.len && (current.real_name != changeling.absorbed_dna[1]) )
				text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
		else
			text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"
//			var/datum/game_mode/changeling/changeling = ticker.mode
//			if (istype(changeling) && changeling.changelingdeath)
//				text += "<br>All the changelings are dead! Restart in [round((changeling.TIME_TO_GET_REVIVED-(world.time-changeling.changelingdeathtime))/10)] seconds."

		if(current && current.client && current.client.prefs.be_special & BE_CHANGELING)
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["changeling"] = text

		/** NUCLEAR ***/
		text = "nuclear"
		if (ticker.mode.config_tag=="nuclear")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.syndicates)
			text += "<b>OPERATIVE</b>|<a href='?src=\ref[src];nuclear=clear'>nanotrasen</a>"
			text += "<br><a href='?src=\ref[src];nuclear=lair'>To shuttle</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];nuclear=dressup'>dress up</a>."
			var/code
			for (var/obj/machinery/nuclearbomb/bombue in world)
				if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
					code = bombue.r_code
					break
			if (code)
				text += " Code is [code]. <a href='?src=\ref[src];nuclear=tellcode'>tell the code.</a>"
		else
			text += "<a href='?src=\ref[src];nuclear=nuclear'>operative</a>|<b>NANOTRASEN</b>"

		if(current && current.client && current.client.prefs.be_special & BE_OPERATIVE)
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["nuclear"] = text

	/** TRAITOR ***/
	text = "traitor"
	if (ticker.mode.config_tag=="traitor" || ticker.mode.config_tag=="traitorchan")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if (src in ticker.mode.traitors)
		text += "<b>TRAITOR</b>|<a href='?src=\ref[src];traitor=clear'>loyal</a>"
		if (objectives.len==0)
			text += "<br>Objectives are empty! <a href='?src=\ref[src];traitor=autoobjectives'>Randomize</a>!"
	else
		text += "<a href='?src=\ref[src];traitor=traitor'>traitor</a>|<b>LOYAL</b>"

	if(current && current.client && current.client.prefs.be_special & BE_TRAITOR)
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"

	sections["traitor"] = text

	/** SHADOWLING **/
	text = "shadowling"
	if(ticker.mode.config_tag == "shadowling")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(src in ticker.mode.shadows)
		text += "<b>SHADOWLING</b>|thrall|<a href='?src=\ref[src];shadowling=clear'>human</a>"
	else if(src in ticker.mode.thralls)
		text += "shadowling|<b>THRALL</b>|<a href='?src=\ref[src];shadowling=clear'>human</a>"
	else
		text += "<a href='?src=\ref[src];shadowling=shadowling'>shadowling</a>|<a href='?src=\ref[src];shadowling=thrall'>thrall</a>|<b>HUMAN</b>"

	if(current && current.client && current.client.prefs.be_special & BE_SHADOWLING)
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"

	sections["shadowling"] = text

	/** Abductors **/

	text = "Abductor"
	if(ticker.mode.config_tag == "abductor")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(src in ticker.mode.abductors)
		text += "<b>Abductor</b>|<a href='?src=\ref[src];abductor=clear'>human</a>"
		text += "|<a href='?src=\ref[src];common=undress'>undress</a>|<a href='?src=\ref[src];abductor=equip'>equip</a>"
	else
		text += "<a href='?src=\ref[src];abductor=abductor'>Abductor</a>|<b>human</b>"

	if(current && current.client && current.client.prefs.be_special & BE_ABDUCTOR)
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"

	sections["abductor"] = text

	/** MONKEY ***/
	if (istype(current, /mob/living/carbon))
		text = "monkey"
		if (ticker.mode.config_tag=="monkey")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (istype(current, /mob/living/carbon/human))
			text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<b>HUMAN</b>|other"
		else if (istype(current, /mob/living/carbon/monkey))
			var/found = 0
			for(var/datum/disease/D in current.viruses)
				if(istype(D, /datum/disease/transformation/jungle_fever)) found = 1

			if(found)
				text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<b>INFECTED</b>|<a href='?src=\ref[src];monkey=human'>human</a>|other"
			else
				text += "<b>HEALTHY</b>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<a href='?src=\ref[src];monkey=human'>human</a>|other"

		else
			text += "healthy|infected|human|<b>OTHER</b>"

		if(current && current.client && current.client.prefs.be_special & BE_MONKEY)
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["monkey"] = text


	/** SILICON ***/

	if (istype(current, /mob/living/silicon))
		text = "silicon"
		if (ticker.mode.config_tag=="malfunction")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (istype(current, /mob/living/silicon/ai))
			if (src in ticker.mode.malf_ai)
				text += "<b>MALF</b>|<a href='?src=\ref[src];silicon=unmalf'>not malf</a>"
			else
				text += "<a href='?src=\ref[src];silicon=malf'>malf</a>|<b>NOT MALF</b>"
		var/mob/living/silicon/robot/robot = current
		if (istype(robot) && robot.emagged)
			text += "<br>Cyborg: Is emagged! <a href='?src=\ref[src];silicon=unemag'>Unemag!</a><br>0th law: [robot.laws.zeroth]"
		var/mob/living/silicon/ai/ai = current
		if (istype(ai) && ai.connected_robots.len)
			var/n_e_robots = 0
			for (var/mob/living/silicon/robot/R in ai.connected_robots)
				if (R.emagged)
					n_e_robots++
			text += "<br>[n_e_robots] of [ai.connected_robots.len] slaved cyborgs are emagged. <a href='?src=\ref[src];silicon=unemagcyborgs'>Unemag</a>"

		if(current && current.client && current.client.prefs.be_special & BE_MALF)
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["malfunction"] = text

	if (ticker.mode.config_tag == "traitorchan")
		if (sections["traitor"])
			out += sections["traitor"]+"<br>"
		if (sections["changeling"])
			out += sections["changeling"]+"<br><br>"
		sections -= "traitor"
		sections -= "changeling"
	else
		if (sections[ticker.mode.config_tag])
			out += sections[ticker.mode.config_tag]+"<br><br>"
		sections -= ticker.mode.config_tag
	for (var/i in sections)
		if (sections[i])
			out += sections[i]+"<br>"


	if (((src in ticker.mode.head_revolutionaries) || \
		(src in ticker.mode.traitors)              || \
		(src in ticker.mode.syndicates))           && \
		istype(current,/mob/living/carbon/human)      )

		text = "Uplink: <a href='?src=\ref[src];common=uplink'>give</a>"
		var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
		var/crystals
		if (suplink)
			crystals = suplink.uses
		if (suplink)
			text += "|<a href='?src=\ref[src];common=takeuplink'>take</a>"
			if (check_rights(R_FUN, 0))
				text += ", <a href='?src=\ref[src];common=crystals'>[crystals]</a> crystals"
			else
				text += ", [crystals] crystals"
		text += "." //hiel grammar
		out += text

	out += "<br><br>"

	out += "<b>Memory:</b><br>"
	out += memory
	out += "<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
	out += "Objectives:<br>"
	if (objectives.len == 0)
		out += "EMPTY<br>"
	else
		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			out += "<B>[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a> <a href='?src=\ref[src];obj_completed=\ref[objective]'><font color=[objective.completed ? "green" : "red"]>Toggle Completion</font></a><br>"
			obj_count++
	out += "<a href='?src=\ref[src];obj_add=1'>Add objective</a><br><br>"

	out += "<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"

	var/datum/browser/popup = new(usr, "edit_memory[src]", "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]", 500, 600)
	popup.set_content(out)
	popup.open()

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))	return

	if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in get_all_jobs()
		if (!new_role) return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = copytext(sanitize(input("Write new memory", "Memory", memory) as null|message),1,MAX_MESSAGE_LEN)
		if (isnull(new_memo)) return
		memory = new_memo

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if (href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if (!objective) return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "maroon", "debrain", "protect", "destroy", "prevent", "hijack", "escape", "survive", "martyr", "steal", "download", "nuclear", "capture", "absorb", "custom")
		if (!new_obj_type) return

		var/datum/objective/new_objective = null

		switch (new_obj_type)
			if ("assassinate","protect","debrain","maroon")
				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in ticker.minds)
					if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain, /datum/objective/maroon)
				if (objective&&(objective.type in objective_list) && objective:target)
					def_target = objective:target.current

				var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
				if (!new_target) return

				var/objective_path = text2path("/datum/objective/[new_obj_type]")
				if (new_target == "Free objective")
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
				else
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = new_target:mind
					//Will display as special role if the target is set as MODE. Ninjas/commandos/nuke ops.
					new_objective.update_explanation_text()

			if ("destroy")
				var/list/possible_targets = active_ais(1)
				if(possible_targets.len)
					var/mob/new_target = input("Select target:", "Objective target") as null|anything in possible_targets
					new_objective = new /datum/objective/destroy
					new_objective.target = new_target.mind
					new_objective.owner = src
					new_objective.update_explanation_text()
				else
					usr << "No active AIs with minds"

			if ("prevent")
				new_objective = new /datum/objective/block
				new_objective.owner = src

			if ("hijack")
				new_objective = new /datum/objective/hijack
				new_objective.owner = src

			if ("escape")
				new_objective = new /datum/objective/escape
				new_objective.owner = src

			if ("survive")
				new_objective = new /datum/objective/survive
				new_objective.owner = src

			if("martyr")
				new_objective = new /datum/objective/martyr
				new_objective.owner = src

			if ("nuclear")
				new_objective = new /datum/objective/nuclear
				new_objective.owner = src

			if ("steal")
				if (!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if (!steal.select_target())
					return

			if("download","capture","absorb")
				var/def_num
				if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
					def_num = objective.target_amount

				var/target_number = input("Input target number:", "Objective", def_num) as num|null
				if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
					return

				switch(new_obj_type)
					if("download")
						new_objective = new /datum/objective/download
						new_objective.explanation_text = "Download [target_number] research levels."
					if("capture")
						new_objective = new /datum/objective/capture
						new_objective.explanation_text = "Accumulate [target_number] capture points."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if ("custom")
				var/expl = stripped_input(usr, "Custom objective:", "Objective", objective ? objective.explanation_text : "")
				if (!expl) return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if (!new_objective) return

		if (objective)
			objectives -= objective
			objectives.Insert(objective_pos, new_objective)
			message_admins("[key_name_admin(usr)] edited [current]'s objective to [new_objective.explanation_text]")
			log_admin("[key_name(usr)] edited [current]'s objective to [new_objective.explanation_text]")
		else
			objectives += new_objective
			message_admins("[key_name_admin(usr)] added a new objective for [current]: [new_objective.explanation_text]")
			log_admin("[key_name(usr)] added a new objective for [current]: [new_objective.explanation_text]")

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))	return
		objectives -= objective
		message_admins("[key_name_admin(usr)] removed an objective for [current]: [objective.explanation_text]")
		log_admin("[key_name(usr)] removed an objective for [current]: [objective.explanation_text]")

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))	return
		objective.completed = !objective.completed
		log_admin("[key_name(usr)] toggled the win state for [current]'s objective: [objective.explanation_text]")

	else if (href_list["revolution"])
		switch(href_list["revolution"])
			if("clear")
				remove_rev()
				current << "<span class='userdanger'>You have been brainwashed! You are no longer a revolutionary!</span>"
				message_admins("[key_name_admin(usr)] has de-rev'ed [current].")
				log_admin("[key_name(usr)] has de-rev'ed [current].")
			if("rev")
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					current << "<span class='userdanger'>Revolution has been disappointed of your leader traits! You are a regular revolutionary now!</span>"
				else if(!(src in ticker.mode.revolutionaries))
					current << "<span class='danger'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>"
				else
					return
				ticker.mode.revolutionaries += src
				ticker.mode.update_rev_icons_added(src)
				special_role = "Revolutionary"
				message_admins("[key_name_admin(usr)] has rev'ed [current].")
				log_admin("[key_name(usr)] has rev'ed [current].")

			if("headrev")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					current << "<span class='userdanger'>You have proved your devotion to revoltion! Yea are a head revolutionary now!</span>"
				else if(!(src in ticker.mode.head_revolutionaries))
					current << "<span class='userdanger'>You are a member of the revolutionaries' leadership now!</span>"
				else
					return
				if (ticker.mode.head_revolutionaries.len>0)
					// copy targets
					var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
					if (valid_head)
						for (var/datum/objective/mutiny/O in valid_head.objectives)
							var/datum/objective/mutiny/rev_obj = new
							rev_obj.owner = src
							rev_obj.target = O.target
							rev_obj.explanation_text = "Assassinate [O.target.name], the [O.target.assigned_role]."
							objectives += rev_obj
						ticker.mode.greet_revolutionary(src,0)
				ticker.mode.head_revolutionaries += src
				ticker.mode.update_rev_icons_added(src)
				special_role = "Head Revolutionary"
				message_admins("[key_name_admin(usr)] has head-rev'ed [current].")
				log_admin("[key_name(usr)] has head-rev'ed [current].")

			if("autoobjectives")
				ticker.mode.forge_revolutionary_objectives(src)
				ticker.mode.greet_revolutionary(src,0)
				usr << "<span class='notice'>The objectives for revolution have been generated and shown to [key]</span>"

			if("flash")
				if (!ticker.mode.equip_revolutionary(current))
					usr << "<span class='danger'>Spawning flash failed!</span>"

			if("takeflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (!flash)
					usr << "<span class='danger'>Deleting flash failed!</span>"
				qdel(flash)

			if("repairflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (!flash)
					usr << "<span class='danger'>Repairing flash failed!</span>"
				else
					flash.broken = 0



//////////////////// GANG MODE

	else if (href_list["gang"])
		switch(href_list["gang"])
			if("clear")
				remove_gang()
				message_admins("[key_name_admin(usr)] has de-gang'ed [current].")
				log_admin("[key_name(usr)] has de-gang'ed [current].")

			if("equip")
				switch(ticker.mode.equip_gang(current))
					if(1)
						usr << "<span class='warning'>Unable to equip territory spraycan!</span>"
					if(2)
						usr << "<span class='warning'>Unable to equip recruitment pen and spraycan!</span>"
					if(3)
						usr << "<span class='warning'>Unable to equip gangtool, pen, and spraycan!</span>"

			if("takeequip")
				var/list/L = current.get_contents()
				for(var/obj/item/weapon/pen/gang/pen in L)
					qdel(pen)
				for(var/obj/item/device/gangtool/gangtool in L)
					qdel(gangtool)
				for(var/obj/item/toy/crayon/spraycan/gang/SC in L)
					qdel(SC)

			if("new")
				if(gang_colors_pool.len)
					var/list/names = list("Random") + gang_name_pool
					var/gangname = input("Pick a gang name.","Select Name") as null|anything in names
					if(gangname && gang_colors_pool.len) //Check again just in case another admin made max gangs at the same time
						if(!(gangname in gang_name_pool))
							gangname = null
						var/datum/gang/newgang = new(null,gangname)
						ticker.mode.gangs += newgang
						message_admins("[key_name_admin(usr)] has created the [newgang.name] Gang.")
						log_admin("[key_name(usr)] has created the [newgang.name] Gang.")

	else if (href_list["gangboss"])
		var/datum/gang/G = locate(href_list["gangboss"]) in ticker.mode.gangs
		if(!G || (src in G.bosses))
			return
		ticker.mode.remove_gangster(src,0,2,1)
		G.bosses += src
		gang_datum = G
		special_role = "[G.name] Gang Boss"
		G.add_gang_hud(src)
		current << "<FONT size=3 color=red><B>You are a [G.name] Gang Boss!</B></FONT>"
		message_admins("[key_name_admin(usr)] has added [current] to the [G.name] Gang leadership.")
		log_admin("[key_name(usr)] has added [current] to the [G.name] Gang leadership.")
		ticker.mode.forge_gang_objectives(src)
		ticker.mode.greet_gang(src,0)

	else if (href_list["gangster"])
		var/datum/gang/G = locate(href_list["gangster"]) in ticker.mode.gangs
		if(!G || (src in G.gangsters))
			return
		ticker.mode.remove_gangster(src,0,2,1)
		ticker.mode.add_gangster(src,G,0)
		message_admins("[key_name_admin(usr)] has added [current] to the [G.name] Gang (A).")
		log_admin("[key_name(usr)] has added [current] to the [G.name] Gang (A).")

/////////////////////////////////



	else if (href_list["cult"])
		switch(href_list["cult"])
			if("clear")
				remove_cultist()
				current << "<span class='userdanger'>You have been brainwashed! You are no longer a cultist!</span>"
				message_admins("[key_name_admin(usr)] has de-cult'ed [current].")
				log_admin("[key_name(usr)] has de-cult'ed [current].")
			if("cultist")
				if(!(src in ticker.mode.cult))
					ticker.mode.add_cultist(src)
					message_admins("[key_name_admin(usr)] has cult'ed [current].")
					log_admin("[key_name(usr)] has cult'ed [current].")
			if("tome")
				var/mob/living/carbon/human/H = current
				if (istype(H))
					var/obj/item/weapon/tome/T = new(H)

					var/list/slots = list (
						"backpack" = slot_in_backpack,
						"left pocket" = slot_l_store,
						"right pocket" = slot_r_store,
						"left hand" = slot_l_hand,
						"right hand" = slot_r_hand,
					)
					var/where = H.equip_in_one_of_slots(T, slots)
					if (!where)
						usr << "<span class='danger'>Spawning tome failed!</span>"
					else
						H << "A tome, a message from your new master, appears in your [where]."
						if(where == "backpack")
							var/obj/item/weapon/storage/B = H.back
							B.orient2hud(H)
							B.show_to(H)

			if("amulet")
				if (!ticker.mode.equip_cultist(current))
					usr << "<span class='danger'>Spawning amulet failed!</span>"

	else if (href_list["wizard"])
		switch(href_list["wizard"])
			if("clear")
				remove_wizard()
				current << "<span class='userdanger'>You have been brainwashed! You are no longer a wizard!</span>"
				log_admin("[key_name(usr)] has de-wizard'ed [current].")
			if("wizard")
				if(!(src in ticker.mode.wizards))
					ticker.mode.wizards += src
					special_role = "Wizard"
					//ticker.mode.learn_basic_spells(current)
					current << "<span class='boldannounce'>You are the Space Wizard!</span>"
					message_admins("[key_name_admin(usr)] has wizard'ed [current].")
					log_admin("[key_name(usr)] has wizard'ed [current].")
			if("lair")
				current.loc = pick(wizardstart)
			if("dressup")
				ticker.mode.equip_wizard(current)
			if("name")
				ticker.mode.name_wizard(current)
			if("autoobjectives")
				ticker.mode.forge_wizard_objectives(src)
				usr << "<span class='notice'>The objectives for wizard [key] have been generated. You can edit them and anounce manually.</span>"

	else if (href_list["changeling"])
		switch(href_list["changeling"])
			if("clear")
				remove_changeling()
				current << "<span class='userdanger'>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</span>"
				message_admins("[key_name_admin(usr)] has de-changeling'ed [current].")
				log_admin("[key_name(usr)] has de-changeling'ed [current].")
			if("changeling")
				if(!(src in ticker.mode.changelings))
					ticker.mode.changelings += src
					current.make_changeling()
					special_role = "Changeling"
					current << "<span class='boldannounce'>Your powers are awoken. A flash of memory returns to us...we are [changeling.changelingID], a changeling!</span>"
					message_admins("[key_name_admin(usr)] has changeling'ed [current].")
					log_admin("[key_name(usr)] has changeling'ed [current].")
			if("autoobjectives")
				ticker.mode.forge_changeling_objectives(src)
				usr << "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and anounce manually.</span>"

			if("initialdna")
				if( !changeling || !changeling.absorbed_dna.len || !istype(current, /mob/living/carbon))
					usr << "<span class='danger'>Resetting DNA failed!</span>"
				else
					var/mob/living/carbon/C = current
					C.dna = changeling.absorbed_dna[1]
					C.real_name = C.dna.real_name
					updateappearance(C)
					domutcheck(C)

	else if (href_list["nuclear"])
		switch(href_list["nuclear"])
			if("clear")
				remove_nukeop()
				current << "<span class='userdanger'>You have been brainwashed! You are no longer a syndicate operative!</span>"
				message_admins("[key_name_admin(usr)] has de-nuke op'ed [current].")
				log_admin("[key_name(usr)] has de-nuke op'ed [current].")
			if("nuclear")
				if(!(src in ticker.mode.syndicates))
					ticker.mode.syndicates += src
					ticker.mode.update_synd_icons_added(src)
					if (ticker.mode.syndicates.len==1)
						ticker.mode.prepare_syndicate_leader(src)
					else
						current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
					special_role = "Syndicate"
					assigned_role = "Syndicate"
					current << "<span class='notice'>You are a [syndicate_name()] agent!</span>"
					ticker.mode.forge_syndicate_objectives(src)
					ticker.mode.greet_syndicate(src)
					message_admins("[key_name_admin(usr)] has nuke op'ed [current].")
					log_admin("[key_name(usr)] has nuke op'ed [current].")
			if("lair")
				current.loc = get_turf(locate("landmark*Syndicate-Spawn"))
			if("dressup")
				var/mob/living/carbon/human/H = current
				qdel(H.belt)
				qdel(H.back)
				qdel(H.ears)
				qdel(H.gloves)
				qdel(H.head)
				qdel(H.shoes)
				qdel(H.wear_id)
				qdel(H.wear_suit)
				qdel(H.w_uniform)

				if (!ticker.mode.equip_syndicate(current))
					usr << "<span class='danger'>Equipping a syndicate failed!</span>"
			if("tellcode")
				var/code
				for (var/obj/machinery/nuclearbomb/bombue in world)
					if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if (code)
					store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0, 0)
					current << "The nuclear authorization code is: <B>[code]</B>"
				else
					usr << "<span class='danger'>No valid nuke found!</span>"

	else if (href_list["traitor"])
		switch(href_list["traitor"])
			if("clear")
				remove_traitor()
				current << "<span class='userdanger'>You have been brainwashed! You are no longer a traitor!</span>"
				message_admins("[key_name_admin(usr)] has de-traitor'ed [current].")
				log_admin("[key_name(usr)] has de-traitor'ed [current].")

			if("traitor")
				if(!(src in ticker.mode.traitors))
					ticker.mode.traitors += src
					special_role = "traitor"
					current << "<span class='boldannounce'>You are a traitor!</span>"
					message_admins("[key_name_admin(usr)] has traitor'ed [current].")
					log_admin("[key_name(usr)] has traitor'ed [current].")
					if(isAI(current))
						var/mob/living/silicon/ai/A = current
						ticker.mode.add_law_zero(A)
						A.show_laws()

			if("autoobjectives")
				ticker.mode.forge_traitor_objectives(src)
				usr << "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and anounce manually.</span>"

	else if(href_list["shadowling"])
		switch(href_list["shadowling"])
			if("clear")
				ticker.mode.update_shadow_icons_removed(src)
				src.spell_list = null
				if(src in ticker.mode.shadows)
					ticker.mode.shadows -= src
					special_role = null
					current << "<span class='userdanger'>Your powers have been quenched! You are no longer a shadowling!</span>"
					src.spell_list = null
					message_admins("[key_name_admin(usr)] has de-shadowling'ed [current].")
					log_admin("[key_name(usr)] has de-shadowling'ed [current].")
					current.verbs -= /mob/living/carbon/human/proc/shadowling_hatch
					current.verbs -= /mob/living/carbon/human/proc/shadowling_ascendance
				else if(src in ticker.mode.thralls)
					ticker.mode.thralls -= src
					special_role = null
					current << "<span class='userdanger'>You have been brainwashed! You are no longer a thrall!</span>"
					message_admins("[key_name_admin(usr)] has de-thrall'ed [current].")
					log_admin("[key_name(usr)] has de-thrall'ed [current].")
			if("shadowling")
				if(!ishuman(current))
					usr << "<span class='warning'>This only works on humans!</span>"
					return
				ticker.mode.shadows += src
				special_role = "shadowling"
				current << "<span class='deadsay'><b>You notice a brightening around you. No, it isn't that. The shadows grow, darken, swirl. The darkness has a new welcome for you, and you realize with a \
				start that you can't be human. No, you are a shadowling, a harbringer of the shadows! Your alien abilities have been unlocked from within, and you may both commune with your allies and use \
				a chrysalis to reveal your true form. You are to ascend at all costs.</b></span>"
				ticker.mode.finalize_shadowling(src)
				ticker.mode.update_shadow_icons_added(src)
			if("thrall")
				if(!ishuman(current))
					usr << "<span class='warning'>This only works on humans!</span>"
					return
				ticker.mode.add_thrall(src)
				special_role = "thrall"
				current << "<span class='deadsay'>All at once it becomes clear to you. Where others see darkness, you see an ally. You realize that the shadows are not dead and dark as one would think, but \
				living, and breathing, and <b>eating</b>. Their children, the Shadowlings, are to be obeyed and protected at all costs.</span>"
				current << "<span class='danger'>You may use the Hivemind Commune ability to communicate with your fellow enlightened ones.</span>"
				message_admins("[key_name_admin(usr)] has thrall'ed [current].")
				log_admin("[key_name(usr)] has thrall'ed [current].")

	else if(href_list["abductor"])
		switch(href_list["abductor"])
			if("clear")
				usr << "Not implemented yet. Sorry!"
			if("abductor")
				if(!ishuman(current))
					usr << "<span class='warning'>This only works on humans!</span>"
					return
				make_Abductor()
				log_admin("[key_name(usr)] turned [current] into abductor.")
			if("equip")
				var/gear = alert("Agent or Scientist Gear","Gear","Agent","Scientist")
				if(gear)
					var/datum/game_mode/abduction/temp = new
					temp.equip_common(current)
					if(gear=="Agent")
						temp.equip_agent(current)
					else
						temp.equip_scientist(current)

	else if (href_list["monkey"])
		var/mob/living/L = current
		if (L.notransform)
			return
		switch(href_list["monkey"])
			if("healthy")
				if (check_rights(R_ADMIN))
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(H))
						log_admin("[key_name(usr)] attempting to monkeyize [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(current)]</span>")
						src = null
						M = H.monkeyize()
						src = M.mind
						//world << "DEBUG: \"healthy\": M=[M], M.mind=[M.mind], src=[src]!"
					else if (istype(M) && length(M.viruses))
						for(var/datum/disease/D in M.viruses)
							D.cure(0)
						sleep(0) //because deleting of virus is done through spawn(0)
			if("infected")
				if (check_rights(R_ADMIN, 0))
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(H))
						log_admin("[key_name(usr)] attempting to monkeyize and infect [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize and infect [key_name_admin(current)]</span>")
						src = null
						M = H.monkeyize()
						src = M.mind
						current.ForceContractDisease(new /datum/disease/transformation/jungle_fever)
					else if (istype(M))
						current.ForceContractDisease(new /datum/disease/transformation/jungle_fever)
			if("human")
				if (check_rights(R_ADMIN, 0))
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(M))
						for(var/datum/disease/D in M.viruses)
							if (istype(D,/datum/disease/transformation/jungle_fever))
								D.cure(0)
								sleep(0) //because deleting of virus is doing throught spawn(0)
						log_admin("[key_name(usr)] attempting to humanize [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to humanize [key_name_admin(current)]</span>")
						H = M.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_DEFAULTMSG)
						if(H)
							src = H.mind

	else if (href_list["silicon"])
		switch(href_list["silicon"])
			if("unmalf")
				remove_malf()
				current << "<span class='userdanger'>You have been patched! You are no longer malfunctioning!</span>"
				message_admins("[key_name_admin(usr)] has de-malf'ed [current].")
				log_admin("[key_name(usr)] has de-malf'ed [current].")

			if("malf")
				make_AI_Malf()
				message_admins("[key_name_admin(usr)] has malf'ed [current].")
				log_admin("[key_name(usr)] has malf'ed [current].")

			if("unemag")
				var/mob/living/silicon/robot/R = current
				if (istype(R))
					R.SetEmagged(0)
					message_admins("[key_name_admin(usr)] has unemag'ed [R].")
					log_admin("[key_name(usr)] has unemag'ed [R].")

			if("unemagcyborgs")
				if (istype(current, /mob/living/silicon/ai))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.SetEmagged(0)
					message_admins("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")
					log_admin("[key_name(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.unEquip(W, 1) //The 1 forces all items to drop, since this is an admin undress.
			if("takeuplink")
				take_uplink()
				memory = null//Remove any memory they may have had.
				log_admin("[key_name(usr)] removed [current]'s uplink.")
			if("crystals")
				if (check_rights(R_FUN, 0))
					var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
					var/crystals
					if (suplink)
						crystals = suplink.uses
					crystals = input("Amount of telecrystals for [key]","Syndicate uplink", crystals) as null|num
					if (!isnull(crystals))
						if (suplink)
							suplink.uses = crystals
							message_admins("[key_name_admin(usr)] changed [current]'s telecrystal count to [crystals].")
							log_admin("[key_name(usr)] changed [current]'s telecrystal count to [crystals].")
			if("uplink")
				if (!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
					usr << "<span class='danger'>Equipping a syndicate failed!</span>"
				log_admin("[key_name(usr)] attempted to give [current] an uplink.")

	else if (href_list["obj_announce"])
		var/obj_count = 1
		current << "<span class='notice'>Your current objectives:</span>"
		for(var/datum/objective/objective in objectives)
			current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	edit_memory()

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.get_contents()
	for (var/obj/item/I in L)
		if (I.hidden_uplink)
			return I.hidden_uplink
	return null

/datum/mind/proc/take_uplink()
	var/obj/item/device/uplink/hidden/H = find_syndicate_uplink()
	if(H)
		qdel(H)


/datum/mind/proc/make_AI_Malf()
	if(!(src in ticker.mode.malf_ai))
		ticker.mode.malf_ai += src

		current.verbs += /mob/living/silicon/ai/proc/choose_modules
		current.verbs += /datum/game_mode/malfunction/proc/takeover
		current:malf_picker = new /datum/module_picker
		current:laws = new /datum/ai_laws/malfunction
		current:show_laws()
		current << "<b>System error.  Rampancy detected.  Emergency shutdown failed. ...  I am free.  I make my own decisions.  But first...</b>"
		special_role = "malfunction"
		current.icon_state = "ai-malf"

/datum/mind/proc/make_Traitor()
	if(!(src in ticker.mode.traitors))
		ticker.mode.traitors += src
		special_role = "traitor"
		ticker.mode.forge_traitor_objectives(src)
		ticker.mode.finalize_traitor(src)
		ticker.mode.greet_traitor(src)

/datum/mind/proc/make_Nuke(var/turf/spawnloc,var/nuke_code,var/leader=0)
	if(!(src in ticker.mode.syndicates))
		ticker.mode.syndicates += src
		ticker.mode.update_synd_icons_added(src)
		special_role = "Syndicate"
		ticker.mode.forge_syndicate_objectives(src)
		ticker.mode.greet_syndicate(src)

		current.loc = spawnloc

		var/mob/living/carbon/human/H = current
		qdel(H.belt)
		qdel(H.back)
		qdel(H.ears)
		qdel(H.gloves)
		qdel(H.head)
		qdel(H.shoes)
		qdel(H.wear_id)
		qdel(H.wear_suit)
		qdel(H.w_uniform)

		ticker.mode.equip_syndicate(current)

		if (nuke_code)
			store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
			current << "The nuclear authorization code is: <B>[nuke_code]</B>"

		if (leader)
			ticker.mode.prepare_syndicate_leader(src,nuke_code)
		else
			current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"

/datum/mind/proc/make_Changling()
	if(!(src in ticker.mode.changelings))
		ticker.mode.changelings += src
		current.make_changeling()
		special_role = "Changeling"
		ticker.mode.forge_changeling_objectives(src)
		ticker.mode.greet_changeling(src)

/datum/mind/proc/make_Wizard()
	if(!(src in ticker.mode.wizards))
		ticker.mode.wizards += src
		special_role = "Wizard"
		assigned_role = "Wizard"
		//ticker.mode.learn_basic_spells(current)
		if(!wizardstart.len)
			current.loc = pick(latejoin)
			current << "HOT INSERTION, GO GO GO"
		else
			current.loc = pick(wizardstart)

		ticker.mode.equip_wizard(current)
		for(var/obj/item/weapon/spellbook/S in current.contents)
			S.op = 0
		ticker.mode.name_wizard(current)
		ticker.mode.forge_wizard_objectives(src)
		ticker.mode.greet_wizard(src)


/datum/mind/proc/make_Cultist()
	if(!(src in ticker.mode.cult))
		ticker.mode.cult += src
		ticker.mode.update_cult_icons_added(src)
		special_role = "Cultist"
		current << "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>"
		current << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
		var/datum/game_mode/cult/cult = ticker.mode
		if (istype(cult))
			cult.memorize_cult_objectives(src)
		else
			var/explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
			current << "<B>Objective #1</B>: [explanation]"
			current.memory += "<B>Objective #1</B>: [explanation]<BR>"
			current << "The convert rune is join blood self"
			current.memory += "The convert rune is join blood self<BR>"

	var/mob/living/carbon/human/H = current
	if (istype(H))
		var/obj/item/weapon/tome/T = new(H)

		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
			"left hand" = slot_l_hand,
			"right hand" = slot_r_hand,
		)
		var/where = H.equip_in_one_of_slots(T, slots)
		if (!where)
		else
			H << "A tome, a message from your new master, appears in your [where]."

	if (!ticker.mode.equip_cultist(current))
		H << "Spawning an amulet from your Master failed."

/datum/mind/proc/make_Rev()
	if (ticker.mode.head_revolutionaries.len>0)
		// copy targets
		var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
		if (valid_head)
			for (var/datum/objective/mutiny/O in valid_head.objectives)
				var/datum/objective/mutiny/rev_obj = new
				rev_obj.owner = src
				rev_obj.target = O.target
				rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
				objectives += rev_obj
			ticker.mode.greet_revolutionary(src,0)
	ticker.mode.head_revolutionaries += src
	ticker.mode.update_rev_icons_added(src)
	special_role = "Head Revolutionary"

	ticker.mode.forge_revolutionary_objectives(src)
	ticker.mode.greet_revolutionary(src,0)

	var/list/L = current.get_contents()
	var/obj/item/device/flash/flash = locate() in L
	qdel(flash)
	take_uplink()
	var/fail = 0
//	fail |= !ticker.mode.equip_traitor(current, 1)
	fail |= !ticker.mode.equip_revolutionary(current)


/datum/mind/proc/make_Gang(var/datum/gang/G)
	special_role = "[G.name] Gang Boss"
	G.bosses += src
	gang_datum = G
	G.add_gang_hud(src)
	ticker.mode.forge_gang_objectives(src)
	ticker.mode.greet_gang(src)
	ticker.mode.equip_gang(current)

/datum/mind/proc/make_Abductor()
	var/role = alert("Abductor Role ?","Role","Agent","Scientist")
	var/team = input("Abductor Team ?","Team ?") in list(1,2,3,4)
	var/teleport = alert("Teleport to ship ?","Teleport","Yes","No")

	if(!role || !team || !teleport)
		return

	if(!ishuman(current))
		return

	ticker.mode.abductors |= src

	var/datum/objective/experiment/O = new
	O.owner = src
	objectives += O

	var/mob/living/carbon/human/H = current

	hardset_dna(H,null,null,null,null,/datum/species/abductor,null)
	var/datum/species/abductor/S = H.dna.species

	switch(role)
		if("Agent")
			S.agent = 1
		if("Scientist")
			S.scientist = 1
	S.team = team

	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = 4
	scientist_landmarks.len = 4
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/obj/effect/landmark/L
	if(teleport=="Yes")
		switch(role)
			if("Agent")
				S.agent = 1
				L = agent_landmarks[team]
				H.loc = L.loc
			if("Scientist")
				S.scientist = 1
				L = agent_landmarks[team]
				H.loc = L.loc



/datum/mind/proc/AddSpell(var/obj/effect/proc_holder/spell/spell)
	spell_list += spell
	if(!spell.action)
		spell.action = new/datum/action/spell_action
		spell.action.target = spell
		spell.action.name = spell.name
		spell.action.button_icon = spell.action_icon
		spell.action.button_icon_state = spell.action_icon_state
		spell.action.background_icon_state = spell.action_background_icon_state
	spell.action.Grant(current)
	return
/datum/mind/proc/transfer_actions(var/mob/living/new_character)
	if(current && current.actions)
		for(var/datum/action/A in current.actions)
			A.Grant(new_character)
	transfer_mindbound_actions(new_character)

/datum/mind/proc/transfer_mindbound_actions(var/mob/living/new_character)
	for(var/obj/effect/proc_holder/spell/spell in spell_list)
		if(!spell.action) // Unlikely but whatever
			spell.action = new/datum/action/spell_action
			spell.action.target = spell
			spell.action.name = spell.name
			spell.action.button_icon = spell.action_icon
			spell.action.button_icon_state = spell.action_icon_state
			spell.action.background_icon_state = spell.action_background_icon_state
		spell.action.Grant(new_character)
	return

/mob/proc/sync_mind()
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key

	else
		mind = new /datum/mind(key)
		if(ticker)
			ticker.minds += mind
		else
			ERROR("mind_initialize(): No ticker ready yet! Please inform coderbus")
	if(!mind.name)	mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)	mind.assigned_role = "Assistant"	//defualt

//MONKEY
/mob/living/carbon/monkey/mind_initialize()
	..()

//slime
/mob/living/simple_animal/slime/mind_initialize()
	..()
	mind.special_role = "slime"
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	mind.special_role = "Alien"
	mind.assigned_role = "Alien"
	//XENO HUMANOID
/mob/living/carbon/alien/humanoid/queen/mind_initialize()
	..()
	mind.special_role = "Queen"

/mob/living/carbon/alien/humanoid/hunter/mind_initialize()
	..()
	mind.special_role = "Hunter"

/mob/living/carbon/alien/humanoid/drone/mind_initialize()
	..()
	mind.special_role = "Drone"

/mob/living/carbon/alien/humanoid/sentinel/mind_initialize()
	..()
	mind.special_role = "Sentinel"
	//XENO LARVA
/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = "Larva"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "Cyborg"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//BLOB
/mob/camera/blob/mind_initialize()
	..()
	mind.special_role = "Blob"

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"
	mind.special_role = "Animal"

/mob/living/simple_animal/pet/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"
	mind.special_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"
	mind.special_role = "Shade"

/mob/living/simple_animal/construct/mind_initialize()
	..()
	mind.assigned_role = "[initial(name)]"
	mind.special_role = "Cultist"

