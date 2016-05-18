/datum/sprite_theme/oldsec
	overrides = list(/datum/sprite_override/hos/oldsec,
					/datum/sprite_override/sec/oldsec,
					/datum/sprite_override/warden/oldsec,
					/datum/sprite_override/sec_armor/oldsec,
					/datum/sprite_override/sec_helmet/old,
					/datum/sprite_override/sec_backpack/old,
					/datum/sprite_override/sec_shoes/old)

/datum/sprite_theme/greysec
	overrides = list(/datum/sprite_override/hos/greysec,
					/datum/sprite_override/sec/greysec,
					/datum/sprite_override/warden/greysec,
					/datum/sprite_override/sec_armor/newsec,
					/datum/sprite_override/sec_helmet/normal,
					/datum/sprite_override/sec_backpack/normal,
					/datum/sprite_override/sec_shoes/normal)

/datum/sprite_theme/copsec
	overrides = list(/datum/sprite_override/hos/copsec,
					/datum/sprite_override/sec/copsec,
					/datum/sprite_override/warden/copsec,
					/datum/sprite_override/sec_armor/copsec,
					/datum/sprite_override/warden_armor/copsec,
					/datum/sprite_override/hos_armor/copsec,
					/datum/sprite_override/sec_helmet/copsec,
					/datum/sprite_override/sec_backpack/old,
					/datum/sprite_override/sec_shoes/old)

/datum/sprite_theme/corpsec
	overrides = list(/datum/sprite_override/hos/corpsec,
					/datum/sprite_override/sec/corpsec,
					/datum/sprite_override/warden/corpsec,
					/datum/sprite_override/sec_armor/newsec,
					/datum/sprite_override/sec_helmet/alt,
					/datum/sprite_override/sec_backpack/normal,
					/datum/sprite_override/sec_shoes/normal)

/datum/sprite_theme/redsec
	overrides = list(/datum/sprite_override/hos/redsec,
					/datum/sprite_override/sec/redsec,
					/datum/sprite_override/warden/redsec,
					/datum/sprite_override/sec_armor/newsec,
					/datum/sprite_override/sec_helmet/normal,
					/datum/sprite_override/sec_backpack/normal,
					/datum/sprite_override/sec_shoes/normal)

// Head of Security

/datum/sprite_override/hos
	item_type = /obj/item/clothing/under/rank/head_of_security

/datum/sprite_override/hos/New()
	list_to_search = hos_outfits
	..()

/datum/sprite_override/hos/oldsec
	alts = list(/datum/sprite_alt/hos_alt5)
/datum/sprite_override/hos/greysec
	alts = list(/datum/sprite_alt/hos_alt3)
/datum/sprite_override/hos/copsec
	alts = list(/datum/sprite_alt/hos_alt4)
/datum/sprite_override/hos/corpsec
	alts = list(/datum/sprite_alt/hos_alt2)
/datum/sprite_override/hos/redsec
	alts = list(/datum/sprite_alt/hos_alt1)



/datum/sprite_alt/hos_alt1
	name = "HoS Alts"
	icon_state = "hos_alt1"
	item_state = "hos_alt1"
	item_color = "hos_alt1"

/datum/sprite_alt/hos_alt2
	name = "HoS Alts"
	icon_state = "hos_alt2"
	item_state = "hos_alt2"
	item_color = "hos_alt2"

/datum/sprite_alt/hos_alt3
	name = "HoS Alts"
	icon_state = "hos_alt3"
	item_state = "hos_alt3"
	item_color = "hos_alt3"

/datum/sprite_alt/hos_alt4
	name = "HoS Alts"
	icon_state = "hos_alt4"
	item_state = "hos_alt4"
	item_color = "hos_alt4"

/datum/sprite_alt/hos_alt5
	name = "HoS Alts"
	icon_state = "hos_alt5"
	item_state = "hos_alt5"
	item_color = "hos_alt5"

// Security Officer

/datum/sprite_override/sec
	item_type = /obj/item/clothing/under/rank/security

/datum/sprite_override/sec/New()
	list_to_search = sec_outfits
	..()

