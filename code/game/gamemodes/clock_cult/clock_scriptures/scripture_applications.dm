//////////////////
// APPLICATIONS //
//////////////////

//Sigil of Accession: Creates a sigil of accession, which is like a sigil of submission, but can convert any number of non-implanted targets and up to one implanted target.
/datum/clockwork_scripture/create_object/sigil_of_accession
	descname = "Trap, Permanent Conversion"
	name = "Sigil of Accession"
	desc = "Places a luminous sigil much like a Sigil of Submission, but it will remain even after successfully converting a non-implanted target. \
	It will penetrate mindshield implants once before disappearing."
	invocations = list("Divinity, enslave...", "...all who trespass here!")
	channel_time = 70
	consumed_components = list(BELLIGERENT_EYE = 4, GEIS_CAPACITOR = 2, HIEROPHANT_ANSIBLE = 2)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/submission/accession
	prevent_path = /obj/effect/clockwork/sigil/submission
	creator_message = "<span class='brass'>A luminous sigil appears below you. All non-servants to cross it will be enslaved after a brief time if they do not move.</span>"
	usage_tip = "It will remain after converting a target, unless that target has a mindshield implant, which it will break to convert them, but consume itself in the process."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = BELLIGERENT_EYE
	sort_priority = 1
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Accession, which can convert a mindshielded non-Servant that remains on it."


//Fellowship Armory: Arms the invoker and nearby servants with Ratvarian armor.
/datum/clockwork_scripture/fellowship_armory
	descname = "Area Servant Armor"
	name = "Fellowship Armory"
	desc = "Equips the invoker and all visible Servants with Ratvarian armor. This armor provides high melee resistance but a weakness to lasers. \
	It grows faster to invoke with more adjacent Servants."
	invocations = list("Shield us...", "...with the...", "... fragments of Engine!")
	channel_time = 100
	consumed_components = list(VANGUARD_COGWHEEL = 4, REPLICANT_ALLOY = 2, HIEROPHANT_ANSIBLE = 2)
	usage_tip = "This scripture will replace all weaker armor worn by affected Servants."
	tier = SCRIPTURE_APPLICATION
	multiple_invokers_used = TRUE
	multiple_invokers_optional = TRUE
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Attempts to armor all nearby Servants with powerful Ratvarian armor."
	var/static/list/ratvarian_armor_typecache = typecacheof(list(
	/obj/item/clothing/suit/armor/clockwork,
	/obj/item/clothing/head/helmet/clockwork,
	/obj/item/clothing/gloves/clockwork,
	/obj/item/clothing/shoes/clockwork)) //don't replace this ever
	var/static/list/better_armor_typecache = typecacheof(list(
	/obj/item/clothing/suit/space,
	/obj/item/clothing/head/helmet/space,
	/obj/item/clothing/shoes/magboots)) //replace this only if ratvar is up

/datum/clockwork_scripture/fellowship_armory/run_scripture()
	for(var/mob/living/L in orange(1, invoker))
		if(can_recite_scripture(L))
			channel_time = max(channel_time - 10, 0)
	return ..()

/datum/clockwork_scripture/fellowship_armory/scripture_effects()
	var/affected = 0
	for(var/mob/living/L in view(7, get_turf(invoker)))
		if(L.stat == DEAD || !is_servant_of_ratvar(L))
			continue
		var/do_message = 0
		var/obj/item/I = L.get_item_by_slot(slot_wear_suit)
		if(remove_item_if_better(I, L))
			do_message += L.equip_to_slot_or_del(new/obj/item/clothing/suit/armor/clockwork(null), slot_wear_suit)
		I = L.get_item_by_slot(slot_head)
		if(remove_item_if_better(I, L))
			do_message += L.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/clockwork(null), slot_head)
		I = L.get_item_by_slot(slot_gloves)
		if(remove_item_if_better(I, L))
			do_message += L.equip_to_slot_or_del(new/obj/item/clothing/gloves/clockwork(null), slot_gloves)
		I = L.get_item_by_slot(slot_shoes)
		if(remove_item_if_better(I, L))
			do_message += L.equip_to_slot_or_del(new/obj/item/clothing/shoes/clockwork(null), slot_shoes)
		if(do_message)
			L.visible_message("<span class='warning'>Strange armor appears on [L]!</span>", "<span class='heavy_brass'>A bright shimmer runs down your body, equipping you with Ratvarian armor.</span>")
			playsound(L, 'sound/magic/clockwork/fellowship_armory.ogg', 15*do_message, 1) //get sound loudness based on how much we equipped
			affected++
	return affected

