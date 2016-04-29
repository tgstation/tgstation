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
#include <sstream>
#include <vector>
#include <algorithm>

using namespace std;

struct runtime {
	string text;
	string proc;
	string source;
	string usr;
	string src;
	string loc;
	unsigned int count;
};
struct harddel {
	string type;
	unsigned int count;
};
//Make all of these global. It's bad yes, but it's a small program so it really doesn't affect anything.

//Because hardcoded numbers are bad :(
//const unsigned short maxStorage = 1000;

//What we use to read input
string lastLine = "";
string currentLine = "";
string nextLine = "";

//Stores lines we want to keep to print out
vector<runtime*> storedRuntime;
vector<runtime*> storedInfiniteLoop;
vector<harddel*> storedHardDel;

//Stat tracking stuff for output
unsigned int totalRuntimes = 0;
unsigned int totalUniqueRuntimes = 0;
unsigned int totalInfiniteLoops = 0;
unsigned int totalUniqueInfiniteLoops = 0;
unsigned int totalHardDels = 0;
unsigned int totalUniqueHardDels = 0;

//Misc
runtime* currentRuntime = NULL; //for storing the current runtime when we want to read the extra info on the next lines.

void forward_progress(ifstream &inputFile) {
	lastLine = currentLine;
	currentLine	= nextLine;
	getline(inputFile, nextLine);
	//strip out any timestamps.
	if (nextLine.substr(0,1) == "[" && nextLine.substr(3,1) == ":" && nextLine.substr(6,1) == ":" && nextLine.substr(9,1) == "]")
		nextLine = nextLine.substr(10);
}	
bool readFromFile() {
	//Open file to read
	ifstream inputFile("Input.txt");

	if (inputFile.is_open()) {
		while (!inputFile.eof()) { //Until end of file
			//Update our lines
			forward_progress(inputFile);

			//After finding a new runtime, check to see if there are extra values to store
			if (currentRuntime) {
				//Skip ahead
				forward_progress(inputFile);

				//If we find this, we have new stuff to store
				if (nextLine.find("usr:") != std::string::npos) {
					//Skip ahead
					forward_progress(inputFile);
					
					//Store more info
					currentRuntime->source = lastLine;
					currentRuntime->usr = currentLine;
					currentRuntime->src = nextLine;
					
					//Skip ahead again
					forward_progress(inputFile);

					if (nextLine.find("src.loc:") != std::string::npos)
						currentRuntime->loc = nextLine;
					
				}
				currentRuntime = NULL;
			}

			//Found an infinite loop!
			if (currentLine.find("Infinite loop suspected") != std::string::npos || currentLine.find("Maximum recursion level reached") != std::string::npos) {
				totalInfiniteLoops++;
				bool found = false;
				for (int i=0; i < storedInfiniteLoop.size(); i++) {
					//We've already encountered this
					if (currentLine == storedInfiniteLoop[i]->text) {
						storedInfiniteLoop[i]->count++;
						found = true;
						break;
					}

				}
				//We've never encountered this
				if (!found) {
					runtime* R = new runtime;
					storedInfiniteLoop.push_back(R);
					R->text = currentLine;
					forward_progress(inputFile);
					R->proc = nextLine;
					currentRuntime = R;
					totalUniqueInfiniteLoops++;
				}
				
			}
			//Found a runtime!
			else if (currentLine.find("runtime error:") != std::string::npos) {
				if (currentLine.length() <= 17) { //empty runtime, check next line.
					if (nextLine.length() < 2) //runtime is on the line before this one.
						nextLine = lastLine;
					forward_progress(inputFile);
					currentLine = "runtime error: " + currentLine;
				}
				totalRuntimes++;
				bool found = false;
				for (int i=0; i < storedRuntime.size(); i++) {
					//We've already encountered this
					if (currentLine == storedRuntime[i]->text) {
						storedRuntime[i]->count++;
						found = true;
						break;
					}

				}

				//We've never encountered this
				if (!found) {
					runtime* R = new runtime;
					storedRuntime.push_back(R);
					R->text = currentLine;
					R->proc = nextLine;
					R->count = 1;
					currentRuntime = R;
					totalUniqueRuntimes++;
				}
			}
			
			//Found a hard del!
			else if (currentLine.find("Path :") != std::string::npos) {				
				unsigned int failures = (unsigned int)strtoul(nextLine.substr(11).c_str(), NULL, 10);

				
				totalHardDels += failures;
				bool found = false;
				for (int i=0; i < storedHardDel.size(); i++) {
					
					//We've already encountered this
					if (currentLine == storedHardDel[i]->type) {
						storedHardDel[i]->count += failures;
						found = true;
						break;
					}
				}
			
				//We've never encountered this
				if (!found) {
					harddel* D = new harddel;
					storedHardDel.push_back(D);
					D->type = currentLine;
					D->count = failures;
					totalUniqueHardDels++;
				}
			}
		}
	} else {
		return false;
	}
	return true;
}

