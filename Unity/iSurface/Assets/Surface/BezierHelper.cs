using UnityEngine;

public partial class BezierSurface {

	private class BezierHelper {
		
		public static Vector3 BezierAtPoint(float u, float v, int n, int m, Vector3[,] anchorPoints) {
			float x = 0;
			for (int i = 0; i <= n; i++) {
				for (int j = 0; j <= m; j++) {
					x += BernsteinPolynomial(n, i, u) * BernsteinPolynomial(m, j, v) * anchorPoints[i, j].x;
				}
			}
			
			float y = 0;
			for (int i = 0; i <= n; i++) {
				for (int j = 0; j <= m; j++) {
					y += BernsteinPolynomial(n, i, u) * BernsteinPolynomial(m, j, v) * anchorPoints[i, j].y;
				}
			}
			
			float z = 0;
			for (int i = 0; i <= n; i++) {
				for (int j = 0; j <= m; j++) {
					z += BernsteinPolynomial(n, i, u) * BernsteinPolynomial(m, j, v) * anchorPoints[i, j].z;
				}
			}
			
			return new Vector3(x, y, z);
		}
		
		public static float BernsteinPolynomial(int n, int i, float u) {
			return (Factorial(n) / (Factorial(i) * Factorial(n - i))) * Mathf.Pow(u, i) * Mathf.Pow(1.0f - u, n - i);
		}
		
		private static long Factorial(long x) {
			return (x == 0) ? 1 : x * Factorial(x - 1);
		}
	}
}