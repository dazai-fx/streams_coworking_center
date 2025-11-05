package org.iesvdm.coworking.modelo;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.ColumnDefault;

import java.time.LocalDate;
import java.util.LinkedHashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Miembro {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    @Column(name = "miembro_id", nullable = false)
    private Long id;

    @Column(name = "nombre", nullable = false, length = 150)
    private String nombre;

    @Column(name = "email", nullable = false, length = 190)
    private String email;

    @Column(name = "telefono", length = 20)
    private String telefono;

    @Column(name = "empresa", length = 160)
    private String empresa;

    @ColumnDefault("'BASIC'")
    @Column(name = "plan", nullable = false, length = 10)
    private String plan;

    @Column(name = "fecha_alta", nullable = false)
    private LocalDate fechaAlta;

    @OneToMany(fetch = FetchType.EAGER)
    @JoinColumn(name = "miembro_id")
    private Set<Reserva> reservas = new LinkedHashSet<>();

}