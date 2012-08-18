/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++++++//                //++++++++++++++++++++++++++++++++++
======================================SPACE NINJA SETUP====================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
	README:

	Data:

	>> space_ninja.dm << is this file. It contains a variety of procs related to either spawning space ninjas,
	modifying their verbs, various help procs, testing debug-related content, or storing unused procs for later.
	Similar functions should go into this file, along with anything else that may not have an explicit category.
	IMPORTANT: actual ninja suit, gloves, etc, are stored under the appropriate clothing files. If you need to change
	variables or look them up, look there. Easiest way is through the map file browser.

	>> ninja_abilities.dm << contains all the ninja-related powers. Spawning energy swords, teleporting, and the like.
	If more powers are added, or perhaps something related to powers, it should go there. Make sure to describe
	what an ability/power does so it's easier to reference later without looking at the code.
	IMPORTANT: verbs are still somewhat funky to work with. If an argument is specified but is not referenced in a way
	BYOND likes, in the code content, the verb will fail to trigger. Nothing will happen, literally, when clicked.
	This can be bypassed by either referencing the argument properly, or linking to another proc with the argument
	attached. The latter is what I like to do for certain cases--sometimes it's necessary to do that regardless.

	>> ninja_equipment.dm << deals with all the equipment-related procs for a ninja. Primarily it has the suit, gloves,
	and mask. The suit is by far the largest section of code out of the three and includes a lot of code that ties in
	to other functions. This file has gotten kind of large so breaking it up may be in order. I use section hearders.
	IMPORTANT: not much to say here. Follow along with the comments and adding new functions should be a breeze. Also
	know that certain equipment pieces are linked in other files. The energy blade, for example, has special
	functions defined in the appropriate files (airlock, securestorage, etc).

	General Notes:

	I created space ninjas with the expressed purpose of spicing up boring rounds. That is, ninjas are to xenos as marauders are to
	death squads. Ninjas are stealthy, tech-savvy, and powerful. Not to say marauders are all of those things, but a clever ninja
	should have little problem murderampaging their way through just about anything. Short of admin wizards maybe.
	HOWEVER!
	Ninjas also have a fairly great weakness as they require energy to use abilities. If, theoretically, there is a game
	mode based around space ninjas, make sure to account for their energy needs.

	Admin Notes:

	Ninjas are not admin PCs--please do not use them for that purpose. They are another way to participate in the game post-death,
	like pais, xenos, death squads, and cyborgs.
	I'm currently looking for feedback from regular players since beta testing is largely done. I would appreciate if
	you spawned regular players as ninjas when rounds are boring. Or exciting, it's all good as long as there is feedback.
	You can also spawn ninja gear manually if you want to.

	How to do that:
	Make sure your character has a mind.
	Change their assigned_role to "MODE", no quotes. Otherwise, the suit won't initialize.
	Change their special_role to "Space Ninja", no quotes. Otherwise, the character will be gibbed.
	Spawn ninja gear, put it on, hit initialize. Let the suit do the rest. You are now a space ninja.
	I don't recommend messing with suit variables unless you really know what you're doing.

	Miscellaneous Notes:

	Potential Upgrade Tree:
		Energy Shield:
			Extra Ability
			Syndicate Shield device?
				Works like the force wall spell, except can be kept indefinitely as long as energy remains. Toggled on or off.
				Would block bullets and the like.
		Phase Shift
			Extra Ability
			Advanced Sensors?
				Instead of being unlocked at the start, Phase Shieft would become available once requirements are met.
		Uranium-based Recharger:
			Suit Upgrade
			Unsure
				Instead of losing energy each second, the suit would regain the same amount of energy.
				This would not count in activating stealth and similar.
		Extended Battery Life:
			Suit Upgrade
			Battery of higher capacity
				Already implemented. Replace current battery with one of higher capacity.
		Advanced Cloak-Tech device.
			Suit Upgrade
			Syndicate Cloaking Device?
				Remove cloak failure rate.
*/

//=======//RANDOM EVENT//=======//
/*
Also a dynamic ninja mission generator.
I decided to scrap round-specific objectives since keeping track of them would require some form of tracking.
When I already created about 4 new objectives, this doesn't seem terribly important or needed.
*/

/var/global/toggle_space_ninja = 1//If ninjas can spawn or not.
/var/global/sent_ninja_to_station = 0//If a ninja is already on the station.

/proc/space_ninja_arrival()

	var/datum/game_mode/current_mode = ticker.mode
	var/datum/mind/current_mind

	/*Is the ninja playing for the good or bad guys? Is the ninja helping or hurting the station?
	Their directives also influence behavior. At least in theory.*/
	var/side = pick("face","heel")

	var/antagonist_list[] = list()//The main bad guys. Evil minds that plot destruction.
	var/protagonist_list[] = current_mode.get_living_heads()//The good guys. Mostly Heads. Who are alive.

	var/xeno_list[] = list()//Aliens.
	var/commando_list[] = list()//Commandos.

	//We want the ninja to appear only in certain modes.
