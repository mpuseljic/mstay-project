<template>
  <div class="add-listing-page">
    <div class="overlay"></div>
    <div
      class="container d-flex justify-content-center align-items-center min-vh-100"
    >
      <div
        class="listing-form shadow-lg rounded-5 bg-white p-5 animate__animated animate__fadeInUp"
      >
        <h2 class="text-center mb-4 fw-bold text-dark">📌 Novi oglas</h2>
        <form @submit.prevent="submitListing" class="needs-validation">
          <div class="mb-4">
            <label class="form-label fw-semibold">📍 Naslov smještaja</label>
            <input
              v-model="title"
              type="text"
              class="form-control form-control-lg rounded-3"
              placeholder="Npr. Luksuzna vila uz more"
              required
            />
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">🌍 Lokacija</label>
            <input
              v-model="location"
              type="text"
              class="form-control form-control-lg rounded-3"
              placeholder="Npr. Split, Hrvatska"
              required
            />
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">📝 Opis</label>
            <textarea
              v-model="description"
              class="form-control form-control-lg rounded-3"
              rows="4"
              placeholder="Kratki opis smještaja"
              required
            ></textarea>
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold"
              >💰 Cijena po noćenju (ETH)</label
            >
            <input
              v-model="price"
              type="number"
              step="0.01"
              class="form-control form-control-lg rounded-3"
              placeholder="Npr. 0.05"
              required
            />
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold"
              >🖼️ Linkovi slika (max 10)</label
            >
            <div v-for="(url, index) in imageUrls" :key="index" class="mb-2">
              <input
                v-model="imageUrls[index]"
                type="text"
                class="form-control rounded-3"
                placeholder="https://example.com/slika.jpg"
              />
            </div>
            <button
              type="button"
              class="btn btn-outline-secondary btn-sm rounded-pill"
              @click="addImageUrl"
              :disabled="imageUrls.length >= 10"
            >
              ➕ Dodaj još sliku
            </button>
          </div>

          <div class="d-grid mt-4">
            <button
              type="submit"
              class="btn btn-dark btn-lg rounded-pill shadow"
            >
              🚀 Objavi oglas
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { ethers } from "ethers";
import mStayJson from "@/contracts/mStay.json";
import { useToast } from "vue-toastification";
const toast = useToast();

const title = ref("");
const location = ref("");
const description = ref("");
const price = ref("");
const imageUrls = ref([""]);

const addImageUrl = () => {
  if (imageUrls.value.length < 10) {
    imageUrls.value.push("");
  }
};

const onFilesChange = (e) => {
  const files = Array.from(e.target.files);
  const allowedFiles = files.slice(0, 10 - images.value.length);

  allowedFiles.forEach((file) => {
    images.value.push(file);
    imagePreviews.value.push(URL.createObjectURL(file));
  });

  e.target.value = null;
};

const removeImage = (index) => {
  images.value.splice(index, 1);
  imagePreviews.value.splice(index, 1);
};

const submitListing = async () => {
  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contractAddress = import.meta.env.VITE_CONTRACT_ADDRESS;

    const contract = new ethers.Contract(
      contractAddress,
      mStayJson.abi,
      signer
    );

    const tx = await contract.createListing(
      title.value,
      location.value,
      description.value,
      ethers.utils.parseEther(price.value.toString()),
      imageUrls.value.filter((url) => url.trim() !== "")
    );

    await tx.wait();
    toast.success("✅ Oglas uspješno kreiran!");

    title.value = "";
    location.value = "";
    description.value = "";
    price.value = "";
    imageUrls.value = [""];
  } catch (err) {
    console.error("Greška kod kreiranja oglasa:", err);
    toast.error("❌ Greška pri kreiranju oglasa.");
  }
};
</script>

<style scoped>
.add-listing-page {
  position: relative;
  background: linear-gradient(to right, #dbeafe, #e0f2fe);
  width: 100%;
  min-height: 100vh;
  overflow: hidden;
}

.overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(13, 13, 13, 0.3);
  z-index: 0;
}

.listing-form {
  position: relative;
  z-index: 1;
  max-width: 700px;
  width: 100%;
  border-radius: 1.5rem;
  background: #ffffff;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.08);
}

form {
  font-family: "Open Sans", sans-serif;
}

input,
textarea {
  background: #f9fafb;
  border: 1px solid #d1d5db;
  font-size: 1rem;
  transition: all 0.2s ease-in-out;
}

input:focus,
textarea:focus {
  border-color: #0d6efd;
  box-shadow: 0 0 0 0.15rem rgba(13, 110, 253, 0.25);
}

.btn-dark {
  background-color: #083637;
  border-color: #083637;
}
.btn-dark:hover {
  background-color: #0a4d4e;
  border-color: #0a4d4e;
}

.btn-outline-secondary:hover {
  background-color: #e2e8f0;
  color: #000;
}
</style>
