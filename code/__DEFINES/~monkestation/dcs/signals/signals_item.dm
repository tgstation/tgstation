/// Called before an item is compressed by a bluespace compression kit: (mob/user, obj/item/compression_kit/kit)
#define COMSIG_ITEM_PRE_COMPRESS		"item_pre_compress"
	#define COMPONENT_STOP_COMPRESSION	(1 << 0)
	#define COMPONENT_HANDLED_MESSAGE	(1 << 1)
/// Called after an item is compressed by a bluespace compression kit: (mob/user, obj/item/compression_kit/kit)
#define COMSIG_ITEM_COMPRESSED			"item_compressed"
