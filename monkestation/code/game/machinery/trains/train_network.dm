/datum/train_network
	var/obj/vehicle/ridden/cargo_train/train_head
	var/list/obj/machinery/cart/members = list()
	var/obj/machinery/cart/end_cart


/datum/train_network/Destroy()
	. = ..()
	train_head.listed_network = null
	for(var/obj/machinery/cart/member in members)
		member.linked_network = null

/datum/train_network/proc/connect_train(obj/machinery/cart/connecting_train, mob/user)
	if(connecting_train.linked_network)
		merge_networks(connecting_train.linked_network, connecting_train)
		return
	connecting_train.linked_network = src
	connecting_train.anchored = TRUE
	members += connecting_train
	end_cart = connecting_train

/datum/train_network/proc/disconnect_train(obj/machinery/cart/disconnecting_train, mob/user)
	if(end_cart == disconnecting_train)
		end_cart = null
		members -= disconnecting_train
		disconnecting_train.linked_network = null
		disconnecting_train.anchored = FALSE
		return

	var/list/disconnected_parts = list()
	for(var/obj/machinery/cart/listed_cart in members)
		if(listed_cart == disconnecting_train)
			break
		disconnected_parts += listed_cart

	members -= disconnected_parts
	make_new_group(train_head, disconnected_parts)
	train_head = null

/datum/train_network/proc/make_new_group(obj/vehicle/ridden/cargo_train/new_head, list/new_members)
	var/datum/train_network/new_group = new
	new_group.train_head = new_head
	new_head.listed_network = new_group
	for(var/obj/machinery/cart/new_member in new_members)
		new_member.linked_network = null
		new_group.connect_train(new_member)

/datum/train_network/proc/relay_move(oldloc)
	for(var/obj/machinery/cart/member in members)
		var/turf/next_turf = member.loc
		member.Move(oldloc, get_dir(member, oldloc), glide_size_override = train_head.glide_size)
		if(member.attached_object)
			member.attached_object.Move(oldloc, get_dir(member, oldloc), glide_size_override = train_head.glide_size)
		oldloc = next_turf

/datum/train_network/proc/merge_networks(datum/train_network/incoming_network, obj/machinery/cart/incoming_cart)
	if(incoming_network.train_head)
		return
	if(incoming_cart in members)
		return

	for(var/obj/machinery/cart/listed_cart in incoming_network.members)
		listed_cart.linked_network = src
		members += listed_cart
		end_cart = listed_cart
	qdel(incoming_network)
