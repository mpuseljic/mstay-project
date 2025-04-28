<template>
  <div class="text-center my-5">
    <button
      v-if="!isConnected"
      class="btn btn-primary btn-lg rounded-pill"
      @click="connectWallet"
    >
      Connect Wallet
    </button>
    <div v-else>
      <p><strong>Connected:</strong> {{ userAddress }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import detectEthereumProvider from "@metamask/detect-provider";
import { ethers } from "ethers";
import mStayJson from "@/contracts/mStay.json";

const isConnected = ref(false);
const userAddress = ref("");
const provider = ref(null);
const signer = ref(null);
const contract = ref(null);

const contractAddress = import.meta.env.VITE_CONTRACT_ADDRESS;

const connectWallet = async () => {
  const ethProvider = await detectEthereumProvider();
  if (ethProvider) {
    try {
      await ethProvider.request({ method: "eth_requestAccounts" });
      provider.value = new ethers.providers.Web3Provider(ethProvider);
      signer.value = provider.value.getSigner();
      userAddress.value = await signer.value.getAddress();
      isConnected.value = true;
      contract.value = new ethers.Contract(
        contractAddress,
        mStayJson.abi,
        signer.value
      );
      console.log("Wallet connected:", userAddress.value);
    } catch (error) {
      console.error("Connection failed:", error);
    }
  } else {
    alert("MetaMask nije pronađen!");
  }
};
</script>

<style scoped>
button {
  min-width: 250px;
}
</style>
