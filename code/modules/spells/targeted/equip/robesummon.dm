/spell/targeted/equip_item/robesummon
	name = "Summon Robes	"
	desc = "A spell which will summon you a new set of robes."

	school = "evocation"
	charge_max = 300
	invocation = "I PUT ON MY ROBE AND WIZARD HAT!"
	invocation_type = SpI_SHOUT
	range = -1
	spell_flags = INCLUDEUSER //SELECTABLE hinders you here, since the spell has a range of 1 and only works on adjacent guys. Having the TARGETTED flag here makes it easy for your target to run away from you!

	delete_old = 0 //Players shouldn't lose their hardsuits because they decided to summon some robes.

	cooldown_min = 50

	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_robesummon"


/spell/targeted/equip_item/robesummon/cast(list/targets, mob/user = usr)
	switch(pick("blue","red","marisa"))

		if ("blue")
			equipped_summons = list("[slot_head]" = /obj/item/clothing/head/wizard,
									"[slot_wear_suit]" = /obj/item/clothing/suit/wizrobe,
									"[slot_shoes]" = /obj/item/clothing/shoes/sandal)

		if ("red")
			equipped_summons = list("[slot_head]" = /obj/item/clothing/head/wizard/red,
									"[slot_wear_suit]" = /obj/item/clothing/suit/wizrobe/red,
									"[slot_shoes]" = /obj/item/clothing/shoes/sandal)

		if("marisa")
			equipped_summons = list("[slot_head]" = /obj/item/clothing/head/wizard/marisa,
									"[slot_wear_suit]" = /obj/item/clothing/suit/wizrobe/marisa,
									"[slot_shoes]" = /obj/item/clothing/shoes/sandal/marisa)

	usr.visible_message("<span class='danger'>[usr] puts on his robe and wizard hat!</span>", \
						"<span class='danger'>You put on your robe and wizard hat!</span>")

	..()