using UnityEngine;

public static class TransformExtension {

	public static void LocalIdentity (this Transform transform) {
		transform.localPosition = Vector3.zero;
		transform.localRotation = Quaternion.identity;
		transform.localScale = Vector3.one;
	}
}
