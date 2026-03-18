package com.pizzeria.servicio;

import com.pizzeria.modelo.Cliente;
import com.pizzeria.modelo.CategoriaCliente;
import com.pizzeria.modelo.TipoCliente;
import com.pizzeria.repositorio.ClienteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class ClienteService {

    private final ClienteRepository clienteRepository;

    public ClienteService(ClienteRepository clienteRepository) {
        this.clienteRepository = clienteRepository;
    }

    public List<Cliente> listarTodos() {
        return clienteRepository.findAll();
    }

    public Optional<Cliente> buscarPorId(Long id) {
        return clienteRepository.findById(id);
    }

    @Transactional
    public Cliente crear(Cliente cliente) {
        return clienteRepository.save(cliente);
    }

    @Transactional
    public Cliente actualizar(Long id, Cliente datosNuevos) {
        Cliente existente = clienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException(
                    "Cliente no encontrado con id: " + id));

        existente.setNombre(datosNuevos.getNombre());
        existente.setCategoriaCliente(datosNuevos.getCategoriaCliente());
        existente.setTipoCliente(datosNuevos.getTipoCliente());

        return clienteRepository.save(existente);
    }

    @Transactional
    public void eliminar(Long id) {
        if (!clienteRepository.existsById(id)) {
            throw new RuntimeException("Cliente no encontrado con id: " + id);
        }
        clienteRepository.deleteById(id);
    }

    public List<Cliente> buscarPorTipo(TipoCliente tipo) {
        return clienteRepository.findByTipoCliente(tipo);
    }

    public List<Cliente> buscarPorCategoria(CategoriaCliente categoria) {
        return clienteRepository.findByCategoriaCliente(categoria);
    }

    public List<Cliente> buscarPorNombre(String nombre) {
        return clienteRepository.findByNombreContainingIgnoreCase(nombre);
    }
}
