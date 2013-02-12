/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	var/uses = 5
	var/temp = null
	var/max_uses = 5
	var/op = 1


/obj/item/weapon/spellbook/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat
	if(temp)
		dat = "[temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = "<B>The Book of Spells:</B><BR>"
		dat += "Spells left to memorize: [uses]<BR>"
		dat += "<HR>"
		dat += "<B>Memorize which spell:</B><BR>"
		dat += "<I>The number after the spell name is the cooldown time.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=magicmissile'>Magic Missile</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=fireball'>Fireball</A> (10)<BR>"
		//dat += "<A href='byond://?src=\ref[src];spell_choice=disintegrate'>Disintegrate</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=disabletech'>Disable Technology</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=smoke'>Smoke</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=blind'>Blind</A> (30)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=mindswap'>Mind Transfer</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=forcewall'>Forcewall</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=blink'>Blink</A> (2)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=teleport'>Teleport</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=mutate'>Mutate</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=etherealjaunt'>Ethereal Jaunt</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=knock'>Knock</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=horseman'>Curse of the Horseman</A> (15)<BR>"
//		if(op)
//			dat += "<A href='byond://?src=\ref[src];spell_choice=summonguns'>Summon Guns</A> (One time use, global spell)<BR>"
		dat += "<HR>"
		dat += "<B>Artefacts:</B><BR>"
		dat += "Powerful items imbued with eldritch magics. Summoning one will count towards your maximum number of spells.<BR>"
		dat += "It is recommended that only experienced wizards attempt to wield such artefacts.<BR>"
		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=staffchange'>Staff of Change</A><BR>"
		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=soulstone'>Six Soul Stone Shards and the spell Artificer</A><BR>"
		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=armor'>Mastercrafted Armor Set</A><BR>"
		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=staffanimation'>Staff of Animation</A><BR>"
		dat += "<HR>"
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
				uses--
			/*
			*/
				var/list/available_spells = list(magicmissile = "Magic Missile", fireball = "Fireball", disintegrate = "Disintegrate", disabletech = "Disable Tech", smoke = "Smoke", blind = "Blind", mindswap = "Mind Transfer", forcewall = "Forcewall", blink = "Blink", teleport = "Teleport", mutate = "Mutate", etherealjaunt = "Ethereal Jaunt", knock = "Knock", horseman = "Curse of the Horseman", summonguns = "Summon Guns", staffchange = "Staff of Change", soulstone = "Six Soul Stone Shards and the spell Artificer", armor = "Mastercrafted Armor Set", staffanimate = "Staff of Animation")
				var/already_knows = 0
				for(var/obj/effect/proc_holder/spell/aspell in H.spell_list)
					if(available_spells[href_list["spell_choice"]] == aspell.name)
						already_knows = 1
						temp = "You already know that spell."
						uses++
						break
			/*
			*/
				if(!already_knows)
					switch(href_list["spell_choice"])
						if("magicmissile")
							feedback_add_details("wizard_spell_learned","MM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(H)
							temp = "This spell fires several, slow moving, magic projectiles at nearby targets. If they hit a target, it is paralyzed and takes minor damage."
						if("fireball")
							feedback_add_details("wizard_spell_learned","FB") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/dumbfire/fireball(H)
							temp = "This spell fires a fireball in the direction you're facing and does not require wizard garb. Be careful not to fire it at people that are standing next to you."
						if("disintegrate")
							feedback_add_details("wizard_spell_learned","DG") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/inflict_handler/disintegrate(H)
							temp = "This spell instantly kills somebody adjacent to you with the vilest of magick. It has a long cooldown."
						if("disabletech")
							feedback_add_details("wizard_spell_learned","DT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech(H)
							temp = "This spell disables all weapons, cameras and most other technology in range."
						if("smoke")
							feedback_add_details("wizard_spell_learned","SM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/smoke(H)
							temp = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
						if("blind")
							feedback_add_details("wizard_spell_learned","BD") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/trigger/blind(H)
							temp = "This spell temporarly blinds a single person and does not require wizard garb."
						if("mindswap")
							feedback_add_details("wizard_spell_learned","MT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/mind_transfer(H)
							temp = "This spell allows the user to switch bodies with a target. Careful to not lose your memory in the process."
						if("forcewall")
							feedback_add_details("wizard_spell_learned","FW") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall(H)
							temp = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."
						if("blink")
							feedback_add_details("wizard_spell_learned","BL") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink(H)
							temp = "This spell randomly teleports you a short distance. Useful for evasion or getting into areas if you have patience."
						if("teleport")
							feedback_add_details("wizard_spell_learned","TP") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(H)
							temp = "This spell teleports you to a type of area of your selection. Very useful if you are in danger, but has a decent cooldown, and is unpredictable."
						if("mutate")
							feedback_add_details("wizard_spell_learned","MU") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/genetic/mutate(H)
							temp = "This spell causes you to turn into a hulk and gain telekinesis for a short while."
						if("etherealjaunt")
							feedback_add_details("wizard_spell_learned","EJ") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(H)
							temp = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
						if("knock")
							feedback_add_details("wizard_spell_learned","KN") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/knock(H)
							temp = "This spell opens nearby doors and does not require wizard garb."
						if("horseman")
							feedback_add_details("wizard_spell_learned","HH") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/targeted/horsemask(H)
							temp = "This spell will curse a person to wear an unremovable horse mask (it has glue on the inside) and speak like a horse. It does not require a wizard garb. Do note the curse will disintegrate the target's current mask if they are wearing one."
						if("summonguns")
							feedback_add_details("wizard_spell_learned","SG") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.rightandwrong()
							max_uses--
							temp = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill eachother. Just be careful not to get hit in the crossfire!"
						if("staffchange")
							feedback_add_details("wizard_spell_learned","ST") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/energy/staff(get_turf(H))
							temp = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself"
							max_uses--
						if("soulstone")
							feedback_add_details("wizard_spell_learned","SS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/storage/belt/soulstone/full(get_turf(H))
							H.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(H)
							temp = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
							max_uses--
						if("armor")
							feedback_add_details("wizard_spell_learned","HS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/clothing/shoes/sandal(get_turf(H)) //In case they've lost them.
							new /obj/item/clothing/gloves/purple(get_turf(H))//To complete the outfit
							new /obj/item/clothing/suit/space/rig/wizard(get_turf(H))
							new /obj/item/clothing/head/helmet/space/rig/wizard(get_turf(H))
							temp = "An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space."
							max_uses--
						if("staffanimation")
							feedback_add_details("wizard_spell_learned","SA") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/energy/staff/animate(get_turf(H))
							temp = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
							max_uses--
		else
			if(href_list["temp"])
				temp = null
		attack_self(H)

	return
