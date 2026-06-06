#define FUNCTIONAL_WING_FORCE 2.25 NEWTONS

///Wing base type. doesn't really do anything
/obj/item/organ/wings
	name = "wings"
	desc = "Spread your wings and FLLLLLLLLYYYYY!"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings/functional

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL
	abstract_type = /obj/item/organ/wings

	///The flight action object
	var/datum/action/innate/flight/fly

	///Are our wings open or closed?
	var/wings_open = FALSE
	///We cant hide these wings in suit
	var/cant_hide = FALSE
	///The level of flight this organ provides, from passive 0G drift to magic flight
	var/flight_level = WINGS_AIRWORTHY
	///Does this wing type have open/close sprite variants
	var/has_open_sprite = TRUE

	food_reagents = list(/datum/reagent/flightpotion = 5)

	var/drift_force = FUNCTIONAL_WING_FORCE

///Checks if the wings can soften short falls
/obj/item/organ/wings/proc/can_soften_fall()
	return TRUE

///Implement as needed to play a sound effect on *flap emote
/obj/item/organ/wings/proc/make_flap_sound(mob/living/carbon/wing_owner)
	return

/obj/item/organ/wings/Initialize(mapload)
	. = ..()
	if(flight_level == WINGS_FLIGHTLESS)
		AddComponent( \
			/datum/component/jetpack, \
			TRUE, \
			drift_force, \
			COMSIG_ORGAN_IMPLANTED, \
			COMSIG_ORGAN_REMOVED, \
			null, \
			CALLBACK(src, PROC_REF(allow_flight)), \
			null, \
		)
	else
		AddComponent( \
			/datum/component/jetpack, \
			TRUE, \
			drift_force, \
			COMSIG_WINGS_OPENED, \
			COMSIG_WINGS_CLOSED, \
			null, \
			CALLBACK(src, PROC_REF(can_fly)), \
			CALLBACK(src, PROC_REF(can_fly)), \
		)

/obj/item/organ/wings/Destroy()
	QDEL_NULL(fly)
	return ..()

/obj/item/organ/wings/grind_results()
	return list(/datum/reagent/flightpotion = 5)

/obj/item/organ/wings/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	update_flight(receiver)

/obj/item/organ/wings/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	fly?.Remove(organ_owner)
	if(wings_open)
		toggle_flight(organ_owner)

//If some goober tries to varedit the flight_level instead of running the set_flight() proc, we take care of that
/obj/item/organ/wings/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, flight_level))
		set_flight(owner, var_value)
		return TRUE
	return ..()

/obj/item/organ/wings/proc/set_flight(mob/living/carbon/organ_owner, state = null)
	if(!isnull(state))
		flight_level = state
	update_flight(organ_owner)

/obj/item/organ/wings/proc/update_flight(mob/living/carbon/organ_owner = null)
	fly?.Remove(owner)
	if(wings_open)
		toggle_flight(owner)

	if(!organ_owner || flight_level <= WINGS_FLIGHTLESS)
		return
	if(QDELETED(fly))
		fly = new
	fly.Grant(organ_owner)

/obj/item/organ/wings/on_life(seconds_per_tick)
	. = ..()
	handle_flight(owner)

