/* Runtime Condenser by Nodrak
 * This will sum up identical runtimes into one, giving a total of how many times it occured. The first occurance
 * of the runtime will log the proc, source, usr and src, the rest will just add to the total. Infinite loops will
 * also be caught and displayed (if any) above the list of runtimes.
 *
 * How to use:
 * 1) Copy and paste your list of runtimes from Dream Daemon into input.exe
 * 2) Run RuntimeCondenser.exe
 * 3) Open output.txt for a condensed report of the runtimes
 */

#include <iostream>
#include <fstream>
#include <string>
using namespace std;

//Make all of these global. It's bad yes, but it's a small program so it really doesn't affect anything.
	//Because hardcoded numbers are bad :(
	const unsigned short maxStorage = 99; //100 - 1

	//What we use to read input
	string currentLine = "Blank";
	string nextLine = "Blank";

	//Stores lines we want to keep to print out
	string storedRuntime[maxStorage+1];
	string storedProc[maxStorage+1];
	string storedSource[maxStorage+1];
	string storedUsr[maxStorage+1];
	string storedSrc[maxStorage+1];

	//Stat tracking stuff for output
	unsigned int totalRuntimes = 0;
	unsigned int totalUniqueRuntimes = 0;
	unsigned int totalInfiniteLoops = 0;
	unsigned int totalUniqueInfiniteLoops = 0;

	//Misc
	unsigned int numRuntime[maxStorage+1]; //Number of times a specific runtime has occured
	bool checkNextLines = false; //Used in case byond has condensed a large number of similar runtimes
	int storedIterator = 0; //Used to remember where we stored the runtime

bool readFromFile()
{
	//Open file to read
	ifstream inputFile("input.txt");

	if(inputFile.is_open())
	{
		while(!inputFile.eof()) //Until end of file
		{
			//If we've run out of storage
			if(storedRuntime[maxStorage] != "Blank") break;

			//Update our lines
			currentLine	= nextLine;
			getline(inputFile, nextLine);

			//After finding a new runtime, check to see if there are extra values to store
			if(checkNextLines)
			{
				//Skip ahead
				currentLine = nextLine;
				getline(inputFile, nextLine);

				//If we find this, we have new stuff to store
				if(nextLine.find("usr:") != std::string::npos)
				{
					//Store more info
					storedSource[storedIterator] = currentLine;
					storedUsr[storedIterator] = nextLine;

					//Skip ahead again
					currentLine = nextLine;
					getline(inputFile, nextLine);

					//Store the last of the info
					storedSrc[storedIterator] = nextLine;
				}
				checkNextLines = false;
			}

			//Found an infinite loop!
			if(currentLine.find("Infinite loop suspected") != std::string::npos || currentLine.find("Maximum recursion level reached") != std::string::npos)
			{
				totalInfiniteLoops++;

				for(int i=0; i <= maxStorage; i++)
				{
					//We've already encountered this
					if(currentLine == storedRuntime[i])
					{
						numRuntime[i]++;
						break;
					}

					//We've never encoutnered this
					if(storedRuntime[i] == "Blank")
					{
						storedRuntime[i] = currentLine;
						currentLine = nextLine;
						getline(inputFile, nextLine); //Skip the "if this is not an infinite loop" line
						storedProc[i] = nextLine;
						numRuntime[i] = 1;
						checkNextLines = true;
						storedIterator = i;
						totalUniqueInfiniteLoops++;
						break;
					}
				}
			}
			//Found a runtime!
			else if(currentLine.find("runtime error:") != std::string::npos)
			{
				totalRuntimes++;
				for(int i=0; i <= maxStorage; i++)
				{
					//We've already encountered this
					if(currentLine == storedRuntime[i])
					{
						numRuntime[i]++;
						break;
					}

					//We've never encoutnered this
					if(storedRuntime[i] == "Blank")
					{
						storedRuntime[i] = currentLine;
						storedProc[i] = nextLine;
						numRuntime[i] = 1;
						checkNextLines = true;
						storedIterator = i;
						totalUniqueRuntimes++;
						break;
					}
				}
			}
		}
	}
	else
	{
		return false;
	}
	return true;
}

