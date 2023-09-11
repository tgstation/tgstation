// /datum/component/two_handed signals

///from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/living/carbon/user)
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"
	#define COMPONENT_TWOHANDED_BLOCK_WIELD (1<<0)
///from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/living/carbon/user)
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"
///from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/living/carbon/user, force, sharpened_increase, require_twohands)
#define COMSIG_TWOHANDED_POST_WIELD "comsig_twohanded_post_wield"
///from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/living/carbon/user, force, sharpened_increase, require_twohands)
#define COMSIG_TWOHANDED_POST_UNWIELD "comsig_twohanded_post_unwield"
