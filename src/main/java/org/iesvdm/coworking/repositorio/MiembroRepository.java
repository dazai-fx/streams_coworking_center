package org.iesvdm.coworking.repositorio;

import org.iesvdm.coworking.modelo.Miembro;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MiembroRepository extends JpaRepository<Miembro, Long> {
}
