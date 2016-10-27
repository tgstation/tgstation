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
	required_components = list("belligerent_eye" = 1)
	usage_tip = "Useful for crowd control in a populated area and disrupting mass movement."
	tier = SCRIPTURE_DRIVER
	sort_priority = 1
	var/noncultist_damage = 2 //damage per chant to noncultists
	var/cultist_damage = 8 //damage per chant to non-walking cultists

/datum/clockwork_scripture/channeled/belligerent/chant_effects(chant_number)
	for(var/mob/living/carbon/C in hearers(7, invoker))
		var/number_legs = C.get_num_legs()
		if(!is_servant_of_ratvar(C) && !C.null_rod_check() && number_legs) //you have legs right
			C.apply_damage(noncultist_damage * 0.5, BURN, "l_leg")
			C.apply_damage(noncultist_damage * 0.5, BURN, "r_leg")
			if(C.m_intent != "walk")
				if(!iscultist(C))
					C << "<span class='warning'>Your leg[number_legs > 1 ? "s shiver":" shivers"] with pain!</span>"
				else //Cultists take extra burn damage
					C << "<span class='warning'>Your leg[number_legs > 1 ? "s burn":" burns"] with pain!</span>"
					C.apply_damage(cultist_damage * 0.5, BURN, "l_leg")
					C.apply_damage(cultist_damage * 0.5, BURN, "r_leg")
				C.m_intent = "walk"


//Judicial Visor: Creates a judicial visor, which can smite an area.
/datum/clockwork_scripture/create_object/judicial_visor
	descname = "Delayed Area Stun Glasses"
	name = "Judicial Visor"
	desc = "Forms a visor that, when worn, will grant the ability to smite an area, stunning, muting, and damaging the nonfaithful. \
	Cultists of Nar-Sie will be set on fire, though they will be stunned for half the time."
	invocations = list("Grant me the flames of Engine!")
	channel_time = 10
	required_components = list("belligerent_eye" = 2)
	consumed_components = list("belligerent_eye" = 1)
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/judicial_visor
	creator_message = "<span class='brass'>You form a judicial visor, which is capable of smiting the unworthy.</span>"
	usage_tip = "The visor has a thirty-second cooldown once used, and the marker it creates has a delay of 3 seconds before exploding."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	sort_priority = 2


//Vanguard: Provides twenty seconds of stun immunity. At the end of the twenty seconds, 25% of all stuns absorbed are applied to the invoker.
/datum/clockwork_scripture/vanguard
	descname = "Self Stun Immunity"
	name = "Vanguard"
	desc = "Provides twenty seconds of stun immunity. At the end of the twenty seconds, the invoker is stunned for the equivalent of 25% of all stuns they absorbed. \
	Excessive absorption will cause unconsciousness."
	invocations = list("Shield me...", "...from darkness!")
	channel_time = 30
	required_components = list("vanguard_cogwheel" = 1)
	usage_tip = "You cannot reactivate Vanguard while still shielded by it."
	tier = SCRIPTURE_DRIVER
	sort_priority = 3

/datum/clockwork_scripture/vanguard/check_special_requirements()
	if(islist(invoker.stun_absorption) && invoker.stun_absorption["vanguard"] && invoker.stun_absorption["vanguard"]["end_time"] > world.time)
		invoker << "<span class='warning'>You are already shielded by a Vanguard!</span>"
		return FALSE
	return TRUE

/datum/clockwork_scripture/vanguard/scripture_effects()
	invoker.apply_status_effect(STATUS_EFFECT_VANGUARD)
	return TRUE


//Sentinel's Compromise: Allows the invoker to select a nearby servant convert their brute and burn damage into half as much toxin damage.
/datum/clockwork_scripture/sentinels_compromise
	descname = "Convert Brute/Burn to Half Toxin"
	name = "Sentinel's Compromise"
	desc = "Heals all brute and burn damage on a nearby living, friendly servant, but deals 50% of the damage they had as toxin damage."
	invocations = list("Mend the wounds of...", "...my inferior flesh.")
	channel_time = 30
	required_components = list("vanguard_cogwheel" = 2)
	consumed_components = list("vanguard_cogwheel" = 1)
	usage_tip = "The Compromise is very fast to invoke."
	tier = SCRIPTURE_DRIVER
	sort_priority = 4

