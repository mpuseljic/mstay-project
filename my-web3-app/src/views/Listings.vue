<template>
  <div class="listings-page">
    <section class="py-5">
      <div class="container d-flex justify-content-center">
        <div class="custom-search-bar">
          <div
            class="search-item position-relative"
            ref="locationDropdownWrapper"
          >
            <label>Kamo</label>
            <input
              type="text"
              v-model="searchLocation"
              placeholder="Pretražite odredišta"
              @click="toggleLocationDropdown"
              style="pointer-events: auto"
            />
            <div
              v-if="showLocationDropdown"
              class="location-dropdown"
              ref="locationDropdown"
              @click.stop
            >
              <h6 class="dropdown-heading">Prijedlozi za putovanja</h6>

              <div
                v-for="(dest, index) in filteredDestinations"
                :key="index"
                class="location-item"
                @click="selectDestination(dest)"
              >
                <div
                  class="location-icon"
                  :style="{ backgroundColor: dest.bg || '#f0f0f0' }"
                >
                  <i :class="dest.icon"></i>
                </div>
                <div class="location-text">
                  <strong>{{ dest.name }}</strong>
                  <div class="text-muted small">{{ dest.desc }}</div>
                </div>
              </div>
            </div>
          </div>

          <div class="search-item" ref="checkInRef">
            <label>Dolazak</label>
            <input type="date" v-model="checkIn" />
          </div>

          <div class="search-item" ref="checkOutRef">
            <label>Odlazak</label>
            <input type="date" v-model="checkOut" />
          </div>

          <div
            class="search-item position-relative"
            ref="guestsDropdownWrapper"
            @click="showGuestsDropdown = !showGuestsDropdown"
          >
            <label>Tko</label>
            <input type="text" :value="totalGuests" readonly />

            <div v-if="showGuestsDropdown" class="guests-dropdown" @click.stop>
              <div
                v-for="(label, key) in guestLabels"
                :key="key"
                class="guest-row"
              >
                <div class="guest-text">
                  <div class="guest-label">{{ label }}</div>
                  <div class="guest-desc">{{ getGuestDesc(key) }}</div>
                </div>
                <div class="guest-controls">
                  <button
                    class="round-btn"
                    :disabled="guests[key] === 0"
                    @click.stop="decrement(key)"
                  >
                    −
                  </button>
                  <span class="guest-count">{{ guests[key] }}</span>
                  <button class="round-btn" @click.stop="increment(key)">
                    +
                  </button>
                </div>
              </div>

              <div class="guest-helper-link mt-3">
                <strong>Kućni ljubimci</strong><br />
                <a href="#" class="text-decoration-underline small">
                  S vama dolazi životinja pomagač?
                </a>
              </div>
            </div>
          </div>

          <button class="search-button" @click="filterListings">
            <i class="fas fa-search"></i>
          </button>
        </div>
      </div>
    </section>

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
            @click="goToDetails(listing.id)"
            style="cursor: pointer"
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

            <div
              v-if="listingReviews[listing.id]?.length"
              class="px-4 pb-3 pt-2 border-top bg-light-subtle"
            >
              <h6 class="fw-semibold mb-2 text-dark">🌟 Recenzije</h6>
              <div
                v-for="(review, index) in listingReviews[listing.id]"
                :key="index"
                class="mb-3 pb-2 border-bottom"
              >
                <div class="d-flex align-items-center gap-2 mb-1">
                  <span
                    v-for="i in 5"
                    :key="i"
                    class="fs-6"
                    :class="i <= review.rating ? 'text-warning' : 'text-muted'"
                  >
                    <i class="fas fa-star"></i>
                  </span>
                </div>
                <p class="mb-0 text-muted small fst-italic">
                  "{{ review.comment }}"
                </p>
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
import { ref, onMounted, computed, onBeforeUnmount } from "vue";
import { ethers } from "ethers";
import mStayJson from "@/contracts/mStay.json";
import { useToast } from "vue-toastification";
import { useRouter } from "vue-router";

const listings = ref([]);
const searchLocation = ref("");
const checkIn = ref("");
const checkOut = ref("");
const filteredListings = ref([]);
const toast = useToast();
const userAddress = ref("");
const reservations = ref([]);
const sortOption = ref("");
const minPrice = ref(null);
const maxPrice = ref(null);
const listingReviews = ref({});
const activeField = ref(null);
const locationDropdownWrapper = ref(null);
const locationDropdown = ref(null);
const showLocationDropdown = ref(false);
const showGuestsDropdown = ref(false);
const checkInRef = ref(null);
const checkOutRef = ref(null);
const guestsDropdownWrapper = ref(null);
const router = useRouter();

