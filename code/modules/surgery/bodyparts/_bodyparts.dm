/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "" //Leave this blank! Bodyparts are built using overlays
	/// The icon for Organic limbs using greyscale
	VAR_PROTECTED/icon_greyscale = DEFAULT_BODYPART_ICON_ORGANIC
	///The icon for non-greyscale limbs
	VAR_PROTECTED/icon_static = 'icons/mob/human_parts.dmi'
	///The icon for husked limbs
	VAR_PROTECTED/icon_husk = 'icons/mob/human_parts.dmi'
	///The type of husk for building an iconstate
	var/husk_type = "humanoid"
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	grind_results = list(/datum/reagent/bone_dust = 10, /datum/reagent/liquidgibs = 5) // robotic bodyparts and chests/heads cannot be ground
	/// The mob that "owns" this limb
	/// DO NOT MODIFY DIRECTLY. Use set_owner()
	var/mob/living/carbon/owner

	///A bitfield of bodytypes for clothing, surgery, and misc information
	var/bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC
	///Defines when a bodypart should not be changed. Example: BP_BLOCK_CHANGE_SPECIES prevents the limb from being overwritten on species gain
	var/change_exempt_flags

	var/is_husked = FALSE
	///The ID of a species used to generate the icon. Needs to match the icon_state portion in the limbs file!
	var/limb_id = SPECIES_HUMAN
	//Defines what sprite the limb should use if it is also sexually dimorphic.
	VAR_PROTECTED/limb_gender = "m"
	///Does this limb have a greyscale version?
	var/uses_mutcolor = TRUE
	///Is there a sprite difference between male and female?
	var/is_dimorphic = FALSE
	///The actual color a limb is drawn as, set by /proc/update_limb()
	var/draw_color //NEVER. EVER. EDIT THIS VALUE OUTSIDE OF UPDATE_LIMB. I WILL FIND YOU. It ruins the limb icon pipeline.

	/// BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	var/body_zone
	/// The body zone of this part in english ("chest", "left arm", etc) without the species attached to it
	var/plaintext_zone
	var/aux_zone // used for hands
	var/aux_layer
	/// bitflag used to check which clothes cover this bodypart
	var/body_part
	/// List of obj/item's embedded inside us. Managed by embedded components, do not modify directly
	var/list/embedded_objects = list()
	/// are we a hand? if so, which one!
	var/held_index = 0
	/// For limbs that don't really exist, eg chainsaws
	var/is_pseudopart = FALSE

	///If disabled, limb is as good as missing.
	var/bodypart_disabled = FALSE
	///Multiplied by max_damage it returns the threshold which defines a limb being disabled or not. From 0 to 1. 0 means no disable thru damage
	var/disable_threshold = 0
	///Controls whether bodypart_disabled makes sense or not for this limb.
	var/can_be_disabled = FALSE
	///Multiplier of the limb's damage that gets applied to the mob
	var/body_damage_coeff = 1
	///Multiplier of the limb's stamina damage that gets applied to the mob. Why is this 0.75 by default? Good question!
	var/stam_damage_coeff = 0.75
	var/brutestate = 0
	var/burnstate = 0
	///The current amount of brute damage the limb has
	var/brute_dam = 0
	///The current amount of burn damage the limb has
	var/burn_dam = 0
	///The current amount of stamina damage the limb has
	var/stamina_dam = 0
	///The maximum stamina damage a bodypart can take
	var/max_stamina_damage = 0
	///The maximum "physical" damage a bodypart can take. Set by children
	var/max_damage = 0
	///Gradually increases while burning when at full damage, destroys the limb when at 100
	var/cremation_progress = 0
	///Subtracted to brute damage taken
	var/brute_reduction = 0
	///Subtracted to burn damage taken
	var/burn_reduction = 0

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/species_color = ""
	///Limbs need this information as a back-up incase they are generated outside of a carbon (limbgrower)
	var/should_draw_greyscale = TRUE
	///An "override" color that can be applied to ANY limb, greyscale or not.
	var/mutation_color = ""

	///for nonhuman bodypart (e.g. monkey)
	var/animal_origin
	///whether it can be dismembered with a weapon.
	var/dismemberable = 1

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	///the type of damage overlay (if any) to use when this bodypart is bruised/burned.
	var/dmg_overlay_type
	/// If we're bleeding, which icon are we displaying on this part
	var/bleed_overlay_icon

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"

	/// The wounds currently afflicting this body part
	var/list/wounds

	/// The scars currently afflicting this body part
	var/list/scars
	/// Our current stored wound damage multiplier
	var/wound_damage_multiplier = 1

	/// This number is subtracted from all wound rolls on this bodypart, higher numbers mean more defense, negative means easier to wound
	var/wound_resistance = 0
	/// When this bodypart hits max damage, this number is added to all wound rolls. Obviously only relevant for bodyparts that have damage caps.
	var/disabled_wound_penalty = 15

	/// A hat won't cover your face, but a shirt covering your chest will cover your... you know, chest
	var/scars_covered_by_clothes = TRUE
	/// So we know if we need to scream if this limb hits max damage
	var/last_maxed
	/// Our current bleed rate. Cached, update with refresh_bleed_rate()
	var/cached_bleed_rate = 0
	/// How much generic bleedstacks we have on this bodypart
	var/generic_bleedstacks
	/// If we have a gauze wrapping currently applied (not including splints)
	var/obj/item/stack/current_gauze
	/// If something is currently grasping this bodypart and trying to staunch bleeding (see [/obj/item/hand_item/self_grasp])
	var/obj/item/hand_item/self_grasp/grasped_by

	///A list of all the external organs we've got stored to draw horns, wings and stuff with (special because we are actually in the limbs unlike normal organs :/ )
	var/list/obj/item/organ/external/external_organs = list()

