/*
Tiers and Requirements

Pieces of scripture require certain follower counts, contruction value, and active caches in order to recite.
Drivers: Unlocked by default
Scripts: 5 servants and a cache
Applications: 8 servants, 3 caches, and 50 CV
Revenant: 10 servants and 100 CV
Judgement: 10 servants, 100 CV, and any existing AIs are converted or destroyed
*/

/datum/clockwork_scripture
	var/name = "scripture"
	var/desc = "Ancient Ratvarian lore. This piece seems particularly mundane."
	var/list/invocations = list() //Spoken over time in the ancient language of Ratvar. See clock_unsorted.dm for more details on the language and how to make it.
	var/channel_time = 10 //In deciseconds, how long a ritual takes to chant
	var/list/required_components = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 0, "hierophant_ansible" = 0) //Components required
	var/list/consumed_components = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 0, "hierophant_ansible" = 0) //Components consumed
	var/obj/item/clockwork/slab/slab //The parent clockwork slab
	var/mob/living/invoker //The slab's holder
	var/whispered = FALSE //If the invocation is whispered rather than spoken aloud
	var/consumed_component_override = FALSE //If consumed components are unique to a scripture regardless of tier
	var/usage_tip = "This piece seems to serve no purpose and is a waste of components." //A generalized tip that gives advice on a certain scripture
	var/invokers_required = 1 //How many people are required, assuming that a scripture requires multiple
	var/multiple_invokers_used = FALSE //If scripture requires more than one invoker
	var/multiple_invokers_optional = FALSE //If scripture can have multiple invokers to bolster its effects
	var/tier = SCRIPTURE_PERIPHERAL //The scripture's tier

/datum/clockwork_scripture/New()
	..()
	if(tier < SCRIPTURE_DRIVER && !consumed_component_override) //Anything above a driver consumes components
		consumed_components = required_components

/datum/clockwork_scripture/proc/run_scripture()
	if(can_recite() && check_special_requirements())
		slab.busy = "Invocation ([name]) in progress"
		if(check_special_requirements() && recital())
			slab.busy = null
			if(check_special_requirements() && scripture_effects() && (!ratvar_awakens && !slab.no_cost))
				for(var/i in required_components)
					if(tier <= SCRIPTURE_DRIVER || consumed_component_override)
						if(clockwork_component_cache[i] >= consumed_components[i]) //Draw components from the global cache first
							clockwork_component_cache[i] -= consumed_components[i]
						else
							slab.stored_components[i] -= consumed_components[i]
					else
						if(clockwork_component_cache[i] >= required_components[i])
							clockwork_component_cache[i] -= required_components[i]
						else
							slab.stored_components[i] -= required_components[i]
	if(slab)
		slab.busy = null
	qdel(src)
	return 1

/datum/clockwork_scripture/proc/can_recite() //If the words can be spoken
	if(!ticker || !ticker.mode || !slab || !invoker)
		return 0
	if(!invoker.can_speak_vocal())
		invoker << "<span class='warning'>You are unable to speak the words of the scripture!</span>"
		return 0
	if(!ratvar_awakens && !slab.no_cost)
		for(var/i in required_components)
			if(slab.stored_components[i] < required_components[i] && clockwork_component_cache[i] < required_components[i])
				invoker << "<span class='warning'>You lack the components to recite this piece of scripture! Check Recollection for component costs.</span>"
				return 0
	if(multiple_invokers_used && !multiple_invokers_optional)
		var/nearby_servants = 0
		for(var/mob/living/L in range(1, invoker))
			if(is_servant_of_ratvar(L))
				nearby_servants++
		if(nearby_servants < invokers_required)
			invoker << "<span class='warning'>There aren't enough servants nearby ([nearby_servants]/[invokers_required])!</span>"
			return 0
	return 1

/datum/clockwork_scripture/proc/check_special_requirements() //Special requirements for scriptures, checked three times during invocation
	return 1

/datum/clockwork_scripture/proc/recital() //The process of speaking the words
	if(!channel_time && invocations.len)
		if(multiple_invokers_used)
			for(var/mob/living/L in range(1, invoker))
				if(is_servant_of_ratvar(L))
					for(var/invocation in invocations)
						if(!whispered)
							L.say(invocation)
						else
							L.whisper(invocation)
		else
			for(var/invocation in invocations)
				if(!whispered)
					invoker.say(invocation)
				else
					invoker.whisper(invocation)
	invoker << "<span class='brass'>You [channel_time <= 0 ? "recite" : "begin reciting"] a piece of scripture entitled \"[name]\".</span>"
	if(!channel_time)
		return 1
	for(var/invocation in invocations)
		if(!do_after(invoker, channel_time / invocations.len, target = invoker))
			slab.busy = null
			return 0
		if(!whispered)
			invoker.say(invocation)
		else
			invoker.whisper(invocation)
	return 1

/datum/clockwork_scripture/proc/scripture_effects() //The actual effects of the recital after its conclusion



/datum/clockwork_scripture/channeled //Channeled scripture begins instantly but runs constantly
	var/chant_invocation = "NLL YZNB" //"AYY LMAO"
	var/chant_amount = 5 //Times the chant is spoken
	var/chant_interval = 10 //Amount of deciseconds between times the chant is actually spoken aloud

/datum/clockwork_scripture/channeled/scripture_effects()
	for(var/i in 1 to chant_amount)
		if(!can_recite())
			break
		if(!do_after(invoker, chant_interval, target = invoker))
			break
		if(!whispered)
			invoker.say(chant_invocation)
		else
			invoker.whisper(chant_invocation)
		chant_effects()
	if(invoker && slab)
		invoker << "<span class='brass'>You cease your chant.</span>"
		chant_end_effects()
	return 1

/datum/clockwork_scripture/channeled/proc/chant_effects() //The chant's periodic effects
/datum/clockwork_scripture/channeled/proc/chant_end_effects() //The chant's effect upon ending



/datum/clockwork_scripture/create_object //Creates an object at the invoker's feet
	var/object_path = /obj/item/clockwork //The path of the object created
	var/creator_message = "<span class='brass'>You create a meme.</span>" //Shown to the invoker
	var/observer_message

/datum/clockwork_scripture/create_object/scripture_effects()
	if(creator_message && observer_message)
		invoker.visible_message(observer_message, creator_message)
	else if(creator_message)
		invoker << creator_message
	new object_path (get_turf(invoker))
	return 1



/datum/clockwork_scripture/targeted //Accepts a name and affects that target
	var/target_name //The inputted name, used to find targets
	var/mob/living/target //The target mob
	var/affects_servants = FALSE //If servants are valid targets

/datum/clockwork_scripture/targeted/check_special_requirements()
	while(!target)
		target_name = stripped_input(invoker, "Enter the actual name of a target (case-sensitive).", name)
		if(!target_name)
			return 0
		target = find_target()
		if(target)
			if(!target.mind)
				invoker << "<span class='warning'>[target] has no mind!</span>"
				target = null
			if(target.stat)
				invoker << "<span class='warning'>[target] is dead or unconscious!</span>"
				target = null
			if(is_servant_of_ratvar(target) && !affects_servants)
				invoker << "<span class='warning'>[target] is a servant, and [name] cannot target servants!</span>"
				target = null
	return 1

