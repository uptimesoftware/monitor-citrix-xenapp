using System;
using WFICALib;
using System.Threading;
using System.Windows.Forms;

namespace TestLogin
{
    /// <summary>
    /// This program demo's the basic of launching and ICO session from within an application.
    /// http://blogs.citrix.com/2010/03/02/fun-with-the-ica-client-object-ico-and-net-console-applications/
    /// </summary>
    class Program
    {
        public static AutoResetEvent onLogonResetEvent = null;
        
        static void Main(string[] args)
        {

            string serverIP = "";
            string domain = "";
            string username = "";
            string password = "";
            int wait = 15;
       
            if (args.Length != 5)
            {
                Console.WriteLine("Usage: XenAppTestLogin <Server IP> <Domain> <Username> <Password> <Wait Time> \n");
                Environment.Exit(2);
            }
            else
            {
                serverIP = args[0];
                domain = args[1];
                username = args[2];
                password = args[3];
                wait = Convert.ToInt32(args[4]);

            }

            //Console.WriteLine("after if");

            ICAClientClass ica = new ICAClientClass();
            onLogonResetEvent = new AutoResetEvent(false);

            // launch a desktop session
            ica.Application = "";

            // Launch a new session
            ica.Launch = true;

            //Console.WriteLine("after session launch");

            // Set Server address
            //ica.Address = "10.8.X.X";
            ica.Address = serverIP;

            // Not Password field exposed (for security)
            // but can specify it by using the ICA File "password" property
            /*ica.Username = "johncat";
            ica.Domain = "xxxx";
            ica.SetProp("Password", "xxxx");
             */
            ica.Username = username;
            ica.Domain = domain;
            ica.SetProp("Password", password);

            // Let's have a "pretty" session 
            //ica.DesiredColor = ICAColorDepth.Color24Bit;

            // Reseach the output mode you want, depending on what your trying
            // to attempt to automate. The "Client Simulation APIs" are only available under certain modes
            // (i.e. things like sending keys to the session, enumerating windows, etc.)
            ica.OutputMode = OutputMode.OutputModeWindowless;
            // ica.OutputMode = OutputMode.OutputModeNormal;

            // Height and Width
            //ica.DesiredHRes = 1024;
            //ica.DesiredVRes = 786;

            //Console.WriteLine("before onlogon");

            // Register for the OnLogon event
            ica.OnLogon += new _IICAClientEvents_OnLogonEventHandler(ica_OnLogon);

            // Launch/Connect to the session
            ica.Connect();

            //Console.WriteLine("after connect");

            if (onLogonResetEvent.WaitOne(new TimeSpan(0, 0, wait)))
            {
                Console.WriteLine("ConnectionEstablished True");
                //Environment.Exit(0);
            }
            else
            {
                Console.WriteLine("ConnectionEstablished False");
                //Environment.Exit(2);
            }

            // Logoff our session          
            ica.Logoff();
            //Console.WriteLine("after logoff");
        }

        /// <summary>
        /// OnLogon event handler
        /// </summary>
        static void ica_OnLogon()
        {
            //Console.WriteLine("OnLogon event was Handled!");
            onLogonResetEvent.Set();
        }

    }
}