/**
 * auth-helper.js
 * Añade interactividad al frontend de VetCare (Hospital Veterinario)
 * Soporta persistencia local (localStorage) y fallback/comunicación en vivo con el API
 */

const API_URL = "http://localhost:3000";

document.addEventListener("DOMContentLoaded", () => {
  const path = window.location.pathname;

  // ==========================================
  // A. LOGIN DE CLIENTES (login.html)
  // ==========================================
  if (path.includes("login.html") && !path.includes("login-empleado.html")) {
    const form = document.querySelector("form");
    if (form) {
      form.addEventListener("submit", async (e) => {
        e.preventDefault();
        const email = document.getElementById("email").value;
        const password = document.getElementById("password").value;

        // Intentar llamada real al API
        try {
          const res = await fetch(`${API_URL}/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password })
          });
          const data = await res.json();
          if (data.success && data.client) {
            localStorage.setItem("currentUser", JSON.stringify(data.client));
            window.location.href = "../dashboard/owner.html";
            return;
          }
        } catch (err) {
          console.log("Servidor API offline, usando credenciales simuladas localmente.");
        }

        // Simulación offline / mock exitoso
        const mockUser = {
          id_cliente: 99,
          nombre_cliente: email.split("@")[0].toUpperCase(),
          correo: email
        };
        localStorage.setItem("currentUser", JSON.stringify(mockUser));
        window.location.href = "../dashboard/owner.html";
      });
    }
  }

  // ==========================================
  // B. LOGIN DE EMPLEADOS (login-empleado.html)
  // ==========================================
  if (path.includes("login-empleado.html")) {
    const form = document.querySelector("form");
    if (form) {
      form.addEventListener("submit", (e) => {
        e.preventDefault();
        const email = document.getElementById("emailEmp").value.toLowerCase();
        
        // Simular login de empleado
        if (email.includes("doctor") || email.includes("doc")) {
          localStorage.setItem("currentUser", JSON.stringify({ name: "Dr. Ruiz", role: "doctor" }));
          window.location.href = "../dashboard/doctor.html";
        } else {
          localStorage.setItem("currentUser", JSON.stringify({ name: "María Recepción", role: "recepcionista" }));
          window.location.href = "../dashboard/recepcion.html";
        }
      });
    }
  }

  // ==========================================
  // C. REGISTRO DUEÑO - PASO 1 (register-owner.html / recepcionista.html)
  // ==========================================
  if (path.includes("register-owner.html") || (path.includes("recepcionista.html") && !path.includes("pet"))) {
    const form = document.getElementById("formulario") || document.querySelector("form");
    if (form) {
      form.addEventListener("submit", (e) => {
        e.preventDefault();
        
        const formData = {
          nombre: document.getElementById("nombre").value,
          apellidoP: document.getElementById("apellidoP").value,
          apellidoM: document.getElementById("apellidoM").value,
          email: document.getElementById("email").value,
          telefono: document.getElementById("telefono")?.value || "",
          sexo: document.querySelector('input[name="sexo"]:checked')?.value || "M",
          fechaNac: document.getElementById("fechaNac").value,
          numMascotas: document.getElementById("numMascotas").value,
          pais: document.getElementById("pais").value,
          estado: document.getElementById("estado").value,
          municipio: document.getElementById("municipio").value,
          colonia: document.getElementById("colonia").value,
          calle: document.getElementById("calle").value,
          numExt: document.getElementById("numExt").value,
          numInt: document.getElementById("numInt")?.value || ""
        };

        localStorage.setItem("tempOwnerData", JSON.stringify(formData));
        
        if (path.includes("recepcionista.html")) {
          window.location.href = "../dashboard/recepcioniste2.html";
        } else {
          window.location.href = "register-owner2.html";
        }
      });
    }
  }

  // ==========================================
  // D. REGISTRO DUEÑO - PASO 2 (register-owner2.html / recepcioniste2.html)
  // ==========================================
  if (path.includes("register-owner2.html") || path.includes("recepcioniste2.html")) {
    const form = document.querySelector("form");
    if (form) {
      form.addEventListener("submit", async (e) => {
        e.preventDefault();
        
        const tempOwner = JSON.parse(localStorage.getItem("tempOwnerData") || "{}");
        const contrasena = document.getElementById("password")?.value || "123456";
        
        const fullPayload = {
          ...tempOwner,
          contrasena,
          tarjeta: document.getElementById("tarjeta").value,
          rfc: document.getElementById("RFC").value
        };

        let newClient = {
          id_cliente: 1,
          nombre_cliente: tempOwner.nombre || "Nuevo Dueño",
          correo: tempOwner.email || "correo@ejemplo.com"
        };

        // Enviar al API
        try {
          const res = await fetch(`${API_URL}/auth/register`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(fullPayload)
          });
          const data = await res.json();
          if (data.success && data.client) {
            newClient = data.client;
          }
        } catch (err) {
          console.log("Servidor API offline, registrando cliente localmente.");
          newClient.id_cliente = Date.now();
        }

        // Guardar usuario en localStorage
        localStorage.setItem("currentUser", JSON.stringify(newClient));
        
        // Agregar a la lista local
        const savedOwners = JSON.parse(localStorage.getItem("ownersList") || "[]");
        savedOwners.push(newClient);
        localStorage.setItem("ownersList", JSON.stringify(savedOwners));

        if (path.includes("recepcioniste2.html")) {
          alert("¡Dueño registrado exitosamente por Recepción!");
          window.location.href = "recepcion.html";
        } else {
          window.location.href = "register-pet.html";
        }
      });

      // Hacer que el enlace "Registro de Mascota" actúe como submit
      const petBtn = document.querySelector("a[href='register-pet.html']") || document.querySelector("a[href='recepcion.html']");
      if (petBtn) {
        petBtn.addEventListener("click", (e) => {
          e.preventDefault();
          form.requestSubmit();
        });
      }
    }
  }

  // ==========================================
  // E. REGISTRO DE MASCOTA - PASO 1 (register-pet.html / pet-recepcionista.html)
  // ==========================================
  if (path.includes("register-pet.html") || path.includes("pet-recepcionista.html")) {
    const form = document.querySelector("form");
    if (form) {
      // Intentar llenar especies dinámicamente desde API
      const apiEspecieSelect = document.getElementById("especieSelect") || document.getElementById("especie");
      if (apiEspecieSelect) {
        fetch(`${API_URL}/especies`)
          .then(r => r.json())
          .then(data => {
            if (data.length) {
              apiEspecieSelect.innerHTML = data
                .map(e => `<option value="${e.nom_especie.toLowerCase()}">${e.nom_especie}</option>`)
                .join("");
            }
          })
          .catch(() => console.log("Usando selectores estáticos de especies"));
      }

      form.addEventListener("submit", (e) => {
        e.preventDefault();
        
        const especieVal = document.getElementById("especie")?.value || document.getElementById("especieSelect")?.value || "perro";
        const razaSelect = document.getElementById("razaSelect") || document.getElementById("select-" + especieVal.charAt(0).toUpperCase() + especieVal.slice(1));
        const razaVal = razaSelect?.value || "desconocido";

        const petData = {
          nombre: document.getElementById("nombre").value,
          especie: especieVal,
          raza: razaVal,
          alto: document.getElementById("alto")?.value || 30,
          largo: document.getElementById("largo")?.value || 40,
          ancho: document.getElementById("ancho")?.value || 20,
          peso: document.getElementById("peso")?.value || 10,
          sexo: document.querySelector('input[name="sexo"]:checked')?.value || "Macho",
          fech_nac: document.getElementById("fechaNac")?.value || new Date().toISOString().slice(0, 10),
          esterilizado: document.querySelector('input[name="esterilizado"]:checked')?.value || "Sí",
          largo_pelaje: document.getElementById("pelaje")?.value || 3,
          senas_parti: document.getElementById("senas")?.value || "Ninguna"
        };

        localStorage.setItem("tempPetData", JSON.stringify(petData));
        localStorage.setItem("especieSeleccionada", petData.especie);

        if (path.includes("pet-recepcionista.html")) {
          window.location.href = "../auth/pet-recepcionista2.html";
        } else {
          window.location.href = "register-pet2.html";
        }
      });

      // Asegurar que el botón Siguiente haga submit
      const nextBtn = document.querySelector(".btn[href*='register-pet2.html']") || document.querySelector(".btn[href*='pet-recepcionista2.html']");
      if (nextBtn) {
        nextBtn.addEventListener("click", (e) => {
          e.preventDefault();
          form.requestSubmit();
        });
      }
    }
  }

  // ==========================================
  // F. REGISTRO DE MASCOTA - PASO 2 (register-pet2.html / pet-recepcionista2.html)
  // ==========================================
  if (path.includes("register-pet2.html") || path.includes("pet-recepcionista2.html")) {
    const form = document.querySelector("form");
    if (form) {
      form.addEventListener("submit", async (e) => {
        e.preventDefault();
        
        const tempPet = JSON.parse(localStorage.getItem("tempPetData") || "{}");
        const currentUser = JSON.parse(localStorage.getItem("currentUser") || "{}");
        
        const payload = {
          ...tempPet,
          id_cliente: currentUser.id_cliente || 1,
          id_especie: tempPet.especie === "perro" ? 1 : tempPet.especie === "gato" ? 2 : tempPet.especie === "reptil" ? 3 : 4
        };

        // Enviar al API
        try {
          await fetch(`${API_URL}/auth/register-pet`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
          });
        } catch (err) {
          console.log("Servidor API offline, registrando mascota en localstorage.");
        }

        // Persistencia en LocalStorage
        const myPets = JSON.parse(localStorage.getItem(`pets_${payload.id_cliente}`) || "[]");
        myPets.push({
          id_mascota: Date.now(),
          nombre: payload.nombre,
          nom_especie: payload.especie.toUpperCase(),
          peso: payload.peso,
          sexo: payload.sexo
        });
        localStorage.setItem(`pets_${payload.id_cliente}`, JSON.stringify(myPets));

        if (path.includes("pet-recepcionista2.html")) {
          alert("¡Mascota registrada exitosamente por Recepción!");
          window.location.href = "../dashboard/recepcion.html";
        } else {
          alert("¡Mascota registrada exitosamente!");
          window.location.href = "../dashboard/owner.html";
        }
      });
    }
  }

  // ==========================================
  // G. PANEL DE DUEÑO (owner.html)
  // ==========================================
  if (path.includes("owner.html")) {
    const currentUser = JSON.parse(localStorage.getItem("currentUser") || "{}");
    const welcomeH1 = document.querySelector("h1");
    if (welcomeH1 && currentUser.nombre_cliente) {
      welcomeH1.innerHTML = `👨‍⚕️ Mis mascotas <span style="font-size:1.2rem;font-weight:400;color:var(--text-2)">— ¡Hola, ${currentUser.nombre_cliente}!</span>`;
    }

    // Cargar mascotas dinámicamente
    const container = document.querySelector(".dashboard .cards");
    if (container) {
      const id = currentUser.id_cliente || 1;
      
      const renderPets = (pets) => {
        let petHtml = `
          <div class="card" style="grid-column: span 2">
            <h2>🐾 Mis Pacientes Registrados</h2>
            <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 16px; margin-top:12px;">
        `;

        if (!pets.length) {
          petHtml += `
            <div style="grid-column: span 2; text-align:center; padding: 20px; opacity:0.7">
              Aún no tienes mascotas registradas. ¡Usa las acciones rápidas para dar de alta una!
            </div>
          `;
        } else {
          pets.forEach(pet => {
            petHtml += `
              <div style="background:var(--muted); padding:16px; border-radius:var(--radius-sm); border:1px solid var(--border); display:flex; flex-direction:column; gap:6px;">
                <div style="font-size:1.1rem; font-weight:700; color:var(--text)">🐶 ${pet.nombre}</div>
                <div style="font-size:0.9rem; opacity:0.85"><b>Especie:</b> ${pet.nom_especie || pet.especie || "Desconocido"}</div>
                <div style="font-size:0.9rem; opacity:0.85"><b>Sexo:</b> ${pet.sexo || "Macho"}</div>
                <div style="font-size:0.9rem; opacity:0.85"><b>Peso:</b> ${pet.peso || "10"} kg</div>
                <hr style="border:0; border-top:1px solid var(--border); margin: 6px 0">
                <div style="font-size:0.8rem; font-style:italic; opacity:0.7">Última cita: 28 de mayo de 2026<br>Diagnóstico: Sano</div>
              </div>
            `;
          });
        }

        petHtml += `
            </div>
          </div>
          <div class="card">
            <h2>Acciones rápidas</h2>
            <div style="display:flex; flex-direction:column; gap:10px; margin-top:12px;">
              <a class="btn" href="../auth/register-pet.html">🐾 Registrar nueva mascota</a>
              <a class="btn btn--ghost" href="../auth/login.html" style="text-align:center">Cerrar sesión</a>
            </div>
          </div>
        `;
        
        container.innerHTML = petHtml;
      };

      // Intentar fetch real del API, fallback a localStorage
      fetch(`${API_URL}/clientes/${id}/mascotas`)
        .then(r => r.json())
        .then(data => {
          if (data && data.length) {
            renderPets(data);
          } else {
            throw new Error("No pets from API");
          }
        })
        .catch(() => {
          // LocalStorage
          const localPets = JSON.parse(localStorage.getItem(`pets_${id}`) || "[]");
          if (!localPets.length) {
            // Mock inicial para demostración si está vacío
            localPets.push(
              { nombre: "Max", nom_especie: "PERRO", sexo: "Macho", peso: 15 },
              { nombre: "Rocky", nom_especie: "PERRO", sexo: "Macho", peso: 22 }
            );
          }
          renderPets(localPets);
        });
    }
  }
});
