package com.pizzeria.servicio;

import com.pizzeria.modelo.Pedido;
import com.pizzeria.modelo.Pizza;
import com.pizzeria.repositorio.PedidoRepository;
import com.pizzeria.repositorio.PizzaRepository;
import com.pizzeria.repositorio.ClienteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class PedidoService {

    private final PedidoRepository pedidoRepository;
    private final ClienteRepository clienteRepository;
    private final PizzaRepository pizzaRepository;

    public PedidoService(PedidoRepository pedidoRepository,
                         ClienteRepository clienteRepository,
                         PizzaRepository pizzaRepository) {
        this.pedidoRepository = pedidoRepository;
        this.clienteRepository = clienteRepository;
        this.pizzaRepository = pizzaRepository;
    }

    public List<Pedido> listarTodos() {
        return pedidoRepository.findAll();
    }

    public Optional<Pedido> buscarPorId(Long id) {
        return pedidoRepository.findById(id);
    }

    @Transactional
    public Pedido crear(Pedido pedido) {
        // Verificar que el cliente existe
        if (pedido.getCliente() != null && pedido.getCliente().getId() != null) {
            clienteRepository.findById(pedido.getCliente().getId())
                    .orElseThrow(() -> new RuntimeException(
                        "Cliente no encontrado con id: " + pedido.getCliente().getId()));
        }

        // Cargar pizzas completas (el JSON solo trae ids) y calcular total
        if (pedido.getPizzas() != null && !pedido.getPizzas().isEmpty()) {
            List<Pizza> pizzasCompletas = pedido.getPizzas().stream()
                    .map(p -> pizzaRepository.findById(p.getId())
                            .orElseThrow(() -> new RuntimeException(
                                "Pizza no encontrada con id: " + p.getId())))
                    .toList();
            pedido.setPizzas(pizzasCompletas);
            pedido.setTotal(pizzasCompletas.stream()
                    .mapToDouble(Pizza::getPrecio)
                    .sum());
        }

        return pedidoRepository.save(pedido);
    }

    @Transactional
    public void eliminar(Long id) {
        if (!pedidoRepository.existsById(id)) {
            throw new RuntimeException("Pedido no encontrado con id: " + id);
        }
        pedidoRepository.deleteById(id);
    }

    public List<Pedido> buscarPorCliente(Long clienteId) {
        return pedidoRepository.findByClienteId(clienteId);
    }

    public List<Pedido> buscarPedidosCaros(double minimo) {
        return pedidoRepository.findByTotalGreaterThan(minimo);
    }
}