//	var/acceptable_modes_list[] = list("traitor","revolution","cult","wizard","changeling","traitorchan","nuclear","malfunction","monkey")  // Commented out for both testing and ninjas
//	if(!(current_mode.config_tag in acceptable_modes_list))
//		return

	/*No longer need to determine what mode it is since bad guys are basically universal.
	And there is now a mode with two types of bad guys.*/

	var/possible_bad_dudes[] = list(current_mode.traitors,current_mode.head_revolutionaries,current_mode.head_revolutionaries,
	                                current_mode.cult,current_mode.wizards,current_mode.changelings,current_mode.syndicates)
	for(var/list in possible_bad_dudes)//For every possible antagonist type.
		for(current_mind in list)//For each mind in that list.
			if(current_mind.current&&current_mind.current.stat!=2)//If they are not destroyed and not dead.
				antagonist_list += current_mind//Add them.

	if(protagonist_list.len)//If the mind is both a protagonist and antagonist.
		for(current_mind in protagonist_list)
			if(current_mind in antagonist_list)
				protagonist_list -= current_mind//We only want it in one list.
/*
Malf AIs/silicons aren't added. Monkeys aren't added. Messes with objective completion. Only humans are added.
*/

	//Here we pick a location and spawn the ninja.
	var/list/spawn_list = list()
	for(var/obj/effect/landmark/L in world)
		if(L.name == "carpspawn")
			spawn_list.Add(L)


	var/list/candidates = list()	//list of candidate keys
	for(var/mob/dead/observer/G in player_list)
		if(!G.client.holder && ((G.client.inactivity/10)/60) <= 5)
			if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
				candidates += G.key
	if(!candidates.len)	return


	//The ninja will be created on the right spawn point or at late join.
	var/mob/living/carbon/human/new_ninja = create_space_ninja(pick(spawn_list.len ? spawn_list : latejoin ))
	new_ninja.key = pick(candidates)
	new_ninja.wear_suit:randomize_param()//Give them a random set of suit parameters.
	new_ninja.internal = new_ninja.s_store //So the poor ninja has something to breath when they spawn in spess.
	new_ninja.internals.icon_state = "internal1"

	//Now for the rest of the stuff.

	var/datum/mind/ninja_mind = new_ninja.mind//For easier reference.
	var/mission_set = 0//To determine if we need to do further processing.
	//Xenos and deathsquads take precedence over everything else.

	//Unless the xenos are hiding in a locker somewhere, this'll find em.
	for(var/mob/living/carbon/alien/humanoid/xeno in player_list)
		if(istype(xeno))
			xeno_list += xeno

	if(xeno_list.len>3)//If there are more than three humanoid xenos on the station, time to get dangerous.
		//Here we want the ninja to murder all the queens. The other aliens don't really matter.
		var/xeno_queen_list[] = list()
		for(var/mob/living/carbon/alien/humanoid/queen/xeno_queen in xeno_list)
			if(xeno_queen.mind&&xeno_queen.stat!=2)
				xeno_queen_list += xeno_queen
		if(xeno_queen_list.len&&side=="face")//If there are queen about and the probability is 50.
			for(var/mob/living/carbon/alien/humanoid/queen/xeno_queen in xeno_queen_list)
				var/datum/objective/assassinate/ninja_objective = new
				//We'll do some manual overrides to properly set it up.
				ninja_objective.owner = ninja_mind
				ninja_objective.target = xeno_queen.mind
				ninja_objective.explanation_text = "Kill \the [xeno_queen]."
				ninja_mind.objectives += ninja_objective
			mission_set = 1

	if(sent_strike_team&&side=="heel"&&antagonist_list.len)//If a strike team was sent, murder them all like a champ.
		for(current_mind in antagonist_list)//Search and destroy. Since we already have an antagonist list, they should appear there.
			if(current_mind && current_mind.special_role=="Death Commando")
				commando_list += current_mind
		if(commando_list.len)//If there are living commandos still in play.
			for(var/mob/living/carbon/human/commando in commando_list)
				var/datum/objective/assassinate/ninja_objective = new
				ninja_objective.owner = ninja_mind
				ninja_objective.find_target_by_role(commando.mind.special_role,1)
				ninja_mind.objectives += ninja_objective
			mission_set = 1
