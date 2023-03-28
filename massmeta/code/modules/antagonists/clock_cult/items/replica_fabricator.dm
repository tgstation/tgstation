#define BRASS_POWER_COST 10

/obj/item/clockwork/replica_fabricator
	name = "производитель реплик"
	icon = 'massmeta/icons/obj/clockwork_objects.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	lefthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	icon_state = "replica_fabricator"
	desc = "Странное латунное устройство с множеством вращающихся зубцов и вентиляционных отверстий."
	clockwork_desc = "Устройство, используемое для быстрого изготовления чего-то из латуни."

/obj/item/clockwork/replica_fabricator/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user))
		. += "<hr>"
		. += "Используй на латуни, чтобы преобразовать ее в энергию."
		. += "\nИспользуй на других материалах, чтобы превратить их в латунь."
		. += "\nИспользуй в руке для изготовления латуни по 10Вт/лист."
		. += "\nИспользуй для ремонта поврежденных механизмов."
		. += "\nМожет трансформировать некоторые обьекты в их латунную альтернативу."

/obj/item/clockwork/replica_fabricator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !is_servant_of_ratvar(user))
		return
	if(istype(target, /obj/item/stack/sheet/bronze))
		var/obj/item/stack/sheet/bronze/B = target
		qdel(B)
		GLOB.clockcult_power += B.amount * BRASS_POWER_COST
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_nzcrentr("Превращаю [B.amount] латуни в [B.amount * BRASS_POWER_COST] ватт энергии."))
	else if(istype(target, /obj/item/stack/sheet))
		var/obj/item/stack/S = target
		var/obj/item/stack/sheet/bronze/B = new(get_turf(S))
		B.amount = FLOOR(S.amount * 0.5, 1)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_nzcrentr("Превращаю [S.amount] [S] в [S.amount] латуни."))
		qdel(target)
	else if(isturf(target))
		var/turf/T = target
		if(isfloorturf(target) && !isindestructiblefloor(target))
			if(istype(target,/turf/open/floor/clockwork))
				if(GLOB.clockcult_power < 700)
					user.balloon_alert(user, "not enough power")
					return
				user.balloon_alert(user, "constructing a wall...")
				if(!do_after(user, 15 SECONDS, target))
					return
				if(GLOB.clockcult_power < 700)
					user.balloon_alert(user, "not enough power")
					return
				T.ChangeTurf(/turf/closed/wall/clockwork)
				GLOB.clockcult_power -= 700
			else
				if(GLOB.clockcult_power < 350)
					user.balloon_alert(user, "not enough power")
					return
				user.balloon_alert(user, "transforming [target]...")
				if(!do_after(user, 5 SECONDS, target))
					return
				if(GLOB.clockcult_power < 350)
					user.balloon_alert(user, "not enough power")
					return
				T.ChangeTurf(/turf/open/floor/clockwork)
				GLOB.clockcult_power -= 350
				return
		else if (iswallturf(target) && (isindestructiblewall(target)))
			if(istype(target, /turf/closed/wall/clockwork))
				if(GLOB.clockcult_power < 550)
					user.balloon_alert(user, "not enough power")
					return
				user.balloon_alert(user, "deconstructing [target]...")
				if(!do_after(user, 12.5 SECONDS, target))
					return
				if(GLOB.clockcult_power < 550)
					user.balloon_alert(user, "not enough power")
					return
				T.ChangeTurf(/turf/open/floor/clockwork)
				GLOB.clockcult_power -= 550
				return
			else
				if(GLOB.clockcult_power < 300)
					user.balloon_alert(user, "not enough power")
					return
				user.balloon_alert(user, "transforming [target]...")
				if(!do_after(user, 10 SECONDS, target))
					return
				if(GLOB.clockcult_power < 300)
					user.balloon_alert(user, "not enough power")
					return
				T.ChangeTurf(/turf/closed/wall/clockwork)
				GLOB.clockcult_power -= 300
				return

	else if(istype(target, /obj/machinery/door/airlock) && !istype(target, /obj/machinery/door/airlock/clockwork))
		if(GLOB.clockcult_power < 750)
			user.balloon_alert(user, "not enough power")
			return
		user.balloon_alert(user, "transforming [target]...")
		if(!do_after(user, 15 SECONDS, target))
			return
		if(GLOB.clockcult_power < 750)
			user.balloon_alert(user, "not enough power")
			return
		target.ratvar_act()	

	else if(istype(target, /obj/structure/destructible/clockwork))
		var/obj/structure/destructible/clockwork/C = target
		if(!C.can_be_repaired)
			to_chat(user, span_nzcrentr("Не могу починить [C]!"))
			return
		if(GLOB.clockcult_power < 200)
			to_chat(user, span_nzcrentr("Требуется [200 - GLOB.clockcult_power]W для починки [C]..."))
			return
		if(C.max_integrity == C.atom_integrity)
			to_chat(user, span_nzcrentr("[C] уже в порядке!"))
			return
		to_chat(user, span_nzcrentr("Начинаю ремонтировать [C]..."))
		if(do_after(user, 60, target=target))
			if(C.max_integrity == C.atom_integrity)
				to_chat(user, span_nzcrentr("[C] уже в порядке!"))
				return
			if(GLOB.clockcult_power < 200)
				to_chat(user, span_nzcrentr("Требуется [200 - GLOB.clockcult_power]W для починки [C]..."))
				return
			GLOB.clockcult_power -= 200
			to_chat(user, span_nzcrentr("Чиню некоторый урон на [C]."))
			C.atom_integrity = clamp(C.atom_integrity + 15, 0, C.max_integrity)
		else
			to_chat(user, span_nzcrentr("Не вышло починить [C]..."))

/obj/item/clockwork/replica_fabricator/attack_self(mob/user)
	if(!is_servant_of_ratvar(user))
		return
	fabricate_sheets(get_turf(user), user)

/obj/item/clockwork/replica_fabricator/proc/fabricate_sheets(turf/target, mob/user)
	var/sheets = FLOOR(clamp(GLOB.clockcult_power / BRASS_POWER_COST, 0, 50), 1)
	if(sheets == 0)
		return
	GLOB.clockcult_power -= sheets * BRASS_POWER_COST
	new /obj/item/stack/sheet/bronze(target, sheets)
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, span_brass("Создаю [sheets] листов латуни."))
