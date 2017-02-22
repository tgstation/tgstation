/datum/action/innate/umbrage
	name = "umbrage ability"
	var/id //The ability's ID, for giving, taking and such
	desc = "This probably shouldn't exist."
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	var/psi_cost = 0
	var/lucidity_cost = 0 //How much lucidity the ability costs to buy; if this is 0, it isn't listed on the catalog
	var/blacklisted = 1 //If the ability can't be gained from the psi web
	var/datum/umbrage/linked_umbrage //Our linked umbrage datum

/datum/action/innate/umbrage/Trigger()
	var/successful_activation = 0
	if(!IsAvailable())
		return
	successful_activation = Activate()
	if(successful_activation)
		var/datum/umbrage/U = linked_umbrage
		if(U)
			U.use_psi(psi_cost)

/datum/action/innate/umbrage/IsAvailable()
	var/datum/umbrage/U = linked_umbrage
	if(!U)
		return
	if(U.psi < psi_cost)
		return
	return ..()


//Devour Will: After a brief charge-up, equips a dark bead.
//	- The dark bead disappears after three seconds of no use.
//	- Attacking someone using the dark bead will drain their thoughts.
//	- This knocks them out as well as fully recharging psi.
//	- Finally, they will be made vulnerable to Veil Mind for five ticks.
/datum/action/innate/umbrage/devour_will
	name = "Devour Will"
	id = "devour_will"
	desc = "Creates a dark bead that can be used on a human to fully recharge psi and knock them out."
	button_icon_state = "umbrage_devour_will"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	psi_cost = 20
	lucidity_cost = 0 //Baseline
	blacklisted = 1
	var/list/victims //A list of people we've used the bead on recently; we can't drain them again so soon

/datum/action/innate/umbrage/devour_will/IsAvailable()
	if(!owner || !owner.get_empty_held_indexes())
		return
	return ..()

