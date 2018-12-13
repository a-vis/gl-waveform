// fragment shader with fading based on distance from average

precision highp float;

uniform vec4 viewport;
uniform float thickness;
uniform vec2 amp;

varying vec4 fragColor;
varying float avgCurr, avgPrev, avgNext, avgMin, avgMax, sdev, normThickness;

const float TAU = 6.283185307179586;

float pdf (float x, float mean, float variance) {
	if (variance == 0.) return x == mean ? 9999. : 0.;
	else return exp(-.5 * pow(x - mean, 2.) / variance) / sqrt(TAU * variance);
}

void main() {
	float halfThickness = normThickness * .5;

	float x = (gl_FragCoord.x - viewport.x) / viewport.z;
	float y = (gl_FragCoord.y - viewport.y) / viewport.w;

	// pdfMax makes sure pdf is normalized - has 1. value at the max
	float pdfMax = pdf(0., 0., sdev * sdev  );

	float dist = 1.;

	// local max
	if (y > avgMax + halfThickness) {
		dist = avgMax - y;
		dist = pdf(dist + halfThickness, 0., sdev * sdev  ) / pdfMax;
	}
	// local min
	else if (y < avgMin - halfThickness) {
		dist = y - avgMin;
		dist = pdf(dist + halfThickness, 0., sdev * sdev  ) / pdfMax;
	}

	gl_FragColor = fragColor;
	gl_FragColor.a *= dist;
}
