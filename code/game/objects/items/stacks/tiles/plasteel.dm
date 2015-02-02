/obj/item/stack/tile

/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	w_class = 3.0
	force = 6.0
	m_amt = 937.5
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/plasteel
	mineralType = "metal"

/obj/item/stack/tile/plasteel/cyborg
	desc = "The ground you walk on" //Not the usual floor tile desc as that refers to throwing, Cyborgs can't do that - RR
	m_amt = 0 // All other Borg versions of items have no Metal or Glass - RR
	is_cyborg = 1
	cost = 125

/obj/item/stack/tile/plasteel/New(var/loc, var/amount=null)
	..()
	src.pixel_x = rand(1, 14)
	src.pixel_y = rand(1, 14)
	return


