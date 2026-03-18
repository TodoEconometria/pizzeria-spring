package com.pizzeria.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "clientes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre del cliente es obligatorio")
    @Size(min = 2, max = 150, message = "El nombre debe tener entre 2 y 150 caracteres")
    @Column(nullable = false)
    private String nombre;

    @NotNull(message = "La categoria del cliente es obligatoria")
    @Enumerated(EnumType.STRING)
    private CategoriaCliente categoriaCliente;

    @NotNull(message = "El tipo de cliente es obligatorio")
    @Enumerated(EnumType.STRING)
    private TipoCliente tipoCliente;
}
