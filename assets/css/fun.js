document.addEventListener('DOMContentLoaded', function () {
  // Seleccionar campos
  const nombre    = document.querySelector('#nombre');
  const apellidoP = document.querySelector('#apellidoP');
  const apellidoM = document.querySelector('#apellidoM');
  const email     = document.querySelector('#email');
  const telefono  = document.querySelector('#telefono');
  const fecha     = document.querySelector('#fechaNac');

  // Listeners
  nombre?.addEventListener('blur', validar);
  apellidoP?.addEventListener('blur', validar);
  apellidoM?.addEventListener('blur', validar);
  email?.addEventListener('blur', validar);
  telefono?.addEventListener('blur', validar);
  fecha?.addEventListener('blur', validar);

  // ——— Validación genérica por campo ———
  function validar(e) {
    const input = e.target;
    const contenedor = input.parentElement;

    limpiaralerta(contenedor);

    // Vacío
    if (input.value.trim() === '') {
      mostrarAlerta(`El campo ${input.id} está vacío`, contenedor);
      return;
    }

    // Email
    if (input.id === 'email' && !validarEmail(input.value)) {
      mostrarAlerta('El email es inválido', contenedor);
      return;
    }

    // Teléfono (10 dígitos MX; permite espacios/guiones al escribir)
    if (input.id === 'telefono') {
      const d = normalizaTel(input.value);
      if (d.length !== 10) {
        mostrarAlerta('El teléfono debe tener 10 dígitos (México).', contenedor);
        return;
      }
    }

    // Fecha de nacimiento (obligatoria y no futura)
    if (input.id === 'fechaNac') {
      if (!input.value) {
        mostrarAlerta('La fecha de nacimiento es obligatoria.', contenedor);
        return;
      }
      if (esFechaFutura(input.value)) {
        mostrarAlerta('La fecha no puede ser futura.', contenedor);
        return;
      }
      const anio = new Date(input.value).getFullYear();
      if (anio < 1900) {
        mostrarAlerta('La fecha es inválida (año muy antiguo).', contenedor);
        return;
      }
    }
  }

  // ——— UI de errores ———
  function mostrarAlerta(mensaje, referencia){
    const alerta = referencia.querySelector('.error-msg');
    if (alerta) alerta.remove();

    const error = document.createElement('p');
    error.textContent = mensaje;
    error.classList.add('error-msg');
    referencia.appendChild(error);
  }

  function limpiaralerta(referencia){
    const alerta = referencia.querySelector('.error-msg');
    if (alerta) alerta.remove();
  }

  // ——— Helpers ———
  function validarEmail(email){
    const emailRegex = /^\w+([.\-_+]?\w+)*@\w+([.-]?\w+)*\.\w{2,10}$/;
    return emailRegex.test(email);
  }

  function normalizaTel(valor){
    let d = valor.replace(/\D/g, '');
    if (d.startsWith('52') && d.length === 12) d = d.slice(2); // quita 52
    return d;
  }

  function esFechaFutura(yyyyMmDd){
    const hoy = new Date().toISOString().slice(0,10);
    return yyyyMmDd > hoy;
  }
});
