/datum/spellbook_entry
	var/name = "Entry Name"

	var/spell_type = null
	var/desc = ""
	var/category = "Offensive Spells"
	var/log_name = "XX" //What it shows up as in logs
	var/cost = 1
	var/refundable = 1
	var/surplus = -1 // -1 for infinite, not used by anything atm
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"

/datum/spellbook_entry/proc/IsAvailible() // For config prefs / gamemode restrictions - these are round applied
	return 1
/datum/spellbook_entry/proc/CanBuy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book) // Specific circumstances
	if(book.uses<cost)
		return 0
	return 1
/datum/spellbook_entry/proc/Buy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book) //return 1 on success
	if(!S)
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

/datum/spellbook_entry/proc/CanRefund(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
	if(!refundable)
		return 0
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return 1
	return 0

/datum/spellbook_entry/proc/Refund(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book) //return point value or -1 for failure
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
			del(S)
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
	spell_type = /obj/effect/proc_holder/spell/dumbfire/fireball
	log_name = "FB"

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	log_name = "MM"

/datum/spellbook_entry/disintegrate
	name = "Disintegrate"
	spell_type = /obj/effect/proc_holder/spell/targeted/inflict_handler/disintegrate
	log_name = "DG"

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	spell_type = /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	log_name = "DT"
	category = "Utility Spells"

/datum/spellbook_entry/repulse
	name = "Repulse"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	log_name = "RP"

/datum/spellbook_entry/smoke
	name = "Smoke"
	spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	log_name = "SM"
	category = "Utility Spells"

/datum/spellbook_entry/blind
	name = "Blind"
	spell_type = /obj/effect/proc_holder/spell/targeted/trigger/blind
	log_name = "BD"

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	spell_type = /obj/effect/proc_holder/spell/targeted/mind_transfer
	log_name = "MT"
	category = "Utility Spells"

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall
	log_name = "FW"
	category = "Utility Spells"

/datum/spellbook_entry/blink
	name = "Blink"
	spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	log_name = "BL"
	category = "Utility Spells"

/datum/spellbook_entry/teleport
	name = "Teleport"
	spell_type = /obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	log_name = "TP"
	category = "Utility Spells"

/datum/spellbook_entry/mutate
	name = "Mutate"
	spell_type = /obj/effect/proc_holder/spell/targeted/genetic/mutate
	log_name = "MU"
	category = "Utility Spells"

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	spell_type = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	log_name = "EJ"
	category = "Utility Spells"

/datum/spellbook_entry/knock
	name = "Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock
	log_name = "KN"
	category = "Utility Spells"

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	spell_type = /obj/effect/proc_holder/spell/targeted/inflict_handler/flesh_to_stone
	log_name = "FS"

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	spell_type = /obj/effect/proc_holder/spell/targeted/summonitem
	log_name = "IS"
	category = "Utility Spells"

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	spell_type = /obj/effect/proc_holder/spell/targeted/lichdom
	log_name = "LD"

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	spell_type = /obj/effect/proc_holder/spell/targeted/lightning
	log_name = "LB"

/datum/spellbook_entry/barnyard
	name = "Barnyard Curse"
	spell_type = /obj/effect/proc_holder/spell/targeted/barnyardcurse
	log_name = "BC"

/datum/spellbook_entry/item
	name = "Buy Item"
	category = "Artifacts"
	refundable = 0
	buy_word = "Summon"
	var/item_path= null


/datum/spellbook_entry/item/Buy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
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

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "A caprious tool that can fire all sorts of magic without any rhyme or reason. Using it on people you care about is not recommended."
	item_path = /obj/item/weapon/gun/magic/staff/chaos
	log_name = "SC"

/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid metal into ornate wooden doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/weapon/gun/magic/staff/door
	log_name = "SD"

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy, using it will allow you to ghost while alive, allowing you to spy upon the station with ease. In addition, buying it will permanently grant you x-ray vision."
	item_path = /obj/item/weapon/gun/magic/staff/chaos
	log_name = "SO"

/datum/spellbook_entry/item/scryingorb/Buy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
	if(..())
		if (!(user.dna.check_mutation(XRAY)))
			user.dna.add_mutation(XRAY)
	return 1

/datum/spellbook_entry/item/soulstones
	name = "Six Soul Stone Shards and the spell Artificer"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/weapon/storage/belt/soulstone/full
	log_name = "SS"

/datum/spellbook_entry/item/soulstones/Buy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
	. =..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(null))
	return .

