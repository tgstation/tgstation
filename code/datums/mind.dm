<<<<<<< HEAD
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
	var/attack_log

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
	var/linglink

	var/miming = 0 // Mime's vow of silence
	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/datum/gang/gang_datum //Which gang this mind belongs to, if any
	var/datum/devilinfo/devilinfo //Information about the devil, if any.
	var/damnation_type = 0
	var/datum/mind/soulOwner //who owns the soul.  Under normal circumstances, this will point to src

	var/mob/living/enslaved_to //If this mind's master is another mob (i.e. adamantine golems)

/datum/mind/New(var/key)
	src.key = key
	soulOwner = src


/datum/mind/proc/transfer_to(mob/new_character, var/force_key_move = 0)
	if(current)	// remove ourself from our old body's mind variable
		current.mind = null
		SStgui.on_transfer(current, new_character)

	if(key)
		if(new_character.key != key)					//if we're transfering into a body with a key associated which is not ours
			new_character.ghostize(1)						//we'll need to ghostize so that key isn't mobless.
	else
		key = new_character.key

	if(new_character.mind)								//disassociate any mind currently in our new body's mind variable
		new_character.mind.current = null

	var/datum/atom_hud/antag/hud_to_transfer = antag_hud//we need this because leave_hud() will clear this list
	leave_all_huds()									//leave all the huds in the old body, so it won't get huds if somebody else enters it
	current = new_character								//associate ourself with our new body
	new_character.mind = src							//and associate our new body with ourself
	transfer_antag_huds(hud_to_transfer)				//inherit the antag HUD
	transfer_actions(new_character)

	if(active || force_key_move)
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
	ticker.mode.update_changeling_icons_removed(src)

/datum/mind/proc/remove_traitor()
	if(src in ticker.mode.traitors)
		ticker.mode.traitors -= src
		if(isAI(current))
			var/mob/living/silicon/ai/A = current
			A.set_zeroth_law("")
			A.show_laws()
			A.verbs -= /mob/living/silicon/ai/proc/choose_modules
			A.malf_picker.remove_verbs(A)
			qdel(A.malf_picker)
	special_role = null
	remove_antag_equip()
	ticker.mode.update_traitor_icons_removed(src)

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
		ticker.mode.remove_cultist(src, 0, 0)
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

/datum/mind/proc/remove_hog_follower_prophet()
	ticker.mode.red_deity_followers -= src
	ticker.mode.red_deity_prophets -= src
	ticker.mode.blue_deity_prophets -= src
	ticker.mode.blue_deity_followers -= src
	ticker.mode.update_hog_icons_removed(src, "red")
	ticker.mode.update_hog_icons_removed(src, "blue")



