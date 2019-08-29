import 'dart:async';
import 'dart:convert';

import 'package:peliculas/src/models/actores_model.dart';
import 'package:peliculas/src/models/pelicula_model.dart';
import 'package:http/http.dart' as http;

class PeliculasProvider{
  String _apikey    = '2156c8c54f513026073c957680dc3bbe';
  String _url       = 'api.themoviedb.org';
  String _languaje  = 'es-ES'; 

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();

  //código para stream tuberia
  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();
  /*al dejar el .broadcast hacemos que los demas widgets puedan escuchar si no lo ponemos solo uno puede hacerlo*/

  //definimos dos getters:  para insertar info al stream y otro para escuchar lo que emita
  Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;

  void disposeStreams(){
    _popularesStreamController?.close();
  }



  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);

    //print(decodedData['results']);

    final peliculas = new Peliculas.fromJsonList(decodedData['results']);

    //print(peliculas.items[0].title);

    return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() async{//generamos url
    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key'   : _apikey,
      'languaje'  : _languaje
    });

    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async{
    if (_cargando) return [];

    _cargando = true;

    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular', {
      'api_key'   : _apikey,
      'languaje'  : _languaje,
      'page'      : _popularesPage.toString()
    });

    final resp = await _procesarRespuesta(url);

    _populares.addAll(resp);
    popularesSink( _populares );

    _cargando = false;

    return resp;
  }

  Future<List<Actor>> getCast( String peliId ) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits', {
      'api_key'   : _apikey,
      'languaje'  : _languaje
    });

    final resp = await http.get(url);

    final decodedData = json.decode(resp.body);

    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actores;

  }

  Future<List<Pelicula>> buscarPelicula(String query) async{//generamos url
    
    final url = Uri.https(_url, '3/search/movie', {
      'api_key'   : _apikey,
      'languaje'  : _languaje,
      'query'     : query
    });

    return await _procesarRespuesta(url);
  }
}