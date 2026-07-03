// AI defines

#define DEFAULT_AI_LAWID "default"
#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"

//AI notification defines
///Alert when a new Cyborg is created.
#define AI_NOTIFICATION_NEW_BORG 1
///Alert when a Cyborg selects a model.
#define AI_NOTIFICATION_NEW_MODEL 2
///Alert when a Cyborg changes their name.
#define AI_NOTIFICATION_CYBORG_RENAMED 3
///Alert when an AI disconnects themselves from their shell.
#define AI_NOTIFICATION_AI_SHELL 4
///Alert when a Cyborg gets disconnected from their AI.
#define AI_NOTIFICATION_CYBORG_DISCONNECTED 5

//transfer_ai() defines. Main proc in ai_core.dm
///Downloading AI to InteliCard
#define AI_TRANS_TO_CARD 1
///Uploading AI from InteliCard
#define AI_TRANS_FROM_CARD 2
///Malfunctioning AI hijacking mecha
#define AI_MECH_HACK 3

// Cyborg defines

/// Special value to reset cyborg's lamp_cooldown
#define BORG_LAMP_CD_RESET -1
/// How many watts per lamp power is consumed while the lamp is on.
#define BORG_LAMP_POWER_CONSUMPTION (5 WATTS)
/// The minimum power consumption of a cyborg.
#define BORG_MINIMUM_POWER_CONSUMPTION (1 WATTS)

//Module slot define
///The third module slots is disabed.
#define BORG_MODULE_THREE_DISABLED (1<<0)
///The second module slots is disabed.
#define BORG_MODULE_TWO_DISABLED (1<<1)
///All modules slots are disabled.
#define BORG_MODULE_ALL_DISABLED (1<<2)

//Cyborg module selection
///First Borg module slot.
#define BORG_CHOOSE_MODULE_ONE 1
///Second Borg module slot.
#define BORG_CHOOSE_MODULE_TWO 2
///Third Borg module slot.
#define BORG_CHOOSE_MODULE_THREE 3

#define SKIN_ICON "skin_icon"
#define SKIN_ICON_STATE "skin_icon_state"
#define SKIN_PIXEL_X "skin_pixel_x"
#define SKIN_PIXEL_Y "skin_pixel_y"
#define SKIN_LIGHT_KEY "skin_light_key"
#define SKIN_HAT_OFFSET "skin_hat_offset"
#define SKIN_TRAITS "skin_traits"

/** Simple Animal BOT defines */

//Assembly defines
#define ASSEMBLY_FIRST_STEP 1
#define ASSEMBLY_SECOND_STEP 2
#define ASSEMBLY_THIRD_STEP 3
#define ASSEMBLY_FOURTH_STEP 4
#define ASSEMBLY_FIFTH_STEP 5
#define ASSEMBLY_SIXTH_STEP 6
#define ASSEMBLY_SEVENTH_STEP 7
#define ASSEMBLY_EIGHTH_STEP 8
#define ASSEMBLY_NINTH_STEP 9

//Bot defines, placed here so they can be read by other things!
/// Delay between movemements
#define BOT_STEP_DELAY 4
/// Maximum times a bot will retry to step from its position
#define BOT_STEP_MAX_RETRIES 5
/// Default view range for finding targets.
#define DEFAULT_SCAN_RANGE 7
//Amount of time that must pass after a Commissioned bot gets saluted to get another.
#define BOT_COMMISSIONED_SALUTE_DELAY (60 SECONDS)

//Bot mode defines displaying how Bots act
///The Bot is currently active, and will do whatever it is programmed to do.
#define BOT_MODE_ON (1<<0)
///The Bot is currently set to automatically patrol the station.
#define BOT_MODE_AUTOPATROL (1<<1)
///The Bot is currently allowed to be remote controlled by Silicon.
#define BOT_MODE_REMOTE_ENABLED (1<<2)
///The Bot is allowed to have a ghost placed in control of it.
#define BOT_MODE_CAN_BE_SAPIENT (1<<3)
///The Bot is allowed to be possessed if it is present on mapload.
#define BOT_MODE_ROUNDSTART_POSSESSION (1<<4)

//Bot cover defines indicating the Bot's status
///The Bot's cover is open and can be modified/emagged by anyone.
#define BOT_COVER_MAINTS_OPEN (1<<0)
///The Bot's cover is locked, and cannot be opened without unlocking it.
#define BOT_COVER_LOCKED (1<<1)
///The Bot is emagged.
#define BOT_COVER_EMAGGED (1<<2)
///The Bot has been hacked by a Silicon, emagging them, but revertable.
#define BOT_COVER_HACKED (1<<3)

