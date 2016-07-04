using UnityEngine;
using System;
using System.Collections.Generic;

public partial class BezierSurface : MonoBehaviour {

	public int Id {
		get {
			return Id;
		}
	}

	public SurfaceDegree Degree {
		get {
			return degree;
		}
	}

	private int id;
	private SurfaceDegree degree;
	private Vector3[,] anchorPoints;

	// Child containers
	private GameObject skeleton;
	private GameObject anchorPointsContainer;
	private GameObject anchorLinesContainer;
	private GameObject cornerPointsContainer;
	private GameObject surfaceMesh;
	private GameObject[,] anchorPointsSpheres; 
	private GameObject[] cornerPointsSpheres;
	private Dictionary<string, GameObject> anchorLines = new Dictionary<string, GameObject> (); 

	public bool NeedUpdate = false;
	public bool Enabled = true;


	private enum MaterialType {
		Default,
		Disabled,
		OnEditingConstraintActive,
		OnEditingConstraintDisabled,
		OnChoosePortion
	}

	private MaterialType materialType = MaterialType.Default;
	
	// Use this for initialization
	void Start () {
		Initialize ();
	}

	private bool ShowSkeleton {
		get {
			if (Settings.ConstraintEditor.Enabled) {
				return false;
			}

			switch (Settings.SkeletonVisibility) {
			case Settings.SkeletonVisibilityCases.Always:
				return true;
			case Settings.SkeletonVisibilityCases.Never:
				return false;
			case Settings.SkeletonVisibilityCases.OnPortionEditing:
				return Settings.EditingPortionId == id;
			}
			return false;
		}
	}

	// Update is called once per frame
	void Update () {
		if (NeedUpdate) {
			UpdateSkeleton ();
			UpdateMesh ();
			UpdateCornerPoints ();
			NeedUpdate = false;
		}
		
		if (skeleton.activeSelf != ShowSkeleton) {
			skeleton.SetActive (ShowSkeleton);
		}

		MaterialType newMaterialType = MaterialType.Default;
		
		// Disable portion if some else portion is editing
		Enabled = !(Settings.EditingPortionId >= 0 && Settings.EditingPortionId != id);
		if (Enabled) {
			newMaterialType = MaterialType.Default;
		} else {
			newMaterialType = MaterialType.Disabled;
		}
		if (Settings.EditingPortionId == -2) {
			newMaterialType = MaterialType.OnChoosePortion;
		}

		// Show corner points if editing constraints
		if (cornerPointsContainer.activeSelf != Settings.ConstraintEditor.Enabled) {
			cornerPointsContainer.SetActive (Settings.ConstraintEditor.Enabled);
		}	
		
		// Colorize portion if editing constraints
		if (Settings.ConstraintEditor.Enabled) {
			if (id == Settings.ConstraintEditor.FirstPortionId ||
			    id == Settings.ConstraintEditor.SecondPortionId) {
				newMaterialType = MaterialType.OnEditingConstraintActive;
			} else {
				newMaterialType = MaterialType.OnEditingConstraintDisabled;
			}
		}

		if (materialType != newMaterialType) {
			materialType = newMaterialType;

			switch (materialType) {
			case MaterialType.Default:
				surfaceMesh.GetComponent<MeshRenderer> ().material = Settings.SurfaceMaterial;
				break;
			case MaterialType.Disabled: 
				surfaceMesh.GetComponent<MeshRenderer> ().material = Settings.SurfaceDisabledMaterial;
				break;
			case MaterialType.OnEditingConstraintActive:
				surfaceMesh.GetComponent<MeshRenderer> ().material = Settings.SurfaceEditingActiveMaterial;
				Color color = surfaceMesh.GetComponent<MeshRenderer> ().material.color;
				Color newColor = Settings.DefaultColors[id % Settings.DefaultColors.Length];
				color.r = newColor.r;
				color.g = newColor.g;
				color.b = newColor.b;
				surfaceMesh.GetComponent<MeshRenderer> ().material.color = color;
				break;
			case MaterialType.OnEditingConstraintDisabled:
				surfaceMesh.GetComponent<MeshRenderer> ().material = Settings.SurfaceEditingDisabledMaterial;
				color = surfaceMesh.GetComponent<MeshRenderer> ().material.color;
				newColor = Settings.DefaultColors[id % Settings.DefaultColors.Length];
				color.r = newColor.r;
				color.g = newColor.g;
				color.b = newColor.b;
				surfaceMesh.GetComponent<MeshRenderer> ().material.color = color;
				break;
			case MaterialType.OnChoosePortion:
				surfaceMesh.GetComponent<MeshRenderer> ().material = Settings.SurfaceEditingDisabledMaterial;
				color = surfaceMesh.GetComponent<MeshRenderer> ().material.color;
				newColor = Settings.DefaultColors[id % Settings.DefaultColors.Length];
				color.r = newColor.r;
				color.g = newColor.g;
				color.b = newColor.b;
				surfaceMesh.GetComponent<MeshRenderer> ().material.color = color;
				break;
			}
		}
	}

