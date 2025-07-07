using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace COMTEST
{
    internal class Program
    {
        private static SerialPort com;

        private static void Transmit(uint data)
        {
            byte[] buffer = new byte[4];
            buffer[0] = (byte)(data >> 24);
            buffer[1] = (byte)(data >> 16);
            buffer[2] = (byte)(data >> 8);
            buffer[3] = (byte)(data);
            com.Write(buffer, 0, 4);
        }

        private static uint Receive()
        {
            byte[] buffer = new byte[4];
            com.Read(buffer, 0, 4);
            return (uint)(buffer[0] << 24 | buffer[1] << 16 | buffer[2] << 8 | buffer[3]);
        }

        private static void Write(uint address, uint data) 
        {
            uint address_part = 0x80000000 | (address >> 2);
            Transmit(address_part);
            Transmit(data);
        }

        private static void Write(uint address, uint[] data)
        {
            uint address_part = 0x90000000 | (address >> 2);
            Transmit(address_part);
            Transmit((uint)data.Length);
            foreach (uint d in data)
            {
                Transmit(d);
            }
        }

        private static uint Read(uint address)
        {
            uint address_part = 0x40000000 | (address >> 2);
            Transmit(address_part);
            return Receive();
        }

        private static uint[] Read(uint address, int count)
        {
            uint[] res = new uint[count];
            uint address_part = 0x40000000 | (address >> 2);
            for (int i = 0; i < count; i++)
            {
                Transmit(address_part);
                res[i] = Receive();
            }
            return res;
        }

        private const uint MEM_BASE = 0;
        private const uint VGA_BASE = 512 * 1024;
        private const uint VGA_CONF = VGA_BASE + 8;

        static void Main(string[] args)
        {
            com = new SerialPort("COM3", 1000000, Parity.None, 8, StopBits.One);
            com.Open();

            Write(VGA_CONF, 0x00000009); // PVS[1:0], MONO || COMPACT, BFF, DB, EN;

            for (uint i = 0; i < 640 * 480 / 8; i++)
            {
                Write(MEM_BASE + i * 4, 0x0);
            }

            for (uint i = 0; i < 640 * 480 / 8; i++)
            {
                Write(MEM_BASE + i * 4, 0x12345678);
            }

            for (uint i = 0; i < 640 * 480 / 8; i++)
            {
                Write(MEM_BASE + 640 * 480 / 2 + i * 4, 0x87654321);
            }

            while (true) 
            {
                Console.Write(">>");
                string[] cmd = Console.ReadLine().Trim(' ').Split(' ');
                if (cmd[0].ToLower() == "r")
                {
                    uint address;
                    if (cmd[1].ToLower().StartsWith("0x")) 
                    {
                        address = Convert.ToUInt32(cmd[1], 16);
                    }
                    else
                    {
                        address = Convert.ToUInt32(cmd[1]);
                    }
                    uint res = Read(address);
                    Console.WriteLine("0x{0:X} {0}", res);
                }
                else if (cmd[0].ToLower() == "w")
                {
                    uint address;
                    uint data;
                    if (cmd[1].ToLower().StartsWith("0x"))
                    {
                        address = Convert.ToUInt32(cmd[1], 16);
                    }
                    else
                    {
                        address = Convert.ToUInt32(cmd[1]);
                    }
                    if (cmd[2].ToLower().StartsWith("0x"))
                    {
                        data = Convert.ToUInt32(cmd[2], 16);
                    }
                    else
                    {
                        data = Convert.ToUInt32(cmd[2]);
                    }
                    Write(address, data);
                }  
            }
        }
    }
}
