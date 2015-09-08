import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.Vector;

public class Map
{
  boolean sizeunknown;
  int minx;
  int miny;
  int minz;
  int maxx;
  int maxy;
  int maxz;
  HashMap<String, String> tile_types;
  HashMap<String, String> codes_by_value;
  HashMap<Location, String> tiles;

  public Map()
  {
    this.sizeunknown = true;
    this.tile_types = new HashMap();
    this.codes_by_value = new HashMap();
    this.tiles = new HashMap();
  }

  public Map(File paramFile)
  {
    this(paramFile, false);
  }

  public Map(File paramFile, boolean paramBoolean)
  {
    this.sizeunknown = true;
    try {
      BufferedReader localBufferedReader = new BufferedReader(new InputStreamReader(new FileInputStream(paramFile)));

      this.tile_types = new HashMap();
      this.codes_by_value = new HashMap();
      this.tiles = new HashMap();

      MapPatcher.Systemoutprintln(new StringBuilder().append("Loading map ").append(paramFile.getName()).toString());
      MapPatcher.Systemoutprint("Loading tiles");
      String str1 = "";
      int i = 0;
      while ((str1 = localBufferedReader.readLine()) != null)
      {
          //Read in lines 1 by 1
          //Empty line so break ??? seems weird
        if (str1.equals("")) break;
        if (str1.startsWith("\"")) //First make sure it starts with "
        {
          //Only happens once?  DUH - you only need to calcuate once as in naive format it's always fixed on the line
          if (i < 1)
          {
              //Find closing " for the tag
            int j = str1.indexOf("\"", 1);
            // Calculate the end of the tag i.e "aab" b is end of tag
            i = j - 1;
          }
          //Get tag
          String str2 = str1.substring(1, 1 + i);
          //Get rest of the tile (path{blah}, path{blah}
          String str3 = str1.substring(str1.indexOf("("));
          //Store in dict by tag -> values
          this.tile_types.put(str2, str3);
          //Store by values -> tag
          this.codes_by_value.put(str3, str2);
        }
      }
      //total number of tiles
      MapPatcher.Systemoutprintln(new StringBuilder().append(" ").append(this.tile_types.size()).toString());
      //Tags are now calculated, if some bool is set, now calculate the actual map layout from the rest of the file
      if (!paramBoolean)
      {
        MapPatcher.Systemoutprintln("Loading levels");
        while (true)
        {
            //Get line
          if ((str1 = localBufferedReader.readLine()) != null) { 
              //if the str starts with ( it's the  min x,y,z coord line
              if (str1.startsWith("(")) {
                int k = str1.indexOf(",", 1);
                //m == x
                int m = Integer.parseInt(str1.substring(1, k));
                str1 = str1.substring(k);
                k = str1.indexOf(",", 1);
                //n == y
                int n = Integer.parseInt(str1.substring(1, k));
                str1 = str1.substring(k);
                k = str1.indexOf(")", 1);
                //i1 = z
                int i1 = Integer.parseInt(str1.substring(1, k));

                MapPatcher.Systemoutprintln(new StringBuilder().append("New map part from (").append(m).append(",").append(n).append(",").append(i1).append(")").toString());

            int i3 = n;// currY = read y
            if (this.sizeunknown) //If size not know already
            {
              this.minx = m; this.maxx = this.minx;//set minmax to given z, y ,z
              this.miny = n; this.maxy = this.miny;
              this.minz = i1; this.maxz = this.minz;
              this.sizeunknown = false;
            }
            if (this.minz > i1) this.minz = i1;//if currz < minz set new minz
            if (this.maxz < i1) this.maxz = i1;//if currz > maxz, set new maxz
            //While line not == end map part delimiter
            while (!(str1 = localBufferedReader.readLine()).startsWith("\"}"))
            {
              int i2 = m;//currX = read x
              if (this.miny > i3) this.miny = i3;//if miny > curry update
              if (this.maxy < i3) this.maxy = i3;//if maxy < curry update
              while (str1.length() > 0)//While line is greater than length 0
              {
                //Get first 3 keymap vals
                String str4 = str1.substring(0, i);
                //New location at currx, curry, currz
                Location localLocation = new Location(i2, i3, i1);
                if (this.minx > i2) this.minx = i2;//if currx < minx set
                if (this.maxx < i2) this.maxx = i2;//if currx > maxx set
                //Get tile type and put at location
                this.tiles.put(localLocation, this.tile_types.get(str4));
                //Move string up
                str1 = str1.substring(i);
                //currx +1 (as we walk across
                i2++;
              }
              //New line curry +1
              i3++;
            }
          }
        }
      }
      localBufferedReader.close();
    }
    catch (Exception localException)
    {
      localException.printStackTrace();
    }
  }

  public void mirrorY()
  {
    for (int i = this.minz; i <= this.maxz; i++)
      for (int j = this.minx; j <= this.maxx; j++)
        for (int k = this.miny; k < (this.miny + this.maxy) / 2; k++)
        {
          int m = this.maxy - (k - this.miny);
          String str = contentAt2(j, k, i);
          setAt(j, k, i, contentAt2(j, m, i));
          setAt(j, m, i, str);
        }
  }

  //Get content at (x,y,z) print error if not found and return str "null"
  public String contentAt(int paramInt1, int paramInt2, int paramInt3)
  {
    Location localLocation = new Location(paramInt1, paramInt2, paramInt3);
    String str = (String)this.tiles.get(localLocation);
    if (str == null) System.err.println(new StringBuilder().append("Null at ").append(paramInt1).append(",").append(paramInt2).append(",").append(paramInt3).append(" Possible loading error").toString());
    return str == null ? "null" : str;
  }

  //Given a location, look up tile content contentAt(x,y,z) (no errors)
  public String contentAt2(int paramInt1, int paramInt2, int paramInt3)
  {
    Location localLocation = new Location(paramInt1, paramInt2, paramInt3);
    return (String)this.tiles.get(localLocation);
  }

  //SEt some tile at given params (updating max min bounds if needed)
  //setAt(x, y, z, string)
  public void setAt(int paramInt1, int paramInt2, int paramInt3, String paramString)
  {
    if (this.sizeunknown)
    {
      this.minx = (this.maxx = paramInt1);
      this.miny = (this.maxy = paramInt2);
      this.minz = (this.maxz = paramInt3);
      this.sizeunknown = false;
    }
    else
    {
      this.minx = Math.min(this.minx, paramInt1);
      this.miny = Math.min(this.miny, paramInt2);
      this.minz = Math.min(this.minz, paramInt3);
      this.maxx = Math.max(this.maxx, paramInt1);
      this.maxy = Math.max(this.maxy, paramInt2);
      this.maxz = Math.max(this.maxz, paramInt3);
    }
    Location localLocation = new Location(paramInt1, paramInt2, paramInt3);
    localLocation.set(paramInt1, paramInt2, paramInt3);
    this.tiles.put(localLocation, paramString);
  }

  public void save(File paramFile) throws Exception
  {
    saveReferencing(paramFile, null);
  }

  public void saveReferencing(File paramFile, Map paramMap) throws Exception
  {
    FileWriter localFileWriter = new FileWriter(paramFile);

    this.tile_types.clear();
    this.codes_by_value.clear();
    Vector localVector1 = new Vector();
    //Foreach localLocation in locations on map
    for (Object localObject1 = this.tiles.keySet().iterator(); ((Iterator)localObject1).hasNext(); ) { Location localLocation = (Location)((Iterator)localObject1).next();

      String str1 = (String)this.tiles.get(localLocation);
      //Get key code at this location
      if (!localVector1.contains(str1))
          //If key code not in local key codes array add it
        localVector1.add(str1);
    }
    MapPatcher.Systemoutprintln(new StringBuilder().append("We have ").append(localVector1.size()).append(" different tiles").toString());
    //Possible list of all hash hash keys?
    localObject1 = new String[] { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" };

    int i = 1;
    int j = localObject1.length;
    while (j < localVector1.size())
        //While length of hash array smaller than number of potential map keys
    {
      j *= localObject1.length; //multiple J by object1 length (the fuck???)
      i++;//Increment i
    }
    //New items to write vector
    Vector localVector2;
    if (paramMap == null) {
        //If no map to look up
      localVector2 = localVector1;//Set to all items
    }
    else {
      localVector2 = new Vector();
      for (Iterator localIterator = localVector1.iterator(); localIterator.hasNext(); ) { localObject2 = (String)localIterator.next();
          //foreach item in local tiles possible
          //Item already exists as tile in our old map (don't add to new items vector)
        if (paramMap.codes_by_value.containsKey(localObject2))
        {
          localObject3 = paramMap.getIdFor((String)localObject2);
          //Add to our own tile types as a key for our item
          this.tile_types.put(localObject3, localObject2);
          //Add to our own codes as a reverse mapping
          this.codes_by_value.put(localObject2, localObject3);
        }
        else {
          //Otherwise add the new item to our new items vector
          localVector2.add(localObject2);
        } }
      localVector1.clear();
    }

    int k = 0;
    for (Object localObject2 = localVector2.iterator(); ((Iterator)localObject2).hasNext(); ) { localObject3 = (String)((Iterator)localObject2).next();
        //For each new item in our new items array
      do
      {
        //calculate new code from our hash map keys 
        str2 = int2code((String[])localObject1, k, i);
        k++;
      }while (this.tile_types.containsKey(str2));
      //while the key is a valid tyle type, add the new location tile
      this.tile_types.put(str2, localObject3);
      this.codes_by_value.put(localObject3, str2);
    }
    String str2;
    localVector2.clear();

    k = 0;
    for (int m = 0; m < this.tile_types.size(); m++)
    //Now write out our new file in the dmm format
    //FOr each item in tile_types
    {
      do
      {
        //Calculate key
        localObject3 = int2code((String[])localObject1, k, i);
        k++;
      }while (!this.tile_types.containsKey(localObject3));
      //If not in tile types, write out to end of file
      str2 = (String)this.tile_types.get(localObject3);
      localFileWriter.write(new StringBuilder().append("\"").append((String)localObject3).append("\" = ").append(str2).append("\r\n").toString());
    }
    localVector2.clear();

    localFileWriter.write("\n");
    //how many threads to spawn possibly??? TO DO instrument and confirm
    //For 1 z level 1 + (1-0) = 2 
    //for 2 z level 1 + (2-0) = 2
    //for 3 z level 1 + (3-0) = 4 
    m = 1 + this.maxz - this.minz;
    Object localObject3 = new SavingThread[m]; //array of savingthreads?
    //what is n??? some kind of way of partioning the map up by threads?
    int n = (this.maxy - this.miny) * ((this.maxx - this.minx) * i + 2) + 32;//Buest guess is half the map is partitioned to it
    for (k = 0; k < m; k++)
    {
        //Create new thread for each part of the map and store in our SavingThread array
      localObject3[k] = new SavingThread(this.minz + k, this, n);
      localObject3[k].start();
      //Get each thread to start writing values
    }

    int i1 = 0;
    String str3 = "";
    //Wait for threads to be done
    while (i1 == 0) {
      try {
        Thread.sleep(100L); } catch (Exception localException) {
      }
      i1 = 1;

      str3 = "";
      for (k = 0; k < m; k++)
      {
        if (!localObject3[k].done)
          i1 = 0;
        if (str3.length() != 0) str3 = new StringBuilder().append(str3).append(" ").toString();
        str3 = new StringBuilder().append(str3).append(localObject3[k].done ? "Done" : new StringBuilder().append(localObject3[k].progress).append("%").toString()).toString();
      }
      MapPatcher.Systemoutprint(new StringBuilder().append(str3).append("\r").toString());
    }
    //Once each thread writer is done, get result and write to file in order
    for (k = 0; k < m; k++) {
      localFileWriter.write(localObject3[k].result.toString());
    }
    localFileWriter.flush();
    localFileWriter.close();
  }

  //Given content string get id from dict map
  public String getIdFor(String paramString)
  {
    if (this.codes_by_value.containsKey(paramString))
    {
      return (String)this.codes_by_value.get(paramString);
    }
    //Unknown
    return "???";
  }

  //Given a list of possible hash items, calculate a byond map hash key based on an x/y parameter ?
  public String int2code(String[] paramArrayOfString, int paramInt1, int paramInt2)
  {
    String str = "";
    while (paramInt1 >= paramArrayOfString.length)
    {
      int i = paramInt1 % paramArrayOfString.length;
      str = new StringBuilder().append(paramArrayOfString[i]).append(str).toString();
      paramInt1 -= i;
      paramInt1 /= paramArrayOfString.length;
    }
    str = new StringBuilder().append(paramArrayOfString[paramInt1]).append(str).toString();
    while (str.length() < paramInt2) str = new StringBuilder().append(paramArrayOfString[0]).append(str).toString();
    return str;
  }
}
