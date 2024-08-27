using System;
using System.Drawing;

namespace obstacle_avoidance_poc
{
    internal class Algorithm
    {
        public static Tuple<double, double> Calculate(Bitmap bmp)
        {
            double sumx = 0, sumy = 0, norm = 0;
            for (int i = 0; i < bmp.Height; i++)
            {
                for (int j = 0; j < bmp.Width; j++)
                {
                    double weight = GetWeight(bmp.GetPixel(j, i).G);
                    sumx += weight * j;
                    sumy += weight * i;
                    norm += weight;
                }
            }
            sumx /= norm;
            sumy /= norm;
            return new Tuple<double, double>(sumx, sumy);
        }

        private static double GetWeight(int value)
        {
            const double FMAX = 1;
            const double NMIN = 0; // TODO Negative near weight
            const int FCUT = 100;
            const int NCUT = 155;
            const double PRAMP = -FMAX / FCUT;
            const double NRAMP = NMIN / (255 - NCUT);
            if (value >= FCUT && value <= NCUT) { return 0; }
            else if (value < FCUT) { return FMAX + value * PRAMP; }
            else { return (value - NCUT) * NRAMP; }
        }
    }
}
