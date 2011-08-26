/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	var
		list/icon/current = list() //the current hud icons
	proc
		process_hud(var/mob/M)	return



/obj/item/clothing/glasses/hud/health
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"




/obj/item/clothing/glasses/hud/security
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	icon_state = "securityhud"

	process_hud(var/mob/M)
		if(!M)	return
		if(!M.client)	return
		var/client/C = M.client
		var/icon/tempHud = 'hud.dmi'
		for(var/mob/living/carbon/human/perp in view(M))
			if(perp.wear_id)
				C.images += image(tempHud,perp,"hud[ckey(perp:wear_id:GetJobName())]")
				var/perpname = "wot"
				if(istype(perp.wear_id,/obj/item/weapon/card/id))
					perpname = perp.wear_id:registered
				else if(istype(perp.wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = perp.wear_id
					perpname = tempPda.owner
				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if ((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
								C.images += image(tempHud,perp,"hudwanted")
								break
							else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
								C.images += image(tempHud,perp,"hudprisoner")
								break
			else
				C.images += image(tempHud,perp,"hudunknown")
			for(var/obj/item/weapon/implant/I in perp)
				if(I.implanted)
					if(istype(I,/obj/item/weapon/implant/tracking))
						C.images += image(tempHud,perp,"hud_imp_tracking")
					if(istype(I,/obj/item/weapon/implant/loyalty))
						C.images += image(tempHud,perp,"hud_imp_loyal")

