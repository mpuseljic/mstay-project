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
  top: 20px;
  right: 20px;
  background: rgba(8, 54, 55, 0.95);
  color: white;
  padding: 12px 24px;
  border-radius: 50px;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  z-index: 9999;
}
</style>
