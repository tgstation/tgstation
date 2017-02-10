using System;
using System.IO;
using System.Xml;

namespace DMTreeToGlobalsList
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 1 || !File.Exists(args[0]))
            {
                Console.WriteLine("Usage: DMTreeToGlobalsList.exe <path to code tree xml> [Prefix] [Postfix]");
                return;
            }

            var XMLPath = args[0];
            string Prefix = "", Postfix = "";
            if (args.Length > 1)
            {
                Prefix = args[1];
                if (args.Length > 2)
                    Postfix = args[2];
            }

            XmlDocument Doc;
            using (var FS = new FileStream(XMLPath, FileMode.Open, FileAccess.Read))
            {
                try
                {
                    while (FS.ReadByte() != '<') ;
                }
                catch
                {
                    Console.WriteLine("Failed to find start point of XML in output");
                    return;
                }
                FS.Seek(-1, SeekOrigin.Current);

                Doc = new XmlDocument();
                try
                {
                    Doc.Load(FS);
                }
                catch
                {
                    Console.WriteLine("Failed to load the XML document");
                    return;
                }
            }
            try
            {
                var DMNode = Doc.ChildNodes[1];
                foreach (XmlNode Child in DMNode.ChildNodes)
                    if (Child.Name == "var")
                        Console.WriteLine(Prefix + Child.FirstChild.Value.Trim() + Postfix);
            }
            catch
            {
                Console.WriteLine("Failed parsing the XML");
                return;
            }
        }
    }
}
