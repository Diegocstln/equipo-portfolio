document.addEventListener('DOMContentLoaded',function(){
    //seleccionar los elementos del form

    const nombre = document.querySelector('#nombre');

    const apellidoP = document.querySelector('#apellidoP');

    const apellidoM = document.querySelector('#apellidoM');

    const email = document.querySelector('#email');

    const telefono = document.querySelector('#telefono');

    const fecha = document.querySelector('#fechaNac');

    nombre.addEventListener('blur', validar)
    apellidoP.addEventListener('blur', validar)
    apellidoM.addEventListener('blur', validar)


    function validar (e){
        console.log(e.target.parentElement)

        if(e.target.value.trim() === ''){
            mostrarAlerta(`El campo ${e.target.id} esta vacio`, e.target.parentElement);
            return;

        }
        limpiaralerta(e.target.parentElement)
            
        
    }
    function mostrarAlerta(nombre,referencia){
        const alerta = referencia.querySelector('.error-msg')
        if (alerta){
            alerta.remove();
        }
        const error = document.createElement('P')
        error.textContent = nombre
        error.classList.add('error-msg');

        referencia.appendChild(error);

    }


    function limpiaralerta(referencia){
        //console.log("limpiar alerta")
         const alerta = referencia.querySelector('.error-msg')
        if (alerta){
            alerta.remove();
        }
    }

    //console.log({nombre, apellidoM, apellidoP, email, telefono, fecha});

})