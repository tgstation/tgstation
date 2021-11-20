// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of ClearFromParent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_PARENT_QDELETING "parent_qdeleting"
/// generic topic handler (usr, href_list)
#define COMSIG_TOPIC "handle_topic"
/// handler for vv_do_topic (usr, href_list)
#define COMSIG_VV_TOPIC "vv_topic"
	#define COMPONENT_VV_HANDLED (1<<0)
/// from datum ui_act (usr, action)
#define COMSIG_UI_ACT "COMSIG_UI_ACT"

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"
// /datum/species signals

///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_GAIN "species_gain"
///from datum/species/on_species_loss(): (datum/species/lost_species)
#define COMSIG_SPECIES_LOSS "species_loss"

// /datum/song signals

///sent to the instrument when a song starts playing
#define COMSIG_SONG_START "song_start"
///sent to the instrument when a song stops playing
#define COMSIG_SONG_END "song_end"

/*******Component Specific Signals*******/
//Janitor

///(): Returns bitflags of wet values.
#define COMSIG_TURF_IS_WET "check_turf_wet"
///(max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"

///Called on an object to "clean it", such as removing blood decals/overlays, etc. The clean types bitfield is sent with it. Return TRUE if any cleaning was necessary and thus performed.
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"
	///Returned by cleanable components when they are cleaned.
	#define COMPONENT_CLEANED (1<<0)


//Creamed

///called when you wash your face at a sink: (num/strength)
#define COMSIG_COMPONENT_CLEAN_FACE_ACT "clean_face_act"
//Customizable

///called when an atom with /datum/component/customizable_reagent_holder is customized (obj/item/I)
#define COMSIG_ATOM_CUSTOMIZED "atom_customized"
///called when an item is used as an ingredient: (atom/customized)
#define COMSIG_ITEM_USED_AS_INGREDIENT "item_used_as_ingredient"
///called when an edible ingredient is added: (datum/component/edible/ingredient)
#define COMSIG_EDIBLE_INGREDIENT_ADDED "edible_ingredient_added"
// /datum/component/storage signals

///() - returns bool.
#define COMSIG_CONTAINS_STORAGE "is_storage"
///(obj/item/inserting, mob/user, silent, force) - returns bool
#define COMSIG_TRY_STORAGE_INSERT "storage_try_insert"
///(mob/show_to, force) - returns bool.
#define COMSIG_TRY_STORAGE_SHOW "storage_show_to"
///(mob/hide_from) - returns bool
#define COMSIG_TRY_STORAGE_HIDE_FROM "storage_hide_from"
///returns bool
#define COMSIG_TRY_STORAGE_HIDE_ALL "storage_hide_all"
///(newstate)
#define COMSIG_TRY_STORAGE_SET_LOCKSTATE "storage_lock_set_state"
///() - returns bool. MUST CHECK IF STORAGE IS THERE FIRST!
#define COMSIG_IS_STORAGE_LOCKED "storage_get_lockstate"
///(type, atom/destination, amount = INFINITY, check_adjacent, force, mob/user, list/inserted) - returns bool - type can be a list of types.
#define COMSIG_TRY_STORAGE_TAKE_TYPE "storage_take_type"
///(type, amount = INFINITY, force = FALSE). Force will ignore max_items, and amount is normally clamped to max_items.
#define COMSIG_TRY_STORAGE_FILL_TYPE "storage_fill_type"
///(obj, new_loc, force = FALSE) - returns bool
#define COMSIG_TRY_STORAGE_TAKE "storage_take_obj"
///(loc) - returns bool - if loc is null it will dump at parent location.
#define COMSIG_TRY_STORAGE_QUICK_EMPTY "storage_quick_empty"
///(list/list_to_inject_results_into, recursively_search_inside_storages = TRUE)
#define COMSIG_TRY_STORAGE_RETURN_INVENTORY "storage_return_inventory"
///(obj/item/insertion_candidate, mob/user, silent) - returns bool
#define COMSIG_TRY_STORAGE_CAN_INSERT "storage_can_equip"

// /datum/component/swabbing signals
#define COMSIG_SWAB_FOR_SAMPLES "swab_for_samples" ///Called when you try to swab something using the swabable component, includes a mutable list of what has been swabbed so far so it can be modified.
	#define COMPONENT_SWAB_FOUND (1<<0)

// /datum/component/transforming signals

