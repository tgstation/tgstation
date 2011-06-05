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

	Ninjas are meant for players to respawn as, not admins. They are another way to participate in the game post-death, like pais,
	xenos, death squads, and cyborgs. Ninjas are not admin PCs--please do not use them for that purpose.
	I'm currently looking for feedback from regular players since beta testing is largely done. I would appreciate if
	you spawned regular players as ninjas when rounds are boring. Or exciting, it's all good as long as there is feedback.
	Admin quick-spawning as ninjas is disabled for that reason. You can spawn ninja gear manually if you want to.

	How to do that:
	Make sure your character has a mind.
	Change their assigned_role to "MODE", no quotes. Otherwise, the suit won't initialize.
	Change their special_role to "Space Ninja", no quotes. Otherwise, the character will be gibbed.
	Spawn ninja gear, put it on, hit initialize. Let the suit do the rest. You are now a space ninja.
	I don't recommend messing with suit variables unless you really know what you're doing.

	Miscellaneous Notes:

	Right now I am focused on creating a dynamic objective tree based on round type, in order to create a ninja random event.
	I'll update when possible.
*/

//=======//RANDOM EVENT//=======//

/proc/space_ninja_arrival()
	/*
	var/datum/game_mode/current_mode = ticker.mode
	switch (current_mode.config_tag)
		if ("revolution")


		if ("cult")
			if (src in current_mode:cult)


		if ("wizard")
			if (current_mode:wizard && src == current_mode:wizard)


		if ("changeling")
			if (src in current_mode:changelings)


		if ("malfunction")
			if (src in current_mode:malf_ai)


		if ("nuclear")
			if(src in current_mode:syndicates)
	*/
	return

//=======//ADMIN VERB//=======//

/client/proc/space_ninja()
	set category = "Fun"
	set name = "Spawn Space Ninja"
	set desc = "Spawns a space ninja for when you need a teenager with an attitude."
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	if(!ticker.mode)
		alert("The game hasn't started yet!")
		return
	if(alert("Are you sure you want to send in a space ninja?",,"Yes","No")=="No")
		return

	var/input
	while(!input)
		input = input(src, "Please specify which mission the space ninja shall undertake.", "Specify Mission", "")
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	var/list/spawn_list = list()
	for(var/obj/landmark/X in world)
		if (X.name == "carpspawn")
			spawn_list.Add(X)
	if(!spawn_list.len)
		alert("No spawn location could be found. Aborting.")
		return

	var/admin_name = src
	var/mob/living/carbon/human/new_ninja = create_space_ninja(pick(spawn_list))

	var/mob/dead/observer/G
	var/list/candidates = list()
	for(G in world)
		if(G.client&&!G.client.holder)
		//if(G.client)//Good for testing.
			if(((G.client.inactivity/10)/60) <= 5)
				candidates.Add(G)
	if(candidates.len)
		G = input("Pick character to spawn as the Space Ninja", "Active Players", G) in candidates//It will auto-pick a person when there is only one candidate.
		new_ninja.mind.key = G.key
		new_ninja.client = G.client
		new_ninja.mind.store_memory("<B>Mission:</B> \red [input].")
		del(G)
	else
		alert("Could not locate a suitable ghost. Aborting.")
		del(new_ninja)
		return

	new_ninja.internal = new_ninja.s_store //So the poor ninja has something to breath when they spawn in spess.
	new_ninja.internals.icon_state = "internal1"
	spawn(0)//Parallel process. Will speed things up a bit.
		new_ninja.wear_suit:ninitialize(10,new_ninja)//If you're wondering why I'm passing the argument to the proc when the default should suffice,
		//I'm also wondering that same thing. This makes sure it does not run time error though.

	new_ninja.mind.store_memory("<B>Mission:</B> \red [input].")
	new_ninja << "\blue \nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded \red <B>SPACE NINJA</B>!\blue You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training (initialize your suit by right clicking on it)! \nYour current mission is: \red <B>[input]</B>"

	message_admins("\blue [admin_name] has spawned [new_ninja.key] as a Space Ninja. Hide yo children!", 1)
	log_admin("[admin_name] used Spawn Space Ninja.")

//=======//NINJA CREATION PROCS//=======//

client/proc/create_space_ninja(obj/spawn_point)
	var/mob/living/carbon/human/new_ninja = new(spawn_point.loc)
	var/ninja_title = pick(ninja_titles)
	var/ninja_name = pick(ninja_names)
	new_ninja.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.randomize_appearance_for(new_ninja)

	new_ninja.real_name = "[ninja_title] [ninja_name]"
	new_ninja.dna.ready_dna(new_ninja)
	new_ninja.mind = new
	new_ninja.mind.current = new_ninja
	new_ninja.mind.assigned_role = "MODE"
	new_ninja.mind.special_role = "Space Ninja"
	new_ninja.equip_space_ninja()
	return new_ninja

