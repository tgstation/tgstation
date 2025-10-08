#define FUNCTIONAL_WING_FORCE 2.25 NEWTONS
#define FUNCTIONAL_WING_STABILIZATION 4.5 NEWTONS

///hud action for starting and stopping flight
/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/Activate()
	var/mob/living/carbon/human/human = owner
	var/obj/item/organ/wings/functional/wings = human.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(wings?.can_fly())
		wings.toggle_flight(human)

///The true wings that you can use to fly and shit (you cant actually shit with them)
/obj/item/organ/wings/functional
	///The flight action object
	var/datum/action/innate/flight/fly

	bodypart_overlay = /datum/bodypart_overlay/mutant/wings/functional

	///Are our wings open or closed?
	var/wings_open = FALSE
	///We cant hide this wings in suit
	var/cant_hide = FALSE

	// grind_results = list(/datum/reagent/flightpotion = 5)
	food_reagents = list(/datum/reagent/flightpotion = 5)

	var/drift_force = FUNCTIONAL_WING_FORCE
	var/stabilizer_force = FUNCTIONAL_WING_STABILIZATION

/obj/item/organ/wings/functional/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/jetpack, \
		TRUE, \
		drift_force, \
		stabilizer_force, \
		COMSIG_WINGS_OPENED, \
		COMSIG_WINGS_CLOSED, \
		null, \
		CALLBACK(src, PROC_REF(can_fly)), \
		CALLBACK(src, PROC_REF(can_fly)), \
	)

/obj/item/organ/wings/functional/Destroy()
	QDEL_NULL(fly)
	return ..()

/obj/item/organ/wings/functional/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()

	if(QDELETED(fly))
		fly = new
	fly.Grant(receiver)

/obj/item/organ/wings/functional/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	fly?.Remove(organ_owner)
	if(wings_open)
		toggle_flight(organ_owner)

/obj/item/organ/wings/functional/on_life(seconds_per_tick, times_fired)
	. = ..()
	handle_flight(owner)

