/*
Tiers and Requirements

Pieces of scripture require certain follower counts, contruction value, and active caches in order to recite.
Drivers: Unlocked by default
Scripts: 5 servants
Applications: 8 servants and 100 CV
Revenant: 10 servants and 200 CV
Judgement: 12 servants, 300 CV, and any existing AIs are converted or destroyed
*/

/datum/clockwork_scripture
	var/descname = "useless" //a simple name for the scripture's effect
	var/name = "scripture"
	var/desc = "Ancient Ratvarian lore. This piece seems particularly mundane."
	var/list/invocations = list() //Spoken over time in the ancient language of Ratvar. See clock_unsorted.dm for more details on the language and how to make it.
	var/channel_time = 10 //In deciseconds, how long a ritual takes to chant
	var/potential_cost = 0 //The amount of potential this scripture needs to recite
	var/wisdom_cost = 0 //The amount of wisdom this scripture needs to recite
	var/obj/item/clockwork/slab/slab //The parent clockwork slab
	var/mob/living/invoker //The slab's holder
	var/whispered = FALSE //If the invocation is whispered rather than spoken aloud
	var/usage_tip = "This piece seems to serve no purpose and is a waste of components." //A generalized tip that gives advice on a certain scripture
	var/invokers_required = 1 //How many people are required, assuming that a scripture requires multiple
	var/multiple_invokers_used = FALSE //If scripture requires more than one invoker
	var/multiple_invokers_optional = FALSE //If scripture can have multiple invokers to bolster its effects
	var/tier = SCRIPTURE_PERIPHERAL //The scripture's tier
	var/quickbind = FALSE //if this scripture can be quickbound to a clockwork slab
	var/quickbind_desc = "This shouldn't be quickbindable. File a bug report!"
	var/primary_component
	var/sort_priority = 1 //what position the scripture should have in a list of scripture. Should be based off of component costs/reqs, but you can't initial() lists.

//messages for offstation scripture recital, courtesy ratvar's generals(and neovgre)
	var/static/list/neovgre_penalty = list("Go to the station.", "Useless.", "Don't waste time.", "Pathetic.", "Wasteful.")
	var/static/list/inathneq_penalty = list("Child, this is too far out!", "The barrier isn't thin enough for for me to help!", "Please, go to the station so I can assist you.", \
	"Don't waste my Cogs on this...", "There isn't enough time to linger out here!")
	var/static/list/sevtug_penalty = list("Fool! Get to the station and don't waste capacitors.", "You go this far out and expect help?", "The veil is too strong, idiot.", \
	"How does the Justicar get anything done with servants like you?", "Oh, you love wasting time, don't you?")
	var/static/list/nezbere_penalty = list("You disgrace our master's name with this endeavour.", "This is too far from the station to be a good base.", "This will take too long, friend.", \
	"The barrier isn't weakened enough to make this practical.", "Don't waste alloy.")
	var/static/list/nzcrentr_penalty = list("You'd be easy to hunt in that little hunk of metal.", "Boss says you need to get back to the beacon.", "Boss says I can kill you if you do this again.", \
	"Sending you power is too difficult here.", "Boss says stop wasting time.")

/datum/clockwork_scripture/New()
	creation_update()

/datum/clockwork_scripture/proc/creation_update() //updates any on-creation effects
	return FALSE //return TRUE if updated

/datum/clockwork_scripture/proc/run_scripture()
	var/successful = FALSE
	if(can_recite() && has_requirements())
		if(slab.busy)
			to_chat(invoker, "<span class='warning'>[slab] refuses to work, displaying the message: \"[slab.busy]!\"</span>")
			return FALSE
		slab.busy = "Invocation ([name]) in progress"
		if(GLOB.ratvar_awakens)
			channel_time *= 0.5 //if ratvar has awoken, half channel time and no cost
		else if(!slab.no_cost)
			adjust_clockwork_potential(-potential_cost)
			adjust_clockwork_wisdom(-wisdom_cost)
			update_slab_info()
		channel_time *= slab.speed_multiplier
		if(!recital() || !check_special_requirements() || !scripture_effects()) //if we fail any of these, refund potential used
			adjust_clockwork_potential(potential_cost)
			adjust_clockwork_wisdom(wisdom_cost)
			update_slab_info()
		else
			successful = TRUE
			if(slab && !slab.no_cost && !GLOB.ratvar_awakens) //if the slab exists and isn't debug and ratvar isn't up, log the scripture as being used
				SSblackbox.add_details("clockcult_scripture_recited", name)
	if(slab)
		slab.busy = null
	qdel(src)
	return successful

