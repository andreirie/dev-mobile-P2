import 'dart:io';

import 'package:apk_catalogo/database/helper/horse_helper.dart';
import 'package:apk_catalogo/database/model/horse_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class HorsePage extends StatefulWidget {
  final Horse? horse;
  HorsePage({Key? key, this.horse}) : super(key: key);

  @override
  State<HorsePage> createState() => _HorsePageState();
}

class _HorsePageState extends State<HorsePage> {
  Horse? _editHorse;
  bool _userEdited = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _coatColorController = TextEditingController();
  final _totalRacesController = TextEditingController();
  final _totalWinsController = TextEditingController();
  final _lastVictoryDateController = TextEditingController();

  final HorseHelper _helper = HorseHelper();
  final ImagePicker _picker = ImagePicker();

  final letterInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z\s]'),
  );

  final numberInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9]'),
  );

  @override
  void initState() {
    super.initState();
    if (widget.horse == null) {
      _editHorse = Horse(
        name: "",
        age: 0,
        coatColor: "",
        gender: "",
        totalRaces: 0,
        totalWins: 0,
        lastVictoryDate: 0,
        image: "",
      );
    } else {
      _editHorse = Horse.fromMap(widget.horse!.toMap());
      _nameController.text = _editHorse?.name ?? "";
      _ageController.text = _editHorse?.age.toString() ?? "";
      _coatColorController.text = _editHorse?.coatColor ?? "";
      _totalRacesController.text = _editHorse?.totalRaces.toString() ?? "";
      _totalWinsController.text = _editHorse?.totalWins.toString() ?? "";

      if (_editHorse?.lastVictoryDate != 0 &&
          _editHorse!.lastVictoryDate.toString().length == 8) {
        String dateString = _editHorse!.lastVictoryDate.toString().padLeft(
          8,
          '0',
        );
        String day = dateString.substring(0, 2);
        String month = dateString.substring(2, 4);
        String year = dateString.substring(4, 8);
        _lastVictoryDateController.text = "$day/$month/$year";
      } else {
        _lastVictoryDateController.text = "";
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _coatColorController.dispose();
    _totalRacesController.dispose();
    _totalWinsController.dispose();
    _lastVictoryDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    if (_editHorse?.lastVictoryDate != 0 &&
        _editHorse!.lastVictoryDate.toString().length == 8) {
      final dateString = _editHorse!.lastVictoryDate.toString().padLeft(8, '0');
      final day = int.tryParse(dateString.substring(0, 2)) ?? 1;
      final month = int.tryParse(dateString.substring(2, 4)) ?? 1;
      final year =
          int.tryParse(dateString.substring(4, 8)) ?? DateTime.now().year;

      try {
        initialDate = DateTime(year, month, day);
      } catch (_) {
        initialDate = DateTime.now();
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.brown,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.brown[50],
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _userEdited = true;
      setState(() {
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        final year = picked.year.toString();
        _lastVictoryDateController.text = "$day/$month/$year";

        _editHorse?.lastVictoryDate = int.parse("$day$month$year");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
          _editHorse?.name != null && _editHorse!.name!.isNotEmpty
              ? _editHorse!.name!
              : "Novo Cavalo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: WillPopScope(
        onWillPop: _requestPop,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: GestureDetector(
                      onTap: () => _selectImage(),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 150.0,
                            height: 150.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                color: Colors.brown,
                                width: 3.0,
                              ),
                              image: DecorationImage(
                                image:
                                    _editHorse?.image != null &&
                                        _editHorse!.image!.isNotEmpty
                                    ? FileImage(File(_editHorse!.image!))
                                    : AssetImage("assets/horse.png")
                                          as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildInfoCard(
                  title: "Informações Básicas",
                  children: [
                    _buildTextFormField(
                      controller: _nameController,
                      labelText: "Nome",
                      updateAppBar: true,
                      inputFormatters: [letterInputFormatter],
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editHorse?.name = text;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O nome é obrigatório!';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Apenas letras.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _ageController,
                            labelText: "Idade",
                            keyboardType: TextInputType.number,
                            inputFormatters: [numberInputFormatter],
                            onChanged: (text) {
                              _userEdited = true;
                              _editHorse?.age = int.tryParse(text) ?? 0;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório!';
                              }
                              if (int.tryParse(value)! <= 0 ||
                                  int.tryParse(value)! > 40) {
                                return 'Idade inválida.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: _buildDropdownFormField(
                            labelText: "Gênero",
                            options: ["Macho", "Fêmea"],
                            currentValue: _editHorse?.gender,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _userEdited = true;
                                setState(() {
                                  _editHorse?.gender = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    _buildDropdownFormField(
                      labelText: "Cor da Pelagem",
                      options: [
                        "Castanho",
                        "Alazão",
                        "Tordilho",
                        "Preto",
                        "Baio",
                        "Rosilho",
                      ],
                      currentValue: _editHorse?.coatColor,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _userEdited = true;
                          setState(() {
                            _editHorse?.coatColor = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildInfoCard(
                  title: "Estatísticas de Corrida",
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _totalRacesController,
                            labelText: "Total de Corridas",
                            keyboardType: TextInputType.number,
                            inputFormatters: [numberInputFormatter],
                            onChanged: (text) {
                              _userEdited = true;
                              _editHorse?.totalRaces = int.tryParse(text) ?? 0;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório!';
                              }
                              if (int.tryParse(value)! < 0) {
                                return 'Não pode ser negativo.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: _buildTextFormField(
                            controller: _totalWinsController,
                            labelText: "Total de Vitórias",
                            keyboardType: TextInputType.number,
                            inputFormatters: [numberInputFormatter],
                            onChanged: (text) {
                              _userEdited = true;
                              _editHorse?.totalWins = int.tryParse(text) ?? 0;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório!';
                              }
                              if (int.tryParse(value)! < 0) {
                                return 'Não pode ser negativo.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    _buildDateFormField(
                      labelText: "Data da Última Vitória",
                      controller: _lastVictoryDateController,
                      onTap: () => _selectDate(context),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveHorse,
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 15.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 4.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            Divider(color: Colors.grey[300]),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool updateAppBar = false,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      ),
      onChanged: (text) {
        onChanged(text);
        if (updateAppBar) {
          setState(() {});
        }
      },
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildDateFormField({
    required String labelText,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.brown),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDropdownFormField({
    required String labelText,
    required List<String> options,
    required String? currentValue,
    required void Function(String?) onChanged,
  }) {
    String? valueToUse = options.contains(currentValue) ? currentValue : null;

    List<DropdownMenuItem<String>> dropdownItems = options.map((String option) {
      return DropdownMenuItem<String>(value: option, child: Text(option));
    }).toList();

    dropdownItems.insert(
      0,
      const DropdownMenuItem<String>(value: null, child: Text("-")),
    );

    valueToUse = currentValue == null || !options.contains(currentValue)
        ? null
        : currentValue;

    return DropdownButtonFormField<String>(
      value: valueToUse,
      dropdownColor: Colors.brown[50],
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      ),
      hint: const Text("Selecione"),
      items: dropdownItems,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Obrigatório!';
        }
        return null;
      },
    );
  }

  Future<void> _selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _userEdited = true;
      setState(() {
        _editHorse?.image = image.path;
      });
    }
  }

  void _saveHorse() async {
    if (_formKey.currentState!.validate()) {
      if (_editHorse!.totalWins! > _editHorse!.totalRaces!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "O número de vitórias não pode ser maior que o número total de corridas.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final dateValue = _editHorse!.lastVictoryDate;

      if (_editHorse!.totalWins! > 0 && dateValue == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Se houver vitórias, a Data da Última Vitória é obrigatória.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (dateValue != 0 &&
          (_editHorse!.totalWins == null || _editHorse!.totalWins! == 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Se a Data da Última Vitória for preenchida, o Total de Vitórias deve ser maior que zero.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_editHorse?.image == "") {
        _editHorse?.image = null;
      }

      if (_editHorse?.name != null && _editHorse!.name!.isNotEmpty) {
        if (_editHorse?.id != null) {
          await _helper.updateHorse(_editHorse!);
        } else {
          await _helper.saveHorse(_editHorse!);
        }

        Navigator.pop(context, _editHorse);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("O nome do cavalo é obrigatório."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, verifique todos os campos obrigatórios."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar Alterações?"),
            content: Text("Se sair, as alterações serão perdidas."),
            actions: <Widget>[
              TextButton(
                child: Text("Cancelar", style: TextStyle(color: Colors.brown)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text("Sair", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      ).then((shouldPop) {
        if (shouldPop == true) {
          Navigator.pop(context);
        }
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
