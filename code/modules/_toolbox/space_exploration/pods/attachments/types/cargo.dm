/obj/item/pod_attachment

	cargo/
		name = "pod cargo hold"
		hardpoint_slot = P_HARDPOINT_CARGO_HOLD
		active = P_ATTACHMENT_PASSIVE

		var/capacity = 0
		var/accept_items = 1
		var/max_w_class = 3
		var/list/can_hold = list()

		GetAvailableKeybinds()
			return list()

		GetAdditionalMenuData()
			var/dat = "Storage Capacity: [capacity].<br>"
			dat += "Accept Items: <a href='?src=\ref[src];action=toggle_accept'>[accept_items ? "On" : "Off"]</a><br>"
			if(length(contents))
				dat += "<a href='?src=\ref[src];action=unload_everything'>Unload everything</a><br>"
				dat += "Contents: (click to unload)<ol>"
				for(var/obj/item/I in src)
					dat += "<li><a href='?src=\ref[src];action=unload;item=\ref[I]'>[I.name]</a></li>"
				dat += "</ol>"
			else
				dat += "Storage empty."
			return dat

		Topic(href, href_list)
			..()

			if(href_list["action"] == "unload")
				var/obj/item/I = locate(href_list["item"])
				to_chat(usr,"<span class='info'>You unload the [I]</span>")
				I.loc = get_turf(usr)

			else if(href_list["action"] == "toggle_accept")
				accept_items = !accept_items
				to_chat(usr,"<span class='info'>[accept_items ? "Now" : "No longer"] accepting items.</span>")

			else if(href_list["action"] == "unload_everything")
				for(var/obj/O in contents)
					O.loc = get_turf(src)

		PodAttackbyAction(var/obj/item/I, var/mob/living/user)
			if(user.a_intent != "harm")
				if(HasRoom())
					user.doUnEquip(I)
					var/result = PlaceInto(I)
					if(result == P_CARGOERROR_CLEAR)
						to_chat(user,"<span class='info'>You place the [I] into the [src] of the [attached_to].</span>")
					else
						user.put_in_active_hand(I)
						to_chat(user,"<span class='warning'>[TranslateError(result)].</span>")

					return 1

		proc/HasRoom()
			if(!accept_items)
				return 0
			return length(contents) < capacity

		proc/PlaceInto(var/obj/item/I, var/force = 0)
			if(!accept_items)
				return P_CARGOERROR_NA

			if(I.w_class > max_w_class)
				return P_CARGOERROR_TOOBIG

			if((contents.len >= capacity) && !force)
				return P_CARGOERROR_FULL

			var/_can_hold = 0
			if(!length(can_hold))
				_can_hold = 1
			else
				for(var/type in can_hold)
					if(istype(I, type))
						_can_hold = 1
						break

			if(!_can_hold)
				return P_CARGOERROR_CANTHOLD

			// Add to stack instead of filling a slot.
			if(istype(I, /obj/item/stack))
				var/obj/item/stack/stack = I
				var/obj/item/stack/same = GetObjectFromType(I.type, 1)
				if(same)
					if((same.amount + stack.amount) <= same.max_amount)
						same.amount += stack.amount
						qdel(I)
						return P_CARGOERROR_CLEAR

			I.Move(src)

			return P_CARGOERROR_CLEAR

		proc/GetObjectFromType(var/path, var/strict = 1)
			if(istext(path))
				path = text2path(path)

			for(var/atom/A in contents)
				if(!strict)
					if(istype(A, path))
						return A
				else
					if(A.type == path)
						return A

			return 0

		proc/GetListFromType(var/path, var/strict = 1)
			if(istext(path))
				path = text2path(path)

			var/list/items = list()
			for(var/atom/A in contents)
				if(!strict)
					if(istype(A, path))
						items += A
				else
					if(A.type == path)
						items += A

			return items

		proc/TranslateError(var/bf)
			switch(bf)
				if(P_CARGOERROR_TOOBIG)
					return "\The Item is too big"
				if(P_CARGOERROR_FULL)
					return "\The [src] is full"
				if(P_CARGOERROR_NA)
					return "\The [src] is currently not accepting items"
				if(P_CARGOERROR_CANTHOLD)
					return "\The [src] can't hold that item"

		small/
			name = "small cargo hold"
			capacity = 10
			construction_cost = list("metal" = 1000)
			//origin_tech = "engineering=1;materials=1"

		medium/
			name = "medium cargo hold"
			capacity = 25
			max_w_class = 4
			minimum_pod_size = list(2, 2)
			construction_cost = list("metal" = 2000)
			//origin_tech = "engineering=2;materials=2"

		large/
			name = "large cargo hold"
			capacity = 50
			max_w_class = 4
			minimum_pod_size = list(2, 2)
			construction_cost = list("metal" = 4000)
			//origin_tech = "engineering=4;materials=4"

		industrial/
			name = "industrial cargo hold"
			desc = "Only holds ores."
			capacity = 200
			max_w_class = 4
			minimum_pod_size = list(2, 2)
			construction_cost = list("metal" = 2000)
			//origin_tech = "engineering=1;materials=1"
			can_hold = list(/obj/item/stack/ore)
