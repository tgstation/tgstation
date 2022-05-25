/datum/mutation/human/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telepathically communicate to others."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You can hear your own voice echoing in your mind!</span>"
	text_lose_indication = "<span class='notice'>You don't hear your mind echo anymore.</span>"
	difficulty = 12
	power = /obj/effect/proc_holder/spell/targeted/telepathy
	instability = 10
	energy_coeff = 1


/datum/mutation/human/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = "<span class='notice'>Smells begin to make more sense...</span>"
	text_lose_indication = "<span class='notice'>Your sense of smell goes back to normal.</span>"
	power = /obj/effect/proc_holder/spell/targeted/olfaction
	instability = 30
	synchronizer_coeff = 1
	var/reek = 200

/datum/mutation/human/olfaction/modify()
	if(power)
		var/obj/effect/proc_holder/spell/targeted/olfaction/S = power
		S.sensitivity = GET_MUTATION_SYNCHRONIZER(src)

/obj/effect/proc_holder/spell/targeted/olfaction
	name = "Remember the Scent"
	desc = "Get a scent off of the item you're currently holding to track it. With an empty hand, you'll track the scent you've remembered."
	charge_max = 100
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	action_icon_state = "nose"
	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()
	var/sensitivity = 1

/obj/effect/proc_holder/spell/targeted/olfaction/cast(list/targets, mob/living/user = usr)
	//can we sniff? is there miasma in the air?
	var/datum/gas_mixture/air = user.loc.return_air()
	var/list/cached_gases = air.gases

	if(cached_gases[/datum/gas/miasma])
		user.adjust_disgust(sensitivity * 45)
		to_chat(user, span_warning("With your overly sensitive nose, you get a whiff of stench and feel sick! Try moving to a cleaner area!"))
		return

	var/atom/sniffed = user.get_active_held_item()
	if(sniffed)
		var/old_target = tracking_target
		possible = list()
		var/list/prints = sniffed.return_fingerprints()
		if(prints)
			for(var/mob/living/carbon/C in GLOB.carbon_list)
				if(prints[md5(C.dna.unique_identity)])
					possible |= C
		if(!length(possible))
			to_chat(user,span_warning("Despite your best efforts, there are no scents to be found on [sniffed]..."))
			return
		tracking_target = tgui_input_list(user, "Scent to remember", "Scent Tracking", sort_names(possible))
		if(isnull(tracking_target))
			if(isnull(old_target))
				to_chat(user,span_warning("You decide against remembering any scents. Instead, you notice your own nose in your peripheral vision. This goes on to remind you of that one time you started breathing manually and couldn't stop. What an awful day that was."))
				return
			tracking_target = old_target
			on_the_trail(user)
			return
		to_chat(user,span_notice("You pick up the scent of [tracking_target]. The hunt begins."))
		on_the_trail(user)
		return

	if(!tracking_target)
		to_chat(user,span_warning("You're not holding anything to smell, and you haven't smelled anything you can track. You smell your skin instead; it's kinda salty."))
		return

	on_the_trail(user)

/obj/effect/proc_holder/spell/targeted/olfaction/proc/on_the_trail(mob/living/user)
	if(!tracking_target)
		to_chat(user,span_warning("You're not tracking a scent, but the game thought you were. Something's gone wrong! Report this as a bug."))
		return
	if(tracking_target == user)
		to_chat(user,span_warning("You smell out the trail to yourself. Yep, it's you."))
		return
	if(usr.z < tracking_target.z)
		to_chat(user,span_warning("The trail leads... way up above you? Huh. They must be really, really far away."))
		return
	else if(usr.z > tracking_target.z)
		to_chat(user,span_warning("The trail leads... way down below you? Huh. They must be really, really far away."))
		return
	var/direction_text = "[dir2text(get_dir(usr, tracking_target))]"
	if(direction_text)
		to_chat(user,span_notice("You consider [tracking_target]'s scent. The trail leads <b>[direction_text].</b>"))

/datum/mutation/human/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Your throat is burning!</span>"
	text_lose_indication = "<span class='notice'>Your throat is cooling down.</span>"
	power = /obj/effect/proc_holder/spell/cone/staggered/firebreath
	instability = 30
	energy_coeff = 1
	power_coeff = 1

