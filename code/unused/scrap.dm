// The scrap item
// a single object type represents all combinations of size and composition of scrap
//


/obj/item/scrap
	name = "scrap"
	icon = 'scrap.dmi'
	icon_state = "1metal0"
	item_state = "scrap-metal"
	desc = "A piece of scrap"
	var/classtext = ""
	throwforce = 14.0
	m_amt = 0
	g_amt = 0
	w_amt = 0
	var/size = 1		// 1=piece, 2= few pieces, 3=small pile, 4=large pile
	var/blood = 0		// 0=none, 1=blood-stained, 2=bloody

	throwforce = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 1
	flags = FPRINT | TABLEPASS | CONDUCT

#define MAX_SCRAP	15000	// maximum content amount of a scrap pile


/obj/item/scrap/New()
	src.verbs -= /atom/movable/verb/pull
	..()
	update()

// return a copy
/obj/item/scrap/proc/copy()
	var/obj/item/scrap/ret = new()
	ret.set_components(m_amt, g_amt, w_amt)
	return ret


// set the metal, glass and waste content
/obj/item/scrap/proc/set_components(var/m, var/g, var/w)
	m_amt = m
	g_amt = g
	w_amt = w
	update()

// returns the total amount of scrap in this pile
/obj/item/scrap/proc/total()
	return m_amt + g_amt + w_amt


// sets the size, appearance, and description of the scrap depending on component amounts
/obj/item/scrap/proc/update()
	var/total = total()


	// determine size of pile
	if(total<=400)
		size = 1
	else if(total<=1600)
		size = 2
	else
		size = 3

	w_class = size

	var/sizetext = ""

	switch(size)
		if(1)
			sizetext = "A piece of"
		if(2)
			sizetext = "A few pieces of"
		if(3)
			sizetext = "A pile of"

	// determine bloodiness
	var/bloodtext = ""
	switch(blood)
		if(0)
			bloodtext = ""
		if(1)
			bloodtext = "blood-stained "
		if(2)
			bloodtext = "bloody "


	// find mixture and composition
	var/class = 0		// 0 = mixed, 1=mostly. 2=pure
	var/major = "waste"		// the major component type

	var/max = 0

	if(m_amt > max)
		max = m_amt
	else if(g_amt > max)
		max = g_amt
	else if(w_amt > max)
		max = w_amt

	if(max == total)
		class = 2		// pure
	else if(max/total > 0.6)
		class = 1		// mostly
	else
		class = 0		// mixed

	if(class>0)
		var/remain = total - max
		if(m_amt > remain)
			major = "metal"
		else if(g_amt > remain)
			major = "glass"
		else
			major = "waste"


		if(class == 1)
			desc = "[sizetext] mostly [major] [bloodtext]scrap."
			classtext = "mostly [major] [bloodtext]"
		else
			desc = "[sizetext] [bloodtext][major] scrap."
			classtext = "[bloodtext][major] "
		icon_state = "[size][major][blood]"
	else
		desc = "[sizetext] [bloodtext]mixed scrap."
		classtext = "[bloodtext]mixed"
		icon_state = "[size]mixed[blood]"

	if(size==0)
		pixel_x = rand(-5,5)
		pixel_y = rand(-5,5)
	else
		pixel_x = 0
		pixel_y = 0

	// clear or set conduction flag depending on whether scrap is mostly metal
	if(major=="metal")
		flags |= CONDUCT
	else
		flags &= ~CONDUCT

	item_state = "scrap-[major]"

// add a scrap item to this one
// if the resulting pile is too big, transfer only what will fit
// otherwise add them and deleted the added pile

/obj/item/scrap/proc/add_scrap(var/obj/item/scrap/other, var/limit = MAX_SCRAP)
	var/total = total()
	var/other_total = other.total()

	if( (total + other_total) <= limit )
		m_amt += other.m_amt
		g_amt += other.g_amt
		w_amt += other.w_amt

		blood = (total*blood + other_total*other.blood) / (total + other_total)
		del(other)

	else
		var/space = limit - total

		var/m = round(other.m_amt/other_total*space, 1)
		var/g = round(other.g_amt/other_total*space, 1)
		var/w = round(other.w_amt/other_total*space, 1)

		m_amt += m
		g_amt += g
		w_amt += w

		other.m_amt -= m
		other.g_amt -= g
		other.w_amt -= w

		var/other_trans = m + g + w
		other.update()
		blood = (total*blood + other_trans*other.blood) / (total + other_trans)


	blood = round(blood,1)
	src.update()

// limit this pile to maximum size
// return any remainder as a new scrap item (or null if none)
// note return item is not necessarily smaller than max size

/obj/item/scrap/proc/remainder(var/limit = MAX_SCRAP)
	var/total = total()
	if(total > limit)
		var/m = round( m_amt/total * limit, 1)
		var/g = round( g_amt/total * limit, 1)
		var/w = round( w_amt/total * limit, 1)

		var/obj/item/scrap/S = new()
		S.set_components(m_amt - m,g_amt - g,w_amt - w)
		src.set_components(m,g,w)

		return S
	return null

// if other pile of scrap tries to enter the same turf, then add that pile to this one

/obj/item/scrap/CanPass(var/obj/item/scrap/O)

	if(istype(O))

		src.add_scrap(O)
		if(O)
			return 0		// O still exists if not all could be transfered, so block it
	return 1

/obj/item/scrap/proc/to_text()
	return "[m_amt],[g_amt],[w_amt] ([total()])"


// attack with hand removes a single piece from a pile
/obj/item/scrap/attack_hand(mob/user)
	add_fingerprint(user)
	if(src.is_single_piece())
		return ..(user)
	var/obj/item/scrap/S = src.get_single_piece()
	S.attack_hand(user)
	return


/obj/item/scrap/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/scrap))
		var/obj/item/scrap/S = I
		if( (S.total()+src.total() ) > MAX_SCRAP )
			user << "The pile is full."
			return
		if(ismob(src.loc))		// can't combine scrap in hand
			return

		src.add_scrap(S)

// when dropped, try to make a pile if scrap is already there
/obj/item/scrap/dropped()

	spawn(2)	// delay to allow drop postprocessing (since src may be destroyed)
		for(var/obj/item/scrap/S in oview(0,src))	// excludes src itself
			S.add_scrap(src)

// return true if this is a single piece of scrap
// must be total<=400 and of single composition
/obj/item/scrap/proc/is_single_piece()
	if(total() > 400)
		return 0

	var/empty = (m_amt == 0) + (g_amt == 0) + (w_amt == 0)

	return (empty==2)	// must be 2 components with zero amount


// get a single piece of scrap from a pile
/obj/item/scrap/proc/get_single_piece()

	var/obj/item/scrap/S = new()

	var/cmp = pick(m_amt;1 , g_amt;2, w_amt;3)

	var/amount = 400
	switch(cmp)
		if(1)
			if(m_amt < amount)
				amount = m_amt

			S.set_components(amount, 0, 0)
			src.set_components(m_amt - amount, g_amt, w_amt)

		if(2)
			if(g_amt < amount)
				amount = g_amt
			S.set_components(0, amount, 0)
			src.set_components(m_amt, g_amt - amount, w_amt)

		if(3)
			if(w_amt < amount)
				amount = w_amt
			S.set_components(0, 0, amount)
			src.set_components(m_amt, g_amt, w_amt - amount)


	return S


