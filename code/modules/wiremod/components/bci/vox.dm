/**
 * # VOX Announcement Components
 *
 * These play a VOX announcement with inputed words from either a string or a list.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/list_vox
	display_name = "List VOX Announcement"
	desc = "A component that plays a local VOX Announcement for the user. Requires a BCI shell."
	category = "BCI"

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/input/word_list

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/obj/item/organ/cyberimp/bci/bci

/obj/item/circuit_component/list_vox/populate_ports()
	word_list = add_input_port("Word List", PORT_TYPE_LIST(PORT_TYPE_STRING))

/obj/item/circuit_component/list_vox/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		bci = shell

/obj/item/circuit_component/list_vox/unregister_shell(atom/movable/shell)
	bci = null

/obj/item/circuit_component/list_vox/input_received(datum/port/input/port)
	if(!bci)
		return

	var/mob/living/owner = bci.owner

	if(!owner || !istype(owner) || !owner.client || !word_list.value)
		return

	for(var/word in word_list.value)
		play_vox_word(word, only_listener = owner)

/obj/item/circuit_component/string_vox
	display_name = "String VOX Announcement"
	desc = "A component that plays a local VOX Announcement for the user. Requires a BCI shell."
	category = "BCI"

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/input/words

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/obj/item/organ/cyberimp/bci/bci

/obj/item/circuit_component/string_vox/populate_ports()
	words = add_input_port("Words", PORT_TYPE_STRING)

/obj/item/circuit_component/string_vox/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		bci = shell

/obj/item/circuit_component/string_vox/unregister_shell(atom/movable/shell)
	bci = null

/obj/item/circuit_component/string_vox/input_received(datum/port/input/port)
	if(!bci)
		return

	var/mob/living/owner = bci.owner

	if(!owner || !istype(owner) || !owner.client || !words.value)
		return

	var/words_list = splittext(trim(words.value), " ")

	for(var/word in words_list)
		play_vox_word(word, only_listener = owner)
