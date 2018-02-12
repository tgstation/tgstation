/datum/relic_effect/cosmetic
	var/icon/icon
	var/list/icon_state
	var/icon/item_left
	var/icon/item_right
	var/list/item_state

/datum/relic_effect/cosmetic/apply(var/obj/item/A)
	if(icon)
		A.icon = icon
		A.icon_state = pick(icon_state)
	if(item_left && item_right)
		A.lefthand_file = item_left
		A.righthand_file = item_right
		A.item_state = pick(item_state)

/datum/relic_effect/cosmetic/flash
	firstname = list("tuberous","phosphorescent","fluorescent","flashing","radiant","hypnotizing")
	lastname = list("bulb","mesmerizer","uv-light","diode","infra-emitter")
	icon = 'icons/obj/device.dmi'
	icon_state = list("mindflash","mindflash2","memorizer2","empar","motion1","motion2")
	item_left = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	item_right = 'icons/mob/inhands/equipment/security_righthand.dmi'
	item_state = list("flashtool","seclite","emp")

/datum/relic_effect/cosmetic/melee
	firstname = list("laser","energy","dodecahedric","geo","radial","nuclear","manual")
	lastname = list("hurtinator","hammer","pulverizer","deboner","cyclotron","din")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = list("mjollnir1","mjollnir0","hammeron","sledgehammer","stunbaton","telebaton_1","pride","tailclub","whip","stunbaton_active")
	item_left = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	item_right = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	item_state = list("hammeroff","mjollnir1","mjollnir0","mining_hammer1","hammeroff")

/datum/relic_effect/cosmetic/melee/tool
	firstname = list("mechanical","automatic","serrated","rhombic","triplutic","unstoppable","manual")
	lastname = list("transfibulator","hydrawrench","decalcificator","hyperscrew","doptergun","cryodrill","spintulator")
	icon = 'icons/obj/tools.dmi'
	icon_state = list("indwelder","crowbar_brass","wrench_brass","rcd","jaws_pry","arcd","drill_screw")
	item_left = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	item_right = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = list("rcd","screwdriver_brass","welder1","upindwelder","crowbar_brass","jawsoflife")

/datum/relic_effect/cosmetic/color/apply(var/obj/item/A)
	A.color = color_matrix_rotate_hue(rand(360))

/datum/relic_effect/cosmetic/color/spectral
	firstname = list("spectral","effluevescent","ghastly","paranormal")

/datum/relic_effect/cosmetic/color/spectral/apply(var/obj/item/A)
	var/list/rgb = ReadRGB(HSVtoRGB(hsv(rand(1536),255,rand(128)+128)))
	A.color = list(LUMA_R*rgb[1],LUMA_R*rgb[2],LUMA_R*rgb[3],0, LUMA_G*rgb[1],LUMA_G*rgb[2],LUMA_G*rgb[3],0, LUMA_B*rgb[1],LUMA_B*rgb[2],LUMA_B*rgb[3],0, 0,0,0,1, 0,0,0,0)
	A.blend_mode = BLEND_ADD

/datum/relic_effect/cosmetic/color/sepia
	firstname = list("antique","historical","artifact")

/datum/relic_effect/cosmetic/color/sepia/apply(var/obj/item/A)
	A.color = list(0.393,0.349,0.272,0, 0.769,0.686,0.534,0, 0.189,0.168,0.131,0, 0,0,0,1, 0,0,0,0)
