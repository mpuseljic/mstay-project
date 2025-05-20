<script setup>
import Navbar from "@/components/Navbar.vue";
import Toast from "@/components/Toast.vue";
import { ref } from "vue";

const toastRef = ref(null);

const handleWalletConnected = (address) => {
  toastRef.value?.showToast("Wallet uspješno povezan 🎉");
};
</script>

<template>
  <Navbar @wallet-connected="handleWalletConnected" />
  <Toast ref="toastRef" />
  <router-view></router-view>
</template>
