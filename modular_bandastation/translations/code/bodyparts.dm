// Code for handling declents for bodyparts

/obj/item/bodypart
	var/list/ru_plaintext_zone = list()

/obj/item/bodypart/head/Initialize(mapload)
	. = ..()
	ru_plaintext_zone = ru_names_toml("head")

/obj/item/bodypart/chest/Initialize(mapload)
	. = ..()
	ru_plaintext_zone = ru_names_toml("chest")

/obj/item/bodypart/arm/left/Initialize(mapload)
	. = ..()
	ru_plaintext_zone = ru_names_toml("left arm")

/obj/item/bodypart/arm/right/Initialize(mapload)
	. = ..()
	ru_plaintext_zone = ru_names_toml("right arm")

/obj/item/bodypart/leg/left/Initialize(mapload)
	. = ..()
	ru_plaintext_zone = ru_names_toml("left leg")

/obj/item/bodypart/leg/right/Initialize(mapload)
	. = ..()
	ru_plaintext_zone = ru_names_toml("right leg")

/proc/ru_parse_zone(zone, declent = NOMINATIVE)
	var/static/list/chest = ru_names_toml("chest")
	var/static/list/head = ru_names_toml("head")
	var/static/list/right_hand = ru_names_toml("right hand")
	var/static/list/left_hand = ru_names_toml("left hand")
	var/static/list/left_arm = ru_names_toml("left arm")
	var/static/list/right_arm = ru_names_toml("right arm")
	var/static/list/left_leg =ru_names_toml("left leg")
	var/static/list/right_leg = ru_names_toml("right leg")
	var/static/list/left_foot = ru_names_toml("left leg")
	var/static/list/right_foot = ru_names_toml("left leg")
	var/static/list/groin = ru_names_toml("groin")
	switch(zone)
		if(BODY_ZONE_CHEST)
			return chest[declent] || zone
		if(BODY_ZONE_HEAD)
			return head[declent] || zone
		if(BODY_ZONE_PRECISE_R_HAND)
			return right_hand[declent] || zone
		if(BODY_ZONE_PRECISE_L_HAND)
			return left_hand[declent] || zone
		if(BODY_ZONE_L_ARM)
			return left_arm[declent] || zone
		if(BODY_ZONE_R_ARM)
			return right_arm[declent] || zone
		if(BODY_ZONE_L_LEG)
			return left_leg[declent] || zone
		if(BODY_ZONE_R_LEG)
			return right_leg[declent] || zone
		if(BODY_ZONE_PRECISE_L_FOOT)
			return left_foot[declent] || zone
		if(BODY_ZONE_PRECISE_R_FOOT)
			return right_foot[declent] || zone
		if(BODY_ZONE_PRECISE_GROIN)
			return groin[declent] || zone
		else
			return zone
