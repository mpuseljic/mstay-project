<template>
  <div class="add-listing-wizard bg-light py-5 px-3">
    <div class="container">
      <div
        class="wizard bg-white rounded-4 shadow p-4 mx-auto"
        style="max-width: 700px"
      >
        <div v-if="step === 1">
          <h3 class="fw-bold mb-4">📍 Gdje se nalazi vaš smještaj?</h3>
          <input
            v-model="address"
            class="form-control form-control-lg mb-3"
            placeholder="Unesite adresu (npr. Split, Hrvatska)"
          />
          <button class="btn btn-dark w-100 rounded-pill" @click="nextStep">
            Dalje
          </button>
        </div>

        <div v-else-if="step === 2">
          <h3 class="fw-bold mb-4">🛏️ Detalji o smještaju</h3>
          <div class="row g-3">
            <div class="col-6">
              <label class="form-label">Gostiju</label>
              <input
                type="number"
                min="1"
                v-model="guests"
                class="form-control"
              />
            </div>
            <div class="col-6">
              <label class="form-label">Spavaće sobe</label>
              <input
                type="number"
                min="0"
                v-model="bedrooms"
                class="form-control"
              />
            </div>
            <div class="col-6">
              <label class="form-label">Kreveti</label>
              <input
                type="number"
                min="0"
                v-model="beds"
                class="form-control"
              />
            </div>
            <div class="col-6">
              <label class="form-label">Kupaonice</label>
              <input
                type="number"
                step="0.5"
                v-model="bathrooms"
                class="form-control"
              />
            </div>
          </div>
          <div class="d-flex justify-content-between mt-4">
            <button class="btn btn-outline-secondary" @click="prevStep">
              Natrag
            </button>
            <button class="btn btn-dark" @click="nextStep">Dalje</button>
          </div>
        </div>
        <div v-else-if="step === 3">
          <h3 class="fw-bold mb-4">📸 Dodajte fotografije</h3>
          <div v-for="(url, index) in imageUrls" :key="index" class="mb-2">
            <input
              v-model="imageUrls[index]"
              type="text"
              class="form-control rounded-3 mb-2"
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
          <div class="d-flex justify-content-between mt-4">
            <button class="btn btn-outline-secondary" @click="prevStep">
              Natrag
            </button>
            <button class="btn btn-dark" @click="nextStep">Dalje</button>
          </div>
        </div>
        <div v-else-if="step === 4">
          <h3 class="fw-bold mb-4">✅ Koje sadržaje nudite?</h3>
          <div class="row">
            <div
              class="col-6 d-flex align-items-center mb-3"
              v-for="(val, key) in amenities"
              :key="key"
            >
              <input
                type="checkbox"
                v-model="amenities[key]"
                class="form-check-input me-2"
                :id="key"
              />
              <label
                class="form-check-label d-flex align-items-center"
                :for="key"
              >
                <i class="me-2" :class="iconClasses[key] || 'fas fa-circle'" />
                {{ amenitiesLabels[key] || key }}
              </label>
            </div>
          </div>
          <div class="d-flex justify-content-between mt-4">
            <button class="btn btn-outline-secondary" @click="prevStep">
              Natrag
            </button>
            <button class="btn btn-dark" @click="nextStep">Dalje</button>
          </div>
        </div>

        <div v-else-if="step === 5">
          <h3 class="fw-bold mb-4">📃 Završni podaci</h3>
          <input
            v-model="title"
            class="form-control form-control-lg mb-3"
            placeholder="Naslov oglasa (npr. Apartman uz more)"
          />
          <textarea
            v-model="description"
            class="form-control mb-3"
            rows="4"
            placeholder="Opis smještaja"
          ></textarea>
          <input
            v-model="price"
            type="number"
            class="form-control mb-3"
            placeholder="Cijena po noćenju (u ETH)"
          />
          <div class="d-flex justify-content-between">
            <button class="btn btn-outline-secondary" @click="prevStep">
              Natrag
            </button>
            <button class="btn btn-success" @click="submitListing">
              ✅ Objavi oglas
            </button>
          </div>
        </div>

        <div v-else-if="step === 6">
          <div class="text-center">
            <h3 class="fw-bold">🎉 Oglas uspješno objavljen!</h3>
            <p class="text-muted">
              Vaš oglas je sada aktivan i vidljiv korisnicima.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { ethers } from "ethers";
