// Contains cult communion, guide, and cult master abilities
#define MARK_COOLDOWN

/datum/action/innate/cult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/innate/cult/IsAvailable()
	if(!iscultist(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/comm
	name = "Communion"
	button_icon_state = "cult_comms"

/datum/action/innate/cult/comm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return

	cultist_commune(usr, input)

/proc/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	user.whisper("O bidai nabora se[pick("'","`")]sma!", language = /datum/language/common)
	user.whisper(html_decode(message))
	var/title = "Acolyte"
	var/span = "cultitalic"
	if(user.mind && user.mind.has_antag_datum(ANTAG_DATUM_CULT_MASTER))
		span = "cultlarge"
		if(ishuman(user))
			title = "Master"
		else
			title = "Lord"
	else if(!ishuman(user))
		title = "Construct"
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/mob/M in GLOB.mob_list)
		if(iscultist(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	log_talk(user,"CULT:[key_name(user)] : [message]",LOGSAY)

/mob/living/proc/cult_help()
	set category = "Cultist"
	set name = "How to Play Cult"
	var/text = ""
	text += "<center><font color='red' size=3><b><i>Tenets of the Dark One</i></b></font></center><br><br><br>"

	text += "<font color='red'><b>I. SECRECY</b></font><br>Your cult is a SECRET organization. Your success DEPENDS on keeping your cult's members and locations SECRET for as long as possible. This means that your tome should be hidden \
	in your bag and never brought out in public. You should never create runes where other crew might find them, and you should avoid using talismans or other cult magic with witnesses around.<br><br>"

	text += "<font color='red'><b>II. TOME</b></font><br>You start with a unique talisman in your bag. This supply talisman can be used 3 times, and creates starter equipment for your cult. The most critical of the talisman's functions is \
	the power to create a tome. This tome is your most important item and summoning one (in secret) is your FIRST PRIORITY. It lets you talk to fellow cultists and create runes, which in turn is essential to growing the cult's power.<br><br>"

	text += "<font color='red'><b>III. RUNES</b></font><br>Runes are powerful sources of cult magic. Your tome will allow you to draw runes with your blood. Those runes, when hit with an empty hand, will attempt to \
	trigger the rune's magic. Runes are essential for the cult to convert new members, create powerful minions, or call upon incredibly powerful magic. Some runes require more than one cultist to use.<br><br>"

	text += "<font color='red'><b>IV. TALISMANS</b></font><br>Talismans are a mobile source of cult magic that are NECESSARY to achieve success as a cult. Your starting talisman can produce certain talismans, but you will need \
	to use the -create talisman- rune (with ordinary paper on top) to get more talismans. Talismans are EXTREMELY powerful, therefore creating more talismans in a HIDDEN location should be one of your TOP PRIORITIES.<br><br>"

	text += "<font color='red'><b>V. GROW THE CULT</b></font><br>There are certain basic strategies that all cultists should master. STUN talismans are the foundation of a successful cult. If you intend to convert the stunned person \
	you should use cuffs or a talisman of shackling on them and remove their headset before they recover (it takes about 10 seconds to recover). If you intend to sacrifice the victim, striking them quickly and repeatedly with your tome \
	will knock them out before they can recover. Sacrificed victims will their soul behind in a shard, these shards can be used on construct shells to make powerful servants for the cult. Remember you need TWO cultists standing near a \
	conversion rune to convert someone. Your construct minions cannot trigger most runes, but they will count as cultists in helping you trigger more powerful runes like conversion or blood boil.<br><br>"

	text += "<font color='red'><b>VI. VICTORY</b></font><br>You have two ultimate goals as a cultist, sacrifice your target, and summon Nar-Sie. Sacrificing the target involves killing that individual and then placing \
	their corpse on a sacrifice rune and triggering that rune with THREE cultists. Do NOT lose the target's corpse! Only once the target is sacrificed can Nar-Sie be summoned. Summoning Nar-Sie will take nearly one minute \
	just to draw the massive rune needed. Do not create the rune until your cult is ready, the crew will receive the NAME and LOCATION of anyone who attempts to create the Nar-Sie rune. Once the Nar-Sie rune is drawn \
	you must gathered 9 cultists (or constructs) over the rune and then click it to bring the Dark One into this world!<br><br>"

	var/datum/browser/popup = new(usr, "mind", "", 800, 600)
	popup.set_content(text)
	popup.open()
	return 1

/datum/action/innate/cult/mastervote
	name = "Assert Leadership"
	button_icon_state = "cultvote"

/datum/action/innate/cult/mastervote/IsAvailable()
	if(GLOB.cult_vote_called || !ishuman(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/mastervote/Activate()
	pollCultists(owner)

/proc/pollCultists(var/mob/living/Nominee) //Cult Master Poll
	if(world.time < CULT_POLL_WAIT)
		to_chat(Nominee, "It would be premature to select a leader while everyone is still settling in, try again in [round((CULT_POLL_WAIT-world.time)/10)] seconds.")
		return
	GLOB.cult_vote_called = TRUE //somebody's trying to be a master, make sure we don't let anyone else try
	for(var/datum/mind/B in SSticker.mode.cult)
		if(B.current)
			B.current.update_action_buttons_icon()
			if(!B.current.incapacitated())
				SEND_SOUND(B.current, 'sound/hallucinations/im_here1.ogg')
				to_chat(B.current, "<span class='cultlarge'>Acolyte [Nominee] has asserted that they are worthy of leading the cult. A vote will be called shortly.</span>")
	sleep(100)
	var/list/asked_cultists = list()
	for(var/datum/mind/B in SSticker.mode.cult)
		if(B.current && B.current != Nominee && !B.current.incapacitated())
			SEND_SOUND(B.current, 'sound/magic/exit_blood.ogg')
			asked_cultists += B.current
	var/list/yes_voters = pollCandidates("[Nominee] seeks to lead your cult, do you support [Nominee.p_them()]?", poll_time = 300, group = asked_cultists)
	if(QDELETED(Nominee) || Nominee.incapacitated())
		GLOB.cult_vote_called = FALSE
		for(var/datum/mind/B in SSticker.mode.cult)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current,"<span class='cultlarge'>[Nominee] has died in the process of attempting to win the cult's support!")
		return FALSE
	if(!Nominee.mind)
		GLOB.cult_vote_called = FALSE
		for(var/datum/mind/B in SSticker.mode.cult)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current,"<span class='cultlarge'>[Nominee] has gone catatonic in the process of attempting to win the cult's support!")
		return FALSE
	if(LAZYLEN(yes_voters) <= LAZYLEN(asked_cultists) * 0.5)
		GLOB.cult_vote_called = FALSE
		for(var/datum/mind/B in SSticker.mode.cult)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current, "<span class='cultlarge'>[Nominee] could not win the cult's support and shall continue to serve as an acolyte.")
		return FALSE
	GLOB.cult_mastered = TRUE
	SSticker.mode.remove_cultist(Nominee.mind, TRUE)
	Nominee.mind.add_antag_datum(ANTAG_DATUM_CULT_MASTER)
	for(var/datum/mind/B in SSticker.mode.cult)
		if(B.current)
			for(var/datum/action/innate/cult/mastervote/vote in B.current.actions)
				vote.Remove(B.current)
			if(!B.current.incapacitated())
				to_chat(B.current,"<span class='cultlarge'>[Nominee] has won the cult's support and is now their master. Follow [Nominee.p_their()] orders to the best of your ability!")
	return TRUE

/datum/action/innate/cult/master/IsAvailable()
	if(!owner.mind || !owner.mind.has_antag_datum(ANTAG_DATUM_CULT_MASTER) || GLOB.cult_narsie)
		return 0
	return ..()

/datum/action/innate/cult/master/finalreck
	name = "Final Reckoning"
	desc = "A single-use spell that brings the entire cult to the master's location."
	button_icon_state = "sintouch"

/datum/action/innate/cult/master/finalreck/Activate()
	for(var/i in 1 to 4)
		chant(i)
		var/list/destinations = list()
		for(var/turf/T in orange(1, owner))
			if(!is_blocked_turf(T, TRUE))
				destinations += T
		if(!LAZYLEN(destinations))
			to_chat(owner, "<span class='warning'>You need more space to summon the cult!</span>")
			return
		if(do_after(owner, 30, target = owner))
			for(var/datum/mind/B in SSticker.mode.cult)
				if(B.current && B.current.stat != DEAD)
					var/turf/mobloc = get_turf(B.current)
					switch(i)
						if(1)
							new /obj/effect/temp_visual/cult/sparks(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 50, 1)
						if(2)
							new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 75, 1)
						if(3)
							new /obj/effect/temp_visual/dir_setting/cult/phase(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 100, 1)
						if(4)
							playsound(mobloc, 'sound/magic/exit_blood.ogg', 100, 1)
							if(B.current != owner)
								var/turf/final = pick(destinations)
								if(istype(B.current.loc, /obj/item/device/soulstone))
									var/obj/item/device/soulstone/S = B.current.loc
									S.release_shades(owner)
								B.current.setDir(SOUTH)
								new /obj/effect/temp_visual/cult/blood(final)
								addtimer(CALLBACK(B.current, /mob/.proc/reckon, final), 10)
		else
			return
	GLOB.reckoning_complete = TRUE
	Remove(owner)

/mob/proc/reckon(turf/final)
	new /obj/effect/temp_visual/cult/blood/out(get_turf(src))
	forceMove(final)

/datum/action/innate/cult/master/finalreck/proc/chant(chant_number)
	switch(chant_number)
		if(1)
			owner.say("C'arta forbici!", language = /datum/language/common)
		if(2)
			owner.say("Pleggh e'ntrath!", language = /datum/language/common)
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 50, 1)
		if(3)
			owner.say("Barhah hra zar'garis!", language = /datum/language/common)
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 75, 1)
		if(4)
			owner.say("N'ath reth sh'yro eth d'rekkathnor!!!", language = /datum/language/common)
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 100, 1)

