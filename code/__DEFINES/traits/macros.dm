// This file contains all of the "dynamic" traits and trait sources that can be used
// in a number of versatile and everchanging ways.
// If it uses psuedo-variables like the examples below, it's a macro-trait.


/// From [/datum/element/elevation] for purpose of registering/removing signals and detaching the elevation_core when the trait is absent.
#define TRAIT_TURF_HAS_ELEVATED_OBJ(z) "turf_has_elevated_obj_[z]"

/// The item is magically cursed
#define CURSED_ITEM_TRAIT(item_type) "cursed_item_[item_type]"
/// A trait given by a specific status effect (not sure why we need both but whatever!)
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"
/// Trait given by mech equipment
#define TRAIT_MECH_EQUIPMENT(equipment_type) "mech_equipment_[equipment_type]"
/// Trait applied by element
#define ELEMENT_TRAIT(source) "element_trait_[source]"
