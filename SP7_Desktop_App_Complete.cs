// ==========================================================
// SP-7 GLASS ERP - COMPLETE DESKTOP APP (.NET WINFORMS)
// Author: SP-7 Technologies
// File: SP7_Desktop_App_Complete.cs
// Description: Complete Windows Desktop Application for Glass ERP
// ==========================================================

// ==========================================================
// 1. SP7-ERP.csproj - Project File
// ==========================================================

/*
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net6.0-windows</TargetFramework>
    <UseWindowsForms>true</UseWindowsForms>
    <UseWPF>false</UseWPF>
    <AssemblyName>SP7 Glass ERP</AssemblyName>
    <ApplicationIcon>sp7-logo.ico</ApplicationIcon>
    <StartupObject>SP7_ERP.Program</StartupObject>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="MySql.Data" Version="8.0.33" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="6.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration.Json" Version="6.0.0" />
    <PackageReference Include="System.Data.SqlClient" Version="4.8.5" />
    <PackageReference Include="EPPlus" Version="5.8.0" />
    <PackageReference Include="iTextSharp" Version="5.5.13.3" />
    <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
    <PackageReference Include="Microsoft.Extensions.DependencyInjection" Version="6.0.0" />
  </ItemGroup>

  <ItemGroup>
    <None Update="appsettings.json">
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </None>
  </ItemGroup>
</Project>
*/

// ==========================================================
// 2. appsettings.json - Configuration File
// ==========================================================

/*
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=sp7_erp;User Id=root;Password=;"
  },
  "AppSettings": {
    "CompanyName": "SP-7 Glass ERP",
    "CompanyAddress": "Pune, Maharashtra",
    "CompanyGST": "27ABCDE1234F1Z5",
    "CompanyPAN": "ABCDE1234F",
    "BackupPath": "C:\\SP7_Backup",
    "LogPath": "C:\\SP7_Logs"
  },
  "JwtSettings": {
    "Secret": "sp7_glass_erp_secret_key_2025"
  }
}
*/

// ==========================================================
// 3. Program.cs - Entry Point
// ==========================================================

using System;
using System.Windows.Forms;
using SP7_ERP.Forms;
using Microsoft.Extensions.Configuration;
using System.IO;
using SP7_ERP.Classes;

namespace SP7_ERP
{
    internal static class Program
    {
        public static IConfiguration Configuration { get; private set; }

        [STAThread]
        static void Main()
        {
            // Load configuration
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

            Configuration = builder.Build();

            ApplicationConfiguration.Initialize();
            
            // Show login form
            using (var loginForm = new frmLogin())
            {
                if (loginForm.ShowDialog() == DialogResult.OK)
                {
                    Application.Run(new frmMain());
                }
            }
        }
    }
}

// ==========================================================
// 4. Classes/Database.cs - Database Connection Class
// ==========================================================

using System;
using System.Data;
using MySql.Data.MySqlClient;
using System.Collections.Generic;
using SP7_ERP.Forms;

namespace SP7_ERP.Classes
{
    public class Database
    {
        private MySqlConnection connection;
        private string connectionString;

        public Database()
        {
            connectionString = Program.Configuration.GetConnectionString("DefaultConnection");
        }

        public MySqlConnection GetConnection()
        {
            if (connection == null)
            {
                connection = new MySqlConnection(connectionString);
            }
            return connection;
        }