/datum/action/innate/cult/master/cultmark
	name = "Mark Target"
	desc = "Marks a target for the cult."
	button_icon_state = "cult_mark"
	var/obj/effect/proc_holder/cultmark/CM
	var/cooldown = 0
	var/base_cooldown = 1200

/datum/action/innate/cult/master/cultmark/New()
	CM = new()
	CM.attached_action = src
	..()

/datum/action/innate/cult/master/cultmark/IsAvailable()
	if(!owner.mind || !owner.mind.has_antag_datum(ANTAG_DATUM_CULT_MASTER))
		return FALSE
	if(cooldown > world.time)
		if(!CM.active)
			to_chat(owner, "<span class='cultlarge'><b>You need to wait [round((cooldown - world.time) * 0.1)] seconds before you can mark another target!</b></span>")
		return FALSE
	return ..()

/datum/action/innate/cult/master/cultmark/Destroy()
	QDEL_NULL(CM)
	return ..()

/datum/action/innate/cult/master/cultmark/Activate()
	CM.toggle(owner) //the important bit
	return TRUE

/obj/effect/proc_holder/cultmark
	active = FALSE
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
	var/datum/action/innate/cult/master/cultmark/attached_action

/obj/effect/proc_holder/cultmark/Destroy()
	attached_action = null
	return ..()

