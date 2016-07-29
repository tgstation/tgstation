<<<<<<< HEAD
/datum/spellbook_entry
	var/name = "Entry Name"

	var/spell_type = null
	var/desc = ""
	var/category = "Offensive"
	var/log_name = "XX" //What it shows up as in logs
	var/cost = 2
	var/refundable = 1
	var/surplus = -1 // -1 for infinite, not used by anything atm
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"
	var/limit //used to prevent a spellbook_entry from being bought more than X times with one wizard spellbook

/datum/spellbook_entry/proc/IsAvailible() // For config prefs / gamemode restrictions - these are round applied
	return 1
/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book) // Specific circumstances
	if(book.uses<cost || limit == 0)
		return 0
	return 1
/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book) //return 1 on success
	if(!S || qdeleted(S))
		S = new spell_type()

	//Check if we got the spell already
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name)) // Not using directly in case it was learned from one spellbook then upgraded in another
			if(aspell.spell_level >= aspell.level_max)
				user <<  "<span class='warning'>This spell cannot be improved further.</span>"
				return 0
			else
				aspell.name = initial(aspell.name)
				aspell.spell_level++
				aspell.charge_max = round(initial(aspell.charge_max) - aspell.spell_level * (initial(aspell.charge_max) - aspell.cooldown_min)/ aspell.level_max)
				if(aspell.charge_max < aspell.charge_counter)
					aspell.charge_counter = aspell.charge_max
				switch(aspell.spell_level)
					if(1)
						user << "<span class='notice'>You have improved [aspell.name] into Efficient [aspell.name].</span>"
						aspell.name = "Efficient [aspell.name]"
					if(2)
						user << "<span class='notice'>You have further improved [aspell.name] into Quickened [aspell.name].</span>"
						aspell.name = "Quickened [aspell.name]"
					if(3)
						user << "<span class='notice'>You have further improved [aspell.name] into Free [aspell.name].</span>"
						aspell.name = "Free [aspell.name]"
					if(4)
						user << "<span class='notice'>You have further improved [aspell.name] into Instant [aspell.name].</span>"
						aspell.name = "Instant [aspell.name]"
				if(aspell.spell_level >= aspell.level_max)
					user << "<span class='notice'>This spell cannot be strengthened any further.</span>"
				return 1
	//No same spell found - just learn it
	feedback_add_details("wizard_spell_learned",log_name)
	user.mind.AddSpell(S)
	user << "<span class='notice'>You have learned [S.name].</span>"
	return 1

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	if(!refundable)
		return 0
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return 1
	return 0

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user,obj/item/weapon/spellbook/book) //return point value or -1 for failure
	var/area/wizard_station/A = locate()
	if(!(user in A.contents))
		user << "<span clas=='warning'>You can only refund spells at the wizard lair</span>"
		return -1
	if(!S)
		S = new spell_type()
	var/spell_levels = 0
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			spell_levels = aspell.spell_level
			user.mind.spell_list.Remove(aspell)
			qdel(S)
			return cost * (spell_levels+1)
	return -1
/datum/spellbook_entry/proc/GetInfo()
	if(!S)
		S = new spell_type()
	var/dat =""
	dat += "<b>[initial(S.name)]</b>"
	if(S.charge_type == "recharge")
		dat += " Cooldown:[S.charge_max/10]"
	dat += " Cost:[cost]<br>"
	dat += "<i>[S.desc][desc]</i><br>"
	dat += "[S.clothes_req?"Needs wizard garb":"Can be cast without wizard garb"]<br>"
	return dat

/datum/spellbook_entry/fireball
	name = "Fireball"
	spell_type = /obj/effect/proc_holder/spell/fireball
	log_name = "FB"

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	log_name = "MM"
	category = "Defensive"

/datum/spellbook_entry/disintegrate
	name = "Disintegrate"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/disintegrate
	log_name = "DG"

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	spell_type = /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	log_name = "DT"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	log_name = "RP"
	category = "Defensive"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop
	log_name = "TS"
	category = "Defensive"

/datum/spellbook_entry/smoke
	name = "Smoke"
	spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	log_name = "SM"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blind
	name = "Blind"
	spell_type = /obj/effect/proc_holder/spell/targeted/trigger/blind
	log_name = "BD"
	cost = 1

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	spell_type = /obj/effect/proc_holder/spell/targeted/mind_transfer
	log_name = "MT"
	category = "Mobility"

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall
	log_name = "FW"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	log_name = "BL"
	category = "Mobility"

/datum/spellbook_entry/teleport
	name = "Teleport"
	spell_type = /obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	log_name = "TP"
	category = "Mobility"

/datum/spellbook_entry/mutate
	name = "Mutate"
	spell_type = /obj/effect/proc_holder/spell/targeted/genetic/mutate
	log_name = "MU"

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	spell_type = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	log_name = "EJ"
	category = "Mobility"

/datum/spellbook_entry/knock
	name = "Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock
	log_name = "KN"
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone
	log_name = "FS"

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	spell_type = /obj/effect/proc_holder/spell/targeted/summonitem
	log_name = "IS"
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	spell_type = /obj/effect/proc_holder/spell/targeted/lichdom
	log_name = "LD"
	category = "Defensive"

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	spell_type = /obj/effect/proc_holder/spell/targeted/lightning
	log_name = "LB"

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	spell_type = /obj/effect/proc_holder/spell/targeted/infinite_guns
	log_name = "IG"
	cost = 3

/datum/spellbook_entry/barnyard
	name = "Barnyard Curse"
	spell_type = /obj/effect/proc_holder/spell/targeted/barnyardcurse
	log_name = "BC"

/datum/spellbook_entry/charge
	name = "Charge"
	spell_type = /obj/effect/proc_holder/spell/targeted/charge
	log_name = "CH"
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/shapeshift
	name = "Wild Shapeshift"
	spell_type = /obj/effect/proc_holder/spell/targeted/shapeshift
	log_name = "WS"
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	spell_type = /obj/effect/proc_holder/spell/spacetime_dist
	log_name = "STD"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item
	name = "Buy Item"
	refundable = 0
	buy_word = "Summon"
	var/item_path= null


/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	new item_path(get_turf(user))
	feedback_add_details("wizard_spell_learned",log_name)
	return 1

/datum/spellbook_entry/item/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	dat += " Cost:[cost]<br>"
	dat += "<i>[desc]</i><br>"
	if(surplus>=0)
		dat += "[surplus] left.<br>"
	return dat

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	item_path = /obj/item/weapon/gun/magic/staff/change
	log_name = "ST"

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	item_path = /obj/item/weapon/gun/magic/staff/animate
	log_name = "SA"
	category = "Assistance"

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "A caprious tool that can fire all sorts of magic without any rhyme or reason. Using it on people you care about is not recommended."
	item_path = /obj/item/weapon/gun/magic/staff/chaos
	log_name = "SC"

/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid metal into ornate doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/weapon/gun/magic/staff/door
	log_name = "SD"
	cost = 1
	category = "Mobility"

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "An altruistic staff that can heal the lame and raise the dead."
	item_path = /obj/item/weapon/gun/magic/staff/healing
	log_name = "SH"
	cost = 1
	category = "Defensive"

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy, using it will allow you to ghost while alive, allowing you to spy upon the station with ease. In addition, buying it will permanently grant you x-ray vision."
	item_path = /obj/item/weapon/scrying
	log_name = "SO"
	category = "Defensive"

/datum/spellbook_entry/item/scryingorb/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	if(..())
		if (!(user.dna.check_mutation(XRAY)))
			user.dna.add_mutation(XRAY)
	return 1

