/obj/item/reagent_containers/applicator/patch
	name = "patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "bandaid_blank"
	inhand_icon_state = null
	possible_transfer_amounts = list()
	volume = 40
	apply_method = "apply"
	embed_type = /datum/embedding/med_patch
	// Quick to apply
	application_delay = 1.5 SECONDS
	self_delay = 1.5 SECONDS

/obj/item/reagent_containers/applicator/patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE

	var/mob/living/carbon/carbon_eater = eater
	var/obj/item/bodypart/affecting = carbon_eater.get_bodypart(check_zone(user.zone_selected))

	if(!affecting)
		to_chat(user, span_warning("The limb is missing!"))
		return FALSE

	if(!IS_ORGANIC_LIMB(affecting))
		to_chat(user, span_notice("Medicine won't work on an inorganic limb!"))
		return FALSE

	return TRUE

/obj/item/reagent_containers/applicator/patch/on_consumption(mob/living/carbon/consumer, mob/giver, list/modifiers)
	consumer.log_message("Had \a [src] patch applied by [giver], containing the following reagents: [english_list(reagents.reagent_list)].", LOG_GAME)
	var/clicked_x = LAZYACCESS(modifiers, ICON_X)
	var/clicked_y = LAZYACCESS(modifiers, ICON_Y)
	if (isnull(clicked_x))
		clicked_x = ICON_SIZE_X * (0.5 + rand(-5, 5) * 0.05)
	else
		clicked_x = text2num(clicked_x)
	if (isnull(clicked_y))
		clicked_y = ICON_SIZE_Y * (0.5 + rand(-5, 5) * 0.05)
	else
		clicked_y = text2num(clicked_y)
	giver.do_attack_animation(consumer, used_item = src)
	var/datum/embedding/med_patch/embed = get_embed()
	if (!istype(embed))
		embed = set_embed(/datum/embedding/med_patch)
	embed.overlay_x = clicked_x - ICON_SIZE_X * 0.5
	embed.overlay_y = clicked_y - ICON_SIZE_Y * 0.5
	force_embed(consumer, consumer.get_bodypart(check_zone(giver.zone_selected)) || consumer.get_bodypart(BODY_ZONE_CHEST))

/datum/embedding/med_patch
	embed_chance = 10
	fall_chance = 0
	pain_chance = 0
	jostle_chance = 0
	pain_mult = 0
	jostle_pain_mult = 0
	// Quick to rip off
	rip_time = 0.25 SECONDS
	ignore_throwspeed_threshold = TRUE
	immune_traits = null
	/// How many units are transferred per second
	var/transfer_per_second = 0.75
	/// Cooldown for reagent messages, prevents spam
	COOLDOWN_DECLARE(reagent_message_cd)
	// pixel_x and pixel_y for our overlay
	var/overlay_x = 0
	var/overlay_y = 0
	/// Direction in which mob was facing when the patch was applied, used for layering and positional adjustments
	var/applied_dir = NONE
	/// Patch overlay applied to the mob
	var/mutable_appearance/patch_overlay

/datum/embedding/med_patch/set_owner(mob/living/carbon/victim, obj/item/bodypart/target_limb)
	. = ..()
	overlay_setup()
	RegisterSignal(owner, COMSIG_LIVING_IGNITED, PROC_REF(on_ignited))
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))

/datum/embedding/med_patch/stop_embedding()
	if (owner)
		UnregisterSignal(owner, list(COMSIG_LIVING_IGNITED, COMSIG_ATOM_DIR_CHANGE))
		if (patch_overlay)
			owner.cut_overlay(patch_overlay)
	QDEL_NULL(patch_overlay)
	return ..()

/datum/embedding/med_patch/can_embed(atom/movable/source, mob/living/carbon/victim, hit_zone, datum/thrownthing/throwingdatum)
	. = ..()
	if (!.)
		return
	var/obj/item/bodypart/affecting = victim.get_bodypart(hit_zone) || victim.bodyparts[1]
	if (!IS_ORGANIC_LIMB(affecting))
		return FALSE
	return TRUE

