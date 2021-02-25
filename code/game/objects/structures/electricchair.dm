
/obj/structure/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	var/last_time = 1
	item_chair = null

/obj/structure/chair/e_chair/Initialize()
	. = ..()
	var/obj/item/assembly/shock_kit/stored_kit = new(contents)
	AddComponent(/datum/component/electrified_buckle, (SHOCK_REQUIREMENT_ITEM | SHOCK_REQUIREMENT_LIVE_CABLE), stored_kit, list(image(icon = 'icons/obj/chairs.dmi', icon_state = "echair_over", loc)))

/obj/structure/chair/e_chair/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		var/obj/structure/chair/C = new /obj/structure/chair(loc)
		W.play_tool_sound(src)
		C.setDir(dir)
		qdel(src)