/datum/mutation/human/firebreath/modify()
	// If we have a power chromosome...
	if(power && GET_MUTATION_POWER(src) > 1)
		var/obj/effect/proc_holder/spell/cone/staggered/firebreath/our_spell = power
		our_spell.cone_levels += 2 // Cone fwooshes further, and...
		our_spell.self_throw_range += 1 // the breath throws the user back more


/obj/effect/proc_holder/spell/cone/staggered/firebreath
	name = "Fire Breath"
	desc = "You breathe a cone of fire directly in front of you."
	school = SCHOOL_EVOCATION
	invocation = ""
	invocation_type = INVOCATION_NONE
	charge_max = 400
	clothes_req = FALSE
	range = 20
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	still_recharging_msg = "<span class='warning'>You can't muster any flames!</span>"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises
	respect_density = TRUE
	cone_levels = 3
	antimagic_flags = NONE // cannot be restricted or blocked by antimagic
	/// The range our user is thrown backwards after casting the spell
	var/self_throw_range = 1

/obj/effect/proc_holder/spell/cone/staggered/firebreath/before_cast(list/targets)
	. = ..()
	if(!iscarbon(usr))
		return

	var/mob/living/carbon/our_lizard = usr
	if(!our_lizard.is_mouth_covered())
		return

	our_lizard.adjust_fire_stacks(cone_levels)
	our_lizard.ignite_mob()
	to_chat(our_lizard, span_warning("Something in front of your mouth catches fire!"))

/obj/effect/proc_holder/spell/cone/staggered/firebreath/cast(list/targets, mob/user)
	. = ..()
	// When casting, throw them backwards a few tiles.
	var/original_dir = user.dir
	user.throw_at(get_edge_target_turf(user, turn(user.dir, 180)), range = self_throw_range, speed = 2, gentle = TRUE)
	//Try to set us to our original direction after, so we don't end up backwards.
	user.setDir(original_dir)

// Makes the cone shoot out into a 3 wide column of flames.
/obj/effect/proc_holder/spell/cone/staggered/firebreath/calculate_cone_shape(current_level)
	return (2 * current_level) - 1

/obj/effect/proc_holder/spell/cone/staggered/firebreath/do_turf_cone_effect(turf/target_turf, level)
	// Further turfs experience less exposed_temperature and exposed_volume
	new /obj/effect/hotspot(target_turf) // for style
	target_turf.hotspot_expose(max(500, 900 - (100 * level)), max(50, 200 - (50 * level)), 1)

/obj/effect/proc_holder/spell/cone/staggered/firebreath/do_mob_cone_effect(mob/living/target_mob, level)
	// Further out targets take less immediate burn damage and get less fire stacks.
	// The actual burn damage application is not blocked by fireproofing, like space dragons.
	target_mob.apply_damage(max(10, 40 - (5 * level)), BURN, spread_damage = TRUE)
	target_mob.adjust_fire_stacks(max(2, 5 - level))
	target_mob.ignite_mob()

/obj/effect/proc_holder/spell/cone/staggered/firebreath/do_obj_cone_effect(obj/target_obj, level)
	// Further out objects experience less exposed_temperature and exposed_volume
	target_obj.fire_act(max(500, 900 - (100 * level)), max(50, 200 - (50 * level)))

/datum/mutation/human/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>You feel a heavy, dull force just beyond the walls watching you.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/void
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/human/void/on_life(delta_time, times_fired)
	if(!isturf(owner.loc))
		return
	if(DT_PROB((0.25+((100-dna.stability)/40)) * GET_MUTATION_SYNCHRONIZER(src), delta_time)) //very rare, but enough to annoy you hopefully. +0.5 probability for every 10 points lost in stability
		new /obj/effect/immortality_talisman/void(get_turf(owner), owner)

/obj/effect/proc_holder/spell/self/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	school = SCHOOL_EVOCATION
	clothes_req = FALSE
	charge_max = 600
	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = INVOCATION_SHOUT
	action_icon_state = "void_magnet"

/obj/effect/proc_holder/spell/self/void/can_cast(mob/user = usr)
	. = ..()
	if(!isturf(user.loc))
		return FALSE

