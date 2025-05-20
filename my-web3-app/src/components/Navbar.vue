<template>
  <nav class="top-navbar shadow-sm">
    <div
      class="container d-flex justify-content-between align-items-center py-3"
    >
      <router-link to="/" class="navbar-brand fw-bold fs-3 text-dark">
        <span class="text-accent">mStay</span>
      </router-link>

      <div class="d-flex gap-4 align-items-center nav-links">
        <router-link to="/my-reservations" class="nav-link">
          🗓️ Moje rezervacije
        </router-link>
        <router-link to="/my-listings" class="nav-link">
          📂 Moji oglasi
        </router-link>
        <!-- WalletConnect kao desni login gumb -->
        <div class="wallet-nav">
          <WalletConnect
            @wallet-connected="$emit('wallet-connected', $event)"
          />
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import WalletConnect from "@/components/WalletConnect.vue";
</script>

<style scoped>
.top-navbar {
  position: sticky;
  top: 0;
  z-index: 999;
  background-color: #ffffff;
  border-bottom: 1px solid #eee;
  height: 64px; /* fiksna visina */
  display: flex;
  align-items: center;
}

.top-navbar .container {
  height: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.navbar-brand {
  font-size: 1.8rem;
  text-decoration: none;
  color: #083637;
}

.nav-link {
  text-decoration: none;
  font-weight: 600;
  font-size: 1rem;
  color: #083637;
  transition: all 0.3s ease;
  padding: 0 8px;
}

.nav-link:hover {
  color: #00c2cb;
}

.wallet-nav {
  margin-left: 1rem;
  display: flex;
  align-items: center;
  height: 100%;
}

.wallet-nav button {
  padding: 8px 14px !important;
  font-size: 0.9rem;
  border-radius: 999px;
}
</style>
