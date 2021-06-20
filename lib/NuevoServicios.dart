import 'package:examenflutterjhonnysota/ServiceObject.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;
import 'dart:convert';

class NuevoServicio extends StatefulWidget {
  String titulo;
  ServiceObject oServicio = ServiceObject();
  int codigoClienteSeleccionado = 0;
  String urlGeneral = "http://wscibertec2021.somee.com";
  String urlController = "/Servicio";
  String urlLiestarkey = "/ListarKey?pCodigoServicio=1";
  String urlRegistroModificado = "/RegistraModifica?";

  String mensaje = "";
  bool validacion = false;
  NuevoServicio(this.titulo, this.codigoClienteSeleccionado);

  @override
  _NuevoServicio createState() => _NuevoServicio();
}

class _NuevoServicio extends State<NuevoServicio> {
  final _tfNombreCliente = TextEditingController();
  final _tfNroOrden = TextEditingController();
  final _tfFecha = TextEditingController();
  final _tfLinea = TextEditingController();
  final _tfEstado = TextEditingController();
  final _tfObservacion = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.oServicio.inicializar();
    if (widget.codigoClienteSeleccionado > 0) {
      _listarKey();
    }
  }

  Future<String> _listarKey() async {
    String urlListaClientes = widget.urlGeneral +
        widget.urlController +
        widget.urlLiestarkey +
        widget.codigoClienteSeleccionado.toString();

    var respuesta = await http.get(Uri.parse(urlListaClientes));
    setState(() {
      widget.oServicio = ServiceObject.fromJson(json.decode(respuesta.body));
      if (widget.oServicio.CodigoServicio > 0) {
        widget.mensaje = "Estas Actualizando los datos";
        _mostrarDatos();
      }
      print(widget.oServicio);
    });
    return "proceso";
  }

  void _mostrarDatos() {
    _tfNombreCliente.text = widget.oServicio.NombreCliente;
    _tfNroOrden.text = widget.oServicio.NumeroOrdenServicio;
    _tfFecha.text = widget.oServicio.FechaProgramada;
    _tfLinea.text = widget.oServicio.Linea;
    _tfEstado.text = widget.oServicio.Estado;
    _tfObservacion.text = widget.oServicio.Observaciones;
  }

  bool _validationRegister() {
    if (_tfNombreCliente.text.toString() == "" ||
        _tfNroOrden.text.toString() == "") {
      widget.validacion = false;
      setState(() {
        widget.mensaje = "Falta  completar  los campos  obligatorios";
      });
      return false;
    }
    return true;
  }

  void _grabarRegistro() {
    if (_validationRegister()) {
      _ejecutarServicioGrabado();
    }
  }

  Future<String> _ejecutarServicioGrabado() async {
    String accion = "N";
    if (widget.oServicio.CodigoServicio > 0) {
      accion = "A";
    }

    String strParametros = "";
    strParametros += "Accion=" + accion;
    strParametros +=
        "&CodigoServicio=" + widget.oServicio.CodigoServicio.toString();
    strParametros += "&NombreCliente=" + _tfNombreCliente.text;
    strParametros += "&NumeroOrdenServicio=" + _tfNroOrden.text;
    strParametros += "&Fechaprogramada=" + _tfFecha.text;
    strParametros += "&Linea=" + _tfLinea.text;
    strParametros += "&Estado=" + _tfEstado.text;
    strParametros += "&Observaciones=" + _tfObservacion.text;

    String urlRegistroClientes = "";
    urlRegistroClientes = widget.urlGeneral +
        widget.urlController +
        widget.urlRegistroModificado +
        strParametros;

    var respuesta = await http.get(Uri.parse(urlRegistroClientes));
    var data = respuesta.body;
    setState(() {
      widget.oServicio = ServiceObject.fromJson(json.decode(data));
      if (widget.oServicio.CodigoServicio > 0) {
        widget.mensaje = "Grabado Correcto";
      }
      print(widget.oServicio);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro Servicio " + widget.titulo),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text(" Código  de cliente: " +
                widget.oServicio.CodigoServicio.toString()),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Column(
              children: <Widget>[
                TextField(
                    controller: _tfNombreCliente,
                    decoration: InputDecoration(
                      hintText: "Ingrese  la nombre cliente",
                      labelText: "Nombre Cliente",
                      errorText: _tfNombreCliente.text.toString() == ""
                          ? "falta ingresar el nombre"
                          : null,
                    )),
                TextField(
                    controller: _tfNroOrden,
                    decoration: InputDecoration(
                      hintText: "Numero Orden",
                      labelText: "Numero Orden",
                      errorText: _tfNroOrden.text.toString() == ""
                          ? "falta ingresar el N°Orden"
                          : null,
                    )),
                TextField(
                    controller: _tfFecha,
                    decoration: InputDecoration(
                      hintText: "Fecha",
                      labelText: "Fecha",
                      errorText: _tfFecha.text.toString() == ""
                          ? "falta la fecha"
                          : null,
                    )),
                TextField(
                    controller: _tfLinea,
                    decoration: InputDecoration(
                      hintText: "Linea",
                      labelText: "Linea",
                      errorText: _tfLinea.text.toString() == ""
                          ? "falta ingresar la linea"
                          : null,
                    )),
                TextField(
                    controller: _tfEstado,
                    decoration: InputDecoration(
                      hintText: "Estado",
                      labelText: "Estado",
                      errorText: _tfEstado.text.toString() == ""
                          ? "falta ingresar El estado"
                          : null,
                    )),
                TextField(
                    controller: _tfObservacion,
                    decoration: InputDecoration(
                      hintText: "Observacion",
                      labelText: "Observacion",
                      errorText: _tfObservacion.text.toString() == ""
                          ? "falta ingresar la Observación"
                          : null,
                    )),
                RaisedButton(
                  color: Colors.greenAccent,
                  child: Text(
                    "Grabar",
                    style: TextStyle(fontSize: 18, fontFamily: "rbold"),
                  ),
                  onPressed: _grabarRegistro,
                ),
                Text("Mensaje" + widget.mensaje),
              ],
            ),
          )
        ],
      ),
    );
  }
}