/datum/embedding/med_patch/proc/on_ignited(datum/source)
	SIGNAL_HANDLER
	if (!(parent.resistance_flags & FLAMMABLE))
		return
	if (ishuman(owner))
		var/mob/living/carbon/human/as_human = owner
		if (as_human.get_thermal_protection() >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			return
	INVOKE_ASYNC(src, PROC_REF(fall_out))
	qdel(parent)

/// Create a patch overlay and add it to the mob
/datum/embedding/med_patch/proc/overlay_setup()
	applied_dir = owner.dir
	patch_overlay = mutable_appearance(parent.icon, parent.icon_state, FLOAT_LAYER, parent, appearance_flags = KEEP_APART|RESET_COLOR)
	patch_overlay.color = parent.color
	if (parent.cached_color_filter)
		patch_overlay = filter_appearance_recursive(patch_overlay, parent.cached_color_filter)
	patch_overlay.transform *= 0.5
	patch_overlay.pixel_w = overlay_x
	patch_overlay.pixel_z = overlay_y
	owner.add_overlay(patch_overlay)

/// Changes visual position of the patch based on owner's rotation
/datum/embedding/med_patch/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	owner.cut_overlay(patch_overlay)
	if (new_dir == applied_dir)
		patch_overlay.pixel_w = overlay_x
		patch_overlay.layer = FLOAT_LAYER
		owner.add_overlay(patch_overlay)
		return

	if (new_dir == REVERSE_DIR(applied_dir))
		patch_overlay.pixel_w = -overlay_x
		patch_overlay.layer = BELOW_MOB_LAYER
		owner.add_overlay(patch_overlay)
		return

	var/check_dir = EAST
	var/check_new_dir = SOUTH
	if (applied_dir & (NORTH|SOUTH))
		check_dir = NORTH
		check_new_dir = EAST

	// Turn ourselves based on how we were placed originally
	var/dir_sign = (applied_dir & check_dir)
	if (overlay_x >= 0)
		dir_sign = !dir_sign
	if (new_dir & check_new_dir)
		dir_sign = !dir_sign

	// 0.5 multiplier to fake perspective
	patch_overlay.pixel_w = overlay_x * (dir_sign ? 0.5 : -0.5)
	patch_overlay.layer = dir_sign ? FLOAT_LAYER : BELOW_MOB_LAYER
	owner.add_overlay(patch_overlay)
	return

/datum/embedding/med_patch/process_effect(seconds_per_tick)
	if (HAS_TRAIT(owner, TRAIT_STASIS))
		return

	if (!parent.reagents.total_volume)
		fall_out()
		qdel(parent)
		return TRUE

	var/show_message = FALSE
	if (COOLDOWN_FINISHED(src, reagent_message_cd))
		show_message = TRUE
		COOLDOWN_START(src, reagent_message_cd, PATCH_MESSAGE_COOLDOWN)

	parent.reagents.trans_to(owner, transfer_per_second, methods = PATCH, show_message = show_message)

// delivers all of the patch's contents at once
/datum/embedding/med_patch/instant
	transfer_per_second = /obj/item/reagent_containers/applicator/patch::volume

/obj/item/reagent_containers/applicator/patch/libital
	name = "libital patch (brute)"
	desc = "A pain reliever. Does minor liver damage. Diluted with Granibitaluri."
	list_reagents = list(/datum/reagent/medicine/c2/libital = 2, /datum/reagent/medicine/granibitaluri = 8) //10 iterations
	icon_state = "bandaid_brute"

/obj/item/reagent_containers/applicator/patch/aiuri
	name = "aiuri patch (burn)"
	desc = "Helps with burn injuries. Does minor eye damage. Diluted with Granibitaluri."
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 2, /datum/reagent/medicine/granibitaluri = 8)
	icon_state = "bandaid_burn"

