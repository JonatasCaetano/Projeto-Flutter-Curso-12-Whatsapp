import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/Login.dart';
import 'package:whatsappclone/Telas/AbaContatos.dart';
import 'package:whatsappclone/Telas/AbaConversas.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  TabController _tabController;
  String _emailUsuario='';
  List<String> itensMenu = ['Configurações', 'Deslogar'];

  _recuperarDadosUsuarios() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    setState(() {
      _emailUsuario = usuarioLogado.email;
    });

  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
    _recuperarDadosUsuarios();
    _tabController = TabController(length: 2, vsync: this);
  }

  _escolhaMenuItem(String itemEscolhido){

    switch(itemEscolhido){
      case 'Configurações':
        Navigator.pushNamed(context, '/configuracoes' );
        break;
      case 'Deslogar':
       _deslogarUsuario();
        break;

    }

  }

  _deslogarUsuario()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future _verificarUsuarioLogado()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if(usuarioLogado == null){
      Navigator.pushReplacementNamed(context, '/login');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Whatsapp'),
        bottom: TabBar(
            indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Padding(padding: EdgeInsets.only(bottom: 8, top: 8),
               child: Text('Conversas'),
              ),
              Padding(padding: EdgeInsets.only(bottom: 8, top: 8),
                child: Text('Contatos'),
              )
             ]
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context){
                return itensMenu.map((String item){
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }
                ).toList();
              },
          )
        ],
      ),
      body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            AbaConversas(),
            AbaContatos()
          ],
      )
    );
  }
}
