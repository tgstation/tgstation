using System;
using System.Collections.Generic;
using System.ServiceModel;
namespace TGServiceInterface
{
	public class Server
	{
		/// <summary>
		/// List of types that can be used with GetComponen
		/// </summary>
		public static readonly IList<Type> ValidInterfaces = new List<Type> { typeof(ITGByond), typeof(ITGChat), typeof(ITGCompiler), typeof(ITGConfig), typeof(ITGDreamDaemon), typeof(ITGRepository), typeof(ITGServerUpdater), typeof(ITGStatusCheck) };

		/// <summary>
		/// Base name of the communication pipe
		/// they are formatted as MasterPipeName/ComponentName
		/// </summary>
		public static string MasterPipeName = "TGStationServerService";

		/// <summary>
		/// Returns the requested server component interface. This does not guarantee a successful connection
		/// </summary>
		/// <typeparam name="T">The type of the component to retrieve</typeparam>
		/// <returns></returns>
		public static T GetComponent<T>()
		{
			var ToT = typeof(T);
			if (!ValidInterfaces.Contains(ToT))
				throw new Exception("Invalid type!");

			return new ChannelFactory<T>(new NetNamedPipeBinding { SendTimeout = new TimeSpan(0, 10, 0) }, new EndpointAddress(String.Format("net.pipe://localhost/{0}/{1}", MasterPipeName, typeof(T).Name))).CreateChannel();
		}
		
		/// <summary>
		/// Used to test if the service is avaiable on the machine
		/// Note that state can technically change at any time
		/// and any call to the service may throw an exception because it failed
		/// </summary>
		/// <returns>null on successful connection, error message on failure</returns>
		public static string VerifyConnection()
		{
			try
			{
				GetComponent<ITGStatusCheck>().VerifyConnection();
				return null;
			}
			catch(Exception e)
			{
				return e.ToString();
			}
		}
	}

	/// <summary>
	/// Interface for checking server status
	/// </summary>
	[ServiceContract]
	public interface ITGStatusCheck
	{
		/// <summary>
		/// Does nothing on the server end, but if the call completes, you can be sure you are connected. WCF won't throw until you try until you actually use the API
		/// </summary>
		[OperationContract]
		void VerifyConnection();
	}

	/// <summary>
	/// How to modify the repo during the UpdateServer operation
	/// </summary>
	public enum TGRepoUpdateMethod
	{
		/// <summary>
		/// Do not update the repo
		/// </summary>
		None,
		/// <summary>
		/// Update the repo by merging the origin branch
		/// </summary>
		Merge,
		/// <summary>
		/// Update the repo by hard resetting to the remote branch
		/// </summary>
		Hard,
		/// <summary>
		/// Clean the repo by hard resetting to the origin branch
		/// </summary>
		Reset,
	}

	/// <summary>
	/// One stop shop for server updates
	/// </summary>
	[ServiceContract]
	public interface ITGServerUpdater
	{
		/// <summary>
		/// Updates the server fully with various options as a blocking operation
		/// </summary>
		/// <param name="updateType">How to handle the repository during the update</param>
		/// <param name="push_changelog_if_enabled">true if the changelog should be pushed to git</param>
		/// <param name="testmerge_pr">If not zero, will testmerge the designated pull request</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string UpdateServer(TGRepoUpdateMethod updateType, bool push_changelog_if_enabled, ushort testmerge_pr = 0);
	}

}
