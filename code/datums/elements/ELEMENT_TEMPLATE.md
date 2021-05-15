
# Template file for your new element

See _element.dm for detailed explanations

```dm
/datum/element/myelement
	element_flags = ELEMENT_BESPOKE | ELEMENT_COMPLEX_DETACH | ELEMENT_DETACH | ELEMENT_NOTAREALFLAG    // code/__DEFINES/dcs/flags.dm
	//id_arg_index = 2                                                                                  // Use with ELEMENT_BESPOKE
	var/list/myvar = list()

/datum/element/myelement/Attach(datum/target)
	myvar |= target
	to_chat(target, "Hey, you're in your element.")

/datum/element/myelement/Detach(datum/source)
	myvar -= target
	to_chat(source, "You feel way out of your element.")
```
