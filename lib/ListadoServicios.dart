import 'dart:ui';

import 'package:examenflutterjhonnysota/serviceObject.dart';
import 'package:flutter/material.dart';
import 'package:examenflutterjhonnysota/NuevoServicios.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;
import 'dart:convert';
import 'package:json_table/json_table.dart';

class ListadoServicios extends StatefulWidget {
  List<ServiceObject> oListServicio = [];
  int codigoClienteSeleccionado = 0;
  String urlGeneral = "http://wscibertec2021.somee.com";
  String urlController = "/Servicio";
  String urlRegistroModificado =
      "/RegistraModifica?Accion=N&CodigoServicio=0&NombreCliente=UNMA2Q%20S.A.&NumeroOrdenServicio=ORD-2016-001&Fechaprogramada=20161104&Linea=KING%20OCEAN%20SERVICES&Estado=Aprobado&Observaciones=Ninguno";
  String urlListadoNombre = '/Listar?NombreCliente=';
  String urlListadoCodigo = '&NumeroOrdenServicio=';
  String jsonCliente =
      '[{"CodigoServicio":0,"NombreCliente":"","NumeroOrdenServicio": "","FechaProgramada": "","Linea": "","Estado": "","Observaciones": "","Eliminado": false,"CodigoError": 0,"DescripcionError": "","MensajeError": null}]';
  String titulo;
  ListadoServicios(this.titulo);

  @override
  _ListadoServicios createState() => _ListadoServicios();
}

class _ListadoServicios extends State<ListadoServicios> {
  final _tfNombreCliente = TextEditingController();
  final _tfCodigOrden = TextEditingController();
  bool toggle = true;

  @override
  void initState() {
    super.initState();
  }

  void _nuevoServicio() async {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext pContext) {
      return new NuevoServicio("Nuevo Registro de Cliente", 0);
    }));
  }

  void _verRegistroServicio() async {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext pContexto) {
      return new NuevoServicio(
          "Modificar Cliente", widget.codigoClienteSeleccionado);
    }));
  }

  Future<String> _consultarCliente() async {
    print("Iniciando");
    String urlListarServicios = "";
    urlListarServicios = widget.urlGeneral +
        widget.urlController +
        widget.urlListadoNombre +
        _tfNombreCliente.text.toString() +
        widget.urlListadoCodigo +
        _tfCodigOrden.text.toString();

    var respuesta = await http.get(Uri.parse(urlListarServicios));
    print(respuesta.body);

    var data = respuesta.body;
    var oListaServiciotmp = List<ServiceObject>.from(
        json.decode(data).map((x) => ServiceObject.fromJson(x)));

    for (ServiceObject oServiceObject in oListaServiciotmp) {
      print("Nombre" + oServiceObject.NombreCliente);
    }
    setState(() {
      widget.oListServicio = oListaServiciotmp;
      widget.jsonCliente = data;
    });
    return 'procesado';
  }

  @override
  Widget build(BuildContext context) {
    var json = jsonDecode(widget.jsonCliente);
    print("Ejecutando");
    return Scaffold(
        appBar: AppBar(
          title: Text("Consulta de Servicio" + widget.titulo),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Container(
            child: toggle
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextField(
                          controller: _tfNombreCliente,
                          decoration: InputDecoration(
                            hintText: "Ingrese el nombre del cliente",
                            labelText: "Cliente",
                          )),
                      TextField(
                          controller: _tfCodigOrden,
                          decoration: InputDecoration(
                            hintText: "Ingrese el codigo de orden",
                            labelText: "Cdigo Orden",
                          )),
                      Text("Se Encontro " +
                          widget.oListServicio.length.toString() +
                          " Clientes"),
                      new Table(children: [
                        TableRow(children: [
                          Container(
                            padding: EdgeInsets.only(right: 10.0),
                            child: RaisedButton(
                              color: Colors.greenAccent,
                              child: Text(
                                "Consultar",
                                style: TextStyle(
                                    fontSize: 10, fontFamily: "rbold"),
                              ),
                              onPressed: _consultarCliente,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 10.0),
                            child: RaisedButton(
                              color: Colors.greenAccent,
                              child: Text(
                                "Nuevo",
                                style: TextStyle(
                                    fontSize: 10, fontFamily: "rbold"),
                              ),
                              onPressed: _nuevoServicio,
                            ),
                          )
                        ])
                      ]),
                      JsonTable(
                        json,
                        showColumnToggle: true,
                        allowRowHighlight: true,
                        rowHighlightColor: Colors.yellow[500].withOpacity(0.7),
                        paginationRowCount: 10,
                        onRowSelect: (index, map) {
                          widget.codigoClienteSeleccionado =
                              int.parse(map["CodigoServicio"].toString());
                          print("demo" + map["CodigoServicio"].toString());
                          _verRegistroServicio();
                          print(index);
                          print(map);
                        },
                      ),
                      SizedBox(
                        height: 80.0,
                      ),
                      Text(
                        "Para consultar debes  ingresar la razon  social y luego  dar",
                        style: TextStyle(fontSize: 8, fontFamily: "rbold"),
                      )
                    ],
                  )
                : Center(
                    child: Text(
                      getPrettyJSONString(widget.jsonCliente),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
          ),
        ));
  }

  String getPrettyJSONString(jsonObject) {
    JsonEncoder encoder = new JsonEncoder.withIndent(' ');
    String jsonString = encoder.convert(json.decode(jsonObject));
    return jsonString;
  }
}
