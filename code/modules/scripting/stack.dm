/stack
	var/list
		contents=new
	proc
		Push(value)
			contents+=value

		Pop()
			if(!contents.len) return null
			. = contents[contents.len]
			contents.len--

		Top() //returns the item on the top of the stack without removing it
			if(!contents.len) return null
			return contents[contents.len]

		Copy()
			var/stack/S=new()
			S.contents=src.contents.Copy()
			return S

		Clear()
			contents.Cut()