	void Initialize () {
		// Create skeleton containers
		skeleton = new GameObject ("Skeleton");
		skeleton.transform.parent = transform;
		skeleton.SetActive (ShowSkeleton);
		skeleton.transform.LocalIdentity ();

		// Create surface container
		surfaceMesh = new GameObject ("Mesh");
		surfaceMesh.transform.parent = transform;
		surfaceMesh.transform.LocalIdentity ();
		surfaceMesh.AddComponent<MeshFilter> ();
		MeshRenderer meshRenderer = surfaceMesh.AddComponent<MeshRenderer> ();
		meshRenderer.material = Settings.SurfaceMaterial;

		CreateSkeleton ();

		// Add corner points
		CreateCornerPoints ();
	}
	
	public static BezierSurface CreateSurface (GameObject where, int id, SurfaceDegree degree, Vector3[,] anchorPoints) {
		BezierSurface bezierSurface = where.AddComponent<BezierSurface> ();
		bezierSurface.id = id;
		bezierSurface.degree = degree;
		bezierSurface.anchorPoints = anchorPoints;
		bezierSurface.NeedUpdate = true;
		return bezierSurface;
	}
	
	public SurfaceDegree GetDegree() {
		return degree;
	}

	public Vector3 GetAnchorPoint(int row, int column) {
		return anchorPoints [row, column];
	}

	public void SetAnchorPoint(Vector3 point, int row, int column) {
		anchorPoints [row, column] = point;
		if (!Settings.CachingUpdates) {
			NeedUpdate = true;
		}
	}

