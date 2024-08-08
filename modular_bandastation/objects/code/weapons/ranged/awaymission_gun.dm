/obj/item/gun/energy/laser/awaymission_aeg
	name = "Exploreverse Mk.I"
	desc = "Прототип оружия с миниатюрным реактором для исследований в крайне отдаленных секторах. \
	\n Данная модель использует экспериментальную систему обратного восполнения, работающую на принципе огромной аккумуляции энергии, но крайне уязвимую к радиопомехам, которыми кишит сектор станции, попростую не работая там."
	icon = 'modular_bandastation/objects/icons/guns.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/inhands/guns_righthand.dmi'
	icon_state = "laser_gate"
	inhand_icon_state = "laser_gate"
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/awaymission_aeg)
	can_select = FALSE
	selfcharge = TRUE
	ammo_x_offset = 0
	can_charge = FALSE

/obj/item/ammo_casing/energy/lasergun/awaymission_aeg
	e_cost = LASER_SHOTS(20, STANDARD_CELL_CHARGE)

/obj/item/gun/energy/laser/awaymission_aeg/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(check_z))
	check_z()

/obj/item/gun/energy/laser/awaymission_aeg/proc/check_z()
	SIGNAL_HANDLER

	if(onAwayMission())
		selfcharge = TRUE
		if(ismob(loc))
			to_chat(loc, span_notice("[src.name] активируется, начиная аккумулировать энергию из материи сущего."))
	else
		selfcharge = FALSE
		cell.change(-STANDARD_BATTERY_CHARGE)
		update_appearance()
		if(ismob(loc))
			to_chat(loc, span_danger("[src.name] деактивируется, так как он подавляется системами станции."))
			recharge_newshot(no_cyborg_drain = TRUE)

/obj/item/gun/energy/laser/awaymission_aeg/mk2
	name = "Exploreverse Mk.II"
	desc = "Второй прототип оружия с миниатюрным реактором и забавным рычагом для исследований в крайне отдаленных секторах. \
	\nДанная модель оснащена системой ручного восполнения энергии \"Za.E.-8 A.L'sya\", \
	позволяющей в короткие сроки восполнить необходимую электроэнергию с помощью ручного труда и конвертации личной энергии подключенного к системе зарядки. \
	\nТеперь еще более нелепый дизайн с торчащими проводами!"
	icon_state = "laser_gate_mk2"

/obj/item/gun/energy/laser/awaymission_aeg/mk2/attack_self(mob/living/user)
	. = ..()
	if(!onAwayMission())
		user.balloon_alert(user, "не в гейте!")
		return FALSE

	if(cell.charge >= cell.maxcharge)
		user.balloon_alert(user, "полностью заряжен!")
		return FALSE

	if(user.nutrition <= NUTRITION_LEVEL_STARVING)
		user.balloon_alert(user, "недостаточно сил!")
		return FALSE

	user.balloon_alert(user, "зарядка...")
	playsound(src, 'sound/effects/sparks3.ogg', 10, 1)
	do_sparks(1, 1, src)

	if(!do_after(user, 3 SECONDS, target = src))
		return
	cell.give(STANDARD_CELL_CHARGE * 0.1)
	user.adjust_nutrition(-10)

/datum/design/exploreverse_mk1
	name = "Exploreverse Mk.I"
	desc = "Энергетическое оружие с экспериментальным миниатюрным реактором. Работает только во вратах."
	id = "exploreverse_mk1"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.75,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 0.75,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25
	)
	build_path = /obj/item/gun/energy/laser/awaymission_aeg
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_RANGED,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE
/datum/design/exploreverse_mk2
	name = "Exploreverse Mk.II"
	desc = "Энергетическое оружие с экспериментальным миниатюрным реактором и рычагом для ручной зарядки. Работает только во вратах."
	id = "exploreverse_mk2"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.5
	)
	build_path = /obj/item/gun/energy/laser/awaymission_aeg/mk2
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_RANGED,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/mining/New()
	. = ..()
	design_ids |= "exploreverse_mk1"

/datum/techweb_node/plasma_mining/New()
	. = ..()
	design_ids |= "exploreverse_mk2"
