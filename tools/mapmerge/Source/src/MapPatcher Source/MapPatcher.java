import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.Arrays;

public class MapPatcher
{
  static boolean silent = false;

  public static void main(String[] paramArrayOfString)
  {
    String str1 = "usage: [me] -diff [old_map] [new_map] [diff_file]";
    String str2 = "usage: [me] -patch [old_map] [diff_file] [new_map]";
    String str3 = "usage: [me] -pack [unpacked] [packed.dmm]";
    String str4 = "usage: [me] -unpack [packed.dmm] [unpacked]";
    String str5 = "usage: [me] -clean [oldmap.dmm] [newmap.dmm] [cleaned.dmm]";
    String str6 = "usage: [me] -merge [original] [local] [remote] [output]";

    for (int i = 0; i < paramArrayOfString.length; i++)
      if (paramArrayOfString[i].equalsIgnoreCase("-silent"))
      {
        silent = true;
        for (; i < paramArrayOfString.length - 1; i++)
          paramArrayOfString[i] = paramArrayOfString[(i + 1)];
        paramArrayOfString = (String[])Arrays.copyOf(paramArrayOfString, paramArrayOfString.length - 1);
        break;
      }
    Object localObject;
    int i2;
    int i3;
    int i5;
    if ((paramArrayOfString.length > 0) && (paramArrayOfString[0].equalsIgnoreCase("-merge")))
    {
      if (paramArrayOfString.length < 5)
      {
        System.out.println(str6);
        try { System.in.read(); } catch (Exception localException1) {
        }return;
      }

      Map localMap1 = new Map(new File(paramArrayOfString[1]));
      localObject = new Map(new File(paramArrayOfString[2]));
      Map localMap8 = new Map(new File(paramArrayOfString[3]));
      Map localMap9 = new Map();

      if ((localMap1.minx != ((Map)localObject).minx) || (localMap1.minx != localMap8.minx) || (localMap1.maxx != ((Map)localObject).maxx) || (localMap1.maxx != localMap8.maxx) || (localMap1.miny != ((Map)localObject).miny) || (localMap1.miny != localMap8.miny) || (localMap1.maxy != ((Map)localObject).maxy) || (localMap1.maxy != localMap8.maxy) || (localMap1.minz != ((Map)localObject).minz) || (localMap1.minz != localMap8.minz) || (localMap1.maxz != ((Map)localObject).maxz) || (localMap1.maxz != localMap8.maxz))
      {
        Systemoutprintln("Map sizes differ");
        System.exit(1);
      }
      try
      {
        for (int n = localMap1.minz; n <= localMap1.maxz; n++)
          for (i2 = localMap1.miny; i2 <= localMap1.maxy; i2++)
            for (i3 = localMap1.minx; i3 <= localMap1.maxx; i3++)
            {
              boolean bool1 = localMap1.contentAt(i3, i2, n).equals(((Map)localObject).contentAt(i3, i2, n));
              boolean bool2 = localMap1.contentAt(i3, i2, n).equals(localMap8.contentAt(i3, i2, n));
              i5 = ((Map)localObject).contentAt(i3, i2, n).equals(localMap8.contentAt(i3, i2, n));
              if ((!bool1) && (!bool2))
              {
                if (i5 == 0)
                {
                  Systemoutprintln(i3 + "," + i2 + "," + n + " local and remote don't match original and differ");
                  System.exit(1);
                }
                else {
                  localMap9.setAt(i3, i2, n, ((Map)localObject).contentAt(i3, i2, n));
                }
              } else if (!bool1)
                localMap9.setAt(i3, i2, n, ((Map)localObject).contentAt(i3, i2, n));
              else if (!bool2)
                localMap9.setAt(i3, i2, n, localMap8.contentAt(i3, i2, n));
              else
                localMap9.setAt(i3, i2, n, localMap1.contentAt(i3, i2, n));
            }
        Systemoutprintln("Saving");
        localMap9.saveReferencing(new File(paramArrayOfString[4]), localMap1);
        Systemoutprintln("Done");
      }
      catch (Exception localException12)
      {
        localException12.printStackTrace();
      }
    }
    else
    {
      int m;
      int i1;
      if ((paramArrayOfString.length > 0) && (paramArrayOfString[0].equalsIgnoreCase("-diff")))
      {
        if (paramArrayOfString.length < 4)
        {
          System.out.println(str1);
          try { System.in.read(); } catch (Exception localException2) {
          }return;
        }

        Map localMap2 = new Map(new File(paramArrayOfString[1]));
        localObject = new Map(new File(paramArrayOfString[2]));

        int j = Math.max(localMap2.minx, ((Map)localObject).minx);
        m = Math.min(localMap2.maxx, ((Map)localObject).maxx);
        i1 = Math.max(localMap2.miny, ((Map)localObject).miny);
        i2 = Math.min(localMap2.maxy, ((Map)localObject).maxy);
        i3 = Math.max(localMap2.minz, ((Map)localObject).minz);
        int i4 = Math.min(localMap2.maxz, ((Map)localObject).maxz);
        Systemoutprintln("Comparing: x(" + j + "-" + m + ") y(" + i1 + "-" + i2 + ") z(" + i3 + "-" + i4 + ")");
        try
        {
          FileWriter localFileWriter2 = new FileWriter(paramArrayOfString[3]);
          i5 = 0;
          for (int i6 = i3; i6 <= i4; i6++)
          {
            Systemoutprintln("Z-level " + i6);
            for (int i7 = i1; i7 <= i2; i7++)
              for (int i8 = j; i8 <= m; i8++)
                if (!localMap2.contentAt(i8, i7, i6).equals(((Map)localObject).contentAt(i8, i7, i6)))
                {
                  localFileWriter2.write("(" + i8 + "," + (1 + ((Map)localObject).maxy - i7) + "," + i6 + ")=" + ((Map)localObject).contentAt(i8, i7, i6) + "\n");
                  i5++;
                }
          }
          localFileWriter2.flush();
          localFileWriter2.close();
          if (i5 == 0)
            Systemoutprintln("Files do match");
          else
            Systemoutprintln("Writed out " + i5 + " differences");
        }
        catch (Exception localException13)
        {
          localException13.printStackTrace();
        }

        Systemoutprintln("Done");
      }
      else
      {
        String str7;
        String str8;
        if ((paramArrayOfString.length > 0) && (paramArrayOfString[0].equalsIgnoreCase("-patch")))
        {
          if (paramArrayOfString.length < 4)
          {
            System.out.println(str2);
            try { System.in.read(); } catch (Exception localException3) {
            }return;
          }

          Map localMap3 = new Map(new File(paramArrayOfString[1]));
          try
          {
            localObject = new BufferedReader(new InputStreamReader(new FileInputStream(paramArrayOfString[2])));

            while ((str7 = ((BufferedReader)localObject).readLine()) != null)
            {
              str7 = str7.trim();
              if (str7.length() != 0)
              {
                m = str7.indexOf(",", 1);
                i1 = Integer.parseInt(str7.substring(1, m));
                str7 = str7.substring(m);
                m = str7.indexOf(",", 1);
                i2 = Integer.parseInt(str7.substring(1, m));
                str7 = str7.substring(m);
                m = str7.indexOf(")", 1);
                i3 = Integer.parseInt(str7.substring(1, m));
                str8 = str7.substring(str7.indexOf("=") + 1);
                localMap3.setAt(i1, 1 + localMap3.maxy - i2, i3, str8);
              }
            }
            localMap3.save(new File(paramArrayOfString[3]));
          }
          catch (Exception localException8)
          {
            localException8.printStackTrace();
          }

          Systemoutprintln("Done");
        }
        else if ((paramArrayOfString.length > 0) && (paramArrayOfString[0].equalsIgnoreCase("-pack")))
        {
          if (paramArrayOfString.length < 3)
          {
            System.out.println(str3);
            try { System.in.read(); } catch (Exception localException4) {
            }return;
          }

          Map localMap4 = new Map();
          try {
            BufferedReader localBufferedReader = new BufferedReader(new InputStreamReader(new FileInputStream(paramArrayOfString[1])));
            Systemoutprintln("Loading");

            while ((str7 = localBufferedReader.readLine()) != null)
            {
              str7 = str7.trim();
              if (str7.length() != 0)
              {
                m = str7.indexOf(",", 1);
                i1 = Integer.parseInt(str7.substring(1, m));
                str7 = str7.substring(m);
                m = str7.indexOf(",", 1);
                i2 = Integer.parseInt(str7.substring(1, m));
                str7 = str7.substring(m);
                m = str7.indexOf(")", 1);
                i3 = Integer.parseInt(str7.substring(1, m));
                str8 = str7.substring(str7.indexOf("=") + 1);
                localMap4.setAt(i1, i2, i3, str8);
              }
            }
            Systemoutprintln("Flipping");
            localMap4.mirrorY();
            Systemoutprintln("Saving, bounds: x{" + localMap4.minx + " - " + localMap4.maxx + "}, y{" + localMap4.miny + " - " + localMap4.maxy + "}, z{" + localMap4.minz + " - " + localMap4.maxz + "}");
            localMap4.save(new File(paramArrayOfString[2]));
            Systemoutprintln("Done");
          }
          catch (Exception localException9)
          {
            localException9.printStackTrace();
          }
        }
        else if ((paramArrayOfString.length > 0) && (paramArrayOfString[0].equalsIgnoreCase("-unpack")))
        {
          if (paramArrayOfString.length < 3)
          {
            System.out.println(str4);
            try { System.in.read(); } catch (Exception localException5) {
            }return;
          }

          Systemoutprintln("Loading");
          Map localMap5 = new Map(new File(paramArrayOfString[1]));
          try {
            FileWriter localFileWriter1 = new FileWriter(paramArrayOfString[2]);
            Systemoutprintln("Saving");
            for (int k = localMap5.minz; k <= localMap5.maxz; k++)
            {
              Systemoutprintln("Z-level " + k);
              for (m = localMap5.miny; m <= localMap5.maxy; m++)
                for (i1 = localMap5.minx; i1 <= localMap5.maxx; i1++)
                  localFileWriter1.write("(" + i1 + "," + (1 + localMap5.maxy - m) + "," + k + ")=" + localMap5.contentAt(i1, m, k) + "\n");
              localFileWriter1.write("\n");
            }
            localFileWriter1.flush();
            localFileWriter1.close();

            Systemoutprintln("Done");
          }
          catch (Exception localException10)
          {
            localException10.printStackTrace();
          }
        }
        else if ((paramArrayOfString.length > 0) && (paramArrayOfString[0].equalsIgnoreCase("-clean")))
        {
          if (paramArrayOfString.length < 4)
          {
            System.out.println(str5);
            try { System.in.read(); } catch (Exception localException6) {
            }return;
          }

          Map localMap6 = new Map(new File(paramArrayOfString[1]), true);
          Map localMap7 = new Map(new File(paramArrayOfString[2]));
          try
          {
            localMap7.saveReferencing(new File(paramArrayOfString[3]), localMap6);
            Systemoutprintln("Done");
          }
          catch (Exception localException11)
          {
            localException11.printStackTrace();
          }
        }
        else
        {
          System.out.println(str1);
          System.out.println(str2);
          System.out.println(str3);
          System.out.println(str4);
          System.out.println(str5);
          System.out.println(str6);
          try {
            System.in.read(); } catch (Exception localException7) {  }
        }
      }
    }
  }

  public static void Systemoutprintln(String paramString) { if (!silent)
      System.out.println(paramString); }

  public static void Systemoutprint(String paramString)
  {
    if (!silent)
      System.out.print(paramString);
  }
}
