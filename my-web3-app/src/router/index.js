import { createRouter, createWebHistory } from "vue-router";
import Home from "../views/Home.vue";
import Listings from "../views/Listings.vue";

const routes = [
  { path: "/", name: "Home", component: Home },
  { path: "/listings", name: "Listings", component: Listings },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
