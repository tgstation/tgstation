/obj/effect/proc_holder/spell/targeted/summon_wealth
	name = "Summon wealth"
	desc = "The reward for selling your soul."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	school = "conjuration"
	charge_max = 100
	cooldown_min = 10
	action_icon_state = "moneybag"


/obj/effect/proc_holder/spell/targeted/summon_wealth/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		if(user.drop_item())
			var/obj/item = pick(
					new /obj/item/weapon/coin/gold(user.loc),
					new /obj/item/weapon/coin/diamond(user.loc),
					new /obj/item/weapon/coin/silver(user.loc),
					new /obj/item/clothing/accessory/medal/gold(user.loc),
					new /obj/item/stack/sheet/mineral/gold(user.loc),
					new /obj/item/stack/sheet/mineral/silver(user.loc),
					new /obj/item/stack/sheet/mineral/diamond(user.loc),
					new /obj/item/stack/spacecash/c1000(user.loc))
			C.put_in_hands(item)

/obj/effect/proc_holder/spell/targeted/view_range
	name = "Distant vision"
	desc = "The reward for selling your soul."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	charge_max = 50
	cooldown_min = 10
	action_icon_state = "camera_jump"
	var/ranges = list(7,8,9,10)

/obj/effect/proc_holder/spell/targeted/view_range/cast(list/targets, mob/user = usr)
	for(var/mob/C in targets)
		if(!C.client)
			continue
		C.client.change_view(input("Select view range:", "Range", 4) in ranges)

/obj/effect/proc_holder/spell/targeted/summon_friend
	name = "Summon Friend"
	desc = "The reward for selling your soul."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	charge_max = 50
	cooldown_min = 10
	action_icon_state = "sacredflame"
	var/mob/living/friend
	var/obj/effect/mob_spawn/human/demonic_friend/friendShell

/obj/effect/proc_holder/spell/targeted/summon_friend/cast(list/targets, mob/user = usr)
	if(!QDELETED(friend))
		to_chat(friend, "<span class='userdanger'>Your master has deemed you a poor friend.  Your durance in hell will now resume.</span>")
		friend.dust(TRUE)
		qdel(friendShell)
		return
	if(!QDELETED(friendShell))
		qdel(friendShell)
		return
	for(var/C in targets)
		var/mob/living/L = C
		friendShell = new /obj/effect/mob_spawn/human/demonic_friend(L.loc, L.mind, src)

/obj/effect/proc_holder/spell/targeted/conjure_item/spellpacket/robeless
	clothes_req = FALSE