/obj/item/bodypart/Initialize(mapload)
	. = ..()
	if(can_be_disabled)
		RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_gain)
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_loss)
	if(!IS_ORGANIC_LIMB(src))
		grind_results = null

	name = "[limb_id] [parse_zone(body_zone)]"
	update_icon_dropped()
	refresh_bleed_rate()

/obj/item/bodypart/Destroy()
	if(owner)
		owner.remove_bodypart(src)
		set_owner(null)
	for(var/wound in wounds)
		qdel(wound) // wounds is a lazylist, and each wound removes itself from it on deletion.
	if(length(wounds))
		stack_trace("[type] qdeleted with [length(wounds)] uncleared wounds")
		wounds.Cut()
	for(var/external_organ in external_organs)
		qdel(external_organ)
	return ..()

/obj/item/bodypart/forceMove(atom/destination) //Please. Never forcemove a limb if its's actually in use. This is only for borgs.
	SHOULD_CALL_PARENT(TRUE)

	. = ..()
	if(isturf(destination))
		update_icon_dropped()

/obj/item/bodypart/examine(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	. = ..()
	if(brute_dam > DAMAGE_PRECISION)
		. += span_warning("This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.")
	if(burn_dam > DAMAGE_PRECISION)
		. += span_warning("This limb has [burn_dam > 30 ? "severe" : "minor"] burns.")

	if(locate(/datum/wound/blunt) in wounds)
		. += span_warning("The bones in this limb appear badly cracked.")
	if(locate(/datum/wound/slash) in wounds)
		. += span_warning("The flesh on this limb appears badly lacerated.")
	if(locate(/datum/wound/pierce) in wounds)
		. += span_warning("The flesh on this limb appears badly perforated.")
	if(locate(/datum/wound/burn) in wounds)
		. += span_warning("The flesh on this limb appears badly cooked.")

/obj/item/bodypart/blob_act()
	receive_damage(max_damage, wound_bonus = CANT_WOUND)

/obj/item/bodypart/attack(mob/living/carbon/victim, mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(HAS_TRAIT(victim, TRAIT_LIMBATTACHMENT))
			if(!human_victim.get_bodypart(body_zone) && !animal_origin)
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				if(!attach_limb(victim))
					to_chat(user, span_warning("[human_victim]'s body rejects [src]!"))
					forceMove(human_victim.loc)
				if(human_victim == user)
					human_victim.visible_message(span_warning("[human_victim] jams [src] into [human_victim.p_their()] empty socket!"),\
					span_notice("You force [src] into your empty socket, and it locks into place!"))
				else
					human_victim.visible_message(span_warning("[user] jams [src] into [human_victim]'s empty socket!"),\
					span_notice("[user] forces [src] into your empty socket, and it locks into place!"))
				return
	..()

/obj/item/bodypart/attackby(obj/item/weapon, mob/user, params)
	SHOULD_CALL_PARENT(TRUE)

	if(weapon.get_sharpness())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, span_warning("There is nothing left inside [src]!"))
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
		user.visible_message(span_warning("[user] begins to cut open [src]."),\
			span_notice("You begin to cut open [src]..."))
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	SHOULD_CALL_PARENT(TRUE)

	..()
	if(IS_ORGANIC_LIMB(src))
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, TRUE, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	SHOULD_CALL_PARENT(TRUE)

	var/turf/bodypart_turf = get_turf(src)
	if(IS_ORGANIC_LIMB(src))
		playsound(bodypart_turf, 'sound/misc/splort.ogg', 50, TRUE, -1)
	seep_gauze(9999) // destroy any existing gauze if any exists
	for(var/obj/item/organ/bodypart_organ in get_organs())
		bodypart_organ.transfer_to_limb(src, owner)
	for(var/obj/item/item_in_bodypart in src)
		item_in_bodypart.forceMove(bodypart_turf)

///since organs aren't actually stored in the bodypart themselves while attached to a person, we have to query the owner for what we should have
/obj/item/bodypart/proc/get_organs()
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	if(!owner)
		return FALSE

	var/list/bodypart_organs
	for(var/obj/item/organ/organ_check as anything in owner.internal_organs) //internal organs inside the dismembered limb are dropped.
		if(check_zone(organ_check.zone) == body_zone)
			LAZYADD(bodypart_organs, organ_check) // this way if we don't have any, it'll just return null

	return bodypart_organs

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(delta_time, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	//DO NOT update health here, it'll be done in the carbon's life.
	if(stamina_dam > DAMAGE_PRECISION && owner.stam_regen_start_time <= world.time)
		heal_damage(0, 0, INFINITY, null, FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE, attack_direction = null)
	SHOULD_CALL_PARENT(TRUE)

	var/hit_percent = (100-blocked)/100
	if((!brute && !burn && !stamina) || hit_percent <= 0)
		return FALSE
	if(owner && (owner.status_flags & GODMODE))
		return FALSE	//godmode
	if(required_status && !(bodytype & required_status))
		return FALSE

	var/dmg_multi = CONFIG_GET(number/damage_multiplier) * hit_percent
	brute = round(max(brute * dmg_multi, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_multi, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_multi, 0),DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)
	//No stamina scaling.. for now..

	if(!brute && !burn && !stamina)
		return FALSE

	brute *= wound_damage_multiplier
	burn *= wound_damage_multiplier

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take double burn //nothing can burn with so much snowflake code around
			burn *= 2

	/*
	// START WOUND HANDLING
	*/

	// what kind of wounds we're gonna roll for, take the greater between brute and burn, then if it's brute, we subdivide based on sharpness
	var/wounding_type = (brute > burn ? WOUND_BLUNT : WOUND_BURN)
	var/wounding_dmg = max(brute, burn)

	var/mangled_state = get_mangled_state()
	var/bio_state = owner.get_biological_state()
	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	if(wounding_type == WOUND_BLUNT && sharpness)
		if(sharpness & SHARP_EDGED)
			wounding_type = WOUND_SLASH
		else if (sharpness & SHARP_POINTY)
			wounding_type = WOUND_PIERCE

	//Handling for bone only/flesh only(none right now)/flesh and bone targets
	switch(bio_state)
		// if we're bone only, all cutting attacks go straight to the bone
		if(BIO_JUST_BONE)
			if(wounding_type == WOUND_SLASH)
				wounding_type = WOUND_BLUNT
				wounding_dmg *= (easy_dismember ? 1 : 0.6)
			else if(wounding_type == WOUND_PIERCE)
				wounding_type = WOUND_BLUNT
				wounding_dmg *= (easy_dismember ? 1 : 0.75)
			if((mangled_state & BODYPART_MANGLED_BONE) && try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
				return
		// note that there's no handling for BIO_JUST_FLESH since we don't have any that are that right now (slimepeople maybe someday)
		// standard humanoids
		if(BIO_FLESH_BONE)
			// if we've already mangled the skin (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
			// So a big sharp weapon is still all you need to destroy a limb
			if(mangled_state == BODYPART_MANGLED_FLESH && sharpness)
				playsound(src, "sound/effects/wounds/crackandbleed.ogg", 100)
				if(wounding_type == WOUND_SLASH && !easy_dismember)
					wounding_dmg *= 0.6 // edged weapons pass along 60% of their wounding damage to the bone since the power is spread out over a larger area
				if(wounding_type == WOUND_PIERCE && !easy_dismember)
					wounding_dmg *= 0.75 // piercing weapons pass along 75% of their wounding damage to the bone since it's more concentrated
				wounding_type = WOUND_BLUNT
			else if(mangled_state == BODYPART_MANGLED_BOTH && try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
				return

	// now we have our wounding_type and are ready to carry on with wounds and dealing the actual damage
	if(owner && wounding_dmg >= WOUND_MINIMUM_DAMAGE && wound_bonus != CANT_WOUND)
		check_wounding(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus, attack_direction)

	for(var/datum/wound/iter_wound as anything in wounds)
		iter_wound.receive_damage(wounding_type, wounding_dmg, wound_bonus)

	/*
	// END WOUND HANDLING
	*/

	//back to our regularly scheduled program, we now actually apply damage if there's room below limb damage cap
	var/can_inflict = max_damage - get_damage()
	var/total_damage = brute + burn
	if(total_damage > can_inflict && total_damage > 0) // TODO: the second part of this check should be removed once disabling is all done
		brute = round(brute * (can_inflict / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (can_inflict / total_damage),DAMAGE_PRECISION)

	if(can_inflict <= 0)
		return FALSE
	if(brute)
		set_brute_dam(brute_dam + brute)
	if(burn)
		set_burn_dam(burn_dam + burn)

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	if(stamina)
		set_stamina_dam(stamina_dam + round(clamp(stamina, 0, max_stamina_damage - stamina_dam), DAMAGE_PRECISION))

	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()
			if(stamina > DAMAGE_PRECISION)
				owner.update_stamina()
				owner.stam_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME
				. = TRUE
	return update_bodypart_damage_state() || .

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, required_status, updating_health = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(required_status && !(bodytype & required_status)) //So we can only heal certain kinds of limbs, ie robotic vs organic.
		return

	if(brute)
		set_brute_dam(round(max(brute_dam - brute, 0), DAMAGE_PRECISION))
	if(burn)
		set_burn_dam(round(max(burn_dam - burn, 0), DAMAGE_PRECISION))
	if(stamina)
		set_stamina_dam(round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION))

	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()
	cremation_progress = min(0, cremation_progress - ((brute_dam + burn_dam)*(100/max_damage)))
	return update_bodypart_damage_state()


///Proc to hook behavior associated to the change of the brute_dam variable's value.
/obj/item/bodypart/proc/set_brute_dam(new_value)
	PROTECTED_PROC(TRUE)

	if(brute_dam == new_value)
		return
	. = brute_dam
	brute_dam = new_value


///Proc to hook behavior associated to the change of the burn_dam variable's value.
/obj/item/bodypart/proc/set_burn_dam(new_value)
	PROTECTED_PROC(TRUE)

	if(burn_dam == new_value)
		return
	. = burn_dam
	burn_dam = new_value


///Proc to hook behavior associated to the change of the stamina_dam variable's value.
/obj/item/bodypart/proc/set_stamina_dam(new_value)
	PROTECTED_PROC(TRUE)

	if(stamina_dam == new_value)
		return
	. = stamina_dam
	stamina_dam = new_value

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total = max(total, stamina_dam)
	return total

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled()
	SHOULD_CALL_PARENT(TRUE)

	if(!owner)
		return

	if(!can_be_disabled)
		set_disabled(FALSE)
		CRASH("update_disabled called with can_be_disabled false")

	if(HAS_TRAIT(src, TRAIT_PARALYSIS))
		set_disabled(TRUE)
		return

	var/total_damage = max(brute_dam + burn_dam, stamina_dam)

	// this block of checks is for limbs that can be disabled, but not through pure damage (AKA limbs that suffer wounds, human/monkey parts and such)
	if(!disable_threshold)
		if(total_damage < max_damage)
			last_maxed = FALSE
		else
			if(!last_maxed && owner.stat < UNCONSCIOUS)
				INVOKE_ASYNC(owner, /mob.proc/emote, "scream")
			last_maxed = TRUE
		set_disabled(FALSE) // we only care about the paralysis trait
		return

	// we're now dealing solely with limbs that can be disabled through pure damage, AKA robot parts
	if(total_damage >= max_damage * disable_threshold)
		if(!last_maxed)
			if(owner.stat < UNCONSCIOUS)
				INVOKE_ASYNC(owner, /mob.proc/emote, "scream")
			last_maxed = TRUE
		set_disabled(TRUE)
		return

	if(bodypart_disabled && total_damage <= max_damage * 0.5) // reenable the limb at 50% health
		last_maxed = FALSE
		set_disabled(FALSE)


///Proc to change the value of the `disabled` variable and react to the event of its change.
/obj/item/bodypart/proc/set_disabled(new_disabled)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	if(bodypart_disabled == new_disabled)
		return
	. = bodypart_disabled
	bodypart_disabled = new_disabled

	if(!owner)
		return
	owner.update_health_hud() //update the healthdoll
	owner.update_body()


///Proc to change the value of the `owner` variable and react to the event of its change.
/obj/item/bodypart/proc/set_owner(new_owner)
	SHOULD_CALL_PARENT(TRUE)

	if(owner == new_owner)
		return FALSE //`null` is a valid option, so we need to use a num var to make it clear no change was made.
	var/mob/living/carbon/old_owner = owner
	owner = new_owner
	var/needs_update_disabled = FALSE //Only really relevant if there's an owner
	if(old_owner)
		if(initial(can_be_disabled))
			if(HAS_TRAIT(old_owner, TRAIT_NOLIMBDISABLE))
				if(!owner || !HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
					set_can_be_disabled(initial(can_be_disabled))
					needs_update_disabled = TRUE
			UnregisterSignal(old_owner, list(
				SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE),
				SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE),
				SIGNAL_REMOVETRAIT(TRAIT_NOBLEED),
				SIGNAL_ADDTRAIT(TRAIT_NOBLEED),
				))
	if(owner)
		if(initial(can_be_disabled))
			if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
				set_can_be_disabled(FALSE)
				needs_update_disabled = FALSE
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE), .proc/on_owner_nolimbdisable_trait_loss)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE), .proc/on_owner_nolimbdisable_trait_gain)
			// Bleeding stuff
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NOBLEED), .proc/on_owner_nobleed_loss)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOBLEED), .proc/on_owner_nobleed_gain)

		if(needs_update_disabled)
			update_disabled()

	refresh_bleed_rate()
	return old_owner


