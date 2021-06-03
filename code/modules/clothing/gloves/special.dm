
/obj/item/clothing/gloves/cargo_gauntlet
	name = "\improper H.A.U.L. gauntlets"
	desc = "These clunky gauntlets allow you to drag things with more confidence on them not getting nabbed from you."
	icon_state = "haul_gauntlet"
	inhand_icon_state = "bgloves"
	transfer_prints = FALSE
	equip_delay_self = 3 SECONDS
	equip_delay_other = 4 SECONDS
	clothing_traits = list(TRAIT_CHUNKYFINGERS)
	undyeable = TRUE
	var/datum/component/strong_pull/pull_component

/obj/item/clothing/gloves/cargo_gauntlet/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_GLOVES)
		return
	to_chat(user, "<span class='notice'>You feel the gauntlets activate as soon as you fit them on, making your pulls stronger!</span>")
	pull_component = user.AddComponent(/datum/component/strong_pull)

/obj/item/clothing/gloves/cargo_gauntlet/dropped(mob/user)
	. = ..()
	to_chat(user, "<span class='warning'>You have lost the grip power of [src]!</span>")
	QDEL_NULL(pull_component)
