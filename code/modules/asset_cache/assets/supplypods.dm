/datum/asset/spritesheet/supplypods
	name = "supplypods"

/datum/asset/spritesheet/supplypods/create_spritesheets()
	for (var/datum/pod_style/style as anything in typesof(/datum/pod_style))
		if (ispath(style, /datum/pod_style/seethrough))
			Insert("pod_asset[style::id]", icon('icons/obj/supplypods.dmi' , "seethrough-icon"))
			continue
		var/base = style::icon_state
		if (!base)
			Insert("pod_asset[style::id]", icon('icons/obj/supplypods.dmi', "invisible-icon"))
			continue
		var/icon/podIcon = icon('icons/obj/supplypods.dmi', base)
		var/door = style::has_door
		if (door)
			door = "[base]_door"
			podIcon.Blend(icon('icons/obj/supplypods.dmi', door), ICON_OVERLAY)
		var/shape = style::shape
		if (shape == POD_SHAPE_NORMAL)
			var/decal = style::decal_icon
			if (decal)
				podIcon.Blend(icon('icons/obj/supplypods.dmi', decal), ICON_OVERLAY)
			var/glow = style::glow_color
			if (glow)
				glow = "pod_glow_[glow]"
				podIcon.Blend(icon('icons/obj/supplypods.dmi', glow), ICON_OVERLAY)
		Insert("pod_asset[style::id]", podIcon)
