
/datum/action/innate/cultcomm
	name = "Communion"
	button_icon_state = "cult_comms"
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS

/datum/action/innate/cultcomm/IsAvailable()
	if(!iscultist(owner))
		return 0
	return ..()

/datum/action/innate/cultcomm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return

	cultist_commune(usr, input)
	return

/proc/cultist_commune(mob/living/user, message)
	if(!message)
		return
	if(!ishuman(user))
		user.say("O bidai nabora se[pick("'","`")]sma!")
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!")
	sleep(10)
	if(!user)
		return
	if(!ishuman(user))
		user.say(html_decode(message))
	else
		user.whisper(html_decode(message))
	var/my_message = "<span class='cultitalic'><b>[(ishuman(user) ? "Acolyte" : "Construct")] [user]:</b> [message]</span>"
	for(var/mob/M in mob_list)
		if(iscultist(M))
			M << my_message
		else if(M in dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			M << "[link] [my_message]"

	log_say("[user.real_name]/[user.key] : [message]")

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
	you should use cuffs or a talisman of shackling on them and remove their headset before they recover (this must be done quickly). Some targets like security or hardsuit users cannot have their headsets removed quickly, you can use \
	your tome as a powerful melee weapon to beat them unconscious or an additional stun or EMP talisman to keep them quiet. Anyone with a loyalty implant cannot be converted and should be sacrificed, sacrifice victims will their soul \ 
	behind in a shard, these shards can be used on construct shells to make powerful servants for the cult. Your construct minions can invoke many runes, but cannot create their own.<br><br>"

	text += "<font color='red'><b>VI. VICTORY</b></font><br>You have two ultimate goals as a cultist, sacrifice your target, and summon Nar-Sie. Sacrificing the target involves killing that individual and then placing \
	their corpse on a sacrifice rune and triggering that rune with THREE cultists. Do NOT lose the target's corpse! Only once the target is sacrificed can Nar-Sie be summoned. Summoning Nar-Sie will take nearly one minute \
	just to draw the massive rune needed. Do not create the rune until your cult is ready to bring the Dark One into this world!<br><br>"

	var/datum/browser/popup = new(usr, "mind", "", 800, 600)
	popup.set_content(text)
	popup.open()
	return 1
	
/mob/living/proc/cult_master()
	set category = "Cultist"
	set name = "Assert Leadership"
	pollCultists()
	return

/datum/action/innate/cultmast
	name = "FinalReckoning"
	button_icon_state = "sintouch"
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS

/datum/action/innate/cultmast/IsAvailable()
	if(owner.mind.special_role != "Cult Master")
		return 0
	return ..()

/datum/action/innate/cultmast/Activate()
	for(var/i in 1 to 4)
		if(do_after(owner, 30, target = owner))
			for(var/mob/M in mob_list)
				if(iscultist(M) && M != owner)
					var/turf/mobloc = get_turf(M)
					switch(i)
						if (1)
							new /obj/effect/overlay/temp/cult/sparks(mobloc, M.dir)
							playsound(mobloc, "sparks", 50, 1)
						if (2)
							new /obj/effect/overlay/temp/dir_setting/cult/phase/out(mobloc, M.dir)
							playsound(mobloc, "sparks", 75, 1)
						if (3)
							new /obj/effect/overlay/temp/dir_setting/cult/phase(mobloc, M.dir)
							playsound(mobloc, "sparks", 100, 1)
						if (4)
							new /obj/effect/overlay/temp/cult/spray (mobloc)
							playsound(mobloc, 'sound/magic/lightningbolt.ogg', 100, 1)
							mobloc = get_turf(owner)
							M.forceMove(mobloc)
		if(i == 4)
			for(var/datum/action/innate/cultmast/H in owner.actions)
				qdel(H)


/datum/action/innate/cultmark
    name = "Mark"
    desc = "Marks a target for the cult"
    check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
    var/obj/effect/proc_holder/cultmark/CM

/datum/action/innate/cultmark/New()
    CM = new()
    ..()

/datum/action/innate/cultmark/Destroy()
    qdel(CM)
    CM = null
    return ..()

/datum/action/innate/cultmark/Activate()
    CM.toggle(owner) //the important bit
    return TRUE

/obj/effect/proc_holder/cultmark
    active = FALSE
    ranged_mousepointer = 'icons/effects/cult_target.dmi'

/obj/effect/proc_holder/cultmark/proc/toggle(mob/user) //the important bit
    if(active)
        remove_ranged_ability("You cease the marking ritual...")
    else
        add_ranged_ability(user, "You prepare to mark a target for your cult...")

/obj/effect/proc_holder/cultmark/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return FALSE
	if(target in view(7, get_turf(ranged_ability_user)))
		blood_target = target
		for(var/mob/M in mob_list)
			if(iscultist(M))
				M << "<span class='cultlarge'><b>["Master"] [caller] has marked [blood_target] as the cult's highest priority, get there immediately!</b></span>"
		remove_ranged_ability(caller, "The marking rite is complete! Your mark will last for 2 minutes or until a new mark is added")
		spawn(120)
			blood_target = null
			for(var/mob/M in mob_list)
				if(iscultist(M))
					M << "<span class='cultlarge'><b>The blood mark has expired!</b></span>"
		return TRUE
	return FALSE