/*
If there are no antogonists left it could mean one of two things:
	A) The round is about to end. No harm in spawning the ninja here.
	B) The round is still going and ghosts are probably rioting for something to happen.
In either case, it's a good idea to spawn the ninja with a semi-random set of objectives.
*/
	if(!mission_set)//If mission was not set.

		var/current_minds[]//List being looked on in the following code.
		var/side_list = side=="face" ? 2 : 1//For logic gating.
		var/hostile_targets[] = list()//The guys actually picked for the assassination or whatever.
		var/friendly_targets[] = list()//The guys the ninja must protect.

		for(var/i=2,i>0,i--)//Two lists.
			current_minds = i==2 ? antagonist_list : protagonist_list//Which list are we looking at?
			for(var/t=3,(current_minds.len&&t>0),t--)//While the list is not empty and targets remain. Also, 3 targets is good.
				current_mind = pick(current_minds)//Pick a random person.
				/*I'm creating a logic gate here based on the ninja affiliation that compares the list being
				looked at to the affiliation. Affiliation is just a number used to compare. Meaning comes from the logic involved.
				If the list being looked at is equal to the ninja's affiliation, add the mind to hostiles.
				If not, add the mind to friendlies. Since it can't be both, it will be added only to one or the other.*/
				hostile_targets += i==side_list ? current_mind : null//Adding null doesn't add anything.
				friendly_targets += i!=side_list ? current_mind : null
				current_minds -= current_mind//Remove the mind so it's not picked again.

		var/objective_list[] = list(1,2,3,4,5,6)//To remove later.
		for(var/i=rand(1,3),i>0,i--)//Want to get a few random objectives. Currently up to 3.
			if(!hostile_targets.len)//Remove appropriate choices from switch list if the target lists are empty.
				objective_list -= 1
				objective_list -= 4
			if(!friendly_targets.len)
				objective_list -= 3
			switch(pick(objective_list))
				if(1)//kill
					current_mind = pick(hostile_targets)

					if(current_mind)
						var/datum/objective/assassinate/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role),(current_mind.special_role?1:0))//If they have a special role, use that instead to find em.
						ninja_mind.objectives += ninja_objective

					else
						i++

					hostile_targets -= current_mind//Remove them from the list.
				if(2)//Steal
					var/datum/objective/steal/ninja_objective = new
					var/target_item = pick(ninja_objective.possible_items_special)
					ninja_objective.set_target(target_item)
					ninja_mind.objectives += ninja_objective

					objective_list -= 2
				if(3)//Protect. Keeping people alive can be pretty difficult.
					current_mind = pick(friendly_targets)

					if(current_mind)

						var/datum/objective/protect/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role),(current_mind.special_role?1:0))
						ninja_mind.objectives += ninja_objective

					else
						i++

					friendly_targets -= current_mind
				if(4)//Debrain
					current_mind = pick(hostile_targets)

					if(current_mind)

						var/datum/objective/debrain/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role),(current_mind.special_role?1:0))
						ninja_mind.objectives += ninja_objective

					else
						i++

					hostile_targets -= current_mind//Remove them from the list.
				if(5)//Download research
					var/datum/objective/download/ninja_objective = new
					ninja_objective.gen_amount_goal()
					ninja_mind.objectives += ninja_objective

					objective_list -= 5
				if(6)//Capture
					var/datum/objective/capture/ninja_objective = new
					ninja_objective.gen_amount_goal()
					ninja_mind.objectives += ninja_objective

					objective_list -= 6

		if(ninja_mind.objectives.len)//If they got some objectives out of that.
			mission_set = 1

	if(!ninja_mind.objectives.len||!mission_set)//If they somehow did not get an objective at this point, time to destroy the station.
		var/nuke_code
		var/temp_code
		for(var/obj/machinery/nuclearbomb/N in world)
			temp_code = text2num(N.r_code)
			if(temp_code)//if it's actually a number. It won't convert any non-numericals.
				nuke_code = N.r_code
				break
		if(nuke_code)//If there is a nuke device in world and we got the code.
			var/datum/objective/nuclear/ninja_objective = new//Fun.
			ninja_objective.owner = ninja_mind
			ninja_objective.explanation_text = "Destroy the station with a nuclear device. The code is [nuke_code]." //Let them know what the code is.

	//Finally add a survival objective since it's usually broad enough for any round type.
	var/datum/objective/survive/ninja_objective = new
	ninja_objective.owner = ninja_mind
	ninja_mind.objectives += ninja_objective

	var/directive = generate_ninja_directive(side)
	new_ninja << "\blue \nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded \red <B>SPACE NINJA</B>!\blue You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training (initialize your suit by right clicking on it)! \nYour current directive is: \red <B>[directive]</B>"
	new_ninja.mind.store_memory("<B>Directive:</B> \red [directive]<br>")

	var/obj_count = 1
	new_ninja << "\blue Your current objectives:"
	for(var/datum/objective/objective in ninja_mind.objectives)
		new_ninja << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++

	sent_ninja_to_station = 1//And we're done.
	return new_ninja//Return the ninja in case we need to reference them later.

