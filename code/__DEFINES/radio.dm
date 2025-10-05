// Radios use a large variety of predefined frequencies.

//say based modes like binary are in living/say.dm

#define RADIO_CHANNEL_COMMON "Common"
#define RADIO_KEY_COMMON ";"
#define RADIO_COLOR_COMMON "#1ecc43"

#define RADIO_CHANNEL_SECURITY "Security"
#define RADIO_KEY_SECURITY "s"
#define RADIO_TOKEN_SECURITY ":s"
#define RADIO_COLOR_SECURITY "#dd3535"

#define RADIO_CHANNEL_ENGINEERING "Engineering"
#define RADIO_KEY_ENGINEERING "e"
#define RADIO_TOKEN_ENGINEERING ":e"
#define RADIO_COLOR_ENGINEERING "#f37746"

#define RADIO_CHANNEL_COMMAND "Command"
#define RADIO_KEY_COMMAND "c"
#define RADIO_TOKEN_COMMAND ":c"
#define RADIO_COLOR_COMMAND "#fcdf03"

#define RADIO_CHANNEL_SCIENCE "Science"
#define RADIO_KEY_SCIENCE "n"
#define RADIO_TOKEN_SCIENCE ":n"
#define RADIO_COLOR_SCIENCE "#c68cfa"

#define RADIO_CHANNEL_MEDICAL "Medical"
#define RADIO_KEY_MEDICAL "m"
#define RADIO_TOKEN_MEDICAL ":m"
#define RADIO_COLOR_MEDICAL "#57b8f0"

#define RADIO_CHANNEL_SUPPLY "Supply"
#define RADIO_KEY_SUPPLY "u"
#define RADIO_TOKEN_SUPPLY ":u"
#define RADIO_COLOR_SUPPLY "#b88646"

#define RADIO_CHANNEL_SERVICE "Service"
#define RADIO_KEY_SERVICE "v"
#define RADIO_TOKEN_SERVICE ":v"
#define RADIO_COLOR_SERVICE "#6ca729"

#define RADIO_CHANNEL_AI_PRIVATE "AI Private"
#define RADIO_KEY_AI_PRIVATE "o"
#define RADIO_TOKEN_AI_PRIVATE ":o"
#define RADIO_COLOR_AI_PRIVATE "#d65d95"

#define RADIO_CHANNEL_ENTERTAINMENT "Entertainment"
#define RADIO_KEY_ENTERTAINMENT "p"
#define RADIO_TOKEN_ENTERTAINMENT ":p"
#define RADIO_COLOR_ENTERTAIMENT "#79c5a8"

#define STATUS_DISPLAY_RELAY "Captain-Cast"

#define RADIO_CHANNEL_SYNDICATE "Syndicate"
#define RADIO_KEY_SYNDICATE "t"
#define RADIO_TOKEN_SYNDICATE ":t"
#define RADIO_COLOR_SYNDICATE "#8f4a4b"

#define RADIO_CHANNEL_CENTCOM "CentCom"
#define RADIO_KEY_CENTCOM "y"
#define RADIO_TOKEN_CENTCOM ":y"
#define RADIO_COLOR_CENTCOM "#2681a5"

#define RADIO_CHANNEL_UPLINK "Uplink"
#define RADIO_KEY_UPLINK "z"
#define RADIO_TOKEN_UPLINK ":z"
#define RADIO_COLOR_UPLINK "#8f4a4b"

#define RADIO_CHANNEL_CTF_RED "Red Team"
#define RADIO_COLOR_CTF_RED "#ff0000"
#define RADIO_CHANNEL_CTF_BLUE "Blue Team"
#define RADIO_COLOR_CTF_BLUE "#0000ff"
#define RADIO_CHANNEL_CTF_GREEN "Green Team"
#define RADIO_COLOR_GREEN "#00ff00"
#define RADIO_CHANNEL_CTF_YELLOW "Yellow Team"
#define RADIO_COLOR_YELLOW "#d1ba22"


#define MIN_FREE_FREQ 1201 // -------------------------------------------------
// Frequencies are always odd numbers and range from 1201 to 1599.

