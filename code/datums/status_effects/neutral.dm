//entirely neutral or internal status effects go here

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/obj/screen/alert/status_effect/in_love
	name = "In Love"
	desc = "You feel so wonderfully in love!"
	icon_state = "in_love"

/datum/status_effect/in_love
	id = "in_love"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /obj/screen/alert/status_effect/in_love
	var/mob/living/date

/datum/status_effect/in_love/on_creation(mob/living/new_owner, mob/living/love_interest)
	. = ..()
	if(.)
		date = love_interest
		linked_alert.desc = "You're in love with [date.real_name]! How lovely."

/datum/status_effect/in_love/tick()
	if(date)
		new /obj/effect/temp_visual/love_heart/invisible(date.drop_location(), owner)

/datum/status_effect/throat_soothed
	id = "throat_soothed"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/throat_soothed/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/throat_soothed/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/bounty
	id = "bounty"
	status_type = STATUS_EFFECT_UNIQUE
	var/mob/living/rewarded

/datum/status_effect/bounty/on_creation(mob/living/new_owner, mob/living/caster)
	. = ..()
	if(.)
		rewarded = caster

/datum/status_effect/bounty/on_apply()
	to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>You have been marked for death by [rewarded]. If you die, they will be rewarded.</span>")
	playsound(owner, 'sound/weapons/gun/shotgun/rack.ogg', 75, FALSE)
	return ..()

/datum/status_effect/bounty/tick()
	if(owner.stat == DEAD)
		rewards()
		qdel(src)

/datum/status_effect/bounty/proc/rewards()
	if(rewarded && rewarded.mind && rewarded.stat != DEAD)
		to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>Bounty claimed.</span>")
		playsound(owner, 'sound/weapons/gun/shotgun/shot.ogg', 75, FALSE)
		to_chat(rewarded, "<span class='greentext'>You feel a surge of mana flow into you!</span>")
		for(var/obj/effect/proc_holder/spell/spell in rewarded.mind.spell_list)
			spell.charge_counter = spell.charge_max
			spell.recharging = FALSE
			spell.update_icon()
		rewarded.adjustBruteLoss(-25)
		rewarded.adjustFireLoss(-25)
		rewarded.adjustToxLoss(-25)
		rewarded.adjustOxyLoss(-25)
		rewarded.adjustCloneLoss(-25)

// heldup is for the person being aimed at
/datum/status_effect/heldup
	id = "heldup"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /obj/screen/alert/status_effect/heldup

/obj/screen/alert/status_effect/heldup
	name = "Held Up"
	desc = "Making any sudden moves would probably be a bad idea!"
	icon_state = "aimed"

// holdup is for the person aiming
/datum/status_effect/holdup
	id = "holdup"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /obj/screen/alert/status_effect/holdup

/obj/screen/alert/status_effect/holdup
	name = "Holding Up"
	desc = "You're currently pointing a gun at someone."
	icon_state = "aimed"

// this status effect is used to negotiate the high-fiving capabilities of all concerned parties
/datum/status_effect/high_fiving
	id = "high_fiving"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// The carbons who were offered the ability to partake in the high-five
	var/list/possible_takers
	/// The actual slapper item
	var/obj/item/slapper/slap_item

/datum/status_effect/high_fiving/on_creation(mob/living/new_owner, obj/item/slap)
	. = ..()
	if(!.)
		return

	slap_item = slap
	owner.visible_message("<span class='notice'>[owner] raises [owner.p_their()] arm, looking for a high-five!</span>", \
		"<span class='notice'>You post up, looking for a high-five!</span>", null, 2)

	for(var/mob/living/carbon/possible_taker in orange(1, owner))
		if(!owner.CanReach(possible_taker) || possible_taker.incapacitated())
			continue
		register_candidate(possible_taker)

	if(!possible_takers) // in case we tried high-fiving with only a dead body around or something
		owner.visible_message("<span class='danger'>[owner] realizes no one within range is actually capable of high-fiving, lowering [owner.p_their()] arm in shame...</span>", \
			"<span class='warning'>You realize a moment too late that no one within range is actually capable of high-fiving you, oof...</span>", null, 2)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five_alone)
		qdel(src)
		return

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/check_owner_in_range)
	RegisterSignal(slap_item, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED), .proc/dropped_slap)
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE_MORE, .proc/check_fake_out)

/datum/status_effect/high_fiving/Destroy()
	QDEL_NULL(slap_item)
	for(var/i in possible_takers)
		var/mob/living/carbon/lost_hope = i
		remove_candidate(lost_hope)
	LAZYCLEARLIST(possible_takers)
	return ..()

/// Hook up the specified carbon mob for possible high-fiving, give them the alert and signals and all
/datum/status_effect/high_fiving/proc/register_candidate(mob/living/carbon/possible_candidate)
	var/obj/screen/alert/highfive/G = possible_candidate.throw_alert("[owner]", /obj/screen/alert/highfive)
	if(!G)
		return
	LAZYADD(possible_takers, possible_candidate)
	RegisterSignal(possible_candidate, COMSIG_MOVABLE_MOVED, .proc/check_taker_in_range)
	G.setup(possible_candidate, owner, slap_item)

/// Remove the alert and signals for the specified carbon mob
/datum/status_effect/high_fiving/proc/remove_candidate(mob/living/carbon/removed_candidate)
	removed_candidate.clear_alert("[owner]")
	LAZYREMOVE(possible_takers, removed_candidate)
	UnregisterSignal(removed_candidate, COMSIG_MOVABLE_MOVED)

