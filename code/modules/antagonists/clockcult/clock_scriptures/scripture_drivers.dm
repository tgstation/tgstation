/////////////
// DRIVERS //
/////////////


//Integration Cog: Creates an integration cog that can be inserted into APCs to passively siphon power.
/datum/clockwork_scripture/create_object/integration_cog
	descname = "Power Generation"
	name = "Integration Cog"
	desc = "Fabricates an integration cog, which can be used on an open APC to replace its innards and passively siphon its power."
	invocations = list("Take that which sustains them!")
	channel_time = 10
	power_cost = 10
	whispered = TRUE
	object_path = /obj/item/clockwork/integration_cog
	creator_message = "<span class='brass'>You form an integration cog, which can be inserted into an open APC to passively siphon power.</span>"
	usage_tip = "Tampering isn't visible unless the APC is opened. You can use the cog on a locked APC to unlock it."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 1
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Creates an integration cog, which can be used to siphon power from an open APC."


//Sigil of Transgression: Creates a sigil of transgression, which briefly stuns and applies Belligerent to the first non-servant to cross it.
/datum/clockwork_scripture/create_object/sigil_of_transgression
	descname = "Trap, Stunning"
	name = "Sigil of Transgression"
	desc = "Wards a tile with a sigil, which will briefly stun the next non-Servant to cross it and apply Belligerent to them."
	invocations = list("Divinity, smite...", "...those who trespass here!")
	channel_time = 50
	power_cost = 50
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transgression
	creator_message = "<span class='brass'>A sigil silently appears below you. The next non-Servant to cross it will be smitten.</span>"
	usage_tip = "The sigil does not silence its victim, and is generally used to soften potential converts or would-be invaders."
	tier = SCRIPTURE_DRIVER
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Transgression, which will briefly stun and slow the next non-Servant to cross it."


//Sigil of Submission: Creates a sigil of submission, which converts one heretic above it after a delay.
/datum/clockwork_scripture/create_object/sigil_of_submission
	descname = "Trap, Conversion"
	name = "Sigil of Submission"
	desc = "Places a luminous sigil that will convert any non-Servants that remain on it for 8 seconds."
	invocations = list("Divinity, enlighten...", "...those who trespass here!")
	channel_time = 60
	power_cost = 125
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/submission
	creator_message = "<span class='brass'>A luminous sigil appears below you. Any non-Servants to cross it will be converted after 8 seconds if they do not move.</span>"
	usage_tip = "This is the primary conversion method, though it will not penetrate mindshield implants."
	tier = SCRIPTURE_DRIVER
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 3
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Submission, which will convert non-Servants that remain on it."


//Kindle: Charges the slab with blazing energy. It can be released to stun and silence a target.
/datum/clockwork_scripture/ranged_ability/kindle
	descname = "Short-Range Single-Target Stun"
	name = "Kindle"
	desc = "Charges your slab with divine energy, allowing you to overwhelm a target with Ratvar's light."
	invocations = list("Divinity, show them your light!")
	whispered = TRUE
	channel_time = 30
	power_cost = 125
	usage_tip = "The light can be used from up to two tiles away. Damage taken will GREATLY REDUCE the stun's duration."
	tier = SCRIPTURE_DRIVER
	primary_component = BELLIGERENT_EYE
	sort_priority = 4
	slab_overlay = "volt"
	ranged_type = /obj/effect/proc_holder/slab/kindle
	ranged_message = "<span class='brass'><i>You charge the clockwork slab with divine energy.</i>\n\
	<b>Left-click a target within melee range to stun!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 150
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Stuns and mutes a target from a short range."


//Hateful Manacles: Applies restraints from melee over several seconds. The restraints function like handcuffs and break on removal.
/datum/clockwork_scripture/ranged_ability/hateful_manacles
	descname = "Handcuffs"
	name = "Hateful Manacles"
	desc = "Forms replicant manacles around a target's wrists that function like handcuffs."
	invocations = list("Shackle the heretic!", "Break them in body and spirit!")
	channel_time = 15
	power_cost = 25
	whispered = TRUE
	usage_tip = "The manacles are about as strong as zipties, and break when removed."
	tier = SCRIPTURE_DRIVER
	primary_component = BELLIGERENT_EYE
	sort_priority = 5
	ranged_type = /obj/effect/proc_holder/slab/hateful_manacles
	slab_overlay = "hateful_manacles"
	ranged_message = "<span class='neovgre_small'><i>You charge the clockwork slab with divine energy.</i>\n\
	<b>Left-click a target within melee range to shackle!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 200
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Applies handcuffs to a struck target."


