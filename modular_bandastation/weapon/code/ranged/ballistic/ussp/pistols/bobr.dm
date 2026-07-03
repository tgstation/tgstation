/obj/item/gun/ballistic/revolver/bobr
	name = "Bóbr revolver"
	desc = "Устаревшая попытка увеличить размер револьвера до «пригодного для использования» калибра для пограничных и/или отдаленных планет. \
		Очевидно, результатом этих усилий стал барабан на четыре патрона, изготовленный для патронов 12-го калибра."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev12ga
	recoil = 2
	weapon_weight = WEAPON_LIGHT
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "bobr"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/revolver_fire.ogg'
	spread = 15
	pb_knockback = 1

/obj/item/gun/ballistic/revolver/bobr/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/revolver/bobr/examine_more(mob/user)
	. = ..()
	. += "\"Бобр\" — это дробовик 12-го калибра, имеющий несколько комичный вид револьвера, \
		что не способствует контролю отдачи и прицеливанию. <br><br>\
		\"Бобр\" изначально разрабатывался как спортивное оружие ограниченного выпуска, \
		но быстро завоевал популярность как среди колониальных ополченцев, так и среди населения суровых пограничных территорий. \
		Он пользуется популярностью у контрабандистов по обе стороны закона из-за легкости поиска и перезарядки патронов. \
		В отличие от спортивных вариантов из серебра и дерева, это модель, предназначенная исключительно для выживания, с \
		стандартной прорезиненной рукояткой пистолета и устойчивым к погодным условиям покрытием. \
		Хотя \"Бобр\" и не является самым привлекательным оружием, оно, по крайней мере, довольно практичное."

/obj/item/gun/ballistic/revolver/bobr/short
	name = "snubnose Bóbr revolver"
	desc = parent_type::desc + "<br>Укороченная версия, помещающаяся в карманы. Большой дамский угодник."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev12ga
	recoil = 3
	weapon_weight = WEAPON_LIGHT
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "bobr_short"
