// APC electronics status:
/// There are no electronics in the APC.
#define APC_ELECTRONICS_MISSING 0
/// The electronics are installed but not secured.
#define APC_ELECTRONICS_INSTALLED 1
/// The electronics are installed and secured.
#define APC_ELECTRONICS_SECURED 2

// APC cover status:
/// The APCs cover is closed.
#define APC_COVER_CLOSED 0
/// The APCs cover is open.
#define APC_COVER_OPENED 1
/// The APCs cover is missing.
#define APC_COVER_REMOVED 2

// APC visuals
/// Pixel offset of the APC from the floor turf
#define APC_PIXEL_OFFSET 25

// APC charging status:
/// The APC is not charging.
#define APC_NOT_CHARGING 0
/// The APC is charging.
#define APC_CHARGING 1
/// The APC is fully charged.
#define APC_FULLY_CHARGED 2

// APC channel status:
/// The APCs power channel is manually set off.
#define APC_CHANNEL_OFF 0
/// The APCs power channel is automatically off.
#define APC_CHANNEL_AUTO_OFF 1
/// The APCs power channel is manually set on.
#define APC_CHANNEL_ON 2
/// The APCs power channel is automatically on.
#define APC_CHANNEL_AUTO_ON 3

#define APC_CHANNEL_IS_ON(channel) (channel >= APC_CHANNEL_ON)

// APC autoset enums:
/// The APC turns automated and manual power channels off.
#define AUTOSET_FORCE_OFF 0
/// The APC turns automated power channels off.
#define AUTOSET_OFF 2
/// The APC turns automated power channels on.
#define AUTOSET_ON 1

// External power status:
/// The APC either isn't attached to a powernet or there is no power on the external powernet.
#define APC_NO_POWER 0
/// The APCs external powernet does not have enough power to charge the APC.
#define APC_LOW_POWER 1
/// The APCs external powernet has enough power to charge the APC.
#define APC_HAS_POWER 2

// Ethereals:
/// How long it takes an ethereal to drain or charge APCs. Also used as a spam limiter.
#define APC_DRAIN_TIME (7.5 SECONDS)
/// How much power ethereals gain/drain from APCs.
#define APC_POWER_GAIN 200

// Wires & EMPs:
/// The wire value used to reset the APCs wires after one's EMPed.
#define APC_RESET_EMP "emp"

// update_overlay

// Bitshifts: (If you change the status values to be something other than an int or able to exceed 3 you will need to change these too)
/// The bit shift for the APCs cover status.
#define UPSTATE_COVER_SHIFT (0)
	/// The bitflag representing the APCs cover being open for icon purposes.
	#define UPSTATE_OPENED1 (APC_COVER_OPENED << UPSTATE_COVER_SHIFT)
	/// The bitflag representing the APCs cover being missing for icon purposes.
	#define UPSTATE_OPENED2 (APC_COVER_REMOVED << UPSTATE_COVER_SHIFT)

//These need to be greated then the largest shift you're using for the other bitflags
/// Bit shift for the charging status of the APC.
#define UPOVERLAY_CHARGING_SHIFT (12)
/// Bit shift for the equipment status of the APC.
#define UPOVERLAY_EQUIPMENT_SHIFT (14)
/// Bit shift for the lighting channel status of the APC.
#define UPOVERLAY_LIGHTING_SHIFT (16)
/// Bit shift for the environment channel status of the APC.
#define UPOVERLAY_ENVIRON_SHIFT (18)

// Bitflags:
/// Bitflag indicating that the APCs operating status overlay should be shown.
#define UPOVERLAY_OPERATING (1<<2)
/// Bitflag indicating that the APCs locked status overlay should be shown.
#define UPOVERLAY_LOCKED (1<<3)
/// The APC has a power cell.
#define UPSTATE_CELL_IN (1<<4)
/// The APC is broken or damaged.
#define UPSTATE_BROKE (1<<5)
/// The APC is undergoing maintenance.
#define UPSTATE_MAINT (1<<6)
/// The APC is emagged or malfed.
#define UPSTATE_BLUESCREEN (1<<7)
/// The APCs wires are exposed.
#define UPSTATE_WIREEXP (1<<8)
/// The APC has a terminal deployed
#define UPOVERLAY_TERMINAL (1<<9)
/// The APC has its electronics inserted
#define UPOVERLAY_ELECTRONICS_INSERT (1<<10)
/// The APC has its electronics fastened
#define UPOVERLAY_ELECTRONICS_FASTENED (1<<11)
