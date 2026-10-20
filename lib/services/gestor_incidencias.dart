import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;
  int cantidadEnProceso = 0;
  int cantidadResuelta = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;

    cantidadEnProceso =
        incidencias.where((x) => x.estado == 'En Proceso').length;

    cantidadResuelta = incidencias.where((x) => x.estado == 'Resuelta').length;
  }

  //19/10/2026: funcion "busqueda" modificado para incluir los filtros
  List<Incidencia> buscar(String texto, String prioridad, String estado) {
    List<Incidencia> listaFiltrada = incidencias;
    
    //Busqueda por nombre
    if (texto.trim().isNotEmpty) {
      listaFiltrada = listaFiltrada
          .where((x) => x.titulo.toLowerCase().contains(texto.toLowerCase()))
          .toList();
    }

    //Filtro de prioridad
    if (prioridad.trim().isNotEmpty){
        listaFiltrada = listaFiltrada
          .where((x) => x.prioridad.contains(prioridad))
          .toList();
    }

    //Filtro de estado
    if (estado.isNotEmpty){
        listaFiltrada = listaFiltrada
          .where((x) => x.estado.contains(estado))
          .toList();
    }

    //Retorna filtro acumulado
    return listaFiltrada;
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        break;
      }
    }

    await datos.guardar(incidencias);
  }

  //16/10/2026
  Future<void> cambiarPrioridad(String id, String prioridad) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].prioridad = prioridad;
        break;
      }
    }

    await datos.guardar(incidencias);
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria, String prioridad) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      prioridad: prioridad,
      fecha: DateTime.now().toIso8601String().split('T').first,
    );
    incidencias.insert(0, nuevo);
    cantidadPendientes++;
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
