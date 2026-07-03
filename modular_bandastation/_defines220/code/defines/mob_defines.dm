/// Check if we draw digitigrade legs on the mob. Based on code in human_update_icons.dm
#define CHECK_DIGI_LEGS(mob) (iscarbon(mob) && (mob.bodyshape & BODYSHAPE_DIGITIGRADE))
