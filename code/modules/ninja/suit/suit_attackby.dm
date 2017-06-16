

/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/U, params)
	if(U==affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.

		if(istype(I, /obj/item/weapon/reagent_containers/glass))//If it's a glass beaker.
			var/total_reagent_transfer//Keep track of this stuff.
			for(var/reagent_id in reagent_list)
				var/datum/reagent/R = I.reagents.has_reagent(reagent_id)//Mostly to pull up the name of the reagent after calculating. Also easier to use than writing long proc paths.
				if(R&&reagents.get_reagent_amount(reagent_id)<r_maxamount+(reagent_id == "radium"?(a_boost*a_transfer):0)&&R.volume>=a_transfer)//Radium is always special.
					//Here we determine how much reagent will actually transfer if there is enough to transfer or there is a need of transfer. Minimum of max amount available (using a_transfer) or amount needed.
					var/amount_to_transfer = min( (r_maxamount+(reagent_id == "radium"?(a_boost*a_transfer):0)-reagents.get_reagent_amount(reagent_id)) ,(round(R.volume/a_transfer))*a_transfer)//In the end here, we round the amount available, then multiply it again.
					R.volume -= amount_to_transfer//Remove from reagent volume. Don't want to delete the reagent now since we need to perserve the name.
					reagents.add_reagent(reagent_id, amount_to_transfer)//Add to suit. Reactions are not important.
					total_reagent_transfer += amount_to_transfer//Add to total reagent trans.
					to_chat(U, "Added [amount_to_transfer] units of [R.name].")
					I.reagents.update_total()//Now we manually update the total to make sure everything is properly shoved under the rug.

			to_chat(U, "Replenished a total of [total_reagent_transfer ? total_reagent_transfer : "zero"] chemical units.")
			return

		else if(istype(I, /obj/item/weapon/stock_parts/cell))
			var/obj/item/weapon/stock_parts/cell/CELL = I
			if(CELL.maxcharge > cell.maxcharge && n_gloves && n_gloves.candrain)
				to_chat(U, "<span class='notice'>Higher maximum capacity detected.\nUpgrading...</span>")
				if (n_gloves && n_gloves.candrain && do_after(U,s_delay, target = src))
					U.drop_item()
					CELL.loc = src
					CELL.charge = min(CELL.charge+cell.charge, CELL.maxcharge)
					var/obj/item/weapon/stock_parts/cell/old_cell = cell
					old_cell.charge = 0
					U.put_in_hands(old_cell)
					old_cell.add_fingerprint(U)
					old_cell.corrupt()
					old_cell.update_icon()
					cell = CELL
					to_chat(U, "<span class='notice'>Upgrade complete. Maximum capacity: <b>[round(cell.maxcharge/100)]</b>%</span>")
				else
					to_chat(U, "<span class='danger'>Procedure interrupted. Protocol terminated.</span>")
			return

		else if(istype(I, /obj/item/weapon/disk/tech_disk))//If it's a data disk, we want to copy the research on to the suit.
			var/obj/item/weapon/disk/tech_disk/TD = I
			var/has_research = 0
			for(var/V in  TD.tech_stored)
				if(V)
					has_research = 1
					break
			if(has_research)//If it has something on it.
				to_chat(U, "Research information detected, processing...")
				if(do_after(U,s_delay, target = src))
					for(var/V1 in 1 to TD.max_tech_stored)
						var/datum/tech/new_data = TD.tech_stored[V1]
						TD.tech_stored[V1] = null
						if(!new_data)
							continue
						for(var/V2 in stored_research)
							var/datum/tech/current_data = V2
							if(current_data.id == new_data.id)
								current_data.level = max(current_data.level, new_data.level)
								break
					to_chat(U, "<span class='notice'>Data analyzed and updated. Disk erased.</span>")
				else
					to_chat(U, "<span class='userdanger'>ERROR</span>: Procedure interrupted. Process terminated.")
			else
				I.loc = src
				t_disk = I
				to_chat(U, "<span class='notice'>You slot \the [I] into \the [src].</span>")
			return
	..()