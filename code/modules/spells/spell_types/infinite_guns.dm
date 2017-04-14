/obj/effect/proc_holder/spell/targeted/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? Summons an unending stream of bolt action rifles. Requires both hands free to use. Learning this spell makes you unable to learn Arcane Barrage."
	invocation_type = "none"
	include_user = 1
	range = -1

	school = "conjuration"
	charge_max = 750
	clothes_req = 1
	cooldown_min = 10 //Gun wizard
	action_icon_state = "bolt_action"
	var/summon_path = /obj/item/weapon/gun/ballistic/shotgun/boltaction/enchanted

/obj/effect/proc_holder/spell/targeted/infinite_guns/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		C.drop_item()
		C.swap_hand()
		C.drop_item()
		var/GUN = new summon_path
		C.put_in_hands(GUN)
		C.swap_hand(C.get_held_index_of_item(GUN))

/obj/effect/proc_holder/spell/targeted/infinite_guns/gun

/obj/effect/proc_holder/spell/targeted/infinite_guns/arcane_barrage
	name = "Arcane Barrage"
	desc = "Fire a torrent of arcane energy at your foes with this (powerful) spell. Requires both hands free to use. Learning this spell makes you unable to learn Lesser Summon Gun."
	action_icon_state = "arcane_barrage"
	summon_path = /obj/item/weapon/gun/ballistic/shotgun/boltaction/enchanted/arcane_barrage