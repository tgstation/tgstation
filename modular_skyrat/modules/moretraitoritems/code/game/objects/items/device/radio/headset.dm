/obj/item/radio/headset/headset_cent/impostorsr
    keyslot2 = null

/obj/item/radio/headset/chameleon/advanced
	special_desc = "A chameleon headset employed by the Syndicate in infiltration operations. \
	This particular model features flashbang protection, and the ability to amplify your volume."
	command = TRUE
	freerange = TRUE

/obj/item/radio/headset/chameleon/advanced/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))
