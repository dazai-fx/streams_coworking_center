package org.iesvdm.coworking;

import org.iesvdm.coworking.repositorio.MiembroRepository;
import org.iesvdm.coworking.repositorio.ReservaRepository;
import org.iesvdm.coworking.repositorio.SalaRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class CoworkingApplicationTests {

    @Autowired
    MiembroRepository miembroRepository;

    @Autowired
    ReservaRepository reservaRepository;

    @Autowired
    SalaRepository salaRepository;

    @Test
    void testMiembros() {

        miembroRepository.findAll().forEach(System.out::println);

    }

    @Test
    void testReservas() {

        reservaRepository.findAll().forEach(System.out::println);

    }

    @Test
    void testSalas() {

        salaRepository.findAll().forEach(System.out::println);

    }

    //1. Devuelve un listado de todas las reservas realizadas durante el año 2025, cuya sala tenga un precio_hora superior a 25€.
    // 2. Devuelve un listado de todos los miembros que NO han realizado ninguna reserva.
    // 3. Devuelve una lista de los id's, nombres y emails de los miembros que no tienen el teléfono registrado.
    // El listado tiene que estar ordenado inverso alfabéticamente por nombre (z..a).
    // 4. Devuelve un listado con los id's y emails de los miembros que se hayan registrado con una cuenta de yahoo.es
    // en el año 2024.
    // 5. Devuelve un listado de los miembros cuyo primer apellido es Martín. El listado tiene que estar ordenado
    // por fecha de alta en el coworking de más reciente a menos reciente y nombre y apellidos en orden alfabético.
    // 6. Devuelve el gasto total (estimado) que ha realizado la miembro Ana Beltrán en reservas del coworking.
    // 7. Devuelve el listado de las 3 salas de menor precio_hora.
    // 8. Devuelve la reserva a la que se le ha aplicado la mayor cuantía de descuento sobre el precio sin descuento
    // (precio_hora × horas).
    // 9. Devuelve los miembros que hayan tenido alguna reserva con estado 'ASISTIDA' y exactamente 10 asistentes.
    // 10. Devuelve el valor mínimo de horas reservadas (campo calculado 'horas') en una reserva.
    // 11. Devuelve un listado de las salas que empiecen por 'Sala' y terminen por 'o',
    // y también las salas que terminen por 'x'.
    // 12. Devuelve un listado que muestre todas las reservas y salas en las que se ha registrado cada miembro.
    // El resultado debe mostrar todos los datos del miembro primero junto con un sublistado de sus reservas y salas.
    // El listado debe mostrar los datos de los miembros ordenados alfabéticamente por nombre.
    // 13. Devuelve el total de personas que podrían alojarse simultáneamente en el centro en base al aforo de todas las salas.
    // 14. Calcula el número total de miembros (diferentes) que tienen alguna reserva.
    // 15. Devuelve el listado de las salas para las que se aplica un descuento porcentual (descuento_pct) superior al 10%
    // en alguna de sus reservas.
    // 16. Devuelve el nombre del miembro que pagó la reserva de mayor cuantía (precio_hora × horas aplicando el descuento).
    // 17. Devuelve los nombres de los miembros que hayan coincidido en alguna reserva con la miembro Ana Beltrán
    // (misma sala y fecha con solape horario).
    // 18. Devuelve el total de lo ingresado por el coworking en reservas para el mes de enero de 2025.
    // 19. Devuelve el conteo de cuántos miembros tienen la observación 'Requiere equipamiento especial' en alguna de sus reservas.
    // 20. Devuelve cuánto se ingresaría por la sala 'Auditorio Sol' si estuviera reservada durante todo su horario de apertura
    // en un día completo (sin descuentos).
}
