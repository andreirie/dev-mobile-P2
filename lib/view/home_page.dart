import 'dart:io';

import 'package:apk_catalogo/database/helper/horse_helper.dart';
import 'package:apk_catalogo/database/model/horse_model.dart';
import 'package:apk_catalogo/view/horse_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum OrderOptions { orderAZ, orderZA, orderWinsDesc, orderWinsAsc }

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HorseHelper horseHelper = HorseHelper();
  List<Horse> horses = [];

  OrderOptions _currentOrder = OrderOptions.orderAZ;

  @override
  void initState() {
    super.initState();
    _reloadHorses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Catálogo de Cavalos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: _orderList,
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderAZ,
                child: Text("Ordenar por Nome (A-Z)"),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderZA,
                child: Text("Ordenar por Nome (Z-A)"),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderWinsDesc,
                child: Text("Ordenar por Vitórias (Maior)"),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderWinsAsc,
                child: Text("Ordenar por Vitórias (Menor)"),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.brown[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showHorsePage();
        },
        backgroundColor: Colors.brown,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Adicionar", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Lottie.asset(
              'assets/horse_steps.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          horses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Nenhum cavalo cadastrado.",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      Text(
                        "Toque no '+' para adicionar.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: horses.length,
                  itemBuilder: (context, index) {
                    return _horseCard(context, index);
                  },
                ),
        ],
      ),
    );
  }

  void _reloadHorses() {
    horseHelper.getAllHorses().then((list) {
      setState(() {
        horses = list;
        _orderList(_currentOrder);
      });
    });
  }

  String _formatDate(int? date) {
    if (date == null || date == 0) return "N/A";
    String dateString = date.toString().padLeft(8, '0');
    if (dateString.length == 8) {
      return "${dateString.substring(0, 2)}/${dateString.substring(2, 4)}/${dateString.substring(4, 8)}";
    }
    return "Inválida";
  }

  String _calculateWinRatio(int totalWins, int totalRaces) {
    if (totalRaces == 0) {
      return "0%";
    }
    double ratio = totalWins / totalRaces;
    return "${(ratio * 100).toStringAsFixed(1)}%";
  }

  void _orderList(OrderOptions result) {
    _currentOrder = result;
    switch (result) {
      case OrderOptions.orderAZ:
        horses.sort((a, b) {
          final nameA = a.name ?? "";
          final nameB = b.name ?? "";
          return nameA.toLowerCase().compareTo(nameB.toLowerCase());
        });
        break;
      case OrderOptions.orderZA:
        horses.sort((a, b) {
          final nameA = a.name ?? "";
          final nameB = b.name ?? "";
          return nameB.toLowerCase().compareTo(nameA.toLowerCase());
        });
        break;
      case OrderOptions.orderWinsDesc:
        horses.sort((a, b) {
          final winsA = a.totalWins ?? 0;
          final winsB = b.totalWins ?? 0;
          return winsB.compareTo(winsA);
        });
        break;
      case OrderOptions.orderWinsAsc:
        horses.sort((a, b) {
          final winsA = a.totalWins ?? 0;
          final winsB = b.totalWins ?? 0;
          return winsA.compareTo(winsB);
        });
        break;
    }
    setState(() {});
  }

  void _showHorsePage({Horse? horse}) async {
    final updatedHorse = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HorsePage(horse: horse)),
    );
    if (updatedHorse != null) {
      _reloadHorses();
    }
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          color: Colors.brown[50],
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                horses[index].name ?? "Ações",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text(
                  "Editar Cadastro",
                  style: TextStyle(fontSize: 18.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showHorsePage(horse: horses[index]);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text("Excluir Cavalo", style: TextStyle(fontSize: 18.0)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmar Exclusão"),
          content: Text(
            "Tem certeza que deseja excluir o cavalo ${horses[index].name ?? 'selecionado'}? Esta ação é irreversível.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("CANCELAR", style: TextStyle(color: Colors.blueGrey)),
            ),
            TextButton(
              onPressed: () {
                if (horses[index].id != null) {
                  final horseName = horses[index].name;
                  horseHelper.deleteHorse(horses[index].id!);
                  setState(() {
                    horses.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Cavalo $horseName excluído com sucesso!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erro ao excluir: ID não encontrado."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text("EXCLUIR", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.0, color: Colors.grey[600]),
        SizedBox(width: 4.0),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.0, color: Colors.brown[700]),
              SizedBox(width: 4.0),
              Flexible(
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _horseCard(BuildContext context, int index) {
    final horse = horses[index];
    final formattedDate = _formatDate(horse.lastVictoryDate);
    final winRatio = _calculateWinRatio(
      horse.totalWins ?? 0,
      horse.totalRaces ?? 0,
    );

    return Card(
      elevation: 6.0,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: () {
          _showOptions(context, index);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Seção da Imagem ---
            Container(
              height: 180.0, // Aumentando a altura da imagem
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(13.0)),
                image: DecorationImage(
                  image: horse.image != null && horse.image!.isNotEmpty
                      ? FileImage(File(horse.image!))
                      : AssetImage("assets/horse.png") as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                // Adiciona um gradiente para o texto ficar mais legível
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(13.0),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: Text(
                  horse.name ?? "Nome Desconhecido",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white, // Nome em branco para destaque
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // --- Seção de Detalhes e Estatísticas ---
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Chips de Detalhes
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: <Widget>[
                      _buildDetailChip(
                        icon: Icons.access_time,
                        label: "${horse.age} anos",
                      ),
                      _buildDetailChip(
                        icon: Icons.pets,
                        label: horse.gender ?? "Não Informado",
                      ),
                      _buildDetailChip(
                        icon: Icons.palette,
                        label: horse.coatColor ?? "Cor Indefinida",
                      ),
                    ],
                  ),
                  Divider(height: 16.0, color: Colors.grey[300]),
                  // Colunas de Estatísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        icon: Icons.emoji_events,
                        count: horse.totalWins.toString(),
                        label: "Vitórias",
                      ),
                      _buildStatColumn(
                        icon: Icons.directions_run,
                        count: horse.totalRaces.toString(),
                        label: "Corridas",
                      ),
                      _buildStatColumn(
                        icon: Icons.trending_up,
                        count: winRatio,
                        label: "Taxa de Vitórias",
                      ),
                    ],
                  ),
                  Divider(height: 16.0, color: Colors.grey[300]),
                  // Última Vitória
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.0,
                        color: Colors.brown,
                      ),
                      SizedBox(width: 6.0),
                      Text(
                        "Última Vitória: ",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
