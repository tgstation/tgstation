/mob/living
	var/list/alternate_screams

/mob/living/carbon/proc/reindex_screams()
	clear_screams()
	if(head)
		add_screams(head.alternate_screams)
	if(wear_mask)
		add_screams(wear_mask.alternate_screams)
	if(back)
		add_screams(back.alternate_screams)

/mob/living/carbon/human/reindex_screams()
	..()
	//More slots in humans.
	if(ears)
		add_screams(ears.alternate_screams)
	if(wear_suit)
		add_screams(wear_suit.alternate_screams)
	if(w_uniform)
		add_screams(w_uniform.alternate_screams)
	if(glasses)
		add_screams(glasses.alternate_screams)
	if(gloves)
		add_screams(gloves.alternate_screams)
	if(shoes)
		add_screams(shoes.alternate_screams)
	if(belt)
		add_screams(belt.alternate_screams)
	if(s_store)
		add_screams(s_store.alternate_screams)
	if(wear_id)
		add_screams(wear_id.alternate_screams)

//Note that the following two are for /mob/living, while the above two are for /carbon and /human
/mob/living/proc/add_screams(var/list/screams)
	LAZYINITLIST(alternate_screams)
	if(!screams || screams.len == 0)
		return
	for(var/S in screams)
		LAZYADD(alternate_screams, S)

/mob/living/proc/clear_screams()
	LAZYINITLIST(alternate_screams)
	LAZYCLEARLIST(alternate_screams)