	private void CreateSkeleton () {
		anchorPointsContainer = new GameObject ("Anchor Points");
		anchorPointsContainer.transform.parent = skeleton.transform;
		anchorPointsContainer.transform.LocalIdentity ();
		
		anchorLinesContainer = new GameObject ("Lines");
		anchorLinesContainer.transform.parent = skeleton.transform;
		anchorLinesContainer.transform.LocalIdentity ();

		if (anchorPoints == null || anchorPoints.Length == 0) {
			return;
		}
		
		int rows = degree.N + 1;
		int columns = degree.M + 1;

		anchorPointsSpheres = new GameObject[rows, columns];

		// Add anchor points
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < columns; j++) {
				GameObject point = GameObject.CreatePrimitive(PrimitiveType.Sphere);
				point.name = "Point [" + i + ", " + j + "]";
				point.transform.parent = anchorPointsContainer.transform;
				point.transform.LocalIdentity();
				point.GetComponent<MeshRenderer>().material = Settings.AnchorPointMaterial;
				anchorPointsSpheres[i, j] = point;
			}
		}
		
		// Add lines between anchor points
		Action<int, int, int, int> addLineBetweenAnchorPointsWithIndexes = (i1, j1, i2, j2) => { 
			GameObject line = new GameObject ();
			line.name = "Line [" + i1 + ", " + j1 + "] – [" + i2 + ", " + j2 + "]";
			line.transform.parent = anchorLinesContainer.transform;
			line.transform.LocalIdentity ();
			LineRenderer lineRenderer = line.AddComponent<LineRenderer> ();
			lineRenderer.SetWidth(0.1f, 0.1f);
			lineRenderer.material = Settings.AnchorLineMaterial;
			lineRenderer.useWorldSpace = false;
			lineRenderer.SetVertexCount(2);
			anchorLines.Add (i1.ToString() + " " + j1.ToString() + " " + i2.ToString() + " " + j2.ToString(), line);
		};
		for (int i = 0; i < rows - 1; i++) {
			for (int j = 0; j < columns; j++) {
				addLineBetweenAnchorPointsWithIndexes(i, j, i + 1, j);
			}
		}
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < columns - 1; j++) {
				addLineBetweenAnchorPointsWithIndexes(i, j, i, j + 1);
			}
		}

		UpdateSkeleton ();
	}

	private void UpdateSkeleton () {
		if (anchorPoints == null || anchorPoints.Length == 0) {
			return;
		}

		int rows = degree.N + 1;
		int columns = degree.M + 1;

		// Update anchor points positions
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < columns; j++) {
				anchorPointsSpheres[i, j].transform.localPosition = anchorPoints[i, j];
			}
		}

		// Update lines positions
		Action<int, int, int, int> updateLineBetweenAnchorPointsWithIndexes = (i1, j1, i2, j2) => { 
			GameObject line = anchorLines [i1.ToString() + " " + j1.ToString() + " " + i2.ToString() + " " + j2.ToString()];
			LineRenderer lineRenderer = line.gameObject.GetComponent<LineRenderer> ();
			lineRenderer.SetPosition(0, anchorPoints[i1, j1]);
			lineRenderer.SetPosition(1, anchorPoints[i2, j2]);
		};
		for (int i = 0; i < rows - 1; i++) {
			for (int j = 0; j < columns; j++) {
				updateLineBetweenAnchorPointsWithIndexes(i, j, i + 1, j);
			}
		}
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < columns - 1; j++) {
				updateLineBetweenAnchorPointsWithIndexes(i, j, i, j + 1);
			}
		}
	}

	private void CreateCornerPoints () {
		cornerPointsSpheres = new GameObject[4];
		cornerPointsContainer = new GameObject ("Corner Points");
		cornerPointsContainer.transform.parent = transform;
		cornerPointsContainer.transform.LocalIdentity ();
		cornerPointsContainer.SetActive (false);
		int[,] cornerPointsIndices = {
			{0, 0}, 
			{0, degree.M},
			{degree.N, degree.M},
			{degree.N, 0}};
		for (int i = 0; i < 4; i++) {
			int row = cornerPointsIndices [i, 0];
			int column = cornerPointsIndices [i, 1];
			GameObject point = GameObject.CreatePrimitive (PrimitiveType.Sphere);
			point.name = "Corner Point [" + row + ", " + column + "]";
			point.transform.parent = cornerPointsContainer.transform;
			point.transform.LocalIdentity ();
			point.transform.localPosition = anchorPoints [row, column];
			point.GetComponent<MeshRenderer> ().material = Settings.CornerPointMaterial;
			Color color = point.GetComponent<MeshRenderer> ().material.color;
			color.r = Settings.DefaultColors [i].r;
			color.g = Settings.DefaultColors [i].g;
			color.b = Settings.DefaultColors [i].b;
			point.GetComponent<MeshRenderer> ().material.color = color;
			cornerPointsSpheres [i] = point;
		}
	}

	private void UpdateMesh () {
		MeshFilter meshFilter = surfaceMesh.GetComponent<MeshFilter> ();

		Mesh mesh = new Mesh ();
		mesh.name = "Surface";
		meshFilter.mesh = mesh;

		if (anchorPoints == null || anchorPoints.Length == 0) {
			return;
		}
		if (degree.N < 3 || degree.M < 3) {
			return;
		}

		// * 2 – double vertices to make triangles for back surface faces
		int resolution = 32;
		int verticesCount = resolution * resolution;
		Vector3[] vertices = new Vector3[verticesCount * 2];
				
		float du = 1.0f / (resolution - 1);
		float dv = 1.0f / (resolution - 1);

		int i = 0;
		for (float u = 0.0f; u < 1.0f; u += du) {
			for (float v = 0.0f; v < 1.0f; v += dv) {
				vertices[i++] = BezierHelper.BezierAtPoint(u, v, degree.N, degree.M, anchorPoints);
			}
		}

		// Double vertices to make triangles for back surface faces
		for (i = 0; i < verticesCount; i++) {
			vertices[verticesCount + i] = vertices[i];
		}

		// 2 * resolution – triangles per line
		// 2 * resolution * resolution – total triangles count
		// 2 * resolution * resolution * 3 – total triangles vertices count
		// 2 * resolution * resolution * 3 * 2 – double and inverce triangles to make surface back faces 
		int trianglesVerticesCount =  2 * resolution * resolution * 3;
		int[] triangles = new int[trianglesVerticesCount * 2];

		int k = 0;
		for (i = 0; i < resolution - 1; i++) {
			for (int j = 0; j < resolution - 1; j++) {
				triangles[k++] = i * resolution + j;
				triangles[k++] = (i + 1) * resolution + (j + 1);
				triangles[k++] = i * resolution + (j + 1);

				triangles[k++] = i * resolution + j;
				triangles[k++] = (i + 1) * resolution + j;
				triangles[k++] = (i + 1) * resolution + (j + 1);
			}
		}

		// Inverce triangles 
		// To make surface back faces visible 
		for (i = 0; i < triangles.Length / 2; i += 3) {
			triangles[trianglesVerticesCount + i] = triangles[i] + verticesCount;
			triangles[trianglesVerticesCount + i + 2] = triangles[i + 1] + verticesCount;
			triangles[trianglesVerticesCount + i + 1] = triangles[i + 2] + verticesCount;
		}
		
		mesh.vertices = vertices;
		mesh.triangles = triangles;
		mesh.RecalculateNormals ();
	}

	private void UpdateCornerPoints () {
		int[,] cornerPointsIndices = {
			{0, 0}, 
			{0, degree.M},
			{degree.N, degree.M},
			{degree.N, 0}};
		for (int i = 0; i < 4; i++) {
			int row = cornerPointsIndices[i, 0];
			int column = cornerPointsIndices[i, 1];
			cornerPointsSpheres[i].transform.localPosition = anchorPoints[row, column];
		}
	}
}