const goToDetails = (id) => {
  router.push(`/listing/${id}`);
};

const loadReviews = async () => {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const contract = new ethers.Contract(
    import.meta.env.VITE_CONTRACT_ADDRESS,
    mStayJson.abi,
    provider
  );

  const reviewsByListing = {};
  for (const listing of listings.value) {
    try {
      const reviews = await contract.getReviewsForListing(listing.id);

      reviewsByListing[listing.id] = reviews.map((r) => ({
        reviewer: r.reviewer,
        rating: Number(r.rating),
        comment: r.comment,
      }));
    } catch (err) {
      console.warn(`❌ Greška kod recenzija za oglas ${listing.id}`, err);
    }
  }

  listingReviews.value = reviewsByListing;
};

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

    listings.value = allListings
      .map((l) => ({
        id: Number(l[0]),
        owner: l[1],
        title: l[2],
        location: l[3],
        description: l[4],
        pricePerNight: ethers.utils.formatEther(l[5]),
        image: l[6]?.[0] || "/hero.jpg",
      }))
      .filter(
        (l) =>
          l.owner !== "0x0000000000000000000000000000000000000000" && l.title
      ); // filtriraj obrisane

    filteredListings.value = [...listings.value];
  } catch (err) {
    console.error("Greška prilikom dohvaćanja oglasa:", err);
  }
};