/datum/spellbook_entry/item/soulstones
	name = "Six Soul Stone Shards and the spell Artificer"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/weapon/storage/belt/soulstone/full
	log_name = "SS"
	category = "Assistance"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	. =..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(null))
	return .

/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as skeletal thralls for you to command."
	item_path = /obj/item/device/necromantic_stone
	log_name = "NS"
	category = "Assistance"

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "A collection of wands that allow for a wide variety of utility. Wands have a limited number of charges, so be conservative in use. Comes in a handy belt."
	item_path = /obj/item/weapon/storage/belt/wands/full
	log_name = "WA"
	category = "Defensive"

/datum/spellbook_entry/item/armor
	name = "Mastercrafted Armor Set"
	desc = "An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space."
	item_path = /obj/item/clothing/suit/space/hardsuit/wizard
	log_name = "HS"
	category = "Defensive"

/datum/spellbook_entry/item/armor/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	. = ..()
	if(.)
		new /obj/item/clothing/shoes/sandal(get_turf(user)) //In case they've lost them.
		new /obj/item/clothing/gloves/color/purple(get_turf(user))//To complete the outfit

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/weapon/antag_spawner/contract
	log_name = "CT"
	category = "Assistance"

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "A bottle of magically infused blood, the smell of which will attract extradimensional beings when broken. Be careful though, the kinds of creatures summoned by blood magic are indiscriminate in their killing, and you yourself may become a victim."
	item_path = /obj/item/weapon/antag_spawner/slaughter_demon
	log_name = "BB"
	limit = 3
	category = "Assistance"

/datum/spellbook_entry/item/hugbottle
	name = "Bottle of Tickles"
	desc = "A bottle of magically infused fun, the smell of which will \
		attract adorable extradimensional beings when broken. These beings \
		are similar to slaughter demons, but they do not permamently kill \
		their victims, instead putting them in an extradimensional hugspace, \
		to be released on the demon's death. Chaotic, but not ultimately \
		damaging. The crew's reaction to the other hand could be very \
		destructive."
	item_path = /obj/item/weapon/antag_spawner/slaughter_demon/laughter
	cost = 1 //non-destructive; it's just a jape, sibling!
	log_name = "HB"
	limit = 3
	category = "Assistance"

/datum/spellbook_entry/item/hadesstone
	name = "Dark Seed"
	desc = "A small, dark stone that whispers to you menacingly.\
			The seed calls for the corpses of living beings,\
			in order to summon an ancient, powerful being.\
			The power and tenacity of the summoned being directly\
			correlates to the power of the absorbed beings,\
			so choose your targets wisely."
	item_path = /obj/item/hades_summoner
	cost = 2
	log_name = "DS"
	limit = 1
	category = "Assistance"

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "A mighty hammer on loan from Thor, God of Thunder. It crackles with barely contained power."
	item_path = /obj/item/weapon/twohanded/mjollnir
	log_name = "MJ"

/datum/spellbook_entry/item/singularity_hammer
	name = "Singularity Hammer"
	desc = "A hammer that creates an intensely powerful field of gravity where it strikes, pulling everthing nearby to the point of impact."
	item_path = /obj/item/weapon/twohanded/singularityhammer
	log_name = "SI"

/datum/spellbook_entry/item/cursed_heart
	name = "Cursed Heart"
	desc = "A heart that has been revived by dark magicks, the user must \
	concentrate to ensure the heart beats, but every beat heals them. It \
	must beat every 6 seconds. The heart is fickle, and will not work for a \
	lich."
	item_path = /obj/item/organ/heart/cursed/wizard
	log_name = "CH"
	cost = 1
	category = "Defensive"

/datum/spellbook_entry/summon
	name = "Summon Stuff"
	category = "Rituals"
	refundable = 0
	buy_word = "Cast"
	var/active = 0

/datum/spellbook_entry/summon/CanBuy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	return ..() && !active

/datum/spellbook_entry/summon/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	if(cost>0)
		dat += " Cost:[cost]<br>"
	else
		dat += " No Cost<br>"
	dat += "<i>[desc]</i><br>"
	if(active)
		dat += "<b>Already cast!</b><br>"
	return dat

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	category = "Rituals"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. Just be careful not to stand still too long!"
	log_name = "SG"

/datum/spellbook_entry/summon/guns/IsAvailible()
	if(!ticker.mode) // In case spellbook is placed on map
		return 0
	return (ticker.mode.name != "ragin' mages" && !config.no_summon_guns)

/datum/spellbook_entry/summon/guns/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	feedback_add_details("wizard_spell_learned",log_name)
	rightandwrong(0, user, 25)
	playsound(get_turf(user),"sound/magic/CastSummon.ogg",50,1)
	user << "<span class='notice'>You have cast summon guns!</span>"
	return 1

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	category = "Challenges"
	desc = "Share the wonders of magic with the crew and show them why they aren't to be trusted with it at the same time."
	cost = 0
	log_name = "SU"

/datum/spellbook_entry/summon/magic/IsAvailible()
	if(!ticker.mode) // In case spellbook is placed on map
		return 0
	return (ticker.mode.name != "ragin' mages" && !config.no_summon_magic)

/datum/spellbook_entry/summon/magic/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	feedback_add_details("wizard_spell_learned",log_name)
	rightandwrong(1, user, 0)
	book.uses += 1
	active = 1
	playsound(get_turf(user),"sound/magic/CastSummon.ogg",50,1)
	user << "<span class='notice'>You have cast summon magic and gained an extra charge for your spellbook.</span>"
	return 1

/datum/spellbook_entry/summon/events
	name = "Summon Events"
	desc = "Give Murphy's law a little push and replace all events with special wizard ones that will confound and confuse everyone. Multiple castings increase the rate of these events."
	cost = 2
	log_name = "SE"
	var/times = 0

/datum/spellbook_entry/summon/events/IsAvailible()
	if(!ticker.mode) // In case spellbook is placed on map
		return 0
	return (ticker.mode.name != "ragin' mages" && !config.no_summon_events)

/datum/spellbook_entry/summon/events/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	feedback_add_details("wizard_spell_learned",log_name)
	summonevents()
	times++
	playsound(get_turf(user),"sound/magic/CastSummon.ogg",50,1)
	user << "<span class='notice'>You have cast summon events.</span>"
	return 1

/datum/spellbook_entry/summon/events/GetInfo()
	. = ..()
	if(times>0)
		. += "You cast it [times] times.<br>"
	return .

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "An unearthly tome that glows with power."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = 1
	var/uses = 10
	var/temp = null
	var/op = 1
	var/tab = null
	var/mob/living/carbon/human/owner
	var/list/datum/spellbook_entry/entries = list()
	var/list/categories = list()

/obj/item/weapon/spellbook/examine(mob/user)
	..()
	if(owner)
		user << "There is a small signature on the front cover: \"[owner]\"."
	else
		user << "It appears to have no author."

/obj/item/weapon/spellbook/proc/Initialize()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon
	for(var/T in entry_types)
		var/datum/spellbook_entry/E = new T
		if(E.IsAvailible())
			entries |= E
			categories |= E.category
		else
			qdel(E)
	tab = categories[1]

/obj/item/weapon/spellbook/New()
	..()
	Initialize()


/obj/item/weapon/spellbook/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/antag_spawner/contract))
		var/obj/item/weapon/antag_spawner/contract/contract = O
		if(contract.used)
			user << "<span class='warning'>The contract has been used, you can't get your points back now!</span>"
		else
			user << "<span class='notice'>You feed the contract back into the spellbook, refunding your points.</span>"
			uses++
			for(var/datum/spellbook_entry/item/contract/CT in entries)
				if(!isnull(CT.limit))
					CT.limit++
			qdel(O)
	else if(istype(O, /obj/item/weapon/antag_spawner/slaughter_demon))
		user << "<span class='notice'>On second thought, maybe summoning a demon is a bad idea. You refund your points.</span>"
		uses++
		for(var/datum/spellbook_entry/item/bloodbottle/BB in entries)
			if(!isnull(BB.limit))
				BB.limit++
		qdel(O)