/datum/clockwork_scripture/proc/can_recite() //If the words can be spoken
	if(!invoker || !slab || invoker.get_active_held_item() != slab)
		return FALSE
	if(!invoker.can_speak_vocal())
		to_chat(invoker, "<span class='warning'>You are unable to speak the words of the scripture!</span>")
		return FALSE
	return TRUE

/datum/clockwork_scripture/proc/has_requirements() //if we have the components and invokers to do it
	var/checked_penalty = FALSE
	if(!GLOB.ratvar_awakens && !slab.no_cost)
		if(potential_cost && !has_clockwork_potential(potential_cost))
			to_chat(invoker, "<span class='warning'>There isn't enough potential to recite this scripture! ([GLOB.clockwork_potential]/[potential_cost])")
			return
		if(wisdom_cost && !has_clockwork_wisdom(wisdom_cost))
			to_chat(invoker, "<span class='warning'>There isn't enough wisdom to recite this scripture! Wait for it to regenerate! ([GLOB.clockwork_wisdom]/[wisdom_cost])")
	if(multiple_invokers_used && !multiple_invokers_optional && !GLOB.ratvar_awakens && !slab.no_cost)
		var/nearby_servants = 0
		for(var/mob/living/L in range(1, get_turf(invoker)))
			if(can_recite_scripture(L))
				nearby_servants++
		if(nearby_servants < invokers_required)
			to_chat(invoker, "<span class='warning'>There aren't enough non-mute servants nearby ([nearby_servants]/[invokers_required])!</span>")
			return FALSE
	if(!check_special_requirements())
		return FALSE
	if(checked_penalty && !slab.busy)
		var/message
		var/ratvarian_prob = 0
		switch(primary_component)
			if(BELLIGERENT_EYE)
				message = pick(neovgre_penalty)
				ratvarian_prob = 55
			if(VANGUARD_COGWHEEL)
				message = pick(inathneq_penalty)
				ratvarian_prob = 25
			if(GEIS_CAPACITOR)
				message = pick(sevtug_penalty)
				ratvarian_prob = 40
			if(REPLICANT_ALLOY)
				message = pick(nezbere_penalty)
				ratvarian_prob = 10
			if(HIEROPHANT_ANSIBLE)
				message = pick(nzcrentr_penalty)
				ratvarian_prob = 70
		if(message)
			if(prob(ratvarian_prob))
				message = text2ratvar(message)
			to_chat(invoker, "<span class='[get_component_span(primary_component)]_large'>\"[message]\"</span>")
			invoker << 'sound/magic/clockwork/invoke_general.ogg'
	return TRUE

/datum/clockwork_scripture/proc/check_special_requirements() //Special requirements for scriptures, checked multiple times during invocation
	return TRUE

/datum/clockwork_scripture/proc/recital() //The process of speaking the words
	if(!channel_time && invocations.len)
		if(multiple_invokers_used)
			for(var/mob/living/L in range(1, invoker))
				if(can_recite_scripture(L))
					for(var/invocation in invocations)
						clockwork_say(L, text2ratvar(invocation), whispered)
		else
			for(var/invocation in invocations)
				clockwork_say(invoker, text2ratvar(invocation), whispered)
	to_chat(invoker, "<span class='brass'>You [channel_time <= 0 ? "recite" : "begin reciting"] a piece of scripture entitled \"[name]\".</span>")
	if(!channel_time)
		return TRUE
	for(var/invocation in invocations)
		if(!do_after(invoker, channel_time / invocations.len, target = invoker, extra_checks = CALLBACK(src, .proc/check_special_requirements)))
			slab.busy = null
			return FALSE
		if(multiple_invokers_used)
			for(var/mob/living/L in range(1, get_turf(invoker)))
				if(can_recite_scripture(L))
					clockwork_say(L, text2ratvar(invocation), whispered)
		else
			clockwork_say(invoker, text2ratvar(invocation), whispered)
	return TRUE

