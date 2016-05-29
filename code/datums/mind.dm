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

	var/special_roles = list()

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
	// TODO implment
	return

/datum/mind/proc/remove_changeling()
	return // TODO kjflkfajklsdfjkl

/datum/mind/proc/remove_traitor()
	return // TODO

/datum/mind/proc/remove_nukeop()
	return // TODO

/datum/mind/proc/remove_wizard()
	return // TODO

/datum/mind/proc/remove_cultist()
	return // TODO

/datum/mind/proc/remove_rev()
	return // TODO

/datum/mind/proc/remove_gang()
	return // TODO

/datum/mind/proc/remove_hog_follower_prophet()
	return // TODO

/datum/mind/proc/remove_antag_equip()
	return // TODO

/datum/mind/proc/remove_all_antag() //For the Lazy amongst us.
	return // TODO YOU THINK YOU'RE LAZY!?

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

	// TODO again reimplment this but with TGUI AND ACTUALLY NOT SHIT

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
		spawn(0)
			S.start_recharge()

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