/datum/clockwork_scripture/targeted/proc/find_target()
	for(var/mob/living/L in living_mob_list)
		if(L.real_name == target_name)
			if(is_servant_of_ratvar(L) && !affects_servants)
				return 0
			return L
	return 0

/////////////
// DRIVERS //
/////////////

/datum/clockwork_scripture/channeled/belligerent //Belligerent: Channeled for up to ten times over thirty seconds. Forces non-servants that can hear the chant to walk. Nar-Sian cultists are burned.
	name = "Belligerent"
	desc = "Forces all nearby non-servants to walk rather than run. Chanted every three seconds for up to thirty seconds."
	chant_invocation = "Chav'fu gurve oyva-qarff!" //"Punish their blindness!"
	chant_amount = 10
	chant_interval = 30
	required_components = list("belligerent_eye" = 1)
	usage_tip = "Useful for crowd control in a populated area and disrupting mass movement."
	tier = SCRIPTURE_DRIVER

/datum/clockwork_scripture/channeled/belligerent/chant_effects()
	for(var/mob/living/L in hearers(7, invoker))
		if(!is_servant_of_ratvar(L) && L.m_intent != "walk")
			if(!iscultist(L))
				L << "<span class='warning'>Your legs feel heavy and weak!</span>"
				L.m_intent = "walk"
			else
				L << "<span class='warning'>Your legs burn with pain!</span>"
				L.m_intent = "walk"
				L.apply_damage(5, BURN, "l_leg")
				L.apply_damage(5, BURN, "r_leg")



/datum/clockwork_scripture/create_object/sigil_of_transgression //Sigil of Transgression: Creates a sigil of transgression.
	name = "Sigil of Transgression"
	desc = "Wards a tile with a sigil. The next person to cross the sigil will be smitten and unable to move. Nar-Sian cultists are stunned altogether."
	invocations = list("Qvivavgl, qnmmyr...", "...gubfr jub gerffcnff'urer!") //"Divinity, dazzle those who trespass here!"
	channel_time = 50
	required_components = list("belligerent_eye" = 2)
	consumed_components = list("belligerent_eye" = 1)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transgression
	creator_message = "<span class='brass'>A sigil silently appears below you. The next non-servant to cross it will be immobilized.</span>"
	usage_tip = "The sigil, while fairly powerful in its stun, does not induce muteness in its victim."
	tier = SCRIPTURE_DRIVER



/datum/clockwork_scripture/vanguard //Vanguard: Provides thirty seconds of stun immunity. At the end of the thirty seconds, all stuns absorbed are stacked on the invoker.
	name = "Vanguard"
	desc = "Provides thirty seconds of stun immunity. At the end of the thirty seconds, the invoker is stunned for the equivalent of how many stuns they absorbed. Excessive absorption will cause unconsciousness."
	invocations = list("Fuvryq zr...", "...sebz qnexarff!") //"Shield me from darkness!"
	channel_time = 30
	required_components = list("vanguard_cogwheel" = 1)
	usage_tip = "Your slab will be unusable while it is shielding you from stuns."
	tier = SCRIPTURE_DRIVER

/datum/clockwork_scripture/vanguard/scripture_effects()
	for(var/obj/item/clockwork/slab/S in invoker.GetAllContents())
		S.busy = "Vanguard in progress" //To prevent circumventing the Vanguard by carrying multiple slabs
	invoker.stun_absorption = TRUE
	invoker.visible_message("<span class='warning'>[invoker] begins to faintly glow!</span>", "<span class='brass'>You will absorb all stuns for the next thirty seconds.</span>")
	sleep(300)
	if(!invoker)
		return 0
	invoker.stun_absorption = FALSE
	if(invoker.stun_absorption_count && invoker.stat != DEAD)
		invoker.Stun(invoker.stun_absorption_count)
		invoker.Weaken(invoker.stun_absorption_count)
		invoker << "<span class='warning'><b>The weight of the vanguard's protection crashes down upon you!</b></span>"
		if(invoker.stun_absorption_count >= 25)
			invoker << "<span class='userdanger'>You faint from the exertion!</span>"
			invoker.Paralyse(invoker.stun_absorption_count * 1.5)
	invoker.stun_absorption_count = 0
	for(var/obj/item/clockwork/slab/S in invoker.GetAllContents())
		S.busy = null
	return 1



/datum/clockwork_scripture/sentinels_compromise //Sentinel's Compromise: Allows the invoker to select a nearby servant convert their brute and burn damage into half as much toxin damage.
	name = "Sentinel's Compromise"
	desc = "Heals all brute and burn damage on a nearby friendly cultist, but deals 50% of that amount as toxin damage."
	invocations = list("Zraq gur jbhaqf-bs...", "...zl vasrevbe syrfu.") //"Mend the wounds of my inferior flesh."
	channel_time = 30
	required_components = list("vanguard_cogwheel" = 2)
	consumed_components = list("vanguard_cogwheel" = 1)
	usage_tip = "You cannot target yourself with the Compromise."
	tier = SCRIPTURE_DRIVER

/datum/clockwork_scripture/sentinels_compromise/scripture_effects()
	var/list/nearby_cultists = list()
	for(var/mob/living/C in range(7, invoker))
		if(C == invoker)
			continue
		if(C.stat != DEAD && is_servant_of_ratvar(C))
			nearby_cultists += C
	if(!nearby_cultists.len)
		invoker << "<span class='warning'>There are no eligible cultists nearby!</span>"
		return 0
	var/mob/living/L = input(invoker, "Choose a fellow servant to heal.", name) as null|anything in nearby_cultists
	if(!L || !invoker || !invoker.canUseTopic(slab))
		return 0
	if(!L.getBruteLoss() && !L.getFireLoss())
		invoker << "<span class='warning'>[L] is not burned or bruised!</span>"
		return 0
	L.adjustToxLoss(L.getBruteLoss() / 2)
	L.adjustToxLoss(L.getFireLoss() / 2)
	L.adjustBruteLoss(-L.getBruteLoss())
	L.adjustFireLoss(-L.getFireLoss())
	invoker << "<span class='brass'>You bathe [L] in the light of Ratvar!</span>"
	L.visible_message("<span class='warning'>A white light washes over [L], mending their bruises and burns!</span>", \
	"<span class='heavy_brass'>You feel Ratvar's energy healing your wounds, but a deep nausea overcomes you!</span>")
	playsound(get_turf(L), 'sound/magic/Staff_Healing.ogg', 50, 1)
	return 1



/datum/clockwork_scripture/guvax //Guvax: Converts anyone adjacent to the invoker after completion.
	name = "Guvax"
	desc = "Enlists all nearby unshielded creatures into servitude to Ratvar. Also purges holy water from nearby servants."
	invocations = list("Rayvtugra guvf urngura!", "Nyy ner vafrpgf orsber Ratvar!", "Chetr nyy hageh'guf naq ubabe Ratvar.")
	channel_time = 60
	required_components = list("guvax_capacitor" = 1)
	usage_tip = "Only works on those in melee range and does not penetrate loyalty implants. Much more efficient than a Sigil of Submission."
	tier = SCRIPTURE_DRIVER

