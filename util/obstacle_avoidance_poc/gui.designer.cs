namespace obstacle_avoidance_poc
{
    partial class Gui
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.frame = new System.Windows.Forms.PictureBox();
            this.btnFill = new System.Windows.Forms.Button();
            this.colorPicker = new System.Windows.Forms.Label();
            this.btnCalc = new System.Windows.Forms.Button();
            this.brushSize = new System.Windows.Forms.NumericUpDown();
            this.resultList = new System.Windows.Forms.ListBox();
            ((System.ComponentModel.ISupportInitialize)(this.frame)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.brushSize)).BeginInit();
            this.SuspendLayout();
            // 
            // frame
            // 
            this.frame.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.frame.Location = new System.Drawing.Point(12, 12);
            this.frame.Name = "frame";
            this.frame.Size = new System.Drawing.Size(640, 480);
            this.frame.TabIndex = 0;
            this.frame.TabStop = false;
            this.frame.MouseMove += new System.Windows.Forms.MouseEventHandler(this.frame_MouseMove);
            // 
            // btnFill
            // 
            this.btnFill.Location = new System.Drawing.Point(658, 12);
            this.btnFill.Name = "btnFill";
            this.btnFill.Size = new System.Drawing.Size(109, 23);
            this.btnFill.TabIndex = 1;
            this.btnFill.Text = "Fill";
            this.btnFill.Click += new System.EventHandler(this.btnFill_Click);
            // 
            // colorPicker
            // 
            this.colorPicker.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.colorPicker.Location = new System.Drawing.Point(773, 12);
            this.colorPicker.Name = "colorPicker";
            this.colorPicker.Size = new System.Drawing.Size(23, 23);
            this.colorPicker.TabIndex = 2;
            this.colorPicker.Click += new System.EventHandler(this.colorPicker_Click);
            // 
            // btnCalc
            // 
            this.btnCalc.Location = new System.Drawing.Point(658, 67);
            this.btnCalc.Name = "btnCalc";
            this.btnCalc.Size = new System.Drawing.Size(138, 23);
            this.btnCalc.TabIndex = 3;
            this.btnCalc.Text = "Calculate";
            this.btnCalc.Click += new System.EventHandler(this.btnCalc_Click);
            // 
            // brushSize
            // 
            this.brushSize.Location = new System.Drawing.Point(658, 41);
            this.brushSize.Maximum = new decimal(new int[] {
            320,
            0,
            0,
            0});
            this.brushSize.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.brushSize.Name = "brushSize";
            this.brushSize.Size = new System.Drawing.Size(138, 20);
            this.brushSize.TabIndex = 4;
            this.brushSize.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.brushSize.ValueChanged += new System.EventHandler(this.brushSize_ValueChanged);
            // 
            // resultList
            // 
            this.resultList.Location = new System.Drawing.Point(658, 98);
            this.resultList.Name = "resultList";
            this.resultList.Size = new System.Drawing.Size(138, 394);
            this.resultList.TabIndex = 5;
            this.resultList.DoubleClick += new System.EventHandler(this.resultList_DoubleClick);
            // 
            // Gui
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(808, 504);
            this.Controls.Add(this.resultList);
            this.Controls.Add(this.brushSize);
            this.Controls.Add(this.btnCalc);
            this.Controls.Add(this.colorPicker);
            this.Controls.Add(this.btnFill);
            this.Controls.Add(this.frame);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "Gui";
            this.ShowIcon = false;
            this.Text = "obstacle_avoidance_poc";
            ((System.ComponentModel.ISupportInitialize)(this.frame)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.brushSize)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PictureBox frame;
        private System.Windows.Forms.Button btnFill;
        private System.Windows.Forms.Label colorPicker;
        private System.Windows.Forms.Button btnCalc;
        private System.Windows.Forms.NumericUpDown brushSize;
        private System.Windows.Forms.ListBox resultList;
    }
}