/obj/effect/proc_holder/cultmark/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability("<span class='cult'>You cease the marking ritual.</span>")
	else
		add_ranged_ability(user, "<span class='cult'>You prepare to mark a target for your cult...</span>")

/obj/effect/proc_holder/cultmark/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(target in view(7, get_turf(ranged_ability_user)))
		GLOB.blood_target = target
		var/area/A = get_area(target)
		attached_action.cooldown = world.time + attached_action.base_cooldown
		addtimer(CALLBACK(attached_action.owner, /mob.proc/update_action_buttons_icon), attached_action.base_cooldown)
		GLOB.blood_target_image = image('icons/effects/cult_target.dmi', target, "glow", ABOVE_MOB_LAYER)
		GLOB.blood_target_image.appearance_flags = RESET_COLOR
		GLOB.blood_target_image.pixel_x = -target.pixel_x
		GLOB.blood_target_image.pixel_y = -target.pixel_y
		for(var/datum/mind/B in SSticker.mode.cult)
			if(B.current && B.current.stat != DEAD && B.current.client)
				to_chat(B.current, "<span class='cultlarge'><b>Master [ranged_ability_user] has marked [GLOB.blood_target] in the [A.name] as the cult's top priority, get there immediately!</b></span>")
				SEND_SOUND(B.current, sound(pick('sound/hallucinations/over_here2.ogg','sound/hallucinations/over_here3.ogg'),0,1,75))
				B.current.client.images += GLOB.blood_target_image
		attached_action.owner.update_action_buttons_icon()
		remove_ranged_ability("<span class='cult'>The marking rite is complete! It will last for 90 seconds.</span>")
		GLOB.blood_target_reset_timer = addtimer(CALLBACK(GLOBAL_PROC, .proc/reset_blood_target), 900, TIMER_STOPPABLE)
		return TRUE
	return FALSE

