// pet.js
document.addEventListener('DOMContentLoaded', () => {
    console.log("conectada")
  const especieSel = document.getElementById('especie'); // nombre consistente

  // Mapeo especie → selects (tus IDs tal cual)
  const selects = {
    perro : document.getElementById('Perro'),
    gato  : document.getElementById('Gato'),
    reptil: document.getElementById('Reptil'),
    ave   : document.getElementById('Aves'),
  };

  // Mapeo especie → labels (opcional, para ocultar/mostrar etiqueta)
  const labels = {
    perro : document.querySelector('label[for="Perro"]'),
    gato  : document.querySelector('label[for="Gato"]'),
    reptil: document.querySelector('label[for="Reptil"]'),
    ave   : document.querySelector('label[for="Aves"]'),
  };

  function mostrarLista(especie){
    Object.keys(selects).forEach(key => {
      const sel = selects[key];
      const lab = labels[key];
      const activa = (key === especie);

      if (sel) {
        sel.classList.toggle('hidden', !activa); // <- classList (minúscula)
        sel.hidden = !activa;
        if (activa) sel.setAttribute('name','raza');
        else        sel.removeAttribute('name');
        if (activa && !sel.value) sel.selectedIndex = 0;
      }
      if (lab) lab.classList.toggle('hidden', !activa);
    });
  }

  especieSel.addEventListener('change', (e) => {
    mostrarLista(e.target.value);
  });

  // Estado inicial
  mostrarLista(especieSel.value || 'perro');
});
