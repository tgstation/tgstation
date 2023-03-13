/// Big Brother: really simple structured logging, because this is 1984 and I
/// am *always* watching.
///
/// Arguments:
/// - `cat`: The logging category. This should be one of the `DEFINE`s in
///    `__DEFINES/bb_defines.dm`.
/// - `fmt_str`: A formatting string for log consumers. For example,
///   "{user} attacks {target} in the {limb}". You should optimize your format
///   to be concise and understandable.
/// - `ctx...`: Contextual formatting arguments. An associative list of each
///   label present in `fmt_str`. For example,
///   `list(user = mob, target = target, limb = mob.head)`
///
/// Contextual information about each of the provided arguments is provided by
/// `bb_snapshot`, which is defined for all `/datum/`s in
/// `code/modules/logging/bb.dm`. If you have a new datum and you want to log
/// specific information about that datum, consider overriding it!
#define BB_LOG(cat, fmt_str, ctx...) \
	_bb_log_impl(cat, "[__FILE__]:[__LINE__]", fmt_str, list(##ctx))

#define BB_SAY "say"
#define BB_OOC "ooc"
#define BB_ASAY "asay"
#define BB_GAME "game"
#define BB_TCOMMS "tcomms"
#define BB_ATMOS "atmos"
#define BB_RESEARCH "research"
#define BB_WOUND "wound"
#define BB_POINT "point"
#define BB_EMOTE "emote"
#define BB_LEGACY "legacy"
#define BB_COMBAT "combat"
#define BB_SURGERY "surgery"

#define BB_BOXING "boxing"
#define BB_CQC "cqc"
#define BB_KRAV_MAGA = "krav maga"
#define BB_MUSHROOM_PUNCH "mushroom punch"
#define BB_PLASMA_FIST "plasma fist"
#define BB_PSYCHOTIC_BRAWL "psychotic brawling"
#define BB_SLEEPING_CARP "sleeping carp"
#define BB_WRESTLING "wrestling"
#define BB_HULK "hulk"