/proc/reset_blood_target()
	for(var/datum/mind/B in SSticker.mode.cult)
		if(B.current && B.current.stat != DEAD && B.current.client)
			if(GLOB.blood_target)
				to_chat(B.current,"<span class='cultlarge'><b>The blood mark has expired!</b></span>")
			B.current.client.images -= GLOB.blood_target_image
	QDEL_NULL(GLOB.blood_target_image)
	GLOB.blood_target = null



//////// ELDRITCH PULSE /////////



/datum/action/innate/cult/master/pulse
	name = "Eldritch Pulse"
	desc = "Seize upon a fellow cultist or cult structure and teleport it to a nearby location."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "arcane_barrage"
	var/obj/effect/proc_holder/pulse/PM
	var/cooldown = 0
	var/base_cooldown = 150
	var/throwing = FALSE
	var/mob/living/throwee

/datum/action/innate/cult/master/pulse/New()
	PM = new()
	PM.attached_action = src
	..()

/datum/action/innate/cult/master/pulse/IsAvailable()
	if(!owner.mind || !owner.mind.has_antag_datum(ANTAG_DATUM_CULT_MASTER))
		return FALSE
	if(cooldown > world.time)
		if(!PM.active)
			to_chat(owner, "<span class='cultlarge'><b>You need to wait [round((cooldown - world.time) * 0.1)] seconds before you can pulse again!</b></span>")
		return FALSE
	return ..()

/datum/action/innate/cult/master/pulse/Destroy()
	QDEL_NULL(PM)
	return ..()

/datum/action/innate/cult/master/pulse/Activate()
	PM.toggle(owner) //the important bit
	return TRUE

/obj/effect/proc_holder/pulse
	active = FALSE
	ranged_mousepointer = 'icons/effects/throw_target.dmi'
	var/datum/action/innate/cult/master/pulse/attached_action

/obj/effect/proc_holder/pulse/Destroy()
	QDEL_NULL(attached_action)
	return ..()

/obj/effect/proc_holder/pulse/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability("<span class='cult'>You cease your preparations...</span>")
		attached_action.throwing = FALSE
	else
		add_ranged_ability(user, "<span class='cult'>You prepare to tear through the fabric of reality...</span>")

/obj/effect/proc_holder/pulse/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(target in view(7, get_turf(ranged_ability_user)))
		if((!(iscultist(target) || istype(target, /obj/structure/destructible/cult)) || target == caller) && !(attached_action.throwing))
			return
		if(!attached_action.throwing)
			attached_action.throwing = TRUE
			attached_action.throwee = target
			SEND_SOUND(ranged_ability_user, sound('sound/weapons/thudswoosh.ogg'))
			to_chat(ranged_ability_user,"<span class='cult'><b>You reach through the veil with your mind's eye and seize [target]!</b></span>")
			return
		else
			new /obj/effect/temp_visual/cult/sparks(get_turf(attached_action.throwee), ranged_ability_user.dir)
			var/distance = get_dist(attached_action.throwee, target)
			if(distance >= 16)
				return
			playsound(target,'sound/magic/exit_blood.ogg')
			attached_action.throwee.Beam(target,icon_state="sendbeam",time=4)
			attached_action.throwee.forceMove(get_turf(target))
			new /obj/effect/temp_visual/cult/sparks(get_turf(target), ranged_ability_user.dir)
			attached_action.throwing = FALSE
			attached_action.cooldown = world.time + attached_action.base_cooldown
			remove_mousepointer(ranged_ability_user.client)
			remove_ranged_ability("<span class='cult'>A pulse of blood magic surges through you as you shift [attached_action.throwee] through time and space.</span>")
			caller.update_action_buttons_icon()
			addtimer(CALLBACK(caller, /mob.proc/update_action_buttons_icon), attached_action.base_cooldown)
