<template>
  <div class="listing-details container py-5">
    <div v-if="listing">
      <h1 class="fw-bold display-3 mb-2 text-dark">{{ listing.title }}</h1>
      <p class="text-secondary fs-5 mb-4">
        <i class="fas fa-map-marker-alt me-2"></i>{{ listing.location }}
      </p>

      <div class="row g-3 mb-5">
        <div class="col-lg-8">
          <img
            :src="listing.imageUrls[0]"
            class="img-fluid rounded-4 w-100 shadow"
            style="height: 400px; object-fit: cover"
            alt="Main image"
          />
        </div>
        <div class="col-lg-4 d-flex flex-column gap-3">
          <img
            v-for="(img, i) in listing.imageUrls.slice(1, 4)"
            :key="i"
            :src="img"
            class="img-fluid rounded-4 shadow-sm"
            style="height: 120px; object-fit: cover"
            alt="Gallery image"
          />
        </div>
      </div>
      <div class="row g-5">
        <div class="col-lg-8">
          <div class="mb-5">
            <h4 class="fw-bold mb-3 text-dark">
              <i class="fas fa-bed me-2"></i>Smještaj
            </h4>
            <ul class="list-unstyled text-muted fs-5 d-flex flex-wrap gap-3">
              <li class="d-flex align-items-center">
                <i class="fas fa-user-friends me-2"></i>
                {{ listing.guests }} gostiju
              </li>
              <li class="d-flex align-items-center">
                <i class="fas fa-door-open me-2"></i>
                {{ listing.bedrooms }} spavaćih soba
              </li>
              <li class="d-flex align-items-center">
                <i class="fas fa-bed me-2"></i> {{ listing.beds }} kreveta
              </li>
              <li class="d-flex align-items-center">
                <i class="fas fa-bath me-2"></i>
                {{ listing.bathrooms }} kupaonica
              </li>
            </ul>
          </div>

          <div class="mb-5">
            <h4 class="fw-bold mb-3 text-dark">
              <i class="fas fa-file-alt me-2"></i>Opis
            </h4>
            <p class="fs-5 text-body">{{ listing.description }}</p>
          </div>
          <div class="mb-4">
            <h4 class="fw-bold mb-3 text-dark">
              <i class="fas fa-concierge-bell me-2"></i>Sadržaji
            </h4>
            <div class="row">
              <div
                class="col-md-6 mb-3 d-flex align-items-center gap-3"
                v-for="(val, key) in filteredAmenities"
                :key="key"
              >
                <i class="fs-5" :class="iconClasses[key] || 'fas fa-circle'" />
                <span class="fs-6">{{ amenitiesLabels[key] || key }}</span>
              </div>
            </div>
          </div>
          <div class="mb-5">
            <h4 class="fw-bold mb-3 text-dark">
              <i class="fas fa-calendar-alt me-2"></i>Dostupnost
            </h4>
            <DatePicker
              v-model:range="dateRange"
              :disabled-dates="bookedDates"
              :min-date="new Date()"
              range
              inline
              locale="hr"
              :attributes="[
                {
                  key: 'booked',
                  dates: bookedDates,
                  dot: true,
                  order: 10,
                  class: 'dp__cell--booked',
                },
              ]"
            />
          </div>
          <div class="mb-5" v-if="listing.reviews?.length">
            <h4 class="fw-bold mb-4 text-dark">
              <i class="fas fa-star me-2 text-warning"></i>Recenzije gostiju
            </h4>
            <div class="row row-cols-1 row-cols-md-2 g-4">
              <div
                class="col"
                v-for="(review, index) in listing.reviews"
                :key="index"
              >
                <div class="border rounded-4 p-3 bg-white shadow-sm h-100">
                  <div class="d-flex align-items-center mb-2">
                    <div
                      class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3"
                      style="width: 40px; height: 40px"
                    >
                      <strong>{{
                        review.reviewer.slice(2, 4).toUpperCase()
                      }}</strong>
                    </div>
                    <div>
                      <div class="fw-semibold text-dark">Korisnik</div>
                      <div class="text-muted small">
                        <i class="fas fa-star text-warning me-1"></i
                        >{{ review.rating }} / 5
                      </div>
                    </div>
                  </div>
                  <p class="text-body mt-2">{{ review.comment }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-4">
          <div
            class="bg-white border p-4 rounded-4 shadow sticky-top"
            style="top: 100px"
          >
            <h3 class="fw-bold text-dark mb-3">
              {{ parseFloat(listing.price).toFixed(2) }} ETH
              <small class="fs-6 fw-normal text-muted">/ noćenje</small>
            </h3>

            <div class="border rounded-4 p-3 mb-3">
              <div class="d-flex justify-content-between">
                <div>
                  <strong>Dolazak</strong>
                  <input
                    type="date"
                    class="form-control form-control-sm"
                    v-model="checkIn"
                  />
                </div>
                <div>
                  <strong>Odlazak</strong>
                  <input
                    type="date"
                    class="form-control form-control-sm"
                    v-model="checkOut"
                  />
                </div>
              </div>
              <hr />
              <div>
                <strong>Gosti</strong>
                <input
                  type="number"
                  class="form-control form-control-sm"
                  v-model="guestsCount"
                  min="1"
                />
              </div>
            </div>

            <button
              class="btn btn-danger w-100 py-3 rounded-pill fs-5 shadow-sm"
              :disabled="isLoading"
              @click="reserve"
            >
              <span v-if="isLoading">
                <i class="fas fa-spinner fa-spin me-2"></i> Rezerviram...
              </span>
              <span v-else> Rezerviraj </span>
            </button>

            <p class="text-center text-muted small mt-3 mb-2">
              Još vam nećemo ništa naplatiti
            </p>

            <div class="d-flex justify-content-between border-bottom pb-2">
              <span class="text-muted">
                {{ parseFloat(listing.price).toFixed(2) }} ETH x
                {{ numberOfNights }} noćenja
              </span>
              <span class="text-dark">{{ subtotal }} ETH</span>
            </div>
            <div class="d-flex justify-content-between border-bottom py-2">
              <span class="text-muted">Naknada za usluge</span>
              <span class="text-dark">{{ serviceFee }} ETH</span>
            </div>
            <div class="d-flex justify-content-between pt-2">
              <strong>Ukupno</strong>
              <strong>{{ total }} ETH</strong>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, computed } from "vue";
