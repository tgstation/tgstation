import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Scanner;

public class MapMergerMain {
	
	private static Scanner input = new Scanner(System.in);
	
	public static void main(String[] args) throws IOException{
		
		System.out.print("Path to _maps folder: ");
		String pathTo_maps = input.nextLine();
		Path fileDir = Paths.get(pathTo_maps);
		FileFinder finder = new FileFinder("*.dmm");
		Files.walkFileTree(fileDir, finder);
		ArrayList<Path> foundFiles = finder.foundPaths;
		if (foundFiles.size() > 0) {
				for(int num = 0;num < foundFiles.size();num++){
					System.out.println(num + ": " + foundFiles.get(num));
				}
		}else{
			System.out.println("No files were found!");
		}
		System.out.print("File to use: ");
		int selection;
		inputCheck:while(true){
			while(!input.hasNextInt()){
					String temp = input.next();
					System.out.println(temp + " is not a valid int.");
			}
			selection = input.nextInt();
			if(selection < 0 || selection >= foundFiles.size()){
				if(selection < 0){
					System.out.println("Use a number greater than 0!");
				}else{
					System.out.println("Use a number less than " + foundFiles.size() +"!");
				}
				continue inputCheck;
			}else{
				break inputCheck;
			}
		}
		
		String newMap = foundFiles.get(selection) + "";
		String oldMap = foundFiles.get(selection) + ".backup";
		String[] passInto = new String[4];
		passInto[0] = "-clean";
		passInto[1] = oldMap;
		passInto[2] = newMap;
		passInto[3] = newMap;
		MapPatcher.main(passInto);
	}
	
}