/*
This proc will give the ninja a directive to follow. They are not obligated to do so but it's a fun roleplay reminder.
Making this random or semi-random will probably not work without it also being incredibly silly.
As such, it's hard-coded for now. No reason for it not to be, really.
*/
/proc/generate_ninja_directive(side)
	var/directive = "[side=="face"?"Nanotrasen":"The Syndicate"] is your employer. "//Let them know which side they're on.
	switch(rand(1,13))
		if(1)
			directive += "The Spider Clan must not be linked to this operation. Remain as hidden and covert as possible."
		if(2)
			directive += "[station_name] is financed by an enemy of the Spider Clan. Cause as much structural damage as possible."
		if(3)
			directive += "A wealthy animal rights activist has made a request we cannot refuse. Prioritize saving animal lives whenever possible."
		if(4)
			directive += "The Spider Clan absolutely cannot be linked to this operation. Eliminate all witnesses using most extreme prejudice."
		if(5)
			directive += "We are currently negotiating with Nanotrasen command. Prioritize saving human lives over ending them."
		if(6)
			directive += "We are engaged in a legal dispute over [station_name]. If a laywer is present on board, force their cooperation in the matter."
		if(7)
			directive += "A financial backer has made an offer we cannot refuse. Implicate Syndicate involvement in the operation."
		if(8)
			directive += "Let no one question the mercy of the Spider Clan. Ensure the safety of all non-essential personnel you encounter."
		if(9)
			directive += "A free agent has proposed a lucrative business deal. Implicate Nanotrasen involvement in the operation."
		if(10)
			directive += "Our reputation is on the line. Harm as few civilians or innocents as possible."
		if(11)
			directive += "Our honor is on the line. Utilize only honorable tactics when dealing with opponents."
		if(12)
			directive += "We are currently negotiating with a Syndicate leader. Disguise assassinations as suicide or another natural cause."
		else
			directive += "There are no special supplemental instructions at this time."
	return directive

//=======//CURRENT PLAYER VERB//=======//

/client/proc/cmd_admin_ninjafy(var/mob/M in player_list)
	set category = null
	set name = "Make Space Ninja"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(!toggle_space_ninja)
		alert("Space Ninjas spawning is disabled.")
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return

	if(ishuman(M))
		log_admin("[key_name(src)] turned [M.key] into a Space Ninja.")
		spawn(10)
			M:create_mind_space_ninja()
			M:equip_space_ninja(1)
			if(istype(M:wear_suit, /obj/item/clothing/suit/space/space_ninja))
				M:wear_suit:randomize_param()
				spawn(0)
					M:wear_suit:ninitialize(10,M)
	else
		alert("Invalid mob")

//=======//CURRENT GHOST VERB//=======//

