/*
  hero-scene.js — the homepage signature.

  A single procedural object: a noise-displaced sphere that reads as a bead of
  serum. Deep olive body, gold rim light, slow drift, a few degrees of lean
  toward the cursor. No model file, so nothing here depends on product
  photography that does not exist yet.

  Colours are read from the section's own colour scheme at mount time, so
  changing the scheme in the theme editor recolours the scene.

  This module is only ever imported by brand.js, and only after it has checked
  for WebGL2, a fine pointer, a viewport wide enough to be worth it, and no
  reduced-motion preference. If it throws, brand.js swallows it and the CSS
  gradient underneath stays on screen.
*/

const VERTEX_SHADER = /* glsl */ `
  uniform float uTime;
  uniform float uAmplitude;
  varying vec3 vNormal;
  varying vec3 vPosition;
  varying float vDisplacement;

  //
  // Ashima simplex noise (public domain). Used to push vertices along their
  // normals so the surface moves like something viscous rather than elastic.
  //
  vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
  vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
  vec4 permute(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }
  vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

  float snoise(vec3 v) {
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);

    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    i = mod289(i);
    vec4 p = permute(permute(permute(
              i.z + vec4(0.0, i1.z, i2.z, 1.0))
            + i.y + vec4(0.0, i1.y, i2.y, 1.0))
            + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    float n_ = 0.142857142857;
    vec3 ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);

    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);

    vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
  }

  void main() {
    // Two octaves: a slow swell, and a finer ripple travelling over it.
    float swell  = snoise(position * 0.9 + vec3(0.0, uTime * 0.16, 0.0));
    float ripple = snoise(position * 2.6 - vec3(uTime * 0.22, 0.0, 0.0)) * 0.35;
    float displacement = (swell + ripple) * uAmplitude;

    vDisplacement = displacement;
    vNormal = normalize(normalMatrix * normal);

    vec3 displaced = position + normal * displacement;
    vec4 mvPosition = modelViewMatrix * vec4(displaced, 1.0);
    vPosition = mvPosition.xyz;

    gl_Position = projectionMatrix * mvPosition;
  }
`;

const FRAGMENT_SHADER = /* glsl */ `
  uniform vec3 uColorDeep;
  uniform vec3 uColorMid;
  uniform vec3 uColorRim;
  varying vec3 vNormal;
  varying vec3 vPosition;
  varying float vDisplacement;

  void main() {
    vec3 viewDirection = normalize(-vPosition);
    vec3 normal = normalize(vNormal);

    // Fresnel: the rim lights up where the surface turns away from the viewer.
    float fresnel = pow(1.0 - clamp(dot(viewDirection, normal), 0.0, 1.0), 2.4);

    // A single key light from upper left, kept soft so the form stays readable.
    float key = clamp(dot(normal, normalize(vec3(-0.4, 0.8, 0.6))), 0.0, 1.0);

    // Crests read warmer than troughs, which is what makes it look wet.
    float crest = smoothstep(-0.2, 0.35, vDisplacement);

    vec3 color = mix(uColorDeep, uColorMid, key * 0.75 + crest * 0.25);
    color = mix(color, uColorRim, fresnel * 0.85);

    gl_FragColor = vec4(color, 0.92);
  }
`;

/** Reads an "r,g,b" Dawn colour-scheme custom property as a 0–1 triplet. */
function readSchemeColor(styles, name, fallback) {
  const raw = styles.getPropertyValue(name).trim();
  const parts = raw.split(',').map((part) => Number.parseFloat(part));
  if (parts.length < 3 || parts.some(Number.isNaN)) return fallback;
  return parts.slice(0, 3).map((channel) => channel / 255);
}

