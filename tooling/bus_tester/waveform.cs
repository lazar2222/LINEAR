using System.Collections.Generic;
using System.IO;

namespace bus_tester
{
    internal class Waveform
    {
        public List<int> timestamps;
        public List<Dictionary<string, string>> values;

        private Waveform() 
        {
        }

        public static Waveform Parse(string path) 
        {
            Dictionary<string, string> shorthandToName = new Dictionary<string, string>();
            Dictionary<string, int> shorthandToBit = new Dictionary<string, int>();

            List<string> signalNameStack = new List<string>();

            Waveform w = new Waveform();

            StreamReader sr = new StreamReader(path);

            while (!sr.EndOfStream)
            {
                ParseLine(sr.ReadLine(), shorthandToName, shorthandToBit, signalNameStack, w);
            }

            sr.Close();

            return w;
        }

        private static void ParseLine(string line, Dictionary<string, string> shorthandToName, Dictionary<string, int> shorthandToBit, List<string> signalNameStack, Waveform w)
        {
            if (line.StartsWith("$"))
            {
                ParseCommand(line, shorthandToName, shorthandToBit, signalNameStack);
            }
            else 
            {
                ParseValueChange(line, shorthandToName, shorthandToBit, w);
            }
        }

        private static void ParseCommand(string line, Dictionary<string, string> shorthandToName, Dictionary<string, int> shorthandToBit, List<string> signalNameStack)
        {
            string[] parts = line.Split(' ');

            if (parts[0] == "$var")
            {
                string shorthand = parts[2];
                string name = parts[3];
                int bit = int.Parse(parts[4]);

                shorthandToName[shorthand] = name;
                shorthandToBit[shorthand] = bit;
            }
            else if (parts[0] == "$dumpvars")
            {
                w.values = new List<Dictionary<string, string>>();
                w.timestamps = new List<int>();
            }
            else if (parts[0] == "$enddefinitions")
            {
                // Do nothing
            }
            else if (parts[0] == "$dumpall")
            {
                // Do nothing
            }
            else if (parts[0] == "$end")
            {
                // Do nothing
            }
            else if (parts[0] == "$scope")
            {
                signalNameStack.Add(parts[2]);
            }
            else if (parts[0] == "$upscope")
            {
                signalNameStack.RemoveAt(signalNameStack.Count - 1);
            }
            else
            {
                // Do nothing
            }
        }
    }
}