/datum/sprite_override/sec/oldsec
	alts = list(/datum/sprite_alt/sec_alt5)
/datum/sprite_override/sec/greysec
	alts = list(/datum/sprite_alt/sec_alt3)
/datum/sprite_override/sec/copsec
	alts = list(/datum/sprite_alt/sec_alt4)
/datum/sprite_override/sec/corpsec
	alts = list(/datum/sprite_alt/sec_alt2)
/datum/sprite_override/sec/redsec
	alts = list(/datum/sprite_alt/sec_alt1)

/datum/sprite_alt/sec_alt1
	name = "Security Alts"
	icon_state = "sec_alt1"
	item_state = "sec_alt1"
	item_color = "sec_alt1"

/datum/sprite_alt/sec_alt2
	name = "Security Alts"
	icon_state = "sec_alt2"
	item_state = "sec_alt2"
	item_color = "sec_alt2"

/datum/sprite_alt/sec_alt3
	name = "Security Alts"
	icon_state = "sec_alt3"
	item_state = "sec_alt3"
	item_color = "sec_alt3"

/datum/sprite_alt/sec_alt4
	name = "Security Alts"
	icon_state = "sec_alt4"
	item_state = "sec_alt4"
	item_color = "sec_alt4"

/datum/sprite_alt/sec_alt5
	name = "Security Alts"
	icon_state = "sec_alt5"
	item_state = "sec_alt5"
	item_color = "sec_alt5"

// Warden

/datum/sprite_override/warden
	item_type = /obj/item/clothing/under/rank/warden
	alts = list()

/datum/sprite_override/warden/New()
	list_to_search = warden_outfits
	..()

/datum/sprite_override/warden/oldsec
	alts = list(/datum/sprite_alt/warden_alt5)
/datum/sprite_override/warden/greysec
	alts = list(/datum/sprite_alt/warden_alt3)
/datum/sprite_override/warden/copsec
	alts = list(/datum/sprite_alt/warden_alt4)
/datum/sprite_override/warden/corpsec
	alts = list(/datum/sprite_alt/warden_alt2)
/datum/sprite_override/warden/redsec
	alts = list(/datum/sprite_alt/warden_alt1)


/datum/sprite_alt/warden_alt1
	name = "Warden Alts"
	icon_state = "warden_alt1"
	item_state = "warden_alt1"
	item_color = "warden_alt1"

/datum/sprite_alt/warden_alt2
	name = "Warden Alts"
	icon_state = "warden_alt2"
	item_state = "warden_alt2"
	item_color = "warden_alt2"

/datum/sprite_alt/warden_alt3
	name = "Warden Alts"
	icon_state = "warden_alt3"
	item_state = "warden_alt3"
	item_color = "warden_alt3"

/datum/sprite_alt/warden_alt4
	name = "Warden Alts"
	icon_state = "warden_alt4"
	item_state = "warden_alt4"
	item_color = "warden_alt4"

/datum/sprite_alt/warden_alt5
	name = "Warden Alts"
	icon_state = "warden_alt5"
	item_state = "warden_alt5"
	item_color = "warden_alt5"

/datum/sprite_override/sec_helmet
	item_type = /obj/item/clothing/head/helmet/sec

/datum/sprite_override/sec_helmet/New()
	list_to_search = helmet_list
	..()

/datum/sprite_override/sec_helmet/normal
	alts = list(/datum/sprite_alt/helmet_alt1)

/datum/sprite_override/sec_helmet/alt
	alts = list(/datum/sprite_alt/helmet_alt2)

/datum/sprite_override/sec_helmet/old
	alts = list(/datum/sprite_alt/helmet_alt3)

/datum/sprite_override/sec_helmet/copsec
	alts = list(/datum/sprite_alt/helmet_alt4)


/datum/sprite_alt/helmet_alt1
	name = "Sec Alts"
	icon_state = "helmet"
	item_state = "helmet"
	item_color = "helmet"

/datum/sprite_alt/helmet_alt2
	name = "Sec Alts"
	icon_state = "helmetalt"
	item_state = "helmetalt"
	item_color = "helmetalt"

