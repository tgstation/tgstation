#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_dispenser/
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'chemical.dmi'
	icon_state = "dispenser"
	use_power = 1
	idle_power_usage = 40
	var/energy = 25
	var/max_energy = 75
	var/amount = 30
	var/beaker = null
	var/list/dispensable_reagents = list("hydrogen","lithium","carbon","nitrogen","oxygen","fluorine","sodium","aluminum","silicon","phosphorus","sulfur","chlorine","potassium","iron","copper","mercury","tungsten","radium","water","ethanol","sugar","acid","milk",)
	var/charging_reagents = 0

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

	proc/updateWindow(mob/user as mob)
		winset(user, "chemdispenser.energy", "text=\"Energy: [round(src.energy)]\"")
		winset(user, "chemdispenser.amount", "text=\"Amount: [src.amount]\"")
		if (beaker)
			winset(user, "chemdispenser.eject", "text=\"Eject beaker\"")
		else
			winset(user, "chemdispenser.eject", "text=\"\[Insert beaker\]\"")
		if(charging_reagents)
			winset(user, "chemdispenser.charging", "text=\"Charging\"")
		else
			winset(user, "chemdispenser.charging", "text=\"Not Charging\"")
	proc/initWindow(mob/user as mob)
		var/i = 0
		var list/nameparams = params2list(winget(user, "chemdispenser_reagents.template_name", "pos;size;type;image;image-mode"))
		var list/buttonparams = params2list(winget(user, "chemdispenser_reagents.template_dispense", "pos;size;type;image;image-mode;text;is-flat"))
		for(var/re in dispensable_reagents)
			for(var/da in typesof(/datum/reagent) - /datum/reagent)
				var/datum/reagent/temp = new da()
				if(temp.id == re)
					var list/newparams1 = nameparams.Copy()
					var list/newparams2 = buttonparams.Copy()
					var/posy = 8 + 40 * i
					newparams1["pos"] = text("8,[posy]")
					newparams2["pos"] = text("248,[posy]")
					newparams1["parent"] = "chemdispenser_reagents"
					newparams2["parent"] = "chemdispenser_reagents"
					newparams1["text"] = temp.name
					newparams2["command"] = text("skincmd \"chemdispenser;[temp.id]\"")
					winset(user, "chemdispenser_reagent_name[i]", list2params(newparams1))
					winset(user, "chemdispenser_reagent_dispense[i]", list2params(newparams2))
					i++
		winset(user, "chemdispenser_reagents", "size=340x[8 + 40 * i]")

	SkinCmd(mob/user as mob, var/data as text)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src

		if (data == "amountc")
			var/num = text2num(input("Enter desired output amount", "Amount", "30"))
			if (num)
				amount = text2num(num)
		else if (data == "eject")
			if (src.beaker)
				var/obj/item/weapon/reagent_containers/glass/B = src.beaker
				B.loc = src.loc
				src.beaker = null
		else if (data == "tcharge")
			src.charging_reagents = !src.charging_reagents
		else if (copytext(data, 1, 7) == "amount")
			if (text2num(copytext(data, 7)))
				amount = text2num(copytext(data, 7))
		else
			if (dispensable_reagents.Find(data) && beaker != null)
				var/obj/item/weapon/reagent_containers/glass/B = src.beaker
				var/datum/reagents/R = B.reagents
				var/space = R.maximum_volume - R.total_volume
				R.add_reagent(data, min(amount, round(energy) * 10, space))
				energy = max(energy - min(amount, space) / 10, 0)

		amount = round(amount, 10) // Chem dispenser doesnt really have that much prescion
		if (amount < 0) // Since the user can actually type the commands himself, some sanity checking
			amount = 0
		if (amount > 100)
			amount = 100

		for(var/mob/player)
			if (player.machine == src && player.client)
				updateWindow(player)

		src.add_fingerprint(usr)
		return

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (istype(W,/obj/item/weapon/vending_charge/chemistry))
			var/obj/item/weapon/vending_charge/chemistry/C = W
			energy += C.charge_amt
			del(C)
			user << "You load the charge into the machine."
			return

		if(!istype(W, /obj/item/weapon/reagent_containers/glass))
			return

		var/obj/item/weapon/reagent_containers/glass/B = W

		if(src.beaker)
			user << "A beaker is already loaded into the machine."
			return

		src.beaker =  B
		user.drop_item()
		B.loc = src
		user << "You add the beaker to the machine!"
		for(var/mob/player)
			if (player.machine == src && player.client)
				updateWindow(player)

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src

		initWindow(user)
		updateWindow(user)
		winshow(user, "chemdispenser", 1)
		user.skincmds["chemdispenser"] = src
		return


