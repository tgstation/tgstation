
/obj/item/clothing
	var/icon_avatar_file	// This is our solution for getting clothing items to pull from a different file for custom items. This has to be inserted into human/update_icons.dm
	// NOTE: This currently is only being used by Uniforms. Each category will need to have its own one of these. Create them as needed.

/obj/item/clothing/under
	icon_avatar_file = 'icons/mob/uniform.dmi'

// Search clothing.dm
/obj/item/clothing/under/blockhead
	name = "idiot apparel"
	desc = "You can almost picture the owner of this outfit spending evenings chucking rocks at birds."

	// NOTE: The actual WORN item goes in uniform.dmi, etc. Pluralized to uniforms.dmi is the icon, but singular is the worn thing.
	icon_avatar_file = 'icons/Fulpstation/fulpavatar.dmi'

	icon = 'icons/Fulpstation/fulpitems.dmi' // This is the ICON for the object, NOT what it looks like when worn. //'icons/Fulpstation/fulpitems_worn.dmi'
	icon_state = "outfit_blockhead" // Name in icon GOES WITH "icon" (shown when it's in your inventory)

	item_state = "outfit_blockhead" // Seems to be when held in your hands?
	lefthand_file = 'icons/Fulpstation/fulpitems_hold_left.dmi'
	righthand_file = 'icons/Fulpstation/fulpitems_hold_right.dmi'
