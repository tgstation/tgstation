/*
	File: Scanner
*/
/*
	Class: n_Scanner
	An object responsible for breaking up source code into tokens for use by the parser.
*/
/n_Scanner
	var
		code
		list
/*
	Var: errors
	A list of fatal errors found by the scanner. If there are any items in this list, then it is not safe to parse the returned tokens.

	See Also:
	- <scriptError>
*/
			errors   = new
/*
	Var: warnings
	A list of non-fatal problems in the source code found by the scanner.
*/
			warnings = new

	proc
/*
	Proc: LoadCode
	Loads source code.
*/
		LoadCode(c)
			code=c

/*
	Proc: LoadCodeFromFile
	Gets the code from a file and calls <LoadCode()>.
*/
		LoadCodeFromFile(f)
			LoadCode(file2text(f))

/*
	Proc: Scan
	Runs the scanner and returns the resulting list of tokens. Ensure that <LoadCode()> has been called first.
*/
		Scan()

/*
	Class: nS_Scanner
	A scanner implementation for n_Script.
*/
/n_Scanner/nS_Scanner

	var
/*
	Variable: codepos
	The scanner's position in the source code.
*/
		codepos				 = 1
		line					 = 1
		linepos 			 = 0 										 //column=codepos-linepos
		n_scriptOptions/nS_Options/options

		commenting = 0
				// 1: single-line
				// 2: multi-line
		list
/*
	Variable: ignore
	A list of characters that are ignored by the scanner.

	Default Value:
	Whitespace
*/
			ignore 			 = list(" ", "\t", "\n") //Don't add tokens for whitespace
/*
	Variable: end_stmt
	A list of characters that end a statement. Each item may only be one character long.

	Default Value:
	Semicolon
*/
			end_stmt		 = list(";")
/*
	Variable: string_delim
	A list of characters that can start and end strings.

	Default Value:
	Double and single quotes.
*/
			string_delim = list("\"", "'")
/*
	Variable: delim
	A list of characters that denote the start of a new token. This list is automatically populated.
*/
			delim 			 = new

/*
	Macro: COL
	The current column number.
*/
	#define COL codepos-linepos

/*
	Constructor: New
	Parameters:
	code	 	- The source code to tokenize.
	options - An <nS_Options> object used to configure the scanner.
*/
	New(code, n_scriptOptions/nS_Options/options)
		.=..()
		ignore+= ascii2text(13) //Carriage return
		delim += ignore + options.symbols + end_stmt + string_delim
		src.options=options
		LoadCode(code)

	Scan() //Creates a list of tokens from source code
		var/list/tokens=new
		for(, src.codepos<=lentext(code), src.codepos++)

			var/char=copytext(code, codepos, codepos+1)
			if(char=="\n")
				line++
				linepos=codepos

			if(ignore.Find(char))
				continue
			else if(char == "/")
				ReadComment()
			else if(end_stmt.Find(char))
				tokens+=new /token/end(char, line, COL)
			else if(string_delim.Find(char))
				codepos++ //skip string delimiter
				tokens+=ReadString(char)
			else if(options.CanStartID(char))
				tokens+=ReadWord()
			else if(options.IsDigit(char))
				tokens+=ReadNumber()
			else if(options.symbols.Find(char))
				tokens+=ReadSymbol()


		codepos=initial(codepos)
		line=initial(line)
		linepos=initial(linepos)
		return tokens

	proc
/*
	Proc: ReadString
	Reads a string in the source code into a token.

	Parameters:
	start - The character used to start the string.
*/
		ReadString(start)
			var
				buf
			for(, codepos <= lentext(code), codepos++)//codepos to lentext(code))
				var/char=copytext(code, codepos, codepos+1)
				switch(char)
					if("\\")					//Backslash (\) encountered in string
						codepos++       //Skip next character in string, since it was escaped by a backslash
						char=copytext(code, codepos, codepos+1)
						switch(char)
							if("\\")      //Double backslash
								buf+="\\"
							if("n")				//\n Newline
								buf+="\n"
							else
								if(char==start) //\" Doublequote
									buf+=start
								else				//Unknown escaped text
									buf+=char
					if("\n")
						. = new/token/string(buf, line, COL)
						errors+=new/scriptError("Unterminated string. Newline reached.", .)
						line++
						linepos=codepos
						break
					else
						if(char==start) //string delimiter found, end string
							break
						else
							buf+=char     //Just a normal character in a string
			if(!.) return new/token/string(buf, line, COL)

/*
	Proc: ReadWord
	Reads characters separated by an item in <delim> into a token.
*/
		ReadWord()
			var
				char=copytext(code, codepos, codepos+1)
				buf
			while(!delim.Find(char) && codepos<=lentext(code))
				buf+=char
				char=copytext(code, ++codepos, codepos+1)
			codepos-- //allow main Scan() proc to read the delimiter
			if(options.keywords.Find(buf))
				return new /token/keyword(buf, line, COL)
			else
				return new /token/word(buf, line, COL)

/*
	Proc: ReadSymbol
	Reads a symbol into a token.
*/
		ReadSymbol()
			var
				char=copytext(code, codepos, codepos+1)
				buf

			while(options.symbols.Find(buf+char))
				buf+=char
				if(++codepos>lentext(code)) break
				char=copytext(code, codepos, codepos+1)

			codepos-- //allow main Scan() proc to read the next character
			return new /token/symbol(buf, line, COL)

/*
	Proc: ReadNumber
	Reads a number into a token.
*/
		ReadNumber()
			var
				char=copytext(code, codepos, codepos+1)
				buf
				dec=0

			while(options.IsDigit(char) || (char=="." && !dec))
				if(char==".") dec=1
				buf+=char
				codepos++
				char=copytext(code, codepos, codepos+1)
			var/token/number/T=new(buf, line, COL)
			if(isnull(text2num(buf)))
				errors+=new/scriptError("Bad number: ", T)
				T.value=0
			codepos-- //allow main Scan() proc to read the next character
			return T

/*
	Proc: ReadComment
	Reads a comment and outputs the type of comment
*/

		ReadComment()
			var
				char=copytext(code, codepos, codepos+1)
				nextchar=copytext(code, codepos+1, codepos+2)
				charstring = char+nextchar
				comm = 1
					// 1: single-line comment
					// 2: multi-line comment
				expectedend = 0

			if(charstring == "//" || charstring == "/*")
				if(charstring == "/*")
					comm = 2 // starts a multi-line comment

				while(comm)
					if(++codepos>lentext(code)) break

					if(expectedend) // ending statement expected...
						char = copytext(code, codepos, codepos+1)
						if(char == "/") // ending statement found - beak the comment
							comm = 0
							break

					if(comm == 2)
						// multi-line comments are broken by ending statements
						char = copytext(code, codepos, codepos+1)
						if(char == "*")
							expectedend = 1
							continue
					else
						char = copytext(code, codepos, codepos+1)
						if(char == "\n")
							comm = 0
							break

					if(expectedend) expectedend = 0

				if(comm == 2)
					errors+=new/scriptError/UnterminatedComment()

