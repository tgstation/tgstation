using RGiesecke.DllExport;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;
using System.Threading;
using System.Web.Script.Serialization;

namespace TGIssueReporter
{
	public class IssueReporter
	{
		// Handles verifying arguments, creating threads, GC collection, etc
		#region Exports
		[DllExport("CreateIssue", CallingConvention = CallingConvention.Cdecl)]
		public static int CreateIssue(int argc, [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.LPStr, SizeParamIndex = 0)]string[] args)
		{
			try
			{
				if (args.Length >= 4)
				{
					var RepoID = Convert.ToInt32(args[1]);
					ThreadPool.QueueUserWorkItem(o =>
					{
						try
						{
							CreateIssueImpl(args[0], RepoID, args[2], args[3]);
						}
						catch { }
						GC.Collect();
					});
				}
			}
			catch { }
			GC.Collect();
			return 0;
		}

		[DllExport("AppendIssue", CallingConvention = CallingConvention.Cdecl)]
		public static int AppendIssue(int argc, [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.LPStr, SizeParamIndex = 0)]string[] args)
		{
			try
			{
				if (args.Length >= 4)
				{
					var RepoID = Convert.ToInt32(args[1]);
					var IssueID = Convert.ToInt32(args[2]);
					ThreadPool.QueueUserWorkItem(o => {
						try
						{
							AppendIssueImpl(args[0], RepoID, IssueID, args[3]);
						}
						catch { }
						GC.Collect();
					});
				}
			}
			catch { }
			GC.Collect();
			return 0;
		}
		#endregion

		private static void CreateIssueImpl(string APIKey, int RepoID, string Title, string Body)
		{
			var json = new Dictionary<string, object>
			{
				{ "title", Title },
				{ "body", Body }
			};
			PostWebRequest(APIKey, RepoID, "POST", json);
		}

		private static void AppendIssueImpl(string APIKey, int RepoID, int IssueID, string Appendage)
		{
			var oldstuff = GetIssueBody(APIKey, RepoID, IssueID);
			var json = new Dictionary<string, object>
			{
				{ "body", String.Format("{0}\n\n#### ---EDIT---\n\n{1}", oldstuff, Appendage) }
			};
			PostWebRequest(APIKey, RepoID, "PATCH", json, String.Format("/{0}", IssueID));
		}
		
		private static string GetIssueBody(string APIKey, int RepoID, int IssueID)
		{
			HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create(String.Format("{0}/{1}", IssuesURL(RepoID), IssueID));
			httpWebRequest.Method = WebRequestMethods.Http.Get;
			httpWebRequest.Accept = "application/json";
			httpWebRequest.UserAgent = "TGIssueReporter";
			using (var sr = new StreamReader(httpWebRequest.GetResponse().GetResponseStream()))
			{
				var json = new JavaScriptSerializer().Deserialize<IDictionary<string, object>>(sr.ReadToEnd());
				return (string)json["body"];
			}
		}

		private static string IssuesURL(int RepoID)
		{
			HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create(String.Format("https://api.github.com/repositories/{0}", RepoID));
			httpWebRequest.Method = WebRequestMethods.Http.Get;
			httpWebRequest.Accept = "application/json";
			httpWebRequest.UserAgent = "TGIssueReporter";
			using (var sr = new StreamReader(httpWebRequest.GetResponse().GetResponseStream()))
			{
				var json = new JavaScriptSerializer().Deserialize<IDictionary<string, object>>(sr.ReadToEnd());
				return (string)json["url"] + "/issues";
			}
		}

		private static void PostWebRequest(string APIKey, int RepoID, string Method, IDictionary<string, object> json, string URLAppend = "")
		{
			var httpWebRequest = (HttpWebRequest)WebRequest.Create(IssuesURL(RepoID) + URLAppend);
			httpWebRequest.ContentType = "application/json";
			httpWebRequest.Method = Method;
			httpWebRequest.UserAgent = "TGIssueReporter";
			httpWebRequest.Headers.Add(String.Format("Authorization: token {0}", APIKey));

			using (var streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
			{
				var rawdata = new JavaScriptSerializer().Serialize(json);
				streamWriter.Write(rawdata);
				streamWriter.Flush();
				streamWriter.Close();
			}

			httpWebRequest.GetResponse();	//process the request
		}
    }
}
