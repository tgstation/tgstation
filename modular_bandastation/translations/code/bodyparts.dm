// Code for handling declents for bodyparts

/obj/item/bodypart
	var/list/ru_plaintext_zone = list()

/obj/item/bodypart/head
	ru_plaintext_zone = RU_NAMES_LIST("head", "голова", "головы", "голове", "голову", "головой", "голове")

/obj/item/bodypart/chest
	ru_plaintext_zone = RU_NAMES_LIST("chest", "грудь", "груди", "груди", "грудь", "грудью", "груди")

/obj/item/bodypart/arm/left
	ru_plaintext_zone = RU_NAMES_LIST("left arm", "левая рука", "левой руки", "левой руке", "левую руку", "левой рукой", "левой руке")

/obj/item/bodypart/arm/right
	ru_plaintext_zone = RU_NAMES_LIST("right arm", "правая рука", "правой руки", "правой руке", "правую руку", "правой рукой", "правой руке")

/obj/item/bodypart/leg/left
	ru_plaintext_zone = RU_NAMES_LIST("left leg", "левая нога", "левой ноги", "левой ноге", "левую ногу", "левой ногой", "левой ноге")

/obj/item/bodypart/leg/right
	ru_plaintext_zone = RU_NAMES_LIST("right leg", "правая нога", "правой ноги", "правой ноге", "правую ногу", "правой ногой", "правой ноге")

/proc/ru_parse_zone(zone, declent = NOMINATIVE)
	var/static/list/chest = RU_NAMES_LIST("chest", "грудь", "груди", "груди", "грудь", "грудью", "груди")
	var/static/list/head = RU_NAMES_LIST("head", "голова", "головы", "голове", "голову", "головой", "голове")
	var/static/list/right_hand = RU_NAMES_LIST("right hand", "правое запястье", "правого запястья", "правому запястью", "правое запястье", "правым запястьем", "правом запястье")
	var/static/list/left_hand = RU_NAMES_LIST("left hand", "левое запястье", "левое запястье", "левой руке", "левую руку", "левой рукой", "левой руке")
	var/static/list/left_arm = RU_NAMES_LIST("left arm", "левая рука", "левой руки", "левой руке", "левую руку", "левой рукой", "левой руке")
	var/static/list/right_arm = RU_NAMES_LIST("right arm", "правая рука", "правой руки", "правой руке", "правую руку", "правой рукой", "правой руке")
	var/static/list/left_leg = RU_NAMES_LIST("left leg", "левая нога", "левой ноги", "левой ноге", "левую ногу", "левой ногой", "левой ноге")
	var/static/list/right_leg = RU_NAMES_LIST("right leg", "правая нога", "правой ноги", "правой ноге", "правую ногу", "правой ногой", "правой ноге")
	var/static/list/left_foot = RU_NAMES_LIST("left leg", "левая стопа", "левой стопы", "левой стопе", "левую стопу", "левой стопой", "левой стопе")
	var/static/list/right_foot = RU_NAMES_LIST("left leg", "правая стопа", "правой стопы", "правой стопе", "правую стопу", "правой стопой", "правой стопе")
	var/static/list/groin = RU_NAMES_LIST("groin", "паховая область", "паховой области", "паховой области", "паховую область", "паховой областью", "паховой области")
	switch(zone)
		if(BODY_ZONE_CHEST)
			return chest[declent]
		if(BODY_ZONE_HEAD)
			return head[declent]
		if(BODY_ZONE_PRECISE_R_HAND)
			return right_hand[declent]
		if(BODY_ZONE_PRECISE_L_HAND)
			return left_hand[declent]
		if(BODY_ZONE_L_ARM)
			return left_arm[declent]
		if(BODY_ZONE_R_ARM)
			return right_arm[declent]
		if(BODY_ZONE_L_LEG)
			return left_leg[declent]
		if(BODY_ZONE_R_LEG)
			return right_leg[declent]
		if(BODY_ZONE_PRECISE_L_FOOT)
			return left_foot[declent]
		if(BODY_ZONE_PRECISE_R_FOOT)
			return right_foot[declent]
		if(BODY_ZONE_PRECISE_GROIN)
			return groin[declent]
		else
			return zone
