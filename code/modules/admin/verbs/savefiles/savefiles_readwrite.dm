// In this file:
// * A lot of hacks to make stuff save/load correctly
// * A lot of hacks to keep save files small
// * A lot of hacks to stop server crashes on saving


// Reduces save file size
/atom/movable/Write(var/savefile/F)
	..()
	F.dir.Remove("tag", "suit_fibers", "blood_DNA",
	"fingerprints", "fingerprintshidden", "fingerprintslast")

	if(F["attack_verb"])
		var/list/verbs = F["attack_verb"]
		if(!verbs.len)
			F.dir.Remove("attack_verb")

/mob/Write(var/savefile/F)
	..()
	F.dir.Remove("attack_log", "lastattacker", "lastattacked")


/obj/item/Write(var/savefile/F)
	..()
	if(!armor["melee"] && !armor["bullet"] && !armor["laser"] && !armor["energy"] && !armor["bomb"] && !armor["bio"] && !armor["rad"])
		F.dir.Remove("armor")
	if(!species_exception.len)
		F.dir.Remove("species_exception")
	var/itemlist = list(/obj/structure/table,/obj/structure/rack,/obj/structure/closet,/obj/item/weapon/storage,/obj/structure/safe,/obj/machinery/disposal)
	if(list2params(can_be_placed_into) == list2params(itemlist))
		F.dir.Remove("can_be_placed_into")

/obj/item/Read(var/savefile/F)
	..()
	if(!F["armor"])
		armor = list("melee" = 0,"bullet" = 0,"laser" = 0,"energy" = 0,"bomb" = 0,"bio" = 0,"rad" = 0)
	if(!F["species_exception"])
		species_exception = list()
	if(!F["can_be_placed_into"])
		can_be_placed_into = list(/obj/structure/table,/obj/structure/rack,/obj/structure/closet,/obj/item/weapon/storage,/obj/structure/safe,/obj/machinery/disposal)

/obj/item/weapon/Write(var/savefile/F)
	..()
	if((damtype == "fire" && hitsound == 'sound/items/welder.ogg') || (damtype == "brute" && hitsound == "swing_hit"))
		F.dir.Remove("hitsound")

/obj/item/weapon/stock_parts/cell/Write(var/savefile/F)
	..()
	F.dir.Remove("overlays")



// Reduces save file size and updates icons correctly
/mob/living/carbon/human/Write(var/savefile/F)
	..()
	F.dir.Remove("overlays")

/mob/Read()
	..()
	regenerate_icons()

/mob/living/carbon/human/Read()
	..()
	updateappearance(src)
	domutcheck(src)


// Removes mobs from blood's donor. We do not want to S/L the whole mob from blood syringe
/datum/reagent/blood/Write(var/savefile/F)
	var/donor = data["donor"]
	data["donor"] = null
	..()
	data["donor"] = donor



// Special roles save/load
/datum/mind/Write(var/savefile/F)
	..()
	var/list/roles = list()

	if(src in ticker.mode.changelings)
		roles.Add("changeling")
	if(src in ticker.mode.wizards)
		roles.Add("wizard")
	if(src in ticker.mode.cult)
		roles.Add("cult")
	if(src in ticker.mode.syndicates)
		roles.Add("operative")
	if(src in ticker.mode.head_revolutionaries)
		roles.Add("head_rev")
	if(src in ticker.mode.revolutionaries)
		roles.Add("rev")
	if(src in ticker.mode.traitors)
		roles.Add("traitor")

	if(roles.len)
		F["roles"] << roles

/datum/mind/Read(var/savefile/F)
	..()
	var/list/roles
	F["roles"] >> roles

	if(!roles || !roles.len)
		return

	for(var/role in roles)
		switch(role)
			if("changeling")
				ticker.mode.changelings.Add(src)
			if("wizard")
				ticker.mode.wizards.Add(src)
			if("cult")
				ticker.mode.add_cultist(src)
			if("operative")
				ticker.mode.syndicates.Add(src)
			if("rev")
				ticker.mode.add_revolutionary(src)
			if("head_rev")
				ticker.mode.head_revolutionaries.Add(src)
				ticker.mode.update_rev_icons_added(src)
				ticker.mode.forge_revolutionary_objectives(src)
			if("traitor")
				ticker.mode.traitors.Add(src)


// Stops Login()-related freezes on mob loading
/mob/Read(var/savefile/F)
	var/cilentkey
	F["key"] >> cilentkey
	F.dir.Remove("key")
	..()
	spawn(5)
		key = cilentkey
	F["key"] << cilentkey



// Not save any vars for this items:

// Because grabs are totally /tmp/ objects
/obj/item/weapon/grab/Write(var/savefile/F)
	return

/obj/item/tk_grab/Write(var/savefile/F)
	return

// Because saving 50 boolets can trigger infinite loop check.
// Boolets are respawned on New when magazine is loaded.
/obj/item/ammo_box/magazine/m762/Write(var/savefile/F)
	return