/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as skeletal thralls for you to command."
	item_path = /obj/item/device/necromantic_stone
	log_name = "NS"

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "A collection of wands that allow for a wide variety of utility. Wands do not recharge, so be conservative in use. Comes in a handy belt."
	item_path = /obj/item/weapon/storage/belt/wands/full
	log_name = "WA"

/datum/spellbook_entry/item/armor
	name = "Mastercrafted Armor Set"
	desc = "An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space."
	item_path = /obj/item/clothing/suit/space/hardsuit/wizard
	log_name = "HS"

/datum/spellbook_entry/item/armor/Buy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
	. = ..()
	if(.)
		new /obj/item/clothing/shoes/sandal(get_turf(user)) //In case they've lost them.
		new /obj/item/clothing/gloves/color/purple(get_turf(user))//To complete the outfit

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/weapon/antag_spawner/contract
	log_name = "CT"

/datum/spellbook_entry/summon
	name = "Summon Stuff"
	category = "Rituals"
	refundable = 0
	buy_word = "Cast"
	var/active = 0

/datum/spellbook_entry/summon/CanBuy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
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
	category = "Challenges"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. Just be careful not to stand still too long!"
	cost = 0
	log_name = "SG"

/datum/spellbook_entry/summon/guns/IsAvailible()
	return !config.no_summon_guns

/datum/spellbook_entry/summon/guns/Buy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
	feedback_add_details("wizard_spell_learned",log_name)
	rightandwrong(0, user, 0)
	book.uses += 1
	active = 1
	playsound(get_turf(user),"sound/magic/CastSummon.ogg",50,1)
	user << "<span class='notice'>You have cast summon guns and gained an extra charge for your spellbook.</span>"
	return 1

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	category = "Challenges"
	desc = "Share the wonders of magic with the crew and show them why they aren't to be trusted with it at the same time."
	cost = 0
	log_name = "SU"

/datum/spellbook_entry/summon/magic/IsAvailible()
	return !config.no_summon_magic

/datum/spellbook_entry/summon/magic/Buy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
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
	cost = 1
	log_name = "SE"
	var/times = 0

/datum/spellbook_entry/summon/events/IsAvailible()
	return (ticker.mode.name != "ragin' mages" && !config.no_summon_events)

/datum/spellbook_entry/summon/events/Buy(var/mob/living/carbon/human/user,var/obj/item/weapon/spellbook/book)
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
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = 1.0
	var/uses = 5
	var/temp = null
	var/op = 1
	var/tab = null
	var/mob/living/carbon/human/owner
	var/list/datum/spellbook_entry/entries = list()
	var/list/categories = list()

/obj/item/weapon/spellbook/New()
	..()
	var/entry_types = typesof(/datum/spellbook_entry) - /datum/spellbook_entry - /datum/spellbook_entry/item - /datum/spellbook_entry/summon
	for(var/T in entry_types)
		var/datum/spellbook_entry/E = new T
		if(E.IsAvailible())
			entries |= E
			categories |= E.category
		else
			del(E)
	tab = categories[1]


/obj/item/weapon/spellbook/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/weapon/antag_spawner/contract))
		var/obj/item/weapon/antag_spawner/contract/contract = O
		if(contract.used)
			user << "<span class='warning'>The contract has been used, you can't get your points back now!</span>"
		else
			user << "<span class='notice'>You feed the contract back into the spellbook, refunding your points.</span>"
			src.uses++
			qdel(O)

/obj/item/weapon/spellbook/proc/GetCategoryHeader(var/category)
	var/dat = ""
	switch(category)
		if("Offensive Spells")
			dat += "Spells that can be reused endlessly.<BR>"
			dat += "The number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Utility Spells")
			dat += "Spells that can be reused endlessly.<BR>"
			dat += "The number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Artifacts")
			dat += "Powerful items imbued with eldritch magics. Summoning one will count towards your maximum number of uses.<BR>"
			dat += "These items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
		if("Challenges")
			dat += "The Wizard Federation typically has hard limits on the potency and number of spells brought to the station based on risk.<BR>"
			dat += "Arming the station against you will increases the risk, but will grant you one more charge for your spellbook.<BR>"
		if("Rituals")
			dat += "These powerful spells change the very fabric of reality. Not always in your favour.<BR>"
	return dat

