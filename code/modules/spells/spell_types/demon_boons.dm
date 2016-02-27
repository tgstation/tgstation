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
	action_icon_state = "bolt_action" //TODO: set icon


/obj/effect/proc_holder/spell/targeted/summon_wealth/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		if(user.drop_item())
			var/obj/item = pick(
					new /obj/item/weapon/coin/gold(user.loc),
					new /obj/item/weapon/coin/diamond(user.loc),
					new /obj/item/weapon/coin/silver(user.loc),
					new /obj/item/clothing/tie/medal/gold(user.loc),
					new /obj/item/stack/sheet/mineral/gold(user.loc),
					new /obj/item/stack/sheet/mineral/silver(user.loc),
					new /obj/item/stack/sheet/mineral/diamond(user.loc),
					new /obj/item/stack/spacecash/c1000(user.loc))
			C.put_in_hands(item)
