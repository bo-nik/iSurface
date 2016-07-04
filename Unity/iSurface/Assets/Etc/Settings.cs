using UnityEngine;
using System.Collections;

public class Settings {

	public enum SkeletonVisibilityCases {
		Always, 
		OnPortionEditing, 
		Never
	}

	public static Material SurfaceMaterial {
		get {
			return Resources.Load<Material>("Surface");
		}
	}

	public static Material SurfaceDisabledMaterial {
		get {
			return Resources.Load<Material>("Surface-Disabled");
		}
	}

	public static Material SurfaceEditingActiveMaterial {
		get {
			return Resources.Load<Material> ("Surface-Editing-Active");
		}
	}
	
	public static Material SurfaceEditingDisabledMaterial {
		get {
			return Resources.Load<Material> ("Surface-Editing-Disabled");
		}
	}

	public static Material AnchorPointMaterial {
		get {
			return Resources.Load<Material>("Anchor-Point");
		}
	}

	public static Material CornerPointMaterial {
		get {
			return Resources.Load<Material>("Corner-Point");
		}
	}

	public static Material AnchorLineMaterial {
		get {
			return Resources.Load<Material>("Line");
		}
	}

	public static SkeletonVisibilityCases SkeletonVisibility = SkeletonVisibilityCases.OnPortionEditing;

	public static int EditingPortionId = -1;

	public struct ConstraintEditor {

		public static bool Enabled = false;

		public static int FirstPortionId = -1;

		public static int SecondPortionId = -1;

	}

	public static bool CachingUpdates = false;
	
	public static Color[] DefaultColors = {Color.red, Color.green, Color.blue, Color.yellow};
}