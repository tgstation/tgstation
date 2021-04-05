// The severity of explosions. Why are these inverted? I have no idea, but git blame doesn't go back far enough for me to find out.
/// The (current) highest possible explosion severity.
#define EXPLODE_DEVASTATE 3
/// The (current) middling explosion severity.
#define EXPLODE_HEAVY 2
/// The (current) lowest possible explosion severity.
#define EXPLODE_LIGHT 1
/// The default explosion severity used to mark that an object is beyond the impact range of the explosion.
#define EXPLODE_NONE 0

// Internal explosion argument list keys.
/// The origin atom of the explosion.
#define EXARG_KEY_ORIGIN "origin"
/// The devastation range of the explosion.
#define EXARG_KEY_DEV_RANGE "devastation_range"
/// The heavy impact range of the explosion.
#define EXARG_KEY_HEAVY_RANGE "heavy_range"
/// The light impact range of the explosion.
#define EXARG_KEY_LIGHT_RANGE "light_range"
/// The flash range of the explosion.
#define EXARG_KEY_FLASH_RANGE "flash_range"
/// Whether or not the explosion should be logged.
#define EXARG_KEY_ADMIN_LOG "admin_log"
/// Whether or not the explosion should ignore the bombcap.
#define EXARG_KEY_IGNORE_CAP "ignore_cap"
/// The flame range of the explosion.
#define EXARG_KEY_FLAME_RANGE "flame_range"
/// Whether or not the explosion should produce sound effects and screenshake if it is large enough to warrant it.
#define EXARG_KEY_SILENT "silent"
/// Whether or not the explosion should produce smoke if it is large enough to warrant it.
#define EXARG_KEY_SMOKE "smoke"
