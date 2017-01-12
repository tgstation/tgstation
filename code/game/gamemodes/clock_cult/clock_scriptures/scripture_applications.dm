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
	required_components = list(BELLIGERENT_EYE = 3, GEIS_CAPACITOR = 1, HIEROPHANT_ANSIBLE = 1)
	consumed_components = list(BELLIGERENT_EYE = 2, GEIS_CAPACITOR = 1, HIEROPHANT_ANSIBLE = 1)
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


//Vitality Matrix: Creates a sigil which will drain health from nonservants and can use that health to heal or even revive servants.
/datum/clockwork_scripture/create_object/vitality_matrix
	descname = "Trap, Damage to Healing"
	name = "Vitality Matrix"
	desc = "Scribes a sigil beneath the invoker which drains life from any living non-Servants that cross it. Servants that cross it, however, will be healed based on how much it drained from non-Servants. \
	Dead Servants can be revived by this sigil if it has enough stored vitality."
	invocations = list("Divinity...", "...steal their life...", "...for these shells!")
	channel_time = 70
	required_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 3, HIEROPHANT_ANSIBLE = 1)
	consumed_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 2, HIEROPHANT_ANSIBLE = 1)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/vitality
	creator_message = "<span class='brass'>A vitality matrix appears below you. It will drain life from non-Servants and heal Servants that cross it.</span>"
	usage_tip = "To revive a Servant, the sigil must have 20 vitality plus the target Servant's non-oxygen damage. It will still heal dead Servants if it lacks the vitality to outright revive them."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Creates a Vitality Matrix, which drains non-Servants on it to heal Servants that cross it."


//Memory Allocation: Finds a willing ghost and makes them into a clockwork marauders for the invoker.
/datum/clockwork_scripture/memory_allocation
	descname = "Guardian"
	name = "Memory Allocation"
	desc = "Allocates part of your consciousness to a Clockwork Marauder, a vigilant fighter that lives within you, able to be \
	called forth by Speaking its True Name or if you become exceptionally low on health.<br>\
	If it remains close to you, you will gradually regain health up to a low amount, but it will die if it goes too far from you."
	invocations = list("Fright's will...", "...call forth...")
	channel_time = 100
	required_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 3)
	consumed_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 2)
	usage_tip = "Marauders are useful as personal bodyguards and frontline warriors."
	tier = SCRIPTURE_APPLICATION
	primary_component = GEIS_CAPACITOR
	sort_priority = 3

/datum/clockwork_scripture/memory_allocation/check_special_requirements()
	for(var/mob/living/simple_animal/hostile/clockwork/marauder/M in living_mob_list)
		if(M.host == invoker)
			invoker << "<span class='warning'>You can only house one marauder at a time!</span>"
			return FALSE
	return TRUE

/datum/clockwork_scripture/memory_allocation/scripture_effects()
	return create_marauder()

/datum/clockwork_scripture/memory_allocation/proc/create_marauder()
	invoker.visible_message("<span class='warning'>A purple tendril appears from [invoker]'s [slab.name] and impales itself in [invoker.p_their()] forehead!</span>", \
	"<span class='heavy_brass'>A tendril flies from [slab] into your forehead. You begin waiting while it painfully rearranges your thought pattern...</span>")
	invoker.notransform = TRUE //Vulnerable during the process
	slab.busy = "Thought Modification in progress"
	if(!do_after(invoker, 50, target = invoker))
		invoker.visible_message("<span class='warning'>The tendril, covered in blood, retracts from [invoker]'s head and back into the [slab.name]!</span>", \
		"<span class='heavy_brass'>Total agony overcomes you as the tendril is forced out early!</span>")
		invoker.notransform = FALSE
		invoker.Stun(5)
		invoker.Weaken(5)
		invoker.apply_damage(10, BRUTE, "head")
		slab.busy = null
		return FALSE
	clockwork_say(invoker, text2ratvar("...the mind made..."))
	invoker.notransform = FALSE
	slab.busy = "Marauder Selection in progress"
	if(!check_special_requirements())
		return FALSE
	invoker << "<span class='warning'>The tendril shivers slightly as it selects a marauder...</span>"
	var/list/marauder_candidates = pollCandidates("Do you want to play as the clockwork marauder of [invoker.real_name]?", ROLE_SERVANT_OF_RATVAR, null, FALSE, 100)
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
	M.host = invoker
	M << M.playstyle_string
	M << "<b>Your true name is \"[M.true_name]\". You can change this <i>once</i> by using the Change True Name verb in your Marauder tab.</b>"
	add_servant_of_ratvar(M, TRUE)
	invoker.visible_message("<span class='warning'>The tendril retracts from [invoker]'s head, sealing the entry wound as it does so!</span>", \
	"<span class='heavy_brass'>The procedure was successful! [M.true_name], a clockwork marauder, has taken up residence in your mind. Communicate with it via the \"Linked Minds\" ability in the \
	Clockwork tab.</span>")
	invoker.verbs += /mob/living/proc/talk_with_marauder
	return TRUE