/obj/machinery/chem_dispenser/process()
	if(stat & NOPOWER) return
	if(!charging_reagents || src.energy > 30) return

	use_power(10000)
	src.energy += 0.05

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master/
	name = "ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'chemical.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	var/beaker = null
	var/mode = 0
	var/condi = 0
	var/bottlesprite = "1" //yes, strings
	var/pillsprite = "1"
	var/client/has_sprites = list()

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src

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
		if(!istype(B, /obj/item/weapon/reagent_containers/glass) && !istype(B,/obj/item/weapon/reagent_containers/syringe))
			return

		if(src.beaker)
			if(istype(beaker,/obj/item/weapon/reagent_containers/syringe))
				user << "A syringe is already loaded into the machine."
			else
				user << "A beaker is already loaded into the machine."
			return

		src.beaker =  B
		user.drop_item()
		B.loc = src
		if(istype(B,/obj/item/weapon/reagent_containers/syringe))
			user << "You add the syringe to the machine!"
			src.updateUsrDialog()
			icon_state = "mixers"
		else
			user << "You add the beaker to the machine!"
			src.updateUsrDialog()
			icon_state = "mixer1"

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		src.add_fingerprint(usr)
		usr.machine = src
		if(!beaker) return
		var/datum/reagents/R = beaker:reagents

		if (href_list["analyze"])
			var/dat = ""
			if(!condi)
				if(href_list["name"] == "Blood")
					var/datum/reagent/blood/G
					for(var/datum/reagent/F in R.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "<TITLE>Condimaster 3000</TITLE>Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=chem_master;size=575x400")
			return
		else if (href_list["add1"])
			R.remove_reagent(href_list["add1"], 1) //Remove/add used instead of trans_to since we're moving a specific reagent.
			reagents.add_reagent(href_list["add1"], 1)
		else if (href_list["add5"])
			R.remove_reagent(href_list["add5"], 5)
			reagents.add_reagent(href_list["add5"], 5)
		else if (href_list["add10"])
			R.remove_reagent(href_list["add10"], 10)
			reagents.add_reagent(href_list["add10"], 10)
		else if (href_list["addall"])
			var/temp_amt = R.get_reagent_amount(href_list["addall"])
			reagents.add_reagent(href_list["addall"], temp_amt)
			R.del_reagent(href_list["addall"])
		else if (href_list["remove1"])
			reagents.remove_reagent(href_list["remove1"], 1)
			if(mode) R.add_reagent(href_list["remove1"], 1)
		else if (href_list["remove5"])
			reagents.remove_reagent(href_list["remove5"], 5)
			if(mode) R.add_reagent(href_list["remove5"], 5)
		else if (href_list["remove10"])
			reagents.remove_reagent(href_list["remove10"], 10)
			if(mode) R.add_reagent(href_list["remove10"], 10)
		else if (href_list["removeall"])
			if(mode)
				var/temp_amt = reagents.get_reagent_amount(href_list["removeall"])
				R.add_reagent(href_list["removeall"], temp_amt)
			reagents.del_reagent(href_list["removeall"])
		else if (href_list["toggle"])
			if(mode)
				mode = 0
			else
				mode = 1
		else if (href_list["main"])
			attack_hand(usr)
			return
		else if (href_list["eject"])
			beaker:loc = src.loc
			beaker = null
			reagents.clear_reagents()
			icon_state = "mixer0"
		else if (href_list["createpill"])
			var/name = reject_bad_text(input(usr,"Name:","Name your pill!",reagents.get_master_reagent_name()))
			var/obj/item/weapon/reagent_containers/pill/P = new/obj/item/weapon/reagent_containers/pill(src.loc)
			if(!name) name = reagents.get_master_reagent_name()
			P.name = "[name] pill"
			P.pixel_x = rand(-7, 7) //random position
			P.pixel_y = rand(-7, 7)
			P.icon_state = "pill"+pillsprite
			reagents.trans_to(P,50)
		else if (href_list["createbottle"])
			if(!condi)
				var/name = reject_bad_text(input(usr,"Name:","Name your bottle!",reagents.get_master_reagent_name()))
				var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "bottle"+bottlesprite
				reagents.trans_to(P,30)
			else
				var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
				reagents.trans_to(P,50)
		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		else if(href_list["change_bottle"])
			#define MAX_BOTTLE_SPRITE 20 //max icon state of the bottle sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&bottle_sprite=[i]\"><img src=\"bottle[i].png\" /></a></td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]
		else
			usr << browse(null, "window=chem_master")
		src.updateUsrDialog()
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			spawn()
			if(!(user.client in has_sprites))	//yes, it's in three places, so they get downloaded even when they arent going to be shown, because they could be in the future
				spawn()
					has_sprites += user.client
					for(var/i = 1 to MAX_PILL_SPRITE)
						usr << browse_rsc(icon('chemical.dmi', "pill" + num2text(i)), "pill[i].png")
					for(var/i = 1 to MAX_BOTTLE_SPRITE)
						usr << browse_rsc(icon('chemical.dmi', "bottle" + num2text(i)), "bottle[i].png")
			return
		user.machine = src
		var/dat = ""
		if(!beaker)
			dat = "Please insert beaker.<BR>"
			dat += "<A href='?src=\ref[src];close=1'>Close</A>"
			if(!(user.client in has_sprites))
				spawn()
					has_sprites += user.client
					for(var/i = 1 to MAX_PILL_SPRITE)
						usr << browse_rsc(icon('chemical.dmi', "pill" + num2text(i)), "pill[i].png")
					for(var/i = 1 to MAX_BOTTLE_SPRITE)
						usr << browse_rsc(icon('chemical.dmi', "bottle" + num2text(i)), "bottle[i].png")
		else
			if(!(user.client in has_sprites))
				has_sprites += user.client
				for(var/i = 1 to MAX_PILL_SPRITE)
					usr << browse_rsc(icon('chemical.dmi', "pill" + num2text(i)), "pill[i].png")
				for(var/i = 1 to MAX_BOTTLE_SPRITE)
					usr << browse_rsc(icon('chemical.dmi', "bottle" + num2text(i)), "bottle[i].png")
			var/datum/reagents/R = beaker:reagents
			dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR><BR>"
			if(!R.total_volume)
				dat += "Beaker is empty."
			else
				dat += "Add to buffer:<BR>"
				for(var/datum/reagent/G in R.reagent_list)
					dat += "[G.name] , [G.volume] Units - "
					dat += "<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name];reagent=[G]'>(Analyze)</A> "
					dat += "<A href='?src=\ref[src];add1=[G.id]'>(1)</A> "
					if(G.volume >= 5) dat += "<A href='?src=\ref[src];add5=[G.id]'>(5)</A> "
					if(G.volume >= 10) dat += "<A href='?src=\ref[src];add10=[G.id]'>(10)</A> "
					dat += "<A href='?src=\ref[src];addall=[G.id]'>(All)</A><BR>"
			if(!mode)
				dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>disposal:</A><BR>"
			else
				dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>beaker:</A><BR>"
			if(reagents.total_volume)
				for(var/datum/reagent/N in reagents.reagent_list)
					dat += "[N.name] , [N.volume] Units - "
					dat += "<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A> "
					dat += "<A href='?src=\ref[src];remove1=[N.id]'>(1)</A> "
					if(N.volume >= 5) dat += "<A href='?src=\ref[src];remove5=[N.id]'>(5)</A> "
					if(N.volume >= 10) dat += "<A href='?src=\ref[src];remove10=[N.id]'>(10)</A> "
					dat += "<A href='?src=\ref[src];removeall=[N.id]'>(All)</A><BR>"
			else
				dat += "Empty<BR>"
			if(!condi)
				dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pill (50 units max)</A><a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"
				dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (30 units max)</A><a href=\"?src=\ref[src]&change_bottle=1\"><img src=\"bottle[bottlesprite].png\" /></a>"
			else
				dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
		if(!condi)
			user << browse("<TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
		else
			user << browse("<TITLE>Condimaster 3000</TITLE>Condimaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
		onclose(user, "chem_master")
		return


/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	condi = 1

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	density = 1
	anchored = 1
	icon = 'chemical.dmi'
	icon_state = "mixer0"
	var/temphtml = ""
	var/wait = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null


	set_broken()
		icon_state = (src.beaker?"mixer1_b":"mixer0_b")
		stat |= BROKEN


	power_change()

		if(stat & BROKEN)
			icon_state = (src.beaker?"mixer1_b":"mixer0_b")

		else if(powered())
			icon_state = (src.beaker?"mixer1":"mixer0")
			stat &= ~NOPOWER

		else
			spawn(rand(0, 15))
				src.icon_state = (src.beaker?"mixer1_nopower":"mixer0_nopower")
				stat |= NOPOWER


	Topic(href, href_list)
		if(stat & (NOPOWER|BROKEN)) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src
		if(!beaker) return

		if (href_list["create_vaccine"])
			if(!src.wait)
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
				if(B)
					var/vaccine_type = text2path(href_list["create_vaccine"])//the path is received as string - converting
					var/datum/disease/D = new vaccine_type
					if(D)
						B.name = "[D.name] vaccine bottle"
						B.reagents.add_reagent("vaccine",15,vaccine_type)
						del(D)
						wait = 1
						var/datum/reagents/R = beaker.reagents
						var/datum/reagent/blood/Blood = null
						for(var/datum/reagent/blood/L in R.reagent_list)
							if(L)
								Blood = L
								break
						var/list/res = Blood.data["resistances"]
						spawn(res.len*500)
							src.wait = null
			else
				src.temphtml = "The replicator is not ready yet."
			src.updateUsrDialog()
			return
		else if (href_list["create_virus_culture"])
			if(!wait)
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
				B.icon_state = "bottle3"
				var/type = text2path(href_list["create_virus_culture"])//the path is received as string - converting
				var/datum/disease/D = new type
				var/list/data = list("viruses"=list(D))
				var/name = sanitize(input(usr,"Name:","Name the culture",D.name))
				if(!name || name == " ") name = D.name
				B.name = "[name] culture bottle"
				B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
				B.reagents.add_reagent("blood",20,data)
				src.updateUsrDialog()
				wait = 1
				spawn(2000)
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


				if(Blood.data["viruses"])
					var/list/vir = Blood.data["viruses"]
					if(vir.len)
						for(var/datum/disease/D in Blood.data["viruses"])
							if(!D.hidden[PANDEMIC])

								dat += "<b>Disease Agent:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[D.type]'>Create virus culture bottle</A>":"none"]<BR>"
								dat += "<b>Common name:</b> [(D.name||"none")]<BR>"
								dat += "<b>Description: </b> [(D.desc||"none")]<BR>"
								dat += "<b>Possible cure:</b> [(D.cure||"none")]<BR><BR>"

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

		user << browse("<TITLE>[src.name]</TITLE><BR>[dat]", "window=pandemic;size=575x400")
		onclose(user, "pandemic")
		return

	attackby(var/obj/I as obj, var/mob/user as mob)
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe(src.loc)
					new /obj/item/weapon/shard(src.loc)
					var/obj/item/weapon/circuitboard/pandemic/M = new /obj/item/weapon/circuitboard/pandemic(A)
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					var/obj/item/weapon/circuitboard/pandemic/M = new /obj/item/weapon/circuitboard/pandemic(A)
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)
		else if(istype(I, /obj/item/weapon/reagent_containers/glass))
			if(stat & (NOPOWER|BROKEN)) return
			if(src.beaker)
				user << "A beaker is already loaded into the machine."
				return

			src.beaker =  I
			user.drop_item()
			I.loc = src
			user << "You add the beaker to the machine!"
			src.updateUsrDialog()
			icon_state = "mixer1"

		else
			..()
		return
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/reagentgrinder
	name = "Reagent Grinder"
	icon = 'kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/obj/item/weapon/reagent_containers/beaker = null
	var/global/list/allowed_items = list ( // reagent = amount, amount of 0 indicate to determine the amount from the reagents list, only implemented on plants for now
		/obj/item/stack/sheet/plasma = list("plasma" = 20),
		/obj/item/stack/sheet/uranium = list("uranium" = 20),
		/obj/item/stack/sheet/clown = list("banana" = 20),
		/obj/item/stack/sheet/silver = list("silver" = 20),
		/obj/item/stack/sheet/gold = list("gold" = 20),
/*
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list("imidazoline" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap = list("psilocybin" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita = list("amatoxin" = 0, "psilocybin" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel = list("amatoxin" = 0, "psilocybin" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili = list("capsaicin" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper = list("frostoil" = 0),
*/
		/obj/item/weapon/grown/nettle = list("acid" = 0),
		/obj/item/weapon/grown/deathnettle = list("pacid" = 0),
	)

