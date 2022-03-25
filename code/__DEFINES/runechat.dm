/// How long the chat message's spawn-in animation will occur for
#define CHAT_MESSAGE_SPAWN_TIME 0.2 SECONDS
/// How long the chat message will exist prior to any exponential decay
#define CHAT_MESSAGE_LIFESPAN 5 SECONDS
/// How long the chat message's end of life fading animation will occur for
#define CHAT_MESSAGE_EOL_FADE 0.7 SECONDS
/// Factor of how much the message index (number of messages) will account to exponential decay
#define CHAT_MESSAGE_EXP_DECAY 0.7
/// Factor of how much height will account to exponential decay
#define CHAT_MESSAGE_HEIGHT_DECAY 0.9
/// Approximate height in pixels of an 'average' line, used for height decay
#define CHAT_MESSAGE_APPROX_LHEIGHT 11
/// Max width of chat message in pixels
#define CHAT_MESSAGE_WIDTH 96
/// Max length of chat message in characters
#define CHAT_MESSAGE_MAX_LENGTH 110
/// The dimensions of the chat message icons
#define CHAT_MESSAGE_ICON_SIZE 9

///Base layer of chat elements
#define CHAT_LAYER 1
///Highest possible layer of chat elements
#define CHAT_LAYER_MAX 2
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP 0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z (CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP

///the chatmessage datum was just created and is scheduling the point in time where it starts fading
#define RUNECHAT_SCHEDULE_LIFESPAN "runechat_schedule_lifespan"
///the chatmessage datum has started to fade and is scheduling the point in time where it gets deleted
#define RUNECHAT_SCHEDULE_DELETION "runechat_schedule_lifespan"
///the runechat datum must split off the images for part of its clients into a new canon timeline
#define RUNECHAT_SCHEDULE_SPLIT_CANON_EVENT "runechat_schedule_split_canon_event"
