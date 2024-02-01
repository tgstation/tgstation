/datum/outfit/slasher
	name = "Slasher Outfit"
	suit = /obj/item/clothing/suit/apron/slasher
	uniform = /obj/item/clothing/under/color/random/slasher
	shoes = /obj/item/clothing/shoes/slasher_shoes
	mask = /obj/item/clothing/mask/gas/slasher

/datum/antagonist/slasher
	name = "\improper Slasher"
	show_in_antagpanel = TRUE
	roundend_category = "slashers"
	antagpanel_category = "Slasher"
	job_rank = ROLE_SLASHER
	antag_hud_name = "slasher"
	show_name_in_check_antagonists = TRUE
	hud_icon = 'monkestation/icons/mob/slasher.dmi'
	preview_outfit = /datum/outfit/slasher
	show_to_ghosts = TRUE

	///the linked machette that the slasher can summon even if destroyed and is unique to them
	var/obj/item/slasher_machette/linked_machette
	///toggles false/true if we are visible in order to breathe out or in
	var/breath_out = FALSE
	///rallys the amount of souls effects are based on this
	var/souls_sucked = 0
	///when we sucked our last soul in world time
	var/last_soul_sucked = 0
	///cooldown we should have for soul sucking without downside
	var/soul_digestion = 5 MINUTES
	///our current soul punishment state
	var/soul_punishment = 0
	///our cached brute_mod
	var/cached_brute_mod = 0
	///processes to heartbeat
	var/heartbeat_processes = 0
	///processes until wail if above punishment threshold
	var/wailing_processes = 0
	///our breath processes
	var/breath_processes = 0
	///list of mobs that have been given a overlay so we can remove later
	var/list/mobs_with_fullscreens = list()
	///this is needed because it double fires sometimes before finishing
	var/is_hudchecking = FALSE
	/// the mob we are stalking
	var/mob/living/carbon/human/stalked_human
	/// how close we are in % to finishing stalking
	var/stalk_precent = 0
	/// are we corporeal
	var/corporeal = TRUE
	///ALL Powers currently owned
	var/list/datum/action/cooldown/slasher/powers = list()

/datum/antagonist/slasher/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	ADD_TRAIT(current_mob, TRAIT_BATON_RESISTANCE, "slasher")
	ADD_TRAIT(current_mob, TRAIT_CLUMSY, "slasher")
	ADD_TRAIT(current_mob, TRAIT_DUMB, "slasher")
	ADD_TRAIT(current_mob, TRAIT_NODEATH, "slasher")
	ADD_TRAIT(current_mob, TRAIT_LIMBATTACHMENT, "slasher")

	var/mob/living/carbon/carbon = current_mob
	var/obj/item/organ/internal/eyes/shadow/shadow = new
	shadow.Insert(carbon, drop_if_replaced = FALSE)

	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))

	///abilities galore
	for(var/datum/action/cooldown/slasher/listed_slasher as anything in subtypesof(/datum/action/cooldown/slasher))
		var/datum/action/cooldown/slasher/new_ability = new listed_slasher
		new_ability.Grant(current_mob)
		powers |= new_ability

	var/mob/living/carbon/human/human = current_mob
	if(istype(human))
		human.equipOutfit(/datum/outfit/slasher)
	cached_brute_mod = human.dna.species.brutemod


/datum/antagonist/slasher/on_removal()
	. = ..()
	owner.current.remove_traits(list(TRAIT_BATON_RESISTANCE, TRAIT_CLUMSY, TRAIT_NODEATH, TRAIT_DUMB, TRAIT_LIMBATTACHMENT), "slasher")
	for(var/datum/action/cooldown/slasher/listed_slasher as anything in powers)
		listed_slasher.Remove(owner.current)

/datum/antagonist/slasher/proc/LifeTick(mob/living/source, seconds_per_tick, times_fired)
	if(corporeal)
		breath_processes++
		if(breath_processes >= 2)
			breath_processes = 0
			if(breath_out)
				source.emote("exhale")
				breath_out = FALSE
			else
				source.emote("inhale")
				breath_out = TRUE

	heartbeat_processes++
	if(heartbeat_processes >= 4)
		heartbeat_processes = 0
		for(var/mob/living/carbon/human in view(7, source))
			if(human == source)
				continue
			human.playsound_local(human, 'sound/health/slowbeat.ogg', 40, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)

	if(stalked_human)
		for(var/mob/living/carbon/human in view(7, source))
			if(stalked_human != human)
				continue
			if(stalked_human.stat == DEAD)
				failed_stalking()
			stalk_precent += (1 / 1.8)
		if(stalk_precent >= 100)
			finish_stalking()

	if(!is_hudchecking)
		is_hudchecking = TRUE
		var/list/starting_humans = list()
		starting_humans += mobs_with_fullscreens
		for(var/mob/living/carbon/human in view(7, source))
			if(!(human in mobs_with_fullscreens))
				mobs_with_fullscreens += human
				human.overlay_fullscreen("slasher_prox", /atom/movable/screen/fullscreen/nearby, 1)
			else
				starting_humans -= human

		if(length(starting_humans))
			for(var/mob/living/carbon/human in starting_humans)
				human.clear_fullscreen("slasher_prox", 15)
				mobs_with_fullscreens -= human
		is_hudchecking = FALSE

	for(var/obj/machinery/light/listed_light in view(3, source))
		if(prob(10))
			listed_light.break_light_tube()

	var/turf/TT = get_turf(source)
	var/turf/T = pick(RANGE_TURFS(4,TT))

	if(prob(5))
		new /obj/effect/gibspawner/generic(T)

	if(soul_punishment >= 2)
		wailing_processes++
		if(wailing_processes >= 8)
			wailing_processes = 0
			playsound(owner.current, 'monkestation/sound/voice/terror-cry.ogg', 50, falloff_exponent = 0, use_reverb = FALSE)
			owner.current.emote("wails")
			var/mob/living/carbon/human/human = owner.current
			human.blood_volume -= 10
			var/turf/turf = get_turf(human)
			var/list/blood_drop = list(human.get_blood_id() = 10)
			turf.add_liquid_list(blood_drop, FALSE, 300)

/datum/antagonist/slasher/proc/finish_stalking()
	to_chat(owner, span_boldwarning("You have finished spooking your victim, and have harvested part of their soul!"))
	if(linked_machette)
		linked_machette.force += 2.5
		linked_machette.throwforce += 2.5
	stalked_human = null

/datum/antagonist/slasher/proc/failed_stalking()
	to_chat(owner, span_boldwarning("You let your victim be taken before it was time!"))
	if(linked_machette)
		linked_machette.force -= 5
		linked_machette.throwforce -= 5
	stalked_human = null