///Proc to change the value of the `can_be_disabled` variable and react to the event of its change.
/obj/item/bodypart/proc/set_can_be_disabled(new_can_be_disabled)
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(can_be_disabled == new_can_be_disabled)
		return
	. = can_be_disabled
	can_be_disabled = new_can_be_disabled
	if(can_be_disabled)
		if(owner)
			if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
				CRASH("set_can_be_disabled to TRUE with for limb whose owner has TRAIT_NOLIMBDISABLE")
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_gain)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), .proc/on_paralysis_trait_loss)
		update_disabled()
	else if(.)
		if(owner)
			UnregisterSignal(owner, list(
				SIGNAL_ADDTRAIT(TRAIT_PARALYSIS),
				SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS),
				))
		set_disabled(FALSE)


///Called when TRAIT_PARALYSIS is added to the limb.
/obj/item/bodypart/proc/on_paralysis_trait_gain(obj/item/bodypart/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	if(can_be_disabled)
		set_disabled(TRUE)


///Called when TRAIT_PARALYSIS is removed from the limb.
/obj/item/bodypart/proc/on_paralysis_trait_loss(obj/item/bodypart/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	if(can_be_disabled)
		update_disabled()


///Called when TRAIT_NOLIMBDISABLE is added to the owner.
/obj/item/bodypart/proc/on_owner_nolimbdisable_trait_gain(mob/living/carbon/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	set_can_be_disabled(FALSE)


///Called when TRAIT_NOLIMBDISABLE is removed from the owner.
/obj/item/bodypart/proc/on_owner_nolimbdisable_trait_loss(mob/living/carbon/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	set_can_be_disabled(initial(can_be_disabled))

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	SHOULD_CALL_PARENT(TRUE)

	var/tbrute = round( (brute_dam/max_damage)*3, 1 )
	var/tburn = round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE

//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
//set is_creating to true if you want to change the appearance of the limb outside of mutation changes or forced changes.
/obj/item/bodypart/proc/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(HAS_TRAIT(owner, TRAIT_HUSK) && IS_ORGANIC_LIMB(src))
		dmg_overlay_type = "" //no damage overlay shown when husked
		is_husked = TRUE
	else
		dmg_overlay_type = initial(dmg_overlay_type)
		is_husked = FALSE

	if(!dropping_limb && owner.dna?.check_mutation(/datum/mutation/human/hulk))
		mutation_color = "#00aa00"
	else
		mutation_color = null

	if(mutation_color)
		draw_color = mutation_color
	else if(should_draw_greyscale)
		draw_color = (species_color) || (skin_tone && skintone2hex(skin_tone))
	else
		draw_color = null

	if(!is_creating)
		return

	if(!animal_origin && ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner

		var/datum/species/owner_species = human_owner.dna.species
		species_flags_list = human_owner.dna.species.species_traits
		limb_gender = (human_owner.physique == MALE) ? "m" : "f"

		if(owner_species.use_skintones)
			skin_tone = human_owner.skin_tone
		else
			skin_tone = ""

		if(((MUTCOLORS in owner_species.species_traits) || (DYNCOLORS in owner_species.species_traits)) && uses_mutcolor) //Ethereal code. Motherfuckers.
			if(owner_species.fixed_mut_color)
				species_color = owner_species.fixed_mut_color
			else
				species_color = human_owner.dna.features["mcolor"]
		else
			species_color = null

		draw_color = mutation_color
		if(should_draw_greyscale) //Should the limb be colored?
			draw_color ||= (species_color) || (skin_tone && skintone2hex(skin_tone))

		dmg_overlay_type = owner_species.damage_overlay_type

	else if(animal_origin == MONKEY_BODYPART) //currently monkeys are the only non human mob to have damage overlays.
		dmg_overlay_type = animal_origin

	if(!IS_ORGANIC_LIMB(src))
		dmg_overlay_type = "robotic"

	recolor_external_organs()
	return TRUE

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	SHOULD_CALL_PARENT(TRUE)

	cut_overlays()
	var/list/standing = get_limb_icon(TRUE)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/img as anything in standing)
		img.pixel_x = px_x
		img.pixel_y = px_y
	add_overlay(standing)

///Generates an /image for the limb to be used as an overlay
/obj/item/bodypart/proc/get_limb_icon(dropped)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/image/aux

	if(animal_origin)
		if(IS_ORGANIC_LIMB(src))
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(limb_id == "husk")
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"

		if(blocks_emissive)
			var/mutable_appearance/limb_em_block = emissive_blocker(limb.icon, limb.icon_state, alpha = limb.alpha)
			limb_em_block.dir = image_dir
			limb.overlays += limb_em_block
		. += limb
		return

	//HUSK SHIIIIT
	if(is_husked)
		limb.icon = icon_husk
		limb.icon_state = "[husk_type]_husk_[body_zone]"
		icon_exists(limb.icon, limb.icon_state, scream = TRUE) //Prints a stack trace on the first failure of a given iconstate.
		. += limb
		if(aux_zone) //Hand shit
			aux = image(limb.icon, "[husk_type]_husk_[aux_zone]", -aux_layer, image_dir)
			. += aux
		return .
	//END HUSK SHIIIIT

	////This is the MEAT of limb icon code
	limb.icon = icon_greyscale
	if(!should_draw_greyscale || !icon_greyscale)
		limb.icon = icon_static

	if(is_dimorphic) //Does this type of limb have sexual dimorphism?
		limb.icon_state = "[limb_id]_[body_zone]_[limb_gender]"
	else
		limb.icon_state = "[limb_id]_[body_zone]"

	icon_exists(limb.icon, limb.icon_state, TRUE) //Prints a stack trace on the first failure of a given iconstate.

	if(body_zone == BODY_ZONE_R_LEG)
		var/obj/item/bodypart/r_leg/leg = src
		var/limb_overlays = limb.overlays
		var/image/new_limb = leg.generate_masked_right_leg(limb.icon, limb.icon_state, image_dir)
		if(new_limb)
			limb = new_limb
			limb.overlays = limb_overlays

	. += limb

	if(aux_zone) //Hand shit
		aux = image(limb.icon, "[limb_id]_[aux_zone]", -aux_layer, image_dir)
		. += aux

	draw_color = mutation_color
	if(should_draw_greyscale) //Should the limb be colored outside of a forced color?
		draw_color ||= (species_color) || (skin_tone && skintone2hex(skin_tone))

	if(draw_color)
		limb.color = "[draw_color]"
		if(aux_zone)
			aux.color = "[draw_color]"

	//EMISSIVE CODE START
	if(blocks_emissive)
		var/mutable_appearance/limb_em_block = emissive_blocker(limb.icon, limb.icon_state, alpha = limb.alpha)
		limb_em_block.dir = image_dir
		limb.overlays += limb_em_block

		if(aux_zone)
			var/mutable_appearance/aux_em_block = emissive_blocker(aux.icon, aux.icon_state, alpha = aux.alpha)
			aux_em_block.dir = image_dir
			aux.overlays += aux_em_block

	//EMISSIVE CODE END
	//Draw external organs like horns and frills
	for(var/obj/item/organ/external/external_organ as anything in external_organs)
		if(!dropped && !external_organ.can_draw_on_bodypart(owner))
			continue
		//Some externals have multiple layers for background, foreground and between
		for(var/external_layer in external_organ.all_layers)
			if(external_organ.layers & external_layer)
				external_organ.get_overlays(
					.,
					image_dir,
					external_organ.bitflag_to_layer(external_layer),
					limb_gender,
				)

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	drop_organs()
	return ..()

/// INTERNAL PROC, DO NOT USE
/// Properly sets us up to manage an inserted embeded object
/obj/item/bodypart/proc/_embed_object(obj/item/embed)
	if(embed in embedded_objects) // go away
		return
	// We don't need to do anything with projectile embedding, because it will never reach this point
	RegisterSignal(embed, COMSIG_ITEM_EMBEDDING_UPDATE, .proc/embedded_object_changed)
	embedded_objects += embed
	refresh_bleed_rate()

/// INTERNAL PROC, DO NOT USE
/// Cleans up any attachment we have to the embedded object, removes it from our list
/obj/item/bodypart/proc/_unembed_object(obj/item/unembed)
	UnregisterSignal(unembed, COMSIG_ITEM_EMBEDDING_UPDATE)
	embedded_objects -= unembed
	refresh_bleed_rate()

/obj/item/bodypart/proc/embedded_object_changed(obj/item/embedded_source)
	SIGNAL_HANDLER
	/// Embedded objects effect bleed rate, gotta refresh lads
	refresh_bleed_rate()

/// Sets our generic bleedstacks
/obj/item/bodypart/proc/setBleedStacks(set_to)
	SHOULD_CALL_PARENT(TRUE)
	adjustBleedStacks(set_to - generic_bleedstacks)

/// Modifies our generic bleedstacks. You must use this to change the variable
/// Takes the amount to adjust by, and the lowest amount we're allowed to have post adjust
/obj/item/bodypart/proc/adjustBleedStacks(adjust_by, minimum = -INFINITY)
	if(!adjust_by)
		return
	var/old_bleedstacks = generic_bleedstacks
	generic_bleedstacks = max(generic_bleedstacks + adjust_by, minimum)

	// If we've started or stopped bleeding, we need to refresh our bleed rate
	if((old_bleedstacks <= 0 && generic_bleedstacks > 0) \
		|| old_bleedstacks > 0 && generic_bleedstacks <= 0)
		refresh_bleed_rate()

/obj/item/bodypart/proc/on_owner_nobleed_loss(datum/source)
	SIGNAL_HANDLER
	refresh_bleed_rate()

/obj/item/bodypart/proc/on_owner_nobleed_gain(datum/source)
	SIGNAL_HANDLER
	refresh_bleed_rate()

/// Refresh the cache of our rate of bleeding sans any modifiers
/// ANYTHING ADDED TO THIS PROC NEEDS TO CALL IT WHEN IT'S EFFECT CHANGES
/obj/item/bodypart/proc/refresh_bleed_rate()
	SHOULD_NOT_OVERRIDE(TRUE)

	var/old_bleed_rate = cached_bleed_rate
	cached_bleed_rate = 0
	if(!owner)
		return

	if(HAS_TRAIT(owner, TRAIT_NOBLEED) || !IS_ORGANIC_LIMB(src))
		if(cached_bleed_rate != old_bleed_rate)
			update_part_wound_overlay()
		return

	if(generic_bleedstacks > 0)
		cached_bleed_rate += 0.5

	for(var/obj/item/embeddies in embedded_objects)
		if(!embeddies.isEmbedHarmless())
			cached_bleed_rate += 0.25

	for(var/datum/wound/iter_wound as anything in wounds)
		cached_bleed_rate += iter_wound.blood_flow

	if(!cached_bleed_rate)
		QDEL_NULL(grasped_by)

	// Our bleed overlay is based directly off bleed_rate, so go aheead and update that would you?
	if(cached_bleed_rate != old_bleed_rate)
		update_part_wound_overlay()

	return cached_bleed_rate

/// Returns our bleed rate, taking into account laying down and grabbing the limb
/obj/item/bodypart/proc/get_modified_bleed_rate()
	var/bleed_rate = cached_bleed_rate
	if(owner.body_position == LYING_DOWN)
		bleed_rate *= 0.75
	if(grasped_by)
		bleed_rate *= 0.7
	return bleed_rate

// how much blood the limb needs to be losing per tick (not counting laying down/self grasping modifiers) to get the different bleed icons
#define BLEED_OVERLAY_LOW 0.5
#define BLEED_OVERLAY_MED 1.5
#define BLEED_OVERLAY_GUSH 3.25

/obj/item/bodypart/proc/update_part_wound_overlay()
	if(!owner)
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_NOBLEED) || !IS_ORGANIC_LIMB(src) || (NOBLOOD in species_flags_list))
		if(bleed_overlay_icon)
			bleed_overlay_icon = null
			owner.update_wound_overlays()
		return FALSE

	var/bleed_rate = cached_bleed_rate
	var/new_bleed_icon = null

	switch(bleed_rate)
		if(-INFINITY to BLEED_OVERLAY_LOW)
			new_bleed_icon = null
		if(BLEED_OVERLAY_LOW to BLEED_OVERLAY_MED)
			new_bleed_icon = "[body_zone]_1"
		if(BLEED_OVERLAY_MED to BLEED_OVERLAY_GUSH)
			if(owner.body_position == LYING_DOWN || IS_IN_STASIS(owner) || owner.stat == DEAD)
				new_bleed_icon = "[body_zone]_2s"
			else
				new_bleed_icon = "[body_zone]_2"
		if(BLEED_OVERLAY_GUSH to INFINITY)
			if(IS_IN_STASIS(owner) || owner.stat == DEAD)
				new_bleed_icon = "[body_zone]_2s"
			else
				new_bleed_icon = "[body_zone]_3"

	if(new_bleed_icon != bleed_overlay_icon)
		bleed_overlay_icon = new_bleed_icon
		owner.update_wound_overlays()

#undef BLEED_OVERLAY_LOW
#undef BLEED_OVERLAY_MED
#undef BLEED_OVERLAY_GUSH

/**
 * apply_gauze() is used to- well, apply gauze to a bodypart
 *
 * As of the Wounds 2 PR, all bleeding is now bodypart based rather than the old bleedstacks system, and 90% of standard bleeding comes from flesh wounds (the exception is embedded weapons).
 * The same way bleeding is totaled up by bodyparts, gauze now applies to all wounds on the same part. Thus, having a slash wound, a pierce wound, and a broken bone wound would have the gauze
 * applying blood staunching to the first two wounds, while also acting as a sling for the third one. Once enough blood has been absorbed or all wounds with the ACCEPTS_GAUZE flag have been cleared,
 * the gauze falls off.
 *
 * Arguments:
 * * gauze- Just the gauze stack we're taking a sheet from to apply here
 */
/obj/item/bodypart/proc/apply_gauze(obj/item/stack/gauze)
	if(!istype(gauze) || !gauze.absorption_capacity)
		return
	var/newly_gauzed = FALSE
	if(!current_gauze)
		newly_gauzed = TRUE
	QDEL_NULL(current_gauze)
	current_gauze = new gauze.type(src, 1)
	gauze.use(1)
	if(newly_gauzed)
		SEND_SIGNAL(src, COMSIG_BODYPART_GAUZED, gauze)

/**
 * seep_gauze() is for when a gauze wrapping absorbs blood or pus from wounds, lowering its absorption capacity.
 *
 * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandages falls off and we're left with nothing.
 *
 * Arguments:
 * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
 */
/obj/item/bodypart/proc/seep_gauze(seep_amt = 0)
	if(!current_gauze)
		return
	current_gauze.absorption_capacity -= seep_amt
	if(current_gauze.absorption_capacity <= 0)
		owner.visible_message(span_danger("\The [current_gauze.name] on [owner]'s [name] falls away in rags."), span_warning("\The [current_gauze.name] on your [name] falls away in rags."), vision_distance=COMBAT_MESSAGE_RANGE)
		QDEL_NULL(current_gauze)
		SEND_SIGNAL(src, COMSIG_BODYPART_GAUZE_DESTROYED)

///Loops through all of the bodypart's external organs and update's their color.
/obj/item/bodypart/proc/recolor_external_organs()
	for(var/obj/item/organ/external/ext_organ as anything in external_organs)
		ext_organ.inherit_color(force = TRUE)
