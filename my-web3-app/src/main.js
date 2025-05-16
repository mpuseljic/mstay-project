import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";
import "./style.css";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "animate.css";
import "vue-toastification/dist/index.css";
import Toast from "vue-toastification";
import "@fortawesome/fontawesome-free/css/all.min.css";

const toastOptions = {
  position: "top-right",
  timeout: 3000,
  closeOnClick: true,
  pauseOnHover: true,
  draggable: true,
  draggablePercent: 0.6,
  showCloseButtonOnHover: false,
  hideProgressBar: false,
  closeButton: "button",
  icon: true,
  rtl: false,
};

const app = createApp(App);

app.use(router);
app.use(Toast, toastOptions);

app.mount("#app");