//Anima Fragment: Creates an empty anima fragment, which produces an anima fragment that moves at extreme speed and does high damage.
/datum/clockwork_scripture/create_object/anima_fragment
	descname = "Fast Soul Vessel Shell"
	name = "Anima Fragment"
	desc = "Creates a large shell fitted for soul vessels. Adding an active soul vessel to it results in a powerful construct with decent health, notable melee power, \
	and exceptional speed, though taking damage will temporarily slow it down."
	invocations = list("Call forth...", "...the soldiers of Armorer.")
	channel_time = 80
	required_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 1, REPLICANT_ALLOY = 3)
	consumed_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 1, REPLICANT_ALLOY = 2)
	object_path = /obj/structure/destructible/clockwork/shell/fragment
	creator_message = "<span class='brass'>You form an anima fragment, a powerful soul vessel receptable.</span>"
	observer_message = "<span class='warning'>The slab disgorges a puddle of black metal that expands and forms into a strange shell!</span>"
	usage_tip = "Useless without a soul vessel and should not be created without one."
	tier = SCRIPTURE_APPLICATION
	primary_component = REPLICANT_ALLOY
	sort_priority = 4
	quickbind = TRUE
	quickbind_desc = "Creates a Fragment Shell, which produces an Anima Fragment when filled with a Soul Vessel."


//Sigil of Transmission: Creates a sigil of transmission that can store power for clockwork structures.
/datum/clockwork_scripture/create_object/sigil_of_transmission
	descname = "Structure Battery"
	name = "Sigil of Transmission"
	desc = "Scribes a sigil beneath the invoker which stores power to power clockwork structures."
	invocations = list("Divinity...", "...power our creations!")
	channel_time = 70
	required_components = list(VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 1, HIEROPHANT_ANSIBLE = 3)
	consumed_components = list(VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 1, HIEROPHANT_ANSIBLE = 2)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transmission
	creator_message = "<span class='brass'>A sigil silently appears below you. It will automatically power clockwork structures adjecent to it.</span>"
	usage_tip = "Can be recharged by using Volt Void while standing on it."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 5
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Transmission, which stores power for clockwork structures."


//Interdiction Lens: Creates a powerful totem that disables radios and cameras and drains power into nearby sigils of transmission.
/datum/clockwork_scripture/create_object/interdiction_lens
	descname = "Structure, Disables Machinery"
	name = "Interdiction Lens"
	desc = "Creates a clockwork totem that sabotages nearby machinery and funnels drained power into nearby Sigils of Transmission or the area's APC."
	invocations = list("May this totem...", "...shroud the false suns!")
	channel_time = 80
	required_components = list(BELLIGERENT_EYE = 4, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 1)
	consumed_components = list(BELLIGERENT_EYE = 3, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 1)
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


//Mending Motor: Creates a prism that will quickly heal mechanical servants/clockwork structures and consume power or replicant alloy.
/datum/clockwork_scripture/create_object/mending_motor
	descname = "Structure, Repairs Other Structures"
	name = "Mending Motor"
	desc = "Creates a mechanized prism that will rapidly repair damage to clockwork creatures, converted cyborgs, and clockwork structures. Requires power to function."
	invocations = list("May this prism...", "...mend our dents and scratches!")
	channel_time = 80
	required_components = list(VANGUARD_COGWHEEL = 4, GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 1)
	consumed_components = list(VANGUARD_COGWHEEL = 3, GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 1)
	object_path = /obj/structure/destructible/clockwork/powered/mending_motor
	creator_message = "<span class='brass'>You form a mending motor, which will consume power to mend constructs and structures.</span>"
	observer_message = "<span class='warning'>An onyx prism forms in midair and sprouts tendrils to support itself!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Powerful healing but power use is somewhat inefficient, though much better than a proselytizer."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 7
	quickbind = TRUE
	quickbind_desc = "Creates a Mending Motor, which rapidly repairs constructs and structures at a power cost."