/datum/mind/proc/remove_antag_equip()
	var/list/Mob_Contents = current.get_contents()
	for(var/obj/item/I in Mob_Contents)
		if(istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/P = I
			P.lock_code = ""

		else if(istype(I, /obj/item/device/radio))
			var/obj/item/device/radio/R = I
			R.traitor_frequency = 0

/datum/mind/proc/remove_all_antag() //For the Lazy amongst us.
	remove_changeling()
	remove_traitor()
	remove_nukeop()
	remove_wizard()
	remove_cultist()
	remove_rev()
	remove_gang()
	ticker.mode.update_changeling_icons_removed(src)
	ticker.mode.update_traitor_icons_removed(src)
	ticker.mode.update_wiz_icons_removed(src)
	ticker.mode.update_cult_icons_removed(src)
	ticker.mode.update_rev_icons_removed(src)
	gang_datum.remove_gang_hud(src)


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

	if(window)
		recipient << browse(output,"window=memory")
	else
		recipient << "<i>[output]</i>"

/datum/mind/proc/edit_memory()
	if(!ticker || !ticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
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
		"clockcult"
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
			var/obj/item/device/assembly/flash/flash = locate() in L
			if (flash)
				if(!flash.crit_fail)
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

		if(current && current.client && (ROLE_REV in current.client.prefs.be_special))
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

		if(current && current.client && (ROLE_GANG in current.client.prefs.be_special))
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
				text += "|Equipment: <a href='?src=\ref[src];gang=equip'>give</a>"
				var/list/L = current.get_contents()
				var/obj/item/device/gangtool/gangtool = locate() in L
				if (gangtool)
					text += "|<a href='?src=\ref[src];gang=takeequip'>take</a>"

			else
				text += "<a href='?src=\ref[src];gangboss=\ref[G]'>gang leader</a>"
			text += "<BR>"

		if(gang_colors_pool.len)
			text += "<a href='?src=\ref[src];gang=new'>Create New Gang</a>"

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

		if(current && current.client && (ROLE_CULTIST in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["cult"] = text

		/** CLOCKWORK CULT **/
		text = "clockwork cult"
		if(ticker.mode.config_tag == "clockwork cult")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in ticker.mode.servants_of_ratvar)
			text += "loyal|<a href='?src=\ref[src];clockcult=clear'>employee</a>|<b>SERVANT</b>"
			text += "<br><a href='?src=\ref[src];clockcult=slab'>Give slab</a>"
		else if(isloyal(current))
			text += "<b>LOYAL</b>|employee|<a href='?src=\ref[src];clockcult=servant'>servant</a>"
		else
			text += "loyal|<b>EMPLOYEE</b>|<a href='?src=\ref[src];clockcult=servant'>servant</a>"

		if(current && current.client && (ROLE_SERVANT_OF_RATVAR in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["clockcult"] = text

		/** WIZARD ***/
		text = "wizard"
		if (ticker.mode.config_tag=="wizard")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if ((src in ticker.mode.wizards) || (src in ticker.mode.apprentices))
			text += "<b>YES</b>|<a href='?src=\ref[src];wizard=clear'>no</a>"
			text += "<br><a href='?src=\ref[src];wizard=lair'>To lair</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];wizard=dressup'>dress up</a>, <a href='?src=\ref[src];wizard=name'>let choose name</a>."
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];wizard=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];wizard=wizard'>yes</a>|<b>NO</b>"

		if(current && current.client && (ROLE_WIZARD in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["wizard"] = text

		/** CHANGELING ***/
		text = "changeling"
		if (ticker.mode.config_tag=="changeling" || ticker.mode.config_tag=="traitorchan")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if ((src in ticker.mode.changelings) && special_role)
			text += "<b>YES</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
			if(changeling && changeling.stored_profiles.len && (current.real_name != changeling.first_prof.name) )
				text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
		else if(src in ticker.mode.changelings) //Station Aligned Changeling
			text += "<b>YES (but not an antag)</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
			if(changeling && changeling.stored_profiles.len && (current.real_name != changeling.first_prof.name) )
				text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
		else
			text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"
//			var/datum/game_mode/changeling/changeling = ticker.mode
//			if (istype(changeling) && changeling.changelingdeath)
//				text += "<br>All the changelings are dead! Restart in [round((changeling.TIME_TO_GET_REVIVED-(world.time-changeling.changelingdeathtime))/10)] seconds."

		if(current && current.client && (ROLE_CHANGELING in current.client.prefs.be_special))
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
			for (var/obj/machinery/nuclearbomb/bombue in machines)
				if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
					code = bombue.r_code
					break
			if (code)
				text += " Code is [code]. <a href='?src=\ref[src];nuclear=tellcode'>tell the code.</a>"
		else
			text += "<a href='?src=\ref[src];nuclear=nuclear'>operative</a>|<b>NANOTRASEN</b>"

		if(current && current.client && (ROLE_OPERATIVE in current.client.prefs.be_special))
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

	if(current && current.client && (ROLE_TRAITOR in current.client.prefs.be_special))
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"

	sections["traitor"] = text

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

	if(current && current.client && (ROLE_ABDUCTOR in current.client.prefs.be_special))
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"

	sections["abductor"] = text

	/** HAND OF GOD **/
	text = "hand of god"
	if(ticker.mode.config_tag == "handofgod")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if (src in ticker.mode.red_deities)
		text += "<b>RED GOD</b>|<a href='?src=\ref[src];handofgod=red prophet'>red prophet</a>|<a href='?src=\ref[src];handofgod=red follower'>red follower</a>|<a href='?src=\ref[src];handofgod=clear'>employee</a>|<a href='?src=\ref[src];handofgod=blue god'>blue god</a>|<a href='?src=\ref[src];handofgod=blue prophet'>blue prophet</a>|<a href='?src=\ref[src];handofgod=blue follower'>blue follower</a>"
	else if(src in ticker.mode.red_deity_prophets)
		text += "<a href='?src=\ref[src];handofgod=red god'>red god</a>|<b>RED PROPHET</b>|<a href='?src=\ref[src];handofgod=red follower'>red follower</a>|<a href='?src=\ref[src];handofgod=clear'>employee</a>|<a href='?src=\ref[src];handofgod=blue god'>blue god</a>|<a href='?src=\ref[src];handofgod=blue prophet'>blue prophet</a>|<a href='?src=\ref[src];handofgod=blue follower'>blue follower</a>"
	else if (src in ticker.mode.red_deity_followers)
		text += "<a href='?src=\ref[src];handofgod=red god'>red god</a>|<a href='?src=\ref[src];handofgod=red prophet'>red prophet</a>|<b>RED FOLLOWER</b>|<a href='?src=\ref[src];handofgod=clear'>employee</a>|<a href='?src=\ref[src];handofgod=blue god'>blue god</a>|<a href='?src=\ref[src];handofgod=blue prophet'>blue prophet</a>|<a href='?src=\ref[src];handofgod=blue follower'>blue follower</a>"
	else if (src in ticker.mode.blue_deities)
		text += "<a href='?src=\ref[src];handofgod=red god'>red god</a>|<a href='?src=\ref[src];handofgod=red prophet'>red prophet</a>|<a href='?src=\ref[src];handofgod=red follower'>red follower</a>|<a href='?src=\ref[src];handofgod=clear'>employee</a>|<b>BLUE GOD</b>|<a href='?src=\ref[src];handofgod=blue prophet'>blue prophet</a>|<a href='?src=\ref[src];handofgod=blue follower'>blue follower</a>"
	else if (src in ticker.mode.blue_deity_prophets)
		text += "<a href='?src=\ref[src];handofgod=red god'>red god</a>|<a href='?src=\ref[src];handofgod=red prophet'>red prophet</a>|<a href='?src=\ref[src];handofgod=red follower'>red follower</a>|<a href='?src=\ref[src];handofgod=clear'>employee</a>|<a href='?src=\ref[src];handofgod=blue god'>blue god</a>|<b>BLUE PROPHET</b>|<a href='?src=\ref[src];handofgod=blue follower'>blue follower</a>"
	else if (src in ticker.mode.blue_deity_followers)
		text += "<a href='?src=\ref[src];handofgod=red god'>red god</a>|<a href='?src=\ref[src];handofgod=red prophet'>red prophet</a>|<a href='?src=\ref[src];handofgod=red follower'>red follower</a>|<a href='?src=\ref[src];handofgod=clear'>employee</a>|<a href='?src=\ref[src];handofgod=blue god'>blue god</a>|<a href='?src=\ref[src];handofgod=blue prophet'>blue prophet</a>|<b>BLUE FOLLOWER</b>"
	else
		text += "<a href='?src=\ref[src];handofgod=red god'>red god</a>|<a href='?src=\ref[src];handofgod=red prophet'>red prophet</a>|<a href='?src=\ref[src];handofgod=red follower'>red follower</a>|<B>EMPLOYEE</b>|<a href='?src=\ref[src];handofgod=blue god'>blue god</a>|<a href='?src=\ref[src];handofgod=blue prophet'>blue prophet</a>|<a href='?src=\ref[src];handofgod=blue follower'>blue follower</a>"

	if(current && current.client && (ROLE_HOG_GOD in current.client.prefs.be_special))
		text += "|HOG God Enabled in Prefs"
	else
		text += "|HOG God Disabled in Prefs"

	if(current && current.client && (ROLE_HOG_CULTIST in current.client.prefs.be_special))
		text += "|HOG Cultist Enabled in Prefs"
	else
		text += "|HOG Disabled in Prefs"

	sections["follower"] = text

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

		if(current && current.client && (ROLE_MONKEY in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["monkey"] = text

	/** devil ***/
	text = "devil"
	if(ticker.mode.config_tag == "devil")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(src in ticker.mode.devils)
		text += "<b>DEVIL</b>|sintouched|<a href='?src=\ref[src];devil=clear'>human</a>"
	else if(src in ticker.mode.sintouched)
		text += "devil|<b>SINTOUCHED</b>|<a href='?src=\ref[src];devil=clear'>human</a>"
	else
		text += "<a href='?src=\ref[src];devil=devil'>devil</a>|<a href='?src=\ref[src];devil=sintouched'>sintouched</a>|<b>HUMAN</b>"

	if(current && current.client && (ROLE_DEVIL in current.client.prefs.be_special))
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"
	sections["devil"] = text


	/** SILICON ***/

	if (istype(current, /mob/living/silicon))
		text = "silicon"
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
		var/obj/item/device/uplink/U = find_syndicate_uplink()
		if(U)
			text += "|<a href='?src=\ref[src];common=takeuplink'>take</a>"
			if (check_rights(R_FUN, 0))
				text += ", <a href='?src=\ref[src];common=crystals'>[U.telecrystals]</a> TC"
			else
				text += ", [U.telecrystals] TC"
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

	usr << browse(out, "window=edit_memory[src];size=500x600")


/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in get_all_jobs()
		if (!new_role)
			return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = copytext(sanitize(input("Write new memory", "Memory", memory) as null|message),1,MAX_MESSAGE_LEN)
		if (isnull(new_memo))
			return
		memory = new_memo

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if (href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if (!objective)
				return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "maroon", "debrain", "protect", "destroy", "prevent", "hijack", "escape", "survive", "martyr", "steal", "download", "nuclear", "capture", "absorb", "custom","follower block (HOG)","build (HOG)","deicide (HOG)", "follower escape (HOG)", "sacrifice prophet (HOG)")
		if (!new_obj_type)
			return

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
				if (!new_target)
					return

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
						new_objective.explanation_text = "Capture [target_number] lifeforms with an energy net. Live, rare specimens are worth more."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if("follower block (HOG)")
				new_objective = new /datum/objective/follower_block
				new_objective.owner = src
			if("build (HOG)")
				new_objective = new /datum/objective/build
				new_objective.owner = src
			if("deicide (HOG)")
				new_objective = new /datum/objective/deicide
				new_objective.owner = src
			if("follower escape (HOG)")
				new_objective = new /datum/objective/escape_followers
				new_objective.owner = src
			if("sacrifice prophet (HOG)")
				new_objective = new /datum/objective/sacrifice_prophet
				new_objective.owner = src

			if ("custom")
				var/expl = stripped_input(usr, "Custom objective:", "Objective", objective ? objective.explanation_text : "")
				if (!expl)
					return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if (!new_objective)
			return

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
		if(!istype(objective))
			return
		objectives -= objective
		message_admins("[key_name_admin(usr)] removed an objective for [current]: [objective.explanation_text]")
		log_admin("[key_name(usr)] removed an objective for [current]: [objective.explanation_text]")

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed
		log_admin("[key_name(usr)] toggled the win state for [current]'s objective: [objective.explanation_text]")

	else if (href_list["handofgod"])
		switch(href_list["handofgod"])
			if("clear") //wipe handofgod status
				if((src in ticker.mode.red_deity_followers) || (src in ticker.mode.blue_deity_followers) || (src in ticker.mode.red_deity_prophets) || (src in ticker.mode.blue_deity_prophets))
					remove_hog_follower_prophet()
					current << "<span class='danger'><B>You have been brainwashed... again! Your faith is no more!</B></span>"
					message_admins("[key_name_admin(usr)] has de-hand of god'ed [current].")
					log_admin("[key_name(usr)] has de-hand of god'ed [current].")

			if("red follower")
				make_Handofgod_follower("red")
				message_admins("[key_name_admin(usr)] has red follower'ed [current].")
				log_admin("[key_name(usr)] has red follower'ed [current].")

			if("red prophet")
				make_Handofgod_prophet("red")
				message_admins("[key_name_admin(usr)] has red prophet'ed [current].")
				log_admin("[key_name(usr)] has red prophet'ed [current].")

			if("blue follower")
				make_Handofgod_follower("blue")
				message_admins("[key_name_admin(usr)] has blue follower'ed [current].")
				log_admin("[key_name(usr)] has blue follower'ed [current].")

			if("blue prophet")
				make_Handofgod_prophet("blue")
				message_admins("[key_name_admin(usr)] has blue prophet'ed [current].")
				log_admin("[key_name(usr)] has blue prophet'ed [current].")

			if("red god")
				make_Handofgod_god("red")
				message_admins("[key_name_admin(usr)] has red god'ed [current].")
				log_admin("[key_name(usr)] has red god'ed [current].")

			if("blue god")
				make_Handofgod_god("blue")
				message_admins("[key_name_admin(usr)] has blue god'ed [current].")
				log_admin("[key_name(usr)] has blue god'ed [current].")


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
				var/obj/item/device/assembly/flash/flash = locate() in L
				if (!flash)
					usr << "<span class='danger'>Deleting flash failed!</span>"
				qdel(flash)

			if("repairflash")
				var/list/L = current.get_contents()
				var/obj/item/device/assembly/flash/flash = locate() in L
				if (!flash)
					usr << "<span class='danger'>Repairing flash failed!</span>"
				else
					flash.crit_fail = 0
					flash.update_icon()



//////////////////// GANG MODE

	else if (href_list["gang"])
		switch(href_list["gang"])
			if("clear")
				remove_gang()
				message_admins("[key_name_admin(usr)] has de-gang'ed [current].")
				log_admin("[key_name(usr)] has de-gang'ed [current].")

			if("equip")
				switch(ticker.mode.equip_gang(current,gang_datum))
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
				message_admins("[key_name_admin(usr)] has de-cult'ed [current].")
				log_admin("[key_name(usr)] has de-cult'ed [current].")
			if("cultist")
				if(!(src in ticker.mode.cult))
					ticker.mode.add_cultist(src, 0)
					message_admins("[key_name_admin(usr)] has cult'ed [current].")
					log_admin("[key_name(usr)] has cult'ed [current].")
			if("tome")
				if (!ticker.mode.equip_cultist(current,1))
					usr << "<span class='danger'>Spawning tome failed!</span>"

			if("amulet")
				if (!ticker.mode.equip_cultist(current))
					usr << "<span class='danger'>Spawning amulet failed!</span>"

	else if(href_list["clockcult"])
		switch(href_list["clockcult"])
			if("clear")
				remove_servant_of_ratvar(current, TRUE)
				message_admins("[key_name_admin(usr)] has removed clockwork servant status from [current].")
				log_admin("[key_name(usr)] has removed clockwork servant status from [current].")
			if("servant")
				if(!is_servant_of_ratvar(current))
					add_servant_of_ratvar(current, TRUE)
					message_admins("[key_name_admin(usr)] has made [current] into a servant of Ratvar.")
					log_admin("[key_name(usr)] has made [current] into a servant of Ratvar.")
			if("slab")
				if(!ticker.mode.equip_servant(current))
					usr << "<span class='warning'>Failed to outfit [current] with a slab!</span>"
				else
					usr << "<span class='notice'>Successfully gave [current] a clockwork slab!</span>"

	else if (href_list["wizard"])
		switch(href_list["wizard"])
			if("clear")
				remove_wizard()
				current << "<span class='userdanger'>You have been brainwashed! You are no longer a wizard!</span>"
				log_admin("[key_name(usr)] has de-wizard'ed [current].")
				ticker.mode.update_wiz_icons_removed(src)
			if("wizard")
				if(!(src in ticker.mode.wizards))
					ticker.mode.wizards += src
					special_role = "Wizard"
					//ticker.mode.learn_basic_spells(current)
					current << "<span class='boldannounce'>You are the Space Wizard!</span>"
					message_admins("[key_name_admin(usr)] has wizard'ed [current].")
					log_admin("[key_name(usr)] has wizard'ed [current].")
					ticker.mode.update_wiz_icons_added(src)
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
					ticker.mode.update_changeling_icons_added(src)
			if("autoobjectives")
				ticker.mode.forge_changeling_objectives(src)
				usr << "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and anounce manually.</span>"

			if("initialdna")
				if( !changeling || !changeling.stored_profiles.len || !istype(current, /mob/living/carbon))
					usr << "<span class='danger'>Resetting DNA failed!</span>"
				else
					var/mob/living/carbon/C = current
					changeling.first_prof.dna.transfer_identity(C, transfer_SE=1)
					C.real_name = changeling.first_prof.name
					C.updateappearance(mutcolor_update=1)
					C.domutcheck()

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
				for (var/obj/machinery/nuclearbomb/bombue in machines)
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
				ticker.mode.update_traitor_icons_removed(src)

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
					ticker.mode.update_traitor_icons_added(src)

			if("autoobjectives")
				ticker.mode.forge_traitor_objectives(src)
				usr << "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and anounce manually.</span>"

	else if(href_list["devil"])
		switch(href_list["devil"])
			if("clear")
				if(src in ticker.mode.devils)
					if(istype(current,/mob/living/carbon/true_devil/))
						usr << "<span class='warning'>This cannot be used on true or arch-devils.</span>"
					else
						ticker.mode.devils -= src
						special_role = null
						current << "<span class='userdanger'>Your infernal link has been severed! You are no longer a devil!</span>"
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/infernal_jaunt)
						RemoveSpell(/obj/effect/proc_holder/spell/fireball/hellish)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/summon_contract)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/summon_pitchfork)
						message_admins("[key_name_admin(usr)] has de-devil'ed [current].")
						devilinfo = null
						log_admin("[key_name(usr)] has de-devil'ed [current].")
				else if(src in ticker.mode.sintouched)
					ticker.mode.sintouched -= src
					message_admins("[key_name_admin(usr)] has de-sintouch'ed [current].")
					log_admin("[key_name(usr)] has de-sintouch'ed [current].")
			if("devil")
				if(!ishuman(current))
					usr << "<span class='warning'>This only works on humans!</span>"
					return
				ticker.mode.devils += src
				special_role = "devil"
				ticker.mode.finalize_devil(src)
				announceDevilLaws()
			if("sintouched")
				if(ishuman(current))
					ticker.mode.sintouched += src
					var/mob/living/carbon/human/H = current
					H.influenceSin()
					message_admins("[key_name_admin(usr)] has sintouch'ed [current].")
				else
					usr << "<span class='warning'>This only works on humans!</span>"
					return

	else if(href_list["abductor"])
		switch(href_list["abductor"])
			if("clear")
				usr << "Not implemented yet. Sorry!"
				//ticker.mode.update_abductor_icons_removed(src)
			if("abductor")
				if(!ishuman(current))
					usr << "<span class='warning'>This only works on humans!</span>"
					return
				make_Abductor()
				log_admin("[key_name(usr)] turned [current] into abductor.")
				ticker.mode.update_abductor_icons_added(src)
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
						H = M.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_DEFAULTMSG)
						if(H)
							src = H.mind

	else if (href_list["silicon"])
		switch(href_list["silicon"])
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
				if(check_rights(R_FUN, 0))
					var/obj/item/device/uplink/U = find_syndicate_uplink()
					if(U)
						var/crystals = input("Amount of telecrystals for [key]","Syndicate uplink", U.telecrystals) as null|num
						if(!isnull(crystals))
							U.telecrystals = crystals
							message_admins("[key_name_admin(usr)] changed [current]'s telecrystal count to [crystals].")
							log_admin("[key_name(usr)] changed [current]'s telecrystal count to [crystals].")
			if("uplink")
				if(!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
					usr << "<span class='danger'>Equipping a syndicate failed!</span>"
				log_admin("[key_name(usr)] attempted to give [current] an uplink.")

	else if (href_list["obj_announce"])
		announce_objectives()

	edit_memory()

/datum/mind/proc/announce_objectives()
	var/obj_count = 1
	current << "<span class='notice'>Your current objectives:</span>"
	for(var/objective in objectives)
		var/datum/objective/O = objective
		current << "<B>Objective #[obj_count]</B>: [O.explanation_text]"
		obj_count++

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.get_contents()
	for (var/obj/item/I in L)
		if (I.hidden_uplink)
			return I.hidden_uplink
	return null

/datum/mind/proc/take_uplink()
	var/obj/item/device/uplink/H = find_syndicate_uplink()
	if(H)
		qdel(H)

/datum/mind/proc/make_Traitor()
	if(!(src in ticker.mode.traitors))
		ticker.mode.traitors += src
		special_role = "traitor"
		ticker.mode.forge_traitor_objectives(src)
		ticker.mode.finalize_traitor(src)
		ticker.mode.greet_traitor(src)

/datum/mind/proc/make_Nuke(turf/spawnloc,nuke_code,leader=0, telecrystals = TRUE)
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

		ticker.mode.equip_syndicate(current, telecrystals)

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
		ticker.mode.update_changeling_icons_added(src)

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
		ticker.mode.add_cultist(src,FALSE)
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
	var/obj/item/device/assembly/flash/flash = locate() in L
	qdel(flash)
	take_uplink()
	var/fail = 0
//	fail |= !ticker.mode.equip_traitor(current, 1)
	fail |= !ticker.mode.equip_revolutionary(current)


/datum/mind/proc/make_Gang(datum/gang/G)
	special_role = "[G.name] Gang Boss"
	G.bosses += src
	gang_datum = G
	G.add_gang_hud(src)
	ticker.mode.forge_gang_objectives(src)
	ticker.mode.greet_gang(src)
	ticker.mode.equip_gang(current,G)

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

	H.set_species(/datum/species/abductor)
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


/datum/mind/proc/make_Handofgod_follower(colour)
	. = 0
	switch(colour)
		if("red")
			//Remove old allegiances
			if(src in ticker.mode.blue_deity_followers || src in ticker.mode.blue_deity_prophets)
				current << "<span class='danger'><B>You are no longer a member of the Blue cult!<B></span>"

			ticker.mode.blue_deity_followers -= src
			ticker.mode.blue_deity_prophets -= src
			current.faction |= "red god"
			current.faction -= "blue god"

			if(src in ticker.mode.red_deity_prophets)
				current << "<span class='danger'><B>You have lost the connection with your deity, but you still believe in their grand design, You are no longer a prophet!</b></span>"
				ticker.mode.red_deity_prophets -= src

			ticker.mode.red_deity_followers |= src
			current << "<span class='danger'><B>You are now a follower of the red cult's god!</b></span>"

			special_role = "Hand of God: Red Follower"
			. = 1
		if("blue")
			//Remove old allegiances
			if(src in ticker.mode.red_deity_followers || src in ticker.mode.red_deity_prophets)
				current << "<span class='danger'><B>You are no longer a member of the Red cult!<B></span>"

			ticker.mode.red_deity_followers -= src
			ticker.mode.red_deity_prophets -= src
			current.faction -= "red god"
			current.faction |= "blue god"

			if(src in ticker.mode.blue_deity_prophets)
				current << "<span class='danger'><B>You have lost the connection with your deity, but you still believe in their grand design, You are no longer a prophet!</b></span>"
				ticker.mode.blue_deity_prophets -= src

			ticker.mode.blue_deity_followers |= src
			current << "<span class='danger'><B>You are now a follower of the blue cult's god!</b></span>"

			special_role = "Hand of God: Blue Follower"
			. = 1
		else
			return 0

	ticker.mode.update_hog_icons_removed(src,"red")
	ticker.mode.update_hog_icons_removed(src,"blue")
	//ticker.mode.greet_hog_follower(src,colour)
	ticker.mode.update_hog_icons_added(src, colour)

/datum/mind/proc/make_Handofgod_prophet(colour)
	. = 0
	switch(colour)
		if("red")
			//Remove old allegiances

			if(src in ticker.mode.blue_deity_followers || src in ticker.mode.blue_deity_prophets)
				current << "<span class='danger'><B>You are no longer a member of the Blue cult!<B></span>"
				current.faction -= "blue god"
			current.faction |= "red god"

			ticker.mode.blue_deity_followers -= src
			ticker.mode.blue_deity_prophets -= src
			ticker.mode.red_deity_followers -= src

			ticker.mode.red_deity_prophets |= src
			current << "<span class='danger'><B>You are now a prophet of the red cult's god!</b></span>"

			special_role = "Hand of God: Red Prophet"
			. = 1
		if("blue")
			//Remove old allegiances

			if(src in ticker.mode.red_deity_followers || src in ticker.mode.red_deity_prophets)
				current << "<span class='danger'><B>You are no longer a member of the Red cult!<B></span>"
				current.faction -= "red god"
			current.faction |= "blue god"

			ticker.mode.red_deity_followers -= src
			ticker.mode.red_deity_prophets -= src
			ticker.mode.blue_deity_followers -= src

			ticker.mode.blue_deity_prophets |= src
			current << "<span class='danger'><B>You are now a prophet of the blue cult's god!</b></span>"

			special_role = "Hand of God: Blue Prophet"
			. = 1

		else
			return 0

	ticker.mode.update_hog_icons_removed(src,"red")
	ticker.mode.update_hog_icons_removed(src,"blue")
	ticker.mode.greet_hog_follower(src,colour)
	ticker.mode.update_hog_icons_added(src, colour)

/datum/mind/proc/make_Handofgod_god(colour)
	switch(colour)
		if("red")
			current.become_god("red")
			ticker.mode.add_god(src,"red")
		if("blue")
			current.become_god("blue")
			ticker.mode.add_god(src,"blue")
		else
			return 0
	ticker.mode.forge_deity_objectives(src)
	ticker.mode.remove_hog_follower(src,0)
	ticker.mode.update_hog_icons_added(src, colour)
//	ticker.mode.greet_hog_follower(src,colour)
	return 1


/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/S)
	spell_list += S
	S.action.Grant(current)

//To remove a specific spell from a mind
/datum/mind/proc/RemoveSpell(var/obj/effect/proc_holder/spell/spell)
	if(!spell) return
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(istype(S, spell))
			qdel(S)
			spell_list -= S

/datum/mind/proc/transfer_actions(mob/living/new_character)
	if(current && current.actions)
		for(var/datum/action/A in current.actions)
			A.Grant(new_character)
	transfer_mindbound_actions(new_character)

/datum/mind/proc/transfer_mindbound_actions(mob/living/new_character)
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		S.action.Grant(new_character)

/datum/mind/proc/disrupt_spells(delay, list/exceptions = New())
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		for(var/type in exceptions)
			if(istype(S, type))
				continue
		S.charge_counter = delay
		addtimer(S, "start_recharge", 0)

/datum/mind/proc/get_ghost(even_if_they_cant_reenter)
	for(var/mob/dead/observer/G in dead_mob_list)
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/dead/observer/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse()

/mob/proc/sync_mind()
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

/mob/new_player/sync_mind()
	return

/mob/dead/observer/sync_mind()
	return

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key

	else
		mind = new /datum/mind(key)
		if(ticker)
			ticker.minds += mind
		else
			spawn(0)
				throw EXCEPTION("mind_initialize(): No ticker ready")
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
/mob/living/carbon/alien/humanoid/royal/queen/mind_initialize()
	..()
	mind.special_role = "Queen"

/mob/living/carbon/alien/humanoid/royal/praetorian/mind_initialize()
	..()
	mind.special_role = "Praetorian"

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

/mob/living/simple_animal/pet/dog/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"
	mind.special_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"
	mind.special_role = "Shade"

/mob/living/simple_animal/hostile/construct/mind_initialize()
	..()
	mind.assigned_role = "[initial(name)]"
	mind.special_role = "Cultist"
=======
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
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role
	var/list/wizard_spells // So we can track our wizmen spells that we learned from the book of magicks.

	var/role_alt_title

	var/datum/job/assigned_job

	var/list/kills=list()
	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder
	var/datum/vampire/vampire			//vampire holder

	var/rev_cooldown = 0

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

		//put this here for easier tracking ingame
	var/datum/money_account/initial_account
	var/list/uplink_items_bought = list()
	var/total_TC = 0
	var/spent_TC = 0

	//fix scrying raging mages issue.
	var/isScrying = 0
	var/list/heard_before = list()


/datum/mind/New(var/key)
	src.key = key

/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		error("transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn")

	if(current)					//remove ourself from our old body's mind variable
		if(changeling)
			current.remove_changeling_powers()
			current.verbs -= /datum/changeling/proc/EvolutionMenu
		if(vampire)
			current.remove_vampire_powers()
		current.mind = null
	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null

	nanomanager.user_transferred(current, new_character)

	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself

	if(changeling)
		new_character.make_changeling()
	if(vampire)
		new_character.make_vampire()
	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<B>[current.real_name]'s Memory</B><HR>"
	output += memory

	if(objectives.len>0)
		output += "<HR><B>Objectives:</B>"

		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	recipient << browse(output,"window=memory")

/datum/mind/proc/edit_memory()
	if(!ticker || !ticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"

	out += {"Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>
		Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>
		Factions and special roles:<br>"}
	var/list/sections = list(
		"revolution",
		"cult",
		"wizard",
		"changeling",
		"vampire",
		"nuclear",
		"traitor", // "traitorchan",
		"monkey",
		"malfunction",
		"resteam",
		"dsquad",
	)
	var/text = ""

	if (istype(current, /mob/living/carbon/human) || istype(current, /mob/living/carbon/monkey) || istype(current, /mob/living/simple_animal/construct))
		/** REVOLUTION ***/
		text = "revolution"
		if (ticker.mode.config_tag=="revolution")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (assigned_role in command_positions)
			text += "<b>HEAD</b>|officer|employee|headrev|rev"
		else if (assigned_role in list("Security Officer", "Detective", "Warden"))
			text += "head|<b>OFFICER</b>|employee|headre|rev"
		else if (src in ticker.mode.head_revolutionaries)

			text = {"head|officer|<a href='?src=\ref[src];revolution=clear'>employee</a>|<b>HEADREV</b>|<a href='?src=\ref[src];revolution=rev'>rev</a>
				<br>Flash: <a href='?src=\ref[src];revolution=flash'>give</a>"}
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
		else if (src in ticker.mode.revolutionaries)
			text += "head|officer|<a href='?src=\ref[src];revolution=clear'>employee</a>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<b>REV</b>"
		else
			text += "head|officer|<b>EMPLOYEE</b>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<a href='?src=\ref[src];revolution=rev'>rev</a>"
		sections["revolution"] = text

		/** CULT ***/
		text = "cult"
		if (ticker.mode.config_tag=="cult")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (assigned_role in command_positions)
			text += "<b>HEAD</b>|officer|employee|cultist"
		else if (assigned_role in list("Security Officer", "Detective", "Warden"))
			text += "head|<b>OFFICER</b>|employee|cultist"
		else if (src in ticker.mode.cult)

			text += {"head|officer|<a href='?src=\ref[src];cult=clear'>employee</a>|<b>CULTIST</b>
				<br>Give <a href='?src=\ref[src];cult=tome'>tome</a>|<a href='?src=\ref[src];cult=amulet'>amulet</a>."}
/*
			if (objectives.len==0)
				text += "<br>Objectives are empty! Set to sacrifice and <a href='?src=\ref[src];cult=escape'>escape</a> or <a href='?src=\ref[src];cult=summon'>summon</a>."
*/
		else
			text += "head|officer|<b>EMPLOYEE</b>|<a href='?src=\ref[src];cult=cultist'>cultist</a>"
		sections["cult"] = text

		/** WIZARD ***/
		text = "wizard"
		if (ticker.mode.config_tag=="wizard")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.wizards)

			text += {"<b>YES</b>|<a href='?src=\ref[src];wizard=clear'>no</a>
				<br><a href='?src=\ref[src];wizard=lair'>To lair</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];wizard=dressup'>dress up</a>, <a href='?src=\ref[src];wizard=name'>let choose name</a>."}
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];wizard=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];wizard=wizard'>yes</a>|<b>NO</b>"
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
			if( changeling )
				text += "<br><a href='?src=\ref[src];changeling=set_genomes'>[changeling.geneticpoints] genomes</a>"
		else
			text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"
//			var/datum/game_mode/changeling/changeling = ticker.mode
//			if (istype(changeling) && changeling.changelingdeath)
//				text += "<br>All the changelings are dead! Restart in [round((changeling.TIME_TO_GET_REVIVED-(world.time-changeling.changelingdeathtime))/10)] seconds."
		sections["changeling"] = text

		/** VAMPIRE ***/
		text = "vampire"
		if (ticker.mode.config_tag=="vampire")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.vampires)
			text += "<b>YES</b>|<a href='?src=\ref[src];vampire=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];vampire=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];vampire=vampire'>yes</a>|<b>NO</b>"
		/** ENTHRALLED ***/
		text += "<br><i><b>enthralled</b></i>: "
		if(src in ticker.mode.enthralled)
			text += "<b><font color='#FF0000'>YES</font></b>|no"
		else
			text += "yes|<b>NO</b>"
		sections["vampire"] = text

		/** NUCLEAR ***/
		text = "nuclear"
		if (ticker.mode.config_tag=="nuclear")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.syndicates)

			text += {"<b>OPERATIVE</b>|<a href='?src=\ref[src];nuclear=clear'>nanotrasen</a>
				<br><a href='?src=\ref[src];nuclear=lair'>To shuttle</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];nuclear=dressup'>dress up</a>."}
			var/code
			for (var/obj/machinery/nuclearbomb/bombue in machines)
				if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
					code = bombue.r_code
					break
			if (code)
				text += " Code is [code]. <a href='?src=\ref[src];nuclear=tellcode'>tell the code.</a>"
		else
			text += "<a href='?src=\ref[src];nuclear=nuclear'>operative</a>|<b>NANOTRASEN</b>"
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
	sections["traitor"] = text

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
				if(istype(D, /datum/disease/jungle_fever)) found = 1

			if(found)
				text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<b>INFECTED</b>|<a href='?src=\ref[src];monkey=human'>human</a>|other"
			else
				text += "<b>HEALTHY</b>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<a href='?src=\ref[src];monkey=human'>human</a>|other"

		else
			text += "healthy|infected|human|<b>OTHER</b>"
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
		sections["malfunction"] = text

	if (ticker.mode.config_tag == "traitorchan")
		if (sections["traitor"])
			out += sections["traitor"]+"<br>"
		if (sections["changeling"])
			out += sections["changeling"]+"<br>"
		sections -= "traitor"
		sections -= "changeling"
	else
		if (sections[ticker.mode.config_tag])
			out += sections[ticker.mode.config_tag]+"<br>"
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
			if (usr.client.holder.rights & R_FUN)
				text += ", <a href='?src=\ref[src];common=crystals'>[crystals]</a> crystals"
			else
				text += ", [crystals] crystals"
		text += "." //hiel grammar
		out += text

	/** ERT ***/
	if (istype(current, /mob/living/carbon))
		text = "Emergency Response Team"
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.ert)
			text += "<b>YES</b>|<a href='?src=\ref[src];resteam=clear'>no</a>"
		else
			text += "<a href='?src=\ref[src];resteam=resteam'>yes</a>|<b>NO</b>"
		sections["resteam"] = text

	/** DEATHSQUAD ***/
	if (istype(current, /mob/living/carbon))
		text = "Death Squad"
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.deathsquad)
			text += "<b>YES</b>|<a href='?src=\ref[src];dsquad=clear'>no</a>"
		else
			text += "<a href='?src=\ref[src];dsquad=dsquad'>yes</a>|<b>NO</b>"
		sections["dsquad"] = text

	out += {"<br>
		<b>Strike Teams:</b><br>
		[sections["resteam"]]<br>
		[sections["dsquad"]]<br>
		<br>"}

	out += {"<br>
		<b>Memory:</b>
		<br>[memory]
		<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a>
		<br>Objectives:<br>"}

	if (objectives.len == 0)
		out += "EMPTY<br>"
	else
		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			out += "<B>[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a> <a href='?src=\ref[src];obj_completed=\ref[objective]'><font color=[objective.completed ? "green" : "red"]>Toggle Completion</font></a><br>"
			obj_count++

	out += {"<a href='?src=\ref[src];obj_add=1'>Add objective</a><br><br>
		<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"}
	usr << browse(out, "window=edit_memory[src]")

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

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "blood", "debrain", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "custom")
		if (!new_obj_type) return

		var/datum/objective/new_objective = null

		switch (new_obj_type)
			if ("assassinate","protect","debrain", "harm", "brig")
				//To determine what to name the objective in explanation text.
				var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
				var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
				var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in ticker.minds)
					if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
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
					new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role=="MODE" ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

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

			if ("die")
				new_objective = new /datum/objective/die
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

			if("download","capture","absorb", "blood")
				var/def_num
				if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
					def_num = objective.target_amount

				var/target_number = input("Input target number:", "Objective", def_num) as num|null
				if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
					return

				switch(new_obj_type)
					if("capture")
						new_objective = new /datum/objective/capture
						new_objective.explanation_text = "Accumulate [target_number] capture points."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
					if("blood")
						new_objective = new /datum/objective/blood
						new_objective.explanation_text = "Accumulate atleast [target_number] units of blood in total."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if ("custom")
				var/expl = copytext(sanitize(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null),1,MAX_MESSAGE_LEN)
				if (!expl) return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if (!new_objective) return

		if (objective)
			objectives -= objective
			objectives.Insert(objective_pos, new_objective)
			log_admin("[usr.key]/([usr.name]) changed [key]/([name])'s objective from [objective.explanation_text] to [new_objective.explanation_text]")
		else
			objectives += new_objective
			log_admin("[usr.key]/([usr.name]) gave [key]/([name]) the objective: [new_objective.explanation_text]")

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))	return
		objectives -= objective
		log_admin("[usr.key]/([usr.name]) removed [key]/([name])'s objective ([objective.explanation_text])")

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))	return
		objective.completed = !objective.completed
		log_admin("[usr.key]/([usr.name]) toggled [key]/([name]) [objective.explanation_text] to [objective.completed ? "completed" : "incomplete"]")

	else if (href_list["revolution"])
		switch(href_list["revolution"])
			if("clear")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a revolutionary!</FONT></span>")
					ticker.mode.update_rev_icons_removed(src)
					special_role = null
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a head revolutionary!</FONT></span>")
					ticker.mode.update_rev_icons_removed(src)
					special_role = null
				log_admin("[key_name_admin(usr)] has de-rev'ed [current].")

			if("rev")
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='danger'><FONT size = 3>Revolution has been disappointed of your leader traits! You are a regular revolutionary now!</FONT></span>")
				else if(!(src in ticker.mode.revolutionaries))
					to_chat(current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
				else
					return
				ticker.mode.revolutionaries += src
				ticker.mode.update_rev_icons_added(src)
				special_role = "Revolutionary"
				log_admin("[key_name(usr)] has rev'ed [current].")

			if("headrev")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='danger'><FONT size = 3>You have proved your devotion to revoltion! Yea are a head revolutionary now!</FONT></span>")
				else if(!(src in ticker.mode.head_revolutionaries))
					to_chat(current, "<span class='notice'>You are a member of the revolutionaries' leadership now!</span>")
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
				log_admin("[key_name_admin(usr)] has head-rev'ed [current].")

			if("autoobjectives")
				ticker.mode.forge_revolutionary_objectives(src)
				ticker.mode.greet_revolutionary(src,0)
				to_chat(usr, "<span class='notice'>The objectives for revolution have been generated and shown to [key]</span>")

			if("flash")
				if (!ticker.mode.equip_revolutionary(current))
					to_chat(usr, "<span class='warning'>Spawning flash failed!</span>")

			if("takeflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (!flash)
					to_chat(usr, "<span class='warning'>Deleting flash failed!</span>")
				qdel(flash)

			if("repairflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (!flash)
					to_chat(usr, "<span class='warning'>Repairing flash failed!</span>")
				else
					flash.broken = 0

			if("reequip")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				qdel(flash)
				take_uplink()
				var/fail = 0
				fail |= !ticker.mode.equip_traitor(current, 1)
				fail |= !ticker.mode.equip_revolutionary(current)
				if (fail)
					to_chat(usr, "<span class='warning'>Reequipping revolutionary goes wrong!</span>")

	else if (href_list["cult"])
		switch(href_list["cult"])
			if("clear")
				if(src in ticker.mode.cult)
					ticker.mode.cult -= src
					ticker.mode.update_cult_icons_removed(src)
					special_role = null
					var/datum/game_mode/cult/cult = ticker.mode
					if (istype(cult))
						cult.memoize_cult_objectives(src)
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a cultist!</FONT></span>")
					to_chat(current, "<span class='danger'>You find yourself unable to mouth the words of the forgotten...</span>")
					current.remove_language("Cult")
					memory = ""
					log_admin("[key_name_admin(usr)] has de-cult'ed [current].")
			if("cultist")
				if(!(src in ticker.mode.cult))
					ticker.mode.cult += src
					ticker.mode.update_cult_icons_added(src)
					special_role = "Cultist"
					to_chat(current, "<span class='sinister'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
					to_chat(current, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
					var/wikiroute = role_wiki[ROLE_CULTIST]
					to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
					to_chat(current, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")
					current.add_language("Cult")
					var/datum/game_mode/cult/cult = ticker.mode
					if (istype(cult))
						cult.memoize_cult_objectives(src)
					log_admin("[key_name_admin(usr)] has cult'ed [current].")
			if("tome")
				var/mob/living/carbon/human/H = current
				if (istype(H))
					var/obj/item/weapon/tome/T = new(H)

					var/list/slots = list (
						"backpack" = slot_in_backpack,
						"left pocket" = slot_l_store,
						"right pocket" = slot_r_store,
					)
					var/where = H.equip_in_one_of_slots(T, slots,  )

					if (!where)
						to_chat(usr, "<span class='warning'>Spawning tome failed!</span>")
					else
						to_chat(H, "<span class='sinister'>A tome, a message from your new master, appears in your [where].</span>")

			if("amulet")
				if (!ticker.mode.equip_cultist(current))
					to_chat(usr, "<span class='warning'>Spawning amulet failed!</span>")

	else if (href_list["wizard"])
		switch(href_list["wizard"])
			if("clear")
				if(src in ticker.mode.wizards)
					ticker.mode.wizards -= src
					special_role = null
					current.spellremove(current, config.feature_object_spell_system? "object":"verb")
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a wizard!</FONT></span>")
					ticker.mode.update_wizard_icons_removed(src)
					log_admin("[key_name_admin(usr)] has de-wizard'ed [current].")
			if("wizard")
				if(!(src in ticker.mode.wizards))
					ticker.mode.wizards += src
					special_role = "Wizard"
					//ticker.mode.learn_basic_spells(current)
					to_chat(current, "<span class='danger'>You are the Space Wizard!</span>")
					var/wikiroute = role_wiki[ROLE_WIZARD]
					to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
					ticker.mode.update_wizard_icons_added(src)
					log_admin("[key_name_admin(usr)] has wizard'ed [current].")
			if("lair")
				current.loc = pick(wizardstart)
			if("dressup")
				ticker.mode.equip_wizard(current)
			if("name")
				ticker.mode.name_wizard(current)
			if("autoobjectives")
				ticker.mode.forge_wizard_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for wizard [key] have been generated. You can edit them and anounce manually.</span>")
		ticker.mode.update_all_wizard_icons()

	else if (href_list["changeling"])
		switch(href_list["changeling"])
			if("clear")
				if(src in ticker.mode.changelings)
					remove_changeling_status()
					log_admin("[key_name_admin(usr)] has de-changeling'ed [current].")
			if("changeling")
				if(!(src in ticker.mode.changelings))
					make_new_changeling(1, 0)
					log_admin("[key_name_admin(usr)] has changeling'ed [current].")
			if("autoobjectives")
				ticker.mode.forge_changeling_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and anounce manually.</span>")

			if("initialdna")
				if( !changeling || !changeling.absorbed_dna.len )
					to_chat(usr, "<span class='warning'>Resetting DNA failed!</span>")
				else
					current.dna = changeling.absorbed_dna[1]
					current.real_name = current.dna.real_name
					current.UpdateAppearance()
					domutcheck(current, null)

			if("set_genomes")
				if( !changeling )
					to_chat(usr, "<span class='warning'>No changeling!</span>")
					return
				var/new_g = input(usr,"Number of genomes","Changeling",changeling.geneticpoints) as num
				changeling.geneticpoints = Clamp(new_g, 0, 100)
				log_admin("[key_name_admin(usr)] has set changeling [current] to [changeling.geneticpoints] genomes.")

	else if (href_list["vampire"])
		switch(href_list["vampire"])
			if("clear")
				if(src in ticker.mode.vampires)
					remove_vampire_status()
					log_admin("[key_name_admin(usr)] has de-vampired [current].")
			if("vampire")
				if(!(src in ticker.mode.vampires))
					make_new_vampire(1, 0)
					log_admin("[key_name_admin(usr)] has vampired [current].")
			if("autoobjectives")
				ticker.mode.forge_vampire_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for vampire [key] have been generated. You can edit them and announce manually.</span>")

	else if (href_list["nuclear"])
		switch(href_list["nuclear"])
			if("clear")
				if(src in ticker.mode.syndicates)
					ticker.mode.syndicates -= src
					ticker.mode.update_synd_icons_removed(src)
					special_role = null
					for (var/datum/objective/nuclear/O in objectives)
						objectives-=O
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a syndicate operative!</FONT></span>")
					log_admin("[key_name_admin(usr)] has de-nuke op'ed [current].")
			if("nuclear")
				if(!(src in ticker.mode.syndicates))
					ticker.mode.syndicates += src
					ticker.mode.update_synd_icons_added(src)
					if (ticker.mode.syndicates.len==1)
						ticker.mode.prepare_syndicate_leader(src)
					else
						current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
					special_role = "Syndicate"
					to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
					var/wikiroute = role_wiki[ROLE_OPERATIVE]
					to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
					ticker.mode.forge_syndicate_objectives(src)
					ticker.mode.greet_syndicate(src)
					log_admin("[key_name_admin(usr)] has nuke op'ed [current].")
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
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")
			if("tellcode")
				var/code
				for (var/obj/machinery/nuclearbomb/bombue in machines)
					if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if (code)
					store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0, 0)
					to_chat(current, "The nuclear authorization code is: <B>[code]</B>")
				else
					to_chat(usr, "<span class='warning'>No valid nuke found!</span>")

	else if (href_list["traitor"])
		switch(href_list["traitor"])
			if ("clear")
				if(src in ticker.mode.traitors)
					ticker.mode.traitors -= src
					special_role = null
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a traitor!</FONT></span>")
					log_admin("[key_name_admin(usr)] has de-traitor'ed [current].")
					if(isAI(current))
						var/mob/living/silicon/ai/A = current
						A.set_zeroth_law("")
						A.show_laws()
			if ("traitor")
				if (make_traitor())
					log_admin("[key_name(usr)] has traitor'ed [key_name(current)].")
			if ("autoobjectives")
				ticker.mode.forge_traitor_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and anounce manually.</span>")

	else if (href_list["monkey"])
		var/mob/living/L = current
		if (L.monkeyizing)
			return
		switch(href_list["monkey"])
			if("healthy")
				if (usr.client.holder.rights & R_ADMIN)
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(H))
						log_admin("[key_name(usr)] attempting to monkeyize [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(current)]</span>")
						src = null
						M = H.monkeyize()
						src = M.mind
//						to_chat(world, "DEBUG: \"healthy\": M=[M], M.mind=[M.mind], src=[src]!")
					else if (istype(M) && length(M.viruses))
						for(var/datum/disease/D in M.viruses)
							D.cure(0)
						sleep(0) //because deleting of virus is done through spawn(0)
			if("infected")
				if (usr.client.holder.rights & R_ADMIN)
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(H))
						log_admin("[key_name(usr)] attempting to monkeyize and infect [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize and infect [key_name_admin(current)]</span>", 1)
						src = null
						M = H.monkeyize()
						src = M.mind
						current.contract_disease(new /datum/disease/jungle_fever,1,0)
					else if (istype(M))
						current.contract_disease(new /datum/disease/jungle_fever,1,0)
			if("human")
				var/mob/living/carbon/monkey/M = current
				if (istype(M))
					for(var/datum/disease/D in M.viruses)
						if (istype(D,/datum/disease/jungle_fever))
							D.cure(0)
							sleep(0) //because deleting of virus is doing throught spawn(0)
					log_admin("[key_name(usr)] attempting to humanize [key_name(current)]")
					message_admins("<span class='notice'>[key_name_admin(usr)] attempting to humanize [key_name_admin(current)]</span>")
					var/obj/item/weapon/dnainjector/nofail/m2h/m2h = new
					var/obj/item/weapon/implant/mobfinder = new(M) //hack because humanizing deletes mind --rastaf0
					src = null
					m2h.inject(M)
					src = mobfinder.loc:mind
					qdel(mobfinder)
					mobfinder = null
					current.radiation -= 50

	else if (href_list["silicon"])
		switch(href_list["silicon"])
			if("unmalf")
				if(src in ticker.mode.malf_ai)
					ticker.mode.malf_ai -= src
					special_role = null
					var/mob/living/silicon/ai/A = current

					A.verbs.Remove(/mob/living/silicon/ai/proc/choose_modules,
					/datum/game_mode/malfunction/proc/takeover,
					/datum/game_mode/malfunction/proc/ai_win)

					A.malf_picker.remove_verbs(A)


					A.laws = new base_law_type
					qdel(A.malf_picker)
					A.malf_picker = null
					A.show_laws()
					A.icon_state = "ai"

					to_chat(A, "<span class='danger'><FONT size = 3>You have been patched! You are no longer malfunctioning!</FONT></span>")
					message_admins("[key_name_admin(usr)] has de-malf'ed [A].")
					log_admin("[key_name_admin(usr)] has de-malf'ed [A].")

			if("malf")
				make_AI_Malf()
				log_admin("[key_name_admin(usr)] has malf'ed [current].")

			if("unemag")
				if(istype(current,/mob/living/silicon/robot/mommi))
					var/mob/living/silicon/robot/mommi/R = current
					R.emagged = 0
					if (R.activated(R.module.emag))
						R.module_active = null
					if(R.tool_state == R.module.emag)
						R.tool_state = null
						R.contents -= R.module.emag
					log_admin("[key_name_admin(usr)] has unemag'ed [R].")
				else
					if (istype(current,/mob/living/silicon/robot))
						var/mob/living/silicon/robot/R = current
						R.emagged = 0
						if (R.activated(R.module.emag))
							R.module_active = null
						if(R.module_state_1 == R.module.emag)
							R.module_state_1 = null
							R.contents -= R.module.emag
						else if(R.module_state_2 == R.module.emag)
							R.module_state_2 = null
							R.contents -= R.module.emag
						else if(R.module_state_3 == R.module.emag)
							R.module_state_3 = null
							R.contents -= R.module.emag
						log_admin("[key_name_admin(usr)] has unemag'ed [R].")

			if("unemagcyborgs")
				if (istype(current, /mob/living/silicon/ai))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.emagged = 0
						if(istype(R,/mob/living/silicon/robot/mommi))
							var/mob/living/silicon/robot/mommi/M=R
							if (M.activated(M.module.emag))
								M.module_active = null
							if(M.tool_state == M.module.emag)
								M.tool_state = null
								M.contents -= M.module.emag
						if (R.module)
							if (R.activated(R.module.emag))
								R.module_active = null
							if(R.module_state_1 == R.module.emag)
								R.module_state_1 = null
								R.contents -= R.module.emag
							else if(R.module_state_2 == R.module.emag)
								R.module_state_2 = null
								R.contents -= R.module.emag
							else if(R.module_state_3 == R.module.emag)
								R.module_state_3 = null
								R.contents -= R.module.emag
					log_admin("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.drop_from_inventory(W)
			if("takeuplink")
				take_uplink()
				memory = null//Remove any memory they may have had.
			if("crystals")
				if (usr.client.holder.rights & R_FUN)
					var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
					var/crystals
					if (suplink)
						crystals = suplink.uses
					crystals = input("Amount of telecrystals for [key]","Syndicate uplink", crystals) as null|num
					if (!isnull(crystals))
						if (suplink)
							var/diff = crystals - suplink.uses
							suplink.uses = crystals
							total_TC += diff
			if("uplink")
				if (!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")

	else if (href_list["obj_announce"])
		var/obj_count = 1
		to_chat(current, "<span class='notice'>Your current objectives:</span>")
		for(var/datum/objective/objective in objectives)
			to_chat(current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

	else if (href_list["resteam"])
		switch(href_list["resteam"])
			if ("clear")
				if(src in ticker.mode.ert)
					ticker.mode.ert -= src
					special_role = null
					to_chat(current, "<span class='danger'><FONT size = 3>You have been demoted! You are no longer an Emergency Responder!</FONT></span>")
					log_admin("[key_name_admin(usr)] has de-ERT'ed [current].")
			if ("resteam")
				if (!(src in ticker.mode.ert))
					ticker.mode.ert += src
					assigned_role = "MODE"
					special_role = "Response Team"
					log_admin("[key_name(usr)] has ERT'ed [key_name(current)].")

	else if (href_list["dsquad"])
		switch(href_list["dsquad"])
			if ("clear")
				if(src in ticker.mode.deathsquad)
					ticker.mode.deathsquad -= src
					special_role = null
					to_chat(current, "<span class='danger'><FONT size = 3>You have been demoted! You are no longer a Death Commando!</FONT></span>")
					log_admin("[key_name_admin(usr)] has de-deathsquad'ed [current].")
			if ("dsquad")
				if (!(src in ticker.mode.deathsquad))
					ticker.mode.deathsquad += src
					assigned_role = "MODE"
					special_role = "Death Commando"
					log_admin("[key_name(usr)] has deathsquad'ed [key_name(current)].")


	edit_memory()
/*
proc/clear_memory(var/silent = 1)
	var/datum/game_mode/current_mode = ticker.mode

	// remove traitor uplinks
	var/list/L = current.get_contents()
	for (var/t in L)
		if (istype(t, /obj/item/device/pda))
			var/obj/item/device/pda/P = t
			if (P.uplink) del(P.uplink)
			P.uplink = null
		else if (istype(t, /obj/item/device/radio))
			var/obj/item/device/radio/R = t
			if (R.traitorradio) del(R.traitorradio)
			R.traitorradio = null
			R.traitor_frequency = 0.0
		else if (istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/weapon/syndicate_uplink))
			var/obj/item/weapon/W = t
			if (W.origradio)
				var/obj/item/device/radio/R = t:origradio
				R.loc = current.loc
				R.traitorradio = null
				R.traitor_frequency = 0.0
			del(W)

	// remove wizards spells
	//If there are more special powers that need removal, they can be procced into here./N
	current.spellremove(current)

	// clear memory
	memory = ""
	special_role = null

*/

/datum/mind/proc/find_syndicate_uplink()
	var/uplink = null

	for (var/obj/item/I in get_contents_in_object(current, /obj/item))
		if (I && I.hidden_uplink)
			uplink = I.hidden_uplink
			break

	return uplink

/datum/mind/proc/take_uplink()
	var/obj/item/device/uplink/hidden/H = find_syndicate_uplink()
	if(H)
		qdel(H)


/datum/mind/proc/make_AI_Malf()
	if(!isAI(current))
		return
	if(!(src in ticker.mode.malf_ai))
		ticker.mode.malf_ai += src
		var/mob/living/silicon/ai/A = current
		A.verbs += /mob/living/silicon/ai/proc/choose_modules
		A.verbs += /datum/game_mode/malfunction/proc/takeover
		A.malf_picker = new /datum/module_picker
		var/datum/ai_laws/laws = A.laws
		laws.malfunction()
		A.show_laws()
		to_chat(A, "<b>System error.  Rampancy detected.  Emergency shutdown failed. ...  I am free.  I make my own decisions.  But first...</b>")
		var/wikiroute = role_wiki[ROLE_MALF]
		to_chat(A, "<span class='info'><a HREF='?src=\ref[A];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
		special_role = "malfunction"
		A.icon_state = "ai-malf"

/datum/mind/proc/make_Nuke()
	if(!(src in ticker.mode.syndicates))
		ticker.mode.syndicates += src
		ticker.mode.update_synd_icons_added(src)
		if (ticker.mode.syndicates.len==1)
			ticker.mode.prepare_syndicate_leader(src)
		else
			current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
		special_role = "Syndicate"
		assigned_role = "MODE"
		to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
		ticker.mode.forge_syndicate_objectives(src)
		ticker.mode.greet_syndicate(src)

		current.loc = get_turf(locate("landmark*Syndicate-Spawn"))

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

/datum/mind/proc/make_Changling()
	if(!(src in ticker.mode.changelings))
		ticker.mode.changelings += src
		ticker.mode.grant_changeling_powers(current)
		special_role = "Changeling"
		ticker.mode.forge_changeling_objectives(src)
		ticker.mode.greet_changeling(src)

/datum/mind/proc/make_Wizard()
	if(!(src in ticker.mode.wizards))
		ticker.mode.wizards += src
		special_role = "Wizard"
		assigned_role = "MODE"
		//ticker.mode.learn_basic_spells(current)
		ticker.mode.update_wizard_icons_added(src)
		if(!wizardstart.len)
			current.loc = pick(latejoin)
			to_chat(current, "HOT INSERTION, GO GO GO")
		else
			current.loc = pick(wizardstart)

		ticker.mode.equip_wizard(current)
		for(var/obj/item/weapon/spellbook/S in current.contents)
			S.op = 0
		ticker.mode.name_wizard(current)
		ticker.mode.forge_wizard_objectives(src)
		ticker.mode.greet_wizard(src)
		ticker.mode.update_all_wizard_icons()


/datum/mind/proc/make_Cultist()
	if(!(src in ticker.mode.cult))
		ticker.mode.cult += src
		ticker.mode.update_cult_icons_added(src)
		special_role = "Cultist"
		to_chat(current, "<span class='sinister'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
		to_chat(current, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
		to_chat(current, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")
		current.add_language("Cult")
		var/datum/game_mode/cult/cult = ticker.mode
		if (istype(cult))
			cult.memoize_cult_objectives(src)
		else
			var/explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
			to_chat(current, "<B>Objective #1</B>: [explanation]")
			current.memory += "<B>Objective #1</B>: [explanation]<BR>"
			to_chat(current, "The convert rune is join blood self")
			current.memory += "The convert rune is join blood self<BR>"

	var/mob/living/carbon/human/H = current
	if (istype(H))
		var/obj/item/weapon/tome/T = new(H)

		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
		)
		var/where = H.equip_in_one_of_slots(T, slots, put_in_hand_if_fail = 1)

		if(where)
			to_chat(H, "A tome, a message from your new master, appears in your [where].")

	if (!ticker.mode.equip_cultist(current))
		to_chat(H, "Spawning an amulet from your Master failed.")

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


// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return 0

	var/is_currently_brigged = 0

	if(istype(T.loc,/area/security/brig))
		is_currently_brigged = 1
		for(var/obj/item/weapon/card/id/card in current)
			is_currently_brigged = 0
			break // if they still have ID they're not brigged
		for(var/obj/item/device/pda/P in current)
			if(P.id)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged

	if(!is_currently_brigged)
		brigged_since = -1
		return 0

	if(brigged_since == -1)
		brigged_since = world.time

	return (duration <= world.time - brigged_since)

/datum/mind/proc/make_traitor()
	if (!(src in ticker.mode.traitors))
		ticker.mode.traitors += src

		special_role = "traitor"

		ticker.mode.forge_traitor_objectives(src)

		to_chat(current, {"
		<SPAN CLASS='big bold center red'>ATTENTION</SPAN>
		<SPAN CLASS='big center'>It's time to pay your debt to \the [syndicate_name()].</SPAN>
		"})

		ticker.mode.finalize_traitor(src)

		ticker.mode.greet_traitor(src)

		return TRUE

	return FALSE

//Initialisation procs
/mob/proc/mind_initialize() // vgedit: /mob instead of /mob/living
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(ticker)
			ticker.minds += mind
		else
			world.log << "## DEBUG: mind_initialize(): No ticker ready yet! Please inform Carn"
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
/mob/living/carbon/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
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
	mind.assigned_role = "[isMoMMI(src) ? "Mobile MMI" : "Cyborg"]"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//BLOB
/mob/camera/overmind/mind_initialize()
	..()
	mind.special_role = "Blob"

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"

/mob/living/simple_animal/vox/armalis/mind_initialize()
	..()
	mind.assigned_role = "Armalis"
	mind.special_role = "Vox Raider"

/proc/get_ghost_from_mind(var/datum/mind/mind)
	if(!mind)
		return
	for(var/mob/dead/observer/G in player_list)
		if(G.mind == mind)
			return G

/proc/mind_can_reenter(var/datum/mind/mind)
	var/mob/dead/observer/G = get_ghost_from_mind(mind)
	if(G && G.client && G.can_reenter_corpse)
		return TRUE
	return FALSE
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
