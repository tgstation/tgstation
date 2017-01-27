/datum/action/innate/umbrage
	name = "umbrage ability"
	desc = "This probably shouldn't exist."
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	var/psi_cost = 0
	var/blacklisted = 1 //If the ability isn't available from Divulge

/datum/action/innate/umbrage/Activate() //When making a new umbrage ability, add ..() at the end of its Activate()
	..()
	var/datum/umbrage/U = get_umbrage()
	if(U)
		U.use_psi(psi_cost)

/datum/action/innate/umbrage/IsAvailable()
	var/datum/umbrage/U = get_umbrage()
	if(!U)
		return
	if(U.psi < psi_cost)
		usr << "<span class='warning'>You need more psi!</span>"
		return
	return ..()

/datum/action/innate/umbrage/proc/get_umbrage()
	return owner.mind.umbrage_psionics



//Devour Will: After a brief charge-up, equips a dark bead.
//	- The dark bead disappears after one second of no use.
//	- Attacking someone using the dark bead will drain their thoughts.
//	- This knocks them out as well as fully recharging psi.
//	- Finally, they will be made vulnerable to Veil Mind for five ticks.
/datum/action/innate/umbrage/devour_will
	name = "Devour Will"
	desc = "Creates a dark bead that can be used on a human to fully recharge psi and knock them out.<br><br>Costs 20 psi."
	button_icon_state = "umbrage_devour_will"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	psi_cost = 20
	blacklisted = 0
	var/victims = list() //A list of people we've used the bead on recently; we can't drain them again so soon

/datum/action/innate/umbrage/devour_will/IsAvailable()
	if(!usr)
		return
	if(!usr.get_empty_held_indexes())
		usr << "<span class='warning'>You need a free hand to create a dark bead!</span>"
		return
	return ..()

/datum/action/innate/umbrage/devour_will/Activate()
	usr.visible_message("<span class='warning'>[usr]'s hand begins to shimmer...</span>", "<span class='velvet_bold'>pwga...</span><br>\
	<span class='notice'>You begin forming a dark bead...</span>")
	playsound(usr, 'sound/magic/devour_will_begin.ogg', 50, 0)
	if(!do_after(usr, 10, target = usr))
		return
	usr.visible_message("<span class='warning'>A glowing black orb appears in [usr]'s hand!</span>", "<span class='velvet_bold'>...iejz</span><br>\
	<span class='notice'>You form a dark bead in your hand.</span>")
	playsound(usr, 'sound/magic/devour_will_form.ogg', 50, 0)
	var/obj/item/weapon/umbrage_dark_bead/B = new
	usr.put_in_hands(B)
	B.linked_ability = src
	..()
	return 1



//Veil Mind: Converts all eligible targets nearby into veils. Targets become eligible for a short time when drained by Devour Will.
/datum/action/innate/umbrage/veil_mind
	name = "Veil Mind"
	desc = "Converts nearby eligible targets into thralls. To be eligible, they must be alive and recently drained by Devour Will.<br><br>Costs 30 psi."
	button_icon_state = "umbrage_veil_mind"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	blacklisted = 0
	psi_cost = 30

/datum/action/innate/umbrage/veil_mind/IsAvailable()
	if(!usr)
		return
	return ..()

