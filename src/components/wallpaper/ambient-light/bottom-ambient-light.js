(function () {
  "use strict";

  var root = document.getElementById("bottom-ambient-light");
  if (!root || window.BottomAmbientLightSystem) return;

  var palettes = [
    ["112, 190, 255", "158, 115, 255", "255, 120, 198"],
    ["91, 229, 205", "91, 169, 255", "172, 125, 255"],
    ["255, 188, 105", "255, 116, 139", "144, 112, 255"]
  ];
  var state = {
    enabled: true,
    intensity: 72,
    palette: 0,
    pointerReactive: true,
    audioReactive: true,
    paused: false,
    lowPower: false,
    audioLevel: 0
  };
  var pointerFrame = 0;
  var pointerX = 0.5;
  var audioDecayTimer = 0;

  function clamp(value, minimum, maximum) {
    return Math.max(minimum, Math.min(maximum, value));
  }

  function applyPalette() {
    var palette = palettes[clamp(Math.round(state.palette), 0, palettes.length - 1)];
    root.style.setProperty("--bottom-ambient-primary", palette[0]);
    root.style.setProperty("--bottom-ambient-secondary", palette[1]);
    root.style.setProperty("--bottom-ambient-accent", palette[2]);
  }

  function applyStrength() {
    var base = clamp(state.intensity / 100, 0, 1);
    var audioLift = state.audioReactive ? state.audioLevel * 0.16 : 0;
    root.style.opacity = String(clamp(base + audioLift, 0, 1));
    root.style.setProperty("--bottom-ambient-audio-scale", String(1 + state.audioLevel * 0.08));
    root.hidden = !state.enabled || state.intensity <= 0;
    root.classList.toggle("is-paused", state.paused);
    root.classList.toggle("is-low-power", state.lowPower);
  }

  function applyAll() {
    applyPalette();
    applyStrength();
  }

  function updatePointer() {
    pointerFrame = 0;
    var percent = clamp(pointerX * 100, 12, 88);
    var shift = (pointerX - 0.5) * 44;
    root.style.setProperty("--bottom-ambient-focus-x", percent.toFixed(2) + "%");
    root.style.setProperty("--bottom-ambient-shift", shift.toFixed(2) + "px");
  }

  function onPointerMove(event) {
    if (!state.enabled || !state.pointerReactive || state.paused || state.lowPower) return;
    pointerX = clamp(event.clientX / Math.max(1, window.innerWidth), 0, 1);
    if (!pointerFrame) pointerFrame = window.requestAnimationFrame(updatePointer);
  }

  function onAudio(values) {
    if (!state.enabled || !state.audioReactive || state.paused || !values || !values.length) return;
    var count = Math.min(10, values.length);
    var total = 0;
    for (var index = 0; index < count; index++) total += Math.abs(Number(values[index]) || 0);
    var level = total / Math.max(1, count);
    if (level > 1.5) level /= 128;
    state.audioLevel = clamp(level, 0, 1);
    applyStrength();
    window.clearTimeout(audioDecayTimer);
    audioDecayTimer = window.setTimeout(function () {
      state.audioLevel = 0;
      applyStrength();
    }, 220);
  }

  function setPaused(value) {
    state.paused = Boolean(value);
    if (state.paused) state.audioLevel = 0;
    applyStrength();
  }

  function onProperty(name, value) {
    switch (name) {
      case "bottomAmbientEnabled":
        state.enabled = Boolean(value);
        break;
      case "bottomAmbientIntensity":
        state.intensity = clamp(Number(value) || 0, 0, 100);
        break;
      case "bottomAmbientPalette":
        state.palette = clamp(Number(value) || 0, 0, palettes.length - 1);
        break;
      case "bottomAmbientPointerReactive":
        state.pointerReactive = Boolean(value);
        break;
      case "bottomAmbientAudioReactive":
        state.audioReactive = Boolean(value);
        if (!state.audioReactive) state.audioLevel = 0;
        break;
      case "animalTrailLowPower":
      case "spaceLowPower":
        state.lowPower = Boolean(value);
        break;
      case "bottomAmbientReset":
        if (!value) return false;
        state.enabled = true;
        state.intensity = 72;
        state.palette = 0;
        state.pointerReactive = true;
        state.audioReactive = true;
        state.audioLevel = 0;
        break;
      default:
        return false;
    }
    applyAll();
    return true;
  }

  document.addEventListener("pointermove", onPointerMove, { passive: true });
  document.addEventListener("visibilitychange", function () {
    root.classList.toggle("is-document-hidden", document.hidden);
  });

  window.BottomAmbientLightSystem = {
    onAudio: onAudio,
    onProperty: onProperty,
    setPaused: setPaused,
    getState: function () {
      return {
        enabled: state.enabled,
        intensity: state.intensity,
        palette: state.palette,
        pointerReactive: state.pointerReactive,
        audioReactive: state.audioReactive,
        paused: state.paused,
        lowPower: state.lowPower
      };
    }
  };

  applyAll();
}());