/obj/effect/proc_holder/spell/self/void/cast(list/targets, mob/user = usr)
	. = ..()
	new /obj/effect/immortality_talisman/void(get_turf(user), user)

/datum/mutation/human/self_amputation
	name = "Autotomy"
	desc = "Allows a creature to voluntary discard a random appendage."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your joints feel loose.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/self_amputation

	energy_coeff = 1
	synchronizer_coeff = 1

/obj/effect/proc_holder/spell/self/self_amputation
	name = "Drop a limb"
	desc = "Concentrate to make a random limb pop right off your body."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 100
	action_icon_state = "autotomy"

/obj/effect/proc_holder/spell/self/self_amputation/cast(list/targets, mob/user = usr)
	if(!iscarbon(user))
		return

	var/mob/living/carbon/C = user
	if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
		return

	var/list/parts = list()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.body_part != HEAD && BP.body_part != CHEST)
			if(BP.dismemberable)
				parts += BP
	if(!length(parts))
		to_chat(usr, span_notice("You can't shed any more limbs!"))
		return

	var/obj/item/bodypart/BP = pick(parts)
	BP.dismember()

/datum/mutation/human/tongue_spike
	name = "Tongue Spike"
	desc = "Allows a creature to voluntary shoot their tongue out as a deadly weapon."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your feel like you can throw your voice.</span>"
	instability = 15
	power = /obj/effect/proc_holder/spell/self/tongue_spike

	energy_coeff = 1
	synchronizer_coeff = 1

/obj/effect/proc_holder/spell/self/tongue_spike
	name = "Launch spike"
	desc = "Shoot your tongue out in the direction you're facing, embedding it and dealing damage until they remove it."
	clothes_req = FALSE
	human_req = TRUE
	charge_max = 100
	action_icon = 'icons/mob/actions/actions_genetic.dmi'
	action_icon_state = "spike"
	var/spike_path = /obj/item/hardened_spike

/obj/effect/proc_holder/spell/self/tongue_spike/cast(list/targets, mob/user = usr)
	if(!iscarbon(user))
		return

	var/mob/living/carbon/C = user
	if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
		return
	var/obj/item/organ/tongue/tongue
	for(var/org in C.internal_organs)
		if(istype(org, /obj/item/organ/tongue))
			tongue = org
			break

	if(!tongue)
		to_chat(C, span_notice("You don't have a tongue to shoot!"))
		return

	tongue.Remove(C, special = TRUE)
	var/obj/item/hardened_spike/spike = new spike_path(get_turf(C), C)
	tongue.forceMove(spike)
	spike.throw_at(get_edge_target_turf(C,C.dir), 14, 4, C)

/obj/item/hardened_spike
	name = "biomass spike"
	desc = "Hardened biomass, shaped into a spike. Very pointy!"
	icon_state = "tonguespike"
	force = 2
	throwforce = 15 //15 + 2 (WEIGHT_CLASS_SMALL) * 4 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = i didnt do the math
	throw_speed = 4
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 100, "embedded_fall_chance" = 0, "embedded_ignore_throwspeed_threshold" = TRUE)
	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_POINTY
	custom_materials = list(/datum/material/biomass = 500)
	var/mob/living/carbon/human/fired_by
	/// if we missed our target
	var/missed = TRUE

/obj/item/hardened_spike/Initialize(mapload, firedby)
	. = ..()
	fired_by = firedby
	addtimer(CALLBACK(src, .proc/checkembedded), 5 SECONDS)

/obj/item/hardened_spike/proc/checkembedded()
	if(missed)
		unembedded()

/obj/item/hardened_spike/embedded(atom/target)
	if(isbodypart(target))
		missed = FALSE

/obj/item/hardened_spike/unembedded()
	var/turf/T = get_turf(src)
	visible_message(span_warning("[src] cracks and twists, changing shape!"))
	for(var/i in contents)
		var/obj/o = i
		o.forceMove(T)
	qdel(src)

/datum/mutation/human/tongue_spike/chem
	name = "Chem Spike"
	desc = "Allows a creature to voluntary shoot their tongue out as biomass, allowing a long range transfer of chemicals."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your feel like you can really connect with people by throwing your voice.</span>"
	instability = 15
	locked = TRUE
	power = /obj/effect/proc_holder/spell/self/tongue_spike/chem
	energy_coeff = 1
	synchronizer_coeff = 1

