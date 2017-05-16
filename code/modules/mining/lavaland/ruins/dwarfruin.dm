#define DWARF_COOLDOWN 6000 //10 minutes

/*Dwarf Spawner*/
/obj/machinery/migrant_spawner
	name = "strange portal"
	desc = "A strange portal that actas a gateway between this world and another. Strange pixelated images fade in and out inside the frame."
	icon = 'icons/obj/device.dmi'
	icon_state = "dorfportal"
	anchored = TRUE
	var/respawn_cooldown = DWARF_COOLDOWN
	var/list/spawned_dorfs = list()
	var/list/spawned_mobs = list()
	var/list/recently_dead_ckeys = list()
	var/dorf_gear = /datum/outfit/dorf

/obj/machinery/migrant_spawner/Initialize()
	..()
	GLOB.poi_list += src

/obj/machinery/migrant_spawner/Destroy()
	GLOB.poi_list.Remove(src)
	..()

/obj/machinery/migrant_spawner/process()
	for(var/i in spawned_mobs)
		if(!i)
			LAZYREMOVE(spawned_mobs, i)
			continue
		var/mob/living/M = i
		if(M.stat == DEAD) //adding timer to dead dwarfs
			add_dorf_timer(M)

/obj/machinery/migrant_spawner/attack_ghost(mob/user)
	if(!SSticker.HasRoundStarted())
		return
	if(user.ckey in spawned_dorfs)
		if(user.ckey in recently_dead_ckeys)
			to_chat(user, "It must be more than [respawn_cooldown/600] minutes from your last death to respawn!")
			return
		var/client/new_dorf = user.client
		if(user.mind && user.mind.current)
			add_dorf_timer(user.mind.current)
		spawn_dorf(new_dorf)
		return

	spawned_dorfs += user.ckey
	var/client/new_dorf = user.client
	if(user.mind && user.mind.current)
		add_dorf_timer(user.mind.current)
	spawn_dorf(new_dorf)

/obj/machinery/migrant_spawner/proc/add_dorf_timer(mob/living/body)
	if(isliving(body))
		LAZYADD(recently_dead_ckeys, body.ckey)
		addtimer(CALLBACK(src, .proc/clear_cooldown, body.ckey), respawn_cooldown, TIMER_UNIQUE)

/obj/machinery/migrant_spawner/proc/clear_cooldown(var/ckey)
	LAZYREMOVE(recently_dead_ckeys, ckey)

/obj/machinery/migrant_spawner/proc/spawn_dorf(client/new_dorf)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(src))
	new_dorf.prefs.copy_to(M)
	M.set_species(/datum/species/dwarf)
	M.key = new_dorf.key
	M.equipOutfit(dorf_gear)
	M.real_name = M.dna.species.random_name()
	to_chat(M, "<span class='notice'>While traveling in the caravan in search of prosperous lands for a new fortress, your group stumbled upon \
		an ancient portal, humming with ancient runic magic. One brave dwarf stepped through unknowing of what was beyond, surprisngly coming back to report\
		 a hellscape riche in precious metals far beyond what they've ever seen. Your caravan travels through, deciding to take claim to this \
		foriegn world and mark a great beginning for dwarves and future migrants in these lands.</span>")
	M.mind.special_role = "Dwarf"
	var/datum/objective/O = new("Make claim to these hellish lands, constructing a great fortress and mining the rock for its precious metals, in the name of the Dwarven people!")
	M.mind.objectives += O
	LAZYADD(spawned_mobs, M)

/datum/outfit/dorf
	name = "Dwarf Standard"
	uniform = /obj/item/clothing/under/color/grey //they're greys gettit
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/weapon/storage/backpack


/*Anvil + Blacksmith Tools*/
/obj/structure/blacksmith_anvil
	name = "anvil"
	desc = "A sturdy anvil made of forged steel, used for crafting various weapons, tools, or armor."
	icon = 'icons/obj/blacksmith/blacksmithingx32.dmi'
	icon_state = "anvil"

/obj/structure/blacksmith_forge
	name = "forge"
	desc = "A pit of magma burning hot, meant to heat metals for shaping and tempering."
	icon = 'icons/obj/blacksmith/blacksmithingx64.dmi'
	icon_state = "forge"
	pixel_x = -16
	resistance_flags = FIRE_PROOF

/obj/item/weapon/blacksmith_hammer
	name = "blacksmithing hammer"
	desc = "A sturdy hammer meant to help shape the metals heated in a forge."
	icon = 'icons/obj/blacksmith/blacksmithingx32.dmi'
	icon_state = "hammer"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 9
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=120)

/obj/item/weapon/blacksmith_tongs
	name = "blacksmithing tongs"
	desc = "A sturdy set of tongs meant to help hold hot metal while working."
	icon = 'icons/obj/blacksmith/blacksmithingx32.dmi'
	icon_state = "tongs"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=90)

/*Misc Items + Crafting Parts*/
/obj/item/weapon/reagent_containers/food/drinks/wooden_mug
	name = "wooden mug"
	desc = "A mug for serving hearty brews."
	icon = 'icons/obj/drinks.dmi'
	item_state = "manlydorfglass"
	icon_state = "manlydorfglass"
	spillable = 1


#undef DWARF_COOLDOWN