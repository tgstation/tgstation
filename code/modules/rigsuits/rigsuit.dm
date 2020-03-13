//RIG RIG RIG RIG RIG
/obj/item/rig
	icon = 'icons/obj/rig.dmi'

/obj/item/rig/parts
	var/theme = "engi"

/obj/item/rig/parts/control
	name = "RIG control module"
	desc = "A special powered suit that protects against various environments. Wear it on your back, deploy it and turn it on to use its' power."
	icon_state = "engi-module"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	var/theme = "engi"

/obj/item/rig/parts/control/Initialize()
	icon_state = "[theme]-module"

/obj/item/rig/parts/helmet
	name = "RIG helmet"
	icon_state = "engi-helmet-unsealed"

/obj/item/rig/parts/helmet/Initialize()
	icon_state = "[theme]-helmet-unsealed"

/obj/item/rig/parts/suit
	name = "RIG suit"
	icon_state = "engi-suit-unsealed"

/obj/item/rig/parts/suit/Initialize()
	icon_state = "[theme]-suit-unsealed"

/obj/item/rig/parts/gauntlets
	name = "RIG gauntlets"
	icon_state = "engi-gauntlets-unsealed"
/obj/item/rig/parts/gauntlets/Initialize()
	icon_state = "[theme]-gauntlets-unsealed"

/obj/item/rig/parts/boots
	name = "RIG boots"
	icon_state = "engi-boots-unsealed"

/obj/item/rig/parts/boots/Initialize()
	icon_state = "[theme]-boots-unsealed"

/obj/item/rig/modules
	name = "RIG module"
	desc = "A RIGsuit module. You should not see this, scream at the coders!"
	icon_state = "module"