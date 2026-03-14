///role below priests, for losing most powers of priests but still being holy.
#define HOLY_ROLE_DEACON 1
///default priestly role
#define HOLY_ROLE_PRIEST 2
///the one who designates the religion
#define HOLY_ROLE_HIGHPRIEST 3

#define ALIGNMENT_GOOD "good"
#define ALIGNMENT_NEUT "neutral"
#define ALIGNMENT_EVIL "evil"

///how many lines multiplied by tempo should at least be higher than this. Makes people have to choose a long enough song to get the final effect.
#define FESTIVAL_SONG_LONG_ENOUGH 170

/// the probability, when not overridden by sects, for a bible's bless effect to trigger on a smack
#define DEFAULT_SMACK_CHANCE 60

//## which weapons should we use?

// unused but for clarity
#define CONDITION_FIST_FIGHT 1
///can only use the ritual weapons the sparring chaplain makes.
#define CONDITION_CEREMONIAL_ONLY 2
///melee weapon condition, default sparring condition.
#define CONDITION_MELEE_ONLY 3
///any weapon is cool... probably a terrible idea against security
#define CONDITION_ANY_WEAPON 4

//
///must use weapons the chaplain makes from their sect. no fist fighting, even! it ensures a fair fight.
// #define RITUAL_WEAPONS 2

//## where should we fight?

// default value - /area/service/chapel

//## what are the stakes? people you've beaten before can only fight in no stakes battles, to prevent farming

///just for fun
#define STAKES_NONE 1
///standard stakes, winning gets you a point. losing counts towards standard excommunication.
#define STAKES_HOLY_MATCH 2
///no stakes god wise, but whomever wins gets all the money of the other
#define STAKES_MONEY_MATCH 3
///the winner gets the other's soul. you said this was a neutral sect, right?
#define STAKES_YOUR_SOUL 4

///the left signing part of the contract
#define CONTRACT_LEFT_FIELD "left"

///curses the sinner
#define PUNISHMENT_OMEN "omen"
///smites the sinner
#define PUNISHMENT_LIGHTNING "lightningbolt"
///brands the sinner
#define PUNISHMENT_BRAND "brand"

/// Failed to bless the target, beat them over the head
#define BLESSING_FAILED "failed"
/// Blessed unsuccessfully, no limbs to heal, robotic limbs, etc
#define BLESSING_IGNORED "ignored"
/// Blessed successfully by healing or whatever
#define BLESSING_SUCCESS "success"

///The rite will automatically delete itself by the religious tool calling it after it's invoked.
#define RITE_AUTO_DELETE (1<<0)
///The rite can be performed multiple times with a religious tool, so don't delete/null it.
#define RITE_ALLOW_MULTIPLE_PERFORMS (1<<1)
///The rite can only be fully performed once, so we'll completely remove it from the rite list afterwards.
#define RITE_ONE_TIME_USE (1<<2)
