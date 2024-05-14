import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:tcc_app/components/carousel.dart';
import 'package:tcc_app/models/deslike_model.dart';
import 'package:tcc_app/models/like_model.dart';
import 'package:tcc_app/models/user_model.dart';
import 'package:tcc_app/pages/home_page.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/resources/map_methods.dart';
import 'package:tcc_app/resources/format_methods.dart';
import 'package:tcc_app/resources/complaint_methods.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import 'package:tcc_app/pages/edit_complaint_page.dart';

class ComplaintPage extends StatefulWidget {
  final String complaintId;

  const ComplaintPage({Key? key, required this.complaintId}) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  late Future<Complaint> _complaintFuture;
  String _locationText = "Loading data...";
  String _dateText = "Loading data...";
  int _likes = 0;
  int _dislikes = 0;
  bool _userLiked = false;
  bool _userDisliked = false;
  late User _currentUser;
  bool _isCurrentUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _complaintFuture = _loadComplaintDetails();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      String? authToken = await authMethods.getToken();

      _currentUser = await authMethods.getUserDetails(authToken!);
      if (_currentUser.cpf.isNotEmpty) {
        setState(() {
          _isCurrentUserLoaded = true;
        });
      }
    } catch (error) {
      print("Erro ao carregar usuário atual: $error");
    }
  }

  Future<Complaint> _loadComplaintDetails() async {
    try {
      Complaint? complaint =
          await ComplaintMethods().getComplaintById(widget.complaintId);
      _loadLocationDetails(complaint.latitude, complaint.longitude);
      _loadDateDetails(complaint.date);
      _loadLikesAndDislikes();
      return complaint;
    } catch (error) {
      print("Erro ao carregar detalhes da denúncia: $error");
      throw error;
    }
  }

  Future<void> _loadLikesAndDislikes() async {
    try {
      String? authToken = await authMethods.getToken();
      if (authToken != null) {
        User currentUser = await authMethods.getUserDetails(authToken);
        List<Like> likes =
            await ComplaintMethods().getComplaintLikes(widget.complaintId);
        List<Deslike> deslikes =
            await ComplaintMethods().getComplaintDeslikes(widget.complaintId);
        setState(() {
          _likes = likes.length;
          _dislikes = deslikes.length;
          // Verificar se o usuário deu like ou deslike
          _userLiked = likes.any((like) => like.userId == currentUser.uid);
          _userDisliked =
              deslikes.any((dislike) => dislike.userId == currentUser.uid);
        });
      } else {
        throw Exception('Token JWT não encontrado');
      }
    } catch (error) {
      print("Erro ao carregar likes e deslikes: $error");
    }
  }

  Future<void> _likeComplaint() async {
    try {
      await ComplaintMethods().likeOrRemoveLike(widget.complaintId);
      _loadLikesAndDislikes();
    } catch (error) {
      print("Erro ao dar like na denúncia: $error");
    }
  }

  Future<void> _dislikeComplaint() async {
    try {
      await ComplaintMethods().dislikeOrRemoveDislike(widget.complaintId);
      _loadLikesAndDislikes();
    } catch (error) {
      print("Erro ao dar deslike na denúncia: $error");
    }
  }

  Future<void> _loadLocationDetails(double lat, double lon) async {
    try {
      Placemark address = await getAddressByLatLon(lat, lon);
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _locationText = address.street.toString();
        });
      }
    } catch (error) {
      print("Erro ao carregar endereço: $error");
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _locationText = "Erro ao carregar endereço.";
        });
      }
    }
  }

  Future<void> _loadDateDetails(DateTime date) async {
    try {
      String dateOfOccurrence = await formatDate(date);
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _dateText = dateOfOccurrence;
        });
      }
    } catch (error) {
      print("Erro ao carregar endereço: $error");
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _dateText = "Erro ao carregar endereço.";
        });
      }
    }
  }

  void _navigateToEditPage(Complaint complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditComplaintPage(complaint: complaint),
      ),
    );
  }

  // final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  //     GlobalKey<ScaffoldMessengerState>();

  void _showDeleteConfirmationDialog(String complaintId, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza de que deseja excluir esta reclamação?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteComplaint(complaintId, context);
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComplaint(
      String complaintId, BuildContext context) async {
    try {
      await ComplaintMethods().deleteComplaint(complaintId: complaintId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A reclamação foi excluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const HomePage(), // Substitua 'MapPage' pela página que você deseja navegar
        ),
      );
    } catch (error) {
      print("Erro ao excluir a reclamação: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erro ao excluir a reclamação. Por favor, tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _solveComplaint(String complaintId) async {
    try {
      await ComplaintMethods()
          .updateComplaint(complaintId: complaintId, status: 'Resolvido');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A reclamação foi resolvida'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      print("Erro ao excluir a reclamação: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Erro ao resolver a reclamação. Por favor, tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denúncia'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          FutureBuilder(
            future: _complaintFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && _isCurrentUserLoaded) {
                Complaint complaint = snapshot.data as Complaint;
                bool isCurrentUserComplaintOwner =
                    _currentUser.uid == complaint.userId;
                if (isCurrentUserComplaintOwner) {
                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _navigateToEditPage(complaint),
                        tooltip: 'Editar denúncia',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                              complaint.id.toString(), context);
                        },
                        tooltip: 'Exluir denúncia',
                      ),
                    ],
                  );
                }
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: _complaintFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                      "Erro ao carregar detalhes da denúncia: ${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                Complaint complaint = snapshot.data as Complaint;

                // Carrega os detalhes de localização (endereço)
                // _loadLocationDetails(complaint.latitude, complaint.longitude);
                // _loadDateDetails(complaint.date);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (complaint.images != null &&
                        complaint.images!.isNotEmpty)
                      GestureDetector(
                        child: Carousel(
                          images: complaint.images!
                              .map((image) => image.url)
                              .toList(),
                          height: MediaQuery.of(context).size.height * 0.32,
                          viewportFraction: 1,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black87,
                            builder: (BuildContext context) {
                              return Center(
                                child: Container(
                                  alignment: Alignment
                                      .center, // Centraliza verticalmente o conteúdo do Container
                                  padding: EdgeInsets.symmetric(
                                      vertical: 30, horizontal: 20),
                                  child: Carousel(
                                    images: complaint.images!
                                        .map((image) => image.url)
                                        .toList(),
                                    height: MediaQuery.of(context).size.height *
                                        0.7,
                                    viewportFraction: 1,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Chip(
                                  backgroundColor:
                                      complaint.status == 'Resolvido'
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                  label: Text(complaint.status!),
                                  labelStyle: TextStyle(
                                      color: complaint.status == 'Resolvido'
                                          ? Colors.green[900]
                                          : Colors.red[900]),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  side: const BorderSide(
                                      color: Colors.transparent)),
                            ],
                          ),
                          // SizedBox(
                          //   height: 6,
                          // ),
                          Text(
                            complaint.complaintType.classification,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            complaint.typeSpecification.specification,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w400),
                          ),

                          // SizedBox(
                          //   height: 6,
                          // ),
                          // Divider(
                          //   height: 2,
                          //   color: Colors.grey[600],
                          // ),
                          SizedBox(
                            height: 16,
                          ),
                          const Text(
                            'Descrição:',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(complaint.description,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          const SizedBox(height: 16),
                          const Text(
                            'Endereço:',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(_locationText,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          const SizedBox(height: 16),
                          const Text(
                            'Data do Ocorrido:',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(_dateText,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          const SizedBox(height: 16),
                          const Text(
                            'Hora do Ocorrido:',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(formatHour(complaint.hour),
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          const SizedBox(height: 16),
                          if (complaint.resolutionDate != null) ...[
                            const Text(
                              'Data da Resolução:',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              DateFormat.yMMMMd('pt_BR')
                                  .format(complaint.resolutionDate!),
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            children: [
                              IconButton(
                                onPressed: _likeComplaint,
                                icon: Icon(
                                    _userLiked
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    color: _userLiked ? Colors.blue : null),
                                tooltip: 'Curtir denúncia',
                              ),
                              Text('Likes: $_likes'),
                              IconButton(
                                onPressed: _dislikeComplaint,
                                icon: Icon(
                                    _userDisliked
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                    color: _userDisliked ? Colors.blue : null),
                                tooltip: 'Não gostei da denúncia (dislike)',
                              ),
                              Text('Deslikes: $_dislikes'),
                            ],
                          ),
                          SizedBox(height: 16),
                          if (_isCurrentUserLoaded &&
                              _currentUser.uid == complaint.userId &&
                              complaint.status == 'Não Resolvido')
                            ElevatedButton.icon(
                              onPressed: () {
                                _solveComplaint(complaint.id.toString());
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green[800],
                                  side: BorderSide(color: Colors.green),
                                  shadowColor: Colors.transparent),
                              icon: Icon(Icons.check, color: Colors.green),
                              label: Text('Solucionar Denúncia',
                                  style: TextStyle(color: Colors.green)),
                            )
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text(
                      "Erro desconhecido ao carregar detalhes da denúncia."),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
