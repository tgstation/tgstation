/*ALL DEFINES RELATED TO COMBAT GO HERE*/

//Damage and status effect defines

//Damage defines //TODO: merge these down to reduce on defines
/// Physical fracturing and warping of the material.
#define BRUTE "brute"
/// Scorching and charring of the material.
#define BURN "burn"
/// Poisoning. Mostly caused by reagents.
#define TOX "toxin"
/// Suffocation.
#define OXY "oxygen"
/// Cellular degredation. Rare and difficult to treat.
#define CLONE "clone"
/// Exhaustion and nonlethal damage.
#define STAMINA "stamina"
/// Brain damage. Should probably be decomissioned and replaced with proper organ damage.
#define BRAIN "brain"

//Damage flag defines //
/// Involves a melee attack or a thrown object.
#define MELEE "melee"
/// Involves a solid projectile.
#define BULLET "bullet"
/// Involves a laser.
#define LASER "laser"
/// Involves an EMP or energy-based projectile.
#define ENERGY "energy"
/// Involves a shockwave, usually from an explosion.
#define BOMB "bomb"
/// Involved in checking wheter a disease can infect or spread. Also involved in xeno neurotoxin.
#define BIO "bio"
/// Involves fire or temperature extremes.
#define FIRE "fire"
/// Involves corrosive substances.
#define ACID "acid"
/// Involved in checking the likelyhood of applying a wound to a mob.
#define WOUND "wound"
/// Involves being eaten
#define CONSUME "consume"

//bitflag damage defines used for suicide_act
#define BRUTELOSS (1<<0)
#define FIRELOSS (1<<1)
#define TOXLOSS (1<<2)
#define OXYLOSS (1<<3)
#define SHAME             (1<<4)
#define MANUAL_SUICIDE (1<<5) //suicide_act will do the actual killing.
#define MANUAL_SUICIDE_NONLETHAL (1<<6)  //when the suicide is conditionally lethal

#define EFFECT_STUN "stun"
#define EFFECT_KNOCKDOWN "knockdown"
#define EFFECT_UNCONSCIOUS "unconscious"
#define EFFECT_PARALYZE "paralyze"
#define EFFECT_IMMOBILIZE "immobilize"
#define EFFECT_STUTTER "stutter"
#define EFFECT_SLUR "slur"
#define EFFECT_EYE_BLUR "eye_blur"
#define EFFECT_DROWSY "drowsy"
#define EFFECT_JITTER "jitter"

//Bitflags defining which status effects could be or are inflicted on a mob
#define CANSTUN (1<<0)
#define CANKNOCKDOWN (1<<1)
#define CANUNCONSCIOUS (1<<2)
#define CANPUSH (1<<3)
#define GODMODE (1<<4)

//Health Defines
#define HEALTH_THRESHOLD_CRIT 0
#define HEALTH_THRESHOLD_FULLCRIT -30
#define HEALTH_THRESHOLD_DEAD -100

#define HEALTH_THRESHOLD_NEARDEATH -90 //Not used mechanically, but to determine if someone is so close to death they hear the other side

//Actual combat defines

//click cooldowns, in tenths of a second, used for various combat actions
#define CLICK_CD_MELEE 8
#define CLICK_CD_THROW 8
#define CLICK_CD_RANGE 4
#define CLICK_CD_RAPID 2
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_BREAKOUT 100
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_RESIST 20
#define CLICK_CD_GRABBING 10
#define CLICK_CD_LOOK_UP 5

//Cuff resist speeds
#define FAST_CUFFBREAK 1
#define INSTANT_CUFFBREAK 2

//Grab levels
#define GRAB_PASSIVE 0
#define GRAB_AGGRESSIVE 1
#define GRAB_NECK 2
#define GRAB_KILL 3

//Grab breakout odds
#define BASE_GRAB_RESIST_CHANCE 60 //base chance for whether or not you can escape from a grab

