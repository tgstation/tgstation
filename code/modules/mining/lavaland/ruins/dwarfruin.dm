GLOBAL_LIST_INIT(dwarves_list, list())

/*Dwarf Spawner*/
/obj/machinery/migrant_spawner
	name = "strange portal"
	desc = "A strange portal that acts as a gateway between this world and another. Strange pixelated images fade in and out inside the frame."
	icon = 'icons/obj/device.dmi'
	icon_state = "dorfportal"
	anchored = TRUE
	var/spawns_left = 6
	var/dorf_gear = /datum/outfit/dorf

/obj/machinery/migrant_spawner/proc/ghost_message()
	notify_ghosts("A dwarven fortress is ready for a new wave of migrants.", enter_link = "<a href=?src=\ref[src];ghostjoin=1>(Click to migrate)</a>", source = src, action = NOTIFY_ATTACK)

/obj/machinery/migrant_spawner/Topic(href, href_list)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/machinery/migrant_spawner/Initialize()
	. = ..()
	GLOB.poi_list += src

/obj/machinery/migrant_spawner/Destroy()
	GLOB.poi_list.Remove(src)
	return ..()

/obj/machinery/migrant_spawner/attack_ghost(mob/user)
	if(!SSticker.HasRoundStarted())
		return
	if(spawns_left)
		spawns_left--
		var/client/new_dorf = user.client
		spawn_dorf(new_dorf)
	else
		to_chat(user, "There's no more room at the fortress for new migrants! Wait for them to build a new dormitory.")

/obj/machinery/migrant_spawner/proc/spawn_dorf(client/new_dorf)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(src))
	new_dorf.prefs.copy_to(M)
	M.set_species(/datum/species/dwarf)
	M.key = new_dorf.key
	M.equipOutfit(dorf_gear)
	M.real_name = M.dna.species.random_name()
	to_chat(M, "<span class='notice'>You have arrived. After a journey from The Mountainhomes into the forbidding beyond.\
	 Your harsh trek has finally ended. A new chapter of Dwarven history begins at this place 'Koganusan' -Boatmurdered- Strike the Earth.<br><br>There's been rumors of a station occupied by Humans nearby. It's dangerous to fight them, so you probably shouldn't invade unless they really provoke you.<br>The rest of lavaland is rightfully the Dwarven peoples', and you should forge your own path for the empire, be it friendly or hostile.</span>")
	M.mind.special_role = "Dwarf"
	var/datum/objective/O = new("Make claim to these hellish lands, constructing a great fortress and mining the rock for its precious metals, in the name of the Dwarven people!")
	M.mind.objectives += O
	LAZYADD(GLOB.dwarves_list, M)
	to_chat(src, "<b>Be sure to read the wiki page at https://tgstation13.org/wiki/Lava_Dwarf to learn how to strike the earth!</b>")

/obj/machinery/migrant_spawner/attackby(obj/item/weapon/W, mob/user, params)
	if(isdwarf(user))
		to_chat(user, "You wouldn't dare.")
		return
	else
		..()

/datum/outfit/dorf
	name = "Dwarf Standard"
	uniform = /obj/item/clothing/under/dwarf
	shoes = /obj/item/clothing/shoes/dwarf
	back = /obj/item/weapon/storage/backpack/satchel/leather

/*Misc Items + Crafting Parts*/
/obj/item/weapon/reagent_containers/food/drinks/wooden_mug
	name = "wooden mug"
	desc = "A mug for serving hearty brews."
	icon = 'icons/obj/drinks.dmi'
	item_state = "manlydorfglass"
	icon_state = "manlydorfglass"
	spillable = 1

/obj/item/weapon/sword_hilt
	name = "leather hilt"
	desc = "A handle made of leather, meant as base for a sword."