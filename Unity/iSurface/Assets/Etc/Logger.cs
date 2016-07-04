using UnityEngine;
using System;

public class Logger {

	public static void Log (string message) {
		Debug.Log (DateTime.Now.ToString("dd-MM-yyyy HH:mm:ss.ff ") + message + "\n");
	}
}
