/// Called before an item is compressed by a bluespace compression kit: (mob/user, obj/item/compression_kit/kit)
#define COMSIG_ITEM_PRE_COMPRESS		"item_pre_compress"
	#define COMPONENT_STOP_COMPRESSION	(1 << 0)
	#define COMPONENT_HANDLED_MESSAGE	(1 << 1)
/// Called after an item is compressed by a bluespace compression kit: (mob/user, obj/item/compression_kit/kit)
#define COMSIG_ITEM_COMPRESSED			"item_compressed"

/// Called when a clock cultist uses a clockwork slab: (obj/item/clockwork/clockwork_slab/slab)
#define COMSIG_CLOCKWORK_SLAB_USED "clockwork_slab_used"

/// the comsig for clockwork items checking turf
#define COMSIG_CHECK_TURF_CLOCKWORK "check_turf_clockwork"
