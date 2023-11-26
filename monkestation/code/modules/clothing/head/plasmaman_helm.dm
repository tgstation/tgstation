/obj/item/clothing/head/helmet/space/plasmaman
	icon = 'monkestation/icons/obj/clothing/plasmaman_head.dmi'
	worn_icon = 'icons/mob/clothing/head/plasmaman_head.dmi'

/obj/item/clothing/head/helmet/space/plasmaman/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!isinhands && smile)
		var/mutable_appearance/M = mutable_appearance('monkestation/icons/mob/clothing/head/plasmaman_head.dmi', smile_state)
		M.color = smile_color
		. += M
	if(!isinhands && attached_hat)
		. += attached_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi')
	if(!isinhands && !up)
		. += mutable_appearance('monkestation/icons/mob/clothing/head/plasmaman_head.dmi', visor_icon)
	else
		cut_overlays()