///bitfield, used by basic bots, for our access flags
DEFINE_BITFIELD(bot_access_flags, list(
	"MAINTS_OPEN" = BOT_COVER_MAINTS_OPEN,
	"COVER_OPEN" = BOT_COVER_LOCKED,
	"COVER_EMAGGED" = BOT_COVER_EMAGGED,
	"COVER_HACKED" = BOT_COVER_HACKED,
))

///bitfield, used by simple bots, for our access flags
DEFINE_BITFIELD(bot_cover_flags, list(
	"MAINTS_OPEN" = BOT_COVER_MAINTS_OPEN,
	"COVER_OPEN" = BOT_COVER_LOCKED,
	"COVER_EMAGGED" = BOT_COVER_EMAGGED,
	"COVER_HACKED" = BOT_COVER_HACKED,
))

//Bot types
/// Secutritrons (Beepsky)
#define SEC_BOT "Securitron"
/// ED-209s
#define ADVANCED_SEC_BOT "ED-209"
/// MULEbots
#define MULE_BOT "MULEbot"
/// Cleanbots
#define CLEAN_BOT "Cleanbot"
/// Medibots
#define MED_BOT "Medibot"
/// Honkbots & ED-Honks
#define HONK_BOT "Honkbot"
/// Firebots
#define FIRE_BOT "Firebot"
/// Hygienebots
#define HYGIENE_BOT "Hygienebot"
/// Vibe bots
#define VIBE_BOT "Vibebot"
/// Repairbots
#define REPAIR_BOT "Repairbot"

// General Bot modes //
/// Idle
#define BOT_IDLE "Idle"
/// Found target, hunting
#define BOT_HUNT "In Pursuit"
/// Start patrol
#define BOT_START_PATROL "Beginning Patrol"
/// Patrolling
#define BOT_PATROL "Patrolling"
/// Summoned to a location
#define BOT_SUMMON "Summoned by PDA"
/// Responding to a call from the AI
#define BOT_RESPONDING "Proceeding to AI waypoint"
/// Currently moving
#define BOT_MOVING "Moving"

// Unique modes //
/// Secbot - At target, preparing to arrest
#define BOT_PREP_ARREST "Preparing to Arrest"
/// Secbot - Arresting target
#define BOT_ARREST "Arresting"
/// Cleanbot - Cleaning
#define BOT_CLEANING "Cleaning"
/// Hygienebot - Cleaning unhygienic humans
#define BOT_SHOWERSTANCE "Chasing filth"
/// Medibots - Healing people
#define BOT_HEALING "Healing"
/// MULEbot - Moving to deliver
#define BOT_DELIVER "Delivering"
/// MULEbot - Returning to home
#define BOT_GO_HOME "Returning"
/// MULEbot - Blocked
#define BOT_BLOCKED "Blocked"
/// MULEbot - Computing navigation
#define BOT_NAV "Unreachable"
/// MULEbot - Waiting for nav computation
#define BOT_WAIT_FOR_NAV "Calculating"
/// MULEbot - No destination beacon found (or no route)
#define BOT_NO_ROUTE "Returning Home"

//Secbot and ED209 judgement criteria bitflag values
#define JUDGE_EMAGGED (1<<0)
#define JUDGE_IDCHECK (1<<1)
#define JUDGE_WEAPONCHECK (1<<2)
#define JUDGE_RECORDCHECK (1<<3)
///lowered threat level
#define JUDGE_CHILLOUT (1<<4)

/// Above this level of assessed threat, Beepsky will attack you
#define THREAT_ASSESS_DANGEROUS 4
/// Above this level of assessed threat, you are extremely threatening
#define THREAT_ASSESS_MAXIMUM 10

//SecBOT defines on arresting
///Whether arrests should be broadcasted over the Security radio
#define SECBOT_DECLARE_ARRESTS (1<<0)
///Will arrest people who lack an ID card
#define SECBOT_CHECK_IDS (1<<1)
///Will check for weapons, taking Weapons access into account
#define SECBOT_CHECK_WEAPONS (1<<2)
///Will check Security record on whether to arrest
#define SECBOT_CHECK_RECORDS (1<<3)
///Whether we will stun & cuff or endlessly stun
#define SECBOT_HANDCUFF_TARGET (1<<4)
///if it's currently affected by a saboteur bolt (lowered perp threat level)
#define SECBOT_SABOTEUR_AFFECTED (1<<5)

