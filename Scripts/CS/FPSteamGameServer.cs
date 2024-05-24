using Godot;
using Steamworks;
using Steamworks.Data;
using Steamworks.ServerList;
using System;
using System.Runtime.InteropServices;


// Steamworks Socket Server


public partial class FPSteamGameServer : SocketManager {


	public readonly string serverName = "This has a name!";
    public override void OnConnecting(Connection connection, ConnectionInfo data) {
        base.OnConnecting(connection, data);
        connection.Accept();
        GD.Print($"{data.Identity.SteamId} is connecting");
	}

    public override void OnConnected(Connection connection, ConnectionInfo data) {
        base.OnConnected(connection, data);
        GD.Print($"{data.Identity.SteamId} has joined the game");
		//connection.SendMessage()
		//IntPtr ptr = new IntPtr()
		//connection.SendMessage("Here's some data", SendType.Reliable);
		GD.Print("His 'Connection' is : " + connection.Id);
		FPSteamManager.MPManager.Call("server_on_network_peer_connected", data.Identity.SteamId.Value, connection.Id);
	}

    public override void OnDisconnected(Connection connection, ConnectionInfo data) {
        base.OnDisconnected(connection, data);
        GD.Print($"{data.Identity.SteamId} is out of here");
		FPSteamManager.MPManager.Call("_on_network_peer_disconnected", data.Identity.SteamId.Value);
	}

    public override void OnMessage(Connection connection, NetIdentity identity, IntPtr data, int size, long messageNum, long recvTime, int channel) {
        base.OnMessage(connection, identity, data, size, messageNum, recvTime, channel);

		//GD.Print($"We got a message from {identity}!");

		//GD.Print("Server Got A Message " + data);

		byte[] incomingData = new byte[size];
		Marshal.Copy(data, incomingData, 0, size);

		FPSteamManager.MPManager.Call("on_message_server", incomingData, identity.SteamId.Value);

		return;


		//SteamManager.Instance.ProcessMessageFromSocketServer(data, size);

		//ProcessMessage(data, size);

		GD.Print("Connection Got A Message " + data);
		byte[] pingArray = new byte[sizeof(byte)];
		Marshal.Copy(data, pingArray, 0, 1);
		//GD.Print("MyPingArray Check");
		//GD.Print(pingArray[0]);
	}

	/// <summary>
	/// Unreliable
	/// </summary>
	/// <param name="clientID"></param>
	/// <param name="message"></param>
	public void MessageSpecificClient(ulong clientID, byte[] message) {
		foreach (Connection client in Connected) {
			//if (client.UserData.)
			if (client.Id == clientID) {
				Result success = client.SendMessage(message, SendType.Unreliable);
				if (success != Result.OK) {
					Result retry = client.SendMessage(message, SendType.Unreliable);
				}
				break;
			}
		}
	}

	/// <summary>
	/// Reliable
	/// </summary>
	/// <param name="clientID"></param>
	/// <param name="message"></param>
	public void ReliableMessageSpecificClient(ulong clientID, byte[] message) {
		GD.Print("Messaging Client " + clientID + " Reliably.");
		foreach (Connection client in Connected) {
			//if (client.UserData.)
			if (client.Id == clientID) {
				Result success = client.SendMessage(message, SendType.Reliable);
				if (success != Result.OK) {
					Result retry = client.SendMessage(message, SendType.Reliable);
				}
				break;
			}
		}
	}

	/// <summary>
	/// Messages all clients - unused?? 
	/// </summary>
	/// <param name="message"></param>
	/// <param name="size"></param>
	public void MessageClients(byte[] message) {
		try {
			// Loop to only send messages to socket server members who are not the one that sent the message
			foreach (Connection client in Connected) {
				Result success = client.SendMessage(message, SendType.Unreliable);
				if (success != Result.OK) {
					Result retry = client.SendMessage(message, SendType.Unreliable);
				}
			}
		}
		catch {
			GD.Print("Unable to relay socket server message");
		}
	}


}
