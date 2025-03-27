///Вызывается когда вампир повышает ранг: (datum/bloodsucker_datum, mob/owner, mob/target)
#define BLOODSUCKER_RANK_UP "bloodsucker_rank_up"
///Вызывается когда вампир взаимодействует с подданым на стойке подношения.
#define BLOODSUCKER_INTERACT_WITH_VASSAL "bloodsucker_interact_with_vassal"
///Вызывается когда вампир повышает подданого, до подданого любимчика: (datum/vassal_datum, mob/master)
#define BLOODSUCKER_MAKE_FAVORITE "bloodsucker_make_favorite"
///Вызывается когда вампир успешно создал подданого: (datum/bloodsucker_datum)
#define BLOODSUCKER_MADE_VASSAL "bloodsucker_made_vassal"
///Вызывается когда вампир выходит из Торпора.
#define BLOODSUCKER_EXIT_TORPOR "bloodsucker_exit_torpor"
///Вызывается когда вампир достигает финальной смерти.
#define BLOODSUCKER_FINAL_DEATH "bloodsucker_final_death"
	///Становится ли вампир пылью после финальной смерти
	#define DONT_DUST (1<<0)
///Вызывается когда вампир ломает маскарад
#define COMSIG_BLOODSUCKER_BROKE_MASQUERADE "comsig_bloodsucker_broke_masquerade"
///Вызывается когда вампир впадает в безумие
#define BLOODSUCKER_ENTERS_FRENZY "bloodsucker_enters_frenzy"
///Вызывается когда вампир выходит из безумия
#define BLOODSUCKER_EXITS_FRENZY "bloodsucker_exits_frenzy"

#define MARTIALART_FRENZYGRAB "frenzy grabbing"

/**
 * Blood-level defines
 */
#define BS_BLOOD_VOLUME_MAX_REGEN 700
#define TORTURE_BLOOD_HALF_COST 8
#define TORTURE_CONVERSION_COST 50
#define FRENZY_MINIMUM_THRESHOLD_ENTER 25
#define FRENZY_EXTRA_BLOOD_NEEDED 50

/**
 * Vassal defines
 */
#define VASSALIZATION_ALLOWED 0
#define VASSALIZATION_DISLOYAL 1
#define VASSALIZATION_BANNED 2

/**
 * Cooldown defines
 * Used in Cooldowns Bloodsuckers use to prevent spamming
 */
#define BLOODSUCKER_SPAM_HEALING (15 SECONDS)
#define BLOODSUCKER_SPAM_MASQUERADE (60 SECONDS)

#define BLOODSUCKER_SPAM_SOL (30 SECONDS)

/**
 * Clan defines
 */
#define CLAN_NONE "Caitiff"
#define CLAN_BRUJAH "Brujah Clan"
#define CLAN_TOREADOR "Toreador Clan"
#define CLAN_NOSFERATU "Nosferatu Clan"
#define CLAN_TREMERE "Tremere Clan"
#define CLAN_GANGREL "Gangrel Clan"
#define CLAN_VENTRUE "Ventrue Clan"
#define CLAN_MALKAVIAN "Malkavian Clan"
#define CLAN_TZIMISCE "Tzimisce Clan"
#define CLAN_VASSAL "your Master"

#define TREMERE_VASSAL "tremere_vassal"
#define FAVORITE_VASSAL "favorite_vassal"
#define REVENGE_VASSAL "revenge_vassal"
#define DISCORDANT_VASSAL "discordant_vassal"

/**
 * Power defines
 */
#define BP_CANT_USE_IN_TORPOR (1<<0)
#define BP_CANT_USE_IN_FRENZY (1<<1)
#define BP_CANT_USE_WHILE_STAKED (1<<2)
#define BP_CANT_USE_WHILE_INCAPACITATED (1<<3)
#define BP_CANT_USE_WHILE_UNCONSCIOUS (1<<4)

#define BLOODSUCKER_CAN_BUY (1<<0)
#define BLOODSUCKER_DEFAULT_POWER (1<<1)
#define TREMERE_CAN_BUY (1<<2)
#define VASSAL_CAN_BUY (1<<3)
#define BRUJAH_DEFAULT_POWER (1<<4)

#define BP_AM_TOGGLE (1<<0)
#define BP_AM_SINGLEUSE (1<<1)
#define BP_AM_STATIC_COOLDOWN (1<<2)
#define BP_AM_COSTLESS_UNCONSCIOUS (1<<3)
#define BP_AM_VERY_DYNAMIC_COOLDOWN (1<<4)

/**
 * Sol signals & Defines
 */
#define COMSIG_SOL_RANKUP_BLOODSUCKERS "comsig_sol_rankup_bloodsuckers"
#define COMSIG_SOL_RISE_TICK "comsig_sol_rise_tick"
#define COMSIG_SOL_NEAR_START "comsig_sol_near_start"
#define COMSIG_SOL_END "comsig_sol_end"
#define COMSIG_SOL_WARNING_GIVEN "comsig_sol_warning_given"
#define COMSIG_BLOODSUCKER_ON_LIFETICK "comsig_bloodsucker_on_lifetick"

#define DANGER_LEVEL_FIRST_WARNING 1
#define DANGER_LEVEL_SECOND_WARNING 2
#define DANGER_LEVEL_THIRD_WARNING 3
#define DANGER_LEVEL_SOL_ROSE 4
#define DANGER_LEVEL_SOL_ENDED 5

/**
 * Clan defines
 *
 * This is stuff that is used solely by Clans for clan-related activity.
 */
#define BLOODSUCKER_DRINK_NORMAL "bloodsucker_drink_normal"
#define BLOODSUCKER_DRINK_SNOBBY "bloodsucker_drink_snobby"
#define BLOODSUCKER_DRINK_INHUMANELY "bloodsucker_drink_imhumanely"

/**
 * Role defines
 */
#define ROLE_BLOODSUCKER "Bloodsucker"
#define ROLE_VAMPIRICACCIDENT "Vampiric Accident"
#define ROLE_BLOODSUCKERBREAKOUT "Bloodsucker Breakout"

/**
 * Miscellaneous defines
 *
 * (Defines for things too trivial to warrant their own category so we'll just call them "misc".)
 */
#define BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS 4

/**
 * Sources
 */
#define BLOODSUCKER_TRAIT "bloodsucker_trait"
#define FEED_TRAIT "feed_trait"
#define FRENZY_TRAIT "frenzy_trait"

/**
 * Traits
 */
#define TRAIT_MASQUERADE "masquerade"
#define TRAIT_COLDBLOODED "coldblooded"

//Bloodsuckers defines ended//
