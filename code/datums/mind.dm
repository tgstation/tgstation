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
		By setting key or ckey explicitly after transferring the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mind for that mobtype (including setting up stuff like mind.name). Simple!
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

	var/list/spell_list = list() // Wizard mode & "Give Spell" badmin button.

	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder
	var/linglink
	var/datum/martial_art/martial_art
	var/static/default_martial_art = new/datum/martial_art
	var/miming = 0 // Mime's vow of silence
	var/list/antag_datums
	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/datum/gang/gang_datum //Which gang this mind belongs to, if any
	var/damnation_type = 0
	var/datum/mind/soulOwner //who owns the soul.  Under normal circumstances, this will point to src
	var/hasSoul = TRUE // If false, renders the character unable to sell their soul.
	var/isholy = FALSE //is this person a chaplain or admin role allowed to use bibles

	var/mob/living/enslaved_to //If this mind's master is another mob (i.e. adamantine golems)
	var/datum/language_holder/language_holder

/datum/mind/New(var/key)
	src.key = key
	soulOwner = src
	martial_art = default_martial_art

/datum/mind/Destroy()
	SSticker.minds -= src
	if(islist(antag_datums))
		for(var/i in antag_datums)
			var/datum/antagonist/antag_datum = i
			if(antag_datum.delete_on_death)
				qdel(i)
		antag_datums = null
	return ..()

/datum/mind/proc/get_language_holder()
	if(!language_holder)
		var/datum/language_holder/L = current.get_language_holder(shadow=FALSE)
		language_holder = L.copy(src)

	return language_holder

/datum/mind/proc/transfer_to(mob/new_character, var/force_key_move = 0)
	if(current)	// remove ourself from our old body's mind variable
		current.mind = null
		SStgui.on_transfer(current, new_character)

	if(!language_holder)
		var/datum/language_holder/mob_holder = new_character.get_language_holder(shadow = FALSE)
		language_holder = mob_holder.copy(src)

	if(key)
		if(new_character.key != key)					//if we're transferring into a body with a key associated which is not ours
			new_character.ghostize(1)						//we'll need to ghostize so that key isn't mobless.
	else
		key = new_character.key

	if(new_character.mind)								//disassociate any mind currently in our new body's mind variable
		new_character.mind.current = null

	var/datum/atom_hud/antag/hud_to_transfer = antag_hud//we need this because leave_hud() will clear this list
	var/mob/living/old_current = current
	current = new_character								//associate ourself with our new body
	new_character.mind = src							//and associate our new body with ourself
	for(var/a in antag_datums)	//Makes sure all antag datums effects are applied in the new body
		var/datum/antagonist/A = a
		A.on_body_transfer(old_current, current)
	if(iscarbon(new_character))
		var/mob/living/carbon/C = new_character
		C.last_mind = src
	transfer_antag_huds(hud_to_transfer)				//inherit the antag HUD
	transfer_actions(new_character)
	transfer_martial_arts(new_character)
	if(active || force_key_move)
		new_character.key = key		//now transfer the key to link the client to our new body

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/wipe_memory()
	memory = null

// Datum antag mind procs
/datum/mind/proc/add_antag_datum(datum_type)
	if(!datum_type)
		return
	var/datum/antagonist/A = new datum_type(src)
	if(!A.can_be_owned(src))
		qdel(A)
		return
	LAZYADD(antag_datums, A)
	A.on_gain()
	return A

/datum/mind/proc/remove_antag_datum(datum_type)
	if(!datum_type)
		return
	var/datum/antagonist/A = has_antag_datum(datum_type)
	if(A)
		A.on_removal()
		return TRUE


/datum/mind/proc/remove_all_antag_datums() //For the Lazy amongst us.
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		A.on_removal()

/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	if(!datum_type)
		return
	. = FALSE
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		if(check_subtypes && istype(A, datum_type))
			return A
		else if(A.type == datum_type)
			return A

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
	if(src in SSticker.mode.changelings)
		SSticker.mode.changelings -= src
		current.remove_changeling_powers()
		if(changeling)
			qdel(changeling)
			changeling = null
	special_role = null
	remove_antag_equip()
	SSticker.mode.update_changeling_icons_removed(src)

/datum/mind/proc/remove_traitor()
	if(src in SSticker.mode.traitors)
		src.remove_antag_datum(ANTAG_DATUM_TRAITOR)
	SSticker.mode.update_traitor_icons_removed(src)

/datum/mind/proc/remove_nukeop()
	if(src in SSticker.mode.syndicates)
		SSticker.mode.syndicates -= src
		SSticker.mode.update_synd_icons_removed(src)
	special_role = null
	remove_objectives()
	remove_antag_equip()

/datum/mind/proc/remove_wizard()
	if(src in SSticker.mode.wizards)
		SSticker.mode.wizards -= src
		current.spellremove(current)
	special_role = null
	remove_antag_equip()

/datum/mind/proc/remove_cultist()
	if(src in SSticker.mode.cult)
		SSticker.mode.remove_cultist(src, 0, 0)
	special_role = null
	remove_objectives()
	remove_antag_equip()

/datum/mind/proc/remove_rev()
	if(src in SSticker.mode.revolutionaries)
		SSticker.mode.revolutionaries -= src
		SSticker.mode.update_rev_icons_removed(src)
	if(src in SSticker.mode.head_revolutionaries)
		SSticker.mode.head_revolutionaries -= src
		SSticker.mode.update_rev_icons_removed(src)
	special_role = null
	remove_objectives()
	remove_antag_equip()


