<template>
  <div class="add-listing-page">
    <div class="overlay"></div>
    <div
      class="container d-flex justify-content-center align-items-center min-vh-100"
    >
      <div
        class="card p-5 shadow-lg border-0 rounded-4 glass-effect animate__animated animate__fadeInUp"
      >
        <h2 class="text-center mb-5 fw-bold text-primary">
          Dodaj Novi Smještaj
        </h2>
        <form @submit.prevent="submitListing">
          <div class="mb-4">
            <label class="form-label fw-semibold">Naslov smještaja</label>
            <input
              v-model="title"
              type="text"
              class="form-control form-control-lg rounded-3"
              placeholder="Npr. Luksuzna vila uz more"
              required
            />
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">Lokacija</label>
            <input
              v-model="location"
              type="text"
              class="form-control form-control-lg rounded-3"
              placeholder="Npr. Split, Hrvatska"
              required
            />
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">Opis</label>
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
              >Cijena po noćenju (ETH)</label
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
              >Dodaj slike smještaja (max 10)</label
            >
            <div v-for="(url, index) in imageUrls" :key="index" class="mb-3">
              <input
                v-model="imageUrls[index]"
                type="text"
                class="form-control"
                placeholder="https://..."
              />
            </div>
            <button
              type="button"
              class="btn btn-outline-primary btn-sm rounded-pill"
              @click="addImageUrl"
              :disabled="imageUrls.length >= 10"
            >
              Dodaj sliku
            </button>
          </div>
          <div class="d-grid">
            <button
              type="submit"
              class="btn btn-primary btn-lg rounded-pill shadow"
            >
              Objavi Oglas
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
    alert("Oglas uspješno kreiran!");

    title.value = "";
    location.value = "";
    description.value = "";
    price.value = "";
    imageUrls.value = [""];
  } catch (err) {
    console.error("Greška kod kreiranja oglasa:", err);
    alert("Greška pri kreiranju oglasa");
  }
};
</script>

<style scoped>
.add-listing-page {
  position: relative;
  background: url("/hero.jpg") center center / cover no-repeat;
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
  background: rgba(0, 0, 0, 0.5);
  z-index: 0;
}

.glass-effect {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  z-index: 1;
}

.card {
  width: 100%;
  max-width: 600px;
}

h2 {
  font-family: "Poppins", sans-serif;
}

form {
  font-family: "Open Sans", sans-serif;
}

input,
textarea {
  background: rgba(255, 255, 255, 0.8);
}

.text-primary {
  --bs-text-opacity: 1;
  color: rgb(8 54 55) !important;
}
</style>
