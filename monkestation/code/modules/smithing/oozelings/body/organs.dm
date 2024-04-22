/obj/item/organ/internal/eyes/jelly
	name = "photosensitive eyespots"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/eyes/roundstartslime
	name = "photosensitive eyespots"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/ears/jelly
	name = "core audiosomes"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/tongue/jelly
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/lungs/slime
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE
	safe_oxygen_min = 4 //We don't need much oxygen to subsist.

/obj/item/organ/internal/lungs/slime/on_life(seconds_per_tick, times_fired)
	. = ..()
	operated = FALSE

/obj/item/organ/internal/liver/slime
	name = "endoplasmic reticulum"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/liver/slime/on_life(seconds_per_tick, times_fired)
	. = ..()
	operated = FALSE

/obj/item/organ/internal/stomach/slime
	name = "golgi apparatus"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/stomach/slime/on_life(seconds_per_tick, times_fired)
	. = ..()
	operated = FALSE

/obj/item/organ/internal/brain/slime
	name = "core"
	desc = "The center core of a slimeperson, technically their 'extract.' Where the cytoplasm, membrane, and organelles come from; perhaps this is also a mitochondria?"
	zone = BODY_ZONE_CHEST
	var/obj/effect/death_melt_type = /obj/effect/temp_visual/wizard/out
	var/core_color = COLOR_WHITE
	icon = 'monkestation/code/modules/smithing/icons/oozeling.dmi'
	icon_state = "slime_core"
	var/core_ejected = FALSE
	var/gps_active = TRUE

	var/datum/dna/stored_dna

	var/list/stored_items = list()

	var/rebuilt = TRUE
	var/coredeath = TRUE

/obj/item/organ/internal/brain/slime/Initialize(mapload, mob/living/carbon/organ_owner, list/examine_list)
	. = ..()
	colorize()
	transform.Scale(2, 2)

/obj/item/organ/internal/brain/slime/examine()
	. = ..()
	if(gps_active)
		. += span_notice("A dim light lowly pulsates from the center of the core, indicating an outgoing signal from a tracking microchip.")
		. += span_red("You could probably snuff that out.")
	. += span_hypnophrase("You remember that pouring plasma on it, if it's non-embodied, would make it regrow one.")

/obj/item/organ/internal/brain/slime/attack_self(mob/living/user) // Allows a player (presumably an antag) to deactivate the GPS signal on a slime core
	if(!(gps_active))
		return
	user.visible_message(span_warning("[user] begins jamming their hand into a slime core! Slime goes everywhere!"),
	span_notice("You jam your hand into the core, feeling for the densest point! Slime covers your arm."),
	span_notice("You hear an obscene squelching sound.")
	)
	playsound(user, 'sound/surgery/organ1.ogg', 80, TRUE)

	if(!do_after(user, 30 SECONDS, src))
		user.visible_message(span_warning("[user]'s hand slips out of the core before they can cause any harm!'"),
		span_warning("Your hand slips out of the goopy core before you can find it's densest point."),
		span_notice("You hear a resounding plop.")
		)
		return

	user.visible_message(span_warning("[user] crunches something deep in the slime core! It gradually stops glowing."),
	span_notice("You find the densest point, crushing it in your palm. The blinking light in the core slowly dissapates and items start to come out."),
	span_notice("You hear a wet crunching sound."))
	playsound(user, 'sound/effects/wounds/crackandbleed.ogg', 80, TRUE)

	drop_items_to_ground(get_turf(user))

