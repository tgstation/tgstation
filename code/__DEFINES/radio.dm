// Radios use a large variety of predefined frequencies.

#define MIN_FREE_FREQ 1201  // ------------------------------------------------

#define FREQ_SYNDICATE 1213  // Nuke op comms frequency, dark brown
#define FREQ_CTF_RED 1215  // CTF red team comms frequency, red
#define FREQ_CTF_BLUE 1217  // CTF blue team comms frequency, blue
#define FREQ_CENTCOM 1337  // CentCom comms frequency, gray
#define FREQ_SUPPLY 1347  // Supply comms frequency, light brown
#define FREQ_SERVICE 1349  // Service comms frequency, green
#define FREQ_SCIENCE 1351  // Science comms frequency, plum
#define FREQ_COMMAND 1353  // Command comms frequency, gold
#define FREQ_MEDICAL 1355 // Medical comms frequency, soft blue
#define FREQ_ENGINEERING 1357 // Engineering comms frequency, orange
#define FREQ_SECURITY 1359 // Security comms frequency, red

#define MIN_FREQ 1441 // ------------------------------------------------------

#define FREQ_AI_PRIVATE 1447  // AI private comms frequency, magenta
#define FREQ_COMMON 1459  // Common comms frequency, dark green

#define MAX_FREQ 1489 // ------------------------------------------------------

#define MAX_FREE_FREQ 1599 // -------------------------------------------------

// Transmission types.
#define TRANSMISSION_WIRE 0  // some sort of wired connection, not used
#define TRANSMISSION_RADIO 1  // electromagnetic radiation (default)
#define TRANSMISSION_SUBSPACE 2  // subspace transmission (headsets only)
