/datum/relic_appearance
	var/list/firstname
	var/list/lastname
	var/icon/icon
	var/list/icon_state
	var/icon/item_left
	var/icon/item_right
	var/list/item_state

/datum/relic_appearance/proc/apply(var/obj/item/A)
	if(icon)
		A.icon = icon
		A.icon_state = pick(icon_state)
	if(item_left && item_right)
		A.lefthand_file = item_left
		A.righthand_file = item_right
		A.item_state = pick(item_state)

/datum/relic_appearance/flash
	firstname = list("tuberous","phosphorescent","fluorescent","flashing","radiant","hypnotizing")
	lastname = list("bulb","mesmerizer","uv-light","diode","infra-emitter")
	icon = 'icons/obj/device.dmi'
	icon_state = list("mindflash","mindflash2","memorizer2","empar","motion1","motion2")
	item_left = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	item_right = 'icons/mob/inhands/equipment/security_righthand.dmi'
	item_state = list("flashtool","seclite","emp")

/datum/relic_appearance/melee
	firstname = list("laser","energy","dodecahedric","geo","radial","nuclear","manual")
	lastname = list("blade","hurtinator","hammer","pulverizer","deboner","cyclotron","din")
	icon = 'icons/obj/items.dmi'
	icon_state = list("indwelder","crowbar_brass","wrench_brass","rcd","jaws_pry","arcd","drill_screw")

/datum/relic_appearance/melee/tool
	firstname = list("mechanical","automatic","serrated","rhombic","triplutic","unstoppable","manual")
	lastname = list("transfibulator","hydrawrench","decalcificator","hyperscrew","doptergun","cryodrill","spintulator")
	icon = 'icons/obj/tools.dmi'
	icon_state = list("indwelder","crowbar_brass","wrench_brass","rcd","jaws_pry","arcd","drill_screw")
	item_left = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	item_right = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = list("rcd","screwdriver_brass","welder1","upindwelder","crowbar_brass","jawsoflife")

/datum/relic_appearance/color/apply(var/obj/item/A)
	color = color_matrix_rotate_hue(rand(360))