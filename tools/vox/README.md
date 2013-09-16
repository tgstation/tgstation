VOX Toolkit
===========

This is a toolkit written by N3X15 to generate sounds needed for the VOX system.  To do so, it uses the Festival TTS system to generate the speech, then distorts it using sox, finally encoding it with oggenc.

Due to words being required that don't exist in the English dictionary, an additional system has been added to inform Festival how to pronounce these words in an easy, sensible way.

Requirements
------------
* python 2.7
* sox
* festival
* vorbis-tools (oggenc)

Usage
-----
Simply run:

   python create.py voxwords.txt

Sounds encoded will end up in the sounds directory, alongside a cache directory and a tmp directory. Pauses and beeps/bloops will NOT be generated.
   
If words come out incorrectly pronounced, add the word to lexicon.txt following the guide at the top of the file.  This will generate the required LISP script for you.

If it's a single letter, add it to the words.txt as "a = A."


Adding to the List
------------------

Simply edit voxwords.txt and add the desired phrase:

  wordfile = This is a sample phrase that will be saved to wordfile.ogg

To test a phrase as though it were from in-game, run:

  play sounds/{sarah,connor,report,to,medbay,for,health,inspection}.ogg
  