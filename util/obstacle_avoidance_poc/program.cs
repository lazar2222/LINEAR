using System;
using System.Windows.Forms;

namespace obstacle_avoidance_poc
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Gui());
        }
    }
}
