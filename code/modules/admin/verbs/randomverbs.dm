/client/proc/cmd_admin_drop_everything(mob/M as mob in world)
	set category = null
	set name = "Drop Everything"
	if(!holder)
		src << "Only administrators may use this command."
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		M.drop_from_inventory(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)
	feedback_add_details("admin_verb","DEVR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_prison(mob/M as mob in world)
	set category = "Admin"
	set name = "Prison"
	if(!holder)
		src << "Only administrators may use this command."
		return
	if (ismob(M))
		if(istype(M, /mob/living/silicon/ai))
			alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
			return
		//strip their stuff before they teleport into a cell :downs:
		for(var/obj/item/W in M)
			M.drop_from_inventory(W)
		//teleport person to cell
		M.Paralyse(5)
		sleep(5)	//so they black out before warping
		M.loc = pick(prisonwarp)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_if_possible(new /obj/item/clothing/under/color/orange(prisoner), prisoner.slot_w_uniform)
			prisoner.equip_if_possible(new /obj/item/clothing/shoes/orange(prisoner), prisoner.slot_shoes)
		spawn(50)
			M << "\red You have been sent to the prison station!"
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("\blue [key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.", 1)
		feedback_add_details("admin_verb","PRISON") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Subtle Message"

	if(!ismob(M))	return
	if (!holder)
		src << "Only administrators may use this command."
		return

	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text

	if (!msg)
		return
	if(usr)
		if (usr.client)
			if(usr.client.holder)
				M << "\bold You hear a voice in your head... \italic [msg]"

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins("\blue \bold SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] : [msg]", 1)
	feedback_add_details("admin_verb","SMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Special Verbs"
	set name = "Global Narrate"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text

	if (!msg)
		return
	world << "[msg]"
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("\blue \bold GlobalNarrate: [key_name_admin(usr)] : [msg]<BR>", 1)
	feedback_add_details("admin_verb","GLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(var/mob/M)	// Targetted narrate -- TLE
	set category = "Special Verbs"
	set name = "Direct Narrate"

	if(!holder)
		src << "Only administrators may use this command."
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text

	if( !msg )
		return

	M << msg
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	message_admins("\blue \bold DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]<BR>", 1)
	feedback_add_details("admin_verb","DIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Godmode"
	if(!holder)
		src << "Only administrators may use this command."
		return
	if (M.nodamage == 1)
		M.nodamage = 0
		usr << "\blue Toggled OFF"
	else
		M.nodamage = 1
		usr << "\blue Toggled ON"

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.nodamage ? "On" : "Off")]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.nodamage ? "On" : "Off")]", 1)
	feedback_add_details("admin_verb","GOD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(!automute)
		if(usr && usr.client)
			if(!usr.client.holder)
				src << "Only administrators may use this command."
				return
			if (M.client && M.client.holder && (M.client.holder.level >= usr.client.holder.level))
				alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
				return
	if(!M.client)
		src << "This mob doesn't have a client tied to it."
		return

	var/muteunmute = 0	//0 = unmuted; 1 = muted
	var/mute_string = "unknown"

	//The '| automute' thing ensures that if an automute is being applied by code, it always mutes to prevent any potential for automute to unmute someone who was muted.
	switch(mute_type)
		if(MUTE_IC)
			M.client.muted_ic = !M.client.muted_ic | automute
			muteunmute = M.client.muted_ic
			mute_string = "IC (say and emote)"
		if(MUTE_OOC)
			M.client.muted_ooc = !M.client.muted_ooc | automute
			muteunmute = M.client.muted_ooc
			mute_string = "OOC"
		if(MUTE_PRAY)
			M.client.muted_pray = !M.client.muted_pray | automute
			muteunmute = M.client.muted_pray
			mute_string = "pray"
		if(MUTE_ADMINHELP)
			M.client.muted_adminhelp = !M.client.muted_adminhelp | automute
			muteunmute = M.client.muted_adminhelp
			mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)
			M.client.muted_deadchat = !M.client.muted_deadchat | automute
			muteunmute = M.client.muted_deadchat
			mute_string = "deadchat and DSAY"
		if(MUTE_ALL)
			mute_string = "everything"
			if( M.client.muted_ic )
				M.client.muted_ic = 1
				M.client.muted_ooc = 1
				M.client.muted_pray = 1
				M.client.muted_adminhelp = 1
				M.client.muted_deadchat = 1
				muteunmute = 1
			else
				M.client.muted_ic = 0
				M.client.muted_ooc = 0
				M.client.muted_pray = 0
				M.client.muted_adminhelp = 0
				M.client.muted_deadchat = 0
				muteunmute = 0

	if(!automute)
		log_admin("[key_name(usr)] has [(muteunmute ? "muted" : "voiced")] [key_name(M)] from [mute_string]")
		message_admins("[key_name_admin(usr)] has [(muteunmute ? "muted" : "voiced")] [key_name_admin(M)] from [mute_string].", 1)

		M << "You have been [(muteunmute ? "muted" : "voiced")] from [mute_string] by [(usr.client.stealth)?"an admin":"[usr.client]"]."
		feedback_add_details("admin_verb","MUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		log_admin("SPAM AUTOMUTE: [(muteunmute ? "muted" : "voiced")] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [(muteunmute ? "muted" : "voiced")] [key_name_admin(M)] from [mute_string].", 1)

		M << "You have been [(muteunmute ? "muted" : "voiced")] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin."
		feedback_add_details("admin_verb","AUTOMUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_add_random_ai_law()
	set category = "Fun"
	set name = "Add Random AI Law"
	if(!holder)
		src << "Only administrators may use this command."
		return
	log_admin("[key_name(src)] has added a random AI law.")
	message_admins("[key_name_admin(src)] has added a random AI law.", 1)

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert")
		world << sound('ionstorm.ogg')

	IonStorm(0)
	feedback_add_details("admin_verb","ION") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

 /*
 Stealth spawns xenos
 Changed to accomodate specific spawning. It was annoying before. /N
  */
/client/proc/spawn_xeno()
	set category = "Fun"
	set name = "Spawn Xeno"
	set desc = "Spawns a xenomorph for all those boring rounds, without having you to do so manually."
	set popup_menu = 0

	if(!holder)
		src << "Only administrators may use this command."
		return

	create_xeno()
	feedback_add_details("admin_verb","X") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] spawned a xeno.")
	message_admins("\blue [key_name_admin(usr)] spawned a xeno.", 1)
	return

//I use this proc for respawn character too. /N
/proc/create_xeno(mob/dead/observer/G)
	var/alien_caste = alert(src, "Please choose which caste to spawn.",,"Hunter","Sentinel","Drone")

	var/obj/effect/landmark/spawn_here = xeno_spawn.len ? pick(xeno_spawn) : pick(latejoin)

	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter (spawn_here)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel (spawn_here)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone (spawn_here)

	// Picks a random ghost for the role if none is specified. Mostly a copy of alien burst code.
	var/candidates_list[] = list()
	if(G)//If G exists through a passed argument.
		candidates_list += G.client
	else//Else we need to find them.
		for(G in world)
			if(G.client)
				if(!G.client.holder && ((G.client.inactivity/10)/60) <= 5)
					candidates_list += G.client//We want their client, not their ghost.
	if(candidates_list.len)//If there are people to spawn.
		if(!G)//If G was not passed through an argument.
			var/client/G_client = input("Pick the client you want to respawn as a xeno.", "Active Players") as null|anything in candidates_list//It will auto-pick a person when there is only one candidate.
			if(G_client)//They may have logged out when the admin was choosing people. Or were not chosen. Would run time error otherwise.
				G = G_client.mob

		if(G)//If G exists.
			message_admins("\blue [key_name_admin(usr)] has spawned [G.key] as a filthy xeno.", 1)
			new_xeno.mind_initialize(G, alien_caste)
			new_xeno.key = G.key
		else//We won't be reporting duds.
			del(new_xeno)

		del(G)
		return

	alert("There are no available ghosts to throw into the xeno. Aborting command.")
	del(new_xeno)
	return

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Special Verbs"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."
	if(!holder)
		src << "Only administrators may use this command."
		return
	var/input = input(src, "Please specify which key will be respawned.", "Key", "")
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in world)
		if(G.client&&ckey(G.key)==ckey(input))
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		alert("There is no active key like that in the game or the person is not currently a ghost. Aborting command.")
		return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(src)//The mob being spawned.

	//Second, we check if they are an alien or monkey.
	var/adj_name = copytext(G_found.real_name,1,7)//What is their name?
	if(G_found.mind&&G_found.mind.special_role=="Alien")//If they have a mind, are they an alien?
		adj_name="alien "
	if( adj_name==("alien "||"monkey"))
		if(alert("This character appears to either be an an alien or monkey. Would you like to respawn them as such?",,"Yes","No")=="Yes")//If you do.
			switch(adj_name)//Let's check based on adjusted name.
				if("monkey")//A monkey. Monkeys don't have a mind, so we can safely spawn them here if needed.
					//TO DO: Monkeys may have a mind now. May need retooling.
					var/mob/living/carbon/monkey/M = new(pick(latejoin))//Spawn a monkey at latejoin.
					M.mind = G_found.mind
					if(M.mind)//If the mind is not null.
						M.mind.current = M
						M.key = G_found.key//They are now a monkey. Nothing else needs doing.
				if("alien ")//An alien. Aliens can have a mind which can be used to determine a few things.
					if(G_found.mind)
						var/turf/location = xeno_spawn.len ? pick(xeno_spawn) : pick(latejoin)//Location where they will be spawned.
						var/mob/living/carbon/alien/new_xeno//Null alien mob first.
						switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
							if("Hunter")
								new_xeno = new/mob/living/carbon/alien/humanoid/hunter(location)
							if("Sentinel")
								new_xeno = new/mob/living/carbon/alien/humanoid/sentinel(location)
							if("Drone")
								new_xeno = new/mob/living/carbon/alien/humanoid/drone(location)
							if("Queen")
								new_xeno = new/mob/living/carbon/alien/humanoid/queen(location)
							else//If we don't know what special role they have, for whatever reason, or they're a larva.
								create_xeno(G_found)
								return
						//Now to give them a new mind.
						new_xeno.mind = new
						new_xeno.mind.assigned_role = "Alien"
						new_xeno.mind.special_role = G_found.mind.special_role
						new_xeno.mind.key = G_found.key
						new_xeno.mind.current = new_xeno
						new_xeno.key = G_found.key
						new_xeno << "You have been fully respawned. Enjoy the game."
						message_admins("\blue [key_name_admin(usr)] has respawned [new_xeno.key] as a filthy xeno.", 1)
						//And we're done. Announcing other stuff is handled by spawn_xeno.
					else
						create_xeno(G_found)//Else we default to the standard command for spawning a xenomorph.
						return
			del(G_found)
			return
			//Monkeys aren't terribly important so we won't be announcing them. The proc basically ends here.
		else//Or not.
			G_found.mind=null//Null their mind so we don't screw things up ahead.
			G_found.real_name="[pick(pick(first_names_male,first_names_female))] [pick(last_names)]"//Give them a random real name.

	/*Third, we try and locate a record for the person being respawned through data_core.
	This isn't an exact science but it does the trick more often than not.*/
	var/datum/data/record/record_found//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind)//They must have a mind to reference the record. Here we also double check for aliens.
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
		for(var/datum/data/record/t in data_core.locked)
			if(t.fields["id"]==id)
				record_found = t//We shall now reference the record.
				break

	//Now we do some mind locating to see how to set up the rest of the character.
	if(G_found.mind)//If they had a previous mind.
		new_character.mind = G_found.mind
		new_character.mind.special_verbs = list()//New list because they will receive them again.
	else
		new_character.mind = new()
		ticker.minds += new_character.mind//And we'll add it to the minds database.
		new_character.mind.original = new_character//If they are respawning with a new character.
	if(!record_found)//We have to pick their role if they have no record.
		if(G_found.mind&&G_found.mind.assigned_role)//But they may have an assigned role already.
			new_character.mind.assigned_role = G_found.mind.assigned_role//Also makes sure our MODE people are equipped right later on.
		else
			var/assigned_role = input("Please specify which job the character will be respawned as.", "Assigned role") as null|anything in get_all_jobs()
			if(!assigned_role)	new_character.mind.assigned_role = "Assistant"//Defaults to assistant.
			else	new_character.mind.assigned_role = assigned_role

	if(!new_character.mind.assigned_role)	new_character.mind.assigned_role = "Assistant"//If they somehow got a null assigned role.
	new_character.mind.key = G_found.key//In case it's someone else playing as that character.
	new_character.mind.current = new_character//So that it can properly reference later if needed.
	new_character.mind.memory = ""//Memory erased so it doesn't get clunkered up with useless info. This means they may forget their previous mission--this is usually handled through objective code and recalling memory.

	//Here we either load their saved appearance or randomize it.
	var/datum/preferences/A = new()
	if(A.savefile_load(G_found))//If they have a save file. This will automatically load their parameters.
	//Note: savefile appearances are overwritten later on if the character has a data_core entry. By appearance, I mean the physical appearance.
		var/name_safety = G_found.real_name//Their saved parameters may include a random name. Also a safety in case they are playing a character that got their name after round start.
		A.copy_to(new_character)
		new_character.real_name = name_safety
		new_character.name = name_safety
	else
		if(record_found)//If they have a record we can determine a few things.
			new_character.real_name = record_found.fields["name"]//Not necessary to reference the record but I like to keep things uniform.
			new_character.name = record_found.fields["name"]
			new_character.gender = record_found.fields["sex"]//Sex
			new_character.age = record_found.fields["age"]//Age
			new_character.b_type = record_found.fields["b_type"]//Blood type
			//We will update their appearance when determining DNA.
		else
			new_character.gender = MALE
			if(alert("Save file not detected. Record data not detected. Please specify [G_found.real_name]'s gender.",,"Male","Female")=="Female")
				new_character.gender = FEMALE
			var/name_safety = G_found.real_name//Default is a random name so we want to save this.
			A.randomize_appearance_for(new_character)//Now we will randomize their appearance since we have no way of knowing what they look/looked like.
			new_character.real_name = name_safety
			new_character.name = name_safety

	//After everything above, it's time to initialize their DNA.
	if(record_found)//Pull up their name from database records if they did have a mind.
		new_character.dna = new()//Let's first give them a new DNA.
		new_character.dna.unique_enzymes = record_found.fields["b_dna"]//Enzymes are based on real name but we'll use the record for conformity.
		new_character.dna.struc_enzymes = record_found.fields["enzymes"]//This is the default of enzymes so I think it's safe to go with.
		new_character.dna.uni_identity = record_found.fields["identity"]//DNA identity is carried over.
		updateappearance(new_character,new_character.dna.uni_identity)//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
	else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
		new_character.dna.ready_dna(new_character)

	//Here we need to find where to spawn them.
	var/spawn_here = pick(latejoin)//"JoinLate" is a landmark which is deleted on round start. So, latejoin has to be used instead.
	new_character.loc = spawn_here
	//If they need to spawn elsewhere, they will be transferred there momentarily.

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	new_character.key = player_key//Throw them into the mob.

	//Now for special roles and equipment.
	switch(new_character.mind.special_role)
		if("Changeling")
			job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)
			new_character.make_changeling()
		if("traitor")
			job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)
			ticker.mode.equip_traitor(new_character)
		if("Wizard")
			new_character.loc = pick(wizardstart)
			//ticker.mode.learn_basic_spells(new_character)
			ticker.mode.equip_wizard(new_character)
		if("Syndicate")
			var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
			if(synd_spawn)
				new_character.loc = get_turf(synd_spawn)
			call(/datum/game_mode/proc/equip_syndicate)(new_character)
		if("Space Ninja")
			var/ninja_spawn[] = list()
			for(var/obj/effect/landmark/L in world)
				if(L.name=="carpspawn")
					ninja_spawn += L
			new_character.equip_space_ninja()
			new_character.internal = new_character.s_store
			new_character.internals.icon_state = "internal1"
			if(ninja_spawn.len)
				var/obj/effect/landmark/ninja_spawn_here = pick(ninja_spawn)
				new_character.loc = ninja_spawn_here.loc
		if("Death Commando")//Leaves them at late-join spawn.
			new_character.equip_death_commando()
			new_character.internal = new_character.s_store
			new_character.internals.icon_state = "internal1"
		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if("Cyborg")//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize()
					if(new_character.mind.special_role=="traitor")
						call(/datum/game_mode/proc/add_law_zero)(new_character)
				if("AI")
					new_character = new_character.AIize()
					if(new_character.mind.special_role=="traitor")
						call(/datum/game_mode/proc/add_law_zero)(new_character)
				//Add aliens.
				else
					job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!="MODE")//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				call(/mob/new_player/proc/ManifestLateSpawn)(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				call(/mob/new_player/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)

	message_admins("\blue [admin] has respawned [player_key] as [new_character.real_name].", 1)

	new_character << "You have been fully respawned. Enjoy the game."

	del(G_found)//Don't want to leave ghosts around.
	feedback_add_details("admin_verb","RSPCH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Fun"
	set name = "Add Custom AI law"
	if(!holder)
		src << "Only administrators may use this command."
		return
	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return
	for(var/mob/living/silicon/ai/M in world)
		if (M.stat == 2)
			usr << "Upload failed. No signal is being detected from the AI."
		else if (M.see_in_dark == 0)
			usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
		else
			M.add_ion_law(input)
			for(var/mob/living/silicon/ai/O in world)
				O << "\red " + input

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]", 1)

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert")
		world << sound('ionstorm.ogg')
	feedback_add_details("admin_verb","IONC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M as mob in world)
	set category = "Special Verbs"
	set name = "Rejuvenate"
	if(!holder)
		src << "Only administrators may use this command."
		return
	if(!mob)
		return
	if(!istype(M))
		alert("Cannot revive a ghost")
		return
	if(config.allow_admin_rev)
		M.revive()

		log_admin("[key_name(usr)] healed / revived [key_name(M)]")
		message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!", 1)
	else
		alert("Admin revive disabled")
	feedback_add_details("admin_verb","REJU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Special Verbs"
	set name = "Create Command Report"
	if(!holder)
		src << "Only administrators may use this command."
		return
	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null
	if(!input)
		return

	var/confirm = alert(src, "Do you want to announce the contents of the report to the crew?", "Announce", "Yes", "No")
	if(confirm == "Yes")
		command_alert(input);
		for (var/obj/machinery/computer/communications/C in machines)
			if(! (C.stat & (BROKEN|NOPOWER) ) )
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
				P.name = "paper- '[command_name()] Update.'"
				P.info = input
				C.messagetitle.Add("[command_name()] Update")
				C.messagetext.Add(P.info)
	else
		command_alert("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message");
		for (var/obj/machinery/computer/communications/C in machines)
			if(! (C.stat & (BROKEN|NOPOWER) ) )
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
				P.name = "paper- 'Classified [command_name()] Update.'"
				P.info = input
				C.messagetitle.Add("Classified [command_name()] Update")
				C.messagetext.Add(P.info)

	world << sound('commandreport.ogg')
	log_admin("[key_name(src)] has created a command report: [input]")
	message_admins("[key_name_admin(src)] has created a command report", 1)
	feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in world)
	set category = "Admin"
	set name = "Delete"

	if (!holder)
		src << "Only administrators may use this command."
		return

	if (alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] deleted [O] at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","DEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		del(O)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin"
	set name = "List free slots"

	if (!holder)
		src << "Only administrators may use this command."
		return
	if(job_master)
		for(var/datum/job/job in job_master.occupations)
			src << "[job.title]: [job.total_positions]"
	feedback_add_details("admin_verb","LFS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "Explosion"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null) return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null) return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null) return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20))
			if (alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion (O, devastation, heavy, light, flash)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "EM Pulse"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null) return

	if (heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an EM PUlse ([heavy],[light]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Gib"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]", 1)

	if(istype(M, /mob/dead/observer))
		gibs(M.loc, M.viruses)
		return

	M.gib()
	feedback_add_details("admin_verb","GIB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Fun"

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		if (istype(mob, /mob/dead/observer)) // so they don't spam gibs everywhere
			return
		else
			mob.gib()

		log_admin("[key_name(usr)] used gibself.")
		message_admins("\blue [key_name_admin(usr)] used gibself.", 1)
		feedback_add_details("admin_verb","GIBS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/*
/client/proc/cmd_manual_ban()
	set name = "Manual Ban"
	set category = "Special Verbs"
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	var/mob/M = null
	switch(alert("How would you like to ban someone today?", "Manual Ban", "Key List", "Enter Manually", "Cancel"))
		if("Key List")
			var/list/keys = list()
			for(var/mob/M in world)
				keys += M.client
			var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in keys
			if(!selection)
				return
			M = selection:mob
			if ((M.client && M.client.holder && (M.client.holder.level >= holder.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

	switch(alert("Temporary Ban?",,"Yes","No"))
	if("Yes")
		var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num
		if(!mins)
			return
		if(mins >= 525600) mins = 525599
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		if(M)
			AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
			M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
			M << "\red This is a temporary ban, it will be removed in [mins] minutes."
			M << "\red To try to resolve this matter head to http://ss13.donglabs.com/forum/"
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=[mins]&server=[dd_replacetext(config.server_name, "#", "")]")
			del(M.client)
			del(M)
		else

	if("No")
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
		M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
		M << "\red This is a permanent ban."
		M << "\red To try to resolve this matter head to http://ss13.donglabs.com/forum/"
		log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=perma&server=[dd_replacetext(config.server_name, "#", "")]")
		del(M.client)
		del(M)
*/

/client/proc/update_world()
	// If I see anyone granting powers to specific keys like the code that was here,
	// I will both remove their SVN access and permanently ban them from my servers.
	return

/client/proc/cmd_admin_check_contents(mob/living/M as mob in world)
	set category = "Special Verbs"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		usr << "[t]"
	feedback_add_details("admin_verb","CC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/* This proc is DEFERRED. Does not do anything.
/client/proc/cmd_admin_remove_plasma()
	set category = "Debug"
	set name = "Stabilize Atmos."
	if(!holder)
		src << "Only administrators may use this command."
		return
	feedback_add_details("admin_verb","STATM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
// DEFERRED
	spawn(0)
		for(var/turf/T in view())
			T.poison = 0
			T.oldpoison = 0
			T.tmppoison = 0
			T.oxygen = 755985
			T.oldoxy = 755985
			T.tmpoxy = 755985
			T.co2 = 14.8176
			T.oldco2 = 14.8176
			T.tmpco2 = 14.8176
			T.n2 = 2.844e+006
			T.on2 = 2.844e+006
			T.tn2 = 2.844e+006
			T.tsl_gas = 0
			T.osl_gas = 0
			T.sl_gas = 0
			T.temp = 293.15
			T.otemp = 293.15
			T.ttemp = 293.15
*/

/client/proc/toggle_view_range()
	set category = "Special Verbs"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(view == world.view)
		view = input("Select view range:", "FUCK YE", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128)
	else
		view = world.view

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("\blue [key_name_admin(usr)] changed their view range to [view].", 1)	//why? removed by order of XSI

	feedback_add_details("admin_verb","CVRA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()

	set category = "Admin"
	set name = "Call Shuttle"

	if ((!( ticker ) || emergency_shuttle.location))
		return

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || ticker.mode.name == "confliction")
		var/choice = input("The shuttle will just return if you call it. Call anyway?") in list("Confirm", "Cancel")
		if(choice == "Confirm")
			emergency_shuttle.fake_recall = rand(300,500)
		else
			return

	emergency_shuttle.incall()
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
	world << sound('shuttlecalled.ogg')
	feedback_add_details("admin_verb","CSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins("\blue [key_name_admin(usr)] admin-called the emergency shuttle.", 1)
	return

/client/proc/admin_cancel_shuttle()

	set category = "Admin"
	set name = "Cancel Shuttle"

	if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0))
		return

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return

	emergency_shuttle.recall()
	feedback_add_details("admin_verb","CCSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins("\blue [key_name_admin(usr)] admin-recalled the emergency shuttle.", 1)

	return

/client/proc/cmd_admin_attack_log(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Attack Log"

	usr << text("\red <b>Attack Log for []</b>", mob)
	for(var/t in M.attack_log)
		usr << t
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if (ticker && ticker.mode)
		usr << "Nope you can't do this, the game's already started. This only works before rounds!"
		return

	if(ticker.random_players)
		ticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.", 1)
		usr << "Disabled."
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.", 1)

	if(notifyplayers == "Yes")
		world << "\blue <b>Admin [usr.key] has forced the players to have completely random identities!"

	usr << "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>."

	ticker.random_players = 1
	feedback_add_details("admin_verb","MER") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_gravity_on()
	set category = "Debug"
	set name = "Toggle station gravity on"
	set desc = "Toggles all gravity to active on the station."

	if (!(ticker && ticker.mode))
		usr << "Please wait until the game starts!  Not sure how it will work otherwise."
		return


	for(var/area/A in world)
		A.gravitychange(1,A)

	command_alert("CentComm is now beaming gravitons to your station.  We appoligize for any inconvience.")
	feedback_add_details("admin_verb","TSGON") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_gravity_off()
	set category = "Debug"
	set name = "Toggle station gravity off"
	set desc = "Toggles all gravity to inactive on the station."

	if (!(ticker && ticker.mode))
		usr << "Please wait until the game starts!  Not sure how it will work otherwise."
		return


	for(var/area/A in world)
		A.gravitychange(0,A)

	command_alert("For budget reasons, Centcomm is no longer beaming gravitons to your station.  We appoligize for any inconvience.")
	feedback_add_details("admin_verb","TSGOFF") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"
	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"
	if(!config.allow_random_events)
		config.allow_random_events = 1
		usr << "Random events enabled"
		message_admins("Admin [key_name_admin(usr)] has enabled random events.", 1)
	else
		config.allow_random_events = 0
		usr << "Random events disabled"
		message_admins("Admin [key_name_admin(usr)] has disabled random events.", 1)
	feedback_add_details("admin_verb","TRE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