///Called on_life(). Handle flight code and check if we're still flying
/obj/item/organ/wings/proc/handle_flight(mob/living/carbon/human/human)
	if(!HAS_TRAIT_FROM(human, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
		return FALSE
	if(!can_fly())
		toggle_flight(human)
		return FALSE
	return TRUE

///Check if still eligible for active flight (wings covered, atmosphere too thin, etc)
/obj/item/organ/wings/proc/can_fly()
	var/mob/living/carbon/human/human = owner
	if(human.stat || human.body_position == LYING_DOWN || isnull(human.client))
		return FALSE
	if(flight_level < WINGS_AIRWORTHY) //Them wings are useless!
		return FALSE
	var/datum/bodypart_overlay/mutant/wings/wing_overlay = bodypart_overlay
	if(!cant_hide && wing_overlay && (human.obscured_slots & wing_overlay.slot_blocker))
		to_chat(human, span_warning("Your clothing blocks your wings from extending!"))
		return FALSE
	var/turf/location = get_turf(human)
	if(!location)
		return FALSE
	if(flight_level < WINGS_MAGIC)
		var/datum/gas_mixture/environment = location.return_air()
		if(environment?.return_pressure() < HAZARD_LOW_PRESSURE + 10)
			to_chat(human, span_warning("The atmosphere is too thin for you to fly!"))
			return FALSE
	return TRUE

///Check if we can passively drift in low-gravity. Used by WINGS_FLIGHTLESS jetpack component
/obj/item/organ/wings/proc/allow_flight()
	if(!owner || !owner.client)
		return FALSE
	if(owner.has_gravity())
		return FALSE
	var/datum/bodypart_overlay/mutant/wings/wing_overlay = bodypart_overlay
	if(!cant_hide && wing_overlay && (owner.obscured_slots & wing_overlay.slot_blocker))
		return FALSE
	var/datum/gas_mixture/current = owner.loc?.return_air()
	if(current && (current.return_pressure() >= ONE_ATMOSPHERE * 0.85))
		return TRUE
	return FALSE

///Slipping but in the air?
/obj/item/organ/wings/proc/fly_slip(mob/living/carbon/human/human)
	var/obj/buckled_obj
	if(human.buckled)
		buckled_obj = human.buckled

	to_chat(human, span_notice("Your wings spazz out and launch you!"))

	playsound(human.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)

	for(var/obj/item/choking_hazard in human.held_items)
		human.accident(choking_hazard)

	var/olddir = human.dir

	human.stop_pulling()
	if(buckled_obj)
		buckled_obj.unbuckle_mob(human)
		step(buckled_obj, olddir)
	else
		human.AddComponent(/datum/component/force_move, get_ranged_target_turf(human, olddir, 4), TRUE)
	return TRUE

///UNSAFE PROC, should only be called through the Activate or other sources that check for CanFly
/obj/item/organ/wings/proc/toggle_flight(mob/living/carbon/human/human)
	if(!HAS_TRAIT_FROM(human, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
		human.physiology.stun_mod *= 2
		human.add_traits(list(TRAIT_MOVE_FLOATING, TRAIT_IGNORING_GRAVITY, TRAIT_NOGRAV_ALWAYS_DRIFT), SPECIES_FLIGHT_TRAIT)
		human.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/wings)
		human.AddElement(/datum/element/forced_gravity, 0)
		passtable_on(human, SPECIES_FLIGHT_TRAIT)
		open_wings()
		to_chat(human, span_notice("You beat your wings and begin to hover gently above the ground..."))
		human.set_resting(FALSE, TRUE)
		human.refresh_gravity()
		return

	human.physiology.stun_mod *= 0.5
	human.remove_traits(list(TRAIT_MOVE_FLOATING, TRAIT_IGNORING_GRAVITY, TRAIT_NOGRAV_ALWAYS_DRIFT), SPECIES_FLIGHT_TRAIT)
	human.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/wings)
	human.RemoveElement(/datum/element/forced_gravity, 0)
	passtable_off(human, SPECIES_FLIGHT_TRAIT)
	to_chat(human, span_notice("You settle gently back onto the ground..."))
	close_wings()
	human.refresh_gravity()

///Spread wings. Activate Jetpack component
/obj/item/organ/wings/proc/open_wings()
	wings_open = TRUE
	if(has_open_sprite)
		var/datum/bodypart_overlay/mutant/wings/overlay = bodypart_overlay
		overlay?.open_wings()
		owner.update_body_parts()
	SEND_SIGNAL(src, COMSIG_WINGS_OPENED, owner)

///Close wings. Deactivate jetpack component
/obj/item/organ/wings/proc/close_wings()
	wings_open = FALSE
	if(has_open_sprite)
		var/datum/bodypart_overlay/mutant/wings/overlay = bodypart_overlay
		overlay?.close_wings()
		owner.update_body_parts()
	if(isturf(owner?.loc))
		var/turf/location = loc
		location.Entered(src, NONE)
	SEND_SIGNAL(src, COMSIG_WINGS_CLOSED, owner)

///hud action for starting and stopping flight
/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/Activate()
	var/mob/living/carbon/human/human = owner
	var/obj/item/organ/wings/wings = human.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(wings?.can_fly())
		wings.toggle_flight(human)

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = ALL_EXTERNAL_OVERLAYS
	feature_key = FEATURE_WINGS
	/// Slot we check against
	var/slot_blocker = HIDEJUMPSUIT

/datum/bodypart_overlay/mutant/wings/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner, is_husked = FALSE)
	return ..() && !(bodypart_owner.owner?.obscured_slots & slot_blocker)

/datum/bodypart_overlay/mutant/wings/proc/open_wings()
	return

/datum/bodypart_overlay/mutant/wings/proc/close_wings()
	return

///Bodypart overlay of functional wings, including open and close sprite functionality!
/datum/bodypart_overlay/mutant/wings/functional
	///Are our wings currently open? Change through open_wings or close_wings()
	VAR_PRIVATE/wings_open = FALSE

/datum/bodypart_overlay/mutant/wings/functional/get_global_feature_list()
	if(wings_open)
		return SSaccessories.feature_list[FEATURE_WINGS_OPEN]
	return ..()

///Update our wingsprite to the open wings variant
/datum/bodypart_overlay/mutant/wings/functional/open_wings()
	wings_open = TRUE
	feature_key = FEATURE_WINGS_OPEN
	set_appearance_from_name(sprite_datum.name) //It'll look for the same name again, but this time from the open wings list

///Update our wingsprite to the closed wings variant
/datum/bodypart_overlay/mutant/wings/functional/close_wings()
	wings_open = FALSE
	feature_key = initial(feature_key)
	set_appearance_from_name(sprite_datum.name)

/datum/bodypart_overlay/mutant/wings/functional/generate_icon_cache(obj/item/bodypart/limb)
	. = ..()
	. += wings_open ? "open" : "closed"

///angel wings, which relate to humans. comes with holiness.
/obj/item/organ/wings/angel
	name = "angel wings"
	desc = "Holier-than-thou attitude not included."
	sprite_accessory_override = /datum/sprite_accessory/wings_open/angel

	organ_traits = list(TRAIT_HOLY)

///dragon wings, which relate to lizards.
/obj/item/organ/wings/dragon
	name = "dragon wings"
	desc = "Hey, HEY- NOT lizard wings. Dragon wings. Mighty dragon wings."
	sprite_accessory_override = /datum/sprite_accessory/wings/dragon

///robotic wings, which relate to androids.
/obj/item/organ/wings/robotic
	name = "robotic wings"
	desc = "Using microscopic hover-engines, or \"microwings,\" as they're known in the trade, these tiny devices are able to lift a few grams at a time. Gather enough of them, and you can lift impressively large things."
	organ_flags = ORGAN_ROBOTIC
	sprite_accessory_override = /datum/sprite_accessory/wings/robotic

///skeletal wings, which relate to skeletal races.
/obj/item/organ/wings/skeleton
	name = "skeletal wings"
	desc = "Powered by pure edgy-teenager-notebook-scribblings. Just kidding. But seriously, how do these keep you flying?!"
	sprite_accessory_override = /datum/sprite_accessory/wings/skeleton

///fly wings, which relate to flies.
/obj/item/organ/wings/fly
	name = "fly wings"
	desc = "Fly as a fly."
	sprite_accessory_override = /datum/sprite_accessory/wings/fly

///slime wings, which relate to slimes.
/obj/item/organ/wings/slime
	name = "slime wings"
	desc = "How does something so squishy even fly?"
	sprite_accessory_override = /datum/sprite_accessory/wings/slime

#undef FUNCTIONAL_WING_FORCE
