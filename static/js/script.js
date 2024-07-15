function showTab(tabId) {
  document.querySelectorAll(".tab-content").forEach((tab) => {
    tab.classList.remove("active");
  });
  document.querySelectorAll(".tab-button").forEach((button) => {
    button.classList.remove("bg-green-500", "text-white");
    button.classList.add("bg-gray-300", "text-gray-700");
  });
  document.getElementById(tabId).classList.add("active");
  document
    .querySelector(`.tab-button[onclick="showTab('${tabId}')"]`)
    .classList.remove("bg-gray-300", "text-gray-700");
  document
    .querySelector(`.tab-button[onclick="showTab('${tabId}')"]`)
    .classList.add("bg-green-500", "text-white");
}

document.getElementById("file-input").addEventListener("change", uploadImage);

function uploadImage() {
  const form = document.getElementById("upload-form");
  const formData = new FormData(form);

  fetch("/upload", {
    method: "POST",
    body: formData,
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.error) {
        alert(data.error);
      } else {
        const imgUrl = `/images/${data.processed_image}`;
        document.getElementById("processed-image").src = imgUrl;
        document.getElementById("processed-image").style.display = "block";
        loadCatalog();
      }
    })
    .catch((error) => console.error("Error:", error));
}

function syncRotateInput() {
  const rotateRange = document.getElementById("rotate-range");
  const rotateInput = document.getElementById("rotate-input");
  rotateInput.value = rotateRange.value;
  updatePreview();
}

document.getElementById("rotate-input").addEventListener("input", () => {
  const rotateRange = document.getElementById("rotate-range");
  const rotateInput = document.getElementById("rotate-input");
  rotateRange.value = rotateInput.value;
  updatePreview();
});

function updatePreview() {
  const sharpness = document.getElementById("sharpness-input").value || 1.0;
  const brightness = document.getElementById("brightness-input").value || 1.0;
  const contrast = document.getElementById("contrast-input").value || 1.0;
  const color = document.getElementById("color-input").value || 1.0;
  const rotate = document.getElementById("rotate-input").value || 0;
  const grayscale = document.getElementById("grayscale-input").checked;
  const imgSrc = document.getElementById("processed-image").src;
  const filename = imgSrc.split("/").pop();

  fetch("/adjust", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      filename: filename,
      sharpness: parseFloat(sharpness),
      brightness: parseFloat(brightness),
      contrast: parseFloat(contrast),
      color: parseFloat(color),
      rotate: parseFloat(rotate),
      grayscale: grayscale,
    }),
  })
    .then((response) => response.blob())
    .then((blob) => {
      const imgUrl = URL.createObjectURL(blob);
      document.getElementById("processed-image").src = imgUrl;
    })
    .catch((error) => console.error("Error:", error));
}

function adjustImage() {
  updatePreview(); // Final adjustments should reflect in the preview
}

function loadCatalog() {
  fetch("/catalog")
    .then((response) => response.json())
    .then((data) => {
      const tbody = document.getElementById("catalog-tbody");
      tbody.innerHTML = "";
      data.forEach((item) => {
        const row = document.createElement("tr");
        row.innerHTML = `
                <td class="p-2 border">${item.sku}</td>
                <td class="p-2 border">${item.filename}</td>
                <td class="p-2 border">${item.sharpness}</td>
                <td class="p-2 border">${item.brightness}</td>
                <td class="p-2 border">${item.contrast}</td>
                <td class="p-2 border">${item.color}</td>
                <td class="p-2 border">${item.rotate}</td>
                <td class="p-2 border">${item.resize_width} x ${
          item.resize_height
        }</td>
                <td class="p-2 border">${
                  item.crop ? item.crop.join(", ") : ""
                }</td>
                <td class="p-2 border">${item.grayscale}</td>
                <td class="p-2 border">${new Date(
                  item.timestamp
                ).toLocaleString()}</td>
                <td class="p-2 border"><img src="/images/${
                  item.filename
                }" alt="Preview" class="w-16 h-16 rounded shadow"></td>
            `;
        tbody.appendChild(row);
      });
    })
    .catch((error) => console.error("Error:", error));
}

function filterTable() {
  const query = document.getElementById("search").value.toLowerCase();
  const rows = document.querySelectorAll("#catalog-tbody tr");
  rows.forEach((row) => {
    const sku = row.cells[0].textContent.toLowerCase();
    if (sku.includes(query)) {
      row.style.display = "";
    } else {
      row.style.display = "none";
    }
  });
}

window.onload = loadCatalog;
