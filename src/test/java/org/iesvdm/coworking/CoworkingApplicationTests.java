package org.iesvdm.coworking;

import org.iesvdm.coworking.modelo.Miembro;
import org.iesvdm.coworking.modelo.Reserva;
import org.iesvdm.coworking.modelo.Sala;
import org.iesvdm.coworking.repositorio.MiembroRepository;
import org.iesvdm.coworking.repositorio.ReservaRepository;
import org.iesvdm.coworking.repositorio.SalaRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.Month;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

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

    @Test
    void testReservas2025PrecioAlto(){

        List<Reserva> reservas =  reservaRepository.findAll().stream()
                .filter(r -> r.getFecha().getYear() == 2025)
                .filter(r-> r.getSala().getPrecioHora()
                        .compareTo(BigDecimal.valueOf(25)) > 0)
                .toList();

        reservas.forEach(System.out::println);

    }

    // 2. Devuelve un listado de todos los miembros que NO han realizado ninguna reserva.

    @Test
    void testMiembrosNoTienenReservas(){

        var miembros = miembroRepository.findAll()
                .stream()
                .filter(m -> m.getReservas().isEmpty())
                .toList();

        miembros.forEach(System.out::println); // no hay miembros que no tengan reservas

    }

    // 3. Devuelve una lista de los id's, nombres y emails de los miembros que no tienen el teléfono registrado.
    // El listado tiene que estar ordenado inverso alfabéticamente por nombre (z..a).
    @Test
    void testMiembrosSinTelefono(){

        record MiembroDTO(Long id, String nombre, String email) {}

        // isBlank() es mejor que isEmpty() porque también detecta " ".

        var miembros = miembroRepository.findAll().stream()
                .filter(m -> m.getTelefono() == null || m.getTelefono().isBlank())
                .map(m -> new MiembroDTO(m.getId(), m.getNombre(), m.getEmail()))
                .sorted(Comparator.comparing(MiembroDTO::nombre).reversed())
                .toList();

        miembros.forEach(System.out::println);

    }

    // 4. Devuelve un listado con los id's y emails de los miembros que se hayan registrado con una cuenta de yahoo.es
    // en el año 2024.

    @Test
    void testMiembrosYahoo(){

        record MiembroDTO(Long id, String email) {};

        var miembros = miembroRepository.findAll().stream()
                .filter(m -> m.getEmail().endsWith("@yahoo.es"))
                .filter(m -> m.getFechaAlta().getYear() == 2024)
                .map(m -> new MiembroDTO(m.getId(), m.getEmail()))
                .toList();
        miembros.forEach(System.out::println); // no existen miembros con el correo de yahoo.es
    }

    // 5. Devuelve un listado de los miembros cuyo primer apellido es Martín. El listado tiene que estar ordenado
    // por fecha de alta en el coworking de más reciente a menos reciente y nombre y apellidos en orden alfabético.

    @Test
    void testMiembrosMartin() {
        var miembros = miembroRepository.findAll().stream()
                // Filtramos: dividimos por espacio y comprobamos que la segunda parte sea "Martín"
                .filter(m -> {
                    String[] partes = m.getNombre().split(" ");
                    return partes.length == 2 && partes[1].equalsIgnoreCase("Martín");
                })
                // Ordenamos según el enunciado
                .sorted(Comparator
                        .comparing(Miembro::getFechaAlta).reversed()
                        .thenComparing(Miembro::getNombre))
                .toList();

        miembros.forEach(System.out::println);
    }

    // 6. Devuelve el gasto total (estimado) que ha realizado la miembro Ana Beltrán en reservas del coworking.

    @Test
    void TestReservaAna(){

        BigDecimal gastoTotal = reservaRepository.findAll().stream()
                .filter(r -> "Ana Beltrán".equals(r.getMiembro().getNombre()))
                .map(r -> {

                    BigDecimal descuento = Optional.ofNullable(r.getDescuentoPct())
                            .orElse(BigDecimal.ZERO);

                    BigDecimal factor = BigDecimal.ONE.subtract(
                            descuento.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP)
                    );

                    return r.getSala().getPrecioHora()
                            .multiply(r.getHoras())
                            .multiply(factor);
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        System.out.println(gastoTotal);

    }



    // 7. Devuelve el listado de las 3 salas de menor precio_hora.

    @Test
    void testSalasTop3menorPrecioHora(){

        var salas = salaRepository.findAll().stream()
                .sorted(Comparator.comparing(Sala::getPrecioHora))
                .limit(3)
                .toList();

        salas.forEach(System.out::println);

    }

    // 8. Devuelve la reserva a la que se le ha aplicado la mayor cuantía de descuento sobre el precio sin descuento
    // (precio_hora × horas).

    @Test
    void testReservaMayorDescuento(){
        Reserva reservaMayorDescuento = reservaRepository.findAll().stream()
                .max(Comparator.comparing(r -> {
                    BigDecimal precio = r.getSala().getPrecioHora();
                    BigDecimal horas = r.getHoras();
                    BigDecimal descuento = r.getDescuentoPct() == null ? BigDecimal.ZERO : r.getDescuentoPct();
                    return precio.multiply(horas).multiply(descuento).divide(BigDecimal.valueOf(100));
                }))
                .orElse(null);

        System.out.println(reservaMayorDescuento);

    }

    // 9. Devuelve los miembros que hayan tenido alguna reserva con estado 'ASISTIDA' y exactamente 10 asistentes.

    @Test
    void testMiembrosSinASISTIDAY10Asis(){

        var miembros = reservaRepository.findAll().stream()
                .filter(r -> "ASISTIDA".equals(r.getEstado()))
                .filter(r -> r.getAsistentes() != null && r.getAsistentes() == 10)
                .map(Reserva::getMiembro)
                .distinct()
                .toList();

        miembros.forEach(System.out::println);

    }

    // 10. Devuelve el valor mínimo de horas reservadas (campo calculado 'horas') en una reserva.

    @Test
    void testValorMinimoHorasReservadas(){
        BigDecimal minHoras = reservaRepository.findAll().stream()
                .map(Reserva::getHoras)
                .min(Comparator.naturalOrder())
                .orElse(BigDecimal.ZERO);
        System.out.println(minHoras);
    }

    // 11. Devuelve un listado de las salas que empiecen por 'Sala' y terminen por 'o', y también las salas que terminen por 'x'.

    @Test
    void testSalasEmpiecenSalaOTerminenporOoX(){

        var salas = salaRepository.findAll().stream()
                .filter(s -> s.getNombre().startsWith("Sala") &&
                        s.getNombre().endsWith("o")
                        || s.getNombre().endsWith("x"))
                .toList();

        salas.forEach(System.out::println);

    }

    // 12. Devuelve un listado que muestre todas las reservas y salas en las que se ha registrado cada miembro.
    // El resultado debe mostrar todos los datos del miembro primero junto con un sublistado de sus reservas y salas.
    // El listado debe mostrar los datos de los miembros ordenados alfabéticamente por nombre.

    @Test
    void testListadoSalas(){

        List<Miembro> miembros = miembroRepository.findAll().stream()
                .sorted(Comparator.comparing(Miembro::getNombre))
                .toList();

        miembros.forEach(miembro -> {
            System.out.println("Miembro: " + miembro.getNombre() +
                    ", Email: " + miembro.getEmail() +
                    ", Teléfono: " + miembro.getTelefono() +
                    ", Empresa: " + miembro.getEmpresa() +
                    ", Plan: " + miembro.getPlan() +
                    ", Fecha Alta: " + miembro.getFechaAlta());

            miembro.getReservas().stream()
                    .sorted(Comparator.comparing(Reserva::getFecha)
                            .thenComparing(Reserva::getHoraInicio))
                    .forEach(reserva -> System.out.println(
                            "  Reserva ID: " + reserva.getId() +
                                    ", Fecha: " + reserva.getFecha() +
                                    ", Hora Inicio: " + reserva.getHoraInicio() +
                                    ", Hora Fin: " + reserva.getHoraFin() +
                                    ", Horas: " + reserva.getHoras() +
                                    ", Estado: " + reserva.getEstado() +
                                    ", Asistentes: " + reserva.getAsistentes() +
                                    ", Descuento: " + reserva.getDescuentoPct() +
                                    ", Observaciones: " + reserva.getObservaciones() +
                                    ", Sala: " + reserva.getSala().getNombre() +
                                    ", Ubicación: " + reserva.getSala().getUbicacion() +
                                    ", Aforo: " + reserva.getSala().getAforo() +
                                    ", Precio Hora: " + reserva.getSala().getPrecioHora()
                    ));
            System.out.println(); // salto de línea entre miembros
        });

    }

    // 13. Devuelve el total de personas que podrían alojarse simultáneamente en el centro en base al aforo de todas las salas.

    @Test
    void TestTotalPersonasAlojadasEnElCentro(){
        int totalPersonas = salaRepository.findAll().stream()
                .mapToInt(Sala::getAforo)
                .sum();

        System.out.println("Total personas posibles simultáneamente: " + totalPersonas);
    }

    // 14. Calcula el número total de miembros (diferentes) que tienen alguna reserva.

    @Test
    void testTotalMiembrosConReservas(){
        long totalMiembrosConReserva = reservaRepository.findAll().stream()
                .map(reserva -> reserva.getMiembro().getId())
                .distinct()
                .count();

        System.out.println("Total de miembros con al menos una reserva: " + totalMiembrosConReserva);
    }

    // 15. Devuelve el listado de las salas para las que se aplica un descuento porcentual (descuento_pct) superior al 10%
    // en alguna de sus reservas.

    @Test
    void testListadoSalasDescuentoSuperior10(){

        List<Sala> salasConDescuento = salaRepository.findAll().stream()
                .filter(sala -> sala.getReservas().stream()
                        .anyMatch(reserva -> reserva.getDescuentoPct() != null &&
                                reserva.getDescuentoPct().compareTo(BigDecimal.valueOf(10)) > 0))
                .toList();

        salasConDescuento.forEach(sala -> System.out.println(
                "Sala: " + sala.getNombre() +
                        ", Precio Hora: " + sala.getPrecioHora() +
                        ", Aforo: " + sala.getAforo()
        ));

    }

    // 16. Devuelve el nombre del miembro que pagó la reserva de mayor cuantía (precio_hora × horas aplicando el descuento).

    // Método auxiliar para calcular el importe de una reserva
    private BigDecimal calcularImporte(Reserva r) {
        BigDecimal precio = r.getSala().getPrecioHora();
        BigDecimal horas = r.getHoras();
        BigDecimal descuento = r.getDescuentoPct() == null ? BigDecimal.ZERO : r.getDescuentoPct();
        BigDecimal factor = BigDecimal.ONE.subtract(descuento.divide(BigDecimal.valueOf(100)));
        return precio.multiply(horas).multiply(factor);
    }

    @Test
    void testMiembroQuePagoLaReservaMayor(){
        Optional<Miembro> miembroMayorPago = reservaRepository.findAll().stream()
                .max((r1, r2) -> {
                    BigDecimal importe1 = calcularImporte(r1);
                    BigDecimal importe2 = calcularImporte(r2);
                    return importe1.compareTo(importe2);
                })
                .map(Reserva::getMiembro);

        miembroMayorPago.ifPresent(m -> System.out.println("Miembro que pagó más: " + m.getNombre()));
    }


    // 17. Devuelve los nombres de los miembros que hayan coincidido en alguna reserva con la miembro Ana Beltrán
    // (misma sala y fecha con solape horario).

    @Test
    void testMiembrosQueHayanCoincididoEnAlgunaReservaConAnaBeltran(){

        List<Reserva> todasReservas = reservaRepository.findAll();

        List<Reserva> reservasAna = todasReservas.stream()
                .filter(r -> r.getMiembro().getNombre().equals("Ana Beltrán"))
                .toList();

        Set<Miembro> miembrosCoincidentes = todasReservas.stream()
                .filter(r -> !r.getMiembro().getNombre().equals("Ana Beltrán"))
                .filter(r -> reservasAna.stream().anyMatch(ra ->
                        ra.getSala().getId().equals(r.getSala().getId()) &&
                                ra.getFecha().equals(r.getFecha()) &&
                                ra.getHoraInicio().isBefore(r.getHoraFin()) &&
                                ra.getHoraFin().isAfter(r.getHoraInicio())
                ))
                .map(Reserva::getMiembro)
                .collect(Collectors.toSet());

        miembrosCoincidentes.forEach(m -> System.out.println(m.getNombre()));

    }

    // 18. Devuelve el total de lo ingresado por el coworking en reservas para el mes de enero de 2025.

    @Test
    void testTotalIngresadoEnReservasEnEnero2025(){

        BigDecimal totalIngresos = reservaRepository.findAll().stream()
                .filter(r -> r.getFecha().getYear() == 2025 && r.getFecha().getMonth() == Month.JANUARY)
                .map(r -> {
                    BigDecimal precio = r.getSala().getPrecioHora();
                    BigDecimal horas = r.getHoras();
                    BigDecimal descuento = r.getDescuentoPct() == null ? BigDecimal.ZERO : r.getDescuentoPct();
                    BigDecimal factor = BigDecimal.ONE.subtract(descuento.divide(BigDecimal.valueOf(100)));
                    return precio.multiply(horas).multiply(factor);
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        System.out.println("Total ingresos enero 2025: " + totalIngresos);

    }

    // 19. Devuelve el conteo de cuántos miembros tienen la observación 'Requiere equipamiento especial' en alguna de sus reservas.

    @Test
    void testConteoNumMiembrosRequiereEquipamientoEspecial(){

        long miembrosConObservacion = reservaRepository.findAll().stream()
                .filter(r -> "Requiere equipamiento especial".equals(r.getObservaciones()))
                .map(r -> r.getMiembro().getId()) // usamos ID para contar distintos
                .distinct()
                .count();

        System.out.println("Miembros con observación: " + miembrosConObservacion);

    }

    // 20. Devuelve cuánto se ingresaría por la sala 'Auditorio Sol' si estuviera reservada durante todo su horario de apertura
    // en un día completo (sin descuentos).

    @Test
    void testCuantoIngresariaLaSalaAuditorioSolSiSeReservaUnDiaCompleto(){

        Sala auditorioSol = salaRepository.findAll().stream()
                .filter(s -> "Auditorio Sol".equals(s.getNombre()))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Sala no encontrada"));


        BigDecimal horas = BigDecimal.valueOf(
                Duration.between(auditorioSol.getApertura(), auditorioSol.getCierre()).toMinutes() / 60.0
        );


        BigDecimal ingresoTotal = auditorioSol.getPrecioHora().multiply(horas);

        System.out.println("Ingreso potencial diario de 'Auditorio Sol': " + ingresoTotal + " €");

    }

}