const filterListings = () => {
  let result = listings.value.filter((listing) => {
    const locationMatch = listing.location
      .toLowerCase()
      .includes(searchLocation.value.toLowerCase());

    const priceMatch =
      (!minPrice.value ||
        parseFloat(listing.pricePerNight) >= minPrice.value) &&
      (!maxPrice.value || parseFloat(listing.pricePerNight) <= maxPrice.value);

    const inDate = checkIn.value
      ? new Date(checkIn.value).getTime() / 1000
      : null;
    const outDate = checkOut.value
      ? new Date(checkOut.value).getTime() / 1000
      : null;

    const available = !reservations.value.some(
      (r) =>
        r.listingId === listing.id &&
        inDate &&
        outDate &&
        Math.max(r.checkIn, inDate) < Math.min(r.checkOut, outDate)
    );

    return locationMatch && priceMatch && (!inDate || !outDate || available);
  });

  if (sortOption.value === "asc") {
    result.sort(
      (a, b) => parseFloat(a.pricePerNight) - parseFloat(b.pricePerNight)
    );
  } else if (sortOption.value === "desc") {
    result.sort(
      (a, b) => parseFloat(b.pricePerNight) - parseFloat(a.pricePerNight)
    );
  }

  filteredListings.value = result;
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

const popularDestinations = [
  {
    name: "U mojoj blizini",
    desc: "Potražite sadržaje u svojoj blizini",
    icon: "fas fa-location-arrow",
    bg: "#e7f0fb",
  },
  {
    name: "Budimpešta, Mađarska",
    desc: "Zbog znamenitosti kao što je Ribarska tvrđava",
    icon: "fas fa-landmark",
    bg: "#e6f4ec",
  },
  {
    name: "Split, Hrvatska",
    desc: "Popularna destinacija na samoj obali",
    icon: "fas fa-water",
    bg: "#e7f0fb",
  },
  {
    name: "Osijek, Hrvatska",
    desc: "Za putovanje u inozemstvo",
    icon: "fas fa-tree",
    bg: "#eaf6e9",
  },
  {
    name: "Rijeka, Hrvatska",
    desc: "Zbog znamenitosti kao što je Trsatska gradina",
    icon: "fas fa-ship",
    bg: "#fdeef3",
  },
  {
    name: "Beograd, Srbija",
    desc: "Poznato po noćnoj zabavi",
    icon: "fas fa-glass-cheers",
    bg: "#fdecea",
  },
  {
    name: "Zadar, Hrvatska",
    desc: "Popularna destinacija na samoj obali",
    icon: "fas fa-water",
    bg: "#fdecea",
  },
  {
    name: "Pula, Hrvatska",
    desc: "Zbog znamenitosti kao što je Slavoluk Sergijevaca",
    icon: "fas fa-tree",
    bg: "#fdeef3",
  },
  {
    name: "Ljubljana, Slovenija",
    desc: "Zbog zadivljujuće arhitekture",
    icon: "fas fa-tree",
    bg: "#fdeef3",
  },
  {
    name: "Pariz, Francuska",
    desc: "Zbog vrhunske gastronomske ponude",
    icon: "fas fa-wine-glass-alt",
    bg: "#e7f0fb",
  },
  {
    name: "Sarajevo, Bosna i Hercegovina",
    desc: "Za putovanje u inozemstvo",
    icon: "fas fa-city",
    bg: "#f8f1ed",
  },
  {
    name: "Barcelona, Španjolska",
    desc: "Zbog znamenitosti kao što je Crkva Svete Obitelji",
    icon: "fas fa-landmark",
    bg: "#f8f0e9",
  },
  {
    name: "Dubrovnik, Hrvatska",
    desc: "Zbog zadivljujuće arhitekture",
    icon: "fas fa-archway",
    bg: "#fdecec",
  },
  {
    name: "London, Ujedinjeno Kraljevstvo",
    desc: "Poznato po noćnoj zabavi",
    icon: "fas fa-city",
    bg: "#ececec",
  },
  {
    name: "Beč, Austrija",
    desc: "Zbog vrhunske gastronomske ponude",
    icon: "fas fa-utensils",
    bg: "#ffe0f0",
  },
  {
    name: "Šibenik, Hrvatska",
    desc: "Za ljubitelje prirode",
    icon: "fas fa-water",
    bg: "#dff9fb",
  },
  {
    name: "Prag, Češka",
    desc: "Zbog znamenitosti kao što je Praški dvorac",
    icon: "fas fa-chess-rook",
    bg: "#fdeef3",
  },
  {
    name: "Korčula, Hrvatska",
    desc: "Za putovanje u inozemstvo",
    icon: "fas fa-city",
    bg: "#e7f0fb",
  },
  {
    name: "Mostar, Bosna i Hercegovina",
    desc: "Skriveni dragulj",
    icon: "fas fa-tree",
    bg: "#f4f1ee",
  },
  {
    name: "Lisabon, Portugal",
    desc: "Zbog znamenitosti kao što je Trg trgovine",
    icon: "fas fa-landmark",
    bg: "#ede7e3",
  },
  {
    name: "Novi Sad, Srbija",
    desc: "Za putovanje u inozemstvo",
    icon: "fas fa-city",
    bg: "#fdeef3",
  },
];

const selectDestination = (destination) => {
  searchLocation.value = destination.name;
  showLocationDropdown.value = false;
};
const guests = ref({
  adults: 2,
  children: 0,
  infants: 0,
  pets: 0,
});

const guestLabels = {
  adults: "Odrasli",
  children: "Djeca",
  infants: "Bebe",
  pets: "Kućni ljubimci",
};

const getGuestDesc = (key) => {
  switch (key) {
    case "adults":
      return "Najmanje 13 god.";
    case "children":
      return "2 – 12 god.";
    case "infants":
      return "Do 2 god.";
    case "pets":
      return "Primaju li ljubimce?";
    default:
      return "";
  }
};

const filteredDestinations = computed(() => {
  if (!searchLocation.value.trim()) return popularDestinations;

  return popularDestinations.filter((dest) =>
    dest.name.toLowerCase().includes(searchLocation.value.toLowerCase())
  );
});

const totalGuests = computed(() => {
  const a = guests.value.adults;
  const c = guests.value.children;
  const i = guests.value.infants;
  const p = guests.value.pets;

  const parts = [];
  if (a + c > 0) parts.push(`${a + c} gost${a + c === 1 ? "" : "i"}`);
  if (i > 0) parts.push(`${i} beba${i === 1 ? "" : "e"}`);
  if (p > 0) parts.push(`${p} ljubimac${p === 1 ? "" : "a"}`);

  return parts.length ? parts.join(", ") : "Dodaj goste";
});

const increment = (key) => {
  guests.value[key]++;
};
const decrement = (key) => {
  if (guests.value[key] > 0) guests.value[key]--;
};

const handleClickOutside = (event) => {
  const locationEl = locationDropdownWrapper.value;
  const guestsEl = guestsDropdownWrapper.value;

  if (
    showLocationDropdown.value &&
    locationEl &&
    !locationEl.contains(event.target)
  ) {
    showLocationDropdown.value = false;
  }

  if (
    showGuestsDropdown.value &&
    guestsEl &&
    !guestsEl.contains(event.target)
  ) {
    showGuestsDropdown.value = false;
  }
};

const toggleLocationDropdown = () => {
  showLocationDropdown.value = !showLocationDropdown.value;
  showGuestsDropdown.value = false;
};

onMounted(async () => {
  await loadListings();
  await loadReservations();
  await loadReviews();
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  userAddress.value = await signer.getAddress();
  setTimeout(() => {
    document.addEventListener("click", handleClickOutside);
  }, 0);
});

onBeforeUnmount(() => {
  document.removeEventListener("click", handleClickOutside);
});
</script>

<style scoped>
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

.form-label {
  margin-top: 10px;
}

.custom-search-bar {
  display: flex;
  align-items: center;
  background-color: white;
  border-radius: 999px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 1100px;
  border: 1px solid #ddd;
  position: relative;
  z-index: 10;
}

.search-item {
  min-width: 250px;
  position: relative;
}
.search-item {
  flex: 1;
  padding: 16px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  border-right: 1px solid #eee;
}

.search-item:last-of-type {
  border-right: none;
}

.search-item label {
  font-size: 12px;
  font-weight: 600;
  color: #717171;
  margin-bottom: 4px;
}

.search-item input {
  border: none;
  outline: none;
  font-size: 14px;
  color: #222;
  background-color: transparent;
  cursor: pointer;
}

.search-item input::placeholder {
  color: #aaa;
}

.active-capsule {
  background-color: #fff;
  border-radius: 999px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.12);
  padding: 10px 16px !important;
  margin: -10px 0; /* vizualno poravna s ostalima */
  z-index: 10;
  border: 1px solid #ddd;
}