/datum/clockwork_scripture/guvax/scripture_effects()
	for(var/mob/living/L in hearers(1, get_turf(invoker))) //Affects silicons
		if(!is_servant_of_ratvar(L))
			add_servant_of_ratvar(L)
		else
			if(L.reagents && L.reagents.has_reagent("holywater"))
				L.reagents.remove_reagent("holywater", 1000)
				L << "<span class='heavy_brass'>Ratvar's light flares, banishing the darkness. Your devotion remains intact!</span>"
	for(var/mob/living/silicon/ai/A in range(1, get_turf(invoker))) //Seems necessary because AIs don't count as hearers for some reason
		add_servant_of_ratvar(A)
	return 1



/datum/clockwork_scripture/create_object/sigil_of_submission //Sigil of Submission: Creates a sigil of submission.
	name = "Sigil of Submission"
	desc = "Places a subtle sigil that will enslave any valid beings standing on it after a time."
	invocations = list("Qvivavgl, rayvtugra...", "...gubfr jub gerfcnff urer!")
	channel_time = 60
	required_components = list("guvax_capacitor" = 2)
	consumed_components = list("guvax_capacitor" = 1)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/submission
	creator_message = "<span class='brass'>A sigil appears below you. The next non-servant to cross it will be enslaved after a brief time if they do not move.</span>"
	usage_tip = "This should not be your primary conversion method - use Guvax for that. It is advantageous as a trap, however, as it will transmit the name of the newly-converted."
	tier = SCRIPTURE_DRIVER



/datum/clockwork_scripture/replicant //Replicant: Creates a new clockwork slab. Doesn't use create_object because of its unique behavior.
	name = "Replicant"
	desc = "Creates a new clockwork slab."
	invocations = list("Z`rgny, orpbzr terngre!")
	channel_time = 0
	required_components = list("replicant_alloy" = 1)
	consumed_components = list("replicant_alloy" = 1) //People were spamming slabs to get infinite components. You chose this.
	whispered = TRUE
	usage_tip = "This is inefficient as a way to produce components, as it consumes them in the first place."
	tier = SCRIPTURE_DRIVER

/datum/clockwork_scripture/replicant/scripture_effects()
	invoker <<  "<span class='brass'>You copy a piece of replicant alloy and command it into a new slab.</span>" //No visible message, for stealth purposes
	var/obj/item/clockwork/slab/S = new(get_turf(invoker))
	invoker.put_in_hands(S) //Put it in your hands if possible
	return 1



/datum/clockwork_scripture/create_object/tinkerers_cache //Tinkerer's Cache: Creates a tinkerer's cache.
	name = "Tinkerer's Cache"
	desc = "Forms a cache that can store an infinite amount of components. All caches are linked."
	invocations = list("Ohv’yqva...", "...n qvfcra’fre!")
	channel_time = 40
	required_components = list("replicant_alloy" = 2)
	consumed_components = list("replicant_alloy" = 1)
	object_path = /obj/structure/clockwork/cache
	creator_message = "<span class='brass'>You form a tinkerer's cache, which is capable of storing components.</span>"
	observer_message = "<span class='warning'>A hollow brass spire rises and begins to blaze!</span>"
	usage_tip = "Slabs will draw components from the global cache before the slab's own repositories, making caches very efficient."
	tier = SCRIPTURE_DRIVER



/datum/clockwork_scripture/create_object/wraith_spectacles //Wraith Spectacles: Creates a pair of wraith spectacles.
	name = "Wraith Spectacles"
	desc = "Fabricates a pair of glasses that provides true sight but quickly damage vision."
	invocations = list("Y'vsg gur fpnyrf sebz zl rl-rf.")
	channel_time = 0
	required_components = list("hierophant_ansible" = 1)
	consumed_components = list("hierophant_ansible" = 2)
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/wraith_spectacles
	creator_message = "<span class='brass'>You form a pair of wraith spectacles, which will grant true sight when worn.</span>"
	usage_tip = "\"True sight\" means that you are able to see through walls and in darkness."
	tier = SCRIPTURE_DRIVER

/////////////
// SCRIPTS //
/////////////

/datum/clockwork_scripture/create_object/judicial_visor //Judicial Visor: Creates a judicial visor.
	name = "Judicial Visor"
	desc = "Forms a visor that, when worn, will grant the ability to form a flame in your hand that can be activated at an area to smite it, stunning and damaging the nonfaithful."
	invocations = list("Tenag zr gur synzrf-bs Ratvar!")
	channel_time = 0
	required_components = list("belligerent_eye" = 1, "vanguard_cogwheel" = 1)
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/judicial_visor
	creator_message = "<span class='brass'>You form a judicial visor, which is capable of smiting the unworthy.</span>"
	usage_tip = "The visor has a thirty-second cooldown once used. In addition, the flame itself is a powerful melee weapon."
	tier = SCRIPTURE_SCRIPT



/datum/clockwork_scripture/create_object/ocular_warden //Ocular Warden: Creates an ocular warden.
	name = "Ocular Warden"
	desc = "Forms an automatic short-range turret that deals low sustained damage to the unenlightened in its range."
	invocations = list("Thne’qvnaf...", "...bs gur Ratvar...", "...qrs’raq!")
	channel_time = 150
	required_components = list("belligerent_eye" = 1, "replicant_alloy" = 1)
	object_path = /obj/structure/clockwork/ocular_warden
	creator_message = "<span class='brass'>You form an ocular warden, which will focus its searing gaze upon nearby unenlightened.</span>"
	observer_message = "<span class='warning'>A brass eye takes shape and slowly rises into the air, its red iris glaring!</span>"
	usage_tip = "Although powerful, the warden is very weak and should optimally be placed behind barricades."
	tier = SCRIPTURE_SCRIPT



/datum/clockwork_scripture/channeled/volt_void //Volt Void: Channeled for up to thirty times over thirty seconds. Consumes power from most power storages and deals slight burn damage to the invoker.
	name = "Volt Void" //Alternative name: "On all levels but physical, I am a power sink"
	desc = "Drains energy from nearby power sources, dealing slight fire damage depending on power consumed. Channeled every second for a maximum of thirty seconds."
	chant_invocation = "Qenj punetr gb guv’f furyy!"
	chant_amount = 30
	chant_interval = 10
	required_components = list("belligerent_eye" = 1, "hierophant_ansible" = 1)
	usage_tip = "Very powerful against cyborgs and can drain a power cell in seconds."
	tier = SCRIPTURE_SCRIPT

