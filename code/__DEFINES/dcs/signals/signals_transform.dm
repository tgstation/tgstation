// /datum/component/transforming signals

/// From /datum/component/transforming/proc/on_attack_self(obj/item/source, mob/user): (obj/item/source, mob/user, active)
#define COMSIG_TRANSFORMING_PRE_TRANSFORM "transforming_pre_transform"
	/// Return COMPONENT_BLOCK_TRANSFORM to prevent the item from transforming.
	#define COMPONENT_BLOCK_TRANSFORM (1<<0)
/// From /datum/component/transforming/proc/do_transform(obj/item/source, mob/user): (obj/item/source, mob/user, active)
#define COMSIG_TRANSFORMING_ON_TRANSFORM "transforming_on_transform"
	/// Return COMPONENT_NO_DEFAULT_MESSAGE to prevent the transforming component from displaying the default transform message / sound.
	#define COMPONENT_NO_DEFAULT_MESSAGE (1<<0)

/// From /datum/component/transforming/proc/on_transform_end(obj/item/source, mob/user): (mob/source, obj/item/transforming, active)
#define COMSIG_MOB_TRANSFORMING_ITEM "mob_transforming_item"
