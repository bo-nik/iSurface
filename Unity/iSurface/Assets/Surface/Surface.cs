using UnityEngine;
using System.Collections.Generic;

public class Surface : MonoBehaviour {

	public GameObject wrapper;
	private Dictionary<int, BezierSurface> Portions = new Dictionary<int, BezierSurface>();

	// Use this for initialization
	void Start () {
		Initialize ();
	}

	void Initialize () {
		wrapper = new GameObject ("Wrapper");
		wrapper.transform.parent = transform;
		wrapper.transform.LocalIdentity ();
	}

	public void AddPortion (int id, BezierSurface.SurfaceDegree degree, Vector3[,] anchorPoints) {
		GameObject surfacePortion = new GameObject ("Portion " + id.ToString());
		surfacePortion.transform.parent = wrapper.transform;
		surfacePortion.transform.LocalIdentity ();
		Portions.Add (id, BezierSurface.CreateSurface (surfacePortion, id, degree, anchorPoints));
	}

	public void RemovePortion(int id) {
		if (Portions.ContainsKey (id)) {
			Destroy (Portions[id].gameObject);
			Portions.Remove (id);
		}
	}

	public void Clear () {
		foreach (Transform child in wrapper.transform) {
			Destroy (child.gameObject);
		}
		Portions.Clear ();
	}

	public void UpdateAnchorPoint(Vector3 point, int portionId, int row, int column) {
		if (Portions.ContainsKey (portionId)) {
			Portions[portionId].SetAnchorPoint(point, row, column);
		}
	}

	public BezierSurface PortionById(int id) {
		return null;
	}

	public void UpdateAll () {
		foreach (BezierSurface portion in Portions.Values) {
			portion.NeedUpdate = true;
		}
	}
}
