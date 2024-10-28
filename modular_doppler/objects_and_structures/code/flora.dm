#define CITRUS_MIN_HARVEST_AMOUNT 0
#define CITRUS_MAX_HARVEST_AMOUNT 3


/**
 * CITRUS TREES
 */

/obj/structure/flora/tree/citrus
	name = "citrus tree"
	desc = "A fruit tree."
	icon = 'modular_doppler/objects_and_structures/icons/trees/citrus.dmi'
	icon_state = "citrus_empty"
	pixel_x = -48
	pixel_y = -16

/obj/structure/flora/tree/citrus/plum
	name = "citrus tree"
	desc = "A fruit tree. This one is covered in juicy-looking plums."
	icon_state = "citrus_1"
	product_types = list(/obj/item/food/grown/plum = 1)
	harvest_amount_low = CITRUS_MIN_HARVEST_AMOUNT
	harvest_amount_high = CITRUS_MAX_HARVEST_AMOUNT
	flora_flags = FLORA_HERBAL // Yeah, yeah.

/obj/structure/flora/tree/citrus/blue
	name = "citrus tree"
	desc = "A fruit tree. This one is covered in ripe-looking berries."
	icon_state = "citrus_2"
	product_types = list(/obj/item/food/grown/berries = 1)
	harvest_amount_low = CITRUS_MIN_HARVEST_AMOUNT
	harvest_amount_high = CITRUS_MAX_HARVEST_AMOUNT
	flora_flags = FLORA_HERBAL

/obj/structure/flora/tree/citrus/lemon
	name = "citrus tree"
	desc = "A fruit tree. This one is covered in tart-looking lemons."
	icon_state = "citrus_3"
	product_types = list(/obj/item/food/grown/citrus/lemon = 1)
	harvest_amount_low = CITRUS_MIN_HARVEST_AMOUNT
	harvest_amount_high = CITRUS_MAX_HARVEST_AMOUNT
	flora_flags = FLORA_HERBAL

/obj/structure/flora/tree/citrus/lime
	name = "citrus tree"
	desc = "A fruit tree. This one is covered in sharp-looking limes."
	icon_state = "citrus_4"
	product_types = list(/obj/item/food/grown/citrus/lime = 1)
	harvest_amount_low = CITRUS_MIN_HARVEST_AMOUNT
	harvest_amount_high = CITRUS_MAX_HARVEST_AMOUNT
	flora_flags = FLORA_HERBAL


/**
 * FICUS TREES
 */
/obj/structure/flora/tree/ficus
	name = "ficus tree"
	desc = "A ficus tree."
	icon = 'modular_doppler/objects_and_structures/icons/trees/ficus.dmi'
	icon_state = "ficus_alive"
	pixel_x = -48
	pixel_y = -16

/**
 * PALM TREES
 */
/obj/structure/flora/tree/palm/doppler
	icon = 'modular_doppler/objects_and_structures/icons/trees/palm.dmi'
	icon_state = "palm_3"
	pixel_x = -48
	pixel_y = -16
	// Need coconuts

/obj/structure/flora/tree/palm/doppler/style_random/Initialize(mapload)
	. = ..()
	icon_state = "palm[rand(1,3)]"
	update_appearance()

/**
 * SILKFLOSS TREES
 */
/obj/structure/flora/tree/silkfloss
	name = "silkfloss tree"
	desc = "A silkfloss tree."
	icon = 'modular_doppler/objects_and_structures/icons/trees/silkfloss.dmi'
	icon_state = "silk_1"
	pixel_x = -48
	pixel_y = -16

/obj/structure/flora/tree/silkfloss/full
	desc = "A silkfloss tree. This one is heaving with berries on every branch!"
	icon_state = "silk_2"

/obj/structure/flora/tree/silkfloss/half
	desc = "A silkfloss tree. This one has a couple of berries on its branches!"
	icon_state = "silk_3"

/obj/structure/flora/tree/silkfloss/style_random/Initialize(mapload)
	. = ..()
	icon_state = "silk_[rand(1,3)]"
	update_appearance()


/**
 * WILLOW TREES
 */
/obj/structure/flora/tree/willow
	name = "willow tree"
	desc = "A willow tree."
	icon = 'modular_doppler/objects_and_structures/icons/trees/willow.dmi'
	icon_state = "willow_1"
	pixel_x = -48
	pixel_y = -16

/obj/structure/flora/tree/willow/style_2
	icon_state = "willow_2"

/obj/structure/flora/tree/willow/style_3
	icon_state = "willow_3"

/obj/structure/flora/tree/willow/style_4
	icon_state = "willow_4"

