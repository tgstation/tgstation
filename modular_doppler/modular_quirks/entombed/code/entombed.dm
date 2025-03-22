/// How much damage should we be taking when the suit's been disabled a while?
#define ENTOMBED_TICK_DAMAGE 1.5

/datum/quirk/equipping/entombed
	name = "Entombed"
	desc = "You are permanently fused to (or otherwise reliant on) a single MOD unit that can never be removed from your person. If it runs out of charge or is turned off, you'll start to die!"
	gain_text = span_warning("Your exosuit is both prison and home.")
	lose_text = span_notice("At last, you're finally free from that horrible exosuit.")
	medical_record_text = "Patient is physiologically reliant on a MOD unit for homeostasis. Do not attempt removal."
	value = 0
	icon = FA_ICON_ARROW_CIRCLE_DOWN
	forced_items = list(/obj/item/mod/control/pre_equipped/entombed = list(ITEM_SLOT_BACK))
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_PROCESSES
	/// The modsuit we're stuck in
	var/obj/item/mod/control/pre_equipped/entombed/modsuit
	/// Has the player chosen to deploy-lock?
	var/deploy_locked = FALSE
	/// How long before they start taking damage when the suit's not active?
	var/life_support_failure_threshold = 1.5 MINUTES
	/// TimerID for our timeframe tracker
	var/life_support_timer
	/// Are we taking damage?
	var/life_support_failed = FALSE
	/// Alternate icon files for each modular skin
	var/list/modular_icon_files = list(
		"colonist" = 'modular_doppler/kahraman_equipment/icons/modsuits/mod.dmi',
		"moonlight" = 'modular_doppler/special_modsuits/icons/mod.dmi',
		"orbiter" = 'modular_doppler/special_modsuits/icons/mod.dmi',
	)
	/// Alternate icon files for each modular worn skin
	var/list/modular_worn_files = list(
		"colonist" = 'modular_doppler/kahraman_equipment/icons/modsuits/mod_worn.dmi',
		"moonlight" = 'modular_doppler/special_modsuits/icons/mod_worn.dmi',
		"orbiter" = 'modular_doppler/special_modsuits/icons/mod_worn.dmi',
	)
	/// Alternative icon files for each modular skin with a digi variant
	var/list/modular_worn_digi_files = list(
		"moonlight" = 'modular_doppler/special_modsuits/icons/mod_worn_digi.dmi',
		"orbiter" = 'modular_doppler/special_modsuits/icons/mod_worn_digi.dmi',
	)

/datum/quirk/equipping/entombed/process(seconds_per_tick)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if (!modsuit || life_support_failed)
		if (!HAS_TRAIT(human_holder, TRAIT_STASIS))
			// we've got no modsuit or life support and we're not on stasis. take damage ow
			human_holder.adjustToxLoss(ENTOMBED_TICK_DAMAGE * seconds_per_tick, updating_health = TRUE, forced = TRUE)
			human_holder.set_jitter_if_lower(10 SECONDS)

	if (!modsuit.active)
		if (!life_support_timer)
			//start the timer and let the player know
			life_support_timer = addtimer(CALLBACK(src, PROC_REF(life_support_failure), human_holder), life_support_failure_threshold, TIMER_STOPPABLE | TIMER_DELETE_ME)

			to_chat(human_holder, span_danger("Your physiology begins to erratically seize and twitch, bereft of your MODsuit's vital support. <b>Turn it back on as soon as you can!</b>"))
			human_holder.balloon_alert(human_holder, "suit life support warning!")
			human_holder.set_jitter_if_lower(life_support_failure_threshold) //give us some foley jitter
			return
	else
		if (life_support_timer)
			// clear our timer and let the player know everything's back to normal
			deltimer(life_support_timer)
			life_support_timer = null
			life_support_failed = FALSE

			to_chat(human_holder, span_notice("Relief floods your frame as your suit begins sustaining your life once more."))
			human_holder.balloon_alert(human_holder, "suit life support restored!")
			human_holder.adjust_jitter(-(life_support_failure_threshold / 2)) // clear half of it, wow, that was unpleasant