import { useRoute } from "vue-router";
import { ethers } from "ethers";
import mStayJson from "@/contracts/mStay.json";
import { useToast } from "vue-toastification";
import DatePicker from "@vuepic/vue-datepicker";
import "@vuepic/vue-datepicker/dist/main.css";

const toast = useToast();
const route = useRoute();
const listing = ref(null);
const checkIn = ref("");
const checkOut = ref("");
const guestsCount = ref(1);
const isLoading = ref(false);
const dateRange = ref({ start: null, end: null });
const bookedDates = ref([]);

const numberOfNights = computed(() => {
  if (!checkIn.value || !checkOut.value) return 0;
  const start = new Date(checkIn.value);
  const end = new Date(checkOut.value);
  const diff = (end - start) / (1000 * 60 * 60 * 24);
  return diff > 0 ? diff : 0;
});

const subtotal = computed(() => {
  return (parseFloat(listing.value?.price || 0) * numberOfNights.value).toFixed(
    2
  );
});

const serviceFee = computed(() => {
  return (subtotal.value * 0.18).toFixed(2);
});

const total = computed(() => {
  return (parseFloat(subtotal.value) + parseFloat(serviceFee.value)).toFixed(2);
});

const reserve = async () => {
  if (!checkIn.value || !checkOut.value) {
    toast.warning("Molimo odaberite datume dolaska i odlaska.");
    return;
  }

  const inDate = Math.floor(new Date(checkIn.value).getTime() / 1000);
  const outDate = Math.floor(new Date(checkOut.value).getTime() / 1000);
  const nights = (outDate - inDate) / 86400;

  if (nights < 1) {
    toast.error("Datum odlaska mora biti nakon datuma dolaska.");
    return;
  }

  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(
      import.meta.env.VITE_CONTRACT_ADDRESS,
      mStayJson.abi,
      signer
    );

    const priceInEth = ethers.utils.parseEther(listing.value.price.toString());
    const total = priceInEth.mul(nights);

    const tx = await contract.makeReservation(
      listing.value.id,
      inDate,
      outDate,
      {
        value: total,
      }
    );

    await tx.wait();
    toast.success("✅ Rezervacija uspješna!");
  } catch (err) {
    console.error(err);
    toast.error("❌ Greška kod rezervacije.");
  }
};

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

const filteredAmenities = computed(() => {
  if (!listing.value?.amenities) return {};
  return Object.fromEntries(
    Object.entries(listing.value.amenities).filter(([_, v]) => v)
  );
});

onMounted(async () => {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const contract = new ethers.Contract(
    import.meta.env.VITE_CONTRACT_ADDRESS,
    mStayJson.abi,
    provider
  );

  const allListings = await contract.getAllListings();
  const found = allListings.find(
    (l) => Number(l[0]) === Number(route.params.id)
  );
  if (!found) return;

  const amenitiesKeys = Object.keys(amenitiesLabels);
  const amenitiesData = found[7];
  const amenitiesObject = {};
  amenitiesKeys.forEach((key, index) => {
    amenitiesObject[key] = amenitiesData[index];
  });

  listing.value = {
    id: Number(found[0]),
    owner: found[1],
    title: found[2],
    location: found[3],
    description: found[4],
    price: ethers.utils.formatEther(found[5]),
    imageUrls: found[6],
    guests: Number(found[8]),
    bedrooms: Number(found[9]),
    beds: Number(found[10]),
    bathrooms: Number(found[11]),
    amenities: amenitiesObject,
    reviews: [],
  };

  const reviews = await contract.getReviewsForListing(listing.value.id);
  listing.value.reviews = reviews.map((r) => ({
    reviewer: r.reviewer,
    rating: Number(r.rating),
    comment: r.comment,
  }));
  const allReservations = await contract.getAllReservations();
  const relevant = allReservations.filter(
    (r) => Number(r.listingId) === listing.value.id
  );
  let dates = [];
  relevant.forEach((res) => {
    const start = new Date(Number(res.checkInDate) * 1000);
    const end = new Date(Number(res.checkOutDate) * 1000);
    for (let d = new Date(start); d < end; d.setDate(d.getDate() + 1)) {
      dates.push(new Date(d));
    }
  });
  bookedDates.value = dates;
});
</script>

<style scoped>
img {
  object-fit: cover;
}
.text-decoration-line-through {
  text-decoration: line-through;
}
.dp__cell--booked,
.dp__cell--disabled,
.dp__cell--unavailable {
  color: #ccc !important;
  background-color: transparent !important;
  opacity: 1 !important;
  pointer-events: none !important;
  text-decoration: line-through !important;
  font-weight: normal !important;
  position: relative;
  font-size: 14px;
}

.dp__cell--booked::before,
.dp__cell--disabled::before,
.dp__cell--unavailable::before {
  content: "";
  position: absolute;
  top: 50%;
  left: 15%;
  width: 70%;
  height: 1px;
  background-color: #888;
  transform: translateY(-50%) rotate(-20deg);
  z-index: 2;
}
.bg-primary {
  background-color: #083637 !important;
}
.rounded-circle {
  border-radius: 50% !important;
}
</style>