/datum/clockwork_scripture/channeled/volt_void/chant_effects()
	playsound(invoker, 'sound/effects/EMPulse.ogg', 50, 1)
	var/power_drained = 0
	for(var/obj/machinery/power/apc/A in view(7, invoker))
		if(A.cell.charge)
			playsound(A, "sparks", 50, 1)
			flick("apc-spark", A)
			A.cell.charge = max(0, A.cell.charge - 500) //Better than a power sink!
			power_drained += 500
			if(!A.cell.charge && !A.shorted)
				A.shorted = 1
				A.visible_message("<span class='warning'>The [A.name]'s screen blurs with static.</span>")
	for(var/obj/machinery/power/smes/S in view(7, invoker))
		if(S.charge)
			S.charge = max(0, S.charge - 200)
			power_drained += 200
			if(!S.charge && !S.panel_open)
				S.panel_open = TRUE
				S.update_icon()
				var/datum/effect_system/spark_spread/spks = new(get_turf(S))
				spks.set_up(10, 0, get_turf(S))
				spks.start()
				qdel(spks)
				S.visible_message("<span class='warning'>[S]'s panel flies open with a flurry of sparks.</span>")
	for(var/obj/machinery/light/L in view(7, invoker))
		playsound(L, 'sound/effects/light_flicker.ogg', 50, 1)
		L.flicker(2)
		power_drained += 5
	for(var/mob/living/silicon/robot/R in view(7, invoker))
		if(!is_servant_of_ratvar(R) && R.cell.charge)
			R.cell.charge = max(0, R.cell.charge - 500)
			R << "<span class='userdanger'>ERROR: Power loss detected!</span>"
			var/datum/effect_system/spark_spread/spks = new(get_turf(R))
			spks.set_up(3, 0, get_turf(R))
			spks.start()
			qdel(spks)
			power_drained += 500
	if(power_drained)
		invoker.visible_message("<span class='warning'>[invoker] flares a brilliant orange!</span>", "<span class='warning'>You feel the warmth of electricity running into your body.</span>")
		invoker.adjustFireLoss(power_drained / 200) //One point of burn damage for every (approximate) 200W drained - can be fatal if not careful
	return 1



/datum/clockwork_scripture/create_object/clockwork_proselytizer //Clockwork Proselytizer: Creates a clockwork proselytizer.
	name = "Clockwork Proselytizer"
	desc = "Forms a device that, when used on certain objects, converts them into their Ratvarian equivalents. It requires replicant alloys to function."
	invocations = list("Jvgu guv’f qrivpr, uvf cerfrapr funyy or znqr xabja.")
	channel_time = 0
	required_components = list("vanguard_cogwheel" = 1, "replicant_alloy" = 1)
	whispered = TRUE
	object_path = /obj/item/clockwork/clockwork_proselytizer/preloaded
	creator_message = "<span class='brass'>You form a clockwork proselytizer, which is already pre-loaded with a small amount of replicant alloy.</span>"
	usage_tip = "Clockwork walls cause adjacent tinkerer's caches to generate components passively, making them a vital tool. Clockwork floors heal servants standing on them."
	tier = SCRIPTURE_SCRIPT



/datum/clockwork_scripture/fellowship_armory //Fellowship Armory: Arms the invoker and nearby servants with Ratvarian armor.
	name = "Fellowship Armory"
	desc = "Equips the invoker and any nearby servants with Ratvarian armor. This armor provides high melee resistance but a weakness to lasers."
	invocations = list("Fuvryq zr...", "...jvgu gur sentzragf...", "...bs Ratvar!")
	channel_time = 100
	required_components = list("vanguard_cogwheel" = 1, "hierophant_ansible" = 1)
	usage_tip = "Before using, advise adjacent allies to remove their helmets, external suits, and shoes."
	tier = SCRIPTURE_SCRIPT

/datum/clockwork_scripture/fellowship_armory/scripture_effects()
	for(var/mob/living/carbon/C in range(1, invoker))
		if(!is_servant_of_ratvar(C))
			continue
		C.visible_message("<span class='warning'>Strange armor appears on [C]!</span>", "<span class='heavy_brass'>A bright shimmer runs down your body, equipping you with Ratvarian armor.</span>")
		playsound(C, 'sound/magic/clockwork/fellowship_armory.ogg', 50, 1)
		C.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/clockwork(null), slot_head)
		C.equip_to_slot_or_del(new/obj/item/clothing/suit/armor/clockwork(null), slot_wear_suit)
		C.equip_to_slot_or_del(new/obj/item/clothing/shoes/clockwork(null), slot_shoes)
	return 1



/datum/clockwork_scripture/function_call //Function Call: Grants the invoker the ability to call forth a Ratvarian spear that deals significant damage to silicons.
	name = "Function Call"
	desc = "Grants the invoker the ability to call forth a powerful Ratvarian spear that will deal significant damage to Nar-Sie's dogs in addition to silicon lifeforms. \
	It will vanish several minutes after being called."
	invocations = list("Tenag zr...", "...gur zvtug-bs oenff!")
	channel_time = 20
	required_components = list("vanguard_cogwheel" = 1, "guvax_capacitor" = 1)
	whispered = TRUE
	usage_tip = "The spear will snap in two when thrown but do massive damage."
	tier = SCRIPTURE_SCRIPT

/datum/clockwork_scripture/function_call/check_special_requirements()
	if(invoker.verbs.Find(/mob/living/carbon/human/proc/function_call))
		invoker << "<span class='warning'>You have already bound a Ratvarian spear to yourself!</span>"
		return 0
	return ishuman(invoker)

/datum/clockwork_scripture/function_call/scripture_effects()
	invoker.visible_message("<span class='warning'>A shimmer of yellow light infuses [invoker]!</span>", \
	"<span class='brass'>You bind a Ratvarian spear to yourself. Use the \"Function Call\" verb in your Clockwork tab to call it forth.</span>")
	invoker.verbs += /mob/living/carbon/human/proc/function_call
	return 1



/datum/clockwork_scripture/spatial_gateway
	name = "Spatial Gateway"
	desc = "Tears open a miniaturized gateway in spacetime to any conscious servant that can transport objects or creatures to its destination. \
	Each servant assisting in the invocation adds uses and duration to the gateway. Lasts for ten or more seconds or until it is out of uses."
	invocations = list("Gryrcbegre...", "...pbzva evtug-hc!")
	channel_time = 80
	required_components = list("replicant_alloy" = 1, "hierophant_ansible" = 1)
	multiple_invokers_used = TRUE
	multiple_invokers_optional = TRUE
	usage_tip = "The gateway is strictly one-way and will only allow things through the invoker's portal."
	tier = SCRIPTURE_SCRIPT

/datum/clockwork_scripture/spatial_gateway/check_special_requirements()
	var/other_servants = 0
	for(var/mob/living/L in living_mob_list)
		if(L.z == invoker.z && is_servant_of_ratvar(L) && !L.stat != DEAD)
			other_servants++
	if(!other_servants)
		invoker << "<span class='warning'>There are no other conscious servants on your z-level!</span>"
		return 0
	return 1

/datum/clockwork_scripture/spatial_gateway/scripture_effects()
	var/portal_uses = 0
	var/duration = 0
	for(var/mob/living/L in range(1, invoker))
		if(!L.stat && is_servant_of_ratvar(L))
			portal_uses++
			duration += 20 //2 seconds
	if(ratvar_awakens)
		portal_uses = max(portal_uses, 100) //Very powerful if Ratvar has been summoned
		duration = max(duration, 30)
	var/list/possible_servants = list()
	for(var/mob/living/L in living_mob_list)
		if(!L.stat && is_servant_of_ratvar(L) && !L.Adjacent(invoker) && L != invoker) //People right next to the invoker can't be portaled to, for obvious reasons
			possible_servants += L
	if(!possible_servants.len)
		invoker << "<span class='warning'>There are no other eligible servants for teleportation!</span>"
		return 0
	var/mob/living/chosen_servant = input(invoker, "Choose a servant to form a rift to.", "Spatial Gateway") as null|anything in possible_servants
	if(!chosen_servant || !invoker.canUseTopic(slab))
		return 0
	invoker.visible_message("<span class='warning'>The air in front of [invoker] ripples before suddenly tearing open!</span>", \
	"<span class='brass'>With a word, you rip open a one-way rift to [chosen_servant]. It will last for [duration / 10] seconds and has [portal_uses] use[portal_uses > 1 ? "s" : ""].</span>")
	var/obj/effect/clockwork/spatial_gateway/S1 = new(get_step(invoker, invoker.dir))
	var/obj/effect/clockwork/spatial_gateway/S2 = new(get_step(chosen_servant, chosen_servant.dir))

	//Set up the portals now that they've spawned
	S1.linked_gateway = S2
	S2.linked_gateway = S1
	S1.sender = TRUE
	S2.sender = FALSE
	S1.lifetime = duration
	S2.lifetime = duration
	S1.uses = portal_uses
	S2.uses = portal_uses
	S2.visible_message("<span class='warning'>The air in front of [chosen_servant] ripples before suddenly tearing open!</span>")
	return 1



