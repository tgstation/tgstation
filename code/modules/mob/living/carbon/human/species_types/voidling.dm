/datum/species/voidling
	name = "\improper Voidling"
	id = SPECIES_VOIDLING
	sexes = FALSE
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_NO_UNDERWEAR,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOBLOOD,
		TRAIT_NODISMEMBER,
		TRAIT_NEVER_WOUNDED,
		TRAIT_MOVE_FLYING,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOHUNGER,
	)
	changesource_flags = MIRROR_BADMIN

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/voidling,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/voidling,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/voidling,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/voidling,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/voidling,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/voidling,
	)

	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_ICLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_FEET | ITEM_SLOT_BACK

	mutantbrain = /obj/item/organ/internal/brain/voidling
	mutanteyes = /obj/item/organ/internal/eyes/voidling
	mutantheart = null
	mutantlungs = null
	mutanttongue = null

/datum/species/voidling/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()

	RegisterSignal(human_who_gained_species, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_temporary_shatter))
	human_who_gained_species.apply_status_effect(/datum/status_effect/glass_passer)

/datum/species/voidling/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()

	UnregisterSignal(human, COMSIG_MOVABLE_CAN_PASS_THROUGH)
	human.remove_status_effect(/datum/status_effect/glass_passer)

/datum/species/voidling/proc/try_temporary_shatter(mob/living/carbon/human/human, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/structure/window))
		var/obj/structure/window/window = target
		window.temporary_shatter()
	else if(istype(src, /obj/structure/grille))
		var/obj/structure/grille/grille = target
		grille.temporary_shatter()
	else
		return
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/glass_passer
	id = "glass_passer"
	duration = INFINITE
	/// How long does it take us to move into glass?
	var/pass_time = 0 SECONDS

/datum/status_effect/glass_passer/on_apply()
	if(!pass_time)
		passwindow_on(owner, type)
	else
		RegisterSignal(owner, COMSIG_MOVABLE_BUMP, PROC_REF(bumped))
	owner.generic_canpass = FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_CAN_PASS_THROUGH, PROC_REF(can_pass_through))
	return TRUE

/datum/status_effect/glass_passer/on_remove()
	passwindow_off(owner, type)

/datum/status_effect/glass_passer/proc/can_pass_through(mob/living/carbon/human/human, atom/blocker, direction)
	SIGNAL_HANDLER

	if(istype(blocker, /obj/structure/grille))
		var/obj/structure/grille/grille = blocker
		if(grille.shock(human, 100))
			return COMSIG_COMPONENT_REFUSE_PASSAGE

	return null

/datum/status_effect/glass_passer/proc/bumped(mob/living/owner, atom/bumpee)
	SIGNAL_HANDLER

	if(!istype(bumpee, /obj/structure/window))
		return FALSE

	INVOKE_ASYNC(src, PROC_REF(phase_through_glass), owner, bumpee)

/datum/status_effect/glass_passer/proc/phase_through_glass(mob/living/owner, atom/bumpee)
	if(!do_after(owner, pass_time, bumpee))
		return
	passwindow_on(owner, type)
	try_move_adjacent(owner, get_dir(owner, bumpee))
	passwindow_off(owner, type)

/datum/status_effect/glass_passer/delayed
	pass_time = 2 SECONDS

/obj/item/organ/internal/eyes/voidling
	name = "black orbs"
	desc = "Dark, blackened orbs, invisible against the rest of the voidlings body."
	eye_icon_state = null
	pepperspray_protect = TRUE
	flash_protect = FLASH_PROTECTION_WELDER
	color_cutoffs = list(20, 10, 40)
	sight_flags = SEE_MOBS

/obj/item/organ/internal/brain/voidling
	name = "..."
	desc = "...."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'

	organ_traits = list(TRAIT_ALLOW_HERETIC_CASTING) //allows use of space phase and also just cool I think
	/// Alpha we have in space
	var/space_alpha = 50
	/// Alpha we have elsewhere
	var/non_space_alpha = 250
	/// We space in phase
	var/datum/action/space_phase = /datum/action/cooldown/spell/jaunt/space_crawl
	/// We settle the un
	var/datum/action/unsettle = /datum/action/cooldown/spell/pointed/unsettle
	/// Regen effect we have in space
	var/datum/status_effect/regen = /datum/status_effect/shadow_regeneration