//slowdown when in softcrit. Note that crawling slowdown will also apply at the same time!
#define SOFTCRIT_ADD_SLOWDOWN 2
//slowdown when crawling
#define CRAWLING_ADD_SLOWDOWN 4

//Attack types for checking shields/hit reactions
#define MELEE_ATTACK 1
#define UNARMED_ATTACK 2
#define PROJECTILE_ATTACK 3
#define THROWN_PROJECTILE_ATTACK 4
#define LEAP_ATTACK 5

//attack visual effects
#define ATTACK_EFFECT_PUNCH "punch"
#define ATTACK_EFFECT_KICK "kick"
#define ATTACK_EFFECT_SMASH "smash"
#define ATTACK_EFFECT_CLAW "claw"
#define ATTACK_EFFECT_SLASH "slash"
#define ATTACK_EFFECT_DISARM "disarm"
#define ATTACK_EFFECT_BITE "bite"
#define ATTACK_EFFECT_MECHFIRE "mech_fire"
#define ATTACK_EFFECT_MECHTOXIN "mech_toxin"
#define ATTACK_EFFECT_BOOP "boop" //Honk

//the define for visible message range in combat
#define SAMETILE_MESSAGE_RANGE 1
#define COMBAT_MESSAGE_RANGE 3
#define DEFAULT_MESSAGE_RANGE 7

//Shove knockdown lengths (deciseconds)
#define SHOVE_KNOCKDOWN_SOLID 20
#define SHOVE_KNOCKDOWN_HUMAN 20
#define SHOVE_KNOCKDOWN_TABLE 20
#define SHOVE_KNOCKDOWN_COLLATERAL 1
#define SHOVE_CHAIN_PARALYZE 30
//Shove slowdown
#define SHOVE_SLOWDOWN_LENGTH 30
#define SHOVE_SLOWDOWN_STRENGTH 0.85 //multiplier
//Shove disarming item list
GLOBAL_LIST_INIT(shove_disarming_types, typecacheof(list(
	/obj/item/gun)))


//Combat object defines

//Embedded objects
///Chance for embedded objects to cause pain (damage user)
#define EMBEDDED_PAIN_CHANCE 15
///Chance for embedded object to fall out (causing pain but removing the object)
#define EMBEDDED_ITEM_FALLOUT 5
///Chance for an object to embed into somebody when thrown
#define EMBED_CHANCE 45
///Coefficient of multiplication for the damage the item does while embedded (this*item.w_class)
#define EMBEDDED_PAIN_MULTIPLIER 2
///Coefficient of multiplication for the damage the item does when it first embeds (this*item.w_class)
#define EMBEDDED_IMPACT_PAIN_MULTIPLIER 4
///The minimum value of an item's throw_speed for it to embed (Unless it has embedded_ignore_throwspeed_threshold set to 1)
#define EMBED_THROWSPEED_THRESHOLD 4
///Coefficient of multiplication for the damage the item does when it falls out or is removed without a surgery (this*item.w_class)
#define EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER 6
///A Time in ticks, total removal time = (this*item.w_class)
#define EMBEDDED_UNSAFE_REMOVAL_TIME 30
///Chance for embedded objects to cause pain every time they move (jostle)
#define EMBEDDED_JOSTLE_CHANCE 5
///Coefficient of multiplication for the damage the item does while
#define EMBEDDED_JOSTLE_PAIN_MULTIPLIER 1
///This percentage of all pain will be dealt as stam damage rather than brute (0-1)
#define EMBEDDED_PAIN_STAM_PCT 0.0
///For thrown weapons, every extra speed it's thrown at above its normal throwspeed will add this to the embed chance
#define EMBED_CHANCE_SPEED_BONUS 10