bool writeToFile() {
	//Open and clear the file
	ofstream outputFile("Output.txt", ios::trunc);

	if(outputFile.is_open()) {
		outputFile << "Note: The proc name, source file, src and usr are all from the FIRST of the identical runtimes. Everything else is cropped.\n\n";
		if(totalUniqueInfiniteLoops > 0)
			outputFile << "Total unique infinite loops: " << totalUniqueInfiniteLoops << endl;

		if(totalInfiniteLoops > 0) 
			outputFile << "Total infinite loops: " << totalInfiniteLoops << endl << endl;

		outputFile << "Total unique runtimes: " << totalUniqueRuntimes << endl;
		outputFile << "Total runtimes: " << totalRuntimes << endl << endl;
		if(totalUniqueHardDels > 0)
			outputFile << "Total unique hard deletions: " << totalUniqueHardDels << endl;

		if(totalHardDels > 0)
			outputFile << "Total hard deletions: " << totalHardDels << endl << endl;


		//If we have infinite loops, display them first.
		if(totalInfiniteLoops > 0) {
			outputFile << "** Infinite loops **";
			for (int i=0; i < storedInfiniteLoop.size(); i++) {
				runtime* R = storedInfiniteLoop[i];
				outputFile << endl << endl << "The following infinite loop has occurred " << R->count << " time(s).\n"; 
				outputFile << R->text << endl;
				if(R->proc.length()) 
					outputFile << R->proc << endl;
				if(R->source.length()) 
					outputFile << R->source << endl;
				if(R->usr.length()) 
					outputFile << R->usr << endl;
				if(R->src.length()) 
					outputFile << R->src << endl;
				if(R->loc.length()) 
					outputFile << R->loc << endl;
			}
			outputFile << endl << endl; //For spacing
		}


		//Do runtimes next
		outputFile << "** Runtimes **";
		for (int i=0; i < storedRuntime.size(); i++) {
			runtime* R = storedRuntime[i];
			outputFile << endl << endl << "The following runtime has occurred " << R->count << " time(s).\n"; 
			outputFile << R->text << endl;
			if(R->proc.length()) 
				outputFile << R->proc << endl;
			if(R->source.length()) 
				outputFile << R->source << endl;
			if(R->usr.length()) 
				outputFile << R->usr << endl;
			if(R->src.length()) 
				outputFile << R->src << endl;
			if(R->loc.length()) 
				outputFile << R->loc << endl;
		}
		outputFile << endl << endl; //For spacing
		
		//and finally, hard deletes
		if(totalHardDels > 0) {
			outputFile << endl << "** Hard deletions **";
			for(int i=0; i < storedHardDel.size(); i++) {
				harddel* D = storedHardDel[i];
				outputFile << endl << D->type << " - " << D->count << " time(s).\n";
			}
		}
		outputFile.close();
	} else {
		return false;
	}
	return true;
}


bool runtimeComp(const runtime* a, const runtime* b) {
    return a->count > b->count;
}

bool hardDelComp(const harddel* a, const harddel* b) {
    return a->count > b->count;
}

int main() {
	char exit; //Used to stop the program from immediately exiting

	if(readFromFile()) {
		cout << "Input read successfully!\n";
	} else {
		cout << "Input failed to open, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 1;
	}

	std::sort(storedRuntime.begin(), storedRuntime.end(), runtimeComp);
	std::sort(storedInfiniteLoop.begin(), storedInfiniteLoop.end(), runtimeComp);
	std::sort(storedHardDel.begin(), storedHardDel.end(), hardDelComp);

	if(writeToFile()) {
		cout << "Output was successful!\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 0;
	} else {
		cout << "The output file could not be opened, shutting down.\n";
		cout << "\nEnter any letter to quit.\n";
		cin >> exit;
		return 0;
	}

	return 0;
}
