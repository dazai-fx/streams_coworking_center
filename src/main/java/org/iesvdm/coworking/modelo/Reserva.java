package org.iesvdm.coworking.modelo;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Setter
@Entity
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Reserva {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    @Column(name = "reserva_id", nullable = false)
    private Long id;

    @ToString.Exclude
    @ManyToOne(optional = false)
    @JoinColumn(name = "miembro_id", nullable = false)
    private Miembro miembro;

    @ToString.Exclude
    @ManyToOne(optional = false)
    @JoinColumn(name = "sala_id", nullable = false)
    private Sala sala;

    private LocalDate fecha;

    private LocalTime horaInicio;

    private LocalTime horaFin;

    @ColumnDefault("'PENDIENTE'")
    private String estado;

    private Integer asistentes;

    private BigDecimal descuentoPct;

    @Lob
    @Column(name = "observaciones")
    private String observaciones;

    @ColumnDefault("round((time_to_sec(timediff(`hora_fin`, `hora_inicio`)) / 3600), 2)")
    @Column(name = "horas", precision = 6, scale = 2)
    private BigDecimal horas;

}