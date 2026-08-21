(function () {
  "use strict";

  var activePanel = null;
  var toastTimer = 0;
  var dock = document.getElementById("dock");
  var toast = document.getElementById("toast");
  var focusToggle = document.getElementById("focus-toggle");
  var clock = document.getElementById("menu-clock");

  function showToast(message) {
    window.clearTimeout(toastTimer);
    toast.textContent = message;
    toast.classList.add("is-visible");
    toastTimer = window.setTimeout(function () {
      toast.classList.remove("is-visible");
    }, 1900);
  }

  function closePanels() {
    document.querySelectorAll(".popover").forEach(function (panel) {
      panel.hidden = true;
    });
    document.querySelectorAll("[data-panel]").forEach(function (trigger) {
      trigger.setAttribute("aria-expanded", "false");
    });
    activePanel = null;
  }

  function togglePanel(panelId, trigger) {
    var panel = document.getElementById(panelId);
    if (!panel) {
      showToast("“" + (trigger.textContent.trim() || "此菜单") + "”正在设计中");
      return;
    }

    var shouldOpen = activePanel !== panelId;
    closePanels();
    if (shouldOpen) {
      panel.hidden = false;
      trigger.setAttribute("aria-expanded", "true");
      activePanel = panelId;
    }
  }

  function selectWindow(windowId) {
    document.querySelectorAll(".desktop-window").forEach(function (windowElement) {
      var shouldShow = windowElement.id === windowId;
      windowElement.hidden = !shouldShow;
      windowElement.classList.toggle("is-active", shouldShow);
    });
    document.querySelectorAll(".stage-card").forEach(function (card) {
      card.classList.toggle("is-selected", card.getAttribute("data-window") === windowId);
    });
    closePanels();
  }

  function updateClock() {
    var now = new Date();
    var formatter = new Intl.DateTimeFormat("zh-CN", {
      weekday: "short",
      hour: "2-digit",
      minute: "2-digit"
    });
    clock.dateTime = now.toISOString();
    clock.textContent = formatter.format(now);
  }

  document.querySelectorAll("[data-panel]").forEach(function (trigger) {
    trigger.addEventListener("click", function (event) {
      event.stopPropagation();
      togglePanel(trigger.getAttribute("data-panel"), trigger);
    });
  });

  document.querySelectorAll("[data-close-panels]").forEach(function (button) {
    button.addEventListener("click", closePanels);
  });

  document.querySelectorAll(".stage-card").forEach(function (card) {
    card.addEventListener("click", function () {
      selectWindow(card.getAttribute("data-window"));
    });
  });

  document.querySelectorAll(".traffic-light.close").forEach(function (button) {
    button.addEventListener("click", function () {
      var windowElement = button.closest(".desktop-window");
      if (windowElement) {
        windowElement.hidden = true;
        showToast("窗口已收起到左侧窗口组");
      }
    });
  });

  document.querySelectorAll(".traffic-light.minimize").forEach(function (button) {
    button.addEventListener("click", function () {
      var windowElement = button.closest(".desktop-window");
      if (windowElement) {
        windowElement.classList.remove("is-active");
        showToast("窗口已最小化");
      }
    });
  });

  document.querySelectorAll(".traffic-light.maximize").forEach(function (button) {
    button.addEventListener("click", function () {
      var windowElement = button.closest(".desktop-window");
      if (windowElement) {
        windowElement.classList.toggle("is-large");
        showToast(windowElement.classList.contains("is-large") ? "窗口已缩放" : "窗口恢复原尺寸");
      }
    });
  });

  focusToggle.addEventListener("click", function () {
    var isFocusMode = document.body.classList.toggle("focus-mode");
    focusToggle.classList.toggle("is-on", isFocusMode);
    focusToggle.setAttribute("aria-pressed", String(isFocusMode));
    showToast(isFocusMode ? "专注模式已开启" : "专注模式已关闭");
  });

  dock.addEventListener("pointermove", function (event) {
    var icons = Array.prototype.slice.call(dock.querySelectorAll(".dock-app"));
    icons.forEach(function (icon) {
      var rect = icon.getBoundingClientRect();
      var distance = Math.abs((rect.left + rect.width / 2) - event.clientX);
      var scale = Math.max(1, 1.42 - distance / 132);
      icon.style.transform = "translateY(" + ((scale - 1) * -18).toFixed(1) + "px) scale(" + scale.toFixed(3) + ")";
      icon.style.zIndex = String(Math.round(scale * 100));
    });
  });

  dock.addEventListener("pointerleave", function () {
    dock.querySelectorAll(".dock-app").forEach(function (icon) {
      icon.style.transform = "";
      icon.style.zIndex = "";
    });
  });

  dock.querySelectorAll(".dock-app").forEach(function (app) {
    app.addEventListener("click", function () {
      showToast((app.getAttribute("data-tooltip") || "应用") + "已准备打开");
    });
  });

  document.addEventListener("click", function (event) {
    if (!event.target.closest(".popover") && !event.target.closest("[data-panel]")) {
      closePanels();
    }
  });

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") closePanels();
    if (event.key.toLowerCase() === "f" && !event.ctrlKey && !event.metaKey && !event.altKey) {
      focusToggle.click();
    }
  });

  updateClock();
  window.setInterval(updateClock, 30000);
}());
