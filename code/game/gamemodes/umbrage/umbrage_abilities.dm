/datum/action/innate/umbrage
	name = "umbrage ability"
	desc = "This probably shouldn't exist."
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	var/psi_cost = 0

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
	return usr.mind.umbrage_psionics



//Devour Will: After a brief charge-up, equips a dark bead.
//	- The dark bead disappears after one second of no use.
//	- Attacking someone using the dark bead will drain their thoughts.
//	- This knocks them out as well as fully recharging psi.
//	- Finally, they will be made vulnerable to Veil Mind for five ticks.
/datum/action/innate/umbrage/devour_will
	name = "Devour Will"
	desc = "Creates a dark bead that can be used on a human to fully recharge psi and knock them out."
	button_icon_state = "umbrage_devour_will"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	psi_cost = 20
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
	desc = "Converts nearby eligible targets into thralls. To be eligible, they must be alive and recently drained by Devour Will."
	button_icon_state = "umbrage_veil_mind"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
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
	usr.visible_message("<span class='boldwarning'>[usr] lets out a horrific scream!</span>", "<span class='velvet_bold'>...wjz oanra</span><br>\
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
					L.visible_message("<span class='warning'>[L] convulses wildly!</span>", "<span class='velvet_large'><b>ukq wna ieja jks</b></span>")
				else
					L << "<span class='boldwarning'>...and it scrambles your thoughts!</span>"
					L.dir = pick(cardinal)
					L.confused += 2
