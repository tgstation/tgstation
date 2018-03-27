/turf/open/floor/plating/desert
	name = "sand"
	baseturfs = /turf/open/floor/plating/desert
	icon = 'code/white/hule/desertmapgen/desert.dmi'
	icon_state = "desert"
	icon_plating = "desert"
	postdig_icon_change = TRUE
	initial_gas_mix = "o2=22;n2=82;TEMP=350"
	archdrops = list(/obj/item/stack/ore/glass = 5)
	attachment_holes = FALSE
	planetary_atmos = TRUE

/turf/open/floor/plating/desert/Initialize()
	. = ..()
	if(prob(20))
		icon_state = "desert[rand(0,5)]"

/turf/open/floor/plating/desert/burn_tile()
	return

/turf/open/floor/plating/desert/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0)
	return

/turf/open/floor/plating/desert/MakeDry(wet_setting = TURF_WET_WATER)
	return

turf/open/floor/plating/desert/attackby(obj/item/W, mob/user, params)
	if(..())
		return TRUE
	if(istype(W, /obj/item/storage/bag/ore))
		var/obj/item/storage/bag/ore/S = W
		if(S.collection_mode == 1)
			for(var/obj/item/ore/O in src.contents)
				O.attackby(W,user)
				return

	if(istype(W, /obj/item/stack/tile))
		var/obj/item/stack/tile/Z = W
		if(!Z.use(1))
			return
		var/turf/open/floor/T = ChangeTurf(Z.turf_type)
		if(istype(Z, /obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
			var/obj/item/stack/tile/light/L = Z
			var/turf/open/floor/light/F = T
			F.state = L.state
		playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
		return

/turf/open/floor/plating/desert/singularity_act()
	return //у нас тут пустыня на планете, будет не круто если пройдет шингулярити и оставит после себя спесс

/turf/open/floor/plating/desert/ex_act(severity, target)
	. = SendSignal(COMSIG_ATOM_EX_ACT, severity, target)
	contents_explosion(severity, target)

/*/turf/open/floor/plating/desert/nevada
	name = "sand"
	baseturfs = /turf/open/floor/plating/desert/nevada
	icon = 'code/white/hule/desertmapgen/desert.dmi'
	icon_state = "nevadadesert"
	icon_plating = "nevadadesert"
	postdig_icon_change = TRUE
	initial_gas_mix = "o2=22;n2=82;TEMP=350"
	archdrops = list(/obj/item/ore/glass = 5)
	attachment_holes = FALSE
	planetary_atmos = TRUE

/turf/open/floor/plating/desert/Initialize()
	. = ..()
	if(prob(20))
		icon_state = "nevadadesert[rand(0,5)]"*/












/area/ruin/unpowered/desert
	outdoors = TRUE