export async function mountHeroScene(layer) {
  const threeSrc = layer.dataset.threeSrc;
  if (!threeSrc) return;

  const THREE = await import(threeSrc);

  const styles = getComputedStyle(layer);
  const deep = readSchemeColor(styles, '--color-background', [0.17, 0.2, 0.15]);
  const mid = readSchemeColor(styles, '--color-foreground', [0.33, 0.42, 0.18]);
  const rim = readSchemeColor(styles, '--color-button', [0.83, 0.78, 0.62]);

  const canvas = document.createElement('canvas');
  layer.appendChild(canvas);

  const renderer = new THREE.WebGLRenderer({
    canvas,
    alpha: true,
    antialias: true,
    powerPreference: 'high-performance',
  });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(38, 1, 0.1, 100);
  camera.position.z = 3.4;

  const uniforms = {
    uTime: { value: 0 },
    uAmplitude: { value: 0.22 },
    uColorDeep: { value: new THREE.Color(...deep) },
    uColorMid: { value: new THREE.Color(...mid) },
    uColorRim: { value: new THREE.Color(...rim) },
  };

  // detail 32 ≈ 21k triangles — dense enough that the displacement reads as a
  // surface rather than facets, light enough to hold 60fps on a laptop GPU.
  const geometry = new THREE.IcosahedronGeometry(1, 32);
  const material = new THREE.ShaderMaterial({
    uniforms,
    vertexShader: VERTEX_SHADER,
    fragmentShader: FRAGMENT_SHADER,
    transparent: true,
  });

  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);

  function resize() {
    const { clientWidth: width, clientHeight: height } = layer;
    if (!width || !height) return;
    renderer.setSize(width, height, false);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
  }

  resize();
  const resizeObserver = new ResizeObserver(resize);
  resizeObserver.observe(layer);

  // Pointer lean. Targets are eased toward, so the object never snaps.
  const pointer = { x: 0, y: 0, targetX: 0, targetY: 0 };
  function onPointerMove(event) {
    pointer.targetX = (event.clientX / window.innerWidth - 0.5) * 2;
    pointer.targetY = (event.clientY / window.innerHeight - 0.5) * 2;
  }
  window.addEventListener('pointermove', onPointerMove, { passive: true });

  // The loop only runs while the hero is on screen and the tab is visible.
  let onScreen = true;
  let frameId = null;
  const clock = new THREE.Clock();

  const visibilityObserver = new IntersectionObserver(
    (entries) => {
      onScreen = entries.some((entry) => entry.isIntersecting);
      if (onScreen) {
        start();
      } else {
        stop();
      }
    },
    { threshold: 0 }
  );
  visibilityObserver.observe(layer);

  function tick() {
    uniforms.uTime.value = clock.getElapsedTime();

    pointer.x += (pointer.targetX - pointer.x) * 0.045;
    pointer.y += (pointer.targetY - pointer.y) * 0.045;

    mesh.rotation.y = clock.getElapsedTime() * 0.09 + pointer.x * 0.28;
    mesh.rotation.x = pointer.y * 0.2;

    renderer.render(scene, camera);
    frameId = requestAnimationFrame(tick);
  }

  function start() {
    if (frameId === null && onScreen && !document.hidden) {
      clock.getDelta();
      frameId = requestAnimationFrame(tick);
    }
  }

  function stop() {
    if (frameId !== null) {
      cancelAnimationFrame(frameId);
      frameId = null;
    }
  }

  function onVisibilityChange() {
    if (document.hidden) {
      stop();
    } else {
      start();
    }
  }
  document.addEventListener('visibilitychange', onVisibilityChange);

  function dispose() {
    stop();
    resizeObserver.disconnect();
    visibilityObserver.disconnect();
    window.removeEventListener('pointermove', onPointerMove);
    document.removeEventListener('visibilitychange', onVisibilityChange);
    document.removeEventListener('shopify:section:unload', dispose);
    geometry.dispose();
    material.dispose();
    renderer.dispose();
    canvas.remove();
  }

  window.addEventListener('pagehide', dispose, { once: true });
  document.addEventListener('shopify:section:unload', dispose);

  layer.dataset.sceneReady = 'true';
  start();
}