#define EMBED_HARMLESS list("pain_mult" = 0, "jostle_pain_mult" = 0, "ignore_throwspeed_threshold" = TRUE)
#define EMBED_HARMLESS_SUPERIOR list("pain_mult" = 0, "jostle_pain_mult" = 0, "ignore_throwspeed_threshold" = TRUE, "embed_chance" = 100, "fall_chance" = 0.1)
#define EMBED_POINTY list("ignore_throwspeed_threshold" = TRUE)
#define EMBED_POINTY_SUPERIOR list("embed_chance" = 100, "ignore_throwspeed_threshold" = TRUE)

//Gun weapon weight
#define WEAPON_LIGHT 1
#define WEAPON_MEDIUM 2
#define WEAPON_HEAVY 3
//Gun trigger guards
#define TRIGGER_GUARD_ALLOW_ALL -1
#define TRIGGER_GUARD_NONE 0
#define TRIGGER_GUARD_NORMAL 1
//Gun bolt types
///Gun has a bolt, it stays closed while not cycling. The gun must be racked to have a bullet chambered when a mag is inserted.
///  Example: c20, shotguns, m90
#define BOLT_TYPE_STANDARD 1
///Gun has a bolt, it is open when ready to fire. The gun can never have a chambered bullet with no magazine, but the bolt stays ready when a mag is removed.
///  Example: Some SMGs, the L6
#define BOLT_TYPE_OPEN 2
///Gun has no moving bolt mechanism, it cannot be racked. Also dumps the entire contents when emptied instead of a magazine.
///  Example: Break action shotguns, revolvers
#define BOLT_TYPE_NO_BOLT 3
///Gun has a bolt, it locks back when empty. It can be released to chamber a round if a magazine is in.
///  Example: Pistols with a slide lock, some SMGs
#define BOLT_TYPE_LOCKING 4
//Sawn off nerfs
///accuracy penalty of sawn off guns
#define SAWN_OFF_ACC_PENALTY 25
///added recoil of sawn off guns
#define SAWN_OFF_RECOIL 1

//ammo box sprite defines
///ammo box will always use provided icon state
#define AMMO_BOX_ONE_SPRITE 0
///ammo box will have a different state for each bullet; <icon_state>-<bullets left>
#define AMMO_BOX_PER_BULLET 1
///ammo box will have a different state for full and empty; <icon_state>-max_ammo and <icon_state>-0
#define AMMO_BOX_FULL_EMPTY 2

#define SUPPRESSED_NONE 0
#define SUPPRESSED_QUIET 1 ///standard suppressed
#define SUPPRESSED_VERY 2 /// no message

//Projectile Reflect
#define REFLECT_NORMAL (1<<0)
#define REFLECT_FAKEPROJECTILE (1<<1)

//His Grace.
#define HIS_GRACE_SATIATED 0 //He hungers not. If bloodthirst is set to this, His Grace is asleep.
#define HIS_GRACE_PECKISH 20 //Slightly hungry.
#define HIS_GRACE_HUNGRY 60 //Getting closer. Increases damage up to a minimum of 20.
#define HIS_GRACE_FAMISHED 100 //Dangerous. Increases damage up to a minimum of 25 and cannot be dropped.
#define HIS_GRACE_STARVING 120 //Incredibly close to breaking loose. Increases damage up to a minimum of 30.
#define HIS_GRACE_CONSUME_OWNER 140 //His Grace consumes His owner at this point and becomes aggressive.
#define HIS_GRACE_FALL_ASLEEP 160 //If it reaches this point, He falls asleep and resets.

#define HIS_GRACE_FORCE_BONUS 4 //How much force is gained per kill.

/// ex_act() with EXPLODE_DEVASTATE severity will gib mobs with less than this much bomb armor
#define EXPLODE_GIB_THRESHOLD 50

#define EMP_HEAVY 1
#define EMP_LIGHT 2

#define GRENADE_CLUMSY_FUMBLE 1
#define GRENADE_NONCLUMSY_FUMBLE 2
#define GRENADE_NO_FUMBLE 3

