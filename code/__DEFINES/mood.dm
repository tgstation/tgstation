#define MOOD_CATEGORY_LEGION_CORE "regenerative core"

// Group types for terror handlers
#define TERROR_HANLDER_SOURCE "source"
#define TERROR_HANDLER_EFFECT "effect"

// Default cooldown for terror messages, to not get spammy
#define TERROR_MESSAGE_CD 30 SECONDS

// Values for terror buildup effects
/// Initial value for effects that apply the component from spooking you
#define TERROR_BUILDUP_INITIAL 100
/// Level at which minor effects start kicking in
#define TERROR_BUILDUP_FEAR 150
/// Level at which major effects start kicking in
#define TERROR_BUILDUP_TERROR 300
/// Level at which we're having a full on panic attack
#define TERROR_BUILDUP_PANIC 500
/// Maximum amount of terror that passive sources can stack
#define TERROR_BUILDUP_PASSIVE_MAXIMUM 600
/// Your heart gives out at this level, should always be higher than TERROR_BUILDUP_PASSIVE_MAXIMUM
#define TERROR_BUILDUP_HEART_ATTACK 800
/// Maximum amount of terror that can be held at once
#define TERROR_BUILDUP_MAXIMUM 1000

// How much terror panic attacks grant
#define PANIC_ATTACK_TERROR_AMOUNT 50
