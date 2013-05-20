/mob/living/silicon/pai/whisper(message as text)
	var/mob/holder = get(src.card.loc,/mob/living)
	var/Q = say_quote(message)
	var/list/L = list(message=message,held_by=holder,quote=Q) //pass along the card's loc until pai.loc is fixed
	..(arglist(L))