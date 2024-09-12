// /obj/item/clothing
/// (/obj/item/clothing, visor_state) - When a clothing gets its visor toggled.
#define COMSIG_CLOTHING_VISOR_TOGGLE "clothing_visor_toggle"
/// From an undersuit being adjusted: ()
#define COMSIG_CLOTHING_UNDER_ADJUSTED "clothing_under_adjusted"

// Accessory sending to clothing
/// /obj/item/clothing/accessory/successful_attach : (obj/item/clothing/under/attached_to)
/// The accessory, at the point of signal sent, is in the clothing's accessory list / loc
#define COMSIG_CLOTHING_ACCESSORY_ATTACHED "clothing_accessory_pinned"
/// /obj/item/clothing/accessory/detach : (obj/item/clothing/under/detach_from)
/// The accessory, at the point of signal sent, is no longer in the accessory list but may still be in the loc
#define COMSIG_CLOTHING_ACCESSORY_DETACHED "clothing_accessory_unpinned"

// To accessories themselves
/// /obj/item/clothing/accessory/successful_attach : (obj/item/clothing/under/attached_to)
/// The accessory, at the point of signal sent, is in the clothing's accessory list / loc
#define COMSIG_ACCESSORY_ATTACHED "accessory_pinned"
/// /obj/item/clothing/accessory/detach : (obj/item/clothing/under/detach_from)
/// The accessory, at the point of signal sent, is no longer in the accessory list but may still be in the loc
#define COMSIG_ACCESSORY_DETACHED "accessory_unpinned"
