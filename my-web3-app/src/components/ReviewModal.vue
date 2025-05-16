<template>
  <div class="modal-backdrop" v-if="show" @click.self="$emit('close')">
    <div class="modal-content bg-white p-4 rounded-4 shadow">
      <h4 class="mb-4 fw-bold text-dark">📝 Ostavi recenziju</h4>

      <!-- Zvjezdice -->
      <div class="mb-3">
        <label class="form-label">Ocjena:</label>
        <div class="star-rating d-flex gap-1 mt-1">
          <i
            v-for="i in 5"
            :key="i"
            class="fa-star"
            :class="i <= rating ? 'fas text-warning' : 'far text-muted'"
            style="cursor: pointer; font-size: 1.5rem"
            @click="rating = i"
          ></i>
        </div>
      </div>

      <!-- Komentar -->
      <div class="mb-3">
        <label class="form-label fw-semibold">Komentar:</label>
        <textarea
          v-model="comment"
          class="form-control rounded-3"
          rows="3"
          placeholder="Napišite kratak osvrt na svoj boravak..."
        ></textarea>
      </div>

      <!-- Gumbi -->
      <div class="d-flex justify-content-end gap-2">
        <button class="btn btn-secondary rounded-pill" @click="$emit('close')">
          Zatvori
        </button>
        <button class="btn btn-primary rounded-pill" @click="submit">
          ✅ Pošalji
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { ethers } from "ethers";
import mStayJson from "@/contracts/mStay.json";
import { useToast } from "vue-toastification";

const props = defineProps(["listingId", "show"]);
const emit = defineEmits(["close", "refresh"]);
const rating = ref(0);
const comment = ref("");
const toast = useToast();

const submit = async () => {
  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(
      import.meta.env.VITE_CONTRACT_ADDRESS,
      mStayJson.abi,
      signer
    );

    const tx = await contract.leaveReview(
      props.listingId,
      rating.value,
      comment.value
    );
    await tx.wait();
    toast.success("Recenzija uspješno dodana!");
    emit("close");
    emit("refresh");
  } catch (err) {
    console.error(err);
    toast.error("Greška kod slanja recenzije.");
  }
};
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 999;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 1rem;
}

.modal-content {
  width: 100%;
  max-width: 500px;
  background-color: #ffffff;
  border-radius: 1rem;
}

.star-rating i {
  transition: transform 0.15s ease;
}
.star-rating i:hover {
  transform: scale(1.2);
}
</style>
