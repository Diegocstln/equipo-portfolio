// pet.js — controla qué lista de razas se ve según la especie seleccionada
document.addEventListener('DOMContentLoaded', () => {
  const especieSel = document.getElementById('especie');

  function mostrarLista(especie) {
    // Oculta todos los selects de raza
    document.querySelectorAll('#contenedor-raza .raza').forEach(sel => {
      sel.classList.add('hidden');
      
      // También deshabilita el select interno
      const select = sel.querySelector('select');
      if (select) select.disabled = true;
    });
    document.querySelectorAll('#contenedor-patron .patron').forEach(sel => {
      sel.classList.add('hidden');
      
      // También deshabilita el select interno
      const select = sel.querySelector('select');
      if (select) select.disabled = true;
    });

    

    // Normaliza el nombre de la especie para los IDs
    let especieId = especie.toLowerCase();
    if (especieId === 'perro') especieId = 'perro';
    else if (especieId === 'gato') especieId = 'gato';
    else if (especieId === 'reptil') especieId = 'reptil';
    else if (especieId === 'ave') especieId = 'ave';

    // Muestra solo el select correspondiente
    const activoRaza = document.getElementById('raza-' + especieId);
    if (activoRaza) {
      activoRaza.classList.remove('hidden');
      const select = activoRaza.querySelector('select');
      if (select) {
        select.disabled = false;
        select.selectedIndex = 0;
      }
    }
        // Muestra solo el select correspondiente
    const activoPatron= document.getElementById('patron-' + especieId);
    if (activoPatron) {
      activoPatron.classList.remove('hidden');
      const select = activoPatron.querySelector('select');
      if (select) {
        select.disabled = false;
        select.selectedIndex = 0;
      }
    }

  }

  especieSel.addEventListener('change', e => mostrarLista(e.target.value));

  // Estado inicial
  mostrarLista(especieSel.value || 'perro');
});


document.getElementById('btn-siguiente').addEventListener('click', function() {
  const especie = document.getElementById('especie').value;
  localStorage.setItem('especieSeleccionada', especie);
  window.location.href = 'register-pet2.html';
});