/datum/quirk/equipping/entombed/proc/life_support_failure()
	// Warn the player and begin the gradual dying process.
	var/mob/living/carbon/human/human_holder = quirk_holder

	human_holder.visible_message(span_danger("[human_holder] suddenly staggers, a dire pallor overtaking [human_holder.p_their()] features as a feeble 'breep' emanates from their suit..."), span_userdanger("Terror descends as your suit's life support system breeps feebly, and then goes horrifyingly silent."))
	human_holder.balloon_alert(human_holder, "SUIT LIFE SUPPORT FAILING!")
	playsound(human_holder, 'sound/effects/alert.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE) // OH GOD THE STRESS NOISE
	life_support_failed = TRUE

/datum/quirk/equipping/entombed/add_unique(client/client_source)
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if (istype(human_holder.back, /obj/item/mod/control/pre_equipped/entombed))
		modsuit = human_holder.back // link this up to the quirk for easy access

	if (isnull(modsuit))
		stack_trace("Entombed quirk couldn't create a fused MODsuit on [quirk_holder] and was force-removed.")
		qdel(src)
		return

	var/lock_deploy = client_source?.prefs.read_preference(/datum/preference/toggle/entombed_deploy_lock)
	if (!isnull(lock_deploy))
		deploy_locked = lock_deploy

	// set no dismember trait for deploy-locked dudes, i'm sorry, there's basically no better way to do this.
	// it's a pretty ample buff but i dunno what else to do...
	if (deploy_locked)
		ADD_TRAIT(human_holder, TRAIT_NODISMEMBER, QUIRK_TRAIT)

	// set all of our customization stuff from prefs, if we have it
	var/modsuit_skin = client_source?.prefs.read_preference(/datum/preference/choiced/entombed_skin)

	if (modsuit_skin == NONE)
		modsuit_skin = "civilian"

	modsuit.skin = LOWER_TEXT(modsuit_skin)

	var/modsuit_name = client_source?.prefs.read_preference(/datum/preference/text/entombed_mod_name)
	if (modsuit_name)
		modsuit.name = modsuit_name

	var/modsuit_desc = client_source?.prefs.read_preference(/datum/preference/text/entombed_mod_desc)
	if (modsuit_desc)
		modsuit.desc = modsuit_desc
		modsuit.AddElement(/datum/element/examined_when_worn)

	var/modsuit_skin_prefix = client_source?.prefs.read_preference(/datum/preference/text/entombed_mod_prefix)
	if (modsuit_skin_prefix)
		modsuit.theme.name = LOWER_TEXT(modsuit_skin_prefix)

	// ensure we're applying our config theme changes, just in case
	for(var/obj/item/part as anything in modsuit.get_parts())
		part.name = "[modsuit.theme.name] [initial(part.name)]"
		part.desc = "[initial(part.desc)] [modsuit.theme.desc]"
		for(var/potential_skin as anything in modular_icon_files)
			if(modsuit.skin == potential_skin)
				part.icon = modular_icon_files[modsuit.skin]
				if(length(part.bodyshape_icon_files))
					part.bodyshape_icon_files[BODYSHAPE_HUMANOID_T] = modular_worn_files[modsuit.skin]
					if(modsuit.skin in modular_worn_digi_files)
						if(istype(part, /obj/item/clothing/head/mod))
							part.bodyshape_icon_files[BODYSHAPE_SNOUTED_T] = modular_worn_digi_files[modsuit.skin]
						else
							part.bodyshape_icon_files[BODYSHAPE_DIGITIGRADE_T] = modular_worn_digi_files[modsuit.skin]
				part.worn_icon = modular_worn_files[modsuit.skin]
				modsuit.icon = modular_icon_files[modsuit.skin]
				modsuit.worn_icon = modular_worn_files[modsuit.skin]
	install_racial_features()
	install_skin_features(modsuit_skin)

	//transfer as many items across from our dropped backslot as we can. do this last incase something breaks
	if (force_dropped_items)
		var/obj/item/old_bag = locate() in force_dropped_items
		if (old_bag.atom_storage)
			old_bag.atom_storage.dump_content_at(modsuit, null, human_holder)

/datum/quirk/equipping/entombed/post_add()
	. = ..()
	// quickly deploy it on roundstart. we can't do this in add_unique because that gets called in the preview screen, which overwrites people's loadout stuff in suit/shoes/gloves slot. very unfun for them
	install_quirk_interaction_features() // have to do this here to ensure all traumas and the like from quirks are applied to our mob
	modsuit.quick_activation()

/datum/quirk/equipping/entombed/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if (deploy_locked && HAS_TRAIT_FROM(human_holder, TRAIT_NODISMEMBER, QUIRK_TRAIT))
		REMOVE_TRAIT(human_holder, TRAIT_NODISMEMBER, QUIRK_TRAIT)
	QDEL_NULL(modsuit)

/datum/quirk/equipping/entombed/proc/install_racial_features()
	// deploy specific racial features - ethereals get ethereal cores, plasmamen get free plasma stabilizer module
	if (!modsuit) // really don't know how this could ever happen but it's better than runtimes
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	if (isethereal(human_holder))
		var/obj/item/mod/core/ethereal/eth_core = new
		eth_core.install(modsuit)
	else if (isplasmaman(human_holder))
		var/obj/item/mod/module/plasma_stabilizer/entombed/plasma_stab = new
		modsuit.install(plasma_stab, human_holder)

/datum/quirk/equipping/entombed/proc/install_quirk_interaction_features()
	// if entombed needs to interact with certain other quirks, add it here
	if (!modsuit)
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	if (human_holder.get_quirk(/datum/quirk/paraplegic))
		var/obj/item/mod/module/anomaly_locked/antigrav/entombed/ambulator = new
		modsuit.install(ambulator, human_holder)

/datum/quirk/equipping/entombed/proc/install_skin_features(modsuit_skin)
	// adds non-functional visual equivalents of modules to skins that should have them
	if (!modsuit)
		return

	var/mob/living/carbon/human/human_holder = quirk_holder

	if (modsuit_skin == "Loader")
		var/obj/item/mod/module/visual_dummy/hydraulic/loader = new
		modsuit.install(loader, human_holder)
	else if (modsuit_skin == "Elite")
		var/obj/item/mod/module/visual_dummy/armor_booster/elite = new
		modsuit.install(elite, human_holder)

/datum/quirk_constant_data/entombed
	associated_typepath = /datum/quirk/equipping/entombed
	customization_options = list(
		/datum/preference/choiced/entombed_skin,
		/datum/preference/text/entombed_mod_desc,
		/datum/preference/text/entombed_mod_name,
		/datum/preference/text/entombed_mod_prefix,
		/datum/preference/toggle/entombed_deploy_lock,
	)

/datum/preference/choiced/entombed_skin
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "entombed_skin"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/entombed_skin/init_possible_values()
	return list(
		"Standard",
		"Civilian",
		"Advanced",
		"Atmospheric",
		"Corpsman",
		"Cosmohonk",
		"Engineering",
		"Infiltrator",
		"Interdyne",
		"Loader",
		"Medical",
		"Mining",
		"Prototype",
		"Security",
		"Elite",
		"Colonist",
		"Orbiter",
		"Moonlight",
	)

/datum/preference/choiced/entombed_skin/create_default_value()
	return "Civilian"

/datum/preference/choiced/entombed_skin/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Entombed" in preferences.all_quirks

/datum/preference/choiced/entombed_skin/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/entombed_mod_name
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "entombed_mod_name"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	maximum_value_length = 64

/datum/preference/text/entombed_mod_name/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Entombed" in preferences.all_quirks

/datum/preference/text/entombed_mod_name/serialize(input)
	return htmlrendertext(input)

/datum/preference/text/entombed_mod_name/deserialize(input, datum/preferences/preferences)
	var/sanitized_input = htmlrendertext(input)
	if(!isnull(sanitized_input))
		return sanitized_input
	else
		return ""

/datum/preference/text/entombed_mod_name/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/entombed_mod_desc
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "entombed_mod_desc"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/text/entombed_mod_desc/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Entombed" in preferences.all_quirks

/datum/preference/text/entombed_mod_desc/serialize(input)
	return htmlrendertext(input)

/datum/preference/text/entombed_mod_desc/deserialize(input, datum/preferences/preferences)
	var/sanitized_input = htmlrendertext(input)
	if(!isnull(sanitized_input))
		return sanitized_input
	else
		return ""

/datum/preference/text/entombed_mod_desc/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/entombed_mod_prefix
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "entombed_mod_prefix"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	maximum_value_length = 16

/datum/preference/text/entombed_mod_prefix/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Entombed" in preferences.all_quirks

/datum/preference/text/entombed_mod_prefix/serialize(input)
	return htmlrendertext(input)

/datum/preference/text/entombed_mod_prefix/deserialize(input, datum/preferences/preferences)
	return htmlrendertext(input)

/datum/preference/text/entombed_mod_prefix/create_default_value()
	return "Fused"

/datum/preference/text/entombed_mod_prefix/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/toggle/entombed_deploy_lock
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "entombed_deploy_lock"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/toggle/entombed_deploy_lock/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Entombed" in preferences.all_quirks

/datum/preference/toggle/entombed_deploy_lock/apply_to_human(mob/living/carbon/human/target, value)
	return

#undef ENTOMBED_TICK_DAMAGE