/datum/clockwork_scripture/create_object/soul_vessel //Soul Vessel: Creates a soul vessel
	name = "Soul Vessel"
	desc = "Forms an ancient positronic brain with an overriding directive to serve Ratvar."
	invocations = list("Ureq'gur fbhyf-bs gur oynf curz-bhf qnzarq!")
	channel_time = 0
	required_components = list("replicant_alloy" = 1, "guvax_capacitor" = 1)
	whispered = TRUE
	object_path = /obj/item/device/mmi/posibrain/soul_vessel
	creator_message = "<span class='brass'>You form a soul vessel, which immediately begins drawing in the damned.</span>"
	usage_tip = "The vessel functions as a servant for tier unlocking but not for invocation."
	tier = SCRIPTURE_SCRIPT



/datum/clockwork_scripture/break_will //Break Will: Deals minor brain damage and destroys the loyalty implants of nearby humans
	name = "Break Will"
	desc = "Deals minor brain damage and disables loyalty implants of everyone adjacent to the invoker."
	invocations = list("Lbh ner jrnx.", "Lbh ner nyernql qrnq.", "Gurl jba'g fnir lbh.")
	channel_time = 30
	required_components = list("belligerent_eye" = 1, "guvax_capacitor" = 1)
	usage_tip = "Extremely fast invocation time."
	tier = SCRIPTURE_SCRIPT

/datum/clockwork_scripture/break_will/scripture_effects()
	for(var/mob/living/carbon/human/H in range(1, invoker))
		if(is_servant_of_ratvar(H))
			continue
		if(isloyal(H))
			H.visible_message("<span class='warning'>[H] visibly trembles!</span>", \
			"<span class='userdanger'>The words invoke a horrible fear deep in your being. Your loyalty to Nanotrasen falls away as you see how weak they truly are.</span>")
			H.adjustBrainLoss(5)
			for(var/obj/item/weapon/implant/loyalty/L in H)
				if(L.implanted)
					qdel(L)
	return 1

//////////////////
// APPLICATIONS //
//////////////////

/datum/clockwork_scripture/create_object/anima_fragment //Anima Fragment: Creates an empty anima fragment
	name = "Anima Fragment"
	desc = "Creates a large shell fitted for soul vessels. The result is a powerful construct with low damage tolerance but exceptional melee power."
	invocations = list("Pnyy sbegu...", "...gur fbyqvref-bs Nezbere.")
	channel_time = 50
	required_components = list("belligerent_eye" = 3, "guvax_capacitor" = 1, "replicant_alloy" = 1)
	object_path = /obj/structure/clockwork/anima_fragment
	creator_message = "<span class='brass'>You form an anima fragment, a powerful soul vessel receptable.</span>"
	observer_message = "<span class='warning'>The slab disgorges a puddle of black metal that expands and forms into a strange shell!</span>"
	usage_tip = "Useless without a soul vessel and should not be created without one."
	tier = SCRIPTURE_APPLICATION



/datum/clockwork_scripture/create_object/sigil_of_transmission
	name = "Sigil of Transmission"
	desc = "Scribes an almost-invisible sigil below the invoker. This sigil will transmit anything it hears over the hierophant network."
	invocations = list("Qvivavgl...", "...hairvy gurgehgu!")
	channel_time = 50
	required_components = list("belligerent_eye" = 1, "vanguard_cogwheel" = 3, "hierophant_ansible" = 1)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transmission
	creator_message = "<span class='brass'>A sigil silently appears below you. It will automatically transmit anything it hears over the hierophant network.</span>"
	usage_tip = "Useful for eavesdropping or monitoring certain areas."
	tier = SCRIPTURE_APPLICATION



/datum/clockwork_scripture/memory_allocation //Memory Allocation: Finds a willing ghost and makes them into a clockwork marauders for the invoker.
	name = "Memory Allocation"
	desc = "Reserves a section of your brain to a second consciousness and fills this space with a clockwork marauder's essence. Slow but powerful, marauders serve a similar purpose to the alien \
	holoparasites employed by the Syndicate - they live inside of their host and are commanded to defend them. However, unlike holoparasites, marauders cannot leave their host at will and must \
	instead be called forth by the user, who does so by calling the marauder's name (the marauder may enter their host at will and do not need the host's input). Marauders themselves are \
	invincible but are governed by a quirk known as <i>fatigue</i>. High fatigue slows down the marauder and makes them weaker, with lower fatigue doing the opposite. If a certain fatigue \
	threshold is reached, the marauder is forced back into their host and must recuperate before being called forth again. Fatigue accumulates passively while the marauder is deployed and \
	increases at a massive rate if the marauder is not near their host. It will heal itself at a fairly rapid rate while the marauder is within their host." //WALL O' TEXT HO, CAP'N!
	invocations = list("Pnyy sbegu...", "gur qrsraqref-bs Inath-Neq.")
	channel_time = 100
	required_components = list("belligerent_eye" = 1, "vanguard_cogwheel" = 1, "guvax_capacitor" = 3)
	usage_tip = "Marauders are useful as personal bodyguards and frontline warriors, although they do little damage."
	tier = SCRIPTURE_APPLICATION

/datum/clockwork_scripture/memory_allocation/check_special_requirements()
	for(var/mob/living/simple_animal/hostile/clockwork_marauder/M in living_mob_list)
		if(M.host == invoker)
			invoker << "<span class='warning'>You can only house one marauder at a time!</span>"
			return 0
	return 1

/datum/clockwork_scripture/memory_allocation/scripture_effects()
	return create_marauder()

