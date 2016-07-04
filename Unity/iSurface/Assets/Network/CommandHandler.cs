using UnityEngine;
using SimpleJSON;

public partial class TCPServer {

	private class CommandHandler {
		
		private static Surface surface = null;
		
		public static void ProcessCommand (string commandText) {
			if (surface == null) {
				surface = GameObject.Find ("Surface").GetComponent<Surface> ();
			}
			
			JSONNode command = JSON.Parse (commandText);
			string commandName = command["command"];
			JSONNode commandData = command["data"];
			
//			Logger.Log ("Command '" + commandName + "' received...");
			
			bool commandAccepted = true;
			bool commandExecuted = false;
			
			switch (commandName) {
			case "set_surface":
				commandExecuted = SetSurface (commandData);
				break;
			case "clear_surface":
				commandExecuted = ClearSurface (commandData);
				break;
			case "update_anchor_point":
				commandExecuted = UpdateAnchorPoint (commandData);
				break;
			case "add_portion":
				commandExecuted = AddPortion (commandData);
				break;
			case "remove_portion":
				commandExecuted = RemovePortion (commandData);
				break;
			case "set_rotation":
				commandExecuted = SetRotation (commandData);
				break;
			case "set_permanent_rotation":
				commandExecuted = SetPermanentRotation (commandData);
				break;
			case "set_permanent_translation":
				commandExecuted = SetPermanentTranslation (commandData);
				break;
			case "set_editing_state":
				commandExecuted = SetEditingState (commandData);
				break;
			case "set_constraint_editing_state":
				commandExecuted = SetConstraintEditingState (commandData);
				break;
			case "set_caching_updates":
				commandExecuted = SetCachingUpdates (commandData);
				break;
			case "set_defaults":
				commandExecuted = SetDefaults (commandData);
				break;
			default:
				commandAccepted = false;
				Logger.Log ("Unknown command '" + commandName + "'...");
				break;
			}
			
//			if (commandAccepted) {
//				Logger.Log ("Command '" + commandName + "' accepted...");
//				if (commandExecuted) {
//					Logger.Log ("Command '" + commandName + "' executed...");
//				} else {
//					Logger.Log ("Command '" + commandName + "' execution failed...");
//				}
//			}
		}
		
		public static bool SetSurface (JSONNode commandData) {
			if (surface == null) {
				return false;
			}

			surface.Clear();
			int portionsCount = commandData["surface"]["portions"].Count;
			for (int n = 0; n < portionsCount; n++) {
				int id = commandData["surface"]["portions"][n]["id"].AsInt;
				BezierSurface.SurfaceDegree degree = new BezierSurface.SurfaceDegree(
					commandData["surface"]["portions"][n]["degree"]["n"].AsInt, 
					commandData["surface"]["portions"][n]["degree"]["m"].AsInt);
				Vector3[,] anchorPoints = new Vector3[degree.N + 1, degree.M + 1];
				for (int i = 0; i <= degree.N; i++) {
					for (int j = 0; j <= degree.M; j++) {
						anchorPoints[i, j] = new Vector3(
							commandData["surface"]["portions"][n]["anchor-points"][i][j]["x"].AsFloat,
							commandData["surface"]["portions"][n]["anchor-points"][i][j]["y"].AsFloat,
							commandData["surface"]["portions"][n]["anchor-points"][i][j]["z"].AsFloat
							);
					}
				}
				surface.AddPortion(id, degree, anchorPoints);
			}

			Settings.EditingPortionId = -1;
			Settings.ConstraintEditor.FirstPortionId = -1;
			Settings.ConstraintEditor.SecondPortionId = -1;

			return true;
		}
		
		public static bool ClearSurface (JSONNode commandData) {
			if (surface == null) {
				return false;
			}
			surface.Clear ();
			return true;
		}
		
		public static bool UpdateAnchorPoint (JSONNode commandData) {
			if (surface == null) {
				return false;
			}
			Vector3 point = new Vector3 (
				commandData["point"]["x"].AsFloat,
				commandData["point"]["y"].AsFloat,
				commandData["point"]["z"].AsFloat
				);
			int portionId = commandData["portion-id"].AsInt;
			int row = commandData["row"].AsInt;
			int column = commandData["column"].AsInt;
			surface.UpdateAnchorPoint(point, portionId, row, column);
			return true;
		}
		
