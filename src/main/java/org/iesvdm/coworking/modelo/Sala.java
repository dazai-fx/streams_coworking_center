package org.iesvdm.coworking.modelo;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

@Getter
@Setter
@Entity
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Sala {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    @Column(name = "sala_id", nullable = false)
    private Long id;


    private String nombre;


    private String ubicacion;


    private Integer aforo;


    private BigDecimal precioHora;


    private LocalTime apertura;


    private LocalTime cierre;

    @Column(name = "recursos")
    @JdbcTypeCode(SqlTypes.JSON)
    private Map<String, Object> recursos;

    @OneToMany(fetch = FetchType.EAGER)
    @JoinColumn(name = "sala_id")
    private Set<Reserva> reservas = new LinkedHashSet<>();

}