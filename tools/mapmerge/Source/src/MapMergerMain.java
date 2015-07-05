import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Scanner;

public class MapMergerMain {
	
	private static Scanner input = new Scanner(System.in);
	
	public static void main(String[] mapPath) throws IOException{
		Path pathToMaps = Paths.get(mapPath[0]);
		FileFinder dmmFinder = new FileFinder("*.dmm");
		Files.walkFileTree(pathToMaps, dmmFinder);
		ArrayList<Path> foundFiles = dmmFinder.foundPaths;
		if (foundFiles.size() > 0) {
			try{
				merge(foundFiles);
			}catch(Exception e){
				System.out.println("Something went wrong.");
				e.printStackTrace();
			}
		}else{
			System.out.println("No files were found in provided directory!");
			System.out.print("Path to maps folder: ");	
			pathToMaps = Paths.get(input.nextLine());
			dmmFinder = new FileFinder("*.dmm");
			Files.walkFileTree(pathToMaps, dmmFinder);
			foundFiles = dmmFinder.foundPaths;
			try{
				merge(foundFiles);
			}catch(Exception e){
				System.out.println("Something went wrong.");
				e.printStackTrace();
			}
		}
	}
	
	
	public static void merge(ArrayList<Path> foundFiles){
		
		System.out.println("How many files do you want to merge?");
		int selection1;
		inputCheck:while(true){
			while(!input.hasNextInt()){
					String temp = input.next();
					System.out.println(temp + " is not a valid int.");
			}
			selection1 = input.nextInt();
			if(selection1 < 0){
					System.out.println("Use a number greater than 0!");
				continue inputCheck;
			}else{
				break inputCheck;
			}
		}
		
		for(int numOfFiles = selection1; numOfFiles != 0; numOfFiles--){
			
			for(int num = 0;num < foundFiles.size();num++){
				System.out.println(num + ": " + foundFiles.get(num));
			}
			
			System.out.print("File to use: ");
			int selection2;
			inputCheck:while(true){
				while(!input.hasNextInt()){
						String temp = input.next();
						System.out.println(temp + " is not a valid int.");
				}
				selection2 = input.nextInt();
				if(selection2 < 0 || selection2 >= foundFiles.size()){
					if(selection2 < 0){
						System.out.println("Use a number greater than 0!");
					}else{
						System.out.println("Use a number less than " + foundFiles.size() +"!");
					}
					continue inputCheck;
				}else{
					break inputCheck;
				}
			}
			
			String newMap = foundFiles.get(selection2) + "";
			String oldMap = foundFiles.get(selection2) + ".backup";
			String[] passInto = new String[4];
			passInto[0] = "-clean";
			passInto[1] = oldMap;
			passInto[2] = newMap;
			passInto[3] = newMap;
			MapPatcher.main(passInto);
		}
	}
	
}