//Vanguard: Provides twenty seconds of stun immunity. At the end of the twenty seconds, 25% of all stuns absorbed are applied to the invoker.
/datum/clockwork_scripture/vanguard
	descname = "Self Stun Immunity"
	name = "Vanguard"
	desc = "Provides twenty seconds of stun immunity. At the end of the twenty seconds, the invoker is knocked down for the equivalent of 25% of all stuns they absorbed. \
	Excessive absorption will cause unconsciousness."
	invocations = list("Shield me...", "...from darkness!")
	channel_time = 30
	power_cost = 25
	usage_tip = "You cannot reactivate Vanguard while still shielded by it."
	tier = SCRIPTURE_DRIVER
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 6
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
	power_cost = 100
	usage_tip = "The Compromise is very fast to invoke, and will remove holy water from the target Servant."
	tier = SCRIPTURE_DRIVER
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 7
	quickbind = TRUE
	quickbind_desc = "Allows you to convert a Servant's brute, burn, and oxygen damage to half toxin damage.<br><b>Click your slab to disable.</b>"
	slab_overlay = "compromise"
	ranged_type = /obj/effect/proc_holder/slab/compromise
	ranged_message = "<span class='inathneq_small'><i>You charge the clockwork slab with healing power.</i>\n\
	<b>Left-click a fellow Servant or yourself to heal!\n\
	Click your slab to cancel.</b></span>"


//Abscond: Used to return to Reebe.
/datum/clockwork_scripture/abscond
	descname = "Return to Reebe"
	name = "Abscond"
	desc = "Yanks you through space, returning you to home base."
	invocations = list("As we bid farewell, and return to the stars...", "...we shall find our way home.")
	whispered = TRUE
	channel_time = 50
	power_cost = 5
	special_power_text = "POWERCOST to bring pulled creature"
	special_power_cost = ABSCOND_ABDUCTION_COST
	usage_tip = "This can't be used while on Reebe, for obvious reasons."
	tier = SCRIPTURE_DRIVER
	primary_component = GEIS_CAPACITOR
	sort_priority = 8
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Returns you to Reebe."
	var/client_color

/datum/clockwork_scripture/abscond/check_special_requirements()
	if(is_reebe(invoker.z))
		to_chat(invoker, "<span class='danger'>You're already at Reebe.</span>")
		return
	return TRUE

/datum/clockwork_scripture/abscond/recital()
	client_color = invoker.client.color
	animate(invoker.client, color = "#AF0AAF", time = 50)
	. = ..()

/datum/clockwork_scripture/abscond/scripture_effects()
	var/take_pulling = invoker.pulling && isliving(invoker.pulling) && get_clockwork_power(ABSCOND_ABDUCTION_COST)
	var/turf/T
	if(GLOB.ark_of_the_clockwork_justiciar)
		T = get_step(GLOB.ark_of_the_clockwork_justiciar, SOUTH)
	else
		T = get_turf(pick(GLOB.servant_spawns))
	invoker.visible_message("<span class='warning'>[invoker] flickers and phases out of existence!</span>", \
	"<span class='bold sevtug_small'>You feel a dizzying sense of vertigo as you're yanked back to Reebe!</span>")
	T.visible_message("<span class='warning'>[invoker] flickers and phases into existence!</span>")
	playsound(invoker, 'sound/magic/magic_missile.ogg', 50, TRUE)
	playsound(T, 'sound/magic/magic_missile.ogg', 50, TRUE)
	do_sparks(5, TRUE, invoker)
	do_sparks(5, TRUE, T)
	if(take_pulling)
		adjust_clockwork_power(-special_power_cost)
		invoker.pulling.forceMove(T)
	invoker.forceMove(T)
	if(invoker.client)
		animate(invoker.client, color = client_color, time = 25)

/datum/clockwork_scripture/abscond/scripture_fail()
	if(invoker && invoker.client)
		animate(invoker.client, color = client_color, time = 10)


//Replicant: Creates a new clockwork slab.
/datum/clockwork_scripture/create_object/replicant
	descname = "New Clockwork Slab"
	name = "Replicant"
	desc = "Creates a new clockwork slab."
	invocations = list("Metal, become greater!")
	channel_time = 10
	power_cost = 25
	whispered = TRUE
	object_path = /obj/item/clockwork/slab
	creator_message = "<span class='brass'>You copy a piece of replicant alloy and command it into a new slab.</span>"
	usage_tip = "This is inefficient as a way to produce components, as the slab produced must be held by someone with no other slabs to produce components."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 9
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Creates a new Clockwork Slab."


//Wraith Spectacles: Creates a pair of wraith spectacles, which grant xray vision but damage vision slowly.
/datum/clockwork_scripture/create_object/wraith_spectacles
	descname = "Limited Xray Vision Glasses"
	name = "Wraith Spectacles"
	desc = "Fabricates a pair of glasses which grant true sight but cause gradual vision loss."
	invocations = list("Show the truth of this world to me!")
	channel_time = 10
	power_cost = 50
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/wraith_spectacles
	creator_message = "<span class='brass'>You form a pair of wraith spectacles, which grant true sight but cause gradual vision loss.</span>"
	usage_tip = "\"True sight\" means that you are able to see through walls and in darkness."
	tier = SCRIPTURE_DRIVER
	space_allowed = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 10
	quickbind = TRUE
	quickbind_desc = "Creates a pair of Wraith Spectacles, which grant true sight but cause gradual vision loss."
