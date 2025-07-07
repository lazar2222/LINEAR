using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace bus_tester
{
    class Transaction 
    {
        public enum TransactionType
        {
            Read,
            Write,
            None
        }

        public enum Source
        {
            SM0_IM = 10,
            SM0_DM = 11,
            SM1_IM = 20,
            SM1_DM = 21,
            HAB = 30
        }

        public enum Destination
        {
            IM0   = 0,
            DM0   = 2048,
            CM0   = 4096,
            CM0_1 = 6144,
            IM1   = 8192 + 0,
            DM1   = 8192 + 2048,
            CM1   = 8192 + 4096,
            CM1_1 = 8192 + 6144,
            SMC   = 16384,
            MISS  = 16384 + 1024
        }

        public Source source;
        public TransactionType type;
        public Destination dest;
        public int locadr;
        public int time;

        public Transaction(int time, int source, bool read, bool write, int addr)
        {
            this.time = time;
            this.source = (Source)source;
            this.type = read ? TransactionType.Read : write ? TransactionType.Write : TransactionType.None;
            this.dest = (Destination)((addr / 2048) * 2048);
            this.locadr = addr % 2048;
            if (dest == Destination.SMC && locadr == 1024) 
            {
                dest = Destination.MISS;
                locadr = 0;
            }
        }

        public override string ToString()
        {
            return $"{time} : {source} {type} {dest} {locadr}";
        }

        public void Assert() 
        {
            int ptc = 0;
            bool ptcz = false;
            int hit = 0;
            int complete = 0;
            int error = 0;
            if (source == Source.SM0_IM || source == Source.SM1_IM)
            {
                hit = (dest == Destination.IM0 || dest == Destination.IM1) ? 1 : 0;
            }
            else 
            { 
                hit = dest == Destination.MISS ? 0 : 1;
            }
            complete = (hit == 1 && type != TransactionType.None) ? 1 : 0;
            ptcz = !(complete == 1 && type == TransactionType.Read);
            ptc = (int)dest + locadr;
            if (ptcz)
            {
                //Program.AssertSignalHasZAtTime(time+100, $"testbench_bus/{source.ToString().ToLower()}/data_ptc");
            }
            else
            {
                Program.AssertSignalHasValueAtTime(time+100, $"testbench_bus/{source.ToString().ToLower()}/data_ptc", ptc);
            }
            Program.AssertSignalHasValueAtTime(time, $"testbench_bus/{source.ToString().ToLower()}/hit", hit);
            Program.AssertSignalHasValueAtTime(time, $"testbench_bus/{source.ToString().ToLower()}/complete", complete);
        }

    }

    internal class Program
    {
        static void Main(string[] args)
        {
            int time = 150;

            List<string> masters = new List<string>{ "testbench_bus/sm0_im", "testbench_bus/sm0_dm", "testbench_bus/sm1_im", "testbench_bus/sm1_dm", "testbench_bus/hab" };

            Console.WriteLine("Scanning transactions from 150");

            while (true) 
            {
                transactions.Add(time, new Dictionary<Transaction.Source, Transaction>());

                foreach (string master in masters)
                {
                    bool read = GetSignalValueAt(time, master + "/read") == "1";
                    bool write = GetSignalValueAt(time, master + "/write") == "1";
                    int ctp = Convert.ToInt32(new string(GetSignalValueAt(time, master + "/data_ctp").Reverse().ToArray()), 2);
                    int addr = Convert.ToInt32(new string(GetSignalValueAt(time, master + "/address").Reverse().ToArray()), 2);
                    int be = Convert.ToInt32(new string(GetSignalValueAt(time, master + "/byte_enable").Reverse().ToArray()), 2);
                    Transaction transaction = new Transaction(time, ctp, read, write, addr);
                    //Console.WriteLine(transaction.ToString());
                    transaction.Assert();
                    transactions[time].Add(transaction.source, transaction);
                }   

                time += 100;
                if (!timetoidx.ContainsKey(time + 100)) 
                {
                    break;
                }
            }

            Console.WriteLine();

            Console.WriteLine($"Checks complete {errors} errors in total");
        }

        private static void ParseLine(string v)
        {
            if (v.StartsWith("$")) 
            {
                if (v.StartsWith("$scope "))
                {
                    string[] splits = v.Split(' ');
                    if (splits[1] != "module") 
                    {
                        Console.WriteLine($"Unknown scope type {splits[1]}");
                    }
                    signalStack.Add(splits[2]);
                    if (splits[3] != "$end") 
                    {
                        Console.WriteLine($"$scope improper end");
                    }
                }
                else if(v.StartsWith("$var "))
                {
                    string[] splits = v.Split(' ');
                    if (splits[1] != "wire" && splits[1] != "reg")
                    {
                        Console.WriteLine($"Unknown var type {splits[1]}");
                    }
                    if (splits[2] != "1")
                    {
                        Console.WriteLine($"Unknown var width {splits[1]}");
                    }
                    string shorthand = splits[3];
                    string name = splits[4];
                    if (splits.Length == 7) 
                    {
                        string section = splits[5];
                        if (!section.StartsWith("[") || !section.EndsWith("]")) 
                        {
                            Console.WriteLine($"Unknown var section {section}");
                        }
                        section = section.Substring(1, section.Length - 2);
                        int iss = 0;
                        if (!int.TryParse(section, out iss)) 
                        {
                            Console.WriteLine($"Unknown var section {section}");
                        }
                        bitmap.Add(shorthand, iss);
                    }
                    sigmap.Add(shorthand, Hier() + name);
                    if (splits.Length != 6 && splits.Length != 7) 
                    {
                        Console.WriteLine($"Unknown var length {splits.Length}");
                    }
                    if (splits[splits.Length-1] != "$end")
                    {
                        Console.WriteLine($"$var improper end");
                    }
                }
                else if (v.StartsWith("$upscope "))
                {
                    string[] splits = v.Split(' ');
                    signalStack.RemoveAt(signalStack.Count - 1);
                    if (splits[1] != "$end")
                    {
                        Console.WriteLine($"$scope improper end");
                    }
                }
                else 
                {
                    Console.WriteLine($"Skipping Line {v}");
                }
            }
            else
            {
                if (v.StartsWith("#"))
                {
                    Console.WriteLine(v);
                    v = v.Substring(1);
                    times.Add(Convert.ToInt32(v));
                    timetoidx.Add(Convert.ToInt32(v), times.Count - 1);
                    currentTime = times.Count - 1;
                    values.Add(new Dictionary<string, string>());
                }
                else if (v.StartsWith("1"))
                {
                    v = v.Substring(1);
                    SetSignal(v, "1");
                    if (!values[currentTime].ContainsKey(sigmap[v]))
                    {
                    }
                    else 
                    {
                        if (values[currentTime][sigmap[v]] != "1" || currentTime != 0)
                        {
                            //Console.WriteLine($"ERROR Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is 1");
                        }
                        else 
                        {
                            //Console.WriteLine($"Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is 1");
                        }
                    }
                }
                else if (v.StartsWith("0"))
                {
                    v = v.Substring(1);
                    SetSignal(v, "0");
                    if (!values[currentTime].ContainsKey(sigmap[v]))
                    {
                    }
                    else
                    {
                        if (values[currentTime][sigmap[v]] != "0" || currentTime != 0)
                        {
                            //Console.WriteLine($"ERROR Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is 0");
                        }
                        else
                        {
                            //Console.WriteLine($"Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is 0");
                        }
                    }
                }
                else if (v.StartsWith("b1"))
                {
                    v = v.Substring(3);
                    SetSignal(v, "1");
                    if (!values[currentTime].ContainsKey(sigmap[v]))
                    {
                    }
                    else
                    {
                        if (values[currentTime][sigmap[v]] != "1" || currentTime != 0)
                        {
                            //Console.WriteLine($"ERROR Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is 1");
                        }
                        else
                        {
                            //Console.WriteLine($"Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is 1");
                        }
                    }
                }
                else if (v.StartsWith("b0"))
                {
                    v = v.Substring(3);
                    SetSignal(v, "0");
                    if (!values[currentTime].ContainsKey(sigmap[v]))
                    {
                    }
                    else
                    {
                        if (values[currentTime][sigmap[v]] != "0" || currentTime != 0)
                        {
                            //Console.WriteLine($"ERROR Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is 0");
                        }
                        else
                        {
                            //Console.WriteLine($"Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is 0");
                        }
                    }
                }
                else if (v.StartsWith("z"))
                {
                    v = v.Substring(1);
                    SetSignal(v, "z");
                    if (!values[currentTime].ContainsKey(sigmap[v]))
                    {
                    }
                    else
                    {
                        if (values[currentTime][sigmap[v]] != "z" || currentTime != 0)
                        {
                            //Console.WriteLine($"ERROR Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is z");
                        }
                        else
                        {
                            //Console.WriteLine($"Duplicate definition of {sigmap[v]}, last value was {values[currentTime][sigmap[v]]}, now is z");
                        }
                    }
                }
                else 
                {
                    Console.WriteLine($"Unknown spec {v}");
                }
            }
        }

        private static void SetSignal(string s, string v)
        {
            if (bitmap.ContainsKey(s))
            {
                SetSignal(s, v, bitmap[s]);
            }
            else if (!values[currentTime].ContainsKey(sigmap[s]))
            {
                values[currentTime].Add(sigmap[s], v);
            }
            else {
                //Console.WriteLine(sigmap[s]);
            }
        }

        private static void SetSignal(string s, string v1, int v2)
        {
            //Console.WriteLine($"Setting bit {v2} of {sigmap[s]} to {v1}");
            string prevVal = GetSignalValueAt(times[currentTime], sigmap[s]);
            if (!values[currentTime].ContainsKey(sigmap[s]))
            {

                values[currentTime].Add(sigmap[s], SetBit(prevVal, v1, v2));
            }
            else
            {
                values[currentTime][sigmap[s]]= SetBit(values[currentTime][sigmap[s]], v1, v2);
            }

        }

        private static string SetBit(string prevVal, string v1, int v2)
        {
            StringBuilder sb = new StringBuilder(prevVal);
            if (sb.Length <= v2) 
            {
                sb.Append(sb[sb.Length-1], v2 - sb.Length + 1);
            }
            sb[v2] = v1[0];
            return sb.ToString();
        }

        private static string Hier()
        {
            string h = "";
            foreach (string line in signalStack)
            {
                h += line + "/";
            }
            return h;
        }

        private static string GetSignalValueAt(int time, string signal) 
        {
            int idx = timetoidx[time];
            while (idx >= 0) 
            {
                if (values[idx].ContainsKey(signal)) 
                {
                    return values[idx][signal];
                }
                idx--;
            }
            return "x";
        }

        public static void AssertSignalHasValueAtTime(int time, string signal, int value) 
        {
            if (GetSignalValueAt(time, signal).Contains("z") || GetSignalValueAt(time, signal).Contains("x")) {
                Console.WriteLine($"ERROR signal {signal} at {time} has mixed value");
                errors++;
                return;
            }
            int av = Convert.ToInt32(new string(GetSignalValueAt(time, signal).Reverse().ToArray()), 2);
            if (av != value) 
            {
                Console.WriteLine($"ERROR signal {signal} at {time} has {av} instead of {value}");
                errors++;
                return;
            }
        }

        public static void AssertSignalHasZAtTime(int time, string signal)
        {
            string val = GetSignalValueAt(time, signal);
            foreach (char c in val)
            {
                if (c != 'z')
                {
                    Console.WriteLine($"ERROR signal {signal} at {time} is not z");
                    errors++;
                    return;
                }
            }
        }
    }
}