/datum/sprite_alt/helmet_alt3
	name = "Sec Alts"
	icon_state = "helmet_old"
	item_state = "helmet_old"
	item_color = "helmet_old"

/datum/sprite_alt/helmet_alt4
	name = "Sec Alts"
	icon_state = "policehelm"
	item_state = "policehelm"
	item_color = "policehelm"


/datum/sprite_override/sec_backpack
	item_type = /obj/item/weapon/storage/backpack/security

/datum/sprite_override/sec_backpack/New()
	list_to_search = sec_backpack_list
	..()

/datum/sprite_override/sec_backpack/normal
	alts = list(/datum/sprite_alt/backpack_alt1)

/datum/sprite_override/sec_backpack/old
	alts = list(/datum/sprite_alt/backpack_alt2)


/datum/sprite_alt/backpack_alt1
	name = "Sec Alts"
	icon_state = "securitypack"
	item_state = "securitypack"
	item_color = "securitypack"

/datum/sprite_alt/backpack_alt2
	name = "Sec Alts"
	icon_state = "backpack"
	item_state = "backpack"
	item_color = "backpack"

/datum/sprite_override/sec_shoes
	item_type = /obj/item/clothing/shoes/jackboots

/datum/sprite_override/sec_shoes/New()
	list_to_search = jackboots_list
	..()

/datum/sprite_override/sec_shoes/normal
	alts = list(/datum/sprite_alt/shoes_alt1)

/datum/sprite_override/sec_shoes/old
	alts = list(/datum/sprite_alt/shoes_alt2)


/datum/sprite_alt/shoes_alt1
	name = "Sec Alts"
	icon_state = "jackboots"
	item_state = "jackboots"
	item_color = "hosred"

/datum/sprite_alt/shoes_alt2
	name = "Sec Alts"
	icon_state = "brown"
	item_state = "brown"
	item_color = "brown"

/datum/sprite_override/sec_armor
	item_type = /obj/item/clothing/suit/armor/vest

/datum/sprite_override/sec_armor/New()
	list_to_search = armor_list
	..()


/datum/sprite_override/warden_armor
	item_type = /obj/item/clothing/suit/armor/vest/warden

/datum/sprite_override/warden_armor/New()
	list_to_search = warden_armor_list
	..()

/datum/sprite_override/hos_armor
	item_type = /obj/item/clothing/suit/armor/hos

/datum/sprite_override/hos_armor/New()
	list_to_search = hos_armor_list
	..()

/datum/sprite_override/sec_armor/oldsec
	alts = list(/datum/sprite_alt/armor_alt1)

/datum/sprite_override/sec_armor/newsec
	alts = list(/datum/sprite_alt/armor_alt2)

/datum/sprite_override/sec_armor/copsec
	alts = list(/datum/sprite_alt/sec_armor_alt)

/datum/sprite_override/warden_armor/copsec
	alts = list(/datum/sprite_alt/warden_armor_alt)

/datum/sprite_override/hos_armor/copsec
	alts = list(/datum/sprite_alt/sec_armor_alt)

/datum/sprite_alt/armor_alt1
	name = "Sec Alts"
	icon_state = "armor_alt1"
	item_state = "armor_alt1"
	item_color = "armor_alt1"

/datum/sprite_alt/armor_alt2
	name = "Sec Alts"
	icon_state = "armor_alt2"
	item_state = "armor_alt2"
	item_color = "armor_alt2"

/datum/sprite_alt/warden_armor_alt
	name = "Warden Alts"
	icon_state = "warden_alt4"
	item_state = "warden_alt4"
	item_color = "warden_alt4"

/datum/sprite_alt/hos_armor_alt
	name = "HoS Alts"
	icon_state = "hos_alt4"
	item_state = "hos_alt4"
	item_color = "hos_alt4"

/datum/sprite_alt/sec_armor_alt
	name = "Sec Alts"
	icon_state = "sec_alt4"
	item_state = "sec_alt4"
	item_color = "sec_alt4"