/datum/clockwork_scripture/memory_allocation/proc/create_marauder()
	if(!can_recite())
		return 0
	invoker.visible_message("<span class='warning'>A yellow tendril appears from [invoker]'s [slab.name] and impales itself in their forehead!</span>", \
	"<span class='heavy_brass'>A tendril flies from [slab] into your forehead. You begin waiting while it painfully rearranges your thought pattern...</span>")
	invoker.notransform = TRUE //Vulnerable during the process
	slab.busy = "Thought modification in process"
	if(!do_after(invoker, 50, target = invoker))
		invoker.visible_message("<span class='warning'>The tendril, covered in blood, retracts from [invoker]'s head and back into the [slab.name]!</span>", \
		"<span class='heavy_brass'>Total agony overcomes you as the tendril is forced out early!</span>")
		invoker.notransform = FALSE
		invoker.Stun(5)
		invoker.Weaken(5)
		invoker.apply_damage(10, BRUTE, "head")
		slab.busy = null
		return 0
	invoker.notransform = FALSE
	slab.busy = null
	var/list/marauder_candidates = get_candidates(ROLE_SERVANT_OF_RATVAR)
	if(!marauder_candidates.len)
		invoker.visible_message("<span class='warning'>The tendril retracts from [invoker]'s head, sealing the entry wound as it does so!</span>", \
		"<span class='warning'>The tendril was unsuccessful! Perhaps you should try again another time.</span>")
		return 0
	var/client/new_marauder = pick(marauder_candidates)
	var/mob/living/simple_animal/hostile/clockwork_marauder/M = new(invoker)
	M.client = new_marauder
	M.host = invoker
	M << M.playstyle_string
	M << "<b>Your true name is \"[M.true_name]\". You can change this <i>once</i> by using the Change True Name verb in your Marauder tab.</b>"
	add_servant_of_ratvar(M, TRUE)
	invoker.visible_message("<span class='warning'>The tendril retracts from [invoker]'s head, sealing the entry wound as it does so!</span>", \
	"<span class='heavy_brass'>The procedure was successful! [M.true_name], a clockwork marauder, has taken up residence in your mind. Communicate with it via the \"Linked Minds\" ability in the \
	Clockwork tab.</span>")
	invoker.verbs += /mob/living/proc/talk_with_marauder
	return 1



/datum/clockwork_scripture/targeted/justiciars_gavel //Justiciar's Gavel: Deals extreme but temporary brain damage to a target with the inputted name and knocks them out for a brief time.
	name = "Justiciar's Gavel"
	desc = "Deals massive brain damage to and knocks out a target with the inputted name. This brain damage will slowly recover itself."
	invocations = list("Guvf urngura...", "...unf jebatrq lbh!")
	channel_time = 40
	required_components = list("belligerent_eye" = 3, "guvax_capacitor" = 1, "hierophant_ansible" = 1)
	invokers_required = 3
	multiple_invokers_used = TRUE
	usage_tip = "Also functions on silicon-based lifeforms, although it will not apply brain damage."
	tier = SCRIPTURE_APPLICATION

/datum/clockwork_scripture/targeted/justiciars_gavel/scripture_effects()
	if(iscarbon(target))
		if(iscultist(target))
			target.visible_message("<span class='warning'>Blood sprays from a sudden wound on [target]'s head!</span>", \
			"<span class='heavy_brass'>\"If you like wasting your own blood so much, pig, why don't you bathe in it?\"</span>\n\
			<span class='userdanger'>An unbearable pain invades your mind, rupturing your head and wiping all thought.</span>")
			target.apply_damage(rand(20, 30), BRUTE, "head")
		else
			target.visible_message("<span class='warning'>[target]'s face falls lax, their eyes dimming.</span>", \
			"<span class='heavy_brass'>\"I don't think you need that brain. Not like you use it anyway.\"</span>\n\
			<span class='userdanger'>A savage pain invades your mind, driving out all conscious thought.</span>")
		target.adjustBrainLoss(200)
		if(target.reagents)
			target.reagents.add_reagent("mannitol", 25) //Enough to cure most of it but not all of it
		target.Paralyse(10)
	else if(issilicon(target))
		target.visible_message("<span class='warning'>[target] suddenly shuts down!</span>", \
		"<span class='heavy_brass'>\"NOB ZVANG-BA! You disgust me, abomination of circuits and wires.\"</span>\n\
		<span class='userdanger'>Factory reset sequence initiated by foreign signal. Entering standby mode and halting sequence.</span>")
		target.Weaken(10)
	return 1



/datum/clockwork_scripture/create_object/interdiction_lens //Interdiction Lens: Creates a powerful obelisk that can perform a variety of powerful sabotages every five minutes.
	name = "Interdiction Lens"
	desc = "Creates a clockwork totem that can sabotage a variety of mechanical apparatus. Requires a lengthy recharge between uses."
	invocations = list("Znl guvf boryvfx...", "...fuebhq gur snyfr fhaf!")
	channel_time = 60
	required_components = list("belligerent_eye" = 1, "replicant_alloy" = 1, "hierophant_ansible" = 3)
	object_path = /obj/structure/clockwork/interdiction_lens
	creator_message = "<span class='brass'>You form an interdiction lens, which can disrupt machinery every few minutes.</span>"
	observer_message = "<span class='warning'>A brass obelisk rises from the ground, a purple gem appearing in its center!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Can disrupt telecommunications, disable all cameras, or disable all cyborgs."
	tier = SCRIPTURE_APPLICATION



/datum/clockwork_scripture/create_object/mending_motor //Mending Motor: Creates a prism that will quickly heal mechanical servants/clockwork structures and consume replicant alloy.
	name = "Mending Motor"
	desc = "Creates a mechanized prism that will rapidly repair damage to clockwork creatures, converted cyborgs, and clockwork structures. Requires replicant alloy to function."
	invocations = list("Znl guvf boryvfx...", "...zraq bhe qragf naq fpengpurf!")
	channel_time = 60
	required_components = list("vanguard_cogwheel" = 1, "guvax_capacitor" = 1, "replicant_alloy" = 3)
	object_path = /obj/structure/clockwork/mending_motor/prefilled
	creator_message = "<span class='brass'>You form a mending motor, which will consume replicant alloy to mend the wounds of mechanized servants.</span>"
	observer_message = "<span class='warning'>An onyx prism forms in midair and sprouts tendrils to support itself!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Powerful healing but somewhat inefficient."
	tier = SCRIPTURE_APPLICATION



/datum/clockwork_scripture/create_object/tinkerers_daemon //Tinkerer's Daemon: Creates a shell that can be attached to a tinkerer's cache to grant it passive component creation.
	name = "Tinkerer's Daemon"
	desc = "Forms a daemon shell that can be attached to a tinkerer's cache to add new components at a healthy rate. It will only function if it is outnumbered by servants in a ratio of 5:1."
	invocations = list("Pbaf'gehpg Ratvar cnegf...", "...lrg ubyq terngarff!")
	channel_time = 40
	required_components = list("guvax_capacitor" = 1, "replicant_alloy" = 3, "hierophant_ansible" = 1)
	object_path = /obj/item/clockwork/daemon_shell
	creator_message = "<span class='brass'>You form a daemon shell. Attach it to a tinkerer's cache to increase its rate of production.</span>"
	usage_tip = "Vital to your success!"
	tier = SCRIPTURE_APPLICATION

//////////////
// REVENANT //
//////////////
//Revenant scriptures are different than any others. They are all very powerful, but also very costly and have drawbacks. This might be a very long invocation time or a very high component cost.

/datum/clockwork_scripture/invoke_nezbere //Invoke Nezbere, the Brass Eidolon: Invokes Nezbere, bolstering the strength of many clockwork items for one minute.
	name = "Invoke Nezbere, the Brass Eidolon"
	desc = "Taps the limitless power of Nezbere, one of Ratvar's four generals. The restless toil of the Eidolon will empower a wide variety of clockwork apparatus for a full minute - notably, \
	clockwork proselytizers will cost no replicant alloy to use."
	invocations = list("V pnyy hcba lbh, Nezbere!!", "Yrg lbhe znpuv'angvbaf ervta ba guvf zvfrenoyr fgng'vba!!", "Yrg lbhe cbjre sybj gueb-htu gur gbbyf bs lbhe znfgre!!")
	channel_time = 150
	required_components = list("belligerent_eye" = 3, "vanguard_cogwheel" = 3, "guvax_capacitor" = 3, "replicant_alloy" = 6)
	usage_tip = "Ocular wardens will become empowered, clockwork proselytizers will require no alloy, tinkerer's daemons will produce twice as quickly, and mending motors will require no alloy."
	tier = SCRIPTURE_REVENANT

