/obj/item/gun/energy/laser/awaymission_aeg
	name = "Exploreverse Mk.I"
	desc = "Прототип оружия с миниатюрным реактором для исследований в крайне отдаленных секторах."
	icon = 'modular_bandastation/weapon/icons/ranged/energy.dmi'
	icon_state = "laser_gate"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/energy/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/energy/righthand.dmi'
	inhand_icon_state = "laser_gate"
	pin = /obj/item/firing_pin/explorer
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/awaymission_aeg)
	ammo_x_offset = 0
	charge_delay = 10
	selfcharge = TRUE
	can_charge = FALSE
	var/going_boom = FALSE

/obj/projectile/beam/laser/awaymission_aeg
	name = "weak laser"
	wound_bonus = -100
	exposed_wound_bonus = -100
	damage = 15

/obj/item/ammo_casing/energy/lasergun/awaymission_aeg
	projectile_type = /obj/projectile/beam/laser/awaymission_aeg
	e_cost = LASER_SHOTS(20, STANDARD_CELL_CHARGE)

/obj/item/gun/energy/laser/awaymission_aeg/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || going_boom)
		return
	var/turf/current_turf = get_turf(src)
	going_boom = TRUE
	addtimer(CALLBACK(src, PROC_REF(boom)), 3 SECONDS)
	do_sparks(3, FALSE, current_turf)
	playsound(current_turf, 'sound/effects/alert.ogg', 35, TRUE)
	loc.visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает пищать и светиться!"), span_userdanger("[capitalize(declent_ru(NOMINATIVE))] начинает пищать и светиться!"))

/obj/item/gun/energy/laser/awaymission_aeg/proc/boom()
	explosion(src, -1, -1, 1, 2)
	qdel(src)

/obj/item/gun/energy/laser/awaymission_aeg/mk2
	name = "Exploreverse Mk.II"
	desc = "Второй прототип оружия с миниатюрным реактором и забавным рычагом для исследований в крайне отдаленных секторах. \
	\nДанная модель оснащена системой ручного восполнения энергии \"Za.E.-8 A.L'sya\", \
	позволяющей в короткие сроки восполнить необходимую электроэнергию с помощью ручного труда и конвертации личной энергии подключенного к системе зарядки. \
	\nТеперь еще более нелепый дизайн с торчащими проводами!"
	icon_state = "laser_gate_mk2"

/obj/item/gun/energy/laser/awaymission_aeg/mk2/attack_self(mob/living/user)
	. = ..()
	if(cell.charge >= cell.maxcharge)
		user.balloon_alert(user, "полностью заряжен!")
		return FALSE

	if(user.nutrition <= NUTRITION_LEVEL_STARVING)
		user.balloon_alert(user, "недостаточно сил!")
		return FALSE

	user.balloon_alert(user, "зарядка...")
	playsound(src, 'sound/effects/sparks/sparks3.ogg', 10, 1)
	do_sparks(1, 1, src)

	if(!do_after(user, 3 SECONDS, target = src))
		return
	var/obj/item/ammo_casing/energy/ammo = ammo_type[1]
	cell.give(ammo::e_cost)
	user.adjust_nutrition(-10)

/datum/design/exploreverse_mk1
	name = "Exploreverse Mk.I"
	desc = "Энергетическое оружие с экспериментальным миниатюрным реактором."
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
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SECURITY
/datum/design/exploreverse_mk2
	name = "Exploreverse Mk.II"
	desc = "Энергетическое оружие с экспериментальным миниатюрным реактором и рычагом для ручной зарядки."
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
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SECURITY

/datum/techweb_node/mining/New()
	. = ..()
	design_ids |= "exploreverse_mk1"

/datum/techweb_node/plasma_mining/New()
	. = ..()
	design_ids |= "exploreverse_mk2"