//Mania Motor: Creates a malevolent transmitter that will broadcast the whispers of Sevtug into the minds of nearby nonservants, causing a variety of mental effects at a power cost.
/datum/clockwork_scripture/create_object/mania_motor
	descname = "Structure, Area Denial"
	name = "Mania Motor"
	desc = "Creates a mania motor which will cause brain damage and hallucinations in nearby non-servant humans. It will also try to convert humans directly adjecent to the motor."
	invocations = list("May this transmitter...", "...break the will of all who oppose us!")
	channel_time = 80
	required_components = list(GEIS_CAPACITOR = 4, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 1)
	consumed_components = list(GEIS_CAPACITOR = 3, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 1)
	object_path = /obj/structure/destructible/clockwork/powered/mania_motor
	creator_message = "<span class='brass'>You form a mania motor which will cause brain damage and hallucinations in nearby humans while active.</span>"
	observer_message = "<span class='warning'>A two-pronged machine rises from the ground!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Eligible human servants next to the motor will be converted at an additional power cost. It will also cure hallucinations and brain damage in nearby servants."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 8
	quickbind = TRUE
	quickbind_desc = "Creates a Mania Motor, which can convert adjacent non-Servants with power."


//Tinkerer's Daemon: Creates an efficient machine that rapidly produces components at a power cost.
/datum/clockwork_scripture/create_object/tinkerers_daemon
	descname = "Structure, Component Generator"
	name = "Tinkerer's Daemon"
	desc = "Creates a tinkerer's daemon which can rapidly collect components. It will only function if it has sufficient power, is outnumbered by servants by a ratio of 5:1, and there is at least one existing cache."
	invocations = list("May this generator...", "...collect Engine parts that yet hold greatness!")
	channel_time = 80
	required_components = list(BELLIGERENT_EYE = 1, GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 4)
	consumed_components = list(BELLIGERENT_EYE = 1, GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 3)
	object_path = /obj/structure/destructible/clockwork/powered/tinkerers_daemon
	creator_message = "<span class='brass'>You form a tinkerer's daemon which can rapidly collect components at a power cost.</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Vital to your success!"
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = REPLICANT_ALLOY
	sort_priority = 9
	quickbind_desc = "Creates a Tinkerer's Daemon, which can rapidly collect components for power."

/datum/clockwork_scripture/create_object/tinkerers_daemon/check_special_requirements()
	var/servants = 0
	for(var/mob/living/L in living_mob_list)
		if(is_servant_of_ratvar(L))
			servants++
	if(servants * 0.2 < clockwork_daemons)
		invoker << "<span class='nezbere'>\"Daemons are already disabled, making more of them would be a waste.\"</span>"
		return FALSE
	if(servants * 0.2 < clockwork_daemons+1)
		invoker << "<span class='nezbere'>\"This daemon would be useless, friend.\"</span>"
		return FALSE
	return ..()


//Clockwork Obelisk: Creates a powerful obelisk that can be used to broadcast messages or open a gateway to any servant or clockwork obelisk at a power cost.
/datum/clockwork_scripture/create_object/clockwork_obelisk
	descname = "Structure, Teleportation Hub"
	name = "Clockwork Obelisk"
	desc = "Creates a clockwork obelisk that can broadcast messages over the Hierophant Network or open a Spatial Gateway to any living servant or clockwork obelisk."
	invocations = list("May this obelisk...", "...take us to all places!")
	channel_time = 80
	required_components = list(VANGUARD_COGWHEEL = 1, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 4)
	consumed_components = list(VANGUARD_COGWHEEL = 1, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 3)
	object_path = /obj/structure/destructible/clockwork/powered/clockwork_obelisk
	creator_message = "<span class='brass'>You form a clockwork obelisk which can broadcast messages or produce Spatial Gateways.</span>"
	observer_message = "<span class='warning'>A brass obelisk appears handing in midair!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Producing a gateway has a high power cost. Gateways to or between clockwork obelisks recieve double duration and uses."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 10
	quickbind = TRUE
	quickbind_desc = "Creates a Clockwork Obelisk, which can send messages or open Spatial Gateways with power."
