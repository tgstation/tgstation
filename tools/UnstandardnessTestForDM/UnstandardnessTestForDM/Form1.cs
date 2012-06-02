using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using System.IO;

namespace UnstandardnessTestForDM
{
    public partial class Form1 : Form
    {
        DMSource source;

        public Form1()
        {
            InitializeComponent();
            source = new DMSource();
            source.mainform = this;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            source.find_all_defines();
            generate_define_report();
        }

        public void generate_define_report()
        {

            TextWriter tw = new StreamWriter("DEFINES REPORT.txt");

            tw.WriteLine("Unstandardness Test For DM report for DEFINES");
            tw.WriteLine("Generated on " + DateTime.Now);
            tw.WriteLine("Total number of defines " + source.defines.Count());
            tw.WriteLine("Total number of Files " + source.filessearched);
            tw.WriteLine("Total number of references " + source.totalreferences);
            tw.WriteLine("Total number of errorous defines " + source.errordefines);
            tw.WriteLine("------------------------------------------------");

            foreach (Define d in source.defines)
            {
                tw.WriteLine(d.name);
                tw.WriteLine("\tValue: " + d.value);
                tw.WriteLine("\tComment: " + d.comment);
                tw.WriteLine("\tDefined in: " + d.location + " : " + d.line);
                tw.WriteLine("\tNumber of references: " + d.references.Count());
                foreach (String s in d.references)
                {
                    tw.WriteLine("\t\t" + s);
                }
            }

            tw.WriteLine("------------------------------------------------");
            tw.WriteLine("SUCCESS");

            tw.Close();

        }

        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                Define d = (Define)listBox1.Items[listBox1.SelectedIndex];
                label1.Text = d.name;
                label2.Text = "Defined in: " + d.location + " : " + d.line;
                label3.Text = "Value: " + d.value;
                label4.Text = "References: " + d.references.Count();
                listBox2.Items.Clear();
                foreach (String s in d.references)
                {
                    listBox2.Items.Add(s);
                }

            }
            catch (Exception ex) { Console.WriteLine("ERROR HERE: " + ex.Message); }
        }


    }

    public class DMSource
    {
        public List<Define> defines;
        public const int FLAG_DEFINE = 1;
        public Form1 mainform;

        public int filessearched = 0;
        public int totalreferences = 0;
        public int errordefines = 0;

        public DMSource()
        {
            defines = new List<Define>();
        }

        public void find_all_defines()
        {
            DirSearch(".", FLAG_DEFINE);
        }



        
        public void DirSearch(string sDir, int flag)
        {
            try
            {
                foreach (string d in Directory.GetDirectories(sDir))
                {
                    foreach (string f in Directory.GetFiles(d))
                    {
                        if (f.ToLower().EndsWith(".dm"))
                        {
                            if ((flag & FLAG_DEFINE) > 0)
                            {
                                searchFileForDefines(f);
                            }
                        }
                    }
                    DirSearch(d, flag);
                }
            }
            catch (System.Exception excpt)
            {
                Console.WriteLine(excpt.Message);
            }
        }

        //DEFINES
        public void searchFileForDefines(String fileName)
        {
            filessearched++;
            FileInfo f = new FileInfo(fileName);
            List<String> lines = new List<String>();
            mainform.label5.Text = "Files searched: " + filessearched + "; Defines found: " + defines.Count() + "; References found: " + totalreferences + "; Errorous defines: " + errordefines;
            mainform.label5.Refresh();

            //This code segment reads the file and stores it into the lines variable.
            using (var reader = File.OpenText(fileName))
            {
                try
                {
                    String s;
                    while (true)
                    {
                        s = reader.ReadLine();
                        lines.Add(s);
                        s = s.Trim(' ');
                        if (s == "") { continue; }
                    }
                }
                catch { }
            }

            try
            {
                for (int i = 0; i < lines.Count; i++)
                {
                    String line = lines[i];

                    if (!(line is string))
                        continue;

                    //Console.WriteLine("LINE: " + line);

                    foreach (Define define in defines)
                    {

                        if (line.IndexOf(define.name) >= 0)
                        {
                            define.references.Add(fileName + " : " + i);
                            totalreferences++;
                        }
                    }

                    if( line.ToLower().IndexOf("#define") >= 0 )
                    {
                        line = line.Trim();
                        line = line.Replace('\t', ' ');
                        //Console.WriteLine("LINE = "+line);
                        String[] slist = line.Split(' ');
                        if(slist.Length >= 3){
                            //slist[0] has the value of "#define"
                            String name = slist[1];
                            String value = slist[2];

                            for (int j = 3; j < slist.Length; j++)
                            {
                                value += " " + slist[j];
                                //Console.WriteLine("LISTITEM["+j+"] = "+slist[j]);
                            }

                            value = value.Trim();

                            String comment = "";

                            if (value.IndexOf("//") >= 0)
                            {
                                comment = value.Substring(value.IndexOf("//"));
                                value = value.Substring(0, value.IndexOf("//"));
                            }

                            comment = comment.Trim();
                            value = value.Trim();
                        
                            Define d = new Define(fileName,i,name,value,comment);
                            defines.Add(d);
                            mainform.listBox1.Items.Add(d);
                            mainform.listBox1.Refresh();
                        }else{
                            Define d = new Define(fileName, i, "ERROR ERROR", "Something went wrong here", line);
                            errordefines++;
                            defines.Add(d);
                            mainform.listBox1.Items.Add(d);
                            mainform.listBox1.Refresh();
                        }
                    }
                }
            }
            catch (Exception e) { 
                Console.WriteLine(e.Message);
                Console.WriteLine(e.StackTrace);
                MessageBox.Show("Exception: " + e.Message + " | " + e.ToString());
            }
        }
    }

    public class Define
    {
        public String location;
        public int line;
        public String name;
        public String value;
        public String comment;
        public List<String> references;

        public Define(String location, int line, String name, String value, String comment)
        {
            this.location = location;
            this.line = line;
            this.name = name;
            this.value = value;
            this.comment = comment;
            this.references = new List<String>();
        }

        public override String ToString()
        {
            return "DEFINE: \""+name+"\" is defined as \""+value+"\" AT "+location+" : "+line;
        }

    }




}
