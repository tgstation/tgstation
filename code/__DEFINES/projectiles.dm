// check_pierce() return values
/// Default behavior: hit and delete self
#define PROJECTILE_PIERCE_NONE		0
/// Hit the thing but go through without deleting. Causes on_hit to be called with pierced = TRUE
#define PROJECTILE_PIERCE_HIT		1
/// Entirely phase through the thing without ever hitting.
#define PROJECTILE_PIERCE_PHASE		2
// Delete self without hitting
#define PROJECTILE_DELETE_WITHOUT_HITTING		3

// Caliber defines: (Current count stands at 13)
/// Small bullets used by most automatic pistols and SMGs.
#define CALIBER_BALLISTIC_LIGHT		"ballistic-light"
/// Mid size bullets used by automatic rifles and revolvers.
#define CALIBER_BALLISTIC_MEDIUM	"ballistic-medium"
/// Large bullets used by the deagle and sniper rifles.
#define CALIBER_BALLISTIC_HEAVY		"ballistic-heavy"
/// Shotgun shells used by shotguns.
#define CALIBER_SHOTGUN				"shotgun"
/// Grenades and gyrojet rounds used by grenade launchers and the gyrojet pistol.
#define CALIBER_GRENADE				"grenade"
/// Rockets used by the rocket launcher.
#define CALIBER_ROCKET				"rocket"
/// Foam darts used by donksoft and foam force guns.
#define CALIBER_FOAM		"foam_force"
/// Disposable laser cartriges used by laser guns.
#define CALIBER_LASER		"laser"
/// Some form of lens or emitter used by energy guns.
#define CALIBER_ENERGY		"energy"
/// Arrows used by the bow.
#define CALIBER_ARROW		"arrow"
/// Harpoons used by the harpoon gun.
#define CALIBER_HARPOON		"harpoon"
/// The meat hook used... by the meat hook.
#define CALIBER_HOOK		"hook"
/// The tentacle used by the tentacle mutation.
#define CALIBER_TENTACLE	"tentacle"