.search-item:hover {
  background-color: #f9f9f9;
  border-radius: 30px;
  transition: background-color 0.2s ease;
}

.search-button {
  background-color: #ff385c;
  color: white;
  border-radius: 50%;
  padding: 14px;
  border: none;
  width: 48px;
  height: 48px;
  margin: 0 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s ease;
}

.search-button:hover {
  background-color: #e03150;
}

.location-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  width: 480px;
  margin-top: 8px;
  background-color: #fff;
  border-radius: 20px;
  box-shadow: 0 6px 25px rgba(0, 0, 0, 0.12);
  padding: 24px;
  z-index: 999;

  max-height: 400px;
  overflow-y: auto;
}

.dropdown-heading {
  font-weight: 600;
  font-size: 16px;
  margin-bottom: 16px;
}

.location-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px;
  border-radius: 12px;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.location-item:hover {
  background-color: #f7f7f7;
}

.location-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: #333;
}

.location-text {
  display: flex;
  flex-direction: column;
}

.destination-item {
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.destination-item:hover {
  background-color: #f8f9fa;
}

.guests-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 8px;
  background-color: #fff;
  border-radius: 20px;
  box-shadow: 0 6px 25px rgba(0, 0, 0, 0.12);
  padding: 24px;
  z-index: 999;
  width: 340px;
}

.guest-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #eee;
}

.guest-text {
  display: flex;
  flex-direction: column;
}

.guest-label {
  font-weight: 600;
  font-size: 16px;
}

.guest-desc {
  font-size: 14px;
  color: #717171;
}

.guest-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.round-btn {
  background-color: transparent;
  border: 1px solid #ccc;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  font-size: 20px;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #333;
  transition: background 0.2s ease;
}

.round-btn:hover {
  background-color: #f0f0f0;
}

.round-btn:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.guest-count {
  font-size: 16px;
  width: 18px;
  text-align: center;
}

.guest-helper-link {
  margin-top: 16px;
}

.guest-helper-link a {
  color: #222;
  font-size: 14px;
}

.min-width-2 {
  width: 2rem;
}

.search-item {
  padding-right: 1rem;
  border-right: 1px solid #e0e0e0;
}

@media (max-width: 768px) {
  .custom-search-bar {
    flex-direction: column;
    border-radius: 20px;
  }

  .search-item {
    width: 100%;
    border-right: none;
    border-bottom: 1px solid #eee;
  }

  .search-item:last-of-type {
    border-bottom: none;
  }

  .search-button {
    width: 100%;
    border-radius: 0 0 20px 20px;
  }
}
</style>