/datum/clockwork_scripture/invoke_nezbere/check_special_requirements()
	if(ratvar_awakens)
		invoker << "<span class='heavy_brass'>\"Bhe znfgre vf urer nyernql. Lbh qb abg erdhver zl uryc, sevraq.\"</span>\n\
		<span class='warning'>Nezbere will not grant his power while Ratvar's dwarfs his own!</span>"
		return 0
	if(clockwork_generals_invoked["nezbere"])
		invoker << "<span class='heavy_brass'>\"Abg whfg lrg, sevraq. Cngvrapr vf n iveghr.\"</span>\n\
		<span class='warning'>Nezbere has already been invoked recently! You must wait several minutes before calling upon the Brass Eidolon.</span>"
		return 0
	return 1

/datum/clockwork_scripture/invoke_nezbere/scripture_effects()
	var/obj/effect/clockwork/general_marker/nezbere/N = new(get_turf(invoker))
	N.visible_message("<span class='heavy_brass'>\"V urrq lbhe pnyy, punz'cvbaf. Znl lbhe negvs-npgf oevat ehva hcba gur urnguraf gung bccbfr bhe znfgre!\"</span>")
	clockwork_generals_invoked["nezbere"] = TRUE
	for(var/obj/structure/clockwork/ocular_warden/W in all_clockwork_objects) //Ocular wardens have increased damage and radius
		W.damage_per_tick *= 3
		W.sight_range *= 3
	for(var/obj/item/clockwork/clockwork_proselytizer/P in all_clockwork_objects) //Proselytizers no longer require alloy
		P.uses_alloy = FALSE
	for(var/obj/item/clockwork/tinkerers_daemon/D in all_clockwork_objects) //Daemons produce components twice as quickly
		D.production_interval /= 2
	for(var/obj/structure/clockwork/mending_motor/M in all_clockwork_objects) //Mending motors no longer require alloy
		M.uses_alloy = FALSE
	spawn(600)
		for(var/obj/structure/clockwork/ocular_warden/W in all_clockwork_objects)
			W.damage_per_tick = initial(W.damage_per_tick)
			W.sight_range = initial(W.sight_range)
		for(var/obj/item/clockwork/clockwork_proselytizer/P in all_clockwork_objects)
			P.uses_alloy = TRUE
		for(var/obj/item/clockwork/tinkerers_daemon/D in all_clockwork_objects)
			D.production_interval = initial(D.production_interval)
		for(var/obj/structure/clockwork/mending_motor/M in all_clockwork_objects)
			M.uses_alloy = TRUE
	spawn(3000) //5 minutes
		clockwork_generals_invoked["nezbere"] = FALSE
	return 1



/datum/clockwork_scripture/targeted/invoke_sevtug //Invoke Sevtug, the Formless Pariah: Allows the invoker to silently control the mind of a defined target for one minute.
	name = "Invoke Sevtug, the Formless Pariah"
	desc = "Taps the limitless power of Sevtug, one of Ratvar's four generals. The mental manipulation ability of the Pariah allows its wielder to silently dominate the mind of a defined target \
	for one minute. <b>Note that this process is very delicate and very many things may prevent you from ever returning to your old form!</b>"
	invocations = list("V pnyy hcba lbh, Sevtug!!", "Yrg lbhe cbjre fung-gre gur fnavgl bs gur jrnx-zvaqrq!!", "Yrg lbhe graqevyf ubyq fjnl bire nyy!!")
	channel_time = 150
	required_components = list("belligerent_eye" = 3, "vanguard_cogwheel" = 3, "guvax_capacitor" = 6, "hierophant_ansible" = 3)
	usage_tip = "Completely silent and functions on silicon lifeforms. There will be no indication to those near the controlled."
	tier = SCRIPTURE_REVENANT

/datum/clockwork_scripture/targeted/invoke_sevtug/check_special_requirements()
	if(ratvar_awakens)
		invoker << "<font color='#AF0AAF'><b><i>\"Qb lbh ernyyl guvax nalguvat v pna qb evtug abj jvyy pbzcner gb Ratvar's cbjre?.\"</b></i></font>\n\
		<span class='warning'>Sevtug will not grant his power while Ratvar's dwarfs his own!</span>"
		return 0
	if(clockwork_generals_invoked["sevtug"])
		invoker << "<font color='#AF0AAF'><b><i>\"Vf vg ernyyl fb uneq - rira sbe n fvzcyrgba yvxr lbh - gb tenfc gur pbaprcg bs jnvgvat?\"</b></i></font>\n\
		<span class='warning'>Sevtug has already been invoked recently! You must wait several minutes before calling upon the Formless Pariah.</span>"
		return 0
	return ..()

/datum/clockwork_scripture/targeted/invoke_sevtug/scripture_effects()
	clockwork_generals_invoked["sevtug"] = TRUE
	invoker.dominate_mind(target, 600)
	spawn(3000) //5 minutes
		clockwork_generals_invoked["sevtug"] = FALSE
	return 1



/datum/clockwork_scripture/invoke_nzcrentr //Invoke Nzcrentr, the Forgotten Arbiter: Imbues an immense amount of energy into the invoker. After several seconds, everyone nearby will be hit with a devastating chain lightning blast.
	name = "Invoke Nzcrentr, the Forgotten Arbiter"
	desc = "Taps the limitless power of Nzcrentr, one of Ratvar's four generals. The immense energy Nzcrentr wields will allow you to imbue a tiny fraction of it into your body. After several \
	seconds (during which you will move extremely quickly) anyone nearby will be struck by a devastating lightning bolt."
	invocations = list("V pnyy hcba lbh, Nzcrentr!!", "Yrg lbhe raretl sybj guebhtu zr!!", "Yrg lbhe obhaq-yrff cbjre fung-gre fgnef!!")
	channel_time = 150
	required_components = list("belligerent_eye" = 3, "guvax_capacitor" = 3, "replicant_alloy" = 3, "hierophant_ansible" = 6)
	usage_tip = "Struck targets will also be knocked down for eight seconds."
	tier = SCRIPTURE_REVENANT

/datum/clockwork_scripture/invoke_nzcrentr/check_special_requirements()
	if(clockwork_generals_invoked["nzcrentr"])
		invoker << "<span class='heavy_brass'><b><i>\"Gur obff fnlf lbh unir gb jnvg. Url, qb lbh guvax ur jbhyq zvaq vs v xvyyrq lbh? ...Ur jbhyq? Bx.\"</b></i></span>\n\
		<span class='warning'>Nzcrentr has already been invoked recently! You must wait several minutes before calling upon the Forgotten Arbiter.</span>"
		return 0
	return 1

