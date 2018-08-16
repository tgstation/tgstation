GLOBAL_VAR_INIT(terrorism, FALSE)
/client/proc/ak47s() // For when you just can't summon guns worthy of a firefight
	if(!SSticker.HasRoundStarted())
		alert("The game hasn't started yet!")
		return
	GLOB.terrorism = TRUE

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		H.make_terrorism()

	send_to_playing_players("<span class='boldannounce'><font size=6>MOTHER RUSSIA ARMS THE MOB!</font></span>")

/mob/living/carbon/human/proc/make_terrorism()
	for(var/obj/item/I in held_items)
		qdel(I)
	var/obj/item/gun/energy/laser/LaserAK/AK = new(src)
	if(!GLOB.terrorism)
		AK.flags_1 |= ADMIN_SPAWNED_1 //To prevent announcing
	put_in_hands(AK)
	AK.pickup(src) //For the stun shielding
