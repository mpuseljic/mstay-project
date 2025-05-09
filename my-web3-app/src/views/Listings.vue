<template>
  <div class="listings-page">
    <!-- Search Section -->
    <section class="search-section py-5">
      <div class="container">
        <div class="search-box shadow p-4 rounded-4 bg-white">
          <div class="row g-3 align-items-end">
            <div class="col-md-4">
              <label class="form-label fw-semibold">Lokacija</label>
              <input
                v-model="searchLocation"
                type="text"
                class="form-control form-control-lg rounded-3"
                placeholder="Npr. Zagreb"
              />
            </div>
            <div class="col-md-3">
              <label class="form-label fw-semibold">Dolazak</label>
              <input
                v-model="checkIn"
                type="date"
                class="form-control form-control-lg rounded-3"
              />
            </div>
            <div class="col-md-3">
              <label class="form-label fw-semibold">Odlazak</label>
              <input
                v-model="checkOut"
                type="date"
                class="form-control form-control-lg rounded-3"
              />
            </div>
            <div class="col-md-2">
              <button
                class="btn btn-dark btn-lg w-100 rounded-pill"
                @click="filterListings"
              >
                🔍 Traži
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Listings Section -->
    <section class="container my-5">
      <h2
        class="text-center mb-5 fw-bold text-primary animate__animated animate__fadeIn"
      >
        🏡 Dostupni smještaji
      </h2>

      <div v-if="filteredListings.length" class="row g-4">
        <div
          v-for="listing in filteredListings"
          :key="listing.id"
          class="col-md-4"
        >
          <div
            class="card listing-card h-100 border-0 rounded-4 shadow-sm animate__animated animate__fadeInUp"
          >
            <img
              :src="listing.image"
              class="card-img-top rounded-top-4"
              alt="slika smještaja"
              style="height: 250px; object-fit: cover"
            />
            <div class="card-body d-flex flex-column">
              <h5 class="card-title fw-bold">{{ listing.title }}</h5>
              <p class="card-text text-muted mb-1">
                <i class="bi bi-geo-alt"></i> {{ listing.location }}
              </p>
              <p class="card-text small">{{ listing.description }}</p>
              <p class="card-text text-primary fw-semibold mb-3">
                {{ listing.pricePerNight }} ETH / noćenje
              </p>
              <div class="mt-auto">
                <button
                  class="btn btn-outline-dark w-100 rounded-pill"
                  :disabled="isListingReserved(listing.id)"
                  @click="reserve(listing)"
                >
                  {{
                    isListingReserved(listing.id)
                      ? "Zauzeto u odabranom periodu"
                      : "Rezerviraj"
                  }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="text-center text-muted my-5">
        <h4>😕 Nema dostupnih oglasa za zadane uvjete pretrage.</h4>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { ethers } from "ethers";
import mStayJson from "@/contracts/mStay.json";
import { useToast } from "vue-toastification";

const listings = ref([]);
const searchLocation = ref("");
const checkIn = ref("");
const checkOut = ref("");
const filteredListings = ref([]);
const toast = useToast();
const userAddress = ref("");
const reservations = ref([]);

const loadListings = async () => {
  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contractAddress = import.meta.env.VITE_CONTRACT_ADDRESS;

    const contract = new ethers.Contract(
      contractAddress,
      mStayJson.abi,
      provider
    );

    const allListings = await contract.getAllListings();
    const allReservations = await contract.getAllReservations();
    console.log("🧾 Sve iz smart contracta:", allListings);

    listings.value = allListings.map((l) => ({
      id: Number(l[0]),
      owner: l[1],
      title: l[2],
      location: l[3],
      description: l[4],
      pricePerNight: ethers.utils.formatEther(l[5]),
      image: l[6]?.[0] || "/hero.jpg",
    }));

    filteredListings.value = [...listings.value];
  } catch (err) {
    console.error("Greška prilikom dohvaćanja oglasa:", err);
  }
};

const filterListings = () => {
  filteredListings.value = listings.value.filter((listing) => {
    const locationMatch = listing.location
      .toLowerCase()
      .includes(searchLocation.value.toLowerCase());
    return locationMatch;
  });
};

const isListingReserved = (listingId) => {
  if (!checkIn.value || !checkOut.value) return false;
  const inDate = new Date(checkIn.value).getTime() / 1000;
  const outDate = new Date(checkOut.value).getTime() / 1000;

  return reservations.value.some(
    (r) =>
      r.listingId === listingId &&
      Math.max(r.checkIn, inDate) < Math.min(r.checkOut, outDate)
  );
};

const loadReservations = async () => {
  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contractAddress = import.meta.env.VITE_CONTRACT_ADDRESS;

    const contract = new ethers.Contract(
      contractAddress,
      mStayJson.abi,
      provider
    );

    const allReservations = await contract.getAllReservations();
    reservations.value = allReservations.map((r) => ({
      id: Number(r.id),
      guest: r.guest,
      listingId: Number(r.listingId),
      checkIn: Number(r.checkInDate),
      checkOut: Number(r.checkOutDate),
    }));
  } catch (err) {
    console.error("Greška prilikom dohvaćanja rezervacija:", err);
  }
};

const reserve = async (listing) => {
  if (listing.owner.toLowerCase() === userAddress.value.toLowerCase()) {
    toast.error("Ne možete rezervirati vlastiti oglas!");
    return;
  }

  if (!checkIn.value || !checkOut.value) {
    toast.warning("Molimo odaberite datume dolaska i odlaska.");
    return;
  }

  const inDate = Math.floor(new Date(checkIn.value).getTime() / 1000);
  const outDate = Math.floor(new Date(checkOut.value).getTime() / 1000);
  const nights = (outDate - inDate) / 86400;

  if (nights < 1) {
    toast.error("Datum odlaska mora biti nakon dolaska.");
    return;
  }

  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contractAddress = import.meta.env.VITE_CONTRACT_ADDRESS;

    const contract = new ethers.Contract(
      contractAddress,
      mStayJson.abi,
      signer
    );

    const priceInEth = ethers.utils.parseEther(
      listing.pricePerNight.toString()
    );
    const total = priceInEth.mul(nights);

    const tx = await contract.makeReservation(listing.id, inDate, outDate, {
      value: total,
    });

    await tx.wait();
    toast.success("✅ Rezervacija uspješna!");
  } catch (err) {
    console.error(err);
    toast.error("❌ Greška kod rezervacije.");
  }
};

onMounted(async () => {
  await loadListings();
  await loadReservations();
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  userAddress.value = await signer.getAddress();
});
</script>

<style scoped>
.search-section {
  background: linear-gradient(to right, #dbeafe, #e0f2fe);
}

.search-box {
  background: #ffffff;
  border: 1px solid #e0e0e0;
}

.card-title {
  font-family: "Poppins", sans-serif;
  font-size: 1.25rem;
}

.card-text {
  font-family: "Open Sans", sans-serif;
}

.text-primary {
  color: #0d6efd !important;
}

.listing-card {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.listing-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.07);
}

.btn-outline-dark {
  border-color: #0d6efd;
  color: #0d6efd;
}
.btn-outline-dark:hover {
  background-color: #0d6efd;
  color: white;
}

button:disabled {
  background-color: #ccc !important;
  color: #666 !important;
  border-color: #ccc !important;
  cursor: not-allowed;
  pointer-events: none;
}
</style>