/datum/mind/proc/remove_gang()
		SSticker.mode.remove_gangster(src,0,1,1)
		remove_objectives()

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
	SSticker.mode.update_changeling_icons_removed(src)
	SSticker.mode.update_traitor_icons_removed(src)
	SSticker.mode.update_wiz_icons_removed(src)
	SSticker.mode.update_cult_icons_removed(src)
	SSticker.mode.update_rev_icons_removed(src)
	if(gang_datum)
		gang_datum.remove_gang_hud(src)

/datum/mind/proc/equip_traitor(var/employer = "The Syndicate", var/silent = FALSE)
	if(!current)
		return
	var/mob/living/carbon/human/traitor_mob = current
	if (!istype(traitor_mob))
		return
	. = 1

	var/list/all_contents = traitor_mob.GetAllContents()
	var/obj/item/device/pda/PDA = locate() in all_contents
	var/obj/item/device/radio/R = locate() in all_contents
	var/obj/item/weapon/pen/P = locate() in all_contents //including your PDA-pen!

	var/obj/item/uplink_loc

	if(traitor_mob.client && traitor_mob.client.prefs)
		switch(traitor_mob.client.prefs.uplink_spawn_loc)
			if(UPLINK_PDA)
				uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = R
				if(!uplink_loc)
					uplink_loc = P
			if(UPLINK_RADIO)
				uplink_loc = R
				if(!uplink_loc)
					uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = P
			if(UPLINK_PEN)
				uplink_loc = P
				if(!uplink_loc)
					uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = R

	if (!uplink_loc)
		if(!silent) to_chat(traitor_mob, "Unfortunately, [employer] wasn't able to get you an Uplink.")
		. = 0
	else
		var/obj/item/device/uplink/U = new(uplink_loc)
		U.owner = "[traitor_mob.key]"
		uplink_loc.hidden_uplink = U

		if(uplink_loc == R)
			R.traitor_frequency = sanitize_frequency(rand(MIN_FREQ, MAX_FREQ))

			if(!silent) to_chat(traitor_mob, "[employer] has cunningly disguised a Syndicate Uplink as your [R.name]. Simply dial the frequency [format_frequency(R.traitor_frequency)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Frequency:</B> [format_frequency(R.traitor_frequency)] ([R.name]).")

		else if(uplink_loc == PDA)
			PDA.lock_code = "[rand(100,999)] [pick("Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu")]"

			if(!silent) to_chat(traitor_mob, "[employer] has cunningly disguised a Syndicate Uplink as your [PDA.name]. Simply enter the code \"[PDA.lock_code]\" into the ringtone select to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [PDA.lock_code] ([PDA.name]).")

		else if(uplink_loc == P)
			P.traitor_unlock_degrees = rand(1, 360)

			if(!silent) to_chat(traitor_mob, "[employer] has cunningly disguised a Syndicate Uplink as your [P.name]. Simply twist the top of the pen [P.traitor_unlock_degrees] from its starting position to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink Degrees:</B> [P.traitor_unlock_degrees] ([P.name]).")

//Link a new mobs mind to the creator of said mob. They will join any team they are currently on, and will only switch teams when their creator does.

/datum/mind/proc/enslave_mind_to_creator(mob/living/creator)
	if(iscultist(creator))
		SSticker.mode.add_cultist(src)

	else if(is_gangster(creator))
		SSticker.mode.add_gangster(src, creator.mind.gang_datum, TRUE)

	else if(is_revolutionary_in_general(creator))
		SSticker.mode.add_revolutionary(src)

	else if(is_servant_of_ratvar(creator))
		add_servant_of_ratvar(current)

	else if(is_nuclear_operative(creator))
		make_Nuke(null, null, 0, FALSE)

	enslaved_to = creator

	current.faction |= creator.faction
	creator.faction |= current.faction

	if(creator.mind.special_role)
		message_admins("[ADMIN_LOOKUPFLW(current)] has been created by [ADMIN_LOOKUPFLW(creator)], an antagonist.")
		to_chat(current, "<span class='userdanger'>Despite your creators current allegiances, your true master remains [creator.real_name]. If their loyalities change, so do yours. This will never change unless your creator's body is destroyed.</span>")

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
	else if(objectives.len || memory)
		to_chat(recipient, "<i>[output]</i>")

