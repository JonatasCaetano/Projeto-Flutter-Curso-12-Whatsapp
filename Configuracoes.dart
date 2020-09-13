import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {

  TextEditingController _controllerNome = TextEditingController();
  File _imagem;
  String _idUsuarioLogado;
  bool _subindoImagem = false;
  String _urlImagemRecuperada;

  Future _recuperarImagem(String origemImagem) async{

    File imagemSelecionada;

      switch(origemImagem){
        case 'Camera':
          imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
          break;
        case 'Galeria':
          imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
          break;
      }
      setState(() {

        _imagem = imagemSelecionada;
      });
      if(_imagem!= null){
        _subindoImagem = true;
        _uploadImagem();
      }
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child('perfil').child(_idUsuarioLogado + 'jpg');
    StorageUploadTask task = arquivo.putFile(_imagem);
    task.events.listen((StorageTaskEvent storageEvent){
      if(storageEvent.type == StorageTaskEventType.progress){
        setState(() {
          _subindoImagem=true;
        });
      }else if (storageEvent.type == StorageTaskEventType.success){
        setState(() {
          _subindoImagem=false;
        });
      }
    });
    task.onComplete.then(
        (StorageTaskSnapshot snapshot){
          _recuperarUrlImagem(snapshot);
        }
    );
  }

  _recuperarUrlImagem(StorageTaskSnapshot snapshot)async{
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore( url );
    setState(() {
      _urlImagemRecuperada =url;
    });
  }

  _atualizarUrlImagemFirestore( String url ){
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      'urlImagem' : url
    };

    db.collection('usuarios').document(_idUsuarioLogado).updateData( dadosAtualizar);
  }

  _atualizaNomeFirestore( ){

    String nome = _controllerNome.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      'nome' : nome
    };

    db.collection('usuarios').document(_idUsuarioLogado).updateData( dadosAtualizar);
  }

  _recuperarDadosUsuario()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    _idUsuarioLogado = user.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection('usuarios').document(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data;
    _controllerNome.text= dados['nome'];

    if(dados['urlImagem'] != null){
      setState(() {
        _urlImagemRecuperada = dados['urlImagem'];
      });
    }

  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(bottom: 16),
                   child: _subindoImagem ? CircularProgressIndicator() : Container(),
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: _urlImagemRecuperada != null ? NetworkImage(_urlImagemRecuperada) : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                        onPressed: (){_recuperarImagem('Camera');},
                        child: Text('Camera')
                    ),
                    FlatButton(
                        onPressed: (){_recuperarImagem('Galeria');},
                        child: Text('Galeria')
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    autofocus: true,
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: 'Nome',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32)
                        )
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text('Salvar', style: TextStyle(color: Colors.white, fontSize: 20),),
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      onPressed: (){
                        _atualizaNomeFirestore();
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