/obj/item/organ/internal/brain/slime/Insert(mob/living/carbon/organ_owner, special = FALSE, drop_if_replaced, no_id_transfer)
	. = ..()
	if(!.)
		return
	colorize()
	core_ejected = FALSE
	RegisterSignal(organ_owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

/obj/item/organ/internal/brain/slime/proc/colorize()
	if(owner && isoozeling(owner))
		core_color = owner.dna.features["mcolor"]
		add_atom_colour(core_color, FIXED_COLOUR_PRIORITY)

/obj/item/organ/internal/brain/slime/proc/on_stat_change(mob/living/victim, new_stat, turf/loc_override)
	SIGNAL_HANDLER

	if(new_stat != DEAD)
		return

	addtimer(CALLBACK(src, PROC_REF(core_ejection), victim), 0) // explode them after the current proc chain ends, to avoid weirdness

/obj/item/organ/internal/brain/slime/proc/enable_coredeath()
	coredeath = TRUE
	if(owner)
		if(owner.stat != DEAD)
			return
		addtimer(CALLBACK(src, PROC_REF(core_ejection), owner), 0)

///////
/// CORE EJECTION PROC
/// Makes it so that when a slime dies, their core ejects and their body is qdel'd.

/obj/item/organ/internal/brain/slime/proc/core_ejection(mob/living/carbon/human/victim, new_stat, turf/loc_override)
	if(core_ejected || !coredeath)
		return
	if(!stored_dna)
		stored_dna = new

	victim.dna.copy_dna(stored_dna)
	core_ejected = TRUE
	victim.visible_message(span_warning("[victim]'s body completely dissolves, collapsing outwards!"), span_notice("Your body completely dissolves, collapsing outwards!"), span_notice("You hear liquid splattering."))
	var/turf/death_turf = get_turf(victim)

	var/list/items = list()
	items |= victim.get_equipped_items(TRUE)
	for(var/atom/movable/I as anything in items)
		victim.dropItemToGround(I)
		stored_items |= I
		I.forceMove(src)

	if(victim.get_organ_slot(ORGAN_SLOT_BRAIN) == src)
		Remove(victim)
	if(death_turf)
		forceMove(death_turf)
	src.wash(CLEAN_WASH)
	new death_melt_type(death_turf, victim.dir)

	do_steam_effects(death_turf)
	playsound(victim, 'sound/effects/blobattack.ogg', 80, TRUE)

	if(gps_active) // adding the gps signal if they have activated the ability
		AddComponent(/datum/component/gps, "[victim]'s Core")

	if(brainmob)
		var/datum/antagonist/changeling/target_ling = brainmob.mind?.has_antag_datum(/datum/antagonist/changeling)

		if(target_ling)
			if(target_ling.oozeling_revives > 0)
				target_ling.oozeling_revives--
				addtimer(CALLBACK(src, PROC_REF(rebuild_body)), 30 SECONDS)

		if(IS_BLOODSUCKER(brainmob))
			var/datum/antagonist/bloodsucker/target_bloodsucker = brainmob.mind.has_antag_datum(/datum/antagonist/bloodsucker)
			if(target_bloodsucker.bloodsucker_blood_volume >= target_bloodsucker.max_blood_volume * 0.4)
				addtimer(CALLBACK(src, PROC_REF(rebuild_body)), 30 SECONDS)
				target_bloodsucker.bloodsucker_blood_volume -= target_bloodsucker.max_blood_volume * 0.15

	rebuilt = FALSE
	Remove(victim)
	qdel(victim)

/obj/item/organ/internal/brain/slime/proc/do_steam_effects(turf/loc)
	var/datum/effect_system/steam_spread/steam = new()
	steam.set_up(10, FALSE, loc)
	steam.start()

///////
/// CHECK FOR REPAIR SECTION
/// Makes it so that when a slime's core has plasma poured on it, it builds a new body and moves the brain into it.

/obj/item/organ/internal/brain/slime/check_for_repair(obj/item/item, mob/user)
	if(damage && item.is_drainable() && item.reagents.has_reagent(/datum/reagent/toxin/plasma) && item.reagents.get_reagent_amount(/datum/reagent/toxin/plasma) >= 100) //attempt to heal the brain

		user.visible_message(span_notice("[user] starts to slowly pour the contents of [item] onto [src]. It seems to bubble and roil, beginning to stretch its cytoskeleton outwards..."), span_notice("You start to slowly pour the contents of [item] onto [src]. It seems to bubble and roil, beginning to stretch its membrane outwards..."))
		if(!do_after(user, 30 SECONDS, src))
			to_chat(user, span_warning("You failed to pour the contents of [item] onto [src]!"))
			return TRUE

		user.visible_message(span_notice("[user] pours the contents of [item] onto [src], causing it to form a proper cytoplasm and outer membrane."), span_notice("You pour the contents of [item] onto [src], causing it to form a proper cytoplasm and outer membrane."))
		item.reagents.clear_reagents() //removes the whole shit
		rebuild_body()
		return TRUE
	return FALSE

/obj/item/organ/internal/brain/slime/proc/drop_items_to_ground(turf/turf)
	for(var/atom/movable/item as anything in stored_items)
		item.forceMove(turf)
		stored_items -= item

/obj/item/organ/internal/brain/slime/proc/rebuild_body()
	if(rebuilt)
		return
	rebuilt = TRUE
	set_organ_damage(-maxHealth) //heals 2 damage per unit of mannitol, and by using "set_organ_damage", we clear the failing variable if that was up

	if(gps_active) // making sure the gps signal is removed if it's active on revival
		gps_active = FALSE
		qdel(GetComponent(/datum/component/gps))

	//we have the plasma. we can rebuild them.
	var/mob/living/carbon/human/new_body = new /mob/living/carbon/human(src.loc)

	new_body.underwear = "Nude"
	new_body.undershirt = "Nude" //Which undershirt the player wants
	new_body.socks = "Nude" //Which socks the player wants
	stored_dna.transfer_identity(new_body, transfer_SE=1)
	new_body.dna.features["mcolor"] = new_body.dna.features["mcolor"]
	new_body.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
	new_body.real_name = new_body.dna.real_name
	new_body.name = new_body.dna.real_name
	new_body.updateappearance(mutcolor_update=1)
	new_body.domutcheck()
	new_body.forceMove(get_turf(src))
	new_body.blood_volume = BLOOD_VOLUME_SAFE+60
	REMOVE_TRAIT(new_body, TRAIT_NO_TRANSFORM, REF(src))
	if(brainmob)
		SSquirks.AssignQuirks(new_body, brainmob.client)
	var/obj/item/organ/internal/brain/new_body_brain = new_body.get_organ_slot(ORGAN_SLOT_BRAIN)
	qdel(new_body_brain)
	src.forceMove(new_body)
	Insert(new_body)
	for(var/obj/item/bodypart/bodypart as anything in new_body.bodyparts)
		if(!istype(bodypart, /obj/item/bodypart/chest))
			qdel(bodypart)
			continue

	new_body.visible_message(span_warning("[new_body]'s torso \"forms\" from their core, yet to form the rest."))
	to_chat(owner, span_purple("Your torso fully forms out of your core, yet to form the rest."))

	if(brainmob)
		brainmob.mind.transfer_to(new_body)
		new_body.grab_ghost()

	drop_items_to_ground(get_turf(new_body))