/datum/action/innate/umbrage/devour_will/Activate()
	owner.visible_message("<span class='warning'>[owner]'s hand begins to shimmer...</span>", "<span class='velvet bold'>pwga...</span><br>\
	<span owner='notice'>You begin forming a dark bead...</span>")
	playsound(owner, 'sound/magic/devour_will_begin.ogg', 50, 1)
	if(!do_after(owner, 10, target = owner))
		return
	owner.visible_message("<span class='warning'>A glowing black orb appears in [owner]'s hand!</span>", "<span class='velvet bold'>...iejz</span><br>\
	<span class='notice'>You form a dark bead in your hand.</span>")
	playsound(owner, 'sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/item/weapon/dark_bead/B = new
	owner.put_in_hands(B)
	B.linked_ability = src
	return TRUE


//Pass: Equips umbral tendrils.
// - The tendrils' uses are many and varied, including mobility, offense, and more.
/datum/action/innate/umbrage/pass
	name = "Pass"
	id = "pass"
	desc = "Twists an active arm into tendrils with many uses."
	button_icon_state = "umbrage_pass"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	psi_cost = 0
	lucidity_cost = 1
	blacklisted = 0

/datum/action/innate/umbrage/pass/IsAvailable()
	if(!owner || !owner.get_empty_held_indexes())
		return
	return ..()

/datum/action/innate/umbrage/pass/Activate()
	owner.visible_message("<span class='warning'>[owner]'s arm contorts into tentacles!</span>", "<span class='velvet bold'>ikna</span><br>\
	<span class='notice'>You transform your arm into umbral tendrils.</span>")
	playsound(owner, 'sound/magic/devour_will_begin.ogg', 50, 1)
	var/obj/item/weapon/umbral_tendrils/T = new
	owner.put_in_hands(T)
	T.linked_umbrage = linked_umbrage
	active = 1
	return TRUE


/datum/action/innate/umbrage/pass/Deactivate()
	owner.visible_message("<span class='warning'>[owner]'s tentacles contort into an arm!</span>", "<span class='velvet bold'>haoo</span><br>\
	<span class='notice'>You reform your arm.</span>")
	for(var/obj/item/weapon/umbral_tendrils/T in owner)
		qdel(T)
	active = 0
	return TRUE


//Veil Mind: Converts all eligible targets nearby into veils. Targets become eligible for a short time when drained by Devour Will.
/datum/action/innate/umbrage/veil_mind
	name = "Veil Mind"
	id = "veil_mind"
	desc = "Converts nearby eligible targets into thralls. To be eligible, they must be alive and recently drained by Devour Will."
	button_icon_state = "umbrage_veil_mind"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	psi_cost = 30
	lucidity_cost = 1 //Yep, thralling is optional! It's just one of many possible playstyles.
	blacklisted = 0

/datum/action/innate/umbrage/veil_mind/Activate()
	var/mob/living/carbon/human/H = owner
	if(!H.can_speak_vocal())
		H << "<span class='warning'>You can't speak!</span>"
		return
	owner.visible_message("<span class='warning'>[owner]'s sigils flare as they inhale...</span>", "<span class='velvet bold'>dawn kqn okjc...</span><br>\
	<span class='notice'>You take a deep breath...</span>")
	playsound(owner, 'sound/magic/veil_mind_gasp.ogg', 25, 1)
	if(!do_after(owner, 10, target = owner))
		return
	owner.visible_message("<span class='boldwarning'>[owner] lets out a chilling cry!</span>", "<span class='velvet bold'>...wjz oanra</span><br>\
	<span class='notice'>You veil the minds of everyone nearby.</span>")
	playsound(owner, 'sound/magic/veil_mind_scream.ogg', 100, 1)
	for(var/mob/living/L in view(3, owner))
		if(L == owner)
			continue
		if(issilicon(L))
			L << "<span class='ownerdanger'>$@!) ERR: RECEPTOR OVERLOAD ^!</</span>"
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
					if(ticker.mode.antag_veil(L))
						owner << "<span class='velvet'><b>[L.real_name]</b> has become a veil!</span>"
				else
					L << "<span class='boldwarning'>...and it scrambles your thoughts!</span>"
					L.dir = pick(cardinal)
					L.confused += 2
	return TRUE


//Demented Outburst: Deafens and confuses listeners. Even if they can't hear it, they will be thrown away and staggered by its force.
/datum/action/innate/umbrage/demented_outburst
	name = "Demented Outburst"
	id = "demented_outburst"
	desc = "Deafens and confuses listeners, and knocks away everyone nearby. Very loud."
	button_icon_state = "umbrage_demented_outburst"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 60 //big boom = big cost
	lucidity_cost = 2
	blacklisted = 0

/datum/action/innate/umbrage/demented_outburst/Activate()
	owner.visible_message("<span class='warning'>[owner] begins to growl!</span>", "<span class='velvet bold'>cap...</span><br>\
	<span class='danger'>You begin harnessing every ounce of your power...</span>")
	playsound(owner, 'sound/magic/demented_outburst_charge.ogg', 100, 0)
	addtimer(CALLBACK(src, .proc/outburst, owner), 50)
	return TRUE

/datum/action/innate/umbrage/demented_outburst/proc/outburst(mob/living/owner)
	if(!owner || owner.stat)
		return
	owner.visible_message("<span class='boldwarning'>[owner] lets out a deafening scream!</span>", "<span class='velvet bold italics'>WSWU!</span><br>\
	<span class='danger'>You let out a deafening outburst!</span>")
	playsound(owner, 'sound/magic/demented_outburst_scream.ogg', 150, 0)
	var/list/thrown_atoms = list()
	for(var/turf/T in view(5, owner))
		for(var/atom/movable/AM in T)
			thrown_atoms += AM
	for(var/atom/movable/AM in thrown_atoms)
		if(AM == owner || AM.anchored)
			continue
		var/distance = get_dist(owner, AM)
		var/turf/target = get_edge_target_turf(owner, get_dir(owner, get_step_away(AM, owner)))
		AM.throw_at(target, ((Clamp((5 - (Clamp(distance - 2, 0, distance))), 3, 5))), 1, owner)
		if(iscarbon(AM))
			var/mob/living/carbon/L = AM
			if(distance <= 1) //you done fucked up now
				L.visible_message("<span class='warning'>The blast sends [L] flying!</span>", "<span class='ownerdanger'>The force sends you flying!</span>")
				L.Weaken(5)
				L.adjustBruteLoss(10)
				L.soundbang_act(1, 5, 15, 5)
			else if(distance <= 3)
				L.visible_message("<span class='warning'>The blast knocks [L] off their feet!</span>", "<span class='ownerdanger'>The force bowls you over!</span>")
				L.Weaken(3)
				L.soundbang_act(1, 3, 5, 0)
	return TRUE


//Simulacrum: Creates an illusionary copy of the umbrage that moves continually in the direction that they're facing.
// - The illusion lasts for ten seconds and cannot be attacked.
// - If someone examines the illusion, they will be able to tell that it's false.
/datum/action/innate/umbrage/simulacrum
	name = "Simulacrum"
	id = "simulacrum"
	desc = "Creates an illusion that closely resembles you. The illusion will run forward for ten seconds."
	button_icon_state = "umbrage_simulacrum"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	psi_cost = 30
	lucidity_cost = 1
	blacklisted = 0

/datum/action/innate/umbrage/simulacrum/Activate()
	owner.visible_message("<span class='warning'>[owner] suddenly splits into two!</span>", "<span class='velvet bold'>zayaera</span><br>\
	<span class='notice'>You create an illusion of yourself.</span>")
	playsound(owner, 'sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/effect/simulacrum/simulacrum = new(get_turf(owner))
	simulacrum.mimic(owner)
	return TRUE


//Tagalong: Melds with a conscious mob's shadow, allowing the umbrage to freely accompany them anywhere they go.
// - Only usable in targets not in full darkness.
// - If the target enters a fully dark area, the umbrage will be stunned and ejected.
/datum/action/innate/umbrage/tagalong
	name = "Tagalong"
	id = "tagalong"
	desc = "Melds with a target's shadow, allowing you to accompany them into lit areas. Only works on targets not in darkness."
	button_icon_state = "umbrage_tagalong"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 50
	lucidity_cost = 2
	blacklisted = 0
	var/mob/living/tagging_along

/datum/action/innate/umbrage/tagalong/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/action/innate/umbrage/tagalong/process()
	if(!tagging_along)
		return STOP_PROCESSING(SSprocessing, src)
	var/turf/T = get_turf(tagging_along)
	if(T.get_lumcount() < 2)
		owner.forceMove(get_turf(tagging_along))
		owner.visible_message("<span class='warning'>[owner] suddenly manifests from the dark!</span>", "<span class='warning'>You are forcibly ejected from [tagging_along]'s shadow!</span>")
		owner.Weaken(2)
		STOP_PROCESSING(SSprocessing, src)
		tagging_along = null
		return TRUE

/datum/action/innate/umbrage/tagalong/Activate()
	if(tagging_along)
		owner.visible_message("<span class='warning'>[tagging_along]'s shadow suddenly breaks away from their body!</span>", "<span class='notice'>You break away from [tagging_along].</span>")
		owner.forceMove(get_turf(tagging_along))
		tagging_along = null
		STOP_PROCESSING(SSprocessing, src)
		spawn(1)
			psi_cost = initial(psi_cost)
		return TRUE
	else
		var/list/targets = list()
		var/mob/living/target
		for(var/mob/living/L in view(7, owner))
			var/turf/T = get_turf(L)
			if(L == owner || T.get_lumcount() <= 2)
				continue
			targets += L
		if(!targets.len)
			owner << "<span class='warning'>There are no nearby targets in lit areas!</span>"
			return
		if(targets.len == 1)
			target = targets[1] //To prevent the prompt from appearing with just one person
		else
			target = input(owner, "Select a target to tag along with.", name) as null|anything in targets
			if(!target)
				return
		owner << "<span class='velvet bold'>iahz</span><br><span class='notice'>You meld with [target]'s shadow.</span>"
		owner.forceMove(target)
		tagging_along = target
		START_PROCESSING(SSprocessing, src)
		spawn(1)
			psi_cost = 0 //For ejecting
		return TRUE