/client/proc/send_space_ninja()
	set category = "Fun"
	set name = "Spawn Space Ninja"
	set desc = "Spawns a space ninja for when you need a teenager with attitude."
	set popup_menu = 0

	if(!holder)
		src << "Only administrators may use this command."
		return
	if(!ticker.mode)
		alert("The game hasn't started yet!")
		return
	if(!toggle_space_ninja)
		alert("Space Ninjas spawning is disabled.")
		return
	if(alert("Are you sure you want to send in a space ninja?",,"Yes","No")=="No")
		return

	var/mission
	while(!mission)
		mission = copytext(sanitize(input(src, "Please specify which mission the space ninja shall undertake.", "Specify Mission", "")),1,MAX_MESSAGE_LEN)
		if(!mission)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	var/list/spawn_list = list()
	for(var/obj/effect/landmark/L in world)
		if (L.name == "carpspawn")
			spawn_list.Add(L)


	var/input = ckey(input("Pick character to spawn as the Space Ninja", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G
	for(var/mob/dead/observer/G_find in player_list)
		if(G_find.ckey == input)
			G = G_find
			break

	if(!G)//If a ghost was not found.
		alert("There is no active key like that in the game or the person is not currently a ghost. Aborting command.")
		return

	var/admin_name = src
	var/mob/living/carbon/human/new_ninja = create_space_ninja(pick(spawn_list.len ? spawn_list : latejoin ))
	new_ninja.wear_suit:randomize_param()

	new_ninja.key = G.key
	new_ninja.mind.store_memory("<B>Mission:</B> \red [mission].<br>")

	new_ninja.internal = new_ninja.s_store //So the poor ninja has something to breath when they spawn in spess.
	new_ninja.internals.icon_state = "internal1"
	spawn(0)//Parallel process. Will speed things up a bit.
		new_ninja.wear_suit:ninitialize(10,new_ninja)//If you're wondering why I'm passing the argument to the proc when the default should suffice,
		//I'm also wondering that same thing. This makes sure it does not run time error though.

	new_ninja << "\blue \nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded \red <B>SPACE NINJA</B>!\blue You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training! \nYour current mission is: \red <B>[mission]</B>"

	message_admins("\blue [admin_name] has spawned [new_ninja.key] as a Space Ninja. Hide yo children! \nTheir <b>mission</b> is: [mission]", 1)
	log_admin("[admin_name] used Spawn Space Ninja.")

	return

//=======//NINJA CREATION PROCS//=======//

/proc/create_space_ninja(obj/spawn_point)
	var/mob/living/carbon/human/new_ninja = new(spawn_point.loc)
	var/ninja_title = pick(ninja_titles)
	var/ninja_name = pick(ninja_names)
	new_ninja.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.randomize_appearance_for(new_ninja)
	new_ninja.real_name = "[ninja_title] [ninja_name]"
	new_ninja.dna.ready_dna(new_ninja)
	new_ninja.create_mind_space_ninja()
	new_ninja.equip_space_ninja()
	return new_ninja

/mob/living/carbon/human/proc/create_mind_space_ninja()
	mind_initialize()
	mind.assigned_role = "MODE"
	mind.special_role = "Space Ninja"

	//Adds them to current traitor list. Which is really the extra antagonist list.
	ticker.mode.traitors |= mind
	return 1

/mob/living/carbon/human/proc/equip_space_ninja(safety=0)//Safety in case you need to unequip stuff for existing characters.
	if(safety)
		del(w_uniform)
		del(wear_suit)
		del(wear_mask)
		del(head)
		del(shoes)
		del(gloves)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(src)
	equip_to_slot_or_del(R, slot_ears)
	if(gender==FEMALE)
		equip_to_slot_or_del(new /obj/item/clothing/under/color/blackf(src), slot_w_uniform)
	else
		equip_to_slot_or_del(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/space_ninja(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/suit/space/space_ninja(src), slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/space_ninja(src), slot_gloves)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/space_ninja(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/voice/space_ninja(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), slot_belt)
	equip_to_slot_or_del(new /obj/item/weapon/plastique(src), slot_r_store)
	equip_to_slot_or_del(new /obj/item/weapon/plastique(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen(src), slot_s_store)
	resistances += "alien_embryo"
	return 1

//=======//HELPER PROCS//=======//

//Randomizes suit parameters.
/obj/item/clothing/suit/space/space_ninja/proc/randomize_param()
	s_cost = rand(1,20)
	s_acost = rand(20,100)
	k_cost = rand(100,500)
	k_damage = rand(1,20)
	s_delay = rand(10,100)
	s_bombs = rand(5,20)
	a_boost = rand(1,7)

//This proc prevents the suit from being taken off.
/obj/item/clothing/suit/space/space_ninja/proc/lock_suit(mob/living/carbon/U, X = 0)
	if(X)//If you want to check for icons.
		icon_state = U.gender==FEMALE ? "s-ninjanf" : "s-ninjan"
		U:gloves.icon_state = "s-ninjan"
		U:gloves.item_state = "s-ninjan"
	else
		if(U.mind.special_role!="Space Ninja")
			U << "\red <B>fÄTaL ÈÈRRoR</B>: 382200-*#00CÖDE <B>RED</B>\nUNAU†HORIZED USÈ DETÈC†††eD\nCoMMÈNCING SUB-R0U†IN3 13...\nTÈRMInATING U-U-USÈR..."
			U.gib()
			return 0
		if(!istype(U:head, /obj/item/clothing/head/helmet/space/space_ninja))
			U << "\red <B>ERROR</B>: 100113 \black UNABLE TO LOCATE HEAD GEAR\nABORTING..."
			return 0
		if(!istype(U:shoes, /obj/item/clothing/shoes/space_ninja))
			U << "\red <B>ERROR</B>: 122011 \black UNABLE TO LOCATE FOOT GEAR\nABORTING..."
			return 0
		if(!istype(U:gloves, /obj/item/clothing/gloves/space_ninja))
			U << "\red <B>ERROR</B>: 110223 \black UNABLE TO LOCATE HAND GEAR\nABORTING..."
			return 0

		affecting = U
		canremove = 0
		slowdown = 0
		n_hood = U:head
		n_hood.canremove=0
		n_shoes = U:shoes
		n_shoes.canremove=0
		n_shoes.slowdown--
		n_gloves = U:gloves
		n_gloves.canremove=0

	return 1

//This proc allows the suit to be taken off.
/obj/item/clothing/suit/space/space_ninja/proc/unlock_suit()
	affecting = null
	canremove = 1
	slowdown = 1
	icon_state = "s-ninja"
	if(n_hood)//Should be attached, might not be attached.
		n_hood.canremove=1
	if(n_shoes)
		n_shoes.canremove=1
		n_shoes.slowdown++
	if(n_gloves)
		n_gloves.icon_state = "s-ninja"
		n_gloves.item_state = "s-ninja"
		n_gloves.canremove=1
		n_gloves.candrain=0
		n_gloves.draining=0

//Allows the mob to grab a stealth icon.
/mob/proc/NinjaStealthActive(atom/A)//A is the atom which we are using as the overlay.
	invisibility = INVISIBILITY_LEVEL_TWO//Set ninja invis to 2.
	var/icon/opacity_icon = new(A.icon, A.icon_state)
	var/icon/alpha_mask = getIconMask(src)
	var/icon/alpha_mask_2 = new('icons/effects/effects.dmi', "at_shield1")
	alpha_mask.AddAlphaMask(alpha_mask_2)
	opacity_icon.AddAlphaMask(alpha_mask)
	for(var/i=0,i<5,i++)//And now we add it as overlays. It's faster than creating an icon and then merging it.
		var/image/I = image("icon" = opacity_icon, "icon_state" = A.icon_state, "layer" = layer+0.8)//So it's above other stuff but below weapons and the like.
		switch(i)//Now to determine offset so the result is somewhat blurred.
			if(1)
				I.pixel_x -= 1
			if(2)
				I.pixel_x += 1
			if(3)
				I.pixel_y -= 1
			if(4)
				I.pixel_y += 1

		overlays += I//And finally add the overlay.
	overlays += image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)

//When ninja steal malfunctions.
/mob/proc/NinjaStealthMalf()
	invisibility = 0//Set ninja invis to 0.
	overlays += image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)
	playsound(loc, 'sound/effects/stealthoff.ogg', 75, 1)

//=======//GENERIC VERB MODIFIERS//=======//

/obj/item/clothing/suit/space/space_ninja/proc/grant_equip_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/init
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth
	n_gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggled

	s_initialized = 1

/obj/item/clothing/suit/space/space_ninja/proc/remove_equip_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth
	if(n_gloves)
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

	s_initialized = 0

/obj/item/clothing/suit/space/space_ninja/proc/grant_ninja_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjaboost
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjablade
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

	s_initialized=1
	slowdown=0

/obj/item/clothing/suit/space/space_ninja/proc/remove_ninja_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjaboost
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjablade
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

//=======//KAMIKAZE VERBS//=======//

/obj/item/clothing/suit/space/space_ninja/proc/grant_kamikaze(mob/living/carbon/U)
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjawalk
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjamirage

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth

	kamikaze = 1

	icon_state = U.gender==FEMALE ? "s-ninjakf" : "s-ninjak"
	if(n_gloves)
		n_gloves.icon_state = "s-ninjak"
		n_gloves.item_state = "s-ninjak"
		n_gloves.candrain = 0
		n_gloves.draining = 0
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

	cancel_stealth()

	U << browse(null, "window=spideros")
	U << "\red Do or Die, <b>LET'S ROCK!!</b>"

/obj/item/clothing/suit/space/space_ninja/proc/remove_kamikaze(mob/living/carbon/U)
	if(kamikaze)
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjawalk
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjamirage

		verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth
		if(n_gloves)
			n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

		U.incorporeal_move = 0
		kamikaze = 0
		k_unlock = 0
		U << "\blue Disengaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"

//=======//AI VERBS//=======//

/obj/item/clothing/suit/space/space_ninja/proc/grant_AI_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control

	s_busy = 0
	s_control = 0

/obj/item/clothing/suit/space/space_ninja/proc/remove_AI_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control

	s_control = 1

//=======//OLD & UNUSED//=======//

/*

Deprecated. get_dir() does the same thing. Still a nice proc.
Returns direction that the mob or whomever should be facing in relation to the target.
This proc does not grant absolute direction and is mostly useful for 8dir sprite positioning.
I personally used it with getline() to great effect.
/proc/get_dir_to(turf/start,turf/end)//N
	var/xdiff = start.x - end.x//The sign is important.
	var/ydiff = start.y - end.y

	var/direction_x = xdiff<1 ? 4:8//East - west
	var/direction_y = ydiff<1 ? 1:2//North - south
	var/direction_xy = xdiff==0 ? -4:0//If x is the same, subtract 4.
	var/direction_yx = ydiff==0 ? -1:0//If y is the same, subtract 1.
	var/direction_f = direction_x+direction_y+direction_xy+direction_yx//Finally direction tally.
	direction_f = direction_f==0 ? 1:direction_f//If direction is 0(same spot), return north. Otherwise, direction.

	return direction_f

Alternative and inferior method of calculating spideros.
var/temp = num2text(spideros)
var/return_to = copytext(temp, 1, (length(temp)))//length has to be to the length of the thing because by default it's length+1
spideros = text2num(return_to)//Maximum length here is 6. Use (return_to, X) to specify larger strings if needed.

//Old way of draining from wire.
/obj/item/clothing/gloves/space_ninja/proc/drain_wire()
	set name = "Drain From Wire"
	set desc = "Drain energy directly from an exposed wire."
	set category = "Ninja Equip"

	var/obj/structure/cable/attached
	var/mob/living/carbon/human/U = loc
	if(candrain&&!draining)
		var/turf/T = U.loc
		if(isturf(T) && T.is_plating())
			attached = locate() in T
			if(!attached)
				U << "\red Warning: no exposed cable available."
			else
				U << "\blue Connecting to wire, stand still..."
				if(do_after(U,50)&&!isnull(attached))
					drain("WIRE",attached,U:wear_suit,src)
				else
					U << "\red Procedure interrupted. Protocol terminated."
	return

I've tried a lot of stuff but adding verbs to the AI while inside an object, inside another object, did not want to work properly.
This was the best work-around I could come up with at the time. Uses objects to then display to panel, based on the object spell system.
Can be added on to pretty easily.

BYOND fixed the verb bugs so this is no longer necessary. I prefer verb panels.

/obj/item/clothing/suit/space/space_ninja/proc/grant_AI_verbs()
	var/obj/effect/proc_holder/ai_return_control/A_C = new(AI)
	var/obj/effect/proc_holder/ai_hack_ninja/B_C = new(AI)
	var/obj/effect/proc_holder/ai_instruction/C_C = new(AI)
	new/obj/effect/proc_holder/ai_holo_clear(AI)
	AI.proc_holder_list += A_C
	AI.proc_holder_list += B_C
	AI.proc_holder_list += C_C

	s_control = 0

/obj/item/clothing/suit/space/space_ninja/proc/remove_AI_verbs()
	var/obj/effect/proc_holder/ai_return_control/A_C = locate() in AI
	var/obj/effect/proc_holder/ai_hack_ninja/B_C = locate() in AI
	var/obj/effect/proc_holder/ai_instruction/C_C = locate() in AI
	var/obj/effect/proc_holder/ai_holo_clear/D_C = locate() in AI
	del(A_C)
	del(B_C)
	del(C_C)
	del(D_C)
	AI.proc_holder_list = list()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth

	s_control = 1

//Workaround
/obj/effect/proc_holder/ai_holo_clear
	name = "Clear Hologram"
	desc = "Stops projecting the current holographic image."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0


/obj/effect/proc_holder/ai_holo_clear/Click()
	var/obj/item/clothing/suit/space/space_ninja/S = loc.loc//This is so stupid but makes sure certain things work. AI.SUIT
	del(S.hologram.i_attached)
	del(S.hologram)
	var/obj/effect/proc_holder/ai_holo_clear/D_C = locate() in S.AI
	S.AI.proc_holder_list -= D_C
	return

/obj/effect/proc_holder/ai_instruction//Let's the AI know what they can do.
	name = "Instructions"
	desc = "Displays a list of helpful information."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/effect/proc_holder/ai_instruction/Click()
	loc << "The menu you are seeing will contain other commands if they become available.\nRight click a nearby turf to display an AI Hologram. It will only be visible to you and your host. You can move it freely using normal movement keys--it will disappear if placed too far away."

/obj/effect/proc_holder/ai_hack_ninja//Generic proc holder to make sure the two verbs below work propely.
	name = "Hack SpiderOS"
	desc = "Hack directly into the Black Widow(tm) neuro-interface."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/effect/proc_holder/ai_hack_ninja/Click()//When you click on it.
	var/obj/item/clothing/suit/space/space_ninja/S = loc.loc
	S.hack_spideros()
	return

/obj/effect/proc_holder/ai_return_control
	name = "Relinquish Control"
	desc = "Return control to the user."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/effect/proc_holder/ai_return_control/Click()
	var/mob/living/silicon/ai/A = loc
	var/obj/item/clothing/suit/space/space_ninja/S = A.loc
	A << browse(null, "window=hack spideros")//Close window
	A << "You have seized your hacking attempt. [S.affecting] has regained control."
	S.affecting << "<b>UPDATE</b>: [A.real_name] has ceased hacking attempt. All systems clear."
	S.remove_AI_verbs()
	return
*/

//=======//DEBUG//=======//
/*
/obj/item/clothing/suit/space/space_ninja/proc/display_verb_procs()
//DEBUG
//Does nothing at the moment. I am trying to see if it's possible to mess around with verbs as variables.
	//for(var/P in verbs)
//		if(P.set.name)
//			usr << "[P.set.name], path: [P]"
	return


Most of these are at various points of incomplete.

/mob/verb/grant_object_panel()
	set name = "Grant AI Ninja Verbs Debug"
	set category = "Ninja Debug"
	var/obj/effect/proc_holder/ai_return_control/A_C = new(src)
	var/obj/effect/proc_holder/ai_hack_ninja/B_C = new(src)
	usr:proc_holder_list += A_C
	usr:proc_holder_list += B_C

mob/verb/remove_object_panel()
	set name = "Remove AI Ninja Verbs Debug"
	set category = "Ninja Debug"
	var/obj/effect/proc_holder/ai_return_control/A = locate() in src
	var/obj/effect/proc_holder/ai_hack_ninja/B = locate() in src
	usr:proc_holder_list -= A
	usr:proc_holder_list -= B
	del(A)//First.
	del(B)//Second, to keep the proc going.
	return

/client/verb/grant_verb_ninja_debug1(var/mob/M in view())
	set name = "Grant AI Ninja Verbs Debug"
	set category = "Ninja Debug"

	M.verbs += /mob/living/silicon/ai/verb/ninja_return_control
	M.verbs += /mob/living/silicon/ai/verb/ninja_spideros
	return

/client/verb/grant_verb_ninja_debug2(var/mob/living/carbon/human/M in view())
	set name = "Grant Back Ninja Verbs"
	set category = "Ninja Debug"

	M.wear_suit.verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
	M.wear_suit.verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	return

/obj/proc/grant_verb_ninja_debug3(var/mob/living/silicon/ai/A as mob)
	set name = "Grant AI Ninja Verbs"
	set category = "null"
	set hidden = 1
	A.verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	A.verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	return

/mob/verb/get_dir_to_target(var/mob/M in oview())
	set name = "Get Direction to Target"
	set category = "Ninja Debug"

	world << "DIR: [get_dir_to(src.loc,M.loc)]"
	return
//
/mob/verb/kill_self_debug()
	set name = "DEBUG Kill Self"
	set category = "Ninja Debug"

	src:death()

/client/verb/switch_client_debug()
	set name = "DEBUG Switch Client"
	set category = "Ninja Debug"

	mob = mob:loc:loc

/mob/verb/possess_mob(var/mob/M in oview())
	set name = "DEBUG Possess Mob"
	set category = "Ninja Debug"

	client.mob = M

/client/verb/switcharoo(var/mob/M in oview())
	set name = "DEBUG Switch to AI"
	set category = "Ninja Debug"

	var/mob/last_mob = mob
	mob = M
	last_mob:wear_suit:AI:key = key
//
/client/verb/ninjaget(var/mob/M in oview())
	set name = "DEBUG Ninja GET"
	set category = "Ninja Debug"

	mob = M
	M.gib()
	space_ninja()

/mob/verb/set_debug_ninja_target()
	set name = "Set Debug Target"
	set category = "Ninja Debug"

	ninja_debug_target = src//The target is you, brohime.
	world << "Target: [src]"

/mob/verb/hack_spideros_debug()
	set name = "Debug Hack Spider OS"
	set category = "Ninja Debug"

	var/mob/living/silicon/ai/A = loc:AI
	if(A)
		if(!A.key)
			A.client.mob = loc:affecting
		else
			loc:affecting:client:mob = A
	return

//Tests the net and what it does.
/mob/verb/ninjanet_debug()
	set name = "Energy Net Debug"
	set category = "Ninja Debug"

	var/obj/effect/energy_net/E = new /obj/effect/energy_net(loc)
	E.layer = layer+1//To have it appear one layer above the mob.
	stunned = 10//So they are stunned initially but conscious.
	anchored = 1//Anchors them so they can't move.
	E.affecting = src
	spawn(0)//Parallel processing.
		E.process(src)
	return

I made this as a test for a possible ninja ability (or perhaps more) for a certain mob to see hallucinations.
The thing here is that these guys have to be coded to do stuff as they are simply images that you can't even click on.
That is why you attached them to objects.
/mob/verb/TestNinjaShadow()
	set name = "Test Ninja Ability"
	set category = "Ninja Debug"

	if(client)
		var/safety = 4
		for(var/turf/T in oview(5))
			if(prob(20))
				var/current_clone = image('icons/mob/mob.dmi',T,"s-ninja")
				safety--
				spawn(0)
					src << current_clone
					spawn(300)
						del(current_clone)
					spawn while(!isnull(current_clone))
						step_to(current_clone,src,1)
						sleep(5)
			if(safety<=0)	break
	return */