/obj/item/weapon/spellbook/proc/GetCategoryHeader(category)
	var/dat = ""
	switch(category)
		if("Offensive")
			dat += "Spells and items geared towards debilitating and destroying.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Defensive")
			dat += "Spells and items geared towards improving your survivabilty or reducing foes ability to attack.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Mobility")
			dat += "Spells and items geared towards improving your ability to move. It is a good idea to take at least one.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Assistance")
			dat += "Spells and items geared towards bringing in outside forces to aid you or improving upon your other items and abilties.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Challenges")
			dat += "The Wizard Federation typically has hard limits on the potency and number of spells brought to the station based on risk.<BR>"
			dat += "Arming the station against you will increases the risk, but will grant you one more charge for your spellbook.<BR>"
		if("Rituals")
			dat += "These powerful spells change the very fabric of reality. Not always in your favour.<BR>"
	return dat

/obj/item/weapon/spellbook/proc/wrap(content)
	var/dat = ""
	dat +="<html><head><title>Spellbook</title></head>"
	dat += {"
	<head>
		<style type="text/css">
      		body { font-size: 80%; font-family: 'Lucida Grande', Verdana, Arial, Sans-Serif; }
      		ul#tabs { list-style-type: none; margin: 30px 0 0 0; padding: 0 0 0.3em 0; }
      		ul#tabs li { display: inline; }
      		ul#tabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; border-bottom: none; padding: 0.3em; text-decoration: none; }
      		ul#tabs li a:hover { background-color: #f1f0ee; }
      		ul#tabs li a.selected { color: #000; background-color: #f1f0ee; font-weight: bold; padding: 0.7em 0.3em 0.38em 0.3em; }
      		div.tabContent { border: 1px solid #c9c3ba; padding: 0.5em; background-color: #f1f0ee; }
      		div.tabContent.hide { display: none; }
    	</style>
  	</head>
	"}
	dat += {"[content]</body></html>"}
	return dat

/obj/item/weapon/spellbook/attack_self(mob/user)
	if(!owner)
		user << "<span class='notice'>You bind the spellbook to yourself.</span>"
		owner = user
		return
	if(user != owner)
		user << "<span class='warning'>The [name] does not recognize you as it's owner and refuses to open!</span>"
		return
	user.set_machine(src)
	var/dat = ""

	dat += "<ul id=\"tabs\">"
	var/list/cat_dat = list()
	for(var/category in categories)
		cat_dat[category] = "<hr>"
		dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=\ref[src];page=[category]'>[category]</a></li>"

	dat += "<li><a><b>Points remaining : [uses]</b></a></li>"
	dat += "</ul>"

	var/datum/spellbook_entry/E
	for(var/i=1,i<=entries.len,i++)
		var/spell_info = ""
		E = entries[i]
		spell_info += E.GetInfo()
		if(E.CanBuy(user,src))
			spell_info+= "<a href='byond://?src=\ref[src];buy=[i]'>[E.buy_word]</A><br>"
		else
			spell_info+= "<span>Can't [E.buy_word]</span><br>"
		if(E.CanRefund(user,src))
			spell_info+= "<a href='byond://?src=\ref[src];refund=[i]'>Refund</A><br>"
		spell_info += "<hr>"
		if(cat_dat[E.category])
			cat_dat[E.category] += spell_info

	for(var/category in categories)
		dat += "<div class=\"[tab==category?"tabContent":"tabContent hide"]\" id=\"[category]\">"
		dat += GetCategoryHeader(category)
		dat += cat_dat[category]
		dat += "</div>"

	user << browse(wrap(dat), "window=spellbook;size=700x500")
	onclose(user, "spellbook")
	return

/obj/item/weapon/spellbook/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return
	if(!istype(H, /mob/living/carbon/human))
		return 1

	if(H.mind.special_role == "apprentice")
		temp = "If you got caught sneaking a peak from your teacher's spellbook, you'd likely be expelled from the Wizard Academy. Better not."
		return

	var/datum/spellbook_entry/E = null
	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["buy"])
			E = entries[text2num(href_list["buy"])]
			if(E && E.CanBuy(H,src))
				if(E.Buy(H,src))
					if(E.limit)
						E.limit--
					uses -= E.cost
		else if(href_list["refund"])
			E = entries[text2num(href_list["refund"])]
			if(E && E.refundable)
				var/result = E.Refund(H,src)
				if(result > 0)
					if(!isnull(E.limit))
						E.limit += result
					uses += result
		else if(href_list["page"])
			tab = sanitize(href_list["page"])
	attack_self(H)
	return

//Single Use Spellbooks//

/obj/item/weapon/spellbook/oneuse
	var/spell = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile //just a placeholder to avoid runtimes if someone spawned the generic
	var/spellname = "sandbox"
	var/used = 0
	name = "spellbook of "
	uses = 1
	desc = "This template spellbook was never meant for the eyes of man..."

/obj/item/weapon/spellbook/oneuse/New()
	..()
	name += spellname

/obj/item/weapon/spellbook/oneuse/Initialize() //No need to init
	return

/obj/item/weapon/spellbook/oneuse/attack_self(mob/user)
	var/obj/effect/proc_holder/spell/S = new spell
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				if(user.mind.special_role == "apprentice" || user.mind.special_role == "Wizard")
					user <<"<span class='notice'>You're already far more versed in this spell than this flimsy how-to book can provide.</span>"
				else
					user <<"<span class='notice'>You've already read this one.</span>"
			return
	if(used)
		recoil(user)
	else
		user.mind.AddSpell(S)
		user <<"<span class='notice'>you rapidly read through the arcane book. Suddenly you realize you understand [spellname]!</span>"
		user.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.real_name] ([user.ckey]) learned the spell [spellname] ([S]).</font>")
		onlearned(user)

/obj/item/weapon/spellbook/oneuse/proc/recoil(mob/user)
	user.visible_message("<span class='warning'>[src] glows in a black light!</span>")

/obj/item/weapon/spellbook/oneuse/proc/onlearned(mob/user)
	used = 1
	user.visible_message("<span class='caution'>[src] glows dark for a second!</span>")

/obj/item/weapon/spellbook/oneuse/attackby()
	return

/obj/item/weapon/spellbook/oneuse/fireball
	spell = /obj/effect/proc_holder/spell/fireball
	spellname = "fireball"
	icon_state ="bookfireball"
	desc = "This book feels warm to the touch."

/obj/item/weapon/spellbook/oneuse/fireball/recoil(mob/user)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
	qdel(src)

/obj/item/weapon/spellbook/oneuse/smoke
	spell = /obj/effect/proc_holder/spell/targeted/smoke
	spellname = "smoke"
	icon_state ="booksmoke"
	desc = "This book is overflowing with the dank arts."

/obj/item/weapon/spellbook/oneuse/smoke/recoil(mob/user)
	..()
	user <<"<span class='caution'>Your stomach rumbles...</span>"
	if(user.nutrition)
		user.nutrition -= 200
		if(user.nutrition <= 0)
			user.nutrition = 0

/obj/item/weapon/spellbook/oneuse/blind
	spell = /obj/effect/proc_holder/spell/targeted/trigger/blind
	spellname = "blind"
	icon_state ="bookblind"
	desc = "This book looks blurry, no matter how you look at it."

