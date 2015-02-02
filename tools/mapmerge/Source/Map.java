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
        if (str1.equals("")) break;
        if (str1.startsWith("\""))
        {
          if (i < 1)
          {
            int j = str1.indexOf("\"", 1);
            i = j - 1;
          }
          String str2 = str1.substring(1, 1 + i);
          String str3 = str1.substring(str1.indexOf("("));
          this.tile_types.put(str2, str3);
          this.codes_by_value.put(str3, str2);
        }
      }

      MapPatcher.Systemoutprintln(new StringBuilder().append(" ").append(this.tile_types.size()).toString());
      if (!paramBoolean)
      {
        MapPatcher.Systemoutprintln("Loading levels");
        while (true)
        {
          if ((str1 = localBufferedReader.readLine()) != null) { if (str1.startsWith("(")) break label270;  } else {
            label270: if (str1 == null)
            {
              break;
            }
            int k = str1.indexOf(",", 1);
            int m = Integer.parseInt(str1.substring(1, k));
            str1 = str1.substring(k);
            k = str1.indexOf(",", 1);
            int n = Integer.parseInt(str1.substring(1, k));
            str1 = str1.substring(k);
            k = str1.indexOf(")", 1);
            int i1 = Integer.parseInt(str1.substring(1, k));

            MapPatcher.Systemoutprintln(new StringBuilder().append("New map part from (").append(m).append(",").append(n).append(",").append(i1).append(")").toString());

            int i3 = n;
            if (this.sizeunknown)
            {
              this.minx = m; this.maxx = this.minx;
              this.miny = n; this.maxy = this.miny;
              this.minz = i1; this.maxz = this.minz;
              this.sizeunknown = false;
            }
            if (this.minz > i1) this.minz = i1;
            if (this.maxz < i1) this.maxz = i1;
            while (!(str1 = localBufferedReader.readLine()).startsWith("\"}"))
            {
              int i2 = m;
              if (this.miny > i3) this.miny = i3;
              if (this.maxy < i3) this.maxy = i3;
              while (str1.length() > 0)
              {
                String str4 = str1.substring(0, i);
                Location localLocation = new Location(i2, i3, i1);
                if (this.minx > i2) this.minx = i2;
                if (this.maxx < i2) this.maxx = i2;
                this.tiles.put(localLocation, this.tile_types.get(str4));
                str1 = str1.substring(i);
                i2++;
              }
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

  public String contentAt(int paramInt1, int paramInt2, int paramInt3)
  {
    Location localLocation = new Location(paramInt1, paramInt2, paramInt3);
    String str = (String)this.tiles.get(localLocation);
    if (str == null) System.err.println(new StringBuilder().append("Null at ").append(paramInt1).append(",").append(paramInt2).append(",").append(paramInt3).append(" Possible loading error").toString());
    return str == null ? "null" : str;
  }

  public String contentAt2(int paramInt1, int paramInt2, int paramInt3)
  {
    Location localLocation = new Location(paramInt1, paramInt2, paramInt3);
    return (String)this.tiles.get(localLocation);
  }

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
    for (Object localObject1 = this.tiles.keySet().iterator(); ((Iterator)localObject1).hasNext(); ) { Location localLocation = (Location)((Iterator)localObject1).next();

      String str1 = (String)this.tiles.get(localLocation);
      if (!localVector1.contains(str1))
        localVector1.add(str1);
    }
    MapPatcher.Systemoutprintln(new StringBuilder().append("We have ").append(localVector1.size()).append(" different tiles").toString());
    localObject1 = new String[] { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" };

    int i = 1;
    int j = localObject1.length;
    while (j < localVector1.size())
    {
      j *= localObject1.length;
      i++;
    }
    Vector localVector2;
    if (paramMap == null) {
      localVector2 = localVector1;
    }
    else {
      localVector2 = new Vector();
      for (Iterator localIterator = localVector1.iterator(); localIterator.hasNext(); ) { localObject2 = (String)localIterator.next();

        if (paramMap.codes_by_value.containsKey(localObject2))
        {
          localObject3 = paramMap.getIdFor((String)localObject2);
          this.tile_types.put(localObject3, localObject2);
          this.codes_by_value.put(localObject2, localObject3);
        }
        else {
          localVector2.add(localObject2);
        } }
      localVector1.clear();
    }

    int k = 0;
    for (Object localObject2 = localVector2.iterator(); ((Iterator)localObject2).hasNext(); ) { localObject3 = (String)((Iterator)localObject2).next();
      do
      {
        str2 = int2code((String[])localObject1, k, i);
        k++;
      }while (this.tile_types.containsKey(str2));
      this.tile_types.put(str2, localObject3);
      this.codes_by_value.put(localObject3, str2);
    }
    String str2;
    localVector2.clear();

    k = 0;
    for (int m = 0; m < this.tile_types.size(); m++)
    {
      do
      {
        localObject3 = int2code((String[])localObject1, k, i);
        k++;
      }while (!this.tile_types.containsKey(localObject3));
      str2 = (String)this.tile_types.get(localObject3);
      localFileWriter.write(new StringBuilder().append("\"").append((String)localObject3).append("\" = ").append(str2).append("\r\n").toString());
    }
    localVector2.clear();

    localFileWriter.write("\n");

    m = 1 + this.maxz - this.minz;
    Object localObject3 = new SavingThread[m];
    int n = (this.maxy - this.miny) * ((this.maxx - this.minx) * i + 2) + 32;

    for (k = 0; k < m; k++)
    {
      localObject3[k] = new SavingThread(this.minz + k, this, n);
      localObject3[k].start();
    }

    int i1 = 0;
    String str3 = "";
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

    for (k = 0; k < m; k++) {
      localFileWriter.write(localObject3[k].result.toString());
    }
    localFileWriter.flush();
    localFileWriter.close();
  }

  public String getIdFor(String paramString)
  {
    if (this.codes_by_value.containsKey(paramString))
    {
      return (String)this.codes_by_value.get(paramString);
    }
    return "???";
  }

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
