// pet.js — controla qué lista de razas se ve según la especie seleccionada
document.addEventListener('DOMContentLoaded', () => {
  const especieSel = document.getElementById('especie');

  function mostrarLista(especie){
    // Oculta todas y quita name para no enviar múltiples valores
    document.querySelectorAll('#contenedor-raza .raza').forEach(sel => {
      sel.classList.add('hidden');
      sel.removeAttribute('name');
    });

    // Muestra solo la de la especie actual y asegura name="raza"
    const activo = document.getElementById('raza-' + especie);
    if (activo){
      activo.classList.remove('hidden');
      activo.setAttribute('name','raza');
      if (!activo.value) activo.selectedIndex = 0;
    }
  }

  especieSel.addEventListener('change', e => mostrarLista(e.target.value));

  // Estado inicial (valor actual del select especie)
  mostrarLista(especieSel.value || 'perro');
});
