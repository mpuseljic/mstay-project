<template>
  <div class="my-reservations-page py-5">
    <div class="container">
      <h2 class="fw-bold text-primary text-center mb-5">📅 Moje rezervacije</h2>
      <div v-if="userReservations.length" class="row g-4">
        <div
          v-for="reservation in userReservations"
          :key="reservation.id"
          class="col-md-4"
        >
          <div class="card h-100 shadow-sm border-0 rounded-4">
            <img
              :src="reservation.image"
              class="card-img-top rounded-top-4"
              alt="smještaj"
              style="height: 200px; object-fit: cover"
            />
            <div class="card-body">
              <h5 class="card-title fw-bold">{{ reservation.title }}</h5>
              <p class="card-text text-muted">📍 {{ reservation.location }}</p>
              <p class="card-text">
                🗓️ {{ formatDate(reservation.checkIn) }} -
                {{ formatDate(reservation.checkOut) }}
              </p>
              <button
                class="btn btn-outline-danger btn-sm"
                @click="cancelReservation(reservation.id)"
              >
                ❌ Otkaži rezervaciju
              </button>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="text-center text-muted mt-5">
        <h4>⛔ Trenutno nemate nijednu rezervaciju.</h4>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { ethers } from "ethers";
import mStayJson from "@/contracts/mStay.json";
import { useToast } from "vue-toastification";

const toast = useToast();

const userReservations = ref([]);

const formatDate = (timestamp) => {
  const date = new Date(timestamp * 1000);
  return date.toLocaleDateString("hr-HR");
};

const loadUserReservations = async () => {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const userAddress = await signer.getAddress();
  const contractAddress = import.meta.env.VITE_CONTRACT_ADDRESS;

  const contract = new ethers.Contract(
    contractAddress,
    mStayJson.abi,
    provider
  );

  const allListings = await contract.getAllListings();
  const allReservations = await contract.getAllReservations();

  const myReservations = allReservations
    .map((r) => ({
      id: Number(r.id),
      guest: r.guest,
      listingId: Number(r.listingId),
      checkIn: Number(r.checkInDate),
      checkOut: Number(r.checkOutDate),
    }))
    .filter((r) => r.guest.toLowerCase() === userAddress.toLowerCase());

  userReservations.value = myReservations
    .map((res) => {
      const listing = allListings.find((l) => Number(l.id) === res.listingId);
      if (!listing) return null;
      return {
        ...res,
        title: listing.title,
        location: listing.location,
        image: listing.images?.[0] || "/hero.jpg",
      };
    })
    .filter((r) => r !== null);
};

onMounted(loadUserReservations);

const cancelReservation = async (reservationId) => {
  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(
      import.meta.env.VITE_CONTRACT_ADDRESS,
      mStayJson.abi,
      signer
    );

    const tx = await contract.cancelReservation(reservationId);
    await tx.wait();
    toast.success("Rezervacija otkazana.");
    await loadUserReservations();
  } catch (err) {
    console.error(err);
    toast.error("Greška prilikom otkazivanja.");
  }
};
</script>

<style scoped>
.my-reservations-page {
  background: #f5f9ff;
  min-height: 100vh;
}
.card-title {
  font-family: "Poppins", sans-serif;
}
.card-text {
  font-family: "Open Sans", sans-serif;
}
.text-primary {
  color: #083637 !important;
}
</style>
