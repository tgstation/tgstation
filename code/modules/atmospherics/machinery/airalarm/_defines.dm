#define AALARM_MODE_SCRUBBING 1
#define AALARM_MODE_VENTING 2 //makes draught
#define AALARM_MODE_PANIC 3 //like siphon, but stronger (enables widenet)
#define AALARM_MODE_REPLACEMENT 4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_OFF 5
#define AALARM_MODE_FLOOD 6 //Emagged mode; turns off scrubbers and pressure checks on vents
#define AALARM_MODE_SIPHON 7 //Scrubbers suck air
#define AALARM_MODE_CONTAMINATED 8 //Turns on all filtering and widenet scrubbing.
#define AALARM_MODE_REFILL 9 //just like normal, but with triple the air output

#define AALARM_PRESSURE "pressure"
#define AALARM_TEMPERATURE "temperature"

#define AALARM_BUILD_STAGE_COMPLETE 2
#define AALARM_BUILD_STAGE_NO_WIRES 1
#define AALARM_BUILD_STAGE_NO_CIRCUIT 0

#define AALARM_ALERT_SEVERE 2
#define AALARM_ALERT_MINOR 1
#define AALARM_ALERT_CLEAR 0

#define AALARM_REPORT_TIMEOUT 100