/obj/item/reagent_containers/applicator/patch/fent
	name = "unmarked patch"
	desc = "An unmarked, unlabeled transdermal patch for you to wear!"
	list_reagents = list(/datum/reagent/toxin/fentanyl = 2)

/obj/item/reagent_containers/applicator/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries. Slightly toxic. Three patches applied can restore a corpse husked by burns."
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 20)
	list_reagents_purity = 1
	icon_state = "bandaid_both"
	embed_type = /datum/embedding/med_patch/instant //synthflesh effects occur on the initial apply only, so we need to apply it all at once

/obj/item/reagent_containers/applicator/patch/canconsume(mob/eater, mob/user)
	. = ..()
	if(!iscarbon(eater))
		return
	var/datum/reagent/medicine/c2/synthflesh/synthflesh_patch = reagents.has_reagent(/datum/reagent/medicine/c2/synthflesh)
	if(!synthflesh_patch)
		return
	// Check mob damage for synthflesh unhusking
	var/mob/living/carbon/carbies = eater
	if(HAS_TRAIT_FROM(carbies, TRAIT_HUSK, BURN) && carbies.getFireLoss() > UNHUSK_DAMAGE_THRESHOLD * 2.5)
		// give them a warning if the mob is a husk but synthflesh won't unhusk yet
		carbies.visible_message(span_boldwarning("[carbies]'s burns need to be repaired first before synthflesh will unhusk it!"))

/obj/item/reagent_containers/applicator/patch/ondansetron
	name = "ondansetron patch"
	desc = "Alleviates nausea. May cause drowsiness."
	list_reagents = list(/datum/reagent/medicine/ondansetron = 10)
	icon_state = "bandaid_toxin"

// Patch styles for chem master

/obj/item/reagent_containers/applicator/patch/style
	icon_state = "bandaid_blank"
/obj/item/reagent_containers/applicator/patch/style/brute
	icon_state = "bandaid_brute_2"
/obj/item/reagent_containers/applicator/patch/style/burn
	icon_state = "bandaid_burn_2"
/obj/item/reagent_containers/applicator/patch/style/bruteburn
	icon_state = "bandaid_both"
/obj/item/reagent_containers/applicator/patch/style/toxin
	icon_state = "bandaid_toxin_2"
/obj/item/reagent_containers/applicator/patch/style/oxygen
	icon_state = "bandaid_suffocation_2"
/obj/item/reagent_containers/applicator/patch/style/omni
	icon_state = "bandaid_mix"
/obj/item/reagent_containers/applicator/patch/style/bruteplus
	icon_state = "bandaid_brute"
/obj/item/reagent_containers/applicator/patch/style/burnplus
	icon_state = "bandaid_burn"
/obj/item/reagent_containers/applicator/patch/style/toxinplus
	icon_state = "bandaid_toxin"
/obj/item/reagent_containers/applicator/patch/style/oxygenplus
	icon_state = "bandaid_suffocation"
/obj/item/reagent_containers/applicator/patch/style/monkey
	icon_state = "bandaid_monke"
/obj/item/reagent_containers/applicator/patch/style/clown
	icon_state = "bandaid_clown"
/obj/item/reagent_containers/applicator/patch/style/one
	icon_state = "bandaid_1"
/obj/item/reagent_containers/applicator/patch/style/two
	icon_state = "bandaid_2"
/obj/item/reagent_containers/applicator/patch/style/three
	icon_state = "bandaid_3"
/obj/item/reagent_containers/applicator/patch/style/four
	icon_state = "bandaid_4"
/obj/item/reagent_containers/applicator/patch/style/exclamation
	icon_state = "bandaid_exclaimationpoint"
/obj/item/reagent_containers/applicator/patch/style/question
	icon_state = "bandaid_questionmark"
/obj/item/reagent_containers/applicator/patch/style/colonthree
	icon_state = "bandaid_colonthree"