/datum/clockwork_scripture/fellowship_armory/proc/remove_item_if_better(obj/item/I, mob/user)
	if(!I)
		return TRUE
	if(is_type_in_typecache(I, ratvarian_armor_typecache))
		return FALSE
	if(!GLOB.ratvar_awakens && is_type_in_typecache(I, better_armor_typecache))
		return FALSE
	return user.dropItemToGround(I)

//Memory Allocation: Finds a willing ghost and makes them into a clockwork marauders for the invoker.
/datum/clockwork_scripture/memory_allocation
	descname = "Guardian"
	name = "Memory Allocation"
	desc = "Allocates part of your consciousness to a Clockwork Marauder, a vigilant fighter that lives within you, able to be \
	called forth by Speaking its True Name or if you become exceptionally low on health.<br>\
	If it remains close to you, you will gradually regain health up to a low amount, but it will die if it goes too far from you."
	invocations = list("Fright's will...", "...call forth...")
	channel_time = 100
	consumed_components = list(BELLIGERENT_EYE = 2, VANGUARD_COGWHEEL = 2, GEIS_CAPACITOR = 4)
	usage_tip = "Marauders are useful as personal bodyguards and frontline warriors."
	tier = SCRIPTURE_APPLICATION
	primary_component = GEIS_CAPACITOR
	sort_priority = 3

/datum/clockwork_scripture/memory_allocation/check_special_requirements()
	for(var/mob/living/simple_animal/hostile/clockwork/marauder/M in GLOB.all_clockwork_mobs)
		if(M.host == invoker)
			to_chat(invoker, "<span class='warning'>You can only house one marauder at a time!</span>")
			return FALSE
	return TRUE

/datum/clockwork_scripture/memory_allocation/scripture_effects()
	return create_marauder()

/datum/clockwork_scripture/memory_allocation/proc/create_marauder()
	invoker.visible_message("<span class='warning'>A purple tendril appears from [invoker]'s [slab.name] and impales itself in [invoker.p_their()] forehead!</span>", \
	"<span class='sevtug'>A tendril flies from [slab] into your forehead. You begin waiting while it painfully rearranges your thought pattern...</span>")
	invoker.notransform = TRUE //Vulnerable during the process
	slab.busy = "Thought Modification in progress"
	if(!do_after(invoker, 50, target = invoker))
		invoker.visible_message("<span class='warning'>The tendril, covered in blood, retracts from [invoker]'s head and back into the [slab.name]!</span>", \
		"<span class='userdanger'>Total agony overcomes you as the tendril is forced out early!</span>")
		invoker.notransform = FALSE
		invoker.Knockdown(100)
		invoker.apply_damage(10, BRUTE, "head")
		slab.busy = null
		return FALSE
	clockwork_say(invoker, text2ratvar("...the mind made..."))
	invoker.notransform = FALSE
	slab.busy = "Marauder Selection in progress"
	if(!check_special_requirements())
		return FALSE
	to_chat(invoker, "<span class='warning'>The tendril shivers slightly as it selects a marauder...</span>")
	var/list/marauder_candidates = pollGhostCandidates("Do you want to play as the clockwork marauder of [invoker.real_name]?", ROLE_SERVANT_OF_RATVAR, null, FALSE, 50, POLL_IGNORE_CLOCKWORK_MARAUDER)
	if(!check_special_requirements())
		return FALSE
	if(!marauder_candidates.len)
		invoker.visible_message("<span class='warning'>The tendril retracts from [invoker]'s head, sealing the entry wound as it does so!</span>", \
		"<span class='warning'>The tendril was unsuccessful! Perhaps you should try again another time.</span>")
		return FALSE
	clockwork_say(invoker, text2ratvar("...sword and shield!"))
	var/mob/dead/observer/theghost = pick(marauder_candidates)
	var/mob/living/simple_animal/hostile/clockwork/marauder/M = new(invoker)
	M.key = theghost.key
	M.bind_to_host(invoker)
	invoker.visible_message("<span class='warning'>The tendril retracts from [invoker]'s head, sealing the entry wound as it does so!</span>", \
	"<span class='sevtug'>[M.true_name], a clockwork marauder, has taken up residence in your mind. Communicate with it via the \"Linked Minds\" action button.</span>")
	return TRUE


