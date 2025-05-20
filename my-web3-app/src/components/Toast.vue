<template>
  <div
    v-if="visible"
    class="custom-toast animate__animated animate__fadeInDown"
  >
    {{ message }}
  </div>
</template>

<script setup>
import { ref } from "vue";

const visible = ref(false);
const message = ref("");

const showToast = (text, duration = 3000) => {
  message.value = text;
  visible.value = true;
  setTimeout(() => (visible.value = false), duration);
};

defineExpose({ showToast });
</script>

<style scoped>
.custom-toast {
  position: fixed;
  top: 80px;
  right: 20px;
  background: #083637;
  color: white;
  padding: 12px 24px;
  border-radius: 50px;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  z-index: 100000; /* 🚨 još viši da sigurno bude iznad svega */
  pointer-events: none; /* da ne blokira klikove */
}
</style>
