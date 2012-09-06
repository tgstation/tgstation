
//SPELL BOOK PROCS

/obj/item/weapon/spellbook/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = "<B>The Book of Spells:</B><BR>"
		dat += "Spells left to memorize: [src.uses]<BR>"
		dat += "<HR>"
		dat += "<B>Memorize which spell:</B><BR>"
		dat += "<I>The number after the spell name is the cooldown time.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=1'>Magic Missile</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=2'>Fireball</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=3'>Disintegrate</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=4'>Disable Technology</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=5'>Smoke</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=6'>Blind</A> (30)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=7'>Mind Transfer</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=8'>Forcewall</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=9'>Blink</A> (2)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=10'>Teleport</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=11'>Mutate</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=12'>Ethereal Jaunt</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=13'>Knock</A> (10)<BR>"
		if(op)
			dat += "<A href='byond://?src=\ref[src];spell_choice=14'>Summon Guns</A> (One time use, global spell)<BR>"
		dat += "<HR>"
		dat += "<B>Artefacts:</B><BR>"
		dat += "Powerful items imbued with eldritch magics. Summoning one will count towards your maximum number of spells.<BR>"
		dat += "It is recommended that only experienced wizards attempt to wield such artefacts.<BR>"
		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=15'>Staff of Change</A><BR>"
		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=16'>Six Soul Stone Shards and the spell Artificer</A><BR>"
		dat += "<HR>"
		if(op)
			dat += "<A href='byond://?src=\ref[src];spell_choice=18'>Re-memorize Spells</A><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return


/obj/item/weapon/spellbook/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/mob/living/carbon/human/H = usr
	if (!( istype(H, /mob/living/carbon/human)))
		return 1
	if ((usr.contents.Find(src) || (in_range(src,usr) && istype(src.loc, /turf))))
		usr.machine = src
		if(href_list["spell_choice"])
			if(src.uses >= 1 && src.max_uses >=1 && text2num(href_list["spell_choice"]) < 18)
				src.uses--
				var/list/available_spells = list("Magic Missile","Fireball","Disintegrate","Disable Tech","Smoke","Blind","Mind Transfer","Forcewall","Blink","Teleport","Mutate","Ethereal Jaunt","Knock","Summon Guns","Staff of Change","Six Soul Stone Shards and the spell Artificer")
				var/already_knows = 0
				for(var/obj/effect/proc_holder/spell/aspell in usr.spell_list)
					if(available_spells[text2num(href_list["spell_choice"])] == aspell.name)
						already_knows = 1
						src.temp = "You already know that spell."
						src.uses++
						break
				if(!already_knows)
					switch(href_list["spell_choice"])
						if ("1")
							feedback_add_details("wizard_spell_learned","MM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(usr)
							src.temp = "This spell fires several, slow moving, magic projectiles at nearby targets. If they hit a target, it is paralyzed and takes minor damage."
						if ("2")
							feedback_add_details("wizard_spell_learned","FB") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/projectile/fireball(usr)
							src.temp = "This spell fires a fireball in the direction you're facing and does not require wizard garb. Be careful not to fire it at people that are standing next to you."
						if ("3")
							feedback_add_details("wizard_spell_learned","DG") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/inflict_handler/disintegrate(usr)
							src.temp = "This spell instantly kills somebody adjacent to you with the vilest of magick. It has a long cooldown."
						if ("4")
							feedback_add_details("wizard_spell_learned","DT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech(usr)
							src.temp = "This spell disables all weapons, cameras and most other technology in range."
						if ("5")
							feedback_add_details("wizard_spell_learned","SM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/smoke(usr)
							src.temp = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
						if ("6")
							feedback_add_details("wizard_spell_learned","BD") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/trigger/blind(usr)
							src.temp = "This spell temporarly blinds a single person and does not require wizard garb."
						if ("7")
							feedback_add_details("wizard_spell_learned","MT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/mind_transfer(usr)
							src.temp = "This spell allows the user to switch bodies with a target. Careful to not lose your memory in the process."
						if ("8")
							feedback_add_details("wizard_spell_learned","FW") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall(usr)
							src.temp = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."
						if ("9")
							feedback_add_details("wizard_spell_learned","BL") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink(usr)
							src.temp = "This spell randomly teleports you a short distance. Useful for evasion or getting into areas if you have patience."
						if ("10")
							feedback_add_details("wizard_spell_learned","TP") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(usr)
							src.temp = "This spell teleports you to a type of area of your selection. Very useful if you are in danger, but has a decent cooldown, and is unpredictable."
						if ("11")
							feedback_add_details("wizard_spell_learned","MU") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/genetic/mutate(usr)
							src.temp = "This spell causes you to turn into a hulk and gain telekinesis for a short while."
						if ("12")
							feedback_add_details("wizard_spell_learned","EJ") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(usr)
							src.temp = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
						if ("13")
							feedback_add_details("wizard_spell_learned","KN") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/knock(usr)
							src.temp = "This spell opens nearby doors and does not require wizard garb."
						if ("14")
							feedback_add_details("wizard_spell_learned","SG") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							usr.rightandwrong()
							src.max_uses--
							src.temp = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill eachother. Just be careful not to get hit in the crossfire!"
						if ("15")
							feedback_add_details("wizard_spell_learned","ST") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/energy/staff(get_turf(usr))
							src.temp = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself"
							src.max_uses--
						if ("16")
							feedback_add_details("wizard_spell_learned","SS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/storage/belt/soulstone/full(get_turf(usr))
							usr.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(usr)
							src.temp = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
							src.max_uses--
			if (href_list["spell_choice"] == "18")
				var/area/wizard_station/A = locate()
				if(usr in A.contents)
					src.uses = src.max_uses
					usr.spellremove(usr)
					src.temp = "All spells have been removed. You may now memorize a new set of spells."
					feedback_add_details("wizard_spell_learned","UM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
				else
					src.temp = "You may only re-memorize spells whilst located inside the wizard sanctuary."
		else
			if (href_list["temp"])
				src.temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return
