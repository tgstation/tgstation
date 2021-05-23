
# Template file for your new element

See _element.dm for detailed explanations

```dm
/datum/element/myelement
	element_flags = ELEMENT_BESPOKE | ELEMENT_COMPLEX_DETACH | ELEMENT_DETACH | ELEMENT_NOTAREALFLAG    // code/__DEFINES/dcs/flags.dm
	//id_arg_index = 2                                                                                  // Use with ELEMENT_BESPOKE
	var/list/myvar = list()

/datum/element/myelement/Attach(datum/target)
	if(!isatom(target))
		return COMPONENT_INCOMPATIBLE
	var/atom/target_atom = target
	target_atom.name = "elemental [target_atom.name]"
	to_chat(target, "Hey, you're in your element.")

/datum/element/myelement/Detach(datum/source)
	var/atom/source_atom = source
	source_atom.name = initial(source_atom.name)
	to_chat(source, "You feel way out of your element.")
```
