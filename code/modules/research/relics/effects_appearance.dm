/datum/relic_effect/cosmetic
	hogged_signals = list("icon")
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

/datum/relic_effect/cosmetic/device
	weight = 20
	firstname = list("geiger","pulse","advanced","wave","triangulation","biptophasic")
	lastname = list("analyzer","scanner","verifier","sensor","counter","unenzalificator","determinator","emitter","sender","receiver")
	icon = 'icons/obj/device.dmi'
	icon_state = list("hand_tele","shield1","atmos","health_adv","hydro","locator","multitool","signmaker_sec","geiger_on_emag")

/datum/relic_effect/cosmetic/device/assembly
	weight = 20
	firstname = list("automatic","engineering","self-replicating","urthic","signal","z-field")
	lastname = list("fuse","detonator","rig","radio","communicator","tripper","activator","trigger")
	icon = 'icons/obj/assemblies.dmi'
	icon_state = list("armor-igniter-analyzer","radio-igniter-tank","radio-multitool","radio-radio","chemcore","mmi_brain","timer-radio2","timer-multitool2","timer-igniter2")

/datum/relic_effect/cosmetic/device/flash
	weight = 20
	firstname = list("tuberous","phosphorescent","fluorescent","flashing","radiant","hypnotizing")
	lastname = list("bulb","mesmerizer","uv-light","diode","infra-emitter")
	icon = 'icons/obj/device.dmi'
	icon_state = list("mindflash","mindflash2","memorizer2","empar","motion1","motion2")
	item_left = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	item_right = 'icons/mob/inhands/equipment/security_righthand.dmi'
	item_state = list("flashtool","seclite","emp")

/datum/relic_effect/cosmetic/melee
	weight = 50
	firstname = list("laser","energy","dodecahedric","geo","radial","nuclear","manual")
	lastname = list("hurtinator","hammer","pulverizer","deboner","cyclotron","din")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = list("mjollnir1","mjollnir0","hammeron","sledgehammer","stunbaton","telebaton_1","pride","whip","stunbaton_active")
	item_left = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	item_right = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	item_state = list("hammeroff","mjollnir1","mjollnir0","mining_hammer1","hammeroff")

/datum/relic_effect/cosmetic/melee/tool
	weight = 50
	firstname = list("mechanical","automatic","serrated","rhombic","triplutic","unstoppable","manual")
	lastname = list("transfibulator","hydrawrench","decalcificator","hyperscrew","doptergun","cryodrill","spintulator")
	icon = 'icons/obj/tools.dmi'
	icon_state = list("indwelder","crowbar_brass","wrench_brass","rcd","jaws_pry","arcd","drill_screw")
	item_left = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	item_right = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = list("rcd","screwdriver_brass","welder1","upindwelder","crowbar_brass","jawsoflife")

/datum/relic_effect/cosmetic/melee/tool/surgical
	weight = 20
	firstname = list("medical","surgical","torsic","cerebral","vartic")
	lastname = list("degibbulator","sonictool","vivisector","biolopter","pulse cauterizer","exocutter")
	icon = 'icons/obj/surgery.dmi'
	icon_state = list("scalpel","cautery","retractor","hemostat","bone setter","saw","esaw_1","drill")
	item_left = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	item_right = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = list("scalpel","hypo","medipen","defibunit","saw","syringe_15")

/datum/relic_effect/cosmetic/ore
	weight = 20
	firstname = list("ferric","dremell","zx-68","crystalline benzene","petric","AG54")
	lastname = list("alloy","mineral","metal","steel","geode","ore")
	icon = 'icons/obj/mining.dmi'
	icon_state = list("Plasma ore","sheet-gold_3","sheet-diamond","Diamond ore","Uranium ore","goliath_hide_3","Bananium ore","Adamantine ore","sheet-mythril","Gibtonite ore 2","sheet-uranium")

/datum/relic_effect/cosmetic/color
	hogged_signals = list("color")
	weight = 100

/datum/relic_effect/cosmetic/color/apply(var/obj/item/A)
	A.add_atom_colour(color_matrix_rotate_hue(rand(360)), FIXED_COLOUR_PRIORITY)

/datum/relic_effect/cosmetic/color/spectral
	weight = 20
	firstname = list("spectral","effluevescent","ghastly","paranormal")

/datum/relic_effect/cosmetic/color/spectral/apply(var/obj/item/A)
	var/list/rgb = ReadRGB(HSVtoRGB(hsv(rand(1536),255,rand(128)+128)))
	rgb[1] /= 255
	rgb[2] /= 255
	rgb[3] /= 255
	A.add_atom_colour(list(LUMA_R*rgb[1],LUMA_R*rgb[2],LUMA_R*rgb[3],0, LUMA_G*rgb[1],LUMA_G*rgb[2],LUMA_G*rgb[3],0, LUMA_B*rgb[1],LUMA_B*rgb[2],LUMA_B*rgb[3],0, 0,0,0,1, 0.5,0.5,0.5,0), FIXED_COLOUR_PRIORITY)
	A.blend_mode = BLEND_ADD

/datum/relic_effect/cosmetic/color/sepia
	weight = 30
	firstname = list("antique","historical","artifact")

/datum/relic_effect/cosmetic/color/sepia/apply(var/obj/item/A)
	A.add_atom_colour(list(0.393,0.349,0.272,0, 0.769,0.686,0.534,0, 0.189,0.168,0.131,0, 0,0,0,1, 0,0,0,0), FIXED_COLOUR_PRIORITY)

/datum/relic_effect/cosmetic/color/shadow
	weight = 20

/datum/relic_effect/cosmetic/color/shadow/apply(var/obj/item/A)
	A.add_atom_colour("#000000", FIXED_COLOUR_PRIORITY)
	var/mutable_appearance/ma = mutable_appearance('icons/effects/effects.dmi', "electricity")
	ma.color = "#FF0000"
	ma.blend_mode = BLEND_ADD
	ma.appearance_flags = RESET_COLOR
	A.add_overlay(ma)

/datum/relic_effect/cosmetic/color/gold
	weight = 20
	var/static/list/precious_colors = list("#FD0017","#C0C0C0","#B87833")

/datum/relic_effect/cosmetic/color/gold/apply(var/obj/item/A)
	var/list/rgb = ReadRGB(pick(precious_colors))
	rgb[1] /= 255
	rgb[2] /= 255
	rgb[3] /= 255
	A.add_atom_colour(list(LUMA_R*rgb[1],LUMA_R*rgb[2],LUMA_R*rgb[3],0, LUMA_G*rgb[1],LUMA_G*rgb[2],LUMA_G*rgb[3],0, LUMA_B*rgb[1],LUMA_B*rgb[2],LUMA_B*rgb[3],0, 0,0,0,1, 0.5,0.5,0.5,0), FIXED_COLOUR_PRIORITY)
	var/mutable_appearance/ma = mutable_appearance('icons/effects/effects.dmi', "shieldsparkles")
	ma.color = A.color
	ma.appearance_flags = RESET_COLOR
	A.add_overlay(ma)

/datum/relic_effect/cosmetic/color/lightning
	hogged_signals = list()
	weight = 5

/datum/relic_effect/cosmetic/color/lightning/apply(var/obj/item/A)
	var/mutable_appearance/ma = mutable_appearance('icons/effects/effects.dmi', "electricity")
	ma.appearance_flags = RESET_COLOR
	ma.blend_mode = BLEND_ADD
	A.add_overlay(ma)