/// We failed to high-five broh, either because there's no one viable next to us anymore, or we lost the slapper, or what
/datum/status_effect/high_fiving/proc/fail()
	owner.visible_message("<span class='danger'>[owner] slowly lowers [owner.p_their()] arm, realizing no one will high-five [owner.p_them()]! How embarassing...</span>", \
		"<span class='warning'>You realize the futility of continuing to wait for a high-five, and lower your arm...</span>", null, 2)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/left_hanging)
	qdel(src)

/// Yeah broh! This is where we do the high-fiving (or high-tenning :o)
/datum/status_effect/high_fiving/proc/we_did_it(mob/living/carbon/successful_taker)
	var/open_hands_taker
	var/slappers_owner
	for(var/i in successful_taker.held_items) // see how many hands the taker has open for high'ing
		if(isnull(i))
			open_hands_taker++

	if(!open_hands_taker)
		to_chat(successful_taker, "<span class='warning'>You can't high-five [owner] with no open hands!</span>")
		SEND_SIGNAL(successful_taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five_full_hand) // not so successful now!
		return

	for(var/i in owner.held_items)
		var/obj/item/slapper/slap_check = i
		if(istype(slap_check))
			slappers_owner++

	if(!slappers_owner) // THE PRANKAGE
		too_slow_p1(successful_taker)
		return

	if(slappers_owner >= 2) // we only check this if it's already established the taker has 2+ hands free
		owner.visible_message("<span class='notice'>[successful_taker] enthusiastically high-tens [owner]!</span>", "<span class='nicegreen'>Wow! You're high-tenned [successful_taker]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", ignored_mobs=successful_taker)
		to_chat(successful_taker, "<span class='nicegreen'>You give high-tenning [owner] your all!</span>")
		playsound(owner, 'sound/weapons/slap.ogg', 100, TRUE, 1)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_ten)
		SEND_SIGNAL(successful_taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_ten)
	else
		owner.visible_message("<span class='notice'>[successful_taker] high-fives [owner]!</span>", "<span class='nicegreen'>All right! You're high-fived by [successful_taker]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", ignored_mobs=successful_taker)
		to_chat(successful_taker, "<span class='nicegreen'>You high-five [owner]!</span>")
		playsound(owner, 'sound/weapons/slap.ogg', 50, TRUE, -1)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five)
		SEND_SIGNAL(successful_taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five)
	qdel(src)

/// If we don't have any slappers in hand when someone goes to high-five us, we prank the hell out of them
/datum/status_effect/high_fiving/proc/too_slow_p1(mob/living/carbon/rube)
	owner.visible_message("<span class='notice'>[rube] rushes in to high-five [owner], but-</span>", "<span class='nicegreen'>[rube] falls for your trick just as planned, lunging for a high-five that no longer exists! Classic!</span>", ignored_mobs=rube)
	to_chat(rube, "<span class='nicegreen'>You go in for [owner]'s high-five, but-</span>")
	addtimer(CALLBACK(src, .proc/too_slow_p2, rube), 0.5 SECONDS)

/// Part two of the ultimate prank
/datum/status_effect/high_fiving/proc/too_slow_p2(mob/living/carbon/rube)
	if(!owner || !rube)
		qdel(src)
		return
	owner.visible_message("<span class='danger'>[owner] pulls away from [rube]'s slap at the last second, dodging the high-five entirely!</span>", "<span class='nicegreen'>[rube] fails to make contact with your hand, making an utter fool of [rube.p_them()]self!</span>", "<span class='hear'>You hear a disappointing sound of flesh not hitting flesh!</span>", ignored_mobs=rube)
	var/all_caps_for_emphasis = uppertext("NO! [owner] PULLS [owner.p_their()] HAND AWAY FROM YOURS! YOU'RE TOO SLOW!")
	to_chat(rube, "<span class='userdanger'>[all_caps_for_emphasis]</span>")
	playsound(owner, 'sound/weapons/thudswoosh.ogg', 100, TRUE, 1)
	rube.Knockdown(1 SECONDS)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/down_low)
	SEND_SIGNAL(rube, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/too_slow)
	qdel(src)

/// If someone examine_more's us while we don't have a slapper in hand, it'll tip them off to our trickster ways
/datum/status_effect/high_fiving/proc/check_fake_out(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!slap_item)
		examine_list += "<span class='warning'>[owner]'s arm appears tensed up, as if [owner.p_they()] plan on pulling it back suddenly...</span>\n"

/// One of our possible takers moved, see if they left us hanging
/datum/status_effect/high_fiving/proc/check_taker_in_range(mob/living/carbon/taker)
	SIGNAL_HANDLER
	if(owner.CanReach(taker) && !taker.incapacitated())
		return

	to_chat(taker, "<span class='warning'>You left [owner] hanging!</span>")
	remove_candidate(taker)
	if(!possible_takers)
		fail()

/// The propositioner moved, see if anyone is out of range now
/datum/status_effect/high_fiving/proc/check_owner_in_range(mob/living/carbon/source)
	SIGNAL_HANDLER

	for(var/i in possible_takers)
		var/mob/living/carbon/checking_taker = i
		if(!istype(checking_taker) || !owner.CanReach(checking_taker) || checking_taker.incapacitated())
			remove_candidate(checking_taker)

	if(!possible_takers)
		fail()

/// Something fishy is going on here...
/datum/status_effect/high_fiving/proc/dropped_slap(obj/item/source)
	slap_item = null