/obj/item/weapon/spellbook/proc/wrap(var/content)
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

/obj/item/weapon/spellbook/attack_self(mob/user as mob)
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

	dat += "<li><a><b>Uses remaining : [uses]</b></a></li>"
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

	user << browse(wrap(dat), "window=spellbook;size=600x300")
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
					uses -= E.cost
		else if(href_list["refund"])
			E = entries[text2num(href_list["refund"])]
			if(E && E.refundable)
				var/result = E.Refund(H,src)
				if(result > 0)
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

/obj/item/weapon/spellbook/oneuse/attack_self(mob/user as mob)
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

/obj/item/weapon/spellbook/oneuse/proc/recoil(mob/user as mob)
	user.visible_message("<span class='warning'>[src] glows in a black light!</span>")

/obj/item/weapon/spellbook/oneuse/proc/onlearned(mob/user as mob)
	used = 1
	user.visible_message("<span class='caution'>[src] glows dark for a second!</span>")

/obj/item/weapon/spellbook/oneuse/attackby()
	return

/obj/item/weapon/spellbook/oneuse/fireball
	spell = /obj/effect/proc_holder/spell/dumbfire/fireball
	spellname = "fireball"
	icon_state ="bookfireball"
	desc = "This book feels warm to the touch."

/obj/item/weapon/spellbook/oneuse/fireball/recoil(mob/user as mob)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
	qdel(src)

/obj/item/weapon/spellbook/oneuse/smoke
	spell = /obj/effect/proc_holder/spell/targeted/smoke
	spellname = "smoke"
	icon_state ="booksmoke"
	desc = "This book is overflowing with the dank arts."

/obj/item/weapon/spellbook/oneuse/smoke/recoil(mob/user as mob)
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

/obj/item/weapon/spellbook/oneuse/blind/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>You go blind!</span>"
	user.eye_blind = 10

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

/obj/item/weapon/spellbook/oneuse/mindswap/recoil(mob/user as mob)
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

	if(user.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs -= V

	if(stored_swap.mind.special_verbs.len)
		for(var/V in stored_swap.mind.special_verbs)
			stored_swap.verbs -= V

	var/mob/dead/observer/ghost = stored_swap.ghostize(0)

	user.mind.transfer_to(stored_swap)

	if(stored_swap.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs += V

	ghost.mind.transfer_to(user)
	user.key = ghost.key

	if(user.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs += V

	stored_swap <<"<span class='warning'>You're suddenly somewhere else... and someone else?!</span>"
	user <<"<span class='warning'>Suddenly you're staring at [src] again... where are you, who are you?!</span>"
	stored_swap = null

/obj/item/weapon/spellbook/oneuse/forcewall
	spell = /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall
	spellname = "forcewall"
	icon_state ="bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."

/obj/item/weapon/spellbook/oneuse/forcewall/recoil(mob/user as mob)
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

/obj/item/weapon/spellbook/oneuse/knock/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>You're knocked down!</span>"
	user.Weaken(20)

/obj/item/weapon/spellbook/oneuse/barnyard
	spell = /obj/effect/proc_holder/spell/targeted/barnyardcurse
	spellname = "barnyard"
	icon_state ="bookhorses"
	desc = "This book is more horse than your mind has room for."

/obj/item/weapon/spellbook/oneuse/barnyard/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user <<"<font size='15' color='red'><b>HOR-SIE HAS RISEN</b></font>"
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.flags |= NODROP		//curses!
		magichead.flags_inv = null	//so you can still see their face
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

/obj/item/weapon/spellbook/oneuse/charge/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>[src] suddenly feels very warm!</span>"
	empulse(src, 1, 1)

/obj/item/weapon/spellbook/oneuse/summonitem
	spell = /obj/effect/proc_holder/spell/targeted/summonitem
	spellname = "instant summons"
	icon_state ="booksummons"
	desc = "This book is bright and garish, very hard to miss."

/obj/item/weapon/spellbook/oneuse/summonitem/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>[src] suddenly vanishes!</span>"
	qdel(src)
