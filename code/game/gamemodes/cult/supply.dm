//Supply Talisman: Has a few unique effects. Granted only to starter cultists.
/obj/item/weapon/paper/talisman/supply
	cultist_name = "Supply Talisman"
	cultist_desc = "A multi-use talisman that can create various objects. Intended to increase the cult's strength early on."
	invocation = null
	uses = 3
	var/list/possible_summons = list(
		/datum/cult_supply/tome,
		/datum/cult_supply/metal,
		/datum/cult_supply/talisman/teleport,
		/datum/cult_supply/talisman/emp,
		/datum/cult_supply/talisman/stun,
		/datum/cult_supply/talisman/veil,
		/datum/cult_supply/soulstone,
		/datum/cult_supply/construct_shell
	)

/obj/item/weapon/paper/talisman/supply/invoke(mob/living/user, successfuluse = 1)
	var/list/dat = list()
	dat += "<B>There are [uses] bloody runes on the parchment.</B><BR>"
	dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
	dat += "<HR>"
	for(var/s in possible_summons)
		var/datum/cult_supply/S = s
		dat += "<a href='?src=\ref[src];id=[initial(S.id)]'>[initial(S.invocation)]</a> - [initial(S.desc)]<br>"
	var/datum/browser/popup = new(user, "talisman", "", 400, 400)
	popup.set_content(dat.Join(""))
	popup.open()
	return 0

/obj/item/weapon/paper/talisman/supply/Topic(href, href_list)
	if(QDELETED(src) || usr.incapacitated() || !in_range(src, usr))
		return

	var/id = href_list["id"]
	var/datum/cult_supply/match

	for(var/s in possible_summons)
		var/datum/cult_supply/S = s
		if(initial(S.id) == id)
			match = S
			break

	if(!match)
		to_chat(usr, "<span class='userdanger'>The fabric of reality quivers in agony.</span>")
		return

	var/turf/T = get_turf(src)
	var/summon_type = initial(match.summon_type)


	var/atom/movable/AM = new summon_type(T)
	if(istype(AM, /obj/item))
		usr.put_in_hands(AM)

	uses--
	if(uses <= 0)
		to_chat(usr, "<span class='warning'>[src] crumbles to dust.</span>")
		burn()

/obj/item/weapon/paper/talisman/supply/weak
	cultist_name = "Lesser Supply Talisman"
	uses = 2

/obj/item/weapon/paper/talisman/supply/weak/Initialize(mapload)
	. = ..()
	// no runed metal from lesser talismans.
	possible_summons -= /datum/cult_supply/metal

/datum/cult_supply
	var/id = "used_popcorn"
	var/invocation = "Pla'ceho'lder."
	var/desc = "Summons a generic supply item, to aid the cult."
	var/summon_type = /obj/item/trash/popcorn // wait this isn't useful

/datum/cult_supply/tome
	id = "arcane_tome"
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	desc = "Summons an arcane tome, used to scribe runes."
	summon_type = /obj/item/weapon/tome

/datum/cult_supply/metal
	id = "runed_metal"
	invocation = "Bar'tea eas!"
	desc = "Provides 5 runed metal, which can build a variety of cult structures."
	summon_type = /obj/item/stack/sheet/runed_metal/five

/datum/cult_supply/talisman/teleport
	id = "teleport_talisman"
	invocation = "Sas'so c'arta forbici!"
	desc = "Allows you to move to a selected teleportation rune."
	summon_type = /obj/item/weapon/paper/talisman/teleport

/datum/cult_supply/talisman/emp
	id = "emp_talisman"
	invocation = "Ta'gh fara'qha fel d'amar det!"
	desc = "Allows you to destroy technology in a short range."
	summon_type = /obj/item/weapon/paper/talisman/emp

/datum/cult_supply/talisman/stun
	id = "stun_talisman"
	invocation = "Fuu ma'jin!"
	desc = "Allows you to stun a person by attacking them with the talisman. Does not work on people holding a holy weapon!"
	summon_type = /obj/item/weapon/paper/talisman/stun

/datum/cult_supply/talisman/veil
	id = "veil_talisman"
	invocation = "Kla'atu barada nikt'o!"
	desc = "Two use talisman, first use makes all nearby runes invisible, secnd use reveals nearby hidden runes."
	summon_type = /obj/item/weapon/paper/talisman/true_sight

/datum/cult_supply/soulstone
	id = "soulstone"
	invocation = "Kal'om neth!"
	desc = "Summons a soul stone, used to capture the spirits of dead or dying humans."
	summon_type = /obj/item/device/soulstone

/datum/cult_supply/construct_shell
	id = "construct_shell"
	invocation = "Daa'ig osk!"
	desc = "Summons a construct shell for use with soulstone-captured souls. It is too large to carry on your person."
	summon_type = /obj/structure/constructshell

