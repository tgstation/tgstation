//holodeck program flags, holodeck computers can only load programs that have any of their access flags

///the access flag for the normal station holodeck and normal programs
#define STATION_HOLODECK		(1<<0)
///additional flag for custom holodecks, used by nothing
#define CUSTOM_HOLODECK_ONE		(1<<1)
///additional flag for custom holodecks, used by nothing
#define CUSTOM_HOLODECK_TWO		(1<<2)
///you should never see this in game, used for debugging purposes
#define HOLODECK_DEBUG			(1<<3)