/datum/clockwork_scripture/sentinels_compromise/scripture_effects()
	var/list/nearby_cultists = list()
	for(var/mob/living/C in range(7, invoker))
		if(C.stat != DEAD && is_servant_of_ratvar(C) && (C.getBruteLoss() || C.getFireLoss()))
			nearby_cultists += C
	if(!nearby_cultists.len)
		invoker << "<span class='warning'>There are no eligible servants nearby!</span>"
		return FALSE
	var/mob/living/L = input(invoker, "Choose a fellow servant to heal.", name) as null|anything in nearby_cultists
	if(!L || !invoker || !slab || qdeleted(slab) || !invoker.canUseTopic(slab) || !invoker.get_active_held_item() != slab || L.stat == DEAD)
		return FALSE
	var/brutedamage = L.getBruteLoss()
	var/burndamage = L.getFireLoss()
	var/totaldamage = brutedamage + burndamage
	if(!totaldamage)
		invoker << "<span class='warning'>[L] is not burned or bruised!</span>"
		return FALSE
	L.adjustToxLoss(totaldamage * 0.5)
	L.adjustBruteLoss(-brutedamage)
	L.adjustFireLoss(-burndamage)
	var/healseverity = max(round(totaldamage*0.05, 1), 1) //shows the general severity of the damage you just healed, 1 glow per 20
	var/targetturf = get_turf(L)
	for(var/i in 1 to healseverity)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(targetturf, "#1E8CE1"))
	invoker << "<span class='brass'>You bathe [L] in Inath-neq's power!</span>"
	L.visible_message("<span class='warning'>A blue light washes over [L], mending [L.p_their()] bruises and burns!</span>", \
	"<span class='heavy_brass'>You feel Inath-neq's power healing your wounds, but a deep nausea overcomes you!</span>")
	playsound(targetturf, 'sound/magic/Staff_Healing.ogg', 50, 1)
	return TRUE


//Guvax: Converts anyone adjacent to the invoker after completion, but gets gradually slower as the cult gets more dominant.
/datum/clockwork_scripture/guvax
	descname = "Melee Area Convert"
	name = "Guvax"
	desc = "Enlists all nearby living unshielded creatures into servitude to Ratvar. Also purges holy water from nearby Servants."
	invocations = list("Enlighten this heathen!", "All are insects before Engine!", "Purge all untruths and honor Engine.")
	channel_time = 50
	required_components = list("guvax_capacitor" = 1)
	usage_tip = "Only works on those in melee range and does not penetrate mindshield implants. Much more efficient than a Sigil of Submission at low Servant amounts."
	tier = SCRIPTURE_DRIVER
	sort_priority = 5

/datum/clockwork_scripture/guvax/run_scripture()
	var/servants = 0
	for(var/mob/living/M in living_mob_list)
		if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
			servants++
	if(servants > 5)
		servants -= 5
		channel_time = min(channel_time + servants*10, 200) //if above 5 servants, is much slower
	return ..()

/datum/clockwork_scripture/guvax/scripture_effects()
	for(var/mob/living/L in hearers(1, get_turf(invoker))) //Affects silicons
		if(!is_servant_of_ratvar(L))
			if(L.stat != DEAD)
				add_servant_of_ratvar(L)
		else
			if(L.reagents && L.reagents.has_reagent("holywater"))
				L.reagents.remove_reagent("holywater", 1000)
				L << "<span class='heavy_brass'>Ratvar's light flares, banishing the darkness. Your devotion remains intact!</span>"
	return TRUE


//Taunting Tirade: Channeled for up to five times over thirty seconds. Confuses non-servants that can hear it and allows movement for a brief time after each chant.
/datum/clockwork_scripture/channeled/taunting_tirade
	descname = "Channeled, Mobile Area Confusion"
	name = "Taunting Tirade"
	desc = "Weakens, confuses and dizzies all nearby non-servants with a short invocation, then allows movement for five seconds. Chanted every second for up to thirty seconds."
	chant_invocations = list("Hostiles on my back!", "Enemies on my trail!", "Gonna try and shake my tail.", "Bogeys on my six!")
	chant_amount = 5
	chant_interval = 10
	required_components = list("guvax_capacitor" = 2)
	consumed_components = list("guvax_capacitor" = 1)
	usage_tip = "Useful for fleeing attackers, as few will be able to follow someone using this scripture."
	tier = SCRIPTURE_DRIVER
	sort_priority = 6
	var/flee_time = 47 //allow fleeing for 5 seconds
	var/grace_period = 3 //very short grace period so you don't have to stop immediately
	var/datum/progressbar/progbar