bool writeToFile()
{
	//Open and clear the file
	ofstream outputFile("Output.txt", ios::trunc);

	if(outputFile.is_open())
	{
		outputFile << "Note: The proc name, source file, src and usr are all from the FIRST of the identical runtimes. Everything else is cropped.\n\n";
		if(totalUniqueInfiniteLoops > 0)
		{
			outputFile << "Total unique infinite loops: " << totalUniqueInfiniteLoops << endl;
		}
		if(totalInfiniteLoops > 0)
		{
			outputFile << "Total infinite loops: " << totalInfiniteLoops << endl;
		}
		outputFile << "Total unique runtimes: " << totalUniqueRuntimes << endl;
		outputFile << "Total runtimes: " << totalRuntimes << endl << endl;

		//Display a warning if we've hit the maximum space we've allocated for storage
		if(totalUniqueRuntimes + totalUniqueInfiniteLoops >= maxStorage)
		{
			outputFile << "Warning: The maximum number of unique runtimes has been hit. If there were more, they have been cropped out.\n\n";
		}


		//If we have infinite loops, display them first.
		if(totalInfiniteLoops > 0)
		{
			outputFile << "** Infinite loops **";
			for(int i=0; i <= maxStorage; i++)
			{
				if(storedRuntime[i].find("Infinite loop suspected") != std::string::npos || storedRuntime[i].find("Maximum recursion level reached") != std::string::npos)
				{
					if(numRuntime[i] != 0) outputFile << endl << endl << "The following infinite loop has occured " << numRuntime[i] << " time(s).\n";
					if(storedRuntime[i] != "Blank") outputFile << storedRuntime[i] << endl;
					if(storedProc[i] != "Blank") outputFile << storedProc[i] << endl;
					if(storedSource[i] != "Blank") outputFile << storedSource[i] << endl;
					if(storedUsr[i] != "Blank") outputFile << storedUsr[i] << endl;
					if(storedSrc[i] != "Blank") outputFile << storedSrc[i] << endl;
				}
			}
			outputFile << endl << endl; //For spacing
		}


		//Do runtimes next
		outputFile << "** Runtimes **";
		for(int i=0; i <= maxStorage; i++)
		{
			if(storedRuntime[i].find("Infinite loop suspected") != std::string::npos || storedRuntime[i].find("Maximum recursion level reached") != std::string::npos) continue;

			if(numRuntime[i] != 0) outputFile << endl << endl << "The following runtime has occured " << numRuntime[i] << " time(s).\n";
			if(storedRuntime[i] != "Blank") outputFile << storedRuntime[i] << endl;
			if(storedProc[i] != "Blank") outputFile << storedProc[i] << endl;
			if(storedSource[i] != "Blank") outputFile << storedSource[i] << endl;
			if(storedUsr[i] != "Blank") outputFile << storedUsr[i] << endl;
			if(storedSrc[i] != "Blank") outputFile << storedSrc[i] << endl;
		}
		outputFile.close();
	}
	else
	{
		return false;
	}
	return true;
}

void sortRuntimes()
{
	string tempRuntime[maxStorage+1];
	string tempProc[maxStorage+1];
	string tempSource[maxStorage+1];
	string tempUsr[maxStorage+1];
	string tempSrc[maxStorage+1];
	unsigned int tempNumRuntime[maxStorage+1];
	unsigned int highestCount = 0; //Used for descending order
//	int keepLooping = 0;

	//Move all of our data into temporary arrays. Also clear the stored data (not necessary but.. just incase)
	for(int i=0; i <= maxStorage; i++)
	{
		//Get the largest occurance of a single runtime
		if(highestCount < numRuntime[i])
		{
			highestCount = numRuntime[i];
		}

		tempRuntime[i] = storedRuntime[i];	storedRuntime[i] = "Blank";
		tempProc[i] = storedProc[i];		storedProc[i] = "Blank";
		tempSource[i] = storedSource[i];	storedSource[i] = "Blank";
		tempUsr[i] = storedUsr[i];			storedUsr[i] = "Blank";
		tempSrc[i] = storedSrc[i];			storedSrc[i] = "Blank";
		tempNumRuntime[i] = numRuntime[i];	numRuntime[i] = 0;
	}

	while(highestCount > 0)
	{
		for(int i=0; i <= maxStorage; i++) //For every runtime
		{
			if(tempNumRuntime[i] == highestCount) //If the number of occurances of that runtime is equal to our current highest
			{
				for(int j=0; j <= maxStorage; j++) //Find the next available slot and store the info
				{
					if(storedRuntime[j] == "Blank") //Found an empty spot
					{
						storedRuntime[j] = tempRuntime[i];
						storedProc[j] = tempProc[i];
						storedSource[j] = tempSource[i];
						storedUsr[j] = tempUsr[i];
						storedSrc[j] = tempSrc[i];
						numRuntime[j] = tempNumRuntime[i];
						break;
					}
				}
			}
		}
		highestCount--; //Lower our 'highest' by one and continue
	}
}


int main() {
	char exit; //Used to stop the program from immediatly exiting

	//Start everything fresh. "Blank" should never occur in the runtime logs on its own.
	for(int i=0; i <= maxStorage; i++)
	{
		storedRuntime[i] = "Blank";
		storedProc[i] = "Blank";
		storedSource[i] = "Blank";
		storedUsr[i] = "Blank";
		storedSrc[i] = "Blank";
		numRuntime[i] = 0;

	}

	if(readFromFile())
	{
		cout << "Input read successfully!\n";
	}
	else
	{
		cout << "Input failed to open, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 1;
	}

	sortRuntimes();

	if(writeToFile())
	{
		cout << "Output was successful!\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 0;
	}
	else
	{
		cout << "The output file could not be opened, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 0;
	}

	return 0;
}
