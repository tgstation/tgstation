///role below priests, for losing most powers of priests but still being holy.
#define HOLY_ROLE_DEACON 1
///default priestly role
#define HOLY_ROLE_PRIEST 2
///the one who designates the religion
#define HOLY_ROLE_HIGHPRIEST 3

#define ALIGNMENT_GOOD "good"
#define ALIGNMENT_NEUT "neutral"
#define ALIGNMENT_EVIL "evil"

//## which weapons should we use?

///fisticuffs only. will probably be used a lot if the chaplain's weapon is really good
#define FIST_FIGHT 1
///melee weapon condition, default sparring condition.
#define MELEE_ONLY 2
///any weapon is cool... probably a terrible idea against security
#define ANY_WEAPON 3

//
///must use weapons the chaplain makes from their sect. no fist fighting, even! it ensures a fair fight.
// #define RITUAL_WEAPONS 2

//## where should we fight?

// default value - /area/service/chapel

//## what are the stakes? people you've beaten before can only fight in no stakes battles, to prevent farming

///just for fun
#define NO_STAKES 1
///standard stakes, winning gets you a point. losing counts towards standard excommunication.
#define HOLY_MATCH 2
///no stakes god wise, but whomever wins gets all the money of the other
#define MONEY_MATCH 3
///the winner gets the other's soul. you said this was a neutral sect, right?
#define YOUR_SOUL 4

///the left signing part of the contract
#define LEFT_FIELD "left"