#define FREQ_UPLINK 1211	// Dummy loopback frequency, used for radio uplink. Not seen in game.
#define FREQ_SYNDICATE 1213 // Nuke op comms frequency, dark brown
#define FREQ_CTF_RED 1215 // CTF red team comms frequency, red
#define FREQ_CTF_BLUE 1217 // CTF blue team comms frequency, blue
#define FREQ_CTF_GREEN 1219 // CTF green team comms frequency, green
#define FREQ_CTF_YELLOW 1221 // CTF yellow team comms frequency, yellow
#define FREQ_CENTCOM 1337 // CentCom comms frequency, gray
#define FREQ_SUPPLY 1347 // Supply comms frequency, light brown
#define FREQ_SERVICE 1349 // Service comms frequency, green
#define FREQ_SCIENCE 1351 // Science comms frequency, plum
#define FREQ_COMMAND 1353 // Command comms frequency, gold
#define FREQ_MEDICAL 1355 // Medical comms frequency, soft blue
#define FREQ_ENGINEERING 1357 // Engineering comms frequency, orange
#define FREQ_SECURITY 1359 // Security comms frequency, red
#define FREQ_ENTERTAINMENT 1415 // Used by entertainment monitors, cyan
#define FREQ_HOLOGRID_SOLUTION 1433
#define FREQ_STATUS_DISPLAYS 1435

#define MIN_FREQ 1441 // ------------------------------------------------------
// Only the 1441 to 1489 range is freely available for general conversation.
// This represents 1/8th of the available spectrum.

#define FREQ_AI_PRIVATE 1447 // AI private comms frequency, magenta
#define FREQ_PRESSURE_PLATE 1447
#define FREQ_ELECTROPACK 1449
#define FREQ_MAGNETS 1449
#define FREQ_LOCATOR_IMPLANT 1451
#define FREQ_RADIO_NAV_BEACON 1455
#define FREQ_SIGNALER 1457 // the default for new signalers
#define FREQ_COMMON 1459 // Common comms frequency, dark green

#define MIN_UNUSED_FREQ 1461 // Prevents rolling AI Private or Common

#define MAX_FREQ 1489 // ------------------------------------------------------

#define MAX_FREE_FREQ 1599 // -------------------------------------------------

// Transmission types.
#define TRANSMISSION_WIRE 0 // some sort of wired connection, not used
#define TRANSMISSION_RADIO 1 // electromagnetic radiation (default)
#define TRANSMISSION_SUBSPACE 2 // subspace transmission (headsets only)
#define TRANSMISSION_SUPERSPACE 3 // reaches independent (CentCom) radios only

// Filter types, used as an optimization to avoid unnecessary proc calls.
#define RADIO_SIGNALER "signaler"
#define RADIO_AIRLOCK "airlock"
#define RADIO_MAGNETS "magnets"

#define DEFAULT_SIGNALER_CODE 30

//Requests Console
#define REQ_NO_NEW_MESSAGE 0
#define REQ_NORMAL_MESSAGE_PRIORITY 1
#define REQ_HIGH_MESSAGE_PRIORITY 2
#define REQ_EXTREME_MESSAGE_PRIORITY 3

#define ASSISTANCE_REQUEST "Assistance Request"
#define SUPPLY_REQUEST "Supplies Request"
#define INFORMATION_REQUEST "Relay Information"
#define ORE_UPDATE_REQUEST "Ore Update"
#define REPLY_REQUEST "Reply"

///give this to can_receive to specify that there is no restriction on what z level this signal is sent to
#define RADIO_NO_Z_LEVEL_RESTRICTION 0

/// Radio frequency is unlocked and can be ajusted by anyone
#define RADIO_FREQENCY_UNLOCKED 0
/// Radio frequency is locked, unchangeable by players
#define RADIO_FREQENCY_LOCKED 1
/// Radio frequency is locked and unchangeable, but can be unlocked by an emag
#define RADIO_FREQENCY_EMAGGABLE_LOCK 2

///Bitflag for if a headset can use the syndicate radio channel
#define RADIO_SPECIAL_SYNDIE (1<<0)
///Bitflag for if a headset can use the centcom radio channel
#define RADIO_SPECIAL_CENTCOM (1<<1)
///Bitflag for if a headset can use the binary radio channel
#define RADIO_SPECIAL_BINARY (1<<2)