/datum/action/innate/umbrage/veil_mind/Activate()
	var/mob/living/carbon/human/H = usr
	if(!H.can_speak_vocal())
		H << "<span class='warning'>You can't speak!</span>"
		return
	usr.visible_message("<span class='warning'>[usr]'s sigils flare as they inhale...</span>", "<span class='velvet_bold'>dawn kqn okjc...</span><br>\
	<span class='notice'>You take a deep breath...</span>")
	playsound(usr, 'sound/magic/veil_mind_gasp.ogg', 25, 1)
	if(!do_after(usr, 10, target = usr))
		return
	usr.visible_message("<span class='boldwarning'>[usr] lets out a chilling cry!</span>", "<span class='velvet_bold'>...wjz oanra</span><br>\
	<span class='notice'>You veil the minds of everyone nearby.</span>")
	playsound(usr, 'sound/magic/veil_mind_scream.ogg', 100, 0)
	for(var/mob/living/L in view(3, usr))
		if(L == usr)
			continue
		if(issilicon(L))
			L << "<span class='userdanger'>$@!) ERR: RECEPTOR OVERLOAD ^!</</span>"
			L << sound('sound/misc/interference.ogg', volume = 50)
			L.emote("alarm")
			L.Stun(2)
			L.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			L.clear_fullscreen("flash", 10)
		else
			if(L.ear_deaf)
				L << "<span class='warning'>...but you can't hear it!</span>"
			else
				if(L.status_flags & FAKEDEATH)
					usr << "<span class='velvet'><b>[L]</b> has become a veil.</span>"
					L << "<span class='velvet_large'><b>ukq wna ieja jks</b></span>"
					L << "<b>Your mind goes numb. Your thoughts go blank. You feel more vulnerable than you have ever felt. But then, you dream.\n\
					You dream of a vast, empty Void in the deep of space. Stars do not tread there, for they fear what lies within.\n\
					An ancient, unknowable being makes the Void its home. It has a name, but to speak it is heresy. It has a form, but to behold it is madness.\n\
					You hear the voice of the Progenitor reach for you, and you are helpeless to resist its call. Your mind tears itself to tatters, and you know you are destined for much, much more.\n\
					Your former allegiances are now forfeit. You serve the Progenitor above all else, and you must answer to its servants, the umbrages. Obey their every command, and perhaps you will soon be free...</b>"
					L << sound('sound/magic/become_veil.ogg', volume = 50)
					flash_color(L, flash_color = "#21007F", flash_time = 100)
				else
					L << "<span class='boldwarning'>...and it scrambles your thoughts!</span>"
					L.dir = pick(cardinal)
					L.confused += 2



//Demented Outburst: Deafens and confuses listeners. Even if they can't hear it, everyone will be knocked away and staggered by its force.
/datum/action/innate/umbrage/demented_outburst
	name = "Demented Outburst"
	desc = "Deafens and confuses listeners, and knocks away everyone nearby. Incredibly loud.<br><br>Costs 80 psi."
	button_icon_state = "umbrage_demented_outburst"
	check_flags = AB_CHECK_CONSCIOUS
	blacklisted = 0
	psi_cost = 80 //big boom = big cost

/datum/action/innate/umbrage/demented_outburst/IsAvailable()
	if(!usr)
		return
	return ..()

/datum/action/innate/umbrage/demented_outburst/Activate()
	usr.visible_message("<span class='warning'>[usr] begins to growl!</span>", "<span class='velvet_bold'>cap...</span><br>\
	<span class='danger'>You begin harnessing every ounce of your power...</span>")
	playsound(usr, 'sound/magic/demented_outburst_charge.ogg', 100, 0)
	addtimer(CALLBACK(src, .proc/outburst, usr), 50)

/datum/action/innate/umbrage/demented_outburst/proc/outburst(mob/living/user)
	if(!user || user.stat)
		return
	user.visible_message("<span class='boldwarning'>[user] lets out a deafening scream!</span>", "<span class='velvet_bold'><i>WSWU!</i></span><br>\
	<span class='danger'>You let out a deafening outburst!</span>")
	playsound(user, 'sound/magic/demented_outburst_scream.ogg', 150, 0)
	var/list/thrown_atoms = list()
	for(var/turf/T in view(5, user))
		for(var/atom/movable/AM in T)
			thrown_atoms += AM
	for(var/atom/movable/AM in thrown_atoms)
		if(AM == user || AM.anchored)
			continue
		var/distance = get_dist(user, AM)
		var/turf/target = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		AM.throw_at(target, ((Clamp((5 - (Clamp(distance - 2, 0, distance))), 3, 5))), 1, user)
		if(iscarbon(AM))
			var/mob/living/carbon/L = AM
			if(distance <= 1) //you done fucked up now
				L.visible_message("<span class='warning'>The blast sends [L] flying!</span>", "<span class='userdanger'>The force sends you flying!</span>")
				L.Weaken(5)
				L.adjustBruteLoss(10)
				L.soundbang_act(1, 5, 15, 5)
			else if(distance <= 3)
				L.visible_message("<span class='warning'>The blast knocks [L] off their feet!</span>", "<span class='userdanger'>The force bowls you over!</span>")
				L.Weaken(3)
				L.soundbang_act(1, 3, 5, 0)
	var/datum/umbrage/U = get_umbrage()
	U.use_psi(psi_cost)
	return 1
