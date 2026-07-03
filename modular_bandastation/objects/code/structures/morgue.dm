#define CREMATORIUM_REPAIR_IGNITERS 5
/// Repair stages
#define CREMATORIUM_STAGE_IGNITERS 0
#define CREMATORIUM_STAGE_SCREWDRIVER 1
#define CREMATORIUM_STAGE_PLASTEEL 2
#define CREMATORIUM_STAGE_WELDING 3

/obj/structure/bodycontainer/crematorium/atom_deconstruct(disassembled = TRUE)
	var/obj/structure/bodycontainer/crematorium/broken/B = new(loc)
	B.dir = dir
	B.id = id
	for(var/atom/movable/movable in contents)
		if(movable == connected)
			continue
		movable.forceMove(B)
	qdel(src)

/obj/structure/bodycontainer/crematorium/broken
	name = "broken crematorium"
	desc = "Сломанный крематорий, но выглядит так, будто его можно починить."
	icon = 'modular_bandastation/objects/icons/obj/structures/crematorium.dmi'
	icon_state = "crema_broken"
	base_icon_state = "crema_broken"
	dir = SOUTH
	resistance_flags = INDESTRUCTIBLE
	density = TRUE
	anchored = TRUE
	var/repair_stage = 0
	var/igniters_installed = 0
	var/sparking = TRUE

/obj/structure/bodycontainer/crematorium/broken/Initialize(mapload)
	. = ..()
	GLOB.crematoriums -= src
	START_PROCESSING(SSobj, src)

/obj/structure/bodycontainer/crematorium/broken/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/bodycontainer/crematorium/broken/open()
	return FALSE

/obj/structure/bodycontainer/crematorium/broken/cremate()
	return

/obj/structure/bodycontainer/crematorium/broken/attack_hand(mob/user)
	to_chat(user, span_warning("Крематорий сломан."))

/obj/structure/bodycontainer/crematorium/broken/process(seconds_per_tick)

	if(!sparking)
		return
	if(prob(20))
		do_sparks(3, FALSE, src)
	if(prob(30))
		playsound(src, 'sound/items/tools/welder.ogg', 25, TRUE)

//MARK: Процесс ремонта
/obj/structure/bodycontainer/crematorium/broken/attackby(obj/item/W, mob/user, params)

// The first stage of repair is the use of 5 igniters
	if(isigniter(W) && repair_stage == CREMATORIUM_STAGE_IGNITERS)
		qdel(W)
		igniters_installed++
		to_chat(user, span_notice("Вы устанавливаете воспламенитель в крематорий. ([igniters_installed]/[CREMATORIUM_REPAIR_IGNITERS])"))
		if(igniters_installed >= CREMATORIUM_REPAIR_IGNITERS)
			repair_stage = CREMATORIUM_STAGE_SCREWDRIVER
			sparking = FALSE
			to_chat(user, span_notice("Система поджига восстановлена. Теперь необходимо закрепить воспламенители отверткой."))
		return

// The second stage of repair is using a screwdriver
	if(W.tool_behaviour == TOOL_SCREWDRIVER && repair_stage ==  CREMATORIUM_STAGE_SCREWDRIVER)
		to_chat(user, span_notice("Вы начинаете закреплять воспламенители крематория..."))
		if(!W.use_tool(src, user, 3 SECONDS))
			return
		repair_stage = CREMATORIUM_STAGE_PLASTEEL
		to_chat(user, span_notice("Воспламенители закреплены. Теперь требуется пласталь."))
		return

// The third stage of repair is the use of 2 sheets of plasteel, changing the sprite
	if(istype(W, /obj/item/stack/sheet/plasteel) && repair_stage ==  CREMATORIUM_STAGE_PLASTEEL)
		var/obj/item/stack/sheet/plasteel/P = W
		if(P.amount < 2)
			to_chat(user, span_warning("Необходимо 2 листа пластали!"))
			return
		P.use(2)
		icon_state = "crema_broken1"
		repair_stage = CREMATORIUM_STAGE_WELDING
		update_appearance()
		to_chat(user, span_notice("Вы заменяете поврежденные панели пласталью. Осталось заварить корпус."))
		return

// The fourth stage of the renovation is the use of welding to turn the building back into a functioning crematorium.
	if(W.tool_behaviour == TOOL_WELDER && repair_stage == CREMATORIUM_STAGE_WELDING)
		if(!W.tool_start_check(user, amount = 1))
			return
		to_chat(user, span_notice("Вы начинаете восстанавливать крематорий..."))
		if(!W.use_tool(src, user, 5 SECONDS, amount = 1))
			return
		for(var/atom/movable/movable in contents)
			if(movable == connected)
				continue
			movable.forceMove(get_step(src, dir))
		var/obj/structure/bodycontainer/crematorium/C = new(loc)
		C.dir = dir
		C.id = id
		to_chat(user, span_notice("Вы полностью починили крематорий."))
		qdel(src)
		return

	return ..()

/obj/structure/bodycontainer/crematorium/broken/examine(mob/user)
	. = ..()
	switch(repair_stage)
		if(CREMATORIUM_STAGE_IGNITERS)
			. += span_notice("Крематорий поврежден. Требуется установить [span_bold("воспламенители")] ([igniters_installed]/5)")
		if(CREMATORIUM_STAGE_SCREWDRIVER)
			. += span_notice("Компоненты не закреплены. Нужна [span_bold("отвертка")]")
		if(CREMATORIUM_STAGE_PLASTEEL)
			. += span_notice("Корпус поврежден. Требуется несколько листов [span_bold("пластали")]")
		if(CREMATORIUM_STAGE_WELDING)
			. += span_notice("Осталось заварить корпус [span_bold("сваркой")]")

#undef CREMATORIUM_REPAIR_IGNITERS

#undef CREMATORIUM_STAGE_IGNITERS
#undef CREMATORIUM_STAGE_SCREWDRIVER
#undef CREMATORIUM_STAGE_PLASTEEL
#undef CREMATORIUM_STAGE_WELDING