/mob/living/carbon/human/proc/equip_space_ninja()
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(src)
	equip_if_possible(R, slot_ears)
	if(gender==FEMALE)
		equip_if_possible(new /obj/item/clothing/under/color/blackf(src), slot_w_uniform)
	else
		equip_if_possible(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
	equip_if_possible(new /obj/item/clothing/shoes/space_ninja(src), slot_shoes)
	equip_if_possible(new /obj/item/clothing/suit/space/space_ninja(src), slot_wear_suit)
	equip_if_possible(new /obj/item/clothing/gloves/space_ninja(src), slot_gloves)
	equip_if_possible(new /obj/item/clothing/head/helmet/space/space_ninja(src), slot_head)
	equip_if_possible(new /obj/item/clothing/mask/gas/voice/space_ninja(src), slot_wear_mask)
	equip_if_possible(new /obj/item/device/flashlight(src), slot_belt)
	equip_if_possible(new /obj/item/weapon/plastique(src), slot_r_store)
	equip_if_possible(new /obj/item/weapon/plastique(src), slot_l_store)
	equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(src), slot_s_store)
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
		if(U.gender==FEMALE)
			icon_state = "s-ninjanf"
		else
			icon_state = "s-ninjan"
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
	invisibility = 2//Set ninja invis to 2.
	var/icon/opacity_icon = new(A.icon, A.icon_state)
	var/icon/alpha_mask = getIconMask(src)
	var/icon/alpha_mask_2 = new('effects.dmi', "wave1")
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
	overlays += image("icon"='effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)

//When ninja steal malfunctions.
/mob/proc/NinjaStealthMalf()
	invisibility = 0//Set ninja invis to 0.
	overlays += image("icon"='effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)
	playsound(loc, 'stealthoff.ogg', 75, 1)

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

	if(U.gender==FEMALE)
		icon_state = "s-ninjakf"
	else
		icon_state = "s-ninjak"
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

	var/obj/cable/attached
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
	var/obj/proc_holder/ai_return_control/A_C = new(AI)
	var/obj/proc_holder/ai_hack_ninja/B_C = new(AI)
	var/obj/proc_holder/ai_instruction/C_C = new(AI)
	new/obj/proc_holder/ai_holo_clear(AI)
	AI.proc_holder_list += A_C
	AI.proc_holder_list += B_C
	AI.proc_holder_list += C_C

	s_control = 0

/obj/item/clothing/suit/space/space_ninja/proc/remove_AI_verbs()
	var/obj/proc_holder/ai_return_control/A_C = locate() in AI
	var/obj/proc_holder/ai_hack_ninja/B_C = locate() in AI
	var/obj/proc_holder/ai_instruction/C_C = locate() in AI
	var/obj/proc_holder/ai_holo_clear/D_C = locate() in AI
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
/obj/proc_holder/ai_holo_clear
	name = "Clear Hologram"
	desc = "Stops projecting the current holographic image."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0


/obj/proc_holder/ai_holo_clear/Click()
	var/obj/item/clothing/suit/space/space_ninja/S = loc.loc//This is so stupid but makes sure certain things work. AI.SUIT
	del(S.hologram.i_attached)
	del(S.hologram)
	var/obj/proc_holder/ai_holo_clear/D_C = locate() in S.AI
	S.AI.proc_holder_list -= D_C
	return

/obj/proc_holder/ai_instruction//Let's the AI know what they can do.
	name = "Instructions"
	desc = "Displays a list of helpful information."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/proc_holder/ai_instruction/Click()
	loc << "The menu you are seeing will contain other commands if they become available.\nRight click a nearby turf to display an AI Hologram. It will only be visible to you and your host. You can move it freely using normal movement keys--it will disappear if placed too far away."

/obj/proc_holder/ai_hack_ninja//Generic proc holder to make sure the two verbs below work propely.
	name = "Hack SpiderOS"
	desc = "Hack directly into the Black Widow(tm) neuro-interface."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/proc_holder/ai_hack_ninja/Click()//When you click on it.
	var/obj/item/clothing/suit/space/space_ninja/S = loc.loc
	S.hack_spideros()
	return

/obj/proc_holder/ai_return_control
	name = "Relinquish Control"
	desc = "Return control to the user."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/proc_holder/ai_return_control/Click()
	var/mob/living/silicon/ai/A = loc
	var/obj/item/clothing/suit/space/space_ninja/S = A.loc
	A << browse(null, "window=hack spideros")//Close window
	A << "You have seized your hacking attempt. [S.affecting] has regained control."
	S.affecting << "<b>UPDATE</b>: [A.real_name] has ceased hacking attempt. All systems clear."
	S.remove_AI_verbs()
	return
*/

//=======//DEBUG//=======//

/obj/item/clothing/suit/space/space_ninja/proc/display_verb_procs()
//DEBUG
//Does nothing at the moment. I am trying to see if it's possible to mess around with verbs as variables.
	//for(var/P in verbs)
//		if(P.set.name)
//			usr << "[P.set.name], path: [P]"
	return

/*
Most of these are at various points of incomplete.

/mob/verb/grant_object_panel()
	set name = "Grant AI Ninja Verbs Debug"
	set category = "Ninja Debug"
	var/obj/proc_holder/ai_return_control/A_C = new(src)
	var/obj/proc_holder/ai_hack_ninja/B_C = new(src)
	usr:proc_holder_list += A_C
	usr:proc_holder_list += B_C

mob/verb/remove_object_panel()
	set name = "Remove AI Ninja Verbs Debug"
	set category = "Ninja Debug"
	var/obj/proc_holder/ai_return_control/A = locate() in src
	var/obj/proc_holder/ai_hack_ninja/B = locate() in src
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

	var/obj/effects/energy_net/E = new /obj/effects/energy_net(loc)
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
				var/current_clone = image('mob.dmi',T,"s-ninja")
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