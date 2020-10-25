/*
 * Contains:
 *		Security
 *		Detective
 *		Navy uniforms
 */

/*
 * Security
 */

/obj/item/clothing/under/rank/security
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'

/obj/item/clothing/under/rank/security/officer
	name = "security jumpsuit"
	desc = "A tactical security jumpsuit for officers complete with Nanotrasen belt buckle."
	icon_state = "rsecurity"
	inhand_icon_state = "r_suit"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 30, WOUND = 10)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/officer/grey
	name = "grey security jumpsuit"
	desc = "A tactical relic of years past before Nanotrasen decided it was cheaper to dye the suits red instead of washing out the blood."
	icon_state = "security"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/rank/security/officer/skirt
	name = "security jumpskirt"
	desc = "A \"tactical\" security jumpsuit with the legs replaced by a skirt."
	icon_state = "secskirt"
	inhand_icon_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE //you know now that i think of it if you adjust the skirt and the sprite disappears isn't that just like flashing everyone
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/security/officer/blueshirt
	name = "blue shirt and tie"
	desc = "I'm a little busy right now, Calhoun."
	icon_state = "blueshift"
	inhand_icon_state = "blueshift"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/officer/formal
	name = "security officer's formal uniform"
	desc = "The latest in fashionable security outfits."
	icon_state = "officerblueclothes"
	inhand_icon_state = "officerblueclothes"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/constable
	name = "constable outfit"
	desc = "A british looking outfit."
	icon_state = "constable"
	inhand_icon_state = "constable"
	can_adjust = FALSE
	custom_price = 200

/obj/item/clothing/under/rank/security/warden
	name = "security suit"
	desc = "A formal security suit for officers complete with Nanotrasen belt buckle."
	icon_state = "rwarden"
	inhand_icon_state = "r_suit"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 30, WOUND = 10)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/warden/grey
	name = "grey security suit"
	desc = "A formal relic of years past before Nanotrasen decided it was cheaper to dye the suits red instead of washing out the blood."
	icon_state = "warden"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/rank/security/warden/skirt
	name = "warden's suitskirt"
	desc = "A formal security suitskirt for officers complete with Nanotrasen belt buckle."
	icon_state = "rwarden_skirt"
	inhand_icon_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/security/warden/formal
	desc = "The insignia on this uniform tells you that this uniform belongs to the Warden."
	name = "warden's formal uniform"
	icon_state = "wardenblueclothes"
	inhand_icon_state = "wardenblueclothes"
	alt_covers_chest = TRUE

/*
 * Detective
 */
/obj/item/clothing/under/rank/security/detective
	name = "hard-worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	inhand_icon_state = "det"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 30, WOUND = 10)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/detective/skirt
	name = "detective's suitskirt"
	desc = "Someone who wears this means business."
	icon_state = "detective_skirt"
	inhand_icon_state = "det"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/security/detective/grey
	name = "noir suit"
	desc = "A hard-boiled private investigator's grey suit, complete with tie clip."
	icon_state = "greydet"
	inhand_icon_state = "greydet"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/detective/grey/skirt
	name = "noir suitskirt"
	desc = "A hard-boiled private investigator's grey suitskirt, complete with tie clip."
	icon_state = "greydet_skirt"
	inhand_icon_state = "greydet"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/*
 * Head of Security
 */
/obj/item/clothing/under/rank/security/head_of_security
	name = "head of security's jumpsuit"
	desc = "A security jumpsuit decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "rhos"
	inhand_icon_state = "r_suit"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 10)
	strip_delay = 60
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/head_of_security/skirt
	name = "head of security's jumpskirt"
	desc = "A security jumpskirt decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "rhos_skirt"
	inhand_icon_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/security/head_of_security/grey
	name = "head of security's grey jumpsuit"
	desc = "There are old men, and there are bold men, but there are very few old, bold men."
	icon_state = "hos"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/rank/security/head_of_security/alt
	name = "head of security's turtleneck"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with tactical pants."
	icon_state = "hosalt"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/rank/security/head_of_security/alt/skirt
	name = "head of security's turtleneck skirt"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with a tactical skirt."
	icon_state = "hosalt_skirt"
	inhand_icon_state = "bl_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/security/head_of_security/parade
	name = "head of security's parade uniform"
	desc = "A male head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_male"
	inhand_icon_state = "r_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/head_of_security/parade/female
	name = "head of security's parade uniform"
	desc = "A female head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_fem"
	inhand_icon_state = "r_suit"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/head_of_security/formal
	desc = "The insignia on this uniform tells you that this uniform belongs to the Head of Security."
	name = "head of security's formal uniform"
	icon_state = "hosblueclothes"
	inhand_icon_state = "hosblueclothes"
	alt_covers_chest = TRUE

/*
 *Spacepol
 */

/obj/item/clothing/under/rank/security/officer/spacepol
	name = "police uniform"
	desc = "Space not controlled by megacorporations, planets, or pirates is under the jurisdiction of Spacepol."
	icon_state = "spacepol"
	inhand_icon_state = "spacepol"
	can_adjust = FALSE

/obj/item/clothing/under/rank/prisoner
	name = "prison jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon = 'icons/obj/clothing/under/security.dmi'
	icon_state = "prisoner"
	inhand_icon_state = "o_suit"
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/prisoner/skirt
	name = "prison jumpskirt"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner_skirt"
	inhand_icon_state = "o_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/security/officer/beatcop
	name = "space police uniform"
	desc = "A police uniform often found in the lines at donut shops."
	icon_state = "spacepolice_families"
	inhand_icon_state = "spacepolice_families"
	can_adjust = FALSE