/obj/item/organ/internal/brain/voidling/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	RegisterSignal(organ_owner, COMSIG_ATOM_ENTERING, PROC_REF(on_atom_entering))
	organ_owner.remove_from_all_data_huds()

	space_phase = new space_phase ()
	space_phase.Grant(organ_owner)

	unsettle = new unsettle ()
	unsettle.Grant(organ_owner)

/obj/item/organ/internal/brain/voidling/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, COMSIG_ENTER_AREA)
	alpha = 255
	organ_owner.add_to_all_human_data_huds()

	space_phase.Remove(organ_owner)
	space_phase = initial(space_phase)

	unsettle.Remove()
	unsettle = initial(unsettle)

/obj/item/organ/internal/brain/voidling/proc/on_atom_entering(mob/living/carbon/organ_owner, atom/entering)
	SIGNAL_HANDLER

	if(!isturf(entering))
		return

	var/turf/new_turf = entering

	//apply debufs for being in gravity
	if(new_turf.has_gravity())
		animate(organ_owner, alpha = non_space_alpha, time = 0.5 SECONDS)
		organ_owner.add_movespeed_modifier(/datum/movespeed_modifier/grounded_voidling)
	//remove debufs for not being in gravity
	else
		animate(organ_owner, alpha = space_alpha, time = 0.5 SECONDS)
		organ_owner.remove_movespeed_modifier(/datum/movespeed_modifier/grounded_voidling)
		organ_owner.apply_status_effect(/datum/status_effect/space_regeneration)

	//only get the actual regen when we're in space, not no-grav
	if(isspaceturf(new_turf))
		organ_owner.apply_status_effect(/datum/status_effect/space_regeneration)
	else
		organ_owner.remove_status_effect(/datum/status_effect/space_regeneration)

/datum/movespeed_modifier/grounded_voidling
	multiplicative_slowdown = 1.3

/datum/status_effect/space_regeneration
	id = "space_regeneration"
	duration = INFINITE

/datum/status_effect/space_regeneration/on_apply()
	. = ..()
	if (!.)
		return FALSE
	heal_owner()
	return TRUE

/datum/status_effect/space_regeneration/tick(effect)
	. = ..()
	heal_owner()

/// Regenerate health whenever this status effect is applied or reapplied
/datum/status_effect/space_regeneration/proc/heal_owner()
	owner.heal_overall_damage(brute = 1, burn = 1, required_bodytype = BODYTYPE_ORGANIC)

/datum/brain_trauma/voided
	name = "Voided"
	desc = "They've seen the secrets of the cosmis, in exchange for a curse that keeps them chained."
	scan_desc = "cosmic neural pattern"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	random_gain = FALSE
	/// Type for the bodypart texture we add
	var/bodypart_overlay_type = /datum/bodypart_overlay/texture/spacey
	///traits we give on gain
	var/list/traits_to_apply = list(TRAIT_MUTE, TRAIT_PACIFISM)
	/// Do we ban the person from entering space?
	var/ban_from_space = TRUE

/datum/brain_trauma/voided/on_gain()
	. = ..()

	owner.add_traits(traits_to_apply, TRAUMA_TRAIT)
	if(ban_from_space)
		owner.AddComponent(/datum/component/banned_from_space)
	RegisterSignal(owner, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(texture_limb))
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(untexture_limb))

	for(var/obj/item/bodypart as anything in owner.bodyparts)
		texture_limb(owner, bodypart)

	//your underwear is belong to us
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner //CARBON WILL NEVER BE REAL!!!!!
		human.underwear = "Nude"
		human.undershirt = "Nude"
		human.socks = "Nude"

	owner.update_body()

/datum/brain_trauma/voided/on_lose()
	. = ..()

	owner.remove_traits(traits_to_apply, TRAUMA_TRAIT)
	UnregisterSignal(owner, list(COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))
	if(ban_from_space)
		qdel(owner.GetComponent(/datum/component/banned_from_space))

	for(var/obj/item/bodypart/bodypart as anything in owner.bodyparts)
		untexture_limb(owner, bodypart)