#define BODY_ZONE_HEAD "head"
#define BODY_ZONE_CHEST "chest"
#define BODY_ZONE_L_ARM "l_arm"
#define BODY_ZONE_R_ARM "r_arm"
#define BODY_ZONE_L_LEG "l_leg"
#define BODY_ZONE_R_LEG "r_leg"

#define BODY_ZONE_PRECISE_EYES "eyes"
#define BODY_ZONE_PRECISE_MOUTH "mouth"
#define BODY_ZONE_PRECISE_GROIN "groin"
#define BODY_ZONE_PRECISE_L_HAND "l_hand"
#define BODY_ZONE_PRECISE_R_HAND "r_hand"
#define BODY_ZONE_PRECISE_L_FOOT "l_foot"
#define BODY_ZONE_PRECISE_R_FOOT "r_foot"

//We will round to this value in damage calculations.
#define DAMAGE_PRECISION 0.1

//bullet_act() return values
#define BULLET_ACT_HIT "HIT" //It's a successful hit, whatever that means in the context of the thing it's hitting.
#define BULLET_ACT_BLOCK "BLOCK" //It's a blocked hit, whatever that means in the context of the thing it's hitting.
#define BULLET_ACT_FORCE_PIERCE "PIERCE" //It pierces through the object regardless of the bullet being piercing by default.

#define NICE_SHOT_RICOCHET_BONUS 10 //if the shooter has the NICE_SHOT trait and they fire a ricocheting projectile, add this to the ricochet chance and auto aim angle

/// If a carbon is thrown at a speed faster than normal and impacts something solid, they take extra damage for every extra speed up to this number (see [/mob/living/carbon/proc/throw_impact])
#define CARBON_MAX_IMPACT_SPEED_BONUS 5

/// Alternate attack defines. Return these at the end of procs like afterattack_secondary.
/// Calls the normal attack proc. For example, if returned in afterattack_secondary, will call afterattack.
/// Will continue the chain depending on the return value of the non-alternate proc, like with normal attacks.
#define SECONDARY_ATTACK_CALL_NORMAL 1

/// Cancels the attack chain entirely.
#define SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN 2

/// Proceed with the attack chain, but don't call the normal methods.
#define SECONDARY_ATTACK_CONTINUE_CHAIN 3

//Autofire component
/// Compatible firemode is in the gun. Wait until it's held in the user hands.
#define AUTOFIRE_STAT_IDLE (1<<0)
/// Gun is active and in the user hands. Wait until user does a valid click.
#define AUTOFIRE_STAT_ALERT	(1<<1)
/// Gun is shooting.
#define AUTOFIRE_STAT_FIRING (1<<2)

#define COMSIG_AUTOFIRE_ONMOUSEDOWN "autofire_onmousedown"
	#define COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS (1<<0)
#define COMSIG_AUTOFIRE_SHOT "autofire_shot"
	#define COMPONENT_AUTOFIRE_SHOT_SUCCESS (1<<0)

/// Martial arts attack requested but is not available, allow a check for a regular attack.
#define MARTIAL_ATTACK_INVALID -1

/// Martial arts attack happened but failed, do not allow a check for a regular attack.
#define MARTIAL_ATTACK_FAIL FALSE

/// Martial arts attack happened and succeeded, do not allow a check for a regular attack.
#define MARTIAL_ATTACK_SUCCESS TRUE

/// IF an object is weak against armor, this is the value that any present armor is multiplied by
#define ARMOR_WEAKENED_MULTIPLIER 2

/// Return values used in item/melee/baton/baton_attack.
/// Does a normal item attack.
#define BATON_DO_NORMAL_ATTACK 1
/// The attack has been stopped. Either because the user was clumsy or the attack was blocked.
#define BATON_ATTACK_DONE 2
/// The baton attack is still going. baton_effect() is called.
#define BATON_ATTACKING 3
