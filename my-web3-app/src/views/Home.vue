<template>
  <div class="home-page">
    <!-- Hero Section -->
    <div class="wallet-button-container">
      <WalletConnect @wallet-connected="handleWalletConnected" />
    </div>
    <Toast ref="toastRef" />
    <section class="hero d-flex align-items-center text-white text-center">
      <div class="overlay"></div>
      <div class="container hero-content">
        <h1 class="hero-title animate__animated animate__fadeInDown">
          Dobrodošli u <span class="text-accent">mStay</span>
        </h1>
        <p class="hero-subtitle animate__animated animate__fadeInUp">
          Pronađi savršeni smještaj, sigurno i bez posrednika.
        </p>
        <div
          class="d-flex justify-content-center gap-3 mt-4 animate__animated animate__fadeInUp"
        >
          <router-link to="/listings" class="custom-btn primary">
            🏠 Pregledaj smještaje
          </router-link>
          <router-link to="/add-listing" class="custom-btn outline">
            ➕ Dodaj smještaj
          </router-link>
        </div>
      </div>
    </section>

    <!-- About Section -->
    <section class="about-section py-5">
      <div class="container">
        <div class="row align-items-center">
          <div class="col-md-6 mb-4 mb-md-0">
            <img
              src="/about.jpg"
              alt="O nama"
              class="img-fluid rounded-4 shadow-lg"
            />
          </div>
          <div class="col-md-6">
            <h2 class="about-title mb-4">
              Zašto odabrati <span class="text-accent">mStay</span>?
            </h2>
            <p class="about-description">
              Transparentno, decentralizirano i bez stresa – mStay koristi
              blockchain tehnologiju za sigurnije i izravnije rezervacije
              smještaja, bez nepotrebnih posrednika.
            </p>
            <ul class="features-list mt-4">
              <li>
                <i class="fa-solid fa-shield-halved me-2 text-accent"></i>
                Sigurne transakcije putem blockchaina
              </li>
              <li>
                <i class="fa-solid fa-user-lock me-2 text-accent"></i>
                Potpuna kontrola nad rezervacijama
              </li>
              <li>
                <i class="fa-brands fa-ethereum me-2 text-accent"></i>
                Jednostavno plaćanje kriptovalutama
              </li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- Call to Action Section -->
    <section class="cta-section text-white text-center py-5">
      <div class="overlay-blur"></div>
      <div class="container position-relative z-1">
        <h2 class="cta-title animate__animated animate__fadeIn">
          Spremni za svoje iduće
          <span class="highlighted-word">putovanje</span>?
        </h2>
        <p class="cta-subtitle animate__animated animate__fadeInUp mb-4">
          Istraži jedinstvene smještaje dostupne odmah putem blockchaina.
        </p>
        <router-link
          to="/listings"
          class="btn btn-cta rounded-pill shadow animate__animated animate__fadeInUp"
        >
          🔎 Pronađi smještaj
        </router-link>
      </div>
    </section>
  </div>
</template>

<script setup>
import WalletConnect from "@/components/WalletConnect.vue";
import Toast from "@/components/Toast.vue";
import { ref } from "vue";

const toastRef = ref(null);

const handleWalletConnected = (address) => {
  toastRef.value?.showToast("Wallet uspješno povezan 🎉");
};
</script>

<style scoped>
/* Hero Section */
.hero {
  position: relative;
  width: 100%;
  min-height: 100vh;
  background: url("/hero.jpg") center center / cover no-repeat;
  display: flex;
  justify-content: center;
  align-items: center;
  text-shadow: 1px 1px 5px rgba(0, 0, 0, 0.6);
}

.overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  z-index: 0;
}

.hero-content {
  position: relative;
  z-index: 1;
  color: white;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 700;
  font-family: "Poppins", sans-serif;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 700;
  font-family: "Poppins", sans-serif;
}

.text-accent {
  color: #00c2cb;
}

.custom-btn {
  padding: 14px 28px;
  border-radius: 999px;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.3s ease;
  text-decoration: none;
}

.custom-btn.primary {
  background-color: rgb(8, 54, 55);
  color: white;
  border: none;
}

.custom-btn.primary:hover {
  background-color: rgb(6, 44, 45);
}

.custom-btn.outline {
  background-color: transparent;
  border: 2px solid white;
  color: white;
}

.custom-btn.outline:hover {
  background-color: white;
  color: rgb(8, 54, 55);
}

/* Wallet button positioning */
.wallet-button-container {
  position: absolute;
  top: 20px;
  right: 30px;
  z-index: 1000;
}

/* About Section */
.about-section {
  background: linear-gradient(135deg, #f3f6ff 0%, #e9effd 100%);
  padding-top: 4rem;
  padding-bottom: 4rem;
}

.about-title {
  font-family: "Poppins", sans-serif;
  font-size: 2.2rem;
  font-weight: 700;
  color: rgb(8, 54, 55);
}

.about-description {
  font-size: 1.125rem;
  color: #555;
  line-height: 1.7;
}

.text-accent {
  color: #00c2cb;
}

.features-list {
  list-style: none;
  padding-left: 0;
  font-size: 1.05rem;
}

.features-list li {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
  font-weight: 500;
}

/* CTA Section */
.cta-section {
  position: relative;
  background: url("/cta.jpg") center center / cover no-repeat;
  min-height: 60vh;
  display: flex;
  justify-content: center;
  align-items: center;
  padding-top: 4rem;
  padding-bottom: 4rem;
}

.overlay-blur {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  backdrop-filter: blur(4px);
  background: rgba(0, 0, 0, 0.5);
  z-index: 0;
}

.cta-title {
  font-size: 2.75rem;
  font-weight: 700;
  font-family: "Poppins", sans-serif;
  margin-bottom: 1rem;
}

.cta-subtitle {
  font-size: 1.2rem;
  font-weight: 400;
  color: #f0f0f0;
}

.highlighted-word {
  color: #00d1c1;
}

.btn-cta {
  font-size: 1.1rem;
  padding: 0.8rem 2rem;
  background-color: #00c2cb;
  border: none;
  color: #fff;
  transition: background-color 0.3s ease;
}

.btn-cta:hover {
  background-color: #00a4ad;
  color: #fff;
}

.z-1 {
  position: relative;
  z-index: 1;
}

.z-1 {
  position: relative;
  z-index: 1;
}

/* General styling */
body {
  font-family: "Open Sans", sans-serif;
  color: #333333;
  margin: 0;
  padding: 0;
}

h1,
h2,
h3,
.btn,
.navbar-brand {
  font-family: "Poppins", sans-serif;
}

.btn-primary {
  background-color: #4a6cf7;
  border-color: #4a6cf7;
}

.btn-primary:hover {
  background-color: #7baaf7;
  border-color: #7baaf7;
}

.btn-outline-light:hover {
  background-color: #ffffff;
  color: #4a6cf7;
}

.text-primary {
  --bs-text-opacity: 1;
  color: rgb(8 54 55) !important;
}

.wallet-button-container {
  position: absolute;
  top: 10px;
  right: 20px;
  z-index: 1000;
}
</style>