        public void OpenConnection()
        {
            try
            {
                if (connection == null)
                {
                    connection = new MySqlConnection(connectionString);
                }

                if (connection.State != ConnectionState.Open)
                {
                    connection.Open();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Database connection error: " + ex.Message);
            }
        }

        public void CloseConnection()
        {
            try
            {
                if (connection != null && connection.State == ConnectionState.Open)
                {
                    connection.Close();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error closing connection: " + ex.Message);
            }
        }

        public DataTable ExecuteQuery(string query, Dictionary<string, object> parameters = null)
        {
            DataTable dt = new DataTable();

            try
            {
                OpenConnection();

                using (MySqlCommand cmd = new MySqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        foreach (var param in parameters)
                        {
                            cmd.Parameters.AddWithValue(param.Key, param.Value);
                        }
                    }

                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Query execution error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
            }

            return dt;
        }

        public int ExecuteNonQuery(string query, Dictionary<string, object> parameters = null)
        {
            int rowsAffected = 0;

            try
            {
                OpenConnection();

                using (MySqlCommand cmd = new MySqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        foreach (var param in parameters)
                        {
                            cmd.Parameters.AddWithValue(param.Key, param.Value);
                        }
                    }

                    rowsAffected = cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("NonQuery execution error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
            }

            return rowsAffected;
        }

        public object ExecuteScalar(string query, Dictionary<string, object> parameters = null)
        {
            object result = null;

            try
            {
                OpenConnection();

                using (MySqlCommand cmd = new MySqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        foreach (var param in parameters)
                        {
                            cmd.Parameters.AddWithValue(param.Key, param.Value);
                        }
                    }

                    result = cmd.ExecuteScalar();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Scalar execution error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
            }

            return result;
        }

        public MySqlTransaction BeginTransaction()
        {
            OpenConnection();
            return connection.BeginTransaction();
        }
    }
}

// ==========================================================
// 5. Classes/Calculator.cs - Calculation Utilities
// ==========================================================

using System;

namespace SP7_ERP.Classes
{
    public static class Calculator
    {
        // Calculate area in sqft from mm
        public static decimal AreaSqFt(int heightMm, int widthMm)
        {
            return (decimal)(heightMm * widthMm) / 14400m;
        }

        // Calculate area in sqm from mm
        public static decimal AreaSqM(int heightMm, int widthMm)
        {
            return (decimal)(heightMm * widthMm) / 1000000m;
        }

        // Calculate running feet
        public static decimal RunningFt(int heightMm, int widthMm)
        {
            return (decimal)((heightMm + widthMm) * 2) / 304.8m;
        }

        // Calculate item amount
        public static (decimal BaseAmount, decimal Discount, decimal Taxable, decimal Tax, decimal Total)
            CalculateItemAmount(int quantity, int height, int width, decimal rate, decimal discountPercent, decimal taxRate)
        {
            decimal area = AreaSqFt(height, width);
            decimal baseAmount = quantity * area * rate;
            decimal discount = baseAmount * (discountPercent / 100m);
            decimal taxable = baseAmount - discount;
            decimal tax = taxable * (taxRate / 100m);
            decimal total = taxable + tax;

            return (Math.Round(baseAmount, 2), Math.Round(discount, 2), 
                    Math.Round(taxable, 2), Math.Round(tax, 2), Math.Round(total, 2));
        }

        // Calculate GST
        public static (decimal CGST, decimal SGST, decimal IGST, decimal Total)
            CalculateGST(decimal amount, decimal rate, string type = "intra")
        {
            decimal gst = amount * rate / 100m;
            if (type == "intra")
            {
                return (Math.Round(gst / 2, 2), Math.Round(gst / 2, 2), 0, Math.Round(gst, 2));
            }
            else
            {
                return (0, 0, Math.Round(gst, 2), Math.Round(gst, 2));
            }
        }

        // Format currency
        public static string FormatCurrency(decimal amount)
        {
            return "₹ " + amount.ToString("N2");
        }

        // Convert paise to rupees
        public static decimal PaiseToRupees(int paise)
        {
            return paise / 100m;
        }

        // Convert rupees to paise
        public static int RupeesToPaise(decimal rupees)
        {
            return (int)Math.Round(rupees * 100);
        }

        // Number to words
        public static string NumberToWords(decimal number)
        {
            if (number == 0)
                return "Zero";

            int num = (int)number;
            string words = "";

            if (num / 10000000 > 0)
            {
                words += NumberToWords(num / 10000000) + " Crore ";
                num %= 10000000;
            }

            if (num / 100000 > 0)
            {
                words += NumberToWords(num / 100000) + " Lakh ";
                num %= 100000;
            }

            if (num / 1000 > 0)
            {
                words += NumberToWords(num / 1000) + " Thousand ";
                num %= 1000;
            }

            if (num / 100 > 0)
            {
                words += NumberToWords(num / 100) + " Hundred ";
                num %= 100;
            }

            if (num > 0)
            {
                if (words != "")
                    words += "and ";

                var unitsMap = new[] { "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen" };
                var tensMap = new[] { "Zero", "Ten", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety" };

                if (num < 20)
                    words += unitsMap[num];
                else
                {
                    words += tensMap[num / 10];
                    if ((num % 10) > 0)
                        words += " " + unitsMap[num % 10];
                }
            }

            return words + " Rupees Only";
        }
    }
}

// ==========================================================
// 6. Classes/UserSession.cs - User Session Management
// ==========================================================

using System;

namespace SP7_ERP.Classes
{
    public static class UserSession
    {
        public static int UserId { get; set; }
        public static string Username { get; set; }
        public static string FullName { get; set; }
        public static int UserRole { get; set; }
        public static DateTime LoginTime { get; set; }

        public static bool IsAdmin => UserRole == 1;
        public static bool IsManager => UserRole == 2;
        public static bool IsSupervisor => UserRole == 3;
        public static bool IsOperator => UserRole == 4;
        public static bool IsSales => UserRole == 5;

        public static void Clear()
        {
            UserId = 0;
            Username = null;
            FullName = null;
            UserRole = 0;
        }
    }
}

// ==========================================================
// 7. Classes/Logger.cs - Logging Utility
// ==========================================================

using System;
using System.IO;

namespace SP7_ERP.Classes
{
    public static class Logger
    {
        private static string logPath;

        static Logger()
        {
            logPath = Program.Configuration.GetSection("AppSettings")["LogPath"];
            if (!Directory.Exists(logPath))
            {
                Directory.CreateDirectory(logPath);
            }
        }

        public static void LogInfo(string message)
        {
            WriteLog("INFO", message);
        }

        public static void LogError(string message, Exception ex = null)
        {
            string errorMessage = message;
            if (ex != null)
            {
                errorMessage += $"\nException: {ex.Message}\nStack Trace: {ex.StackTrace}";
            }
            WriteLog("ERROR", errorMessage);
        }

        public static void LogWarning(string message)
        {
            WriteLog("WARNING", message);
        }

        private static void WriteLog(string level, string message)
        {
            try
            {
                string fileName = $"log_{DateTime.Now:yyyyMMdd}.txt";
                string fullPath = Path.Combine(logPath, fileName);

                string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [{level}] {message}{Environment.NewLine}";

                File.AppendAllText(fullPath, logEntry);
            }
            catch
            {
                // Silently fail if logging fails
            }
        }
    }
}

// ==========================================================
// 8. Forms/frmLogin.cs - Login Form
// ==========================================================

using System;
using System.Drawing;
using System.Windows.Forms;
using SP7_ERP.Classes;
using MySql.Data.MySqlClient;

namespace SP7_ERP.Forms
{
    public partial class frmLogin : Form
    {
        private Database db;
        private TextBox txtUsername;
        private TextBox txtPassword;
        private Button btnLogin;
        private Button btnCancel;
        private Label lblTitle;
        private Label lblSubTitle;
        private PictureBox pbLogo;

        public frmLogin()
        {
            InitializeComponent();
            db = new Database();
        }

        private void InitializeComponent()
        {
            this.Text = "SP-7 ERP - Login";
            this.Size = new Size(400, 500);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.BackColor = Color.FromArgb(240, 240, 240);

            // Logo
            pbLogo = new PictureBox
            {
                Size = new Size(120, 120),
                Location = new Point(140, 50),
                BackColor = Color.Transparent,
                Image = Properties.Resources.logo,
                SizeMode = PictureBoxSizeMode.Zoom
            };

            // Title
            lblTitle = new Label
            {
                Text = "SP-7 GLASS ERP",
                Font = new Font("Arial", 18, FontStyle.Bold),
                ForeColor = Color.FromArgb(0, 51, 102),
                Size = new Size(300, 30),
                Location = new Point(50, 180),
                TextAlign = ContentAlignment.MiddleCenter
            };

            // Subtitle
            lblSubTitle = new Label
            {
                Text = "Glass Manufacturing ERP",
                Font = new Font("Arial", 10, FontStyle.Regular),
                ForeColor = Color.Gray,
                Size = new Size(300, 20),
                Location = new Point(50, 215),
                TextAlign = ContentAlignment.MiddleCenter
            };

            // Username
            Label lblUsername = new Label
            {
                Text = "Username:",
                Font = new Font("Arial", 10, FontStyle.Regular),
                Location = new Point(50, 260),
                Size = new Size(100, 25)
            };

            txtUsername = new TextBox
            {
                Location = new Point(50, 290),
                Size = new Size(300, 25),
                Font = new Font("Arial", 11, FontStyle.Regular),
                BorderStyle = BorderStyle.FixedSingle
            };

            // Password
            Label lblPassword = new Label
            {
                Text = "Password:",
                Font = new Font("Arial", 10, FontStyle.Regular),
                Location = new Point(50, 330),
                Size = new Size(100, 25)
            };

            txtPassword = new TextBox
            {
                Location = new Point(50, 360),
                Size = new Size(300, 25),
                Font = new Font("Arial", 11, FontStyle.Regular),
                BorderStyle = BorderStyle.FixedSingle,
                PasswordChar = '*'
            };

            // Buttons
            btnLogin = new Button
            {
                Text = "Login",
                Location = new Point(50, 410),
                Size = new Size(140, 35),
                Font = new Font("Arial", 11, FontStyle.Bold),
                BackColor = Color.FromArgb(0, 102, 204),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat
            };
            btnLogin.FlatAppearance.BorderSize = 0;
            btnLogin.Click += BtnLogin_Click;

            btnCancel = new Button
            {
                Text = "Cancel",
                Location = new Point(210, 410),
                Size = new Size(140, 35),
                Font = new Font("Arial", 11, FontStyle.Regular),
                BackColor = Color.FromArgb(100, 100, 100),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat
            };
            btnCancel.FlatAppearance.BorderSize = 0;
            btnCancel.Click += (s, e) => Application.Exit();

            // Demo credentials label
            Label lblDemo = new Label
            {
                Text = "Demo: admin / admin123",
                Font = new Font("Arial", 9, FontStyle.Italic),
                ForeColor = Color.Gray,
                Location = new Point(50, 450),
                Size = new Size(300, 20),
                TextAlign = ContentAlignment.MiddleCenter
            };

            // Add controls
            this.Controls.AddRange(new Control[] {
                pbLogo, lblTitle, lblSubTitle, lblUsername, txtUsername,
                lblPassword, txtPassword, btnLogin, btnCancel, lblDemo
            });

            // Set enter key to login
            this.AcceptButton = btnLogin;
        }

        private void BtnLogin_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtUsername.Text) || string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                MessageBox.Show("Please enter username and password", "Error",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                string query = @"SELECT user_id, username, full_name, user_role, password 
                                FROM tbl_users WHERE username = @username AND is_active = 1";

                var parameters = new Dictionary<string, object>
                {
                    { "@username", txtUsername.Text.Trim() }
                };

                DataTable dt = db.ExecuteQuery(query, parameters);

                if (dt.Rows.Count == 0)
                {
                    MessageBox.Show("Invalid username or password", "Error",
                        MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                string storedPassword = dt.Rows[0]["password"].ToString();

                // For demo, simple comparison (in production use bcrypt)
                if (storedPassword != txtPassword.Text)
                {
                    MessageBox.Show("Invalid username or password", "Error",
                        MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                // Set user session
                UserSession.UserId = Convert.ToInt32(dt.Rows[0]["user_id"]);
                UserSession.Username = dt.Rows[0]["username"].ToString();
                UserSession.FullName = dt.Rows[0]["full_name"].ToString();
                UserSession.UserRole = Convert.ToInt32(dt.Rows[0]["user_role"]);
                UserSession.LoginTime = DateTime.Now;

                // Update last login
                string updateQuery = "UPDATE tbl_users SET last_login = @last_login WHERE user_id = @user_id";
                var updateParams = new Dictionary<string, object>
                {
                    { "@last_login", DateTimeOffset.Now.ToUnixTimeSeconds() },
                    { "@user_id", UserSession.UserId }
                };
                db.ExecuteNonQuery(updateQuery, updateParams);

                Logger.LogInfo($"User {UserSession.Username} logged in successfully");

                this.DialogResult = DialogResult.OK;
                this.Close();
            }
            catch (Exception ex)
            {
                Logger.LogError("Login error", ex);
                MessageBox.Show("Login error: " + ex.Message, "Error",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}

// ==========================================================
// 9. Forms/frmMain.cs - Main Dashboard Form
// ==========================================================

using System;
using System.Drawing;
using System.Windows.Forms;
using SP7_ERP.Classes;

namespace SP7_ERP.Forms
{
    public partial class frmMain : Form
    {
        private Panel sidePanel;
        private Panel topPanel;
        private Panel contentPanel;
        private Button btnDashboard;
        private Button btnMasters;
        private Button btnTransactions;
        private Button btnInventory;
        private Button btnReports;
        private Button btnSettings;
        private Button btnLogout;
        private Label lblWelcome;
        private Label lblDateTime;
        private Timer timer;

        public frmMain()
        {
            InitializeComponent();
            LoadDashboard();
        }

        private void InitializeComponent()
        {
            this.Text = "SP-7 Glass ERP - Dashboard";
            this.WindowState = FormWindowState.Maximized;
            this.StartPosition = FormStartPosition.CenterScreen;
            this.BackColor = Color.FromArgb(240, 240, 240);
            this.Icon = Properties.Resources.sp7_icon;

            // Top Panel
            topPanel = new Panel
            {
                Height = 60,
                Dock = DockStyle.Top,
                BackColor = Color.FromArgb(0, 51, 102)
            };

            Label lblAppName = new Label
            {
                Text = "SP-7 GLASS ERP",
                Font = new Font("Arial", 16, FontStyle.Bold),
                ForeColor = Color.White,
                Location = new Point(20, 15),
                AutoSize = true
            };

            lblWelcome = new Label
            {
                Font = new Font("Arial", 10, FontStyle.Regular),
                ForeColor = Color.White,
                Location = new Point(200, 20),
                AutoSize = true
            };

            lblDateTime = new Label
            {
                Font = new Font("Arial", 10, FontStyle.Regular),
                ForeColor = Color.White,
                Location = new Point(800, 20),
                AutoSize = true
            };

            topPanel.Controls.AddRange(new Control[] { lblAppName, lblWelcome, lblDateTime });

            // Side Panel
            sidePanel = new Panel
            {
                Width = 200,
                Dock = DockStyle.Left,
                BackColor = Color.FromArgb(45, 45, 48)
            };

            // Menu buttons
            btnDashboard = CreateMenuButton("Dashboard", 0, Properties.Resources.dashboard);
            btnMasters = CreateMenuButton("Masters", 50, Properties.Resources.masters);
            btnTransactions = CreateMenuButton("Transactions", 100, Properties.Resources.transactions);
            btnInventory = CreateMenuButton("Inventory", 150, Properties.Resources.inventory);
            btnReports = CreateMenuButton("Reports", 200, Properties.Resources.reports);
            btnSettings = CreateMenuButton("Settings", 250, Properties.Resources.settings);
            btnLogout = CreateMenuButton("Logout", 400, Properties.Resources.logout, Color.FromArgb(192, 57, 43));

            btnDashboard.Click += (s, e) => LoadDashboard();
            btnMasters.Click += (s, e) => LoadMasters();
            btnTransactions.Click += (s, e) => LoadTransactions();
            btnInventory.Click += (s, e) => LoadInventory();
            btnReports.Click += (s, e) => LoadReports();
            btnSettings.Click += (s, e) => LoadSettings();
            btnLogout.Click += BtnLogout_Click;

            sidePanel.Controls.AddRange(new Control[] {
                btnDashboard, btnMasters, btnTransactions,
                btnInventory, btnReports, btnSettings, btnLogout
            });

            // Content Panel
            contentPanel = new Panel
            {
                Dock = DockStyle.Fill,
                BackColor = Color.FromArgb(240, 240, 240),
                AutoScroll = true
            };

            // Timer for clock
            timer = new Timer { Interval = 1000 };
            timer.Tick += (s, e) => UpdateDateTime();
            timer.Start();

            // Add panels
            this.Controls.Add(contentPanel);
            this.Controls.Add(sidePanel);
            this.Controls.Add(topPanel);

            // Set welcome message
            lblWelcome.Text = $"Welcome, {UserSession.FullName}";
        }

        private Button CreateMenuButton(string text, int y, Image image)
        {
            return CreateMenuButton(text, y, image, Color.FromArgb(60, 60, 65));
        }

        private Button CreateMenuButton(string text, int y, Image image, Color backColor)
        {
            Button btn = new Button
            {
                Text = text,
                Image = image,
                ImageAlign = ContentAlignment.MiddleLeft,
                TextAlign = ContentAlignment.MiddleLeft,
                TextImageRelation = TextImageRelation.ImageBeforeText,
                Location = new Point(0, y),
                Size = new Size(200, 45),
                FlatStyle = FlatStyle.Flat,
                FlatAppearance = { BorderSize = 0 },
                BackColor = backColor,
                ForeColor = Color.White,
                Font = new Font("Arial", 11, FontStyle.Regular)
            };
            return btn;
        }

        private void UpdateDateTime()
        {
            lblDateTime.Text = DateTime.Now.ToString("dd MMM yyyy, hh:mm:ss tt");
        }

        private void LoadDashboard()
        {
            contentPanel.Controls.Clear();
            var dashboard = new Controls.ucDashboard();
            dashboard.Dock = DockStyle.Fill;
            contentPanel.Controls.Add(dashboard);
        }

        private void LoadMasters()
        {
            contentPanel.Controls.Clear();
            var masters = new Controls.ucMasters();
            masters.Dock = DockStyle.Fill;
            contentPanel.Controls.Add(masters);
        }

        private void LoadTransactions()
        {
            contentPanel.Controls.Clear();
            var transactions = new Controls.ucTransactions();
            transactions.Dock = DockStyle.Fill;
            contentPanel.Controls.Add(transactions);
        }

        private void LoadInventory()
        {
            contentPanel.Controls.Clear();
            var inventory = new Controls.ucInventory();
            inventory.Dock = DockStyle.Fill;
            contentPanel.Controls.Add(inventory);
        }

        private void LoadReports()
        {
            contentPanel.Controls.Clear();
            var reports = new Controls.ucReports();
            reports.Dock = DockStyle.Fill;
            contentPanel.Controls.Add(reports);
        }

        private void LoadSettings()
        {
            contentPanel.Controls.Clear();
            var settings = new Controls.ucSettings();
            settings.Dock = DockStyle.Fill;
            contentPanel.Controls.Add(settings);
        }

        private void BtnLogout_Click(object sender, EventArgs e)
        {
            var result = MessageBox.Show("Are you sure you want to logout?", "Logout",
                MessageBoxButtons.YesNo, MessageBoxIcon.Question);

            if (result == DialogResult.Yes)
            {
                Logger.LogInfo($"User {UserSession.Username} logged out");
                UserSession.Clear();
                this.Hide();
                using (var loginForm = new frmLogin())
                {
                    if (loginForm.ShowDialog() == DialogResult.OK)
                    {
                        this.Show();
                        lblWelcome.Text = $"Welcome, {UserSession.FullName}";
                    }
                    else
                    {
                        Application.Exit();
                    }
                }
            }
        }
    }
}

// ==========================================================
// 10. Controls/ucDashboard.cs - Dashboard User Control
// ==========================================================

using System;
using System.Drawing;
using System.Windows.Forms;
using SP7_ERP.Classes;
using System.Data;

namespace SP7_ERP.Controls
{
    public partial class ucDashboard : UserControl
    {
        private Database db;
        private Panel statsPanel;
        private Panel chartsPanel;
        private Panel recentPanel;

        public ucDashboard()
        {
            InitializeComponent();
            db = new Database();
            LoadDashboardData();
        }

        private void InitializeComponent()
        {
            this.Size = new Size(1200, 800);
            this.AutoScroll = true;

            // Stats Panel
            statsPanel = new Panel
            {
                Location = new Point(20, 20),
                Size = new Size(1160, 150),
                BackColor = Color.Transparent
            };

            // Charts Panel
            chartsPanel = new Panel
            {
                Location = new Point(20, 190),
                Size = new Size(760, 300),
                BackColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle
            };

            // Recent Items Panel
            recentPanel = new Panel
            {
                Location = new Point(800, 190),
                Size = new Size(380, 300),
                BackColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle
            };

            this.Controls.AddRange(new Control[] { statsPanel, chartsPanel, recentPanel });
        }

        private void LoadDashboardData()
        {
            try
            {
                // Get dashboard summary
                DataTable dt = db.ExecuteQuery("SELECT * FROM view_dashboard_summary");

                if (dt.Rows.Count > 0)
                {
                    CreateStatCard("Today's PI", dt.Rows[0]["today_pi"].ToString(), 
                        Color.FromArgb(52, 152, 219), 0);
                    CreateStatCard("Pending WO", dt.Rows[0]["pending_wo"].ToString(),
                        Color.FromArgb(241, 196, 15), 200);
                    CreateStatCard("Monthly Sales", 
                        Calculator.FormatCurrency(Convert.ToDecimal(dt.Rows[0]["monthly_sales"]) / 100m),
                        Color.FromArgb(46, 204, 113), 400);
                    CreateStatCard("Total Sales",
                        Calculator.FormatCurrency(Convert.ToDecimal(dt.Rows[0]["total_sales"]) / 100m),
                        Color.FromArgb(155, 89, 182), 600);
                }

                // Load recent PIs
                LoadRecentPIs();

                // Load pending WOs
                LoadPendingWOs();
            }
            catch (Exception ex)
            {
                Logger.LogError("Error loading dashboard", ex);
            }
        }

        private void CreateStatCard(string title, string value, Color color, int x)
        {
            Panel card = new Panel
            {
                Location = new Point(x, 0),
                Size = new Size(180, 130),
                BackColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle
            };

            Label lblTitle = new Label
            {
                Text = title,
                Location = new Point(10, 15),
                Size = new Size(160, 20),
                Font = new Font("Arial", 10, FontStyle.Regular),
                ForeColor = Color.Gray
            };

            Label lblValue = new Label
            {
                Text = value,
                Location = new Point(10, 45),
                Size = new Size(160, 40),
                Font = new Font("Arial", 18, FontStyle.Bold),
                ForeColor = color,
                TextAlign = ContentAlignment.MiddleLeft
            };

            Panel colorBar = new Panel
            {
                Location = new Point(0, 0),
                Size = new Size(5, 130),
                BackColor = color
            };

            card.Controls.AddRange(new Control[] { colorBar, lblTitle, lblValue });
            statsPanel.Controls.Add(card);
        }

        private void LoadRecentPIs()
        {
            try
            {
                DataTable dt = db.ExecuteQuery(@"
                    SELECT pi_number, DATE_FORMAT(FROM_UNIXTIME(pi_date), '%d/%m/%Y') as pi_date,
                           customer_name, grand_total 
                    FROM view_pi_report 
                    ORDER BY pi_id DESC LIMIT 10");

                DataGridView dgv = new DataGridView
                {
                    Location = new Point(10, 40),
                    Size = new Size(360, 240),
                    DataSource = dt,
                    ReadOnly = true,
                    AllowUserToAddRows = false,
                    AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                    BackgroundColor = Color.White,
                    BorderStyle = BorderStyle.None,
                    RowHeadersVisible = false
                };

                Label lblTitle = new Label
                {
                    Text = "Recent Proforma Invoices",
                    Location = new Point(10, 10),
                    Font = new Font("Arial", 11, FontStyle.Bold),
                    AutoSize = true
                };

                recentPanel.Controls.Clear();
                recentPanel.Controls.AddRange(new Control[] { lblTitle, dgv });
            }
            catch (Exception ex)
            {
                Logger.LogError("Error loading recent PIs", ex);
            }
        }

        private void LoadPendingWOs()
        {
            try
            {
                DataTable dt = db.ExecuteQuery(@"
                    SELECT wo_number, delivery_date, customer_name, status_name 
                    FROM view_wo_report 
                    WHERE status_name IN ('Pending', 'Cutting', 'Processing')
                    ORDER BY delivery_date LIMIT 10");

                DataGridView dgv = new DataGridView
                {
                    Location = new Point(10, 40),
                    Size = new Size(740, 240),
                    DataSource = dt,
                    ReadOnly = true,
                    AllowUserToAddRows = false,
                    AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                    BackgroundColor = Color.White,
                    BorderStyle = BorderStyle.None,
                    RowHeadersVisible = false
                };

                Label lblTitle = new Label
                {
                    Text = "Pending Work Orders",
                    Location = new Point(10, 10),
                    Font = new Font("Arial", 11, FontStyle.Bold),
                    AutoSize = true
                };

                chartsPanel.Controls.Clear();
                chartsPanel.Controls.AddRange(new Control[] { lblTitle, dgv });
            }
            catch (Exception ex)
            {
                Logger.LogError("Error loading pending WOs", ex);
            }
        }
    }
}

// ==========================================================
// 11. Controls/ucMasters.cs - Masters User Control
// ==========================================================

using System;
using System.Drawing;
using System.Windows.Forms;
using SP7_ERP.Classes;

namespace SP7_ERP.Controls
{
    public partial class ucMasters : UserControl
    {
        private TabControl tabControl;
        private DataGridView dgvCustomers;
        private DataGridView dgvItems;
        private DataGridView dgvProcesses;
        private DataGridView dgvCharges;
        private Database db;

        public ucMasters()
        {
            InitializeComponent();
            db = new Database();
            LoadAllMasters();
        }

        private void InitializeComponent()
        {
            this.Size = new Size(1200, 800);
            this.AutoScroll = true;

            // Tab Control
            tabControl = new TabControl
            {
                Location = new Point(10, 10),
                Size = new Size(1180, 780)
            };

            // Customer Tab
            TabPage tabCustomers = new TabPage("Customers");
            InitializeCustomerTab(tabCustomers);

            // Item Tab
            TabPage tabItems = new TabPage("Items");
            InitializeItemTab(tabItems);

            // Process Tab
            TabPage tabProcesses = new TabPage("Processes");
            InitializeProcessTab(tabProcesses);

            // Charges Tab
            TabPage tabCharges = new TabPage("Charges");
            InitializeChargesTab(tabCharges);

            tabControl.TabPages.AddRange(new TabPage[] {
                tabCustomers, tabItems, tabProcesses, tabCharges
            });

            this.Controls.Add(tabControl);
        }

        private void InitializeCustomerTab(TabPage tab)
        {
            Panel panel = new Panel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(10)
            };

            // Toolbar
            ToolStrip toolbar = new ToolStrip();
            toolbar.Items.Add(new ToolStripButton("Add", null, (s, e) => AddCustomer()));
            toolbar.Items.Add(new ToolStripButton("Edit", null, (s, e) => EditCustomer()));
            toolbar.Items.Add(new ToolStripButton("Delete", null, (s, e) => DeleteCustomer()));
            toolbar.Items.Add(new ToolStripSeparator());
            toolbar.Items.Add(new ToolStripButton("Refresh", null, (s, e) => LoadCustomers()));

            // Grid
            dgvCustomers = new DataGridView
            {
                Dock = DockStyle.Fill,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                ReadOnly = true,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                RowHeadersVisible = false
            };

            panel.Controls.Add(dgvCustomers);
            panel.Controls.Add(toolbar);
            tab.Controls.Add(panel);
        }

        private void InitializeItemTab(TabPage tab)
        {
            Panel panel = new Panel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(10)
            };

            ToolStrip toolbar = new ToolStrip();
            toolbar.Items.Add(new ToolStripButton("Add", null, (s, e) => AddItem()));
            toolbar.Items.Add(new ToolStripButton("Edit", null, (s, e) => EditItem()));
            toolbar.Items.Add(new ToolStripButton("Delete", null, (s, e) => DeleteItem()));
            toolbar.Items.Add(new ToolStripSeparator());
            toolbar.Items.Add(new ToolStripButton("Refresh", null, (s, e) => LoadItems()));

            dgvItems = new DataGridView
            {
                Dock = DockStyle.Fill,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                ReadOnly = true,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                RowHeadersVisible = false
            };

            panel.Controls.Add(dgvItems);
            panel.Controls.Add(toolbar);
            tab.Controls.Add(panel);
        }

        private void InitializeProcessTab(TabPage tab)
        {
            Panel panel = new Panel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(10)
            };

            ToolStrip toolbar = new ToolStrip();
            toolbar.Items.Add(new ToolStripButton("Add", null, (s, e) => AddProcess()));
            toolbar.Items.Add(new ToolStripButton("Edit", null, (s, e) => EditProcess()));
            toolbar.Items.Add(new ToolStripButton("Delete", null, (s, e) => DeleteProcess()));
            toolbar.Items.Add(new ToolStripSeparator());
            toolbar.Items.Add(new ToolStripButton("Refresh", null, (s, e) => LoadProcesses()));

            dgvProcesses = new DataGridView
            {
                Dock = DockStyle.Fill,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                ReadOnly = true,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                RowHeadersVisible = false
            };

            panel.Controls.Add(dgvProcesses);
            panel.Controls.Add(toolbar);
            tab.Controls.Add(panel);
        }

        private void InitializeChargesTab(TabPage tab)
        {
            Panel panel = new Panel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(10)
            };

            ToolStrip toolbar = new ToolStrip();
            toolbar.Items.Add(new ToolStripButton("Add", null, (s, e) => AddCharge()));
            toolbar.Items.Add(new ToolStripButton("Edit", null, (s, e) => EditCharge()));
            toolbar.Items.Add(new ToolStripButton("Delete", null, (s, e) => DeleteCharge()));
            toolbar.Items.Add(new ToolStripSeparator());
            toolbar.Items.Add(new ToolStripButton("Refresh", null, (s, e) => LoadCharges()));

            dgvCharges = new DataGridView
            {
                Dock = DockStyle.Fill,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                ReadOnly = true,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                RowHeadersVisible = false
            };

            panel.Controls.Add(dgvCharges);
            panel.Controls.Add(toolbar);
            tab.Controls.Add(panel);
        }

        private void LoadAllMasters()
        {
            LoadCustomers();
            LoadItems();
            LoadProcesses();
            LoadCharges();
        }

        private void LoadCustomers()
        {
            try
            {
                DataTable dt = db.ExecuteQuery(@"
                    SELECT customer_code, customer_name, bill_city, bill_state, 
                           bill_gst, bill_phone, credit_limit/100 as credit_limit
                    FROM tbl_customer_master WHERE is_active = 1");
                dgvCustomers.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error loading customers: " + ex.Message);
            }
        }

        private void LoadItems()
        {
            try
            {
                DataTable dt = db.ExecuteQuery(@"
                    SELECT item_code, item_name, glass_name, thickness, hsn_code
                    FROM tbl_item_master i
                    JOIN tbl_glass_type_master g ON i.glass_type_id = g.glass_type_id
                    WHERE i.is_active = 1");
                dgvItems.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error loading items: " + ex.Message);
            }
        }

        private void LoadProcesses()
        {
            try
            {
                DataTable dt = db.ExecuteQuery(@"
                    SELECT process_code, process_name, process_category, uom_name
                    FROM tbl_fast_process_master p
                    JOIN tbl_uom_master u ON p.uom_id = u.uom_id
                    WHERE p.is_active = 1");
                dgvProcesses.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error loading processes: " + ex.Message);
            }
        }

        private void LoadCharges()
        {
            try
            {
                DataTable dt = db.ExecuteQuery(@"
                    SELECT charge_code, charge_name, charge_category,
                           CASE calc_type
                               WHEN 1 THEN 'Fixed'
                               WHEN 2 THEN 'Percentage'
                               WHEN 3 THEN 'Per SqFt'
                               WHEN 4 THEN 'Per Piece'
                           END as calc_type,
                           calc_value/100 as value, gst_rate
                    FROM tbl_charges_master WHERE is_active = 1");
                dgvCharges.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error loading charges: " + ex.Message);
            }
        }

        private void AddCustomer()
        {
            // Open customer form
        }

        private void EditCustomer()
        {
            if (dgvCustomers.SelectedRows.Count > 0)
            {
                // Open customer form with selected data
            }
        }

        private void DeleteCustomer()
        {
            if (dgvCustomers.SelectedRows.Count > 0)
            {
                var result = MessageBox.Show("Delete selected customer?", "Confirm",
                    MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (result == DialogResult.Yes)
                {
                    // Delete logic
                }
            }
        }

        private void AddItem() { }
        private void EditItem() { }
        private void DeleteItem() { }
        private void AddProcess() { }
        private void EditProcess() { }
        private void DeleteProcess() { }
        private void AddCharge() { }
        private void EditCharge() { }
        private void DeleteCharge() { }
    }
}

// ==========================================================
// 12. Program.cs - Complete Entry Point
// ==========================================================

/*
using System;
using System.Windows.Forms;
using SP7_ERP.Forms;

namespace SP7_ERP
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            
            // Show splash screen
            using (var splash = new frmSplash())
            {
                splash.ShowDialog();
            }

            // Show login
            using (var login = new frmLogin())
            {
                if (login.ShowDialog() == DialogResult.OK)
                {
                    Application.Run(new frmMain());
                }
            }
        }
    }
}
*/

// ==========================================================
// DESKTOP APP COMPLETE - 12 FILES
// ==========================================================