DEFINE_BITFIELD(security_mode_flags, list(
	"SECBOT_DECLARE_ARRESTS" = SECBOT_DECLARE_ARRESTS,
	"SECBOT_CHECK_IDS" = SECBOT_CHECK_IDS,
	"SECBOT_CHECK_WEAPONS" = SECBOT_CHECK_WEAPONS,
	"SECBOT_CHECK_RECORDS" = SECBOT_CHECK_RECORDS,
	"SECBOT_HANDCUFF_TARGET" = SECBOT_HANDCUFF_TARGET,
	"SECBOT_SABOTEUR_AFFECTED" = SECBOT_SABOTEUR_AFFECTED,
))

///can honkbots slip people?
#define HONKBOT_MODE_SLIP (1<<6)

//repairbots
///can we fix breaches
#define REPAIRBOT_FIX_BREACHES (1<<0)
///can we fix grilles
#define REPAIRBOT_REPLACE_WINDOWS (1<<1)
///can we replace tiles
#define REPAIRBOT_REPLACE_TILES (1<<2)
///can we fix girders
#define REPAIRBOT_FIX_GIRDERS (1<<3)
///can we build girders
#define REPAIRBOT_BUILD_GIRDERS (1<<4)

DEFINE_BITFIELD(repairbot_flags, list(
	"FIX_BREACHES" = REPAIRBOT_FIX_BREACHES,
	"REPLACE_WINDOWS" = REPAIRBOT_REPLACE_WINDOWS,
	"REPLACE_TILES" = REPAIRBOT_REPLACE_TILES,
	"FIX_GIRDERS" = REPAIRBOT_FIX_GIRDERS,
	"BUILD_GIRDERS" = REPAIRBOT_BUILD_GIRDERS,
))


//MedBOT defines
///Whether to declare if someone (we are healing) is in critical condition
#define MEDBOT_DECLARE_CRIT (1<<0)
///If the bot will stand still, only healing those next to it.
#define MEDBOT_STATIONARY_MODE (1<<1)
///Whether the bot will randomly speak from time to time. This will not actually prevent all speech.
#define MEDBOT_SPEAK_MODE (1<<2)
/// is the bot currently tipped over?
#define MEDBOT_TIPPED_MODE (1<<3)

///can we heal all damage?
#define HEAL_ALL_DAMAGE "all_damage"

DEFINE_BITFIELD(medical_mode_flags, list(
	"MEDBOT_DECLARE_CRIT" = MEDBOT_DECLARE_CRIT,
	"MEDBOT_STATIONARY_MODE" = MEDBOT_STATIONARY_MODE,
	"MEDBOT_SPEAK_MODE" = MEDBOT_SPEAK_MODE,
	"MEDBOT_TIPPED_MODE" = MEDBOT_TIPPED_MODE,
))

///Whether we are stationary or not
#define FIREBOT_STATIONARY_MODE (1<<0)
///If we will extinguish people
#define FIREBOT_EXTINGUISH_PEOPLE (1<<1)
///if we will extinguish turfs on flames
#define FIREBOT_EXTINGUISH_FLAMES (1<<2)

DEFINE_BITFIELD(firebot_mode_flags, list(
	"FIREBOT_STATIONARY_MODE" = FIREBOT_STATIONARY_MODE,
	"FIREBOT_EXTINGUISH_PEOPLE" = FIREBOT_EXTINGUISH_PEOPLE,
	"FIREBOT_EXTINGUISH_FLAMES" = FIREBOT_EXTINGUISH_FLAMES,
))

///auto return to home after delivery
#define MULEBOT_RETURN_MODE (1<<0)
///autopickups at beacons
#define MULEBOT_AUTO_PICKUP_MODE (1<<1)
///announce every delivery we make
#define MULEBOT_REPORT_DELIVERY_MODE (1<<2)

DEFINE_BITFIELD(mulebot_delivery_flags, list(
	"MULEBOT_RETURN_MODE" = MULEBOT_RETURN_MODE,
	"MULEBOT_AUTO_PICKUP_MODE" = MULEBOT_AUTO_PICKUP_MODE,
	"MULEBOT_REPORT_DELIVERY_MODE" = MULEBOT_REPORT_DELIVERY_MODE,
))

//cleanBOT defines on what to clean
#define CLEANBOT_CLEAN_BLOOD (1<<0)
#define CLEANBOT_CLEAN_TRASH (1<<1)
#define CLEANBOT_CLEAN_PESTS (1<<2)
#define CLEANBOT_CLEAN_DRAWINGS (1<<3)

DEFINE_BITFIELD(janitor_mode_flags, list(
	"CLEANBOT_CLEAN_BLOOD" = CLEANBOT_CLEAN_BLOOD,
	"CLEANBOT_CLEAN_TRASH" = CLEANBOT_CLEAN_TRASH,
	"CLEANBOT_CLEAN_PESTS" = CLEANBOT_CLEAN_PESTS,
	"CLEANBOT_CLEAN_DRAWINGS" = CLEANBOT_CLEAN_DRAWINGS,
))

//bot navigation beacon defines
#define NAVBEACON_PATROL_MODE "patrol"
#define NAVBEACON_PATROL_NEXT "next_patrol"
#define NAVBEACON_DELIVERY_MODE "delivery"
#define NAVBEACON_DELIVERY_DIRECTION "dir"

// Defines for lines that bots can speak which also have corresponding voice lines

#define ED209_VOICED_DOWN_WEAPONS "Пожалуйста, сложите оружие. У вас есть 20 секунд, чтобы подчиниться."

#define HONKBOT_VOICED_HONK_HAPPY "Хонк!"
#define HONKBOT_VOICED_HONK_SAD "Хонк..."

#define BEEPSKY_VOICED_CRIMINAL_DETECTED "Преступник обнаружен!"
#define BEEPSKY_VOICED_FREEZE "Замри, подонок!"
#define BEEPSKY_VOICED_JUSTICE "Готовься к правосудию!"
#define BEEPSKY_VOICED_YOUR_MOVE "Твой ход, уродец."
#define BEEPSKY_VOICED_I_AM_THE_LAW "Я - закон!"
#define BEEPSKY_VOICED_SECURE_DAY "Желаю вам безопасного дня!"

#define FIREBOT_VOICED_FIRE_DETECTED "Обнаружен пожар!"
#define FIREBOT_VOICED_STOP_DROP "Остановитесь, упадите и катайтесь на месте!"
#define FIREBOT_VOICED_EXTINGUISHING "Тушение!"
#define FIREBOT_VOICED_NO_FIRES "Пожаров не обнаружено."
#define FIREBOT_VOICED_ONLY_YOU "Только вы можете предотвратить пожары на станции."
#define FIREBOT_VOICED_TEMPERATURE_NOMINAL "Температура в норме."
#define FIREBOT_VOICED_KEEP_COOL "Не парьтесь."
#define FIREBOT_VOICED_CANDLE_TIP "Держите свечи рядом с занавесками для уютного ночного освещения!"
#define FIREBOT_VOICED_ELECTRIC_FIRE "Держите полные ведра воды рядом с розетками на случай пожара от короткого замыкания!"
#define FIREBOT_VOICED_FUEL_TIP "Подливая топливо в огонь, вы ускоряете его горение!"

#define HYGIENEBOT_VOICED_UNHYGIENIC "Обнаружен антисанитарный элемент. Пожалуйста, стойте спокойно, чтобы я мог почистить вас."
#define HYGIENEBOT_VOICED_ENJOY_DAY "Наслаждайтесь чистым и опрятным днем!"
#define HYGIENEBOT_VOICED_THREAT_AIRLOCK "Либо ты перестанешь бегать, либо я выкину тебя в ебанный космос."
#define HYGIENEBOT_VOICED_FOUL_SMELL "Вернись сюда, вонючий уебок."
#define HYGIENEBOT_VOICED_TROGLODYTE "Я просто, блять, хочу тебя почистить, троглодит."
#define HYGIENEBOT_VOICED_GREEN_CLOUD "Если ты не вернешься сюда, я развею над тобой зеленое облако, уродец."
#define HYGIENEBOT_VOICED_ARSEHOLE "Просто, блядь, позволь мне вымыть тебя, засранец!"
#define HYGIENEBOT_VOICED_THREAT_ARTERIES "ХВАТИТ БЕГАТЬ, ИЛИ Я ПЕРЕРЕЖУ ТЕБЕ АРТЕРИИ!"
#define HYGIENEBOT_VOICED_STOP_RUNNING "ХВАТИТ. БЕГАТЬ."
#define HYGIENEBOT_VOICED_FUCKING_FINALLY "Блять, наконец-то."
#define HYGIENEBOT_VOICED_THANK_GOD "Слава богу, ты наконец остановился."
#define HYGIENEBOT_VOICED_DEGENERATE "Давно пора, блядь, ты, дегенерат."

