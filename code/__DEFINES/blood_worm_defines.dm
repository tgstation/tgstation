#define BLOOD_WORM_BLOOD_TO_HEALTH (100 / BLOOD_VOLUME_NORMAL)
#define BLOOD_WORM_HEALTH_TO_BLOOD (BLOOD_VOLUME_NORMAL / 100)

/// The health percentage at which blood worms are forcibly kicked out from their hosts.
#define BLOOD_WORM_EJECT_THRESHOLD 0.1

/// How much faster blood worm hosts bleed. Required because blood worms, unlike people, don't die at ~60% blood, instead they leave hosts at 10% blood, and adults have a ton of blood.
/// This means blood worms are ridiculously strong against one of their own weaknesses without this. Don't make this too high, because blood worms use blood to heal, attack and survive.
#define BLOOD_WORM_BLEED_MOD 1.5

/// Returns a blood worm from the mob if it's a blood worm or the host of one.
#define FIND_BLOOD_WORM(mob) ((isbloodworm(mob) ? mob : null) || ((mob && HAS_TRAIT(mob, TRAIT_BLOOD_WORM_HOST)) ? (locate(/mob/living/basic/blood_worm) in mob) : null))
