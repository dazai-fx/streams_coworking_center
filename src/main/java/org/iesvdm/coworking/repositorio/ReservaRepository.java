package org.iesvdm.coworking.repositorio;

import org.iesvdm.coworking.modelo.Reserva;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReservaRepository extends JpaRepository<Reserva, Long> {
}
