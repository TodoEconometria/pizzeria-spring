package com.pizzeria.repositorio;

import com.pizzeria.modelo.Cliente;
import com.pizzeria.modelo.CategoriaCliente;
import com.pizzeria.modelo.TipoCliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Long> {

    List<Cliente> findByTipoCliente(TipoCliente tipoCliente);

    List<Cliente> findByCategoriaCliente(CategoriaCliente categoriaCliente);

    List<Cliente> findByNombreContainingIgnoreCase(String nombre);
}