/datum/brain_trauma/voided/proc/texture_limb(atom/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	limb.add_bodypart_overlay(new bodypart_overlay_type)
	if(istype(limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = limb
		head.head_flags &= ~HEAD_EYESPRITES

/datum/brain_trauma/voided/proc/untexture_limb(atom/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	var/overlay = locate(bodypart_overlay_type) in limb.bodypart_overlays
	if(overlay)
		limb.remove_bodypart_overlay(overlay)

	if(istype(limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = limb
		head.head_flags = initial(head.head_flags)

/datum/brain_trauma/voided/stable
	scan_desc = "stable cosmic neural pattern"
	traits_to_apply = list(TRAIT_MUTE)
	ban_from_space = FALSE

/datum/brain_trauma/voided/stable/on_gain()
	. = ..()

	owner.apply_status_effect(/datum/status_effect/glass_passer/delayed)

/datum/brain_trauma/voided/stable/on_lose()
	. = ..()

	owner.remove_status_effect(/datum/status_effect/glass_passer/delayed)

/datum/component/banned_from_space
	/// List of recent tiles we walked on that aren't space
	var/list/tiles = list()
	/// The max amount of tiles we store
	var/max_tile_list_size = 4

/datum/component/banned_from_space/Initialize(...)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(check_if_space))

/datum/component/banned_from_space/proc/check_if_space(atom/source, atom/new_location)
	SIGNAL_HANDLER

	if(!isturf(new_location))
		return

	if(isspaceturf(new_location))
		send_back(parent)

	else
		tiles.Add(new_location)
		if(tiles.len > max_tile_list_size)
			tiles.Cut(1, 2)

/datum/component/banned_from_space/proc/send_back(atom/movable/parent)
	var/new_turf

	if(tiles.len)
		new_turf = tiles[1]
		new /obj/effect/temp_visual/portal_animation(parent.loc, new_turf, parent)
	else
		new_turf = get_random_station_turf()

	parent.forceMove(new_turf)

/datum/action/cooldown/spell/pointed/unsettle
	name = "Unsettle"
	desc = "Stare directly into someone who doesn't see you. Remain in their view for a bit to stun them for 2 seconds and announce your presence to them. "
	button_icon_state = "terrify"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cooldown_time = 25 SECONDS
	cast_range = 9
	active_msg = "You prepare to stare down a target..."
	deactive_msg = "You refocus your eyes..."
	/// how long we need to stare at someone to unsettle them (woooooh)
	var/stare_time = 8 SECONDS
	/// how long we stun someone on succesful cast
	var/stun_time = 2 SECONDS
	/// stamina damage we doooo
	var/stamina_damage = 80

/datum/action/cooldown/spell/pointed/unsettle/is_valid_target(atom/cast_on)
	. = ..()

	if(!ishuman(cast_on))
		cast_on.balloon_alert(owner, "cannot be targeted!")
		return FALSE

	if(!check_if_in_view(cast_on))
		owner.balloon_alert(owner, "cannot see you!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(do_after(owner, stare_time, cast_on, IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(check_if_in_view), cast_on), hidden = TRUE))
		spookify(cast_on)
		return
	owner.balloon_alert(owner, "line of sight broken!")
	return SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/unsettle/proc/check_if_in_view(mob/living/carbon/human/target)
	SIGNAL_HANDLER

	if(target.is_blind() || !(owner in oview(9, target)))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/proc/spookify(mob/living/carbon/human/target)
	target.flash_act(10, override_blindness_check = TRUE, visual = TRUE, type = /atom/movable/screen/fullscreen/flash/black, length = stun_time)
	target.Stun(stun_time)
	target.adjustStaminaLoss(stamina_damage)
	target.emote("scream")

	new /obj/effect/temp_visual/circle_wave/bioscrambler_wave/unsettle(get_turf(target))

/obj/effect/temp_visual/circle_wave/unsettle
	color = COLOR_PURPLE