/obj/effect/proc_holder/spell/self/tongue_spike/chem
	name = "Launch chem spike"
	desc = "Shoot your tongue out in the direction you're facing, embedding it for a very small amount of damage. While the other person has the spike embedded, you can transfer your chemicals to them."
	action_icon_state = "spikechem"
	spike_path = /obj/item/hardened_spike/chem

/obj/item/hardened_spike/chem
	name = "chem spike"
	desc = "Hardened biomass, shaped into... something."
	icon_state = "tonguespikechem"
	throwforce = 2 //2 + 2 (WEIGHT_CLASS_SMALL) * 0 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = i didnt do the math again but very low or smthin
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 100, "embedded_fall_chance" = 0, "embedded_pain_chance" = 0, "embedded_ignore_throwspeed_threshold" = TRUE) //never hurts once it's in you
	var/been_places = FALSE
	var/datum/action/innate/send_chems/chems

/obj/item/hardened_spike/chem/embedded(mob/living/carbon/human/embedded_mob)
	if(been_places)
		return
	been_places = TRUE
	chems = new
	chems.transfered = embedded_mob
	chems.spikey = src
	to_chat(fired_by, span_notice("Link established! Use the \"Transfer Chemicals\" ability to send your chemicals to the linked target!"))
	chems.Grant(fired_by)

/obj/item/hardened_spike/chem/unembedded()
	to_chat(fired_by, span_warning("Link lost!"))
	QDEL_NULL(chems)
	..()

/datum/action/innate/send_chems
	icon_icon = 'icons/mob/actions/actions_genetic.dmi'
	background_icon_state = "bg_spell"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "spikechemswap"
	name = "Transfer Chemicals"
	desc = "Send all of your reagents into whomever the chem spike is embedded in. One use."
	var/obj/item/hardened_spike/chem/spikey
	var/mob/living/carbon/human/transfered

/datum/action/innate/send_chems/Activate()
	if(!ishuman(transfered) || !ishuman(owner))
		return
	var/mob/living/carbon/human/transferer = owner

	to_chat(transfered, span_warning("You feel a tiny prick!"))
	transferer.reagents.trans_to(transfered, transferer.reagents.total_volume, 1, 1, 0, transfered_by = transferer)

	var/obj/item/bodypart/L = spikey.checkembedded()

	//this is where it would deal damage, if it transfers chems it removes itself so no damage
	spikey.forceMove(get_turf(L))
	transfered.visible_message(span_notice("[spikey] falls out of [transfered]!"))

//spider webs
/datum/mutation/human/webbing
	name = "Webbing Production"
	desc = "Allows the user to lay webbing, and travel through it."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your skin feels webby.</span>"
	instability = 15
	power = /obj/effect/proc_holder/spell/self/lay_genetic_web

/datum/mutation/human/webbing/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_WEB_WEAVER, GENETIC_MUTATION)

/datum/mutation/human/webbing/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_WEB_WEAVER, GENETIC_MUTATION)

/obj/effect/proc_holder/spell/self/lay_genetic_web
	name = "Lay Web"
	desc = "Drops a web. Only you will be able to traverse your web easily, making it pretty good for keeping you safe."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 4 SECONDS //the same time to lay a web
	action_icon = 'icons/mob/actions/actions_genetic.dmi'
	action_icon_state = "lay_web"

/obj/effect/proc_holder/spell/self/lay_genetic_web/cast(list/targets, mob/user = usr)
	var/failed = FALSE
	if(!isturf(user.loc))
		to_chat(user, span_warning("You can't lay webs here!"))
		failed = TRUE
	var/turf/T = get_turf(user)
	var/obj/structure/spider/stickyweb/genetic/W = locate() in T
	if(W)
		to_chat(user, span_warning("There's already a web here!"))
		failed = TRUE
	if(failed)
		revert_cast(user)
		return FALSE

	user.visible_message(span_notice("[user] begins to secrete a sticky substance."),span_notice("You begin to lay a web."))
	if(!do_after(user, 4 SECONDS, target = T))
		to_chat(user, span_warning("Your web spinning was interrupted!"))
		return
	else
		new /obj/structure/spider/stickyweb/genetic(T, user)