/datum/mind/proc/edit_memory()
	if(!SSticker.HasRoundStarted())
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
		"clockcult",
		"devil",
		"ninja"
	)
	var/text = ""

	if(ishuman(current))
		/** REVOLUTION ***/
		text = "revolution"
		if (SSticker.mode.config_tag=="revolution")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (assigned_role in GLOB.command_positions)
			text += "<b>HEAD</b>|loyal|employee|headrev|rev"
		else if (src in SSticker.mode.head_revolutionaries)
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
		else if(current.isloyal())
			text += "head|<b>LOYAL</b>|employee|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|rev"
		else if (src in SSticker.mode.revolutionaries)
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
		if (SSticker.mode.config_tag=="gang")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		text += "[current.isloyal() ? "<B>LOYAL</B>" : "loyal"]|"
		if(src in SSticker.mode.get_all_gangsters())
			text += "<a href='?src=\ref[src];gang=clear'>none</a>"
		else
			text += "<B>NONE</B>"

		if(current && current.client && (ROLE_GANG in current.client.prefs.be_special))
			text += "|Enabled in Prefs<BR>"
		else
			text += "|Disabled in Prefs<BR>"

		for(var/datum/gang/G in SSticker.mode.gangs)
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

		if(GLOB.gang_colors_pool.len)
			text += "<a href='?src=\ref[src];gang=new'>Create New Gang</a>"

		sections["gang"] = text

		/** Abductors **/
		text = "Abductor"
		if(SSticker.mode.config_tag == "abductor")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in SSticker.mode.abductors)
			text += "<b>Abductor</b>|<a href='?src=\ref[src];abductor=clear'>human</a>"
			text += "|<a href='?src=\ref[src];common=undress'>undress</a>|<a href='?src=\ref[src];abductor=equip'>equip</a>"
		else
			text += "<a href='?src=\ref[src];abductor=abductor'>Abductor</a>|<b>human</b>"

		if(current && current.client && (ROLE_ABDUCTOR in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["abductor"] = text

		/** NUCLEAR ***/
		text = "nuclear"
		if (SSticker.mode.config_tag=="nuclear")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in SSticker.mode.syndicates)
			text += "<b>OPERATIVE</b>|<a href='?src=\ref[src];nuclear=clear'>nanotrasen</a>"
			text += "<br><a href='?src=\ref[src];nuclear=lair'>To shuttle</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];nuclear=dressup'>dress up</a>."
			var/code
			for (var/obj/machinery/nuclearbomb/bombue in GLOB.machines)
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

		/** WIZARD ***/
		text = "wizard"
		if (SSticker.mode.config_tag=="wizard")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if ((src in SSticker.mode.wizards) || (src in SSticker.mode.apprentices))
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

	/** CULT ***/
	text = "cult"
	if (SSticker.mode.config_tag=="cult")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(iscultist(current))
		text += "loyal|<a href='?src=\ref[src];cult=clear'>employee</a>|<b>CULTIST</b>"
		text += "<br>Give <a href='?src=\ref[src];cult=tome'>tome</a>|<a href='?src=\ref[src];cult=amulet'>amulet</a>."

	else if(current.isloyal())
		text += "<b>LOYAL</b>|employee|<a href='?src=\ref[src];cult=cultist'>cultist</a>"
	else if(is_convertable_to_cult(current))
		text += "loyal|<b>EMPLOYEE</b>|<a href='?src=\ref[src];cult=cultist'>cultist</a>"
	else
		text += "loyal|<b>EMPLOYEE</b>|<i>cannot serve Nar-Sie</i>"

	if(current && current.client && (ROLE_CULTIST in current.client.prefs.be_special))
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"

	sections["cult"] = text

	/** CLOCKWORK CULT **/
	text = "clockwork cult"
	if(SSticker.mode.config_tag == "clockwork cult")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(is_servant_of_ratvar(current))
		text += "loyal|<a href='?src=\ref[src];clockcult=clear'>employee</a>|<b>SERVANT</b>"
		text += "<br><a href='?src=\ref[src];clockcult=slab'>Give slab</a>"
	else if(current.isloyal())
		text += "<b>LOYAL</b>|employee|<a href='?src=\ref[src];clockcult=servant'>servant</a>"
	else if(is_eligible_servant(current))
		text += "loyal|<b>EMPLOYEE</b>|<a href='?src=\ref[src];clockcult=servant'>servant</a>"
	else
		text += "loyal|<b>EMPLOYEE</b>|<i>cannot serve Ratvar</i>"

	if(current && current.client && (ROLE_SERVANT_OF_RATVAR in current.client.prefs.be_special))
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"

	sections["clockcult"] = text

	/** TRAITOR ***/
	text = "traitor"
	if (SSticker.mode.config_tag=="traitor" || SSticker.mode.config_tag=="traitorchan")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if (src in SSticker.mode.traitors)
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

	if(ishuman(current) || ismonkey(current))

		/** CHANGELING ***/
		text = "changeling"
		if (SSticker.mode.config_tag=="changeling" || SSticker.mode.config_tag=="traitorchan")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if ((src in SSticker.mode.changelings) && special_role)
			text += "<b>YES</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
			if(changeling && changeling.stored_profiles.len && (current.real_name != changeling.first_prof.name) )
				text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
		else if(src in SSticker.mode.changelings) //Station Aligned Changeling
			text += "<b>YES (but not an antag)</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
			if(changeling && changeling.stored_profiles.len && (current.real_name != changeling.first_prof.name) )
				text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
		else
			text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"

		if(current && current.client && (ROLE_CHANGELING in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["changeling"] = text

		/** MONKEY ***/
		text = "monkey"
		if (SSticker.mode.config_tag=="monkey")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (ishuman(current))
			text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<b>HUMAN</b>|other"
		else if(ismonkey(current))
			var/found = FALSE
			for(var/datum/disease/transformation/jungle_fever/JF in current.viruses)
				found = TRUE
				break

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
	if(SSticker.mode.config_tag == "devil")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	var/datum/antagonist/devil/devilinfo = has_antag_datum(ANTAG_DATUM_DEVIL)
	if(devilinfo)
		if(!devilinfo.ascendable)
			text += "<b>DEVIL</b>|<a href='?src=\ref[src];devil=ascendable_devil'>Ascendable Devil</a>|sintouched|<a href='?src=\ref[src];devil=clear'>human</a>"
		else
			text += "<a href='?src=\ref[src];devil=devil'>DEVIL</a>|<b>ASCENDABLE DEVIL</b>|sintouched|<a href='?src=\ref[src];devil=clear'>human</a>"
	else if(src in SSticker.mode.sintouched)
		text += "devil|Ascendable Devil|<b>SINTOUCHED</b>|<a href='?src=\ref[src];devil=clear'>human</a>"
	else
		text += "<a href='?src=\ref[src];devil=devil'>devil</a>|<a href='?src=\ref[src];devil=ascendable_devil'>Ascendable Devil</a>|<a href='?src=\ref[src];devil=sintouched'>sintouched</a>|<b>HUMAN</b>"

	if(current && current.client && (ROLE_DEVIL in current.client.prefs.be_special))
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"
	sections["devil"] = text

/** NINJA ***/
	text = "ninja"
	if(SSticker.mode.config_tag == "ninja")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	var/datum/antagonist/ninja/ninjainfo = has_antag_datum(ANTAG_DATUM_NINJA)
	if(ninjainfo)
		if(ninjainfo.helping_station)
			text += "<a href='?src=\ref[src];ninja=clear'>employee</a> | syndicate | <b>NANOTRASEN</b> | <b><a href='?src=\ref[src];ninja=equip'>EQUIP</a></b>"
		else
			text += "<a href='?src=\ref[src];ninja=clear'>employee</a> | <b>SYNDICATE</b> | nanotrasen | <b><a href='?src=\ref[src];ninja=equip'>EQUIP</a></b>"
	else
		text += "<b>EMPLOYEE</b> | <a href='?src=\ref[src];ninja=syndicate'>syndicate</a> | <a href='?src=\ref[src];ninja=nanotrasen'>nanotrasen</a> | <a href='?src=\ref[src];ninja=random'>random allegiance</a>"
	if(current && current.client && (ROLE_NINJA in current.client.prefs.be_special))
		text += " | Enabled in Prefs"
	else
		text += " | Disabled in Prefs"
	sections["ninja"] = text


/** SILICON ***/
	if(issilicon(current))
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
	if (SSticker.mode.config_tag == "traitorchan")
		if (sections["traitor"])
			out += sections["traitor"]+"<br>"
		if (sections["changeling"])
			out += sections["changeling"]+"<br><br>"
		sections -= "traitor"
		sections -= "changeling"
	else
		if (sections[SSticker.mode.config_tag])
			out += sections[SSticker.mode.config_tag]+"<br><br>"
		sections -= SSticker.mode.config_tag
	for (var/i in sections)
		if (sections[i])
			out += sections[i]+"<br>"


	if(((src in SSticker.mode.head_revolutionaries) || (src in SSticker.mode.traitors) || (src in SSticker.mode.syndicates)) && ishuman(current))

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

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "maroon", "debrain", "protect", "destroy", "prevent", "hijack", "escape", "survive", "martyr", "steal", "download", "nuclear", "capture", "absorb", "custom")
		if (!new_obj_type)
			return

		var/datum/objective/new_objective = null

		switch (new_obj_type)
			if ("assassinate","protect","debrain","maroon")
				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in SSticker.minds)
					if ((possible_target != src) && ishuman(possible_target.current))
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
					to_chat(usr, "No active AIs with minds")

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

	else if (href_list["revolution"])
		switch(href_list["revolution"])
			if("clear")
				remove_rev()
				to_chat(current, "<span class='userdanger'>You have been brainwashed! You are no longer a revolutionary!</span>")
				message_admins("[key_name_admin(usr)] has de-rev'ed [current].")
				log_admin("[key_name(usr)] has de-rev'ed [current].")
			if("rev")
				if(src in SSticker.mode.head_revolutionaries)
					SSticker.mode.head_revolutionaries -= src
					SSticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='userdanger'>Revolution has been disappointed of your leader traits! You are a regular revolutionary now!</span>")
				else if(!(src in SSticker.mode.revolutionaries))
					to_chat(current, "<span class='danger'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
				else
					return
				SSticker.mode.revolutionaries += src
				SSticker.mode.update_rev_icons_added(src)
				special_role = "Revolutionary"
				message_admins("[key_name_admin(usr)] has rev'ed [current].")
				log_admin("[key_name(usr)] has rev'ed [current].")

			if("headrev")
				if(src in SSticker.mode.revolutionaries)
					SSticker.mode.revolutionaries -= src
					SSticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='userdanger'>You have proved your devotion to revoltion! Yea are a head revolutionary now!</span>")
				else if(!(src in SSticker.mode.head_revolutionaries))
					to_chat(current, "<span class='userdanger'>You are a member of the revolutionaries' leadership now!</span>")
				else
					return
				if (SSticker.mode.head_revolutionaries.len>0)
					// copy targets
					var/datum/mind/valid_head = locate() in SSticker.mode.head_revolutionaries
					if (valid_head)
						for (var/datum/objective/mutiny/O in valid_head.objectives)
							var/datum/objective/mutiny/rev_obj = new
							rev_obj.owner = src
							rev_obj.target = O.target
							rev_obj.explanation_text = "Assassinate [O.target.name], the [O.target.assigned_role]."
							objectives += rev_obj
						SSticker.mode.greet_revolutionary(src,0)
				SSticker.mode.head_revolutionaries += src
				SSticker.mode.update_rev_icons_added(src)
				special_role = "Head Revolutionary"
				message_admins("[key_name_admin(usr)] has head-rev'ed [current].")
				log_admin("[key_name(usr)] has head-rev'ed [current].")

			if("autoobjectives")
				SSticker.mode.forge_revolutionary_objectives(src)
				SSticker.mode.greet_revolutionary(src,0)
				to_chat(usr, "<span class='notice'>The objectives for revolution have been generated and shown to [key]</span>")

			if("flash")
				if (!SSticker.mode.equip_revolutionary(current))
					to_chat(usr, "<span class='danger'>Spawning flash failed!</span>")

			if("takeflash")
				var/list/L = current.get_contents()
				var/obj/item/device/assembly/flash/flash = locate() in L
				if (!flash)
					to_chat(usr, "<span class='danger'>Deleting flash failed!</span>")
				qdel(flash)

			if("repairflash")
				var/list/L = current.get_contents()
				var/obj/item/device/assembly/flash/flash = locate() in L
				if (!flash)
					to_chat(usr, "<span class='danger'>Repairing flash failed!</span>")
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
				switch(SSticker.mode.equip_gang(current,gang_datum))
					if(1)
						to_chat(usr, "<span class='warning'>Unable to equip territory spraycan!</span>")
					if(2)
						to_chat(usr, "<span class='warning'>Unable to equip recruitment pen and spraycan!</span>")
					if(3)
						to_chat(usr, "<span class='warning'>Unable to equip gangtool, pen, and spraycan!</span>")

			if("takeequip")
				var/list/L = current.get_contents()
				for(var/obj/item/weapon/pen/gang/pen in L)
					qdel(pen)
				for(var/obj/item/device/gangtool/gangtool in L)
					qdel(gangtool)
				for(var/obj/item/toy/crayon/spraycan/gang/SC in L)
					qdel(SC)

			if("new")
				if(GLOB.gang_colors_pool.len)
					var/list/names = list("Random") + GLOB.gang_name_pool
					var/gangname = input("Pick a gang name.","Select Name") as null|anything in names
					if(gangname && GLOB.gang_colors_pool.len) //Check again just in case another admin made max gangs at the same time
						if(!(gangname in GLOB.gang_name_pool))
							gangname = null
						var/datum/gang/newgang = new(null,gangname)
						SSticker.mode.gangs += newgang
						message_admins("[key_name_admin(usr)] has created the [newgang.name] Gang.")
						log_admin("[key_name(usr)] has created the [newgang.name] Gang.")

	else if (href_list["gangboss"])
		var/datum/gang/G = locate(href_list["gangboss"]) in SSticker.mode.gangs
		if(!G || (src in G.bosses))
			return
		SSticker.mode.remove_gangster(src,0,2,1)
		G.bosses[src] = GANGSTER_BOSS_STARTING_INFLUENCE
		gang_datum = G
		special_role = "[G.name] Gang Boss"
		G.add_gang_hud(src)
		to_chat(current, "<FONT size=3 color=red><B>You are a [G.name] Gang Boss!</B></FONT>")
		message_admins("[key_name_admin(usr)] has added [current] to the [G.name] Gang leadership.")
		log_admin("[key_name(usr)] has added [current] to the [G.name] Gang leadership.")
		SSticker.mode.forge_gang_objectives(src)
		SSticker.mode.greet_gang(src,0)

	else if (href_list["gangster"])
		var/datum/gang/G = locate(href_list["gangster"]) in SSticker.mode.gangs
		if(!G || (src in G.gangsters))
			return
		SSticker.mode.remove_gangster(src,0,2,1)
		SSticker.mode.add_gangster(src,G,0)
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
				if(!(src in SSticker.mode.cult))
					SSticker.mode.add_cultist(src, 0)
					message_admins("[key_name_admin(usr)] has cult'ed [current].")
					log_admin("[key_name(usr)] has cult'ed [current].")
			if("tome")
				if (!SSticker.mode.equip_cultist(current,1))
					to_chat(usr, "<span class='danger'>Spawning tome failed!</span>")

			if("amulet")
				if (!SSticker.mode.equip_cultist(current))
					to_chat(usr, "<span class='danger'>Spawning amulet failed!</span>")

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
				if(!SSticker.mode.equip_servant(current))
					to_chat(usr, "<span class='warning'>Failed to outfit [current] with a slab!</span>")
				else
					to_chat(usr, "<span class='notice'>Successfully gave [current] a clockwork slab!</span>")

	else if (href_list["wizard"])
		switch(href_list["wizard"])
			if("clear")
				remove_wizard()
				to_chat(current, "<span class='userdanger'>You have been brainwashed! You are no longer a wizard!</span>")
				log_admin("[key_name(usr)] has de-wizard'ed [current].")
				SSticker.mode.update_wiz_icons_removed(src)
			if("wizard")
				if(!(src in SSticker.mode.wizards))
					SSticker.mode.wizards += src
					special_role = "Wizard"
					//SSticker.mode.learn_basic_spells(current)
					to_chat(current, "<span class='boldannounce'>You are the Space Wizard!</span>")
					message_admins("[key_name_admin(usr)] has wizard'ed [current].")
					log_admin("[key_name(usr)] has wizard'ed [current].")
					SSticker.mode.update_wiz_icons_added(src)
			if("lair")
				current.loc = pick(GLOB.wizardstart)
			if("dressup")
				SSticker.mode.equip_wizard(current)
			if("name")
				SSticker.mode.name_wizard(current)
			if("autoobjectives")
				SSticker.mode.forge_wizard_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for wizard [key] have been generated. You can edit them and anounce manually.</span>")

	else if (href_list["changeling"])
		switch(href_list["changeling"])
			if("clear")
				remove_changeling()
				to_chat(current, "<span class='userdanger'>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</span>")
				message_admins("[key_name_admin(usr)] has de-changeling'ed [current].")
				log_admin("[key_name(usr)] has de-changeling'ed [current].")
			if("changeling")
				if(!(src in SSticker.mode.changelings))
					SSticker.mode.changelings += src
					current.make_changeling()
					special_role = "Changeling"
					to_chat(current, "<span class='boldannounce'>Your powers are awoken. A flash of memory returns to us...we are [changeling.changelingID], a changeling!</span>")
					message_admins("[key_name_admin(usr)] has changeling'ed [current].")
					log_admin("[key_name(usr)] has changeling'ed [current].")
					SSticker.mode.update_changeling_icons_added(src)
			if("autoobjectives")
				SSticker.mode.forge_changeling_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and anounce manually.</span>")

			if("initialdna")
				if( !changeling || !changeling.stored_profiles.len || !iscarbon(current))
					to_chat(usr, "<span class='danger'>Resetting DNA failed!</span>")
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
				to_chat(current, "<span class='userdanger'>You have been brainwashed! You are no longer a syndicate operative!</span>")
				message_admins("[key_name_admin(usr)] has de-nuke op'ed [current].")
				log_admin("[key_name(usr)] has de-nuke op'ed [current].")
			if("nuclear")
				if(!(src in SSticker.mode.syndicates))
					SSticker.mode.syndicates += src
					SSticker.mode.update_synd_icons_added(src)
					if (SSticker.mode.syndicates.len==1)
						SSticker.mode.prepare_syndicate_leader(src)
					else
						current.real_name = "[syndicate_name()] Operative #[SSticker.mode.syndicates.len-1]"
					special_role = "Syndicate"
					assigned_role = "Syndicate"
					to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
					SSticker.mode.forge_syndicate_objectives(src)
					SSticker.mode.greet_syndicate(src)
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

				if (!SSticker.mode.equip_syndicate(current))
					to_chat(usr, "<span class='danger'>Equipping a syndicate failed!</span>")
			if("tellcode")
				var/code
				for (var/obj/machinery/nuclearbomb/bombue in GLOB.machines)
					if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if (code)
					store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0, 0)
					to_chat(current, "The nuclear authorization code is: <B>[code]</B>")
				else
					to_chat(usr, "<span class='danger'>No valid nuke found!</span>")

	else if (href_list["traitor"])
		switch(href_list["traitor"])
			if("clear")
				to_chat(current, "<span class='userdanger'>You have been brainwashed!</span>")
				remove_traitor()
				message_admins("[key_name_admin(usr)] has de-traitor'ed [current].")
				log_admin("[key_name(usr)] has de-traitor'ed [current].")
				SSticker.mode.update_traitor_icons_removed(src)

			if("traitor")
				if(!(src in SSticker.mode.traitors))
					message_admins("[key_name_admin(usr)] has traitor'ed [current].")
					log_admin("[key_name(usr)] has traitor'ed [current].")
					make_Traitor()

			if("autoobjectives")
				var/datum/antagonist/traitor/traitordatum = has_antag_datum(ANTAG_DATUM_TRAITOR)
				if(!traitordatum)
					message_admins("[key_name_admin(usr)] has traitor'ed [current] as part of autoobjectives.")
					log_admin("[key_name(usr)] has traitor'ed [current] as part of autoobjectives.")
					make_Traitor()
				else
					log_admin("[key_name(usr)] has forged objectives for [current] as part of autoobjectives.")
					traitordatum.forge_traitor_objectives()
					to_chat(usr, "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and anounce manually.</span>")

	else if(href_list["devil"])
		var/datum/antagonist/devil/devilinfo = has_antag_datum(ANTAG_DATUM_DEVIL)
		switch(href_list["devil"])
			if("clear")
				if(src in SSticker.mode.devils)
					remove_devil(current)
					message_admins("[key_name_admin(usr)] has de-devil'ed [current].")
					log_admin("[key_name(usr)] has de-devil'ed [current].")
				if(src in SSticker.mode.sintouched)
					SSticker.mode.sintouched -= src
					message_admins("[key_name_admin(usr)] has de-sintouch'ed [current].")
					log_admin("[key_name(usr)] has de-sintouch'ed [current].")
			if("devil")
				if(devilinfo)
					devilinfo.ascendable = FALSE
					message_admins("[key_name_admin(usr)] has made [current] unable to ascend as a devil.")
					log_admin("[key_name_admin(usr)] has made [current] unable to ascend as a devil.")
					return
				if(!ishuman(current) && !iscyborg(current))
					to_chat(usr, "<span class='warning'>This only works on humans and cyborgs!</span>")
					return
				add_devil(current, FALSE)
				message_admins("[key_name_admin(usr)] has devil'ed [current].")
				log_admin("[key_name(usr)] has devil'ed [current].")
			if("ascendable_devil")
				if(devilinfo)
					devilinfo.ascendable = TRUE
					message_admins("[key_name_admin(usr)] has made [current] able to ascend as a devil.")
					log_admin("[key_name_admin(usr)] has made [current] able to ascend as a devil.")
					return
				if(!ishuman(current) && !iscyborg(current))
					to_chat(usr, "<span class='warning'>This only works on humans and cyborgs!</span>")
					return
				add_devil(current, TRUE)
				message_admins("[key_name_admin(usr)] has devil'ed [current].  The devil has been marked as ascendable.")
				log_admin("[key_name(usr)] has devil'ed [current]. The devil has been marked as ascendable.")
			if("sintouched")
				if(ishuman(current))
					var/mob/living/carbon/human/H = current
					H.influenceSin()
					message_admins("[key_name_admin(usr)] has sintouch'ed [current].")
				else
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
	else if(href_list["ninja"])
		var/datum/antagonist/ninja/ninjainfo = has_antag_datum(ANTAG_DATUM_NINJA)
		switch(href_list["ninja"])
			if("clear")
				remove_ninja(current)
				message_admins("[key_name_admin(usr)] has de-ninja'ed [current].")
				log_admin("[key_name(usr)] has de-ninja'ed [current].")
			if("equip")
				ninjainfo.equip_space_ninja()
				return
			if("nanotrasen")
				add_ninja(current, ANTAG_DATUM_NINJA_FRIENDLY)
				message_admins("[key_name_admin(usr)] has friendly ninja'ed [current].")
				log_admin("[key_name(usr)] has friendly ninja'ed [current].")
			if("syndicate")
				add_ninja(current, ANTAG_DATUM_NINJA)
				message_admins("[key_name_admin(usr)] has syndie ninja'ed [current].")
				log_admin("[key_name(usr)] has syndie ninja'ed [current].")
			if("random")
				add_ninja(current)
				message_admins("[key_name_admin(usr)] has random ninja'ed [current].")
				log_admin("[key_name(usr)] has random ninja'ed [current].")
	else if(href_list["abductor"])
		switch(href_list["abductor"])
			if("clear")
				to_chat(usr, "Not implemented yet. Sorry!")
				//SSticker.mode.update_abductor_icons_removed(src)
			if("abductor")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				make_Abductor()
				log_admin("[key_name(usr)] turned [current] into abductor.")
				SSticker.mode.update_abductor_icons_added(src)
			if("equip")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return

				var/mob/living/carbon/human/H = current
				var/gear = alert("Agent or Scientist Gear","Gear","Agent","Scientist")
				if(gear)
					if(gear=="Agent")
						H.equipOutfit(/datum/outfit/abductor/agent)
					else
						H.equipOutfit(/datum/outfit/abductor/scientist)

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
						//to_chat(world, "DEBUG: \"healthy\": M=[M], M.mind=[M.mind], src=[src]!")
					else if (istype(M) && length(M.viruses))
						for(var/thing in M.viruses)
							var/datum/disease/D = thing
							D.cure(0)
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
						for(var/datum/disease/transformation/jungle_fever/JF in M.viruses)
							JF.cure(0)
							sleep(0) //because deleting of virus is doing throught spawn(0) //What
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
				if(isAI(current))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.SetEmagged(0)
					message_admins("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")
					log_admin("[key_name(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.dropItemToGround(W, TRUE) //The 1 forces all items to drop, since this is an admin undress.
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
				if(!equip_traitor())
					to_chat(usr, "<span class='danger'>Equipping a syndicate failed!</span>")
					log_admin("[key_name(usr)] tried and failed to give [current] an uplink.")
				else
					log_admin("[key_name(usr)] gave [current] an uplink.")

	else if (href_list["obj_announce"])
		announce_objectives()

	edit_memory()

/datum/mind/proc/announce_objectives()
	var/obj_count = 1
	to_chat(current, "<span class='notice'>Your current objectives:</span>")
	for(var/objective in objectives)
		var/datum/objective/O = objective
		to_chat(current, "<B>Objective #[obj_count]</B>: [O.explanation_text]")
		obj_count++

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.GetAllContents()
	for (var/obj/item/I in L)
		if (I.hidden_uplink)
			return I.hidden_uplink
	return null

/datum/mind/proc/take_uplink()
	var/obj/item/device/uplink/H = find_syndicate_uplink()
	if(H)
		qdel(H)

/datum/mind/proc/make_Traitor()
	if(!(has_antag_datum(ANTAG_DATUM_TRAITOR)))
		var/datum/antagonist/traitor/traitordatum = add_antag_datum(ANTAG_DATUM_TRAITOR)
		return traitordatum


/datum/mind/proc/make_Nuke(turf/spawnloc, nuke_code, leader=0, telecrystals = TRUE)
	if(!(src in SSticker.mode.syndicates))
		SSticker.mode.syndicates += src
		SSticker.mode.update_synd_icons_added(src)
		special_role = "Syndicate"
		SSticker.mode.forge_syndicate_objectives(src)
		SSticker.mode.greet_syndicate(src)
		current.faction |= "syndicate"

		if(spawnloc)
			current.loc = spawnloc

		if(ishuman(current))
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

			SSticker.mode.equip_syndicate(current, telecrystals)

		if (nuke_code)
			store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
			to_chat(current, "The nuclear authorization code is: <B>[nuke_code]</B>")
		else
			var/obj/machinery/nuclearbomb/nuke = locate("syndienuke") in GLOB.nuke_list
			if(nuke)
				store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke.r_code]", 0, 0)
				to_chat(current, "The nuclear authorization code is: <B>nuke.r_code</B>")
			else
				to_chat(current, "You were not provided with a nuclear code. Trying asking your team leader or contacting syndicate command.</B>")

		if (leader)
			SSticker.mode.prepare_syndicate_leader(src,nuke_code)
		else
			current.real_name = "[syndicate_name()] Operative #[SSticker.mode.syndicates.len-1]"

/datum/mind/proc/make_Changling()
	if(!(src in SSticker.mode.changelings))
		SSticker.mode.changelings += src
		current.make_changeling()
		special_role = "Changeling"
		SSticker.mode.forge_changeling_objectives(src)
		SSticker.mode.greet_changeling(src)
		SSticker.mode.update_changeling_icons_added(src)

/datum/mind/proc/make_Wizard()
	if(!(src in SSticker.mode.wizards))
		SSticker.mode.wizards += src
		special_role = "Wizard"
		assigned_role = "Wizard"
		if(!GLOB.wizardstart.len)
			SSjob.SendToLateJoin(current)
			to_chat(current, "HOT INSERTION, GO GO GO")
		else
			current.loc = pick(GLOB.wizardstart)

		SSticker.mode.equip_wizard(current)
		SSticker.mode.name_wizard(current)
		SSticker.mode.forge_wizard_objectives(src)
		SSticker.mode.greet_wizard(src)


/datum/mind/proc/make_Cultist()
	if(!(src in SSticker.mode.cult))
		SSticker.mode.add_cultist(src,FALSE)
		special_role = "Cultist"
		to_chat(current, "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy your world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>")
		to_chat(current, "<font color=\"purple\"><b><i>Assist your new bretheren in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>")
		var/datum/antagonist/cult/C
		C.cult_memorization(src)
	var/mob/living/carbon/human/H = current
	if (!SSticker.mode.equip_cultist(current))
		to_chat(H, "Spawning an amulet from your Master failed.")

/datum/mind/proc/make_Rev()
	if (SSticker.mode.head_revolutionaries.len>0)
		// copy targets
		var/datum/mind/valid_head = locate() in SSticker.mode.head_revolutionaries
		if (valid_head)
			for (var/datum/objective/mutiny/O in valid_head.objectives)
				var/datum/objective/mutiny/rev_obj = new
				rev_obj.owner = src
				rev_obj.target = O.target
				rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
				objectives += rev_obj
			SSticker.mode.greet_revolutionary(src,0)
	SSticker.mode.head_revolutionaries += src
	SSticker.mode.update_rev_icons_added(src)
	special_role = "Head Revolutionary"

	SSticker.mode.forge_revolutionary_objectives(src)
	SSticker.mode.greet_revolutionary(src,0)

	var/list/L = current.get_contents()
	var/obj/item/device/assembly/flash/flash = locate() in L
	qdel(flash)
	take_uplink()
	var/fail = 0
	fail |= !SSticker.mode.equip_revolutionary(current)


/datum/mind/proc/make_Gang(datum/gang/G)
	special_role = "[G.name] Gang Boss"
	G.bosses += src
	gang_datum = G
	G.add_gang_hud(src)
	SSticker.mode.forge_gang_objectives(src)
	SSticker.mode.greet_gang(src)
	SSticker.mode.equip_gang(current,G)

/datum/mind/proc/make_Abductor()
	var/role = alert("Abductor Role ?","Role","Agent","Scientist")
	var/team = input("Abductor Team ?","Team ?") in list(1,2,3,4)
	var/teleport = alert("Teleport to ship ?","Teleport","Yes","No")

	if(!role || !team || !teleport)
		return

	if(!ishuman(current))
		return

	SSticker.mode.abductors |= src

	var/datum/objective/experiment/O = new
	O.owner = src
	objectives += O

	var/mob/living/carbon/human/H = current

	H.set_species(/datum/species/abductor)
	var/datum/species/abductor/S = H.dna.species

	if(role == "Scientist")
		S.scientist = TRUE
	S.team = team

	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = 4
	scientist_landmarks.len = 4
	for(var/obj/effect/landmark/abductor/A in GLOB.landmarks_list)
		if(istype(A, /obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A, /obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/obj/effect/landmark/L
	if(teleport=="Yes")
		switch(role)
			if("Agent")
				L = agent_landmarks[team]
			if("Scientist")
				L = scientist_landmarks[team]
		H.forceMove(L.loc)

/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/S)
	spell_list += S
	S.action.Grant(current)

/datum/mind/proc/owns_soul()
	return soulOwner == src

//To remove a specific spell from a mind
/datum/mind/proc/RemoveSpell(obj/effect/proc_holder/spell/spell)
	if(!spell)
		return
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(istype(S, spell))
			spell_list -= S
			qdel(S)

/datum/mind/proc/transfer_martial_arts(mob/living/new_character)
	if(!ishuman(new_character))
		return
	if(martial_art)
		if(martial_art.base) //Is the martial art temporary?
			martial_art.remove(new_character)
		else
			martial_art.teach(new_character)

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
		S.updateButtonIcon()
		INVOKE_ASYNC(S, /obj/effect/proc_holder/spell.proc/start_recharge)

/datum/mind/proc/get_ghost(even_if_they_cant_reenter)
	for(var/mob/dead/observer/G in GLOB.dead_mob_list)
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

/mob/dead/new_player/sync_mind()
	return

/mob/dead/observer/sync_mind()
	return

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key

	else
		mind = new /datum/mind(key)
		SSticker.minds += mind
	if(!mind.name)
		mind.name = real_name
	mind.current = src

/mob/living/carbon/mind_initialize()
	..()
	last_mind = mind

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = "Assistant" //defualt

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	mind.special_role = "Alien"

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
