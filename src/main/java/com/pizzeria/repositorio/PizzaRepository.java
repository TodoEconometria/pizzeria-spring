package com.pizzeria.repositorio;

import com.pizzeria.modelo.Categoria;
import com.pizzeria.modelo.Pizza;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PizzaRepository extends JpaRepository<Pizza, Long> {

    // Spring genera el SQL: SELECT * FROM pizzas WHERE categoria = ?
    List<Pizza> findByCategoria(Categoria categoria);

    // SELECT * FROM pizzas WHERE precio < ?
    List<Pizza> findByPrecioLessThan(double precio);

    // SELECT * FROM pizzas WHERE LOWER(nombre) LIKE LOWER('%?%')
    List<Pizza> findByNombreContainingIgnoreCase(String nombre);
}