/datum/clockwork_scripture/proc/scripture_effects() //The actual effects of the recital after its conclusion


//Channeled scripture begins instantly but runs constantly
/datum/clockwork_scripture/channeled
	var/list/chant_invocations = list("AYY LMAO")
	var/chant_amount = 5 //Times the chant is spoken
	var/chant_interval = 10 //Amount of deciseconds between times the chant is actually spoken aloud

/datum/clockwork_scripture/channeled/scripture_effects()
	for(var/i in 1 to chant_amount)
		if(!do_after(invoker, chant_interval, target = invoker, extra_checks = CALLBACK(src, .proc/can_recite)))
			break
		clockwork_say(invoker, text2ratvar(pick(chant_invocations)), whispered)
		if(!chant_effects(i))
			break
	if(invoker && slab)
		chant_end_effects()
	return TRUE

/datum/clockwork_scripture/channeled/proc/chant_effects(chant_number) //The chant's periodic effects

/datum/clockwork_scripture/channeled/proc/chant_end_effects() //The chant's effect upon ending
	to_chat(invoker, "<span class='brass'>You cease your chant.</span>")


//Creates an object at the invoker's feet
/datum/clockwork_scripture/create_object
	var/object_path = /obj/item/clockwork //The path of the object created
	var/creator_message = "<span class='brass'>You create a meme.</span>" //Shown to the invoker
	var/observer_message
	var/one_per_tile = FALSE
	var/prevent_path
	var/space_allowed = FALSE

/datum/clockwork_scripture/create_object/New()
	..()
	if(!prevent_path)
		prevent_path = object_path

/datum/clockwork_scripture/create_object/check_special_requirements()
	var/turf/T = get_turf(invoker)
	if(!space_allowed && isspaceturf(T))
		to_chat(invoker, "<span class='warning'>You need solid ground to place this object!</span>")
		return FALSE
	if(one_per_tile && (locate(prevent_path) in T))
		to_chat(invoker, "<span class='warning'>You can only place one of this object on each tile!</span>")
		return FALSE
	return TRUE

/datum/clockwork_scripture/create_object/scripture_effects()
	if(creator_message && observer_message)
		invoker.visible_message(observer_message, creator_message)
	else if(creator_message)
		to_chat(invoker, creator_message)
	var/obj/O = new object_path (get_turf(invoker))
	O.ratvar_act() //update the new object so it gets buffed if ratvar is alive
	if(istype(O, /obj/item))
		invoker.put_in_hands(O)
	return TRUE

//Uses a ranged slab ability, returning only when the ability no longer exists(ie, when interrupted) or finishes.
/datum/clockwork_scripture/ranged_ability
	var/slab_icon = "dread_ipad"
	var/ranged_type = /obj/effect/proc_holder/slab
	var/ranged_message = "This is a huge goddamn bug, how'd you cast this?"
	var/timeout_time = 0
	var/allow_mobility = TRUE //if moving and swapping hands is allowed during the while
	var/datum/progressbar/progbar

/datum/clockwork_scripture/ranged_ability/Destroy()
	qdel(progbar)
	return ..()

/datum/clockwork_scripture/ranged_ability/scripture_effects()
	slab.icon_state = slab_icon
	slab.slab_ability = new ranged_type(slab)
	slab.slab_ability.slab = slab
	slab.slab_ability.add_ranged_ability(invoker, ranged_message)
	invoker.update_inv_hands()
	var/end_time = world.time + timeout_time
	var/successful = FALSE
	if(timeout_time)
		progbar = new(invoker, timeout_time, slab)
	var/turf/T = get_turf(invoker)
	while(slab && slab.slab_ability && !slab.slab_ability.finished && (slab.slab_ability.in_progress || !timeout_time || world.time <= end_time) && \
		(allow_mobility || (can_recite() && T == get_turf(invoker))))
		if(progbar)
			if(slab.slab_ability.in_progress)
				qdel(progbar)
			else
				progbar.update(end_time - world.time)
		sleep(1)
	if(slab)
		if(slab.slab_ability)
			successful = slab.slab_ability.successful
			if(!slab.slab_ability.finished)
				slab.slab_ability.remove_ranged_ability()
		slab.icon_state = "dread_ipad"
		if(invoker)
			invoker.update_inv_hands()
	return successful //slab doesn't look like a word now.