//Sigil of Transmission: Creates a sigil of transmission that can store power for clockwork structures.
/datum/clockwork_scripture/create_object/sigil_of_transmission
	descname = "Structure Battery"
	name = "Sigil of Transmission"
	desc = "Places a sigil that stores energy to power clockwork structures."
	invocations = list("Divinity...", "...power our creations!")
	channel_time = 70
	consumed_components = list(VANGUARD_COGWHEEL = 2, GEIS_CAPACITOR = 2, HIEROPHANT_ANSIBLE = 4)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transmission
	creator_message = "<span class='brass'>A sigil silently appears below you. It will automatically power clockwork structures near it.</span>"
	usage_tip = "Cyborgs can charge from this sigil by remaining over it for 5 seconds."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 5
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Transmission, which stores power for clockwork structures."


//Interdiction Lens: Creates a powerful totem that disables radios and cameras and drains power into nearby sigils of transmission.
/datum/clockwork_scripture/create_object/interdiction_lens
	descname = "Structure, Area Sabotage, Power Generator"
	name = "Interdiction Lens"
	desc = "Creates a clockwork totem that sabotages nearby machinery and funnels drained power into nearby Sigils of Transmission or the area's APC."
	invocations = list("May this totem...", "...shroud the false suns!")
	channel_time = 80
	consumed_components = list(BELLIGERENT_EYE = 5, REPLICANT_ALLOY = 2, HIEROPHANT_ANSIBLE = 2)
	object_path = /obj/structure/destructible/clockwork/powered/interdiction_lens
	creator_message = "<span class='brass'>You form an interdiction lens, which disrupts cameras and radios and drains power.</span>"
	observer_message = "<span class='warning'>A brass totem rises from the ground, a purple gem appearing in its center!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "If it fails to funnel power into a nearby Sigil of Transmission or the area's APC and fails to disable even one thing, it will disable itself for two minutes."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = BELLIGERENT_EYE
	sort_priority = 6
	quickbind = TRUE
	quickbind_desc = "Creates an Interdiction Lens, which drains power into nearby Sigils of Transmission."


//Prolonging Prism: Creates a prism that will delay the shuttle at a power cost
/datum/clockwork_scripture/create_object/prolonging_prism
	descname = "Powered Structure, Delay Emergency Shuttles"
	name = "Prolonging Prism"
	desc = "Creates a mechanized prism which will delay the arrival of an emergency shuttle by 2 minutes at a massive power cost."
	invocations = list("May this prism...", "...grant us time to enact his will!")
	channel_time = 80
	consumed_components = list(VANGUARD_COGWHEEL = 5, GEIS_CAPACITOR = 2, REPLICANT_ALLOY = 2)
	object_path = /obj/structure/destructible/clockwork/powered/prolonging_prism
	creator_message = "<span class='brass'>You form a prolonging prism, which will delay the arrival of an emergency shuttle at a massive power cost.</span>"
	observer_message = "<span class='warning'>An onyx prism forms in midair and sprouts tendrils to support itself!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "The power cost to delay a shuttle increases based on CV and the number of times activated."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 7
	quickbind = TRUE
	quickbind_desc = "Creates a Prolonging Prism, which will delay the arrival of an emergency shuttle by 2 minutes at a massive power cost."

