<template>
  <div class="text-center my-5">
    <button
      v-if="!isConnected"
      class="custom-metamask-btn"
      @click="connectWallet"
    >
      <img src="/metamask.png" alt="MetaMask" class="metamask-icon" />
      Connect MetaMask
    </button>
    <div v-else class="connected-info">
      <span>🦊 {{ userAddressShort }}</span>
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

const emit = defineEmits(["wallet-connected"]);

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
      emit("wallet-connected", userAddress.value);
    } catch (error) {
      console.error("Connection failed:", error);
    }
  } else {
    alert("MetaMask nije pronađen!");
  }
};
</script>

<style scoped>
.custom-metamask-btn {
  background-color: rgb(8, 54, 55);
  color: #fff;
  border: none;
  border-radius: 999px;
  padding: 12px 24px;
  font-size: 1rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: background-color 0.3s ease;
}

.custom-metamask-btn:hover {
  background-color: rgb(6, 44, 45);
}

.metamask-icon {
  width: 24px;
  height: 24px;
}

.connected-info {
  font-weight: 600;
  font-size: 14px;
  background-color: #eef6f8;
  padding: 8px 14px;
  border-radius: 50px;
  color: #083637;
}
</style>
