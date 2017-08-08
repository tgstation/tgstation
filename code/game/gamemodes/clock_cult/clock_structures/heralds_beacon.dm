//Used to "declare war" against the station. The servants' equipment will be permanently supercharged, and the Ark given extra time to prepare.
//This will send an announcement to the station, meaning that they will be warned very early in advance about the impending attack.
/obj/structure/destructible/clockwork/heralds_beacon
	name = "herald's beacon"
	desc = "An imposing spire formed of brass, with a thrumming gemstone at its peak."
	clockwork_desc = "A massively-powerful beacon. If enough servants decide to activate it, it will send an incredibly large energy pulse to the Ark, \
	permanently empowering slabs, replica fabricators, clockwork armor, and more, as well as giving the Ark an extra ten minutes before activation. \
	This will alert the crew to your presence, as so much energy is bound to fall under notice."
	icon_state = "interdiction_lens"
	break_message = "<span class='warning'>The beacon crackles with power before collapsing into pieces!</span>"
	max_integrity = 250
	light_color = "#EF078E"
	var/time_remaining = 300 //Amount of seconds left to vote on whether or not to activate the beacon
	var/list/voters  //People who have voted to activate the beacon
	var/votes_needed = 0 //How many votes are needed to activate the beacon
	var/available = FALSE //If the beacon can be used

/obj/structure/destructible/clockwork/heralds_beacon/Initialize()
	. = ..()
	voters = list()
	START_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/heralds_beacon/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/structure/destructible/clockwork/heralds_beacon/process()
	if(!available)
		if(istype(SSticker.mode, /datum/game_mode/clockwork_cult))
			available = TRUE
		else
			return
	if(!SSticker.mode.servants_of_ratvar.len)
		return
	if(!votes_needed)
		var/servants = SSticker.mode.servants_of_ratvar.len
		if(servants)
			votes_needed = round(servants * 0.66)
	time_remaining--
	if(!time_remaining)
		hierophant_message("<span class='bold sevtug_small'>[src] has lost its power, and can no longer be activated.</span>")
		for(var/mob/M in GLOB.player_list)
			if(isobserver(M) || is_servant_of_ratvar(M))
				M.playsound_local(M, 'sound/magic/blind.ogg', 50, FALSE)
		available = FALSE
		icon_state = "interdiction_lens_unwrenched"
		STOP_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/heralds_beacon/examine(mob/user)
	..()
	if(isobserver(user) || is_servant_of_ratvar(user))
		if(!available)
			if(!GLOB.ratvar_approaches)
				to_chat(user, "<span class='bold alloy'>It can no longer be activated.</span>")
			else
				to_chat(user, "<span class='bold neovgre_small'>It has been activated!</span>")
		else
			to_chat(user, "<span class='brass'>There are <b>[time_remaining]</b> second[time_remaining != 1 ? "s" : ""] remaining to vote.</span>")
			to_chat(user, "<span class='big brass'>There are <b>[voters.len]/[votes_needed]</b> votes to activate the beacon!</span>")

/obj/structure/destructible/clockwork/heralds_beacon/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='notice'>You can tell how powerful [src] is; you know better than to touch it.</span>")
		return
	if(!available)
		to_chat(user, "<span class='danger'>You can no longer vote with [src].</span>")
		return
	var/voting = !(user.key in voters)
	if(alert(user, "[voting ? "Cast a" : "Undo your"] vote to activate the beacon?", "Herald's Beacon", "Change Vote", "Cancel") == "Cancel")
		return
	if(!user.canUseTopic(src) || !is_servant_of_ratvar(user) || !available)
		return
	if(voting)
		if(user.key in voters)
			return
		voters += user.key
	else
		if(!user.key in voters)
			return
		voters -= user.key
	var/votes_left = votes_needed - voters.len
	message_admins("[ADMIN_LOOKUPFLW(user)] has [voting ? "voted" : "undone their vote"] to activate [src]! [ADMIN_JMP(user)]")
	hierophant_message("<span class='brass'><b>[user.real_name]</b> has [voting ? "voted" : "undone their vote"] to activate [src]! The beacon needs [votes_left] more votes to activate.")
	for(var/mob/M in GLOB.player_list)
		if(isobserver(M) || is_servant_of_ratvar(M))
			M.playsound_local(M, 'sound/magic/clockwork/fellowship_armory.ogg', 50, FALSE)
	if(!votes_left)
		herald_the_justiciar()

/obj/structure/destructible/clockwork/heralds_beacon/proc/herald_the_justiciar()
	priority_announce("A powerful group of fanatical zealots following the cause of Ratvar have brazenly sacrificed stealth for power, and dare anyone \
	to try and stop them.", title = "The Justiciar Comes", sound = 'sound/ambience/antag/new_clock.ogg')
	GLOB.ratvar_approaches = TRUE
	available = FALSE
	STOP_PROCESSING(SSprocessing, src)
	icon_state = "interdiction_lens_active"
	hierophant_message("<span class='big bold brass'>The beacon's activation has given your team great power! Many of your objects are permanently empowered, and \
	you have an extra ten minutes to prepare before the Ark activates.</span>")
	for(var/mob/living/simple_animal/hostile/clockwork/C in GLOB.all_clockwork_mobs)
		if(C.stat == DEAD)
			continue
		C.update_values()
		to_chat(C, C.empower_string)
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
	G.seconds_until_activation += 600
	SSshuttle.registerHostileEnvironment(G) //no leaving when we need to purge you, heretics
