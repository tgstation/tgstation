SUBSYSTEM_DEF(religion)
	name = "Religion"
	init_order = 19
	flags = SS_NO_FIRE|SS_NO_INIT

	var/religion
	var/deity
	var/bible_name
	var/bible_icon_state
	var/bible_item_state
	var/holy_weapon_type