		public static bool AddPortion (JSONNode commandData) {
			if (surface == null) {
				return false;
			}
			int id = commandData["portion"]["id"].AsInt;
			BezierSurface.SurfaceDegree degree = new BezierSurface.SurfaceDegree(
				commandData["portion"]["degree"]["n"].AsInt, 
				commandData["portion"]["degree"]["m"].AsInt);
			Vector3[,] anchorPoints = new Vector3[degree.N + 1, degree.M + 1];
			for (int i = 0; i <= degree.N; i++) {
				for (int j = 0; j <= degree.M; j++) {
					anchorPoints[i, j] = new Vector3(
						commandData["portion"]["anchor-points"][i][j]["x"].AsFloat,
						commandData["portion"]["anchor-points"][i][j]["y"].AsFloat,
						commandData["portion"]["anchor-points"][i][j]["z"].AsFloat
						);
				}
			}
			surface.AddPortion (id, degree, anchorPoints);
			return true;
		}
		
		public static bool RemovePortion (JSONNode commandData) {
			if (surface == null) {
				return false;
			}
			int id = commandData["portion-id"].AsInt;
			surface.RemovePortion (id);
			return true;
		}
		
		public static bool SetRotation (JSONNode commandData) {
			if (surface == null) {
				return false;
			}
			float x = commandData ["rotation"] ["x"].AsFloat;
			float y = commandData ["rotation"] ["y"].AsFloat;
			float z = commandData ["rotation"] ["z"].AsFloat;
			surface.transform.eulerAngles = new Vector3 (x, y, z);
			return true;
		}

		public static bool SetPermanentRotation (JSONNode commandData) {
			if (surface == null) {
				return false;
			}
			float x = commandData ["rotation"] ["x"].AsFloat;
			float y = commandData ["rotation"] ["y"].AsFloat;
			float z = commandData ["rotation"] ["z"].AsFloat;
			surface.wrapper.transform.localRotation = Quaternion.Euler (x, y, z);
			return true;
		}

		public static bool SetPermanentTranslation (JSONNode commandData) {
			if (surface == null) {
				return false;
			}
			float x = commandData["translation"]["x"].AsFloat;
			float y = commandData["translation"]["y"].AsFloat;
			float z = commandData["translation"]["z"].AsFloat;
			surface.transform.localPosition = new Vector3(x, y, z);
			return true;
		}

		public static bool SetEditingState (JSONNode commandData) {
			bool editing = commandData ["editing"].AsBool;
			if (editing) {
				Settings.EditingPortionId = commandData["portion-id"].AsInt;
				if (Settings.EditingPortionId == -1) {
					Settings.EditingPortionId = -2;
				}
			} else {
				Settings.EditingPortionId = -1;
			}
			return true;
		}

		public static bool SetConstraintEditingState (JSONNode commandData) {
			Settings.ConstraintEditor.Enabled = commandData ["editing"].AsBool;
			if (Settings.ConstraintEditor.Enabled) {
				Settings.ConstraintEditor.FirstPortionId = commandData["first-portion-id"].AsInt;;
				Settings.ConstraintEditor.SecondPortionId = commandData["second-portion-id"].AsInt;;
			} else {
				Settings.ConstraintEditor.FirstPortionId = -1;
				Settings.ConstraintEditor.SecondPortionId = -1;
			}
			return true;
		}

		public static bool SetCachingUpdates (JSONNode commandData) {
			bool lastCachingUpdates = Settings.CachingUpdates;
			Settings.CachingUpdates = commandData ["enable"].AsBool;
			if (lastCachingUpdates != Settings.CachingUpdates && !Settings.CachingUpdates) {
				lastCachingUpdates = Settings.CachingUpdates;
				if (surface == null) {
					return false;
				}
				surface.UpdateAll ();
			}
			return true;
		}

		public static bool SetDefaults (JSONNode commandData) {
			string name = commandData ["name"];
			switch (name) {
			case "skeleton-visibility":
				int visibility = commandData["value"].AsInt;
				switch (visibility) {
				case 0:
					Settings.SkeletonVisibility = Settings.SkeletonVisibilityCases.Always;
					break;
				case 1:
					Settings.SkeletonVisibility = Settings.SkeletonVisibilityCases.OnPortionEditing;
					break;
				case 2:
					Settings.SkeletonVisibility = Settings.SkeletonVisibilityCases.Never;
					break;
				default:
					break;
				}
				break;
			case "default-colors":
				JSONArray colors = commandData["value"].AsArray;
				Color[] defaultColors = new Color[colors.Count];
				for (int i = 0; i < colors.Count; i++) {
					int hex = colors[i].AsInt;
					float red = ((hex & 0xFF0000) >> 16) / 255.0f;
					float green = ((hex & 0x00FF00) >> 8) / 255.0f;
					float blue = (hex & 0x0000FF) / 255.0f;
					defaultColors[i] = new Color(red, green, blue);
				}
				Settings.DefaultColors = defaultColors;
				break;
			default: break;
			}
			return true;
		}
	}
}