/datum/clockwork_scripture/channeled/taunting_tirade/chant_effects(chant_number)
	for(var/mob/living/L in hearers(7, invoker))
		if(!is_servant_of_ratvar(L) && !L.null_rod_check())
			L.confused = min(L.confused + 20, 100)
			L.dizziness = min(L.dizziness + 20, 100)
			L.Weaken(1)
	invoker.visible_message("<span class='warning'>[invoker] is suddenly covered with a thin layer of dark purple smoke!</span>")
	invoker.color = "#AF0AAF"
	animate(invoker, color = initial(invoker.color), time = flee_time+grace_period)
	if(chant_number != chant_amount) //if this is the last chant, we don't have a movement period because the chant is over
		var/endtime = world.time + flee_time
		var/starttime = world.time
		progbar = new(invoker, flee_time, invoker)
		progbar.bar.color = "#AF0AAF"
		animate(progbar.bar, color = initial(progbar.bar.color), time = flee_time+grace_period)
		while(world.time < endtime)
			sleep(1)
			progbar.update(world.time - starttime)
		qdel(progbar)
		sleep(grace_period)

/datum/clockwork_scripture/channeled/taunting_tirade/chant_end_effects()
	qdel(progbar)


//Replicant: Creates a new clockwork slab. Doesn't use create_object because of its unique behavior.
/datum/clockwork_scripture/replicant
	descname = "New Clockwork Slab"
	name = "Replicant"
	desc = "Creates a new clockwork slab."
	invocations = list("Metal, become greater!")
	channel_time = 10
	required_components = list("replicant_alloy" = 1)
	whispered = TRUE
	usage_tip = "This is inefficient as a way to produce components, as the slab produced must be held by someone with no other slabs to produce components."
	tier = SCRIPTURE_DRIVER
	sort_priority = 7

/datum/clockwork_scripture/replicant/scripture_effects()
	invoker <<  "<span class='brass'>You copy a piece of replicant alloy and command it into a new slab.</span>" //No visible message, for stealth purposes
	var/obj/item/clockwork/slab/S = new(get_turf(invoker))
	invoker.put_in_hands(S) //Put it in your hands if possible
	return TRUE


//Tinkerer's Cache: Creates a tinkerer's cache, allowing global component storage.
/datum/clockwork_scripture/create_object/tinkerers_cache
	descname = "Necessary, Shares Components"
	name = "Tinkerer's Cache"
	desc = "Forms a cache that can store an infinite amount of components. All caches are linked and will provide components to slabs."
	invocations = list("Constructing...", "...a cache!")
	channel_time = 50
	required_components = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 2, "hierophant_ansible" = 0)
	consumed_components = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 1, "hierophant_ansible" = 0)
	object_path = /obj/structure/destructible/clockwork/cache
	creator_message = "<span class='brass'>You form a tinkerer's cache, which is capable of storing components, which will automatically be used by slabs.</span>"
	observer_message = "<span class='warning'>A hollow brass spire rises and begins to blaze!</span>"
	usage_tip = "Slabs will draw components from the global cache after the slab's own repositories, making caches very efficient."
	tier = SCRIPTURE_DRIVER
	one_per_tile = TRUE
	sort_priority = 8

/datum/clockwork_scripture/create_object/tinkerers_cache/New()
	var/cache_cost_increase = min(round(clockwork_caches*0.2), 5)
	for(var/i in required_components)
		if(i != "replicant_alloy")
			required_components[i] += cache_cost_increase
	for(var/i in consumed_components)
		if(i != "replicant_alloy")
			consumed_components[i] += cache_cost_increase
	return ..()


//Wraith Spectacles: Creates a pair of wraith spectacles, which grant xray vision but damage vision slowly.
/datum/clockwork_scripture/create_object/wraith_spectacles
	descname = "Xray Vision Glasses"
	name = "Wraith Spectacles"
	desc = "Fabricates a pair of glasses that provides true sight but quickly damage vision, eventually causing blindness if worn for too long."
	invocations = list("Show the truth of this world to me!")
	channel_time = 10
	required_components = list("hierophant_ansible" = 1)
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/wraith_spectacles
	creator_message = "<span class='brass'>You form a pair of wraith spectacles, which will grant true sight when worn.</span>"
	usage_tip = "\"True sight\" means that you are able to see through walls and in darkness."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	sort_priority = 9


//Sigil of Transgression: Creates a sigil of transgression, which stuns the first nonservant to cross it.
/datum/clockwork_scripture/create_object/sigil_of_transgression
	descname = "Stun Trap"
	name = "Sigil of Transgression"
	desc = "Wards a tile with a sigil. The next person to cross the sigil will be smitten and unable to move. Nar-Sian cultists are stunned altogether."
	invocations = list("Divinity, dazzle...", "...those who tresspass here!")
	channel_time = 50
	required_components = list("hierophant_ansible" = 2)
	consumed_components = list("hierophant_ansible" = 1)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transgression
	creator_message = "<span class='brass'>A sigil silently appears below you. The next non-servant to cross it will be immobilized.</span>"
	usage_tip = "The sigil, while fairly powerful in its stun, does not induce muteness in its victim."
	tier = SCRIPTURE_DRIVER
	one_per_tile = TRUE
	sort_priority = 10
