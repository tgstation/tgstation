/mob/living/silicon/pai/binarycheck()
	if(radio)
		return (radio.special_channels & RADIO_SPECIAL_BINARY)
	return FALSE
