/obj/effect/proc_holder/spell/targeted/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? Summons an unending stream of bolt action rifles. Requires both hands free to use."
	invocation_type = "none"
	include_user = 1
	range = -1

	school = "conjuration"
	charge_max = 750
	clothes_req = 1
	cooldown_min = 10 //Gun wizard
	action_icon_state = "bolt_action"



/obj/effect/proc_holder/spell/targeted/infinite_guns/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		C.drop_item()
		C.swap_hand()
		C.drop_item()
		var/obj/item/weapon/gun/ballistic/shotgun/boltaction/enchanted/GUN = new
		C.put_in_hands(GUN)
		C.swap_hand(C.get_held_index_of_item(GUN))
