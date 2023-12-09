precision mediump float;
varying vec2 vUv;
uniform float uProgress1;
uniform float uProgress2;
uniform float uProgress3;
uniform float uAspect1;
uniform float uAspect2;
uniform float uTime;
uniform vec2 uPointer;
uniform vec2 uResolution;

const float PI  = 3.141592653589793;
const float THRESHOLD = 0.0000000000000000001;
const vec3 COLOR_BASE = vec3(1.0, 0.93, 0.99);
const vec3 COLOR_BODY = vec3(1.0, 0.81, 0.88);
const vec3 COLOR_FOOT = vec3(0.87, 0.4, 0.51);
const vec3 COLOR_CHEEK = vec3(1.0, 0.68, 0.78);
const vec3 COLOR_IRIS = vec3(0.91, 0.99, 1.0);
const vec3 COLOR_PURPLE = vec3(0.490, 0.380, 0.780);
const vec3 COLOR_SKY = vec3(0.92, 0.86, 1.0);
const vec3 COLOR_CLOUD = vec3(0.93, 0.99, 1.0);
const vec3 COLOR_CLOUD_EDGE = vec3(0.77, 0.84, 1.0);

#include "../_chunk/classic3d.glsl"
#include "../_chunk/rotate.glsl"

float smin(float a, float b, float k){
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

float sphereSDF(vec3 p, float r){
  return length(p)-r;
}

float ellipsoidSDF(vec3 p, vec3 r){
  float k0 = length(p/r);
  float k1 = length(p/(r*r));
  return k0*(k0-1.0)/k1;
}

float cappedTorusSDF( vec3 p, vec2 sc, float ra, float rb){
  p.x = abs(p.x);
  float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
  return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

float boxSDF(vec3 p, vec3 b){
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float createBody(vec3 p){
  return sphereSDF(
    vec3(
      p.x,
      p.y - 0.05,
      p.z
    ), 0.8
  );
}

float createHandLeft(vec3 p){
 vec3 pos = rotate(
    vec3(
      p.x + 0.4, 
      p.y - 0.3, 
      p.z - 0.5
    ),
    vec3(0.0, 0.0, 1.0),
    PI * 0.175 + (abs(sin(uTime)) * PI * 0.25)
  );
  return ellipsoidSDF(pos,vec3(0.2, 0.3, 0.2));
}

float createHandRight(vec3 p){
    vec3 pos = rotate(
    vec3(
      p.x - 0.375, 
      p.y - 0.55, 
      p.z + 0.0
    ),
    vec3(0.0, 0.0, 1.0),
    PI * -0.15 - (abs(sin(uTime)) * PI * 0.25)
  );
  return ellipsoidSDF(pos,vec3(0.25, 0.35, 0.25));
}

float createFootLeft(vec3 p){
   vec3 pos = rotate(
    vec3(
      p.x + 0.575,
      p.y + 0.525,
      p.z + 0.09
    ),
    vec3(0.0, 0.0, 1.0),
    PI * -0.075
  );
  return ellipsoidSDF(pos,vec3(0.25, 0.35, 0.25));
}

float createFootRight(vec3 p){
    vec3 pos = rotate(
    vec3(
      p.x - 0.18,
      p.y + 0.55,
      p.z + 0.075
    ),
    vec3(0.0, 0.0, 1.0),
    PI * 0.015
  );
  return ellipsoidSDF(pos,vec3(0.26, 0.36, 0.26));
}

float createEyeLeft(vec3 p){
  vec3 pos = rotate(
    vec3(
      p.x - .1 + 0.038,
      p.y - 0.32,
      p.z - .7 - 0.06 - 0.1
    ),
    vec3(0.0, 0.0, 1.0),
    PI * (0.052)
  );
  pos = rotate(
    pos,
    vec3(1.0, 0.0, 0.0),
    PI * -0.124
  );
  return ellipsoidSDF(pos,vec3(0.05, 0.14, 0.01));
}

float createEyeRight(vec3 p){
  vec3 pos = rotate(
    vec3(
      p.x - .1 + 0.038 - 0.17,
      p.y - 0.325,
      p.z - .7 - 0.06 - 0.1
    ),
    vec3(0.0, 0.0, 1.0),
    PI * 0.049
  );
  pos = rotate(
    pos,
    vec3(1.0, 0.0, 0.0),
    PI * -0.082
  );
  return ellipsoidSDF(pos,vec3(0.05 * 0.95, 0.12, 0.01));
}

float createIrisLeft(vec3 p){
    vec3 pos = rotate(
    vec3(
      p.x - .1 + 0.038 + .0175,
      p.y - 0.32 + 0.02,
      p.z - .7 - 0.06 - 0.1 - 0.2
    ),
    vec3(0.0, 0.0, 1.0),
    PI * (0.052)
  );
  pos = rotate(
    pos,
    vec3(1.0, 0.0, 0.0),
    PI * -0.124
  );
  float scale = 0.45;
  return ellipsoidSDF(pos,vec3(0.05 * 0.45, 0.14 * 0.35, 0.01));
}

float createIrisRight(vec3 p){
  vec3 pos = rotate(
    vec3(
      p.x - .1 + 0.038 + .0175 - 0.15 + 0.01,
      p.y - 0.32 + 0.02,
      p.z - .7 - 0.06 - 0.1 - 0.2
    ),
    vec3(0.0, 0.0, 1.0),
    PI * (0.052 - 0.015)
  );
  pos = rotate(
    pos,
    vec3(1.0, 0.0, 0.0),
    PI * -0.124
  );
  return ellipsoidSDF(pos,vec3(0.05 * 0.45 * 0.95, 0.14 * 0.35, 0.01));
}

float createCheekLeft(vec3 p){
  vec3 pos = vec3(
    p.x + 0.1 - 0.035,
    p.y - 0.2 + 0.015,
    p.z - 0.75 - 0.1
  );
  return sphereSDF(pos, 0.085);
}

float createCheekRight(vec3 p){
  vec3 pos = vec3(
    p.x - 0.1 - 0.25 - 0.014,
    p.y - 0.2,
    p.z - 0.75 - 0.1
  );
  return sphereSDF(pos, 0.075);
}

float createMouthCenter(vec3 p){
  vec3 pos = rotate(
    vec3(
      p.x - 0.1825,
      p.y - 0.12,
      p.z - 0.9
    ),
    vec3(0.0, 0.0, 1.0),
    PI * (0.04)
  );
  return cappedTorusSDF(pos, vec2(0.5, 0.5), 0.05 * 1.1, 0.005 * 1.5);
}

float createMouthLeft(vec3 p){
  vec3 pos = rotate(
    vec3(
      p.x - 0.085,
      p.y - 0.14,
      p.z - 1.0
    ),
    vec3(0.0, 0.0, 1.0),
    PI * (-0.45)
  );
  return cappedTorusSDF(pos, vec2(0.4, 0.4), 0.05 *0.9 * 0.9, 0.005 * 1.25 * 0.9);
}

float createMouthRight(vec3 p){
  vec3 pos = rotate(
    vec3(
      p.x - 0.085- 0.1525,
      p.y - 0.154,
      p.z - 1.0
    ),
    vec3(0.0, 0.0, 1.0),
    PI * (0.55)
  );
  return cappedTorusSDF(pos, vec2(0.4, 0.4), 0.05 *0.9 * 0.9, 0.005 * 1.25 * 0.9);
}

float createSky(vec3 p){
  float a1 = uResolution.x / uResolution.y;
  float a2 = uResolution.y / uResolution.x;
  float a3 = max(a1, a2);
  vec3 pos = vec3(p.x,p.y - 0.55,p.z - 1.5);
  float n1 = cnoise(pos) * 0.1;
  return boxSDF(pos, vec3(1.0 * a3, 0.1 - n1, 0.1));
}

float hartSDF(vec3 p, float s){
  p = rotate(p, vec3(0.0, 0.0, 1.0), PI);
  p *= s;
  return sqrt(
    pow(p.x, 2.0) + pow(p.y, 2.0) + 2.25 * pow(p.z, 2.0) + pow(
      pow(p.x, 2.0) + 0.1125 * pow(p.z, 2.0), 
      0.33
    ) * p.y
  ) - 1.0;
}

float createCloud1(vec3 p){
  vec3 pos = vec3(p.x - 2.0,p.y,p.z);
  pos.x += (cos(uTime)) * 0.05;
  pos.y += (sin(uTime)) * -0.05;

  float c,
  c1 = sphereSDF(pos, 0.2),
  c2 = sphereSDF(pos + vec3(-0.15 , 0.1, 0.0), 0.2),
  c3 = sphereSDF(pos + vec3(0.15 , 0.1, 0.0), 0.2),
  c4 = sphereSDF(pos + vec3(0.1 , 0.15, -0.2), 0.15);

  c = smin(c1, c2, 0.04);
  c = smin(c, c3, 0.04);
  c = smin(c, c4, 0.04);
  return c;
}

float createCloud2(vec3 p){
  vec3 pos = vec3(p.x + 2.0,p.y - 0.75,p.z);
  pos.x += (cos(uTime)) * 0.05;
  pos.y += (sin(uTime)) * -0.05;

  float c,
  c1 = sphereSDF(pos, 0.2),
  c2 = sphereSDF(pos + vec3(-0.1 , 0.1, 0.0), 0.2),
  c3 = sphereSDF(pos + vec3(0.2 , 0.1, 0.0), 0.2),
  c4 = sphereSDF(pos + vec3(0.0 , 0.2, -0.1), 0.15);

  c = smin(c1, c2, 0.04);
  c = smin(c, c3, 0.04);
  c = smin(c, c4, 0.04);
  return c;
}

float createCloud3(vec3 p){
  vec3 pos = vec3(p.x + 1.5,p.y + 1.0,p.z);
  pos.x += (sin(uTime)) * 0.05;
  pos.y += (cos(uTime)) * -0.05;

  float c,
  c1 = sphereSDF(pos, 0.2),
  c2 = sphereSDF(pos + vec3(-0.2 , 0.1, 0.0), 0.2),
  c3 = sphereSDF(pos + vec3(0.2 , 0.1, 0.0), 0.2),
  c4 = sphereSDF(pos + vec3(-0.084  , 0.05, -0.15), 0.15);

  c = smin(c1, c2, 0.04);
  c = smin(c, c3, 0.04);
  c = smin(c, c4, 0.04);
  return c;
}

vec2 sceneSDF(vec3 p){
  float dist, id = 0.0;
  vec3 p1=p,p2=p,p3=p;

  p1.y += (abs(sin(uTime)) * 0.1);
  p2.y +=  (abs(sin(uTime)) * 0.08);
  p3.y +=  (abs(sin(uTime)) * 0.09);

  float body = createBody(p1);
  float handLeft = createHandLeft(p1);
  float handRight = createHandRight(p1);
  float footLeft = createFootLeft(p1);
  float footRight = createFootRight(p1);
  float eyeLeft = createEyeLeft(p1);
  float eyeRight = createEyeRight(p1);
  float irisLeft = createIrisLeft(p2);
  float irisRight = createIrisRight(p2);
  float cheekLeft = createCheekLeft(p1);
  float cheekRight = createCheekRight(p1);
  float mouthCenter = createMouthCenter(p3);
  float mouthLeft = createMouthLeft(p2);
  float mouthRight = createMouthRight(p2);

  float sky = createSky(p);
  float cloud1 = createCloud1(p);
  float cloud2 = createCloud2(p);
  float cloud3 = createCloud3(p);

  dist = smin(body, handLeft, 0.05);
  dist = smin(dist, handRight, 0.05);
  dist = min(dist, footLeft);
  dist = min(dist, footRight);
  dist = min(dist, eyeLeft);
  dist = min(dist, eyeRight);
  dist = min(dist, irisLeft);
  dist = min(dist, irisRight);
  dist = min(dist, cheekLeft);
  dist = min(dist, cheekRight);
  dist = min(dist, mouthCenter);
  dist = min(dist, mouthLeft);
  dist = min(dist, mouthRight);
  dist = min(dist, sky);
  dist = min(dist, cloud1);
  dist = min(dist, cloud2);
  dist = min(dist, cloud3);


  if(abs(dist - body) < 0.02) {
    id = 0.0;
  } else if(abs(dist - handLeft) < 0.01 || abs(dist - handRight) < 0.01) {
    id = 1.0;
  } else if (abs(dist - footLeft) < 0.01 || abs(dist - footRight) < 0.01) {
    id = 2.0;
  } else if(abs(dist - eyeLeft) < THRESHOLD || abs(dist - eyeRight) < THRESHOLD) {
    id = 3.0;
  } else if(abs(dist - irisLeft) < THRESHOLD || abs(dist - irisRight) < THRESHOLD) {
    id = 4.0;
  } else if(abs(dist - cheekLeft) < THRESHOLD || abs(dist - cheekRight) < THRESHOLD) {
    id = 5.0;
  } else if(abs(dist - mouthCenter) < THRESHOLD || abs(dist - mouthLeft) < THRESHOLD || abs(dist - mouthRight) < THRESHOLD) {
    id = 6.0;
  } else if(abs(dist - sky) < 0.01) {
    id = 7.0;
  } else if(abs(dist - cloud1) < THRESHOLD || abs(dist - cloud2) < THRESHOLD || abs(dist - cloud3) < THRESHOLD) {
    id = 8.0;
  } else {
    id = -1.0;
  }

  return vec2(dist, id);
}

vec3 calcNormal(vec3 p){
  float eps = 0.0001;
  vec2 h = vec2(eps,0.0);
  return normalize(vec3(
    sceneSDF(p+h.xyy).x - sceneSDF(p-h.xyy).x, 
    sceneSDF(p+h.yxy).x - sceneSDF(p-h.yxy).x, 
    sceneSDF(p+h.yyx).x - sceneSDF(p-h.yyx).x
  ));
}

void main( void ) {
  // vec2 uv = (gl_FragCoord.xy * 2.0 - uResolution) / min(uResolution.x, uResolution.y);
  vec2 uv = vUv * 2.0 - vec2(1.0);
  uv.x *= uAspect1;
  uv.x += (sin(uTime * 0.5) * 0.1);
  uv.y += (sin(uTime * 0.5) * 0.1);

  vec3 rayPos, ligthPos = vec3(2.0),
  cameraPos = vec3(0.0, 0.0, 2.0),
  cameraDir = vec3(0.0, 0.0, -1.0),
  cameraUp = vec3(0.0, 1.0, 0.0),
  cameraSide = cross(cameraDir, cameraUp);

  float targetDepth = 1.0;
  vec3 ray = normalize((cameraSide * uv.x) + (cameraUp * uv.y) + (cameraDir * targetDepth));

  ray = normalize(ray);

  float rayStep = 0.0, rayStepMax = 5.0, id = 0.0;
  for(int i = 0; i < 128; i++) {
    rayPos = ray * rayStep + cameraPos;
    float rayHit = sceneSDF(rayPos).x;
    id = sceneSDF(rayPos).y;
    if(rayHit < 0.0001 || rayStep > rayStepMax) break;
    rayStep+=rayHit;
  }

  vec3 color = COLOR_BASE, edgeColor = COLOR_PURPLE;
  if(rayStep < rayStepMax) {
    vec3 normal = calcNormal(rayPos);
    float diff  = dot(ligthPos, normal);

    float edge = 2.0;
    if(id == 0.0) {
      edge = 2.5;
      color = COLOR_BODY + vec3(diff) * 0.025;
    } 
    else if(id == 1.0) {
      edge = 1.5;
      color = COLOR_BODY + vec3(diff) * 0.025;
    } 
    else if(id == 2.0) {
      edge = 1.25;
      color = COLOR_FOOT + vec3(diff) * 0.025;
    }
    else if(id == 3.0) {
      color = COLOR_PURPLE + vec3(diff) * 0.025;
    }
    else if(id == 4.0) {
      color = COLOR_IRIS + vec3(diff) * 0.025;
    }
    else if(id == 5.0) {
      edge = 1.2;
      color = COLOR_CHEEK;
    }
    else if(id == 6.0) {
      color = COLOR_PURPLE;
    }
    else if(id == 7.0) {
      edge = 0.0;
      edgeColor = COLOR_SKY;
    }
    else if(id == 8.0) {
      edge = 2.0;
      color = COLOR_CLOUD + vec3(diff) * 0.025;
      edgeColor = COLOR_CLOUD_EDGE;
    }

    float fresnel = pow(1.0 + dot(ray, normal), edge);
    float invertFresnel = 1.0 - fresnel;

    float stepFresnel = 1.0 - step(fresnel, 0.6);
    float stepInvertFresnel = 1.0 - step(invertFresnel, 0.4);

    vec3 outline = edgeColor * stepFresnel;
    vec3 base = color * stepInvertFresnel;
    color = base + outline;
  }

  gl_FragColor = vec4(color, 1.0);
}