/datum/clockwork_scripture/create_object/prolonging_prism/check_special_requirements()
	if(SSshuttle.emergency.mode == SHUTTLE_DOCKED || SSshuttle.emergency.mode == SHUTTLE_IGNITING || SSshuttle.emergency.mode == SHUTTLE_STRANDED || SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
		to_chat(invoker, "<span class='inathneq'>\"It is too late to construct one of these, champion.\"</span>")
		return FALSE
	var/turf/T = get_turf(invoker)
	if(!T || T.z != ZLEVEL_STATION)
		to_chat(invoker, "<span class='inathneq'>\"You must be on the station to construct one of these, champion.\"</span>")
		return FALSE
	return ..()


//Mania Motor: Creates a malevolent transmitter that will broadcast the whispers of Sevtug into the minds of nearby nonservants, causing a variety of mental effects at a power cost.
/datum/clockwork_scripture/create_object/mania_motor
	descname = "Powered Structure, Area Denial"
	name = "Mania Motor"
	desc = "Creates a mania motor which causes minor damage and a variety of negative mental effects in nearby non-Servant humans, potentially up to and including conversion."
	invocations = list("May this transmitter...", "...break the will of all who oppose us!")
	channel_time = 80
	consumed_components = list(GEIS_CAPACITOR = 5, REPLICANT_ALLOY = 2, HIEROPHANT_ANSIBLE = 2)
	object_path = /obj/structure/destructible/clockwork/powered/mania_motor
	creator_message = "<span class='brass'>You form a mania motor, which causes minor damage and negative mental effects in non-Servants.</span>"
	observer_message = "<span class='warning'>A two-pronged machine rises from the ground!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "It will also cure hallucinations and brain damage in nearby Servants."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 8
	quickbind = TRUE
	quickbind_desc = "Creates a Mania Motor, which causes minor damage and negative mental effects in non-Servants."


//Tinkerer's Daemon: Creates an efficient machine that rapidly produces components at a power cost.
/datum/clockwork_scripture/create_object/tinkerers_daemon
	descname = "Powered Structure, Component Generator"
	name = "Tinkerer's Daemon"
	desc = "Creates a tinkerer's daemon which can rapidly collect components. It will only function if it has sufficient power, active daemons are outnumbered by Servants by a ratio of 5:1, \
	and there is at least one existing cache."
	invocations = list("May this generator...", "...collect Engine parts that yet hold greatness!")
	channel_time = 80
	consumed_components = list(BELLIGERENT_EYE = 2, GEIS_CAPACITOR = 2, REPLICANT_ALLOY = 5)
	object_path = /obj/structure/destructible/clockwork/powered/tinkerers_daemon
	creator_message = "<span class='brass'>You form a tinkerer's daemon which can rapidly collect components at a power cost.</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Vital to your success!"
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = REPLICANT_ALLOY
	sort_priority = 9
	quickbind = TRUE
	quickbind_desc = "Creates a Tinkerer's Daemon, which can rapidly collect components for power."


//Clockwork Obelisk: Creates a powerful obelisk that can be used to broadcast messages or open a gateway to any servant or clockwork obelisk at a power cost.
/datum/clockwork_scripture/create_object/clockwork_obelisk
	descname = "Powered Structure, Teleportation Hub"
	name = "Clockwork Obelisk"
	desc = "Creates a clockwork obelisk that can broadcast messages over the Hierophant Network or open a Spatial Gateway to any living Servant or clockwork obelisk."
	invocations = list("May this obelisk...", "...take us to all places!")
	channel_time = 80
	consumed_components = list(BELLIGERENT_EYE = 2, VANGUARD_COGWHEEL = 2, HIEROPHANT_ANSIBLE = 5)
	object_path = /obj/structure/destructible/clockwork/powered/clockwork_obelisk
	creator_message = "<span class='brass'>You form a clockwork obelisk which can broadcast messages or produce Spatial Gateways.</span>"
	observer_message = "<span class='warning'>A brass obelisk appears hanging in midair!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Producing a gateway has a high power cost. Gateways to or between clockwork obelisks receive double duration and uses."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 10
	quickbind = TRUE
	quickbind_desc = "Creates a Clockwork Obelisk, which can send messages or open Spatial Gateways with power."
