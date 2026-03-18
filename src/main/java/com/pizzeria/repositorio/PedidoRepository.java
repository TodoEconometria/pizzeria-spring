package com.pizzeria.repositorio;

import com.pizzeria.modelo.Pedido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PedidoRepository extends JpaRepository<Pedido, Long> {

    // Spring navega la relacion: Pedido -> cliente -> id
    List<Pedido> findByClienteId(Long clienteId);

    List<Pedido> findByTotalGreaterThan(double total);
}
