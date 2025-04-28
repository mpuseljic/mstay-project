<template>
  <div class="listings-page">
    <!-- Search Section -->
    <section class="search-section py-5 bg-light">
      <div class="container">
        <div class="row g-3 align-items-center">
          <div class="col-md-4">
            <input
              v-model="searchLocation"
              type="text"
              class="form-control form-control-lg rounded-3"
              placeholder="Upiši lokaciju (npr. Zagreb)"
            />
          </div>
          <div class="col-md-3">
            <input
              v-model="checkIn"
              type="date"
              class="form-control form-control-lg rounded-3"
            />
          </div>
          <div class="col-md-3">
            <input
              v-model="checkOut"
              type="date"
              class="form-control form-control-lg rounded-3"
            />
          </div>
          <div class="col-md-2">
            <button
              class="btn btn-primary btn-lg w-100 rounded-pill"
              @click="filterListings"
            >
              Traži
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- Listings Section -->
    <section class="container my-5">
      <h2
        class="text-center mb-5 fw-bold text-primary animate__animated animate__fadeIn"
      >
        Dostupni smještaji
      </h2>

      <div v-if="filteredListings.length" class="row g-4">
        <div
          v-for="listing in filteredListings"
          :key="listing.id"
          class="col-md-4"
        >
          <div
            class="card h-100 shadow-sm border-0 rounded-4 animate__animated animate__fadeInUp"
          >
            <img
              :src="listing.image"
              class="card-img-top rounded-top-4"
              alt="slika smještaja"
              style="height: 250px; object-fit: cover"
            />
            <div class="card-body d-flex flex-column">
              <h5 class="card-title fw-bold">{{ listing.title }}</h5>
              <p class="card-text text-muted">{{ listing.location }}</p>
              <p class="card-text">{{ listing.description }}</p>
              <p class="card-text text-primary fw-bold">
                {{ listing.pricePerNight }} ETH / noćenje
              </p>
              <div class="mt-auto">
                <button class="btn btn-outline-primary w-100 rounded-pill">
                  Rezerviraj
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
import { ref } from "vue";

const listings = ref([
  {
    id: 1,
    title: "Apartman u Zagrebu",
    location: "Zagreb",
    description: "Moderan apartman blizu centra.",
    pricePerNight: 0.05,
    image: "/listing1.jpg",
  },
  {
    id: 2,
    title: "Vila uz more",
    location: "Split",
    description: "Luksuzna vila s privatnim bazenom.",
    pricePerNight: 0.1,
    image: "/listing2.jpg",
  },
  {
    id: 3,
    title: "Kuća na selu",
    location: "Osijek",
    description: "Mirna kuća okružena prirodom.",
    pricePerNight: 0.03,
    image: "/listing3.jpg",
  },
]);

const searchLocation = ref("");
const checkIn = ref("");
const checkOut = ref("");
const filteredListings = ref([...listings.value]);

const filterListings = () => {
  filteredListings.value = listings.value.filter((listing) => {
    const locationMatch = listing.location
      .toLowerCase()
      .includes(searchLocation.value.toLowerCase());
    return locationMatch;
  });
};
</script>

<style scoped>
.search-section {
  background: #e9effd;
}

.card-title {
  font-family: "Poppins", sans-serif;
}

.card-text {
  font-family: "Open Sans", sans-serif;
}
.text-primary {
  --bs-text-opacity: 1;
  color: rgb(8 54 55) !important;
}
</style>