/obj/item/weapon/spellbook/oneuse/blind/recoil(mob/user)
	..()
	user <<"<span class='warning'>You go blind!</span>"
	user.blind_eyes(10)

/obj/item/weapon/spellbook/oneuse/mindswap
	spell = /obj/effect/proc_holder/spell/targeted/mind_transfer
	spellname = "mindswap"
	icon_state ="bookmindswap"
	desc = "This book's cover is pristine, though its pages look ragged and torn."
	var/mob/stored_swap = null //Used in used book recoils to store an identity for mindswaps

/obj/item/weapon/spellbook/oneuse/mindswap/onlearned()
	spellname = pick("fireball","smoke","blind","forcewall","knock","barnyard","charge")
	icon_state = "book[spellname]"
	name = "spellbook of [spellname]" //Note, desc doesn't change by design
	..()

/obj/item/weapon/spellbook/oneuse/mindswap/recoil(mob/user)
	..()
	if(stored_swap in dead_mob_list)
		stored_swap = null
	if(!stored_swap)
		stored_swap = user
		user <<"<span class='warning'>For a moment you feel like you don't even know who you are anymore.</span>"
		return
	if(stored_swap == user)
		user <<"<span class='notice'>You stare at the book some more, but there doesn't seem to be anything else to learn...</span>"
		return

	var/obj/effect/proc_holder/spell/targeted/mind_transfer/swapper = new
	swapper.cast(user, stored_swap, 1)

	stored_swap <<"<span class='warning'>You're suddenly somewhere else... and someone else?!</span>"
	user <<"<span class='warning'>Suddenly you're staring at [src] again... where are you, who are you?!</span>"
	stored_swap = null

/obj/item/weapon/spellbook/oneuse/forcewall
	spell = /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall
	spellname = "forcewall"
	icon_state ="bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."

/obj/item/weapon/spellbook/oneuse/forcewall/recoil(mob/user)
	..()
	user <<"<span class='warning'>You suddenly feel very solid!</span>"
	var/obj/structure/closet/statue/S = new /obj/structure/closet/statue(user.loc, user)
	S.timer = 30
	user.drop_item()


/obj/item/weapon/spellbook/oneuse/knock
	spell = /obj/effect/proc_holder/spell/aoe_turf/knock
	spellname = "knock"
	icon_state ="bookknock"
	desc = "This book is hard to hold closed properly."

/obj/item/weapon/spellbook/oneuse/knock/recoil(mob/user)
	..()
	user <<"<span class='warning'>You're knocked down!</span>"
	user.Weaken(20)

/obj/item/weapon/spellbook/oneuse/barnyard
	spell = /obj/effect/proc_holder/spell/targeted/barnyardcurse
	spellname = "barnyard"
	icon_state ="bookhorses"
	desc = "This book is more horse than your mind has room for."

/obj/item/weapon/spellbook/oneuse/barnyard/recoil(mob/living/carbon/user)
	if(istype(user, /mob/living/carbon/human))
		user <<"<font size='15' color='red'><b>HOR-SIE HAS RISEN</b></font>"
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.flags |= NODROP		//curses!
		magichead.flags_inv &= ~HIDEFACE //so you can still see their face
		magichead.voicechange = 1	//NEEEEIIGHH
		if(!user.unEquip(user.wear_mask))
			qdel(user.wear_mask)
		user.equip_to_slot_if_possible(magichead, slot_wear_mask, 1, 1)
		qdel(src)
	else
		user <<"<span class='notice'>I say thee neigh</span>" //It still lives here

/obj/item/weapon/spellbook/oneuse/charge
	spell = /obj/effect/proc_holder/spell/targeted/charge
	spellname = "charging"
	icon_state ="bookcharge"
	desc = "This book is made of 100% post-consumer wizard."

/obj/item/weapon/spellbook/oneuse/charge/recoil(mob/user)
	..()
	user <<"<span class='warning'>[src] suddenly feels very warm!</span>"
	empulse(src, 1, 1)

/obj/item/weapon/spellbook/oneuse/summonitem
	spell = /obj/effect/proc_holder/spell/targeted/summonitem
	spellname = "instant summons"
	icon_state ="booksummons"
	desc = "This book is bright and garish, very hard to miss."

/obj/item/weapon/spellbook/oneuse/summonitem/recoil(mob/user)
	..()
	user <<"<span class='warning'>[src] suddenly vanishes!</span>"
	qdel(src)

/obj/item/weapon/spellbook/oneuse/random/New()
	var/real_type = pick(subtypesof(/obj/item/weapon/spellbook/oneuse))
	new real_type(loc)
	qdel(src)
=======
/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state ="spellbook"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	flags = FPRINT
	var/uses = 5
	var/temp = null
	var/max_uses = 5
	var/op = 1

/obj/item/weapon/spellbook/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/antag_spawner/contract))
		var/obj/item/weapon/antag_spawner/contract/contract = O
		if(contract.used)
			to_chat(user, "The contract has been used, you can't get your points back now.")
		else
			to_chat(user, "You feed the contract back into the spellbook, refunding your points.")
			src.max_uses++
			src.uses++
			qdel (O)
			O = null