import mStayJson from "@/contracts/mStay.json";
import { useToast } from "vue-toastification";
const toast = useToast();

const step = ref(1);
const address = ref("");
const title = ref("");
const description = ref("");
const price = ref("");
const guests = ref(1);
const bedrooms = ref(1);
const beds = ref(1);
const bathrooms = ref(1);
const imageUrls = ref([""]);

const amenities = reactive({
  wifi: false,
  kitchen: false,
  airConditioning: false,
  balcony: false,
  hairDryer: false,
  luggageDropoff: false,
  refrigerator: false,
  carbonMonoxideDetector: false,
  smokeDetector: false,
  shampoo: false,
  hotWater: false,
  basicEquipment: false,
  hangers: false,
  iron: false,
  tv: false,
  heating: false,
  firstAidKit: false,
  cookingBasics: false,
  dishesAndCutlery: false,
  selfCheckIn: false,
  keySafe: false,
  outdoorCameras: false,
  washerDryer: false,
});

const amenitiesLabels = {
  wifi: "Wi-Fi",
  kitchen: "Kuhinja",
  airConditioning: "Klima-uređaj",
  balcony: "Otvoreno dvorište ili balkon",
  hairDryer: "Sušilo za kosu",
  luggageDropoff: "Ostavljanje prtljage",
  refrigerator: "Hladnjak",
  carbonMonoxideDetector: "Detektor ugljikovog monoksida",
  smokeDetector: "Detektor dima",
  shampoo: "Šampon",
  hotWater: "Topla voda",
  basicEquipment: "Osnovna oprema",
  hangers: "Vješalice",
  iron: "Glačalo",
  tv: "TV",
  heating: "Grijanje",
  firstAidKit: "Pribor za prvu pomoć",
  cookingBasics: "Osnovni pribor za kuhanje",
  dishesAndCutlery: "Posuđe i pribor za jelo",
  selfCheckIn: "Samostalni dolazak",
  keySafe: "Sef za ključeve",
  outdoorCameras: "Vanjske nadzorne kamere",
  washerDryer: "Perilica / Sušilica",
};

const iconClasses = {
  wifi: "fas fa-wifi",
  kitchen: "fas fa-kitchen-set",
  airConditioning: "fas fa-wind",
  balcony: "fas fa-tree",
  hairDryer: "fas fa-bath",
  luggageDropoff: "fas fa-suitcase",
  refrigerator: "fas fa-snowflake",
  carbonMonoxideDetector: "fas fa-burn",
  smokeDetector: "fas fa-smog",
  shampoo: "fas fa-pump-soap",
  hotWater: "fas fa-shower",
  basicEquipment: "fas fa-toolbox",
  hangers: "fas fa-tshirt",
  iron: "fas fa-steam",
  tv: "fas fa-tv",
  heating: "fas fa-fire",
  firstAidKit: "fas fa-briefcase-medical",
  cookingBasics: "fas fa-blender",
  dishesAndCutlery: "fas fa-utensils",
  selfCheckIn: "fas fa-door-open",
  keySafe: "fas fa-key",
  outdoorCameras: "fas fa-video",
  washerDryer: "fas fa-soap",
};

const nextStep = () => step.value++;
const prevStep = () => step.value--;

const addImageUrl = () => {
  if (imageUrls.value.length < 10) {
    imageUrls.value.push("");
  }
};

const getAmenitiesArray = () => {
  return Object.keys(amenities).map((key) => amenities[key]);
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
      address.value,
      description.value,
      ethers.utils.parseEther(price.value.toString()),
      imageUrls.value.filter((url) => url.trim() !== ""),
      getAmenitiesArray(),
      guests.value,
      bedrooms.value,
      beds.value,
      bathrooms.value
    );

    await tx.wait();
    toast.success("✅ Oglas uspješno kreiran!");
    step.value++;

    title.value = "";
    address.value = "";
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
.add-listing-wizard {
  background: linear-gradient(to right, #f0f4f8, #e2f0ff);
  min-height: 100vh;
}
input:focus,
textarea:focus,
select:focus {
  border-color: #0d6efd;
  box-shadow: 0 0 0 0.15rem rgba(13, 110, 253, 0.25);
}
</style>
