#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_dispenser/
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'chemical.dmi'
	icon_state = "dispenser"
	var/energy = 25
	var/max_energy = 25
	var/list/dispensable_reagents = list("water","oxygen","nitrogen","hydrogen","potassium","mercury","sulfur","carbon","chlorine","fluorine","phosphorus","lithium","acid","radium","iron","aluminium","silicon","plasma","sugar","ethanol")

	proc
		recharge()
			if(stat & BROKEN) return
			if(energy != max_energy)
				energy++
				use_power(50)
			spawn(600) recharge()

	New()
		recharge()

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					del(src)
					return

	blob_act()
		if (prob(50))
			del(src)

	meteorhit()
		del(src)
		return

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src

		if (href_list["dispense"])
			if(!energy)
				var/dat = "Not enough energy.<BR><A href='?src=\ref[src];ok=1'>OK</A>"
				usr << browse("<TITLE>Chemical Dispenser</TITLE>Chemical dispenser:<BR>Energy = [energy]/[max_energy]<BR><BR>[dat]", "window=chem_dispenser")
				return
			var/id = href_list["dispense"]
			var/obj/item/weapon/reagent_containers/glass/dispenser/G = new/obj/item/weapon/reagent_containers/glass/dispenser(src.loc)
			switch(text2num(href_list["state"]))
				if(LIQUID)
					G.icon_state = "liquid"
				if(GAS)
					G.icon_state = "vapour"
				if(SOLID)
					G.icon_state = "solid"
			G.name += " ([lowertext(href_list["name"])])"
			G.reagents.add_reagent(id,30)
			energy--
			src.updateUsrDialog()
			return
		else
			usr << browse(null, "window=chem_dispenser")
			return

		src.add_fingerprint(usr)
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src
		var/dat = ""
		for(var/re in dispensable_reagents)
			for(var/da in typesof(/datum/reagent) - /datum/reagent)
				var/datum/reagent/temp = new da()
				if(temp.id == re)
					dat += "<A href='?src=\ref[src];dispense=[temp.id];state=[temp.reagent_state];name=[temp.name]'>[temp.name]</A><BR>"
					dat += "[temp.description]<BR><BR>"
		user << browse("<TITLE>Chemical Dispenser</TITLE>Chemical dispenser:<BR>Energy = [energy]/[max_energy]<BR><BR>[dat]", "window=chem_dispenser")

		onclose(user, "chem_dispenser")
		return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master/
	name = "CheMaster 3000"
	density = 1
	anchored = 1
	icon = 'chemical.dmi'
	icon_state = "mixer0"
	var/beaker = null

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					del(src)
					return

	blob_act()
		if (prob(50))
			del(src)

	meteorhit()
		del(src)
		return

	attackby(var/obj/item/weapon/reagent_containers/glass/B as obj, var/mob/user as mob)
		if(!istype(B, /obj/item/weapon/reagent_containers/glass))
			return

		if(src.beaker)
			user << "A beaker is already loaded into the machine."
			return

		src.beaker =  B
		user.drop_item()
		B.loc = src
		user << "You add the beaker to the machine!"
		src.updateUsrDialog()
		icon_state = "mixer1"

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src
		if(!beaker) return
		var/datum/reagents/R = beaker:reagents

		if (href_list["isolate"])
			R.isolate_reagent(href_list["isolate"])
			src.updateUsrDialog()
			return
		else if (href_list["remove"])
			R.del_reagent(href_list["remove"])
			src.updateUsrDialog()
			return
		else if (href_list["remove5"])
			R.remove_reagent(href_list["remove5"], 5)
			src.updateUsrDialog()
			return
		else if (href_list["remove1"])
			R.remove_reagent(href_list["remove1"], 1)
			src.updateUsrDialog()
			return
		else if (href_list["analyze"])
			var/dat = "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=chem_master;size=575x400")
			return
		else if (href_list["main"])
			attack_hand(usr)
			return
		else if (href_list["eject"])
			beaker:loc = src.loc
			beaker = null
			icon_state = "mixer0"
			src.updateUsrDialog()
			return
		else if (href_list["createpill"])
			var/obj/item/weapon/reagent_containers/pill/P = new/obj/item/weapon/reagent_containers/pill(src.loc)
			var/name = input(usr,"Name:","Name your pill!",R.get_master_reagent_name())
			if(!name || name == " ") name = R.get_master_reagent_name()
			P.name = "[name] pill"
			R.trans_to(P,R.total_volume)
			src.updateUsrDialog()
			return
		else if (href_list["createbottle"])
			var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			var/name = input(usr,"Name:","Name your bottle!",R.get_master_reagent_name())
			if(!name || name == " ") name = R.get_master_reagent_name()
			P.name = "[name] bottle"
			R.trans_to(P,30)
			src.updateUsrDialog()
			return
		else
			usr << browse(null, "window=chem_master")
			return

		src.add_fingerprint(usr)
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src
		var/dat = ""
		if(!beaker)
			dat = "Please insert beaker.<BR>"
			dat += "<A href='?src=\ref[src];close=1'>Close</A>"
		else
			var/datum/reagents/R = beaker:reagents
			dat += "<A href='?src=\ref[src];eject=1'>Eject beaker</A><BR><BR>"
			if(!R.total_volume)
				dat += "Beaker is empty."
			else
				dat += "Contained reagents:<BR>"
				for(var/datum/reagent/G in R.reagent_list)
					dat += "[G.name] , [G.volume] Units - <A href='?src=\ref[src];isolate=[G.id]'>(Isolate)</A> <A href='?src=\ref[src];remove=[G.id]'>(Remove all)</A> <A href='?src=\ref[src];remove5=[G.id]'>(Remove 5)</A> <A href='?src=\ref[src];remove1=[G.id]'>(Remove 1)</A> <A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A><BR>"
				dat += "<BR><A href='?src=\ref[src];createpill=1'>Create pill</A><BR>"
				dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (30 units max)</A>"
		user << browse("<TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
		onclose(user, "chem_master")
		return





/obj/machinery/pandemic/
	name = "PanD.E.M.I.C 2200"
	density = 1
	anchored = 1
	icon = 'chemical.dmi'
	icon_state = "mixer0"
	var/temphtml = ""
	var/wait = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					del(src)
					return

	blob_act()
		if (prob(50))
			del(src)

	meteorhit()
		del(src)
		return

	power_change()
		if(powered())
			icon_state = (src.beaker?"mixer1":"mixer0")
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = (src.beaker?"mixer1_nopower":"mixer0_nopower")
				stat |= NOPOWER


	attackby(var/obj/item/weapon/reagent_containers/glass/B as obj, var/mob/user as mob)
		if(!istype(B, /obj/item/weapon/reagent_containers/glass))
			return

		if(src.beaker)
			user << "A beaker is already loaded into the machine."
			return

		src.beaker =  B
		user.drop_item()
		B.loc = src
		user << "You add the beaker to the machine!"
		src.updateUsrDialog()
		icon_state = "mixer1"

	Topic(href, href_list)
		if(stat & (NOPOWER|BROKEN)) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src
		if(!beaker) return

		if (href_list["create_vaccine"])
			if(!src.wait)
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
				var/vaccine_type = href_list["create_vaccine"]
				var/datum/disease/D = new vaccine_type
				var/name = input(usr,"Name:","Name the vaccine",D.name)
				if(!name || name == " ") name = D.name
				B.name = "[name] vaccine bottle"
				B.reagents.add_reagent("vaccine",10,vaccine_type)
				del(D)
				wait = 1
				spawn(1200)
					src.wait = null
			else
				src.temphtml = "The replicator is not ready yet."
			src.updateUsrDialog()
			return
		else if (href_list["create_virus_culture"])
			if(!wait)
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
				B.icon_state = "bottle3"
				var/type = href_list["create_virus_culture"]
				var/datum/disease/D = new type
				var/list/data = list("virus"=D)
				var/name = input(usr,"Name:","Name the culture",D.name)
				if(!name || name == " ") name = D.name
				B.name = "[name] culture bottle"
				B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
				B.reagents.add_reagent("blood",20,data)
				src.updateUsrDialog()
				wait = 1
				spawn(3000)
					src.wait = null
			else
				src.temphtml = "The replicator is not ready yet."
			src.updateUsrDialog()
			return
		else if (href_list["empty_beaker"])
			beaker.reagents.clear_reagents()
			src.updateUsrDialog()
			return
		else if (href_list["eject"])
			beaker:loc = src.loc
			beaker = null
			icon_state = "mixer0"
			src.updateUsrDialog()
			return
		else if(href_list["clear"])
			src.temphtml = ""
			src.updateUsrDialog()
			return
		else
			usr << browse(null, "window=pandemic")
			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & (NOPOWER|BROKEN))
			return
		user.machine = src
		var/dat = ""
		if(src.temphtml)
			dat = "[src.temphtml]<BR><BR><A href='?src=\ref[src];clear=1'>Main Menu</A>"
		else if(!beaker)
			dat += "Please insert beaker.<BR>"
			dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"
		else
			var/datum/reagents/R = beaker.reagents
			var/datum/reagent/blood/Blood = null
			for(var/datum/reagent/blood/B in R.reagent_list)
				if(B)
					Blood = B
					break
			if(!R.total_volume||!R.reagent_list.len)
				dat += "The beaker is empty<BR>"
			else if(!Blood)
				dat += "No blood sample found in beaker"
			else
				dat += "<h3>Blood sample data:</h3>"
				dat += "<b>Blood DNA:</b> [(Blood.data["blood_DNA"]||"none")]<BR>"
				dat += "<b>Blood Type:</b> [(Blood.data["blood_type"]||"none")]<BR>"
				var/datum/disease/D = Blood.data["virus"]
				dat += "<b>Agent of disease:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[D.type]'>Create virus culture bottle</A>":"none"]<BR>"
				dat += "<b>Contains antibodies to:</b> "
				if(Blood.data["resistances"])
					var/list/res = Blood.data["resistances"]
					if(res.len)
						dat += "<ul>"
						for(var/type in Blood.data["resistances"])
							var/datum/disease/DR = new type
							dat += "<li>[DR.name] - <A href='?src=\ref[src];create_vaccine=[type]'>Create vaccine bottle</A></li>"
							del(DR)
						dat += "</ul><BR>"
					else
						dat += "nothing<BR>"
				else
					dat += "nothing<BR>"
			dat += "<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]<BR>"
			dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"

		user << browse("<TITLE>PanD.E.M.I.C 2200</TITLE><BR>[dat]", "window=pandemic;size=575x400")
		onclose(user, "pandemic")
		return