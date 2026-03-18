package com.pizzeria.controlador;

import com.pizzeria.modelo.Categoria;
import com.pizzeria.modelo.Pizza;
import com.pizzeria.servicio.PizzaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pizzas")
@Tag(name = "Pizzas", description = "CRUD y busquedas de pizzas")
public class PizzaController {

    private final PizzaService pizzaService;

    public PizzaController(PizzaService pizzaService) {
        this.pizzaService = pizzaService;
    }

    @Operation(summary = "Listar todas las pizzas")
    @GetMapping
    public List<Pizza> listarTodas() {
        return pizzaService.listarTodas();
    }

    @Operation(summary = "Buscar pizza por ID")
    @GetMapping("/{id}")
    public ResponseEntity<Pizza> buscarPorId(@PathVariable Long id) {
        return pizzaService.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Crear una pizza nueva")
    @PostMapping
    public ResponseEntity<Pizza> crear(@Valid @RequestBody Pizza pizza) {
        Pizza nueva = pizzaService.crear(pizza);
        return ResponseEntity.status(HttpStatus.CREATED).body(nueva);
    }

    @Operation(summary = "Actualizar una pizza existente")
    @PutMapping("/{id}")
    public ResponseEntity<Pizza> actualizar(
            @PathVariable Long id, @Valid @RequestBody Pizza pizza) {
        try {
            Pizza actualizada = pizzaService.actualizar(id, pizza);
            return ResponseEntity.ok(actualizada);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(summary = "Eliminar una pizza por ID")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> eliminar(@PathVariable Long id) {
        try {
            pizzaService.eliminar(id);
            return ResponseEntity.noContent().build();
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("No se puede eliminar: la pizza tiene pedidos asociados");
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(summary = "Buscar pizzas por categoria (CLASICA, PREMIUM, VEGANA, INFANTIL)")
    @GetMapping("/categoria/{categoria}")
    public List<Pizza> buscarPorCategoria(
            @PathVariable Categoria categoria) {
        return pizzaService.buscarPorCategoria(categoria);
    }

    @Operation(summary = "Buscar pizzas mas baratas que un precio maximo")
    @GetMapping("/baratas")
    public List<Pizza> buscarBaratas(@RequestParam double precioMax) {
        return pizzaService.buscarBaratas(precioMax);
    }
}
