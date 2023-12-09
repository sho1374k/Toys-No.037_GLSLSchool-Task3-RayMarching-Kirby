precision highp float;
uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;
uniform sampler2D backbuffer;

const float PI  = 3.141592653589793;
const float THRESHOLD = 0.0000000000000000001;
const vec3 COLOR_BASE = vec3(1,.93,.99);
const vec3 COLOR_BODY = vec3(1,.81,.88);
const vec3 COLOR_FOOT = vec3(.87,.4,.51);
const vec3 COLOR_CHEEK = vec3(1,.68,.78);
const vec3 COLOR_IRIS = vec3(.91,.99,1);
const vec3 COLOR_PURPLE = vec3(.490,.380,.780);
const vec3 COLOR_SKY = vec3(.92,.86,1);
const vec3 COLOR_CLOUD = vec3(.93,.99,1);
const vec3 COLOR_CLOUD_EDGE = vec3(.77,.84,1);

// GLSL textureless classic 3D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-10-11
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/ashima/webgl-noise
vec3 mod289(vec3 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 permute(vec4 x){return mod289(((x*34.0)+1.0)*x);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
// Classic Perlin noise
float cnoise(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
  return 2.2 * n_xyz;
}

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
	mat4 m = rotationMatrix(axis, angle);
	return (m * vec4(v, 1.0)).xyz;
}

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
    PI * 0.175 + (abs(sin(time)) * PI * 0.25)
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
    PI * -0.15 - (abs(sin(time)) * PI * 0.25)
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
  float a1 = resolution.x / resolution.y;
  float a2 = resolution.y / resolution.x;
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
  pos.x += (cos(time)) * 0.05;
  pos.y += (sin(time)) * -0.05;

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
  pos.x += (cos(time)) * 0.05;
  pos.y += (sin(time)) * -0.05;

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
  pos.x += (sin(time)) * 0.05;
  pos.y += (cos(time)) * -0.05;

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

  p1.y += (abs(sin(time)) * 0.1);
  p2.y +=  (abs(sin(time)) * 0.08);
  p3.y +=  (abs(sin(time)) * 0.09);

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

void main(){
  vec2 r=resolution,p=(gl_FragCoord.xy*2.-r)/min(r.x,r.y);
  float aspect=r.x/r.y; 
  p.x += (sin(time * 0.5) * 0.1);
  p.y += (sin(time * 0.5) * 0.1);
  
  vec3 rayPos, ligthPos = vec3(2.0),
  cameraPos = vec3(0.0, 0.0, 2.0),
  cameraDir = vec3(0.0, 0.0, -1.0),
  cameraUp = vec3(0.0, 1.0, 0.0),
  cameraSide = cross(cameraDir, cameraUp);

  float targetDepth = 1.0;
  vec3 ray = normalize((cameraSide * p.x) + (cameraUp * p.y) + (cameraDir * targetDepth));

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