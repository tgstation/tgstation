/obj/item/gun/energy/eg_14
	name = "EG-14 advanced energy revolver"
	desc = "Продвинутый энергетический пистолет. Выглядит стильно, а его дизайн делает его немного лучше в качестве оружия ближнего боя. \
	Переключатель режимов имеет два положения: «disable» и «kill»."
	cell_type = /obj/item/stock_parts/power_store/cell/hos_gun
	icon = 'modular_bandastation/weapon/icons/ranged/energy.dmi'
	icon_state = "bsgun"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/energy/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/energy/righthand.dmi'
	inhand_icon_state = null
	force = 7
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser/hos)
	ammo_x_offset = 2
	modifystate = TRUE

/obj/item/gun/energy/eg_14/examine_more(mob/user)
	. = ..()
	. += {"
		EG-14 — это премиальное предложение Shellguard Munitions на рынке энергетического оружия.
		Оно равно или превосходит EG-7 по всем параметрам, сохраняя ту же скорострельность, останавливающую силу и ёмкость батареи.
		Кроме того, благодаря улучшенной эргономике и распределению веса, EG-14 лучше подходит для использованияв качестве импровизированного
		оружия ближнего боя, всё это в компактном формате пистолета.

		Барабан револьвера действительно поворачивается с каждым выстрелом, и его можно прокручивать так же, как барабан баллистического револьвера.
		Однако это никак не влияет на функциональность оружия и добавлено исключительно в декоративных целях.

		Цена EG-14 делает его недоступным для значительной части рынка, однако он пользуется большим спросом среди телохранителей и охотников за головами.
	"}

/obj/item/gun/energy/eg_14/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 19, \
		overlay_y = 10 \
	)
