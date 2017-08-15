/////////////
// DRIVERS //
/////////////

//Belligerent: Channeled for up to fifteen times over thirty seconds. Forces non-servants that can hear the chant to walk, doing minor damage. Nar-Sian cultists are burned.
/datum/clockwork_scripture/channeled/belligerent
	descname = "Channeled, Area Slowdown"
	name = "Belligerent"
	desc = "Forces all nearby non-servants to walk rather than run, doing minor damage. Chanted every two seconds for up to thirty seconds."
	chant_invocations = list("Punish their blindness!", "Take time, make slow!")
	chant_amount = 15
	chant_interval = 20
	channel_time = 20
	usage_tip = "Useful for crowd control in a populated area and disrupting mass movement."
	tier = SCRIPTURE_DRIVER
	primary_component = BELLIGERENT_EYE
	sort_priority = 1
	quickbind = TRUE
	quickbind_desc = "Forces nearby non-Servants to walk, doing minor damage with each chant.<br><b>Maximum 15 chants.</b>"

/datum/clockwork_scripture/channeled/belligerent/chant_effects(chant_number)
	for(var/mob/living/carbon/C in hearers(7, invoker))
		C.apply_status_effect(STATUS_EFFECT_BELLIGERENT)
	new /obj/effect/temp_visual/ratvar/belligerent(get_turf(invoker))
	return TRUE


//Sigil of Transgression: Creates a sigil of transgression, which will briefly stun and apply Belligerent to the next non-Servant to cross it.
/datum/clockwork_scripture/create_object/sigil_of_transgression
	descname = "Trap, Stunning"
	name = "Sigil of Transgression"
	desc = "Wards a tile with a sigil, which will briefly stun and apply Belligerent to the next non-Servant to cross it."
	invocations = list("Divinity, smite...", "...those who tresspass here!")
	channel_time = 50
	consumed_components = list(BELLIGERENT_EYE = 1)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transgression
	creator_message = "<span class='brass'>A sigil silently appears below you. The next non-Servant to cross it will be briefly stunned and affected by Belligerent.</span>"
	usage_tip = "Non-Servants already affected by Belligerent will not be stunned."
	tier = SCRIPTURE_DRIVER
	one_per_tile = TRUE
	primary_component = BELLIGERENT_EYE
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Transgression, which will briefly stun and apply Belligerent to the next non-Servant to cross it."


//Vanguard: Provides 25 seconds of stun immunity. At the end of the twenty seconds, 25% of all stuns absorbed are applied to the invoker.
/datum/clockwork_scripture/vanguard
	descname = "Self Stun Immunity"
	name = "Vanguard"
	desc = "Provides 25 seconds of stun immunity. At the end of the duration, the invoker is knocked down for the equivalent of 30% of all stuns they absorbed."
	invocations = list("Shield me...", "...from darkness!")
	channel_time = 30
	usage_tip = "You cannot reactivate Vanguard while still shielded by it."
	tier = SCRIPTURE_DRIVER
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 3
	quickbind = TRUE
	quickbind_desc = "Allows you to temporarily absorb stuns. All stuns absorbed will affect you when disabled."

/datum/clockwork_scripture/vanguard/check_special_requirements()
	if(!GLOB.ratvar_awakens && islist(invoker.stun_absorption) && invoker.stun_absorption["vanguard"] && invoker.stun_absorption["vanguard"]["end_time"] > world.time)
		to_chat(invoker, "<span class='warning'>You are already shielded by a Vanguard!</span>")
		return FALSE
	return TRUE

/datum/clockwork_scripture/vanguard/scripture_effects()
	if(GLOB.ratvar_awakens)
		for(var/mob/living/L in view(7, get_turf(invoker)))
			if(L.stat != DEAD && is_servant_of_ratvar(L))
				L.apply_status_effect(STATUS_EFFECT_VANGUARD)
			CHECK_TICK
	else
		invoker.apply_status_effect(STATUS_EFFECT_VANGUARD)
	return TRUE


//Sentinel's Compromise: Allows the invoker to select a nearby servant and heal their brute/burn/oxygen damage with Vitality
/datum/clockwork_scripture/ranged_ability/sentinels_compromise
	descname = "Heal Brute/Burn/Oxygen"
	name = "Sentinel's Compromise"
	desc = "Charges your slab with healing power, allowing you to heal a target Servant using Vitality. Healing done without Vitality is much less effective."
	invocations = list("Mend the wounds of...", "...my inferior flesh.")
	channel_time = 30
	consumed_components = list(VANGUARD_COGWHEEL = 1)
	usage_tip = "The Compromise is very fast to invoke, and will remove holy water from the target Servant."
	tier = SCRIPTURE_DRIVER
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 4
	quickbind = TRUE
	quickbind_desc = "Allows you to heal a Servant using Vitality.<br><b>Click your slab to disable.</b>"
	slab_overlay = "compromise"
	ranged_type = /obj/effect/proc_holder/slab/compromise
	ranged_message = "<span class='inathneq_small'><i>You charge the clockwork slab with healing power.</i>\n\
	<b>Left-click a fellow Servant or yourself to heal!\n\
	Click your slab to cancel.</b></span>"


//Geis: Grants a short-range binding attack that allows you to mute and drag around a target in a very obvious manner.
/datum/clockwork_scripture/ranged_ability/geis
	descname = "Melee Mute & Stun"
	name = "Geis"
	desc = "Charges your slab with divine energy, allowing you to bind and pull a struck heretic."
	invocations = list("Divinity, grant me strength...", "...to bind the heathen!")
	whispered = TRUE
	channel_time = 20
	usage_tip = "You CANNOT RECITE SCRIPTURE while the target is bound, so Sigils of Submission should be placed before use."
	tier = SCRIPTURE_DRIVER
	primary_component = GEIS_CAPACITOR
	sort_priority = 5
	quickbind = TRUE
	quickbind_desc = "Allows you to bind and mute an adjacent target non-Servant.<br><b>Click your slab to disable.</b>"
	slab_overlay = "geis"
	ranged_type = /obj/effect/proc_holder/slab/geis
	ranged_message = "<span class='sevtug_small'><i>You charge the clockwork slab with divine energy.</i>\n\
	<b>Left-click a target within melee range to bind!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 100

/datum/clockwork_scripture/ranged_ability/geis/scripture_effects()
	var/mob/living/silicon/robot/R
	if(iscyborg(invoker))
		R = invoker
		if(!R.eye_lights)
			R.update_icons()
		R.eye_lights.color = list("#AF0AAF", "#AF0AAF", "#AF0AAF", rgb(0,0,0)) //robot eye lights turn purple
		R.update_icons()
	. = ..()
	if(!QDELETED(R))
		R.eye_lights.color = null
		R.update_icons()


//Sigil of Submission: Creates a sigil of submission, which converts one heretic above it after a delay.
/datum/clockwork_scripture/create_object/sigil_of_submission
	descname = "Trap, Conversion"
	name = "Sigil of Submission"
	desc = "Places a luminous sigil that will convert any non-Servants that remain on it for 8 seconds."
	invocations = list("Divinity, enlighten...", "...those who trespass here!")
	channel_time = 60
	consumed_components = list(GEIS_CAPACITOR = 1)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/submission
	creator_message = "<span class='brass'>A luminous sigil appears below you. Any non-Servants to cross it will be converted after 8 seconds if they do not move.</span>"
	usage_tip = "This is the primary conversion method, though it will not penetrate mindshield implants."
	tier = SCRIPTURE_DRIVER
	one_per_tile = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 6
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Submission, which will convert non-Servants that remain on it."


//Replicant: Creates a new clockwork slab.
/datum/clockwork_scripture/create_object/replicant
	descname = "New Clockwork Slab"
	name = "Replicant"
	desc = "Creates a new clockwork slab."
	invocations = list("Metal, become greater!")
	channel_time = 10
	whispered = TRUE
	object_path = /obj/item/clockwork/slab
	creator_message = "<span class='brass'>You copy a piece of replicant alloy and command it into a new slab.</span>"
	usage_tip = "This is inefficient as a way to produce components, as the slab produced must be held by someone with no other slabs to produce components."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	primary_component = REPLICANT_ALLOY
	sort_priority = 7
	quickbind = TRUE
	quickbind_desc = "Creates a new Clockwork Slab."


//Tinkerer's Cache: Creates a tinkerer's cache, allowing global component storage.
/datum/clockwork_scripture/create_object/tinkerers_cache
	descname = "Necessary Structure, Shares Components"
	name = "Tinkerer's Cache"
	desc = "Forms a cache that can store an infinite amount of components. All caches are linked and will provide components to slabs. \
	Striking a cache with a slab will transfer that slab's components to the global cache."
	invocations = list("Constructing...", "...a cache!")
	channel_time = 50
	consumed_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 0)
	object_path = /obj/structure/destructible/clockwork/cache
	creator_message = "<span class='brass'>You form a tinkerer's cache, which is capable of storing components, which will automatically be used by slabs.</span>"
	observer_message = "<span class='warning'>A hollow brass spire rises and begins to blaze!</span>"
	usage_tip = "Slabs will draw components from the global cache after the slab's own repositories, making caches extremely useful."
	tier = SCRIPTURE_DRIVER
	one_per_tile = TRUE
	primary_component = REPLICANT_ALLOY
	sort_priority = 8
	quickbind = TRUE
	quickbind_desc = "Creates a Tinkerer's Cache, which stores components globally for slab access."
	var/static/prev_cost = 0

/datum/clockwork_scripture/create_object/tinkerers_cache/creation_update()
	var/cache_cost_increase = min(round(GLOB.clockwork_caches*0.4), 10)
	if(cache_cost_increase != prev_cost)
		prev_cost = cache_cost_increase
		consumed_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 0)
		for(var/i in consumed_components)
			if(i != REPLICANT_ALLOY)
				consumed_components[i] += cache_cost_increase
		return TRUE
	return FALSE


//Spatial Gateway: Allows the invoker to teleport themselves and any nearby allies to a conscious servant or clockwork obelisk.
/datum/clockwork_scripture/spatial_gateway
	descname = "Teleport Gate"
	name = "Spatial Gateway"
	desc = "Tears open a miniaturized gateway in spacetime to any conscious servant that can transport objects or creatures to its destination. \
	Each servant assisting in the invocation adds one additional use and four additional seconds to the gateway's uses and duration."
	invocations = list("Spatial Gateway...", "...activate!")
	channel_time = 80
	multiple_invokers_used = TRUE
	multiple_invokers_optional = TRUE
	usage_tip = "This gateway is strictly one-way and will only allow things through the invoker's portal."
	tier = SCRIPTURE_DRIVER
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 9
	quickbind = TRUE
	quickbind_desc = "Allows you to create a one-way Spatial Gateway to a living Servant or Clockwork Obelisk."

/datum/clockwork_scripture/spatial_gateway/check_special_requirements()
	if(!isturf(invoker.loc))
		to_chat(invoker, "<span class='warning'>You must not be inside an object to use this scripture!</span>")
		return FALSE
	var/turf/T = get_step(invoker, invoker.dir)
	if(is_blocked_turf(T, TRUE) || !invoker.Adjacent(T))
		to_chat(invoker, "<span class='warning'>The turf in front of you must be clear and accessable to use this scripture!</span>")
		return FALSE
	var/other_servants = 0
	for(var/mob/living/L in GLOB.living_mob_list)
		if(is_servant_of_ratvar(L) && !L.stat && L != invoker)
			other_servants++
	for(var/obj/structure/destructible/clockwork/powered/clockwork_obelisk/O in GLOB.all_clockwork_objects)
		if(O.anchored)
			other_servants++
	for(var/obj/structure/destructible/clockwork/massive/celestial_gateway/G in GLOB.all_clockwork_objects)
		if(G.obj_integrity)
			other_servants++
	if(!other_servants)
		to_chat(invoker, "<span class='warning'>There are no other conscious servants or anchored clockwork obelisks!</span>")
		return FALSE
	return TRUE

/datum/clockwork_scripture/spatial_gateway/scripture_effects()
	var/portal_uses = 0
	var/duration = 0
	for(var/mob/living/L in range(1, invoker))
		if(!L.stat && is_servant_of_ratvar(L))
			portal_uses++
			duration += 40 //4 seconds
	if(GLOB.ratvar_awakens)
		portal_uses = max(portal_uses, 100) //Very powerful if Ratvar has been summoned
		duration = max(duration, 100)
	return slab.procure_gateway(invoker, duration, portal_uses)


//Wraith Spectacles: Creates a pair of wraith spectacles, which grant xray vision.
/datum/clockwork_scripture/create_object/wraith_spectacles
	descname = "Limited Xray Vision Glasses"
	name = "Wraith Spectacles"
	desc = "Fabricates a pair of glasses which grant true sight."
	invocations = list("Show the truth of this world to me!")
	channel_time = 10
	consumed_components = list(HIEROPHANT_ANSIBLE = 1)
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/wraith_spectacles
	creator_message = "<span class='brass'>You form a pair of wraith spectacles, which grant true sight.</span>"
	usage_tip = "\"True sight\" means that you are able to see through walls and in darkness."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 10
	quickbind = TRUE
	quickbind_desc = "Creates a pair of Wraith Spectacles, which grant true sight."

