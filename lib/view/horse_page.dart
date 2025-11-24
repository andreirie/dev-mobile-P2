import 'dart:io';

import 'package:apk_catalogo/database/helper/horse_helper.dart';
import 'package:apk_catalogo/database/model/horse_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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

  final dateMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
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

      _lastVictoryDateController.text =
          _editHorse?.lastVictoryDate.toString() == "0"
          ? ""
          : dateMask.maskText(
              _editHorse!.lastVictoryDate.toString().padLeft(8, '0'),
            );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveHorse();
        },
        backgroundColor: Colors.brown,
        icon: Icon(Icons.save, color: Colors.white),
        label: Text("Salvar", style: TextStyle(color: Colors.white)),
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
                              shape: BoxShape.circle,
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
                              if (int.tryParse(value)! < 0) {
                                return 'Não pode ser negativo.';
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
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    _buildTextFormField(
                      controller: _lastVictoryDateController,
                      labelText: "Data da Última Vitória (DD/MM/AAAA)",
                      keyboardType: TextInputType.number,
                      inputFormatters: [dateMask],
                      onChanged: (text) {
                        _userEdited = true;
                        _editHorse?.lastVictoryDate =
                            int.tryParse(dateMask.getUnmaskedText()) ?? 0;
                      },
                    ),
                  ],
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

  bool _isDateValid(String dateString) {
    if (dateString.length != 8) return false;

    try {
      final day = int.parse(dateString.substring(0, 2));
      final month = int.parse(dateString.substring(2, 4));
      final year = int.parse(dateString.substring(4, 8));

      final dateTime = DateTime.utc(year, month, day);

      return dateTime.year == year &&
          dateTime.month == month &&
          dateTime.day == day;
    } catch (e) {
      return false;
    }
  }

  Widget _buildDropdownFormField({
    required String labelText,
    required List<String> options,
    required String? currentValue,
    required void Function(String?) onChanged,
  }) {
    String? valueToUse = options.contains(currentValue) ? currentValue : null;

    return DropdownButtonFormField<String>(
      value: valueToUse,
      dropdownColor: Colors.brown[50],
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      ),
      hint: const Text("Selecione"),
      items: options.map((String option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
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

      final dateText = _lastVictoryDateController.text.replaceAll('/', '');

      if (_editHorse!.totalWins! > 0 && dateText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Se houver vitórias, a Data da Última Vitória é obrigatória (DD/MM/AAAA).",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (dateText.isNotEmpty &&
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
      if (dateText.isNotEmpty && dateText.length != 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Formato de data da última vitória incompleto. Use DD/MM/AAAA.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (dateText.isNotEmpty && !_isDateValid(dateText)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Data da última vitória inválida. Verifique o dia/mês/ano (DD/MM/AAAA).",
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