///Called on_life(). Handle flight code and check if we're still flying
/obj/item/organ/wings/functional/proc/handle_flight(mob/living/carbon/human/human)
	if(!HAS_TRAIT_FROM(human, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
		return FALSE
	if(!can_fly())
		toggle_flight(human)
		return FALSE
	return TRUE

///Check if we're still eligible for flight (wings covered, atmosphere too thin, etc)
/obj/item/organ/wings/functional/proc/can_fly()
	var/mob/living/carbon/human/human = owner
	if(human.stat || human.body_position == LYING_DOWN || isnull(human.client))
		return FALSE
	//Jumpsuits have tail holes, so it makes sense they have wing holes too
	if(!cant_hide && (human.obscured_slots & HIDEJUMPSUIT))
		to_chat(human, span_warning("Your clothing blocks your wings from extending!"))
		return FALSE
	var/turf/location = get_turf(human)
	if(!location)
		return FALSE

	var/datum/gas_mixture/environment = location.return_air()
	if(environment?.return_pressure() < HAZARD_LOW_PRESSURE + 10)
		to_chat(human, span_warning("The atmosphere is too thin for you to fly!"))
		return FALSE
	return TRUE

///Slipping but in the air?
/obj/item/organ/wings/functional/proc/fly_slip(mob/living/carbon/human/human)
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
/obj/item/organ/wings/functional/proc/toggle_flight(mob/living/carbon/human/human)
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

///SPREAD OUR WINGS AND FLLLLLYYYYYY
/obj/item/organ/wings/functional/proc/open_wings()
	var/datum/bodypart_overlay/mutant/wings/functional/overlay = bodypart_overlay
	overlay.open_wings()
	wings_open = TRUE
	owner.update_body_parts()
	SEND_SIGNAL(src, COMSIG_WINGS_OPENED, owner)

///close our wings
/obj/item/organ/wings/functional/proc/close_wings()
	var/datum/bodypart_overlay/mutant/wings/functional/overlay = bodypart_overlay
	wings_open = FALSE
	overlay.close_wings()
	owner.update_body_parts()

	if(isturf(owner?.loc))
		var/turf/location = loc
		location.Entered(src, NONE)

	SEND_SIGNAL(src, COMSIG_WINGS_CLOSED, owner)

///Bodypart overlay of function wings, including open and close functionality!
/datum/bodypart_overlay/mutant/wings/functional
	///Are our wings currently open? Change through open_wings or close_wings()
	VAR_PRIVATE/wings_open = FALSE
	///Feature render key for opened wings
	var/open_feature_key = "wingsopen"

/datum/bodypart_overlay/mutant/wings/functional/get_global_feature_list()
	if(wings_open)
		return SSaccessories.wings_open_list
	else
		return SSaccessories.wings_list

///Update our wingsprite to the open wings variant
/datum/bodypart_overlay/mutant/wings/functional/proc/open_wings()
	wings_open = TRUE
	feature_key = open_feature_key
	set_appearance_from_name(sprite_datum.name) //It'll look for the same name again, but this time from the open wings list

///Update our wingsprite to the closed wings variant
/datum/bodypart_overlay/mutant/wings/functional/proc/close_wings()
	wings_open = FALSE
	feature_key = initial(feature_key)
	set_appearance_from_name(sprite_datum.name)

/datum/bodypart_overlay/mutant/wings/functional/generate_icon_cache()
	. = ..()
	. += wings_open ? "open" : "closed"

///angel wings, which relate to humans. comes with holiness.
/obj/item/organ/wings/functional/angel
	name = "angel wings"
	desc = "Holier-than-thou attitude not included."
	sprite_accessory_override = /datum/sprite_accessory/wings_open/angel

	organ_traits = list(TRAIT_HOLY)

///dragon wings, which relate to lizards.
/obj/item/organ/wings/functional/dragon
	name = "dragon wings"
	desc = "Hey, HEY- NOT lizard wings. Dragon wings. Mighty dragon wings."
	sprite_accessory_override = /datum/sprite_accessory/wings/dragon

///robotic wings, which relate to androids.
/obj/item/organ/wings/functional/robotic
	name = "robotic wings"
	desc = "Using microscopic hover-engines, or \"microwings,\" as they're known in the trade, these tiny devices are able to lift a few grams at a time. Gather enough of them, and you can lift impressively large things."
	organ_flags = ORGAN_ROBOTIC
	sprite_accessory_override = /datum/sprite_accessory/wings/robotic

///skeletal wings, which relate to skeletal races.
/obj/item/organ/wings/functional/skeleton
	name = "skeletal wings"
	desc = "Powered by pure edgy-teenager-notebook-scribblings. Just kidding. But seriously, how do these keep you flying?!"
	sprite_accessory_override = /datum/sprite_accessory/wings/skeleton

/obj/item/organ/wings/functional/moth/make_flap_sound(mob/living/carbon/wing_owner)
	playsound(wing_owner, 'sound/mobs/humanoids/moth/moth_flutter.ogg', 50, TRUE)

///mothra wings, which relate to moths.
/obj/item/organ/wings/functional/moth/mothra
	name = "mothra wings"
	desc = "Fly like the mighty mothra of legend once did."
	sprite_accessory_override = /datum/sprite_accessory/wings/mothra

///megamoth wings, which relate to moths as an alternate choice. they're both pretty cool.
/obj/item/organ/wings/functional/moth/megamoth
	name = "megamoth wings"
	desc = "Don't get murderous."
	sprite_accessory_override = /datum/sprite_accessory/wings/megamoth

///fly wings, which relate to flies.
/obj/item/organ/wings/functional/fly
	name = "fly wings"
	desc = "Fly as a fly."
	sprite_accessory_override = /datum/sprite_accessory/wings/fly

///slime wings, which relate to slimes.
/obj/item/organ/wings/functional/slime
	name = "slime wings"
	desc = "How does something so squishy even fly?"
	sprite_accessory_override = /datum/sprite_accessory/wings/slime

#undef FUNCTIONAL_WING_FORCE
#undef FUNCTIONAL_WING_STABILIZATION