/obj/item/weapon/spellbook/attack_self(mob/user = usr)
	if(!user)
		return
	user.set_machine(src)
	var/dat
	if(temp)
		dat = "[temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else

		dat = {"<B>The Book of Spells:</B><BR>
			Spells left to memorize: [uses]<BR>
			<HR>
			<B>Memorize which spell:</B><BR>
			<I>The number after the spell name is the cooldown time.</I><BR>
			[(Holiday == "Christmas" && universe.name == "Normal") ? "<A href='byond://?src=\ref[src];spell_choice=becomesanta'>Become Santa Claus</A> (One time use, uses three points, global spell)<BR><I>Guess which station's on the naughty list?</I><BR>" : ""]
			<A href='byond://?src=\ref[src];spell_choice=magicmissile'>Magic Missile</A> (10)<BR>
			<I>This spell fires several, slow moving, magic projectiles at nearby targets. If they hit a target, it is paralyzed and takes minor damage.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=fireball'>Fireball</A> (10)<BR>
			<I>This spell fires a fireball in the direction you're facing and does not require wizard garb. Be careful not to fire it at people that are standing next to you.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=lightning'>Lightning</A> (20)<BR>
			<I>Become Zeus and throw lightning at your foes, once you've charged the spell focus it upon any being to unleash electric fury. Upgrading this will cause your lightning to arc.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=disabletech'>Disable Technology</A> (60)<BR>
			<I>This spell disables all weapons, cameras and most other technology in range.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=smoke'>Smoke</A> (10)<BR>
			<I>This spell spawns a cloud of choking smoke at your location and does not require wizard garb.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=blind'>Blind</A> (30)<BR>
			<I>This spell temporarly blinds a single person and does not require wizard garb.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=subjugation'>Subjugation</A> (30)<BR>
			<I>This spell temporarily subjugates a target's mind and does not require wizard garb.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=mindswap'>Mind Transfer</A> (60)<BR>
			<I>This spell allows the user to switch bodies with a target. Careful to not lose your memory in the process.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=forcewall'>Forcewall</A> (10)<BR>
			<I>This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=blink'>Blink</A> (2)<BR>
			<I>This spell randomly teleports you a short distance. Useful for evasion or getting into areas if you have patience.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=teleport'>Teleport</A> (60)<BR>
			<I>This spell teleports you to a type of area of your selection. Very useful if you are in danger, but has a decent cooldown, and is unpredictable.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=mutate'>Mutate</A> (60)<BR>
			<I>This spell causes you to turn into a hulk and gain telekinesis for a short while.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=etherealjaunt'>Ethereal Jaunt</A> (60)<BR>
			<I>This spell creates your ethereal form, temporarily making you invisible and able to pass through walls.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=timestop'>Time Stop</A> (90)<BR>
			<I>Stop the flow of time for all beings but yourself in a large radius.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=knock'>Knock</A> (10)<BR>
			<I>This spell opens nearby doors and does not require wizard garb.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=horseman'>Curse of the Horseman</A> (15)<BR>
			<I>This spell will curse a person to wear an unremovable horse mask (it has glue on the inside) and speak like a horse. It does not require wizard garb.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=frenchcurse'>The French Curse</A> (30)<BR>
			<I>This spell silences sombody adjacent to you, and curses them with an unremovable Mime costume. It does not require robes to cast.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=clowncurse'>The Clown Curse</A> (30)<BR>
			<I>This spell turns an adjacent target into a miserable clown. This spell does not require robes to cast.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=shoesnatch'>Shoe Snatching Charm</A> (15)<BR>
			<I>This spell will remove your victim's shoes and materialize them in your hands. This spell does not require robes to cast.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=robesummon'>Summon Robes</A> (50)<BR>
			<I>This spell will allow you to summon a new set of robes. Useful for stealthy wizards. This spell (quite obviously) does not require robes to cast.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=fleshtostone'>Flesh to Stone</A> (60)<BR>
			<I>This spell will curse a person to immediately turn into an unmoving statue. The effect will eventually wear off if the statue is not destroyed.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=arsenath'>Butt-Bot's Revenge</A> (50)<BR>
			<I>Summon the power of the butt gods to remove the anus of your enemy.</I><BR>
			[!ticker.mode.rage ? "<A href='byond://?src=\ref[src];spell_choice=summonguns'>Summon Guns</A> (One time use, global spell)<BR><I>Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill eachother. Just be careful not to get hit in the crossfire!</I><BR>" : ""]
			<A href='byond://?src=\ref[src];spell_choice=chariot'>Summon Chariot</A> (1/1)<BR>
			<I>Summon the most badass ride in all of wizardry.</I><BR>
			<A href='byond://?src=\ref[src];spell_choice=noclothes'>Remove Clothes Requirement</A> <b>Warning: this takes away 2 spell choices.</b><BR>
			<HR>
			<B>Artefacts:</B><BR>
			Powerful items imbued with eldritch magics. Summoning one will count towards your maximum number of spells.<BR>
			It is recommended that only experienced wizards attempt to wield such artefacts.<BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=staffchange'>Staff of Change</A><BR>
			<I>An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself.</I><BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=mentalfocus'>Mental Focus</A><BR>
			<I>An artefact that channels the will of the user into destructive bolts of force.</I><BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=soulstone'>Six Soul Stone Shards and the spell Artificer</A><BR>
			<I>Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot.</I><BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=armor'>Mastercrafted Armor Set</A><BR>
			<I>An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space.</I><BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=staffanimation'>Staff of Animation</A><BR>
			<I>An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines.</I><BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=staffnecro'>Staff of Necromancy</A><BR>
			<I>An arcane staff capable of summoning undying minions from the corpses of your enemies. This magic doesn't affect machines.</I><BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=contract'>Contract of Apprenticeship</A><BR>
			<I>A magical contract binding an apprentice wizard to your service, using it will summon them to your side.</I><BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=bundle'>Spellbook Bundle</A><BR>
			<I>Feeling adventurous? Buy this bundle and recieve seven random spellbooks! Who knows what spells you will get? (Warning, each spell book may only be used once! No refunds).</I><BR>
			<HR>
			<A href='byond://?src=\ref[src];spell_choice=scrying'>Scrying Orb</A><BR>
			<I>An incandescent orb of crackling energy, using it will allow you to ghost while alive, allowing you to spy upon the station with ease. In addition, buying it will permanently grant you x-ray vision.</I><BR>
			<HR>"}
		if(op)
			dat += "<A href='byond://?src=\ref[src];spell_choice=rememorize'>Re-memorize Spells</A><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/spellbook/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return
	if(!istype(H, /mob/living/carbon/human))
		return 1

	if(H.mind.special_role == "apprentice")
		temp = "If you got caught sneaking a peak from your teacher's spellbook, you'd likely be expelled from the Wizard Academy. Better not."
		return

	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["spell_choice"])
			if(href_list["spell_choice"] == "rememorize")
				var/area/wizard_station/A = locate()
				if(usr in A.contents)
					uses = max_uses
					H.spellremove(usr)
					temp = "All spells have been removed. You may now memorize a new set of spells."
					feedback_add_details("wizard_spell_learned","UM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
				else
					temp = "You may only re-memorize spells whilst located inside the wizard sanctuary."
			else if(uses >= 1 && max_uses >=1)
				if(href_list["spell_choice"] == "noclothes")
					if(uses < 2)
						return
				if(href_list["spell_choice"] == "bundle")
					if(uses < 5)
						return
				uses--

				var/list/available_spells = list(magicmissile = "Magic Missile", fireball = "Fireball", lightning = "Lightning", disintegrate = "Disintegrate", disabletech = "Disable Tech",
				smoke = "Smoke", blind = "Blind", subjugation = "Subjugation", mindswap = "Mind Transfer", forcewall = "Forcewall", blink = "Blink", teleport = "Teleport", mutate = "Mutate",
				etherealjaunt = "Ethereal Jaunt", knock = "Knock", horseman = "Curse of the Horseman", frenchcurse = "The French Curse", summonguns = "Summon Guns", staffchange = "Staff of Change",
				mentalfocus = "Mental Focus", soulstone = "Six Soul Stone Shards and the spell Artificer", armor = "Mastercrafted Armor Set", staffanimate = "Staff of Animation", noclothes = "No Clothes",
				fleshtostone = "Flesh to Stone", arsenath = "Butt-Bot's Revenge", timestop = "Time Stop", bundle = "Spellbook Bundle")
				var/already_knows = 0
				for(var/spell/aspell in H.spell_list)
					if(available_spells[href_list["spell_choice"]] == initial(aspell.name))
						already_knows = 1
						if(!aspell.can_improve())
							temp = "This spell cannot be improved further."
							uses++
							break
						else
							if(aspell.can_improve("speed") && aspell.can_improve("power"))
								var/choice = alert(usr, "Do you want to upgrade this spell's speed or power?", "Select Upgrade", "Speed", "Power", "Cancel")
								switch(choice)
									if("Speed")
										temp = aspell.quicken_spell()
									if("Power")
										temp = aspell.empower_spell()
									else
										uses++
										break
							else if (aspell.can_improve("speed"))
								temp = aspell.quicken_spell()
							else if (aspell.can_improve("power"))
								temp = aspell.empower_spell()
			/*
			*/
				if(!already_knows)
					switch(href_list["spell_choice"])
						if("becomesanta")
							var/obj/item/clothing/santahat = new /obj/item/clothing/head/helmet/space/santahat
							santahat.canremove = 0
							var/obj/item/clothing/santasuit = new /obj/item/clothing/suit/space/santa
							santasuit.canremove = 0
							var/obj/item/weapon/storage/backpack/santabag = new /obj/item/weapon/storage/backpack/santabag
							santabag.canremove = 0
							to_chat(world,'sound/misc/santa.ogg')
							SetUniversalState(/datum/universal_state/christmas)
							if(H.head)
								H.drop_from_inventory(H.head)
							H.equip_to_slot(santahat,slot_head)
							if(H.back)
								H.drop_from_inventory(H.back)
							if(H.wear_suit)
								H.drop_from_inventory(H.wear_suit)
							H.equip_to_slot(santabag,slot_back)
							H.equip_to_slot(santasuit,slot_wear_suit)
							H.real_name = pick("Santa Claus","Jolly St. Nick","Sandy Claws","Sinterklaas","Father Christmas","Kris Kringle")
							H.nutrition += 1000
							temp = "Let's come to town."
							uses -= 2
							add_spell(new/spell/noclothes,H)
							add_spell(new/spell/aoe_turf/conjure/snowmobile,H)
							add_spell(new/spell/targeted/wrapping_paper,H)
							add_spell(new/spell/aoe_turf/conjure/gingerbreadman,H)
							add_spell(new/spell/targeted/flesh_to_coal,H)
						if("noclothes")
							feedback_add_details("wizard_spell_learned","NC")
							add_spell(new/spell/noclothes,H)
							temp = "This teaches you how to use your spells without your magical garb, truely you are the wizardest."
							uses--
						if("magicmissile")
							feedback_add_details("wizard_spell_learned","MM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/projectile/magic_missile,H)
							temp = "You have learned magic missile."
						if("fireball")
							feedback_add_details("wizard_spell_learned","FB") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/projectile/dumbfire/fireball,H)
							temp = "You have learned fireball."
						if("lightning")
							feedback_add_details("wizard_spell_learned","LS")
							add_spell(new/spell/lightning,H)
							temp = "You have learned lightning."
						if("timestop")
							feedback_add_details("wizard_spell_learned","MS")
							add_spell(new/spell/aoe_turf/fall,H)
							temp = "You have learned time stop."
						/*if("disintegrate")
							if(!ticker.mode.rage)
								feedback_add_details("wizard_spell_learned","DG") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
								add_spell(new/spell/targeted/disintegrate,H)
								temp = "You have learned disintegrate."
						*/
						if("disabletech")
							feedback_add_details("wizard_spell_learned","DT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/aoe_turf/disable_tech,H)
							temp = "You have learned disable technology."
						if("smoke")
							feedback_add_details("wizard_spell_learned","SM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/aoe_turf/smoke,H)
							temp = "You have learned smoke."
						if("blind")
							feedback_add_details("wizard_spell_learned","BD") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/genetic/blind,H)
							temp = "You have learned blind."
						if("subjugation")
							feedback_add_details("wizard_spell_learned","SJ") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/subjugation,H)
							temp = "You have learned subjugate."
						if("mindswap")
							feedback_add_details("wizard_spell_learned","MT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/mind_transfer,H)
							temp = "You have learned mindswap."
						if("forcewall")
							feedback_add_details("wizard_spell_learned","FW") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/aoe_turf/conjure/forcewall,H)
							temp = "You have learned forcewall."
						if("blink")
							feedback_add_details("wizard_spell_learned","BL") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/aoe_turf/blink,H)
							temp = "You have learned blink."
						if("teleport")
							feedback_add_details("wizard_spell_learned","TP") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/area_teleport,H)
							temp = "You have learned teleport."
						if("mutate")
							feedback_add_details("wizard_spell_learned","MU") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/genetic/mutate,H)
							temp = "You have learned mutate."
						if("etherealjaunt")
							feedback_add_details("wizard_spell_learned","EJ") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/ethereal_jaunt,H)
							temp = "You have learned ethereal jaunt."
						if("knock")
							feedback_add_details("wizard_spell_learned","KN") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/aoe_turf/knock,H)
							temp = "You have learned knock."
						if("horseman")
							feedback_add_details("wizard_spell_learned","HH") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/equip_item/horsemask,H)
							temp = "You have learned curse of the horseman."
						if("frenchcurse")
							feedback_add_details("wizard_spell_learned","FC") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/equip_item/frenchcurse,H)
							temp = "You have learned the french curse."
						if("clowncurse")
							feedback_add_details("wizard_spell_learned","CC") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/equip_item/clowncurse,H)
							temp = "You have learned the clown curse."
						if("shoesnatch")
							feedback_add_details("wizard_spell_learned","SS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/shoesnatch,H)
							temp = "You have learned the shoe snatching charm."
						if("robesummon")
							feedback_add_details("wizard_spell_learned", "RS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/equip_item/robesummon,H)
							temp = "you have learned summon robes."
						if("fleshtostone")
							feedback_add_details("wizard_spell_learned","FS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/flesh_to_stone,H)
							temp = "You have learned flesh to stone."
						if("arsenath")
							feedback_add_details("wizard_spell_learned","AN") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/targeted/buttbots_revenge,H)
							temp = "You have learned butt-bot's revenge."
						if("summonguns")
							if(!ticker.mode.rage)
								feedback_add_details("wizard_spell_learned","SG") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
								H.rightandwrong(0)
								max_uses--
								temp = "You have cast summon guns."
							else
								log_admin("[usr]([usr.key]) used an href to try and summon guns during ragin mages.")
								uses++
						if("summonmagic")
							feedback_add_details("wizard_spell_learned","SU") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.rightandwrong(1)
							max_uses--
							temp = "You have cast summon magic."
						if("staffchange")
							feedback_add_details("wizard_spell_learned","ST") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/energy/staff(get_turf(H))
							temp = "You have purchased a staff of change."
							max_uses--
						if("mentalfocus")
							feedback_add_details("wizard_spell_learned","MF") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/energy/staff/focus(get_turf(H))
							temp = "An artefact that channels the will of the user into destructive bolts of force."
							max_uses--
						if("soulstone")
							feedback_add_details("wizard_spell_learned","SS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/storage/belt/soulstone/full(get_turf(H))
							add_spell(new/spell/aoe_turf/conjure/construct,H)
							H.add_language("Cult")
							temp = "You have purchased a belt full of soulstones and have learned the artificer spell."
							max_uses--
						if("armor")
							feedback_add_details("wizard_spell_learned","HS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/clothing/shoes/sandal(get_turf(H)) //In case they've lost them.
							new /obj/item/clothing/gloves/purple(get_turf(H))//To complete the outfit
							new /obj/item/clothing/suit/space/rig/wizard(get_turf(H))
							new /obj/item/clothing/head/helmet/space/rig/wizard(get_turf(H))
							temp = "You have purchased a suit of wizard armor."
							max_uses--
						if("staffanimation")
							feedback_add_details("wizard_spell_learned","SA") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/energy/staff/animate(get_turf(H))
							temp = "You have purchased a staff of animation."
							max_uses--
						if("staffnecro")
							feedback_add_details("wizard_spell_learned","SN") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/staff/necro(get_turf(H))
							temp = "You have purchased a staff of necromancy."
							max_uses--
						if("contract")
							feedback_add_details("wizard_spell_learned","CT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/antag_spawner/contract(get_turf(H))
							temp = "You have purchased a contract of apprenticeship."
							max_uses--
						if("scrying")
							feedback_add_details("wizard_spell_learned","SO") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/scrying(get_turf(H))
							if (!(M_XRAY in H.mutations))
								H.mutations.Add(M_XRAY)
								H.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
								H.see_in_dark = 8
								H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
								to_chat(H, "<span class='notice'>The walls suddenly disappear.</span>")
							temp = "You have purchased a scrying orb, and gained x-ray vision."
							max_uses--
						if("chariot")
							feedback_add_details("wizard_spell_learned","WM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							add_spell(new/spell/aoe_turf/conjure/pontiac,H)
							temp = "This spell summons a glorious, flaming chariot that can move in space and through walls.  It also has an extremely long cooldown."
						if("bundle")
							feedback_add_details("wizard_spell_learned","SB")
							new /obj/item/weapon/storage/box/spellbook(get_turf(H))
							temp = "You have purchased the spellbook bundle."
							uses -= 4
							max_uses-=5


		else
			if(href_list["temp"])
				temp = null
		attack_self()

	return

//Single Use Spellbooks//
/obj/item/weapon/spellbook/proc/add_spell(var/spell/spell_to_add,var/mob/user)
	if(user.mind)
		if(!user.mind.wizard_spells)
			user.mind.wizard_spells = list()
		user.mind.wizard_spells += spell_to_add
	user.add_spell(spell_to_add)

/obj/item/weapon/spellbook/oneuse
	var/spell = /spell/targeted/projectile/magic_missile //just a placeholder to avoid runtimes if someone spawned the generic
	var/spellname = "sandbox"
	var/used = 0
	name = "spellbook of "
	uses = 1
	max_uses = 1
	desc = "This template spellbook was never meant for the eyes of man..."

/obj/item/weapon/spellbook/oneuse/New()
	..()
	name += spellname

/obj/item/weapon/spellbook/oneuse/attack_self(mob/user as mob)
	var/spell/S = new spell(user)
	for(var/spell/knownspell in user.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				if(user.mind.special_role == "apprentice" || user.mind.special_role == "Wizard")
					to_chat(user, "<span class='notice'>You're already far more versed in this spell than this flimsy how-to book can provide.</span>")
				else
					to_chat(user, "<span class='notice'>You've already read this one.</span>")
			return
	if(used)
		recoil(user)
	else
		user.add_spell(S)
		to_chat(user, "<span class='notice'>you rapidly read through the arcane book. Suddenly you realize you understand [spellname]!</span>")
		user.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.real_name] ([user.ckey]) learned the spell [spellname] ([S]).</font>")
		onlearned(user)

/obj/item/weapon/spellbook/oneuse/proc/recoil(mob/user as mob)
	user.visible_message("<span class='warning'>[src] glows in a black light!</span>")

/obj/item/weapon/spellbook/oneuse/proc/onlearned(mob/user as mob)
	used = 1
	user.visible_message("<span class='caution'>[src] glows dark for a second!</span>")

/obj/item/weapon/spellbook/oneuse/attackby()
	return

/obj/item/weapon/spellbook/oneuse/fireball
	spell = /spell/targeted/projectile/dumbfire/fireball
	spellname = "fireball"
	icon_state ="bookfireball"
	desc = "This book feels warm to the touch."

/obj/item/weapon/spellbook/oneuse/fireball/recoil(mob/user as mob)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
	qdel(src)

/obj/item/weapon/spellbook/oneuse/smoke
	spell = /spell/aoe_turf/smoke
	spellname = "smoke"
	icon_state ="booksmoke"
	desc = "This book is overflowing with the dank arts."

/obj/item/weapon/spellbook/oneuse/smoke/recoil(mob/living/user as mob)
	..()
	to_chat(user, "<span class='caution'>Your stomach rumbles...</span>")
	if(user.nutrition)
		user.nutrition = max(user.nutrition - 200,0)

/obj/item/weapon/spellbook/oneuse/blind
	spell = /spell/targeted/genetic/blind
	spellname = "blind"
	icon_state ="bookblind"
	desc = "This book looks blurry, no matter how you look at it."

/obj/item/weapon/spellbook/oneuse/blind/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You go blind!</span>")
	user.eye_blind = 10

/obj/item/weapon/spellbook/oneuse/mindswap
	spell = /spell/targeted/mind_transfer
	spellname = "mindswap"
	icon_state ="bookmindswap"
	desc = "This book's cover is pristine, though its pages look ragged and torn."
	var/mob/stored_swap = null //Used in used book recoils to store an identity for mindswaps

/obj/item/weapon/spellbook/oneuse/mindswap/onlearned()
	spellname = pick("fireball","smoke","blind","forcewall","knock","horses","charge")
	icon_state = "book[spellname]"
	name = "spellbook of [spellname]" //Note, desc doesn't change by design
	..()

/obj/item/weapon/spellbook/oneuse/mindswap/recoil(mob/user as mob)
	..()
	if(stored_swap in dead_mob_list)
		stored_swap = null
	if(!stored_swap)
		stored_swap = user
		to_chat(user, "<span class='warning'>For a moment you feel like you don't even know who you are anymore.</span>")
		return
	if(stored_swap == user)
		to_chat(user, "<span class='notice'>You stare at the book some more, but there doesn't seem to be anything else to learn...</span>")
		return

	if(user.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs -= V

	if(stored_swap.mind.special_verbs.len)
		for(var/V in stored_swap.mind.special_verbs)
			stored_swap.verbs -= V

	var/mob/dead/observer/ghost = stored_swap.ghostize(0)
	ghost.spell_list = stored_swap.spell_list

	user.mind.transfer_to(stored_swap)
	stored_swap.spell_list = user.spell_list

	if(stored_swap.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs += V

	ghost.mind.transfer_to(user)
	user.key = ghost.key
	user.spell_list = ghost.spell_list

	if(user.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs += V

	to_chat(stored_swap, "<span class='warning'>You're suddenly somewhere else... and someone else?!</span>")
	to_chat(user, "<span class='warning'>Suddenly you're staring at [src] again... where are you, who are you?!</span>")
	stored_swap = null

/obj/item/weapon/spellbook/oneuse/forcewall
	spell = /spell/aoe_turf/conjure/forcewall
	spellname = "forcewall"
	icon_state ="bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."

/obj/item/weapon/spellbook/oneuse/forcewall/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You suddenly feel very solid!</span>")
	var/obj/structure/closet/statue/S = new /obj/structure/closet/statue(user.loc, user)
	S.timer = 30
	user.drop_item()


/obj/item/weapon/spellbook/oneuse/knock
	spell = /spell/aoe_turf/knock
	spellname = "knock"
	icon_state ="bookknock"
	desc = "This book is hard to hold closed properly."

/obj/item/weapon/spellbook/oneuse/knock/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You're knocked down!</span>")
	user.Weaken(20)

/obj/item/weapon/spellbook/oneuse/horsemask
	spell = /spell/targeted/equip_item/horsemask
	spellname = "horses"
	icon_state ="bookhorses"
	desc = "This book is more horse than your mind has room for."

/obj/item/weapon/spellbook/oneuse/horsemask/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		to_chat(user, "<font size='15' color='red'><b>HOR-SIE HAS RISEN</b></font>")
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.canremove = 0		//curses!
		magichead.voicechange = 1	//NEEEEIIGHH
		user.drop_from_inventory(user.wear_mask)
		user.equip_to_slot_if_possible(magichead, slot_wear_mask, 1, 1)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>I say thee neigh</span>")

/obj/item/weapon/spellbook/oneuse/charge
	spell = /spell/aoe_turf/charge
	spellname = "charging"
	icon_state ="bookcharge"
	desc = "This book is made of 100% post-consumer wizard."

/obj/item/weapon/spellbook/oneuse/charge/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>[src] suddenly feels very warm!</span>")
	empulse(src, 1, 1)

/obj/item/weapon/spellbook/oneuse/clown
	spell = /spell/targeted/equip_item/clowncurse
	spellname = "clowning"
	icon_state = "bookclown"
	desc = "This book is comedy gold!"

/obj/item/weapon/spellbook/oneuse/clown/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		to_chat(user, "<span class ='warning'>You suddenly feel funny!</span>")
		var/obj/item/clothing/mask/gas/clown_hat/magicclown = new /obj/item/clothing/mask/gas/clown_hat
		magicclown.canremove = 0
		magicclown.unacidable = 1
		user.flash_eyes(visual = 1)
		user.dna.SetSEState(CLUMSYBLOCK,1)
		genemutcheck(user,CLUMSYBLOCK,null,MUTCHK_FORCED)
		user.update_mutations()
		user.drop_from_inventory(user.wear_mask)
		user.equip_to_slot_if_possible(magicclown, slot_wear_mask, 1, 1)
		qdel(src)

/obj/item/weapon/spellbook/oneuse/mime
	spell = /spell/targeted/equip_item/frenchcurse
	spellname = "miming"
	icon_state = "bookmime"
	desc = "This book is entirely in french."

/obj/item/weapon/spellbook/oneuse/mime/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		to_chat(user, "<span class ='warning'>You suddenly feel very quiet.</span>")
		var/obj/item/clothing/mask/gas/mime/magicmime = new /obj/item/clothing/mask/gas/mime
		magicmime.canremove = 0
		magicmime.unacidable = 1
		magicmime.muted = 1
		user.flash_eyes(visual = 1)
		user.drop_from_inventory(user.wear_mask)
		user.equip_to_slot_if_possible(magicmime, slot_wear_mask, 1, 1)
		qdel(src)

/obj/item/weapon/spellbook/oneuse/shoesnatch
	spell = /spell/targeted/shoesnatch
	spellname = "shoe snatching"
	icon_state = "bookshoe"
	desc = "This book will knock you off your feet."

/obj/item/weapon/spellbook/oneuse/shoesnatch/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/victim = user
		to_chat(user, "<span class ='warning'>Your feet feel funny!</span>")
		var/obj/item/clothing/shoes/clown_shoes/magicshoes = new /obj/item/clothing/shoes/clown_shoes
		magicshoes.canremove = 0
		magicshoes.wizard_garb = 1
		magicshoes.unacidable = 1
		user.flash_eyes(visual = 1)
		user.drop_from_inventory(victim.shoes)
		user.equip_to_slot(magicshoes, slot_shoes, 1, 1)
		qdel(src)


/obj/item/weapon/spellbook/oneuse/robesummon
	spell = /spell/targeted/equip_item/robesummon
	spellname = "robe summoning"
	icon_state = "bookrobe"
	desc = "This book is full of helpful fashion tips for apprentice wizards."

/obj/item/weapon/spellbook/oneuse/robesummon/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/victim = user
		to_chat(user, "<span class ='warning'>You suddenly feel very restrained!</span>")
		var/obj/item/clothing/suit/straight_jacket/magicjacket = new/obj/item/clothing/suit/straight_jacket
		user.drop_from_inventory(victim.wear_suit)
		user.equip_to_slot(magicjacket, slot_wear_suit, 1, 1)
		user.flash_eyes(visual = 1)
		qdel(src)

/obj/item/weapon/spellbook/oneuse/disabletech
	spell = /spell/aoe_turf/disable_tech
	spellname = "disable tech"
	icon_state = "bookdisabletech"
	desc = "This book was written with luddites in mind."

/obj/item/weapon/spellbook/oneuse/disabletech/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.contract_disease(new /datum/disease/robotic_transformation(0), 1)
		to_chat(user, "<span class ='warning'>You feel a closer connection to technology...</span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/magicmissle
	spell = /spell/targeted/projectile/magic_missile
	spellname = "magic missle"
	icon_state = "bookmm"
	desc = "This book is a perfect prop for LARPers."

/obj/item/weapon/spellbook/oneuse/magicmissle/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.adjustBrainLoss(100)
		to_chat(user, "<span class = 'warning'>You can't cast this spell when it isn't your turn! 	You feel very stupid.</span>")
		qdel(src)


/obj/item/weapon/spellbook/oneuse/mutate
	spell = /spell/targeted/genetic/mutate
	spellname = "mutating"
	icon_state = "bookmutate"
	desc = "All the pages in this book are ripped."

/obj/item/weapon/spellbook/oneuse/mutate/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.dna.SetSEState(HEADACHEBLOCK,1)
		genemutcheck(user,HEADACHEBLOCK,null,MUTCHK_FORCED)
		user.update_mutations()
		to_chat(user, "<span class = 'warning'>You feel like you've been pushing yourself too hard! </span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/subjugate
	spell = /spell/targeted/subjugation
	spellname = "subjugation"
	icon_state = "booksubjugate"
	desc = "This book makes you feel dizzy."

/obj/item/weapon/spellbook/oneuse/subjugate/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.reagents.add_reagent(RUM, 200)
		to_chat(user, "<span class = 'warning'>You feel very drunk all of a sudden.</span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/teleport
	spell = /spell/area_teleport
	spellname = "teleportation"
	icon_state = "booktele"
	desc = "This book will really take you places."

/obj/item/weapon/spellbook/oneuse/teleport/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/h = user
		user.flash_eyes(visual = 1)
		for(var/datum/organ/external/l_leg/E in h.organs)
			E.droplimb(1)
		for(var/datum/organ/external/r_leg/E in h.organs)
			E.droplimb(1)
		to_chat(user, "<span class = 'warning'>Your legs fall off!</span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/teleport/blink //sod coding different effects for each teleport spell
	spell = /spell/aoe_turf/blink
	spellname = "blinking"

/obj/item/weapon/spellbook/oneuse/teleport/jaunt
	spell = /spell/targeted/ethereal_jaunt
	spellname = "jaunting"

/obj/item/weapon/spellbook/oneuse/buttbot
	spell = /spell/targeted/buttbots_revenge
	spellname = "ass magic"
	icon_state = "bookbutt"

/obj/item/weapon/spellbook/oneuse/buttbot/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/C = user
		if(C.op_stage.butt != 4)
			var/obj/item/clothing/head/butt/B = new(C.loc)
			B.transfer_buttdentity(C)
			C.op_stage.butt = 4
			to_chat(user, "<span class='warning'>Your ass just blew up!</span>")
		playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, 1)
		C.apply_damage(40, BRUTE, LIMB_GROIN)
		C.apply_damage(10, BURN, LIMB_GROIN)
		qdel(src)

/obj/item/weapon/spellbook/oneuse/lightning
	spell = /spell/lightning
	spellname = "lightning"
	icon_state = "booklightning"

/obj/item/weapon/spellbook/oneuse/lightning/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.apply_damage(25, BURN, LIMB_LEFT_HAND)
		user.apply_damage(25, BURN, LIMB_RIGHT_HAND)
		to_chat(user, "<span class = 'warning'>The book heats up and burns your hands!</span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/timestop
	spell = /spell/aoe_turf/fall
	spellname = "time stopping"
	icon_state = "booktimestop"
	desc = "A rare, vintage copy of 'WizzWizz's Magical Adventures."

/obj/item/weapon/spellbook/oneuse/timestop/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.stunned = 5
		user.flash_eyes(visual = 1)
		to_chat(user, "<span class = 'warning'>You have been turned into a statue!</span>")
		new /obj/structure/closet/statue(user.loc, user) //makes the statue
		qdel(src)
	return


/obj/item/weapon/spellbook/oneuse/timestop/statute //recoil effect is same as timestop effect so this is a child
	spell = /spell/targeted/flesh_to_stone
	spellname = "sculpting"
	icon_state = "bookstatue"
	desc = "This book is as dense as a rock."

// Spell Book Bundles//

/obj/item/weapon/storage/box/spellbook
	name = "Spellbook Bundle"
	desc = "High quality discount spells! This bundle is non-refundable. The end user is solely liable for any damages arising from misuse of these products."

/obj/item/weapon/storage/box/spellbook/New()
	..()
	var/list/possible_books = typesof(/obj/item/weapon/spellbook/oneuse)
	possible_books -= /obj/item/weapon/spellbook/oneuse
	possible_books -= /obj/item/weapon/spellbook/oneuse/charge
	for(var/i =1; i <= 7; i++)
		var/randombook = pick(possible_books)
		var/book = new randombook(src)
		src.contents += book
		possible_books -= randombook
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