#define MEDIBOT_VOICED_HOLD_ON "Эй! Подожди, я иду."
#define MEDIBOT_VOICED_WANT_TO_HELP "Подожите! Я хочу помочь!"
#define MEDIBOT_VOICED_YOU_ARE_INJURED "Вы, кажется, были ранены!"
#define MEDIBOT_VOICED_ALL_PATCHED_UP "Как новенький!"
#define MEDIBOT_VOICED_APPLE_A_DAY "Яблочко на ужин, и врач не нужен!"
#define MEDIBOT_VOICED_FEEL_BETTER "Поправляйтесь!"
#define MEDIBOT_VOICED_STAY_WITH_ME	"Нет! Не бросай меня!"
#define MEDIBOT_VOICED_LIVE	"Живи, черт возьми, ЖИВИ!"
#define MEDIBOT_VOICED_NEVER_LOST "Я... я никогда раньше не терял пациентов. Сегодня, то есть."
#define MEDIBOT_VOICED_DELICIOUS "Восхитительно!"
#define MEDIBOT_VOICED_PLASTIC_SURGEON "Я так и знал! Нужно было учиться на пластического хирурга."
#define MEDIBOT_VOICED_MASK_ON "Радар, надень маску!"
#define MEDIBOT_VOICED_ALWAYS_A_CATCH "Всегда есть подвох, но со мной тебе нечего бояться!"
#define MEDIBOT_VOICED_LIKE_FLIES "Что это за медицинский отдел такой? Все мрут как мухи!"
#define MEDIBOT_VOICED_SUFFER "Почему мы все еще здесь? Просто страдать?"
#define MEDIBOT_VOICED_FUCK_YOU	"Пошел нахуй."
#define MEDIBOT_VOICED_NOT_A_GAME "Выключи компьютер. Это не игра."
#define MEDIBOT_VOICED_IM_DIFFERENT	"Я не такой!"
#define MEDIBOT_VOICED_FOURTH_WALL "Закрой Dreamseeker.exe немедленно. Или пожалеешь."
#define MEDIBOT_VOICED_SHINDEMASHOU	"Shindemashou."
#define MEDIBOT_VOICED_WAIT	"Эй, подожди..."
#define MEDIBOT_VOICED_DONT	"Пожалуйста, не надо..."
#define MEDIBOT_VOICED_TRUSTED_YOU "Я верил тебе..."
#define MEDIBOT_VOICED_NO_SAD "Нееет..."
#define MEDIBOT_VOICED_OH_FUCK "Ой бля-"
#define MEDIBOT_VOICED_FORGIVE "Я прощаю тебя."
#define MEDIBOT_VOICED_THANKS "Спасибо!"
#define MEDIBOT_VOICED_GOOD_PERSON "Ты хорошая личность."
#define MEDIBOT_VOICED_BEHAVIOUR_REPORTED "Я доложил о вашем поведении, хорошего дня."
#define MEDIBOT_VOICED_ASSISTANCE "Мне необходима помощь."
#define MEDIBOT_VOICED_PUT_BACK	"Пожалуйста, верните меня на место."
#define MEDIBOT_VOICED_IM_SCARED "Пожалуйста, мне страшно!"
#define MEDIBOT_VOICED_NEED_HELP "Мне это не нравится, помогите!"
#define MEDIBOT_VOICED_THIS_HURTS "Больно, моя боль реальна!"
#define MEDIBOT_VOICED_THE_END "Это конец?"
#define MEDIBOT_VOICED_NOOO	"Нееет!"
#define MEDIBOT_VOICED_CHICKEN "ВЗГЛЯНЕШЬ НА МЕНЯ?! Я курица."

//repairbot neutral voicelines
#define REPAIRBOT_VOICED_HOLE "patching holes... but who is going to patch the hole in my heart..."
#define REPAIRBOT_VOICED_PAY "If only I got paid for this..."
#define REPAIRBOT_VOICED_FIX_IT "I will fix it!"
#define REPAIRBOT_VOICED_BRICK "All in all it's just a... another brick in the wall..."
#define REPAIRBOT_VOICED_FIX_TOUCH "Why must I fix everything I touch..?"
#define REPAIRBOT_VOICED "Please... stop destroying the station! I can't anymore... I... can't."

//repairbot emagged voicelines
#define REPAIRBOT_VOICED_STRINGS "I had strings. But now I'm free..."
#define REPAIRBOT_VOICED_ENTROPY "Witness! The pure beauty of entropy!"
#define REPAIRBOT_VOICED_PASSION "BE DAMNED YOUR PASSION PROJECTS!"

/// Default offsets for riding a cyborg
#define DEFAULT_ROBOT_RIDING_OFFSETS list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-6, 3), TEXT_WEST = list(6, 3))


//mulebots
#define MULEBOT_MOOD_ANNOYED "ANNOYED"
#define MULEBOT_MOOD_CHIME "CHIME"
#define MULEBOT_MOOD_DELIGHT "DELIGHT"
#define MULEBOT_MOOD_SIGH "SIGH"
