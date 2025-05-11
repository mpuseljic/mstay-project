<template>
  <div class="my-listings-page py-5">
    <div class="container">
      <h2 class="fw-bold text-primary text-center mb-5">📂 Moji oglasi</h2>

      <div v-if="userListings.length" class="row g-4">
        <div v-for="listing in userListings" :key="listing.id" class="col-md-4">
          <div class="card h-100 shadow-sm border-0 rounded-4">
            <img
              :src="listing.image"
              class="card-img-top rounded-top-4"
              alt="slika"
              style="height: 200px; object-fit: cover"
            />
            <div class="card-body">
              <h5 class="card-title fw-bold">{{ listing.title }}</h5>
              <p class="card-text text-muted">📍 {{ listing.location }}</p>
              <p class="card-text">💬 {{ listing.description }}</p>
              <p class="card-text text-primary fw-bold">
                {{ listing.pricePerNight }} ETH / noćenje
              </p>

              <button
                class="btn btn-outline-danger btn-sm"
                @click="deleteListing(listing.id)"
              >
                ❌ Obriši oglas
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="text-center text-muted mt-5">
        <h4>⛔ Nema objavljenih oglasa.</h4>
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

const userListings = ref([]);

const loadUserListings = async () => {
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

  userListings.value = allListings
    .map((l) => ({
      id: Number(l.id),
      owner: l.owner,
      title: l.title,
      location: l.location,
      description: l.description,
      pricePerNight: ethers.utils.formatEther(l.pricePerNight),
      image: l.images?.[0] || "/hero.jpg",
    }))
    .filter((l) => l.owner.toLowerCase() === userAddress.toLowerCase());
};

const deleteListing = async (listingId) => {
  if (!confirm("Jeste li sigurni da želite obrisati oglas?")) return;

  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(
      import.meta.env.VITE_CONTRACT_ADDRESS,
      mStayJson.abi,
      signer
    );

    const tx = await contract.deleteListing(listingId);
    await tx.wait();

    toast.success("Oglas uspješno obrisan!");
    await loadUserListings();
  } catch (err) {
    console.error(err);
    toast.error("Greška prilikom brisanja oglasa.");
  }
};

onMounted(loadUserListings);
</script>

<style scoped>
.my-listings-page {
  background: #f3f6ff;
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
