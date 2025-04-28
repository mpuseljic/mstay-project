<template>
  <div class="home-page">
    <!-- Hero Section -->
    <section class="hero d-flex align-items-center text-white text-center">
      <div class="overlay"></div>
      <div class="container hero-content">
        <h1
          class="display-2 fw-bold mb-4 animate__animated animate__fadeInDown"
        >
          Dobrodošli u mStay
        </h1>
        <p class="lead mb-5 animate__animated animate__fadeInUp">
          Pronađi savršeni smještaj, sigurno i bez posrednika.
        </p>
        <div>
          <router-link
            to="/listings"
            class="btn btn-primary btn-lg me-3 rounded-pill shadow animate__animated animate__fadeInUp"
          >
            Pregledaj smještaje
          </router-link>
          <router-link
            to="/add-listing"
            class="btn btn-outline-light btn-lg rounded-pill shadow animate__animated animate__fadeInUp"
          >
            Dodaj smještaj
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
              class="img-fluid rounded-4 shadow"
            />
          </div>
          <div class="col-md-6">
            <h2 class="fw-bold mb-4 text-primary">Zašto odabrati mStay?</h2>
            <p class="lead text-muted">
              mStay omogućuje transparentno i sigurno rezerviranje smještaja
              putem blockchain tehnologije, eliminirajući potrebe za skupim
              posrednicima.
            </p>
            <ul class="list-unstyled mt-4">
              <li class="mb-3">✅ Sigurne transakcije putem blockchaina</li>
              <li class="mb-3">✅ Potpuna kontrola nad rezervacijama</li>
              <li class="mb-3">✅ Jednostavno plaćanje kriptovalutama</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- Call to Action Section -->
    <section class="cta-section text-white text-center py-5">
      <div class="overlay"></div>
      <div class="container position-relative z-1">
        <h2 class="display-5 fw-bold mb-4 animate__animated animate__fadeIn">
          Spremni za svoje iduće putovanje?
        </h2>
        <router-link
          to="/listings"
          class="btn btn-light btn-lg rounded-pill shadow animate__animated animate__fadeInUp"
        >
          Pronađi smještaj
        </router-link>
      </div>
    </section>
  </div>
</template>

<script setup></script>

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
}

.overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  z-index: 0;
}

.hero-content {
  position: relative;
  z-index: 1;
}

/* About Section */
.about-section {
  background: #e9effd;
}

/* CTA Section */
.cta-section {
  position: relative;
  background: url("/cta.jpg") center center / cover no-repeat;
  min-height: 50vh;
  display: flex;
  justify-content: center;
  align-items: center;
}

.cta-section .overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  z-index: 0;
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
</style>
