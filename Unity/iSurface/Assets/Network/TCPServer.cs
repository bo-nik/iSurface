using UnityEngine;
using System.Collections;
using System.Text;
using System.Threading;
using System.IO;
using System.Net;
using System.Net.Sockets;
using SimpleJSON;

public partial class TCPServer : MonoBehaviour {

	public int port = 8088;

	private Thread serverThread;
	private Queue commands = new Queue();
		 
	// Use this for initialization
	void Start () {
		serverThread = new Thread(new ThreadStart(RunServer));
		serverThread.Start();
	}
	
	// Update is called once per frame
	void Update () {
		while (commands.Count > 0) {
			CommandHandler.ProcessCommand (commands.Dequeue().ToString());
		}
	}

	void OnApplicationQuit() {
		if (serverThread != null) {
			serverThread.Abort ();
		}
	}

	private void RunServer () {
		TcpListener listener;
		TcpClient client;

		listener = new TcpListener(IPAddress.Any, port);
		listener.Start();
		Logger.Log ("Starting TCP Server...");
		Logger.Log ("Listening port " + port + "...");

		while (true) {
			client = listener.AcceptTcpClient ();
			Logger.Log ("Client accepted...");

			StreamReader reader = new StreamReader (client.GetStream (), Encoding.UTF8);

			string command = reader.ReadLine ();
			while (command != null) {
				commands.Enqueue(command);
				command = reader.ReadLine ();
			}
			commands.Enqueue("{\"command\":\"clear_surface\"}");
			Logger.Log ("Client disconnected...");
		}
	}
}
