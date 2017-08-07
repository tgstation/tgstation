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
		if(C.apply_status_effect(STATUS_EFFECT_BELLIGERENT))
			new /obj/effect/temp_visual/ratvar/belligerent(get_turf(C))
	new /obj/effect/temp_visual/ratvar/belligerent_cast(get_turf(invoker))
	return TRUE


//Judicial Visor: Creates a judicial visor, which can smite an area.
/datum/clockwork_scripture/create_object/judicial_visor
	descname = "Delayed Area Knockdown Glasses"
	name = "Judicial Visor"
	desc = "Creates a visor that can smite an area, applying Belligerent and briefly stunning. The smote area will explode after 3 seconds."
	invocations = list("Grant me the flames of Engine!")
	channel_time = 10
	consumed_components = list(BELLIGERENT_EYE = 1)
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/judicial_visor
	creator_message = "<span class='brass'>You form a judicial visor, which is capable of smiting a small area.</span>"
	usage_tip = "The visor has a thirty-second cooldown once used."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	primary_component = BELLIGERENT_EYE
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Creates a Judicial Visor, which can smite an area, applying Belligerent and briefly stunning."


//Vanguard: Provides twenty seconds of stun immunity. At the end of the twenty seconds, 25% of all stuns absorbed are applied to the invoker.
/datum/clockwork_scripture/vanguard
	descname = "Self Stun Immunity"
	name = "Vanguard"
	desc = "Provides twenty seconds of stun immunity. At the end of the twenty seconds, the invoker is knocked down for the equivalent of 25% of all stuns they absorbed. \
	Excessive absorption will cause unconsciousness."
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


//Sentinel's Compromise: Allows the invoker to select a nearby servant and convert their brute, burn, and oxygen damage into half as much toxin damage.
/datum/clockwork_scripture/ranged_ability/sentinels_compromise
	descname = "Convert Brute/Burn/Oxygen to Half Toxin"
	name = "Sentinel's Compromise"
	desc = "Charges your slab with healing power, allowing you to convert all of a target Servant's brute, burn, and oxygen damage to half as much toxin damage."
	invocations = list("Mend the wounds of...", "...my inferior flesh.")
	channel_time = 30
	consumed_components = list(VANGUARD_COGWHEEL = 1)
	usage_tip = "The Compromise is very fast to invoke, and will remove holy water from the target Servant."
	tier = SCRIPTURE_DRIVER
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 4
	quickbind = TRUE
	quickbind_desc = "Allows you to convert a Servant's brute, burn, and oxygen damage to half toxin damage.<br><b>Click your slab to disable.</b>"
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
	usage_tip = "You CANNOT TAKE ANY NON-PULL ACTIONS while the target is bound, so Sigils of Submission should be placed before use."
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

/datum/clockwork_scripture/ranged_ability/geis/run_scripture()
	var/servants = 0
	if(!GLOB.ratvar_awakens)
		for(var/mob/living/M in GLOB.living_mob_list)
			if(can_recite_scripture(M, TRUE))
				servants++
	if(servants > SCRIPT_SERVANT_REQ)
		whispered = FALSE
		servants -= SCRIPT_SERVANT_REQ
		channel_time = min(channel_time + servants*3, 50)
	return ..()


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


//Wraith Spectacles: Creates a pair of wraith spectacles, which grant xray vision but damage vision slowly.
/datum/clockwork_scripture/create_object/wraith_spectacles
	descname = "Limited Xray Vision Glasses"
	name = "Wraith Spectacles"
	desc = "Fabricates a pair of glasses which grant true sight but cause gradual vision loss."
	invocations = list("Show the truth of this world to me!")
	channel_time = 10
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/wraith_spectacles
	creator_message = "<span class='brass'>You form a pair of wraith spectacles, which grant true sight but cause gradual vision loss.</span>"
	usage_tip = "\"True sight\" means that you are able to see through walls and in darkness."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 9
	quickbind = TRUE
	quickbind_desc = "Creates a pair of Wraith Spectacles, which grant true sight but cause gradual vision loss."


//Sigil of Transgression: Creates a sigil of transgression, which stuns the first nonservant to cross it.
/datum/clockwork_scripture/create_object/sigil_of_transgression
	descname = "Trap, Stunning"
	name = "Sigil of Transgression"
	desc = "Wards a tile with a sigil, which will stun the next non-Servant to cross it."
	invocations = list("Divinity, smite...", "...those who tresspass here!")
	channel_time = 50
	consumed_components = list(HIEROPHANT_ANSIBLE = 1)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transgression
	creator_message = "<span class='brass'>A sigil silently appears below you. The next non-Servant to cross it will be stunned.</span>"
	usage_tip = "The sigil, while fairly powerful in its stun, does not induce muteness in its victim."
	tier = SCRIPTURE_DRIVER
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 10
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Transgression, which will stun the next non-Servant to cross it."
