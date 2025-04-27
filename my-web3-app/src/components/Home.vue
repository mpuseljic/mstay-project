<template>
  <div>
    <!-- Navbar -->
    <nav
      class="navbar navbar-expand-lg navbar-light bg-white shadow-sm fixed-top"
    >
      <div class="container">
        <a class="navbar-brand fw-bold fs-3 text-primary" href="#">mStay</a>
        <button
          class="btn btn-primary rounded-pill fw-semibold"
          @click="connectWallet"
        >
          {{ isConnected ? "Wallet Connected" : "Connect Wallet" }}
        </button>
      </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section d-flex align-items-center text-white">
      <div class="hero-overlay"></div>
      <div class="hero-content text-center">
        <h1
          class="display-3 fw-bold mb-4 animate__animated animate__fadeInDown"
        >
          Tvoje savršeno mjesto za odmor
        </h1>
        <p class="lead mb-5 animate__animated animate__fadeInUp">
          Rezerviraj ili oglašavaj smještaj sigurno i brzo, bez posrednika.
        </p>
        <div>
          <button
            class="btn btn-primary btn-lg me-3 shadow animate__animated animate__fadeInUp rounded-pill"
            data-bs-toggle="modal"
            data-bs-target="#createListingModal"
          >
            Dodaj oglas
          </button>
          <button
            class="btn btn-outline-light btn-lg shadow animate__animated animate__fadeInUp rounded-pill"
            @click="fetchListings"
          >
            Prikaži oglase
          </button>
        </div>
      </div>
    </section>

    <!-- Modal za dodavanje oglasa -->
    <div
      class="modal fade"
      id="createListingModal"
      tabindex="-1"
      aria-labelledby="createListingModalLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 shadow">
          <div class="modal-header">
            <h5
              class="modal-title text-primary fw-bold"
              id="createListingModalLabel"
            >
              Dodaj novi oglas
            </h5>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Zatvori"
            ></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <input
                v-model="title"
                type="text"
                class="form-control form-control-lg rounded-3"
                placeholder="Naslov smještaja"
              />
            </div>
            <div class="mb-3">
              <textarea
                v-model="description"
                class="form-control form-control-lg rounded-3"
                rows="3"
                placeholder="Opis smještaja"
              ></textarea>
            </div>
            <div class="mb-3">
              <input
                v-model="price"
                type="number"
                class="form-control form-control-lg rounded-3"
                placeholder="Cijena po noćenju (ETH)"
              />
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary rounded-pill"
              data-bs-dismiss="modal"
            >
              Odustani
            </button>
            <button
              type="button"
              class="btn btn-primary rounded-pill"
              @click="createListing"
            >
              Objavi oglas
            </button>
          </div>
        </div>
      </div>
    </div>
    <!-- Listings Section -->
    <section v-if="listings.length" id="listings" class="container my-5">
      <h2
        class="text-center mb-5 fw-bold text-primary animate__animated animate__fadeIn"
      >
        Dostupni smještaji
      </h2>
      <div class="row g-4">
        <div v-for="listing in listings" :key="listing.id" class="col-md-4">
          <div
            class="card h-100 shadow-sm border-0 rounded-4 animate__animated animate__fadeInUp"
          >
            <div class="card-body d-flex flex-column">
              <h5 class="card-title fw-bold">{{ listing.title }}</h5>
              <p class="card-text">{{ listing.description }}</p>
              <p class="card-text text-primary fw-bold">
                {{ listing.pricePerNight }} ETH / noćenje
              </p>

              <div class="mt-auto">
                <button
                  class="btn btn-outline-primary w-100 rounded-pill"
                  @click="bookListing(listing.id)"
                >
                  Rezerviraj
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { ethers } from "ethers";
import detectEthereumProvider from "@metamask/detect-provider";

const isConnected = ref(false);
const title = ref("");
const description = ref("");
const price = ref("");
const listings = ref([]);

const connectWallet = async () => {
  const provider = await detectEthereumProvider();
  if (provider) {
    await provider.request({ method: "eth_requestAccounts" });
    isConnected.value = true;
  } else {
    alert("MetaMask nije pronađen!");
  }
};

const createListing = async () => {
  alert(
    `Oglas dodan: ${title.value}, ${description.value}, ${price.value} ETH`
  );
};

const fetchListings = async () => {
  listings.value = [
    {
      id: 1,
      title: "Apartman u Zagrebu",
      description: "Blizu centra, odlična lokacija.",
      pricePerNight: 0.05,
    },
    {
      id: 2,
      title: "Kuća na moru",
      description: "Prekrasan pogled na more.",
      pricePerNight: 0.08,
    },
  ];

  // Automatski skrolaj dolje na listings
  setTimeout(() => {
    const listingsSection = document.getElementById("listings");
    if (listingsSection) {
      listingsSection.scrollIntoView({ behavior: "smooth" });
    }
  }, 100);
};

const bookListing = async (listingId) => {
  alert(`Rezerviran oglas ID: ${listingId}`);
};

const formatPrice = (wei) => {
  return ethers.utils.formatEther(wei);
};
</script>

<style scoped>
html,
body {
  margin: 0;
  padding: 0;
  width: 100%;
  overflow-x: hidden;
}
/* Hero section */
.hero-section {
  position: relative;
  width: 100%;
  min-height: 100vh;
  background-image: url("/hero.jpg");
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
}

.hero-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  z-index: 0;
}

.hero-content {
  position: relative;
  z-index: 1;
  max-width: 700px;
  padding: 0 15px;
  margin-top: 80px; /* da tekst ne ide ispod navbar-a */
}

body {
  margin: 0;
  padding: 0;
}
</style>
