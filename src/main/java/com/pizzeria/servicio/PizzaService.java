package com.pizzeria.servicio;

import com.pizzeria.modelo.Categoria;
import com.pizzeria.modelo.Pizza;
import com.pizzeria.repositorio.PizzaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class PizzaService {

    private final PizzaRepository pizzaRepository;

    // Spring inyecta el repositorio automaticamente (constructor injection)
    public PizzaService(PizzaRepository pizzaRepository) {
        this.pizzaRepository = pizzaRepository;
    }

    public List<Pizza> listarTodas() {
        return pizzaRepository.findAll();
    }

    public Optional<Pizza> buscarPorId(Long id) {
        return pizzaRepository.findById(id);
    }

    @Transactional
    public Pizza crear(Pizza pizza) {
        return pizzaRepository.save(pizza);
    }

    @Transactional
    public Pizza actualizar(Long id, Pizza datosNuevos) {
        Pizza existente = pizzaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException(
                    "Pizza no encontrada con id: " + id));

        existente.setNombre(datosNuevos.getNombre());
        existente.setPrecio(datosNuevos.getPrecio());
        existente.setCategoria(datosNuevos.getCategoria());

        return pizzaRepository.save(existente);
    }

    @Transactional
    public void eliminar(Long id) {
        if (!pizzaRepository.existsById(id)) {
            throw new RuntimeException("Pizza no encontrada con id: " + id);
        }
        pizzaRepository.deleteById(id);
    }

    public List<Pizza> buscarPorCategoria(Categoria categoria) {
        return pizzaRepository.findByCategoria(categoria);
    }

    public List<Pizza> buscarBaratas(double precioMax) {
        return pizzaRepository.findByPrecioLessThan(precioMax);
    }
}
