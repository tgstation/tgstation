/// Appended to the description of magazines that spawn with old-fashioned incendiary ammo, which generally leave fire trails and give firestacks in return for less base damage.
#define MAGAZINE_DESC_INC "<br>Carries rounds which ignite targets and leave flaming trails, but inflict less damage."
/// Appended to the description of magazines that spawn with hollow-point ammo, which generally has higher base damage but is weak against armor.
#define MAGAZINE_DESC_HOLLOWPOINT "<br>Carries hollow-point rounds which are effective against unarmored targets, but suffer greatly against armor."
/// Appended to the description of magazines that spawn with armor-piercing ammo, which generally has less base damage but penetrates armor.
#define MAGAZINE_DESC_ARMORPIERCE "<br>Carries armor-piercing rounds which are effective against armored targets, but less effective against unarmored targets."

/// Defines a magazine to, visually, be for incendiary ammo by setting the ammo band color and appending a short blurb to the description.
#define MAGAZINE_TYPE_INCENDIARY \
	ammo_band_color = COLOR_AMMO_INCENDIARY; \
	desc = parent_type::desc + MAGAZINE_DESC_INC;

/// Defines a magazine to, visually, be for hollow-point ammo by setting the ammo band color and appending a short blurb to the description.
#define MAGAZINE_TYPE_HOLLOWPOINT \
	ammo_band_color = COLOR_AMMO_HOLLOWPOINT; \
	desc = parent_type::desc + MAGAZINE_DESC_HOLLOWPOINT;

/// Defines a magazine to, visually, be for armor-piercing ammo by setting the ammo band color and appending a short blurb to the description.
#define MAGAZINE_TYPE_ARMORPIERCE \
	ammo_band_color = COLOR_AMMO_ARMORPIERCE; \
	desc = parent_type::desc + MAGAZINE_DESC_ARMORPIERCE;
