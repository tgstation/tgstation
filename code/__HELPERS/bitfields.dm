#define is_flag(bitfield, flag) (bitfield & flag)
#define toggle_flag(bitfield, flag) (bitfield ^= flag)
#define set_flag(bitfield, flag) (bitfield |= flag)
#define unset_flag(bitfield, flag) (bitfield &= ~flag)