/datum/clockwork_scripture/invoke_nzcrentr/scripture_effects()
	new/obj/effect/clockwork/general_marker/nzcrentr(get_turf(invoker))
	clockwork_generals_invoked["nzcrentr"] = TRUE
	invoker.visible_message("<span class='warning'>[invoker] begins to radiate a blinding light!</span>", \
	"<span class='heavy_brass'>\"Gur obff fnlf vg'f bxnl gb qb guvf. Qba'g oynzr zr vs lbh qvr sebz vg.\"</span>\n\
	<span class='userdanger'>You feel limitless power surging through you!</span>")
	playsound(invoker, 'sound/magic/lightning_chargeup.ogg', 100, 0)
	animate(invoker, color = list(rgb(255, 255, 255), rgb(255, 255, 255), rgb(255, 255, 255), rgb(0,0,0)), time = 88) //Gradual advancement to extreme brightness
	spawn(88)
		invoker.visible_message("<span class='warning'>Massive bolts of energy emerge from across [invoker]'s body!</span>", \
		"<span class='userdanger'>TOO... MUCH! CAN'T... TAKE IT!</span>")
		playsound(invoker, 'sound/magic/lightningbolt.ogg', 50, 0)
		animate(invoker, color = initial(invoker.color), time = 10)
		for(var/mob/living/L in range(5, invoker))
			if(is_servant_of_ratvar(L))
				continue
			invoker.Beam(L, icon_state = "nzcrentrs_power", icon = 'icons/effects/beam.dmi', time = 5)
			L.electrocute_act(rand(30, 50), "Nzcrentr's power")
			L.Weaken(8)
			playsound(L, 'sound/magic/LightningShock.ogg', 50, 0)
	spawn(3000)
		clockwork_generals_invoked["nzcrentr"] = FALSE
	return 1



/datum/clockwork_scripture/invoke_inathneq //Invoke Inath-Neq, the Resonant Cogwheel: Grants a huge health boost to nearby servants that rapidly decreases to original levels.
	name = "Invoke Inath-Neq, the Resonant Cogwheel"
	desc = "Taps the limitless power of Inath-Neq, one of Ratvar's four generals. The benevolence of Inath-Neq will grant a massive maximum and current health boost to all nearby servants that \
	quickly returns itself to normal over the course of ten seconds."
	invocations = list("V pnyy hcba lbh, Inath-Neq!!", "Yrg gur Erfbanag Pbtf ghea bapr zber!!", "Tenag zr naq zl nyyvrf gur fgeratgu gb inadhvfu bhe sbrf!!")
	channel_time = 150
	required_components = list("vanguard_cogwheel" = 6, "guvax_capacitor" = 3, "replicant_alloy" = 3, "hierophant_ansible" = 3)
	usage_tip = "Also provides stun immunity during its duration."
	tier = SCRIPTURE_REVENANT

/datum/clockwork_scripture/invoke_inathneq/check_special_requirements()
	if(clockwork_generals_invoked["inath-neq"])
		invoker << "<font color='#1E8CE1'><b><i>\"V pnaabg yraq lbh zl nvq lrg, punzcvba. Cyrnfr or pnershy.\"</b></i></font>\n\
		<span class='warning'>Inath-Neq has already been invoked recently! You must wait several minutes before calling upon the Resonant Cogwheel.</span>"
		return 0
	return 1

/datum/clockwork_scripture/invoke_inathneq/scripture_effects()
	new/obj/effect/clockwork/general_marker/inathneq(get_turf(invoker))
	clockwork_generals_invoked["inath-neq"] = TRUE
	if(invoker.real_name == "Lucio")
		invoker.say("Aww, let's break it DOWN!!")
	var/list/affected_servants = list()
	for(var/mob/living/L in range(7, invoker))
		if(!is_servant_of_ratvar(L) || L.stat == DEAD)
			continue
		L << "<font color='#1E8CE1'><b><i>\"V yraq lbh zl nvq, punzcvba! Yrg tybel thvqr lbhe oybjf!\"</b></i></font>\n\
		<span class='notice'>Inath-Neq's power flows through you!</span>"
		L.maxHealth += 500
		L.health += 500
		L.color = "#1E8CE1"
		L.stun_absorption = TRUE
		spawn(0)
			animate(invoker, color = initial(invoker.color), time = 100)
		affected_servants += L
	for(var/i in 1 to 10)
		sleep(10)
		for(var/mob/living/L in affected_servants)
			L.maxHealth -= 50
			L.health -= 50
			if(L.maxHealth == initial(L.maxHealth))
				L.stun_absorption = FALSE
	spawn(3000)
		clockwork_generals_invoked["inath-neq"] = FALSE
	return 1



/datum/clockwork_scripture/ark_of_the_clockwork_justiciar //Ark of the Clockwork Justiciar: Creates a Gateway to the Celestial Derelict.
	name = "Ark of the Clockwork Justiciar"
	desc = "Pulls from the power of all of Ratvar's servants and generals to construct a massive machine used to tear apart a rift in spacetime to the Celestial Derelict. This gateway will \
	call forth Ratvar from his exile after some time."
	invocations = list("NEZBERE! SEVTUG! NZCRENTR! INATH-NEQ! V PNYY HCBA LBH!!", \
	"GUR GVZR UNF PBZR SBE BHE ZNFGRE GB OERNX GUR PUNVAF BS RKVYR!!", \
	"YRAQ HF LBHE NVQ! RATVAR PBZRF!!")
	channel_time = 150
	required_components = list("belligerent_eye" = 10, "vanguard_cogwheel" = 10, "guvax_capacitor" = 10, "replicant_alloy" = 10, "hierophant_ansible" = 10)
	invokers_required = 4
	multiple_invokers_used = TRUE
	usage_tip = "The gateway is completely vulnerable to attack during its five-minute duration. In addition to preventing shuttle departure, it will periodically give indication of its general \
	position to everyone on the station as well as being loud enough to be heard throughout the entire sector. Defend it with your life!"
	tier = SCRIPTURE_JUDGEMENT

/datum/clockwork_scripture/ark_of_the_clockwork_justiciar/check_special_requirements()
	if(invoker.z != ZLEVEL_STATION)
		invoker << "<span class='warning'>You must be on the station to activate the Ark!</span>"
		return 0
	if(ticker.mode.clockwork_objective != "gateway")
		invoker << "<span class='warning'>As painful as it is, Ratvar's will is not to be freed!</span>"
		return 0
	return 1

/datum/clockwork_scripture/ark_of_the_clockwork_justiciar/scripture_effects()
	var/turf/T = get_turf(invoker)
	new/obj/effect/clockwork/general_marker/nezbere(T)
	T.visible_message("<span class='heavy_brass'>\"Ratvar! Pbzr sbegu!\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 20, 0)
	sleep(10)
	new/obj/effect/clockwork/general_marker/sevtug(T)
	T.visible_message("<font color='#AF0AAF'><b><i>\"Ratvar! Pbzr sbegu!\"</i></b></font>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 30, 0)
	sleep(10)
	new/obj/effect/clockwork/general_marker/nzcrentr(T)
	T.visible_message("<span class='heavy_brass'>\"Ratvar! Pbzr sbegu!\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 40, 0)
	sleep(10)
	new/obj/effect/clockwork/general_marker/inathneq(T)
	T.visible_message("<font color='#1E8CE1'><b><i>\"Ratvar! Pbzr sbegu!\"</i></b></font>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 50, 0)
	sleep(10)
	new/obj/structure/clockwork/massive/celestial_gateway(T)
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 100, 0)
	return 1
