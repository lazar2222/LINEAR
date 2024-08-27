using System;
using System.Drawing;
using System.Windows.Forms;

namespace obstacle_avoidance_poc
{
    public partial class Gui : Form
    {
        Bitmap bitmap;
        Graphics graphics;
        SolidBrush brush;
        int size;

        public Gui()
        {
            InitializeComponent();

            bitmap = new Bitmap(frame.Width, frame.Height);
            graphics = Graphics.FromImage(bitmap);
            graphics.Clear(Color.Black);
            frame.Image = bitmap;
            colorPicker.BackColor = Color.White;
            brush = new SolidBrush(colorPicker.BackColor);
            brushSize.Value = 40;
            size = (int)brushSize.Value;
        }

        private void frame_MouseMove(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                graphics.FillRectangle(brush, e.X - (size / 2), e.Y - (size / 2), size, size);
                frame.Refresh();
            }
        }

        private void btnFill_Click(object sender, EventArgs e)
        {
            graphics.Clear(colorPicker.BackColor);
            frame.Refresh();
        }

        private void colorPicker_Click(object sender, EventArgs e)
        {
            colorPicker.BackColor = colorPicker.BackColor == Color.Black ? Color.White : Color.Black;
            brush.Color = colorPicker.BackColor;
        }

        private void brushSize_ValueChanged(object sender, EventArgs e)
        {
            size = (int)brushSize.Value;
        }

        private void btnCalc_Click(object sender, EventArgs e)
        {
            Tuple<double, double> position = Algorithm.Calculate(bitmap);
            resultList.Items.Add($"X={position.Item1,-7:F3} Y={position.Item2,-7:F3}");
            graphics.FillEllipse(Brushes.Blue, (float)position.Item1 - 5, (float)position.Item2 - 5, 10, 10);
            frame.Refresh();
        }

        private void resultList_DoubleClick(object sender, EventArgs e)
        {
            resultList.Items.Clear();
        }
    }
}