/// From /datum/component/transforming/proc/on_attack_self(obj/item/source, mob/user): (obj/item/source, mob/user, active)
#define COMSIG_TRANSFORMING_PRE_TRANSFORM "transforming_pre_transform"
	/// Return COMPONENT_BLOCK_TRANSFORM to prevent the item from transforming.
	#define COMPONENT_BLOCK_TRANSFORM (1<<0)
/// From /datum/component/transforming/proc/do_transform(obj/item/source, mob/user): (obj/item/source, mob/user, active)
#define COMSIG_TRANSFORMING_ON_TRANSFORM "transforming_on_transform"
	/// Return COMPONENT_NO_DEFAULT_MESSAGE to prevent the transforming component from displaying the default transform message / sound.
	#define COMPONENT_NO_DEFAULT_MESSAGE (1<<0)

// /datum/component/two_handed signals

///from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"
	#define COMPONENT_TWOHANDED_BLOCK_WIELD (1<<0)
///from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"

// /datum/element/movetype_handler signals
/// Called when the floating anim has to be temporarily stopped and restarted later: (timer)
#define COMSIG_PAUSE_FLOATING_ANIM "pause_floating_anim"
/// From base of datum/element/movetype_handler/on_movement_type_trait_gain: (flag, old_movement_type)
#define COMSIG_MOVETYPE_FLAG_ENABLED "movetype_flag_enabled"
/// From base of datum/element/movetype_handler/on_movement_type_trait_loss: (flag, old_movement_type)
#define COMSIG_MOVETYPE_FLAG_DISABLED "movetype_flag_disabled"

// /datum/action signals

///from base of datum/action/proc/Trigger(): (datum/action)
#define COMSIG_ACTION_TRIGGER "action_trigger"
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)
// /datum/component/container_item
/// (atom/container, mob/user) - returns bool
#define COMSIG_CONTAINER_TRY_ATTACH "container_try_attach"

// /datum/element/light_eater
///from base of [/datum/element/light_eater/proc/table_buffet]: (list/light_queue, datum/light_eater)
#define COMSIG_LIGHT_EATER_QUEUE "light_eater_queue"
///from base of [/datum/element/light_eater/proc/devour]: (datum/light_eater)
#define COMSIG_LIGHT_EATER_ACT "light_eater_act"
	///Prevents the default light eater behavior from running in case of immunity or custom behavior
	#define COMPONENT_BLOCK_LIGHT_EATER (1<<0)
///from base of [/datum/element/light_eater/proc/devour]: (atom/eaten_light)
#define COMSIG_LIGHT_EATER_DEVOUR "light_eater_devour"
// Merger datum signals
/// Called on the object being added to a merger group: (datum/merger/new_merger)
#define COMSIG_MERGER_ADDING "comsig_merger_adding"
/// Called on the object being removed from a merger group: (datum/merger/old_merger)
#define COMSIG_MERGER_REMOVING "comsig_merger_removing"
/// Called on the merger after finishing a refresh: (list/leaving_members, list/joining_members)
#define COMSIG_MERGER_REFRESH_COMPLETE "comsig_merger_refresh_complete"
/// Exoprobe adventure finished: (result) result is ADVENTURE_RESULT_??? values
#define COMSIG_ADVENTURE_FINISHED "adventure_done"

/// Sent on initial adventure qualities generation from /datum/adventure/proc/initialize_qualities(): (list/quality_list)
#define COMSIG_ADVENTURE_QUALITY_INIT "adventure_quality_init"

/// Sent on adventure node delay start: (delay_time, delay_message)
#define COMSIG_ADVENTURE_DELAY_START "adventure_delay_start"
/// Sent on adventure delay finish: ()
#define COMSIG_ADVENTURE_DELAY_END "adventure_delay_end"

/// Exoprobe status changed : ()
#define COMSIG_EXODRONE_STATUS_CHANGED "exodrone_status_changed"

// Scanner controller signals
/// Sent on begingging of new scan : (datum/exoscan/new_scan)
#define COMSIG_EXOSCAN_STARTED "exoscan_started"
/// Sent on successful finish of exoscan: (datum/exoscan/finished_scan)
#define COMSIG_EXOSCAN_FINISHED "exoscan_finished"

// Exosca signals
/// Sent on exoscan failure/manual interruption: ()
#define COMSIG_EXOSCAN_INTERRUPTED "exoscan_interrupted"