/obj/machinery/reagentgrinder/New()
	..()
	beaker = new /obj/item/weapon/reagent_containers/glass/large(src)
	return

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return


/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass))
		if (beaker)
			return 1
		else
			src.beaker =  O
			user.drop_item()
			O.loc = src
			src.verbs += /obj/machinery/reagentgrinder/verb/detach
			update_icon()
			src.updateUsrDialog()
			return 0
	if (!is_type_in_list(O, allowed_items))
		user << "Cannot refine into a reagent."
		return 1
	user.before_take_item(O)
	O.loc = src
	src.updateUsrDialog()
	return 0

/obj/machinery/reagentgrinder/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user as mob)
	user.machine = src
	interact(user)

/obj/machinery/reagentgrinder/proc/interact(mob/user as mob) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""

	for (var/i in allowed_items)
		for (var/obj/item/O in src.contents)
			if (!istype(O,i))
				continue
			processing_chamber+= "some <B>[O]</B><BR>"
			break
	if (!processing_chamber)
		is_chamber_empty = 1
		processing_chamber = "Nothing."
	if (!beaker)
		beaker_contents = "\The [src] has no beaker attached."
	else if (!beaker.reagents.total_volume)
		beaker_contents = "\The [src]  has attached an empty beaker."
		is_beaker_ready = 1
	else if (beaker.reagents.total_volume < beaker.reagents.maximum_volume)
		beaker_contents = "\The [src]  has attached a beaker with something."
		is_beaker_ready = 1
	else
		beaker_contents = "\The [src]  has attached a beaker and the beaker is full!"

	var/dat = {"
<b>Processing chamber contains:</b><br>
[processing_chamber]<br>
[beaker_contents]<hr>
"}
	if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
		dat += "<A href='?src=\ref[src];action=grind'>Turn on!<BR>"
	if (beaker)
		dat += "<A href='?src=\ref[src];action=detach'>Detach a beaker!<BR>"
	user << browse("<HEAD><TITLE>Reagent Grinder</TITLE></HEAD><TT>[dat]</TT>", "window=reagentgrinder")
	onclose(user, "reagentgrinder")
	return


/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	switch(href_list["action"])
		if ("grind")
			grind()

		if ("detach")
			detach()
	src.updateUsrDialog()
	return

/obj/machinery/reagentgrinder/verb/detach()
	set category = "Object"
	set name = "Detach Beaker from the grinder"
	set src in oview(1)
	if (usr.stat != 0)
		return
	if (!beaker)
		return
	src.verbs -= /obj/machinery/reagentgrinder/verb/detach
	beaker.loc = src.loc
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(var/obj/item/weapon/grown/O)
	for (var/i in allowed_items)
		if (istype(O, i))
			return allowed_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(var/obj/item/weapon/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_grind_id(var/obj/item/stack/sheet/O)
	for (var/i in allowed_items)
		if (istype(O, i))
			return allowed_items[i]

/obj/machinery/reagentgrinder/proc/get_grind_amount(var/obj/item/stack/sheet/O)
	return 20

/obj/machinery/reagentgrinder/proc/grind()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		return
	playsound(src.loc, 'juicer.ogg', 20, 1)
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in src.contents)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if (amount == 0)
				if (O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
			else
				beaker.reagents.add_reagent(r_id,min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		del(O)
	for (var/obj/item/stack/sheet/O in src.contents)
		var/allowed = get_allowed_by_id(O)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		for(var/i = 1; i <= round(O.amount, 1); i++)
			for (var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				beaker.reagents.add_reagent(r_id,min(amount, space))
				if (space < amount)
					break
			if (i == round(O.amount, 1))
				del(O)
				break
	for (var/obj/item/weapon/grown/O in src.contents)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if (amount == 0)
				if (O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
			else
				beaker.reagents.add_reagent(r_id,min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		del(O)