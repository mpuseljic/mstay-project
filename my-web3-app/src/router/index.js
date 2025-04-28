import { createRouter, createWebHistory } from "vue-router";
import Home from "../views/Home.vue";
import Listings from "../views/Listings.vue";
import AddListing from "../views/AddListing.vue";

const routes = [
  { path: "/", name: "Home", component: Home },
  { path: "/listings", name: "Listings", component: Listings },
  { path: "/add-listing", name: "AddListing", component: AddListing },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
