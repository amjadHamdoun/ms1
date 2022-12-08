import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mstand/home/screens/show_file.dart';
import 'package:mstand/language_constants.dart';

class SectionFiles extends StatefulWidget {
  String companyName;
  String user_id;
  String projectName;
  String branchName;
  String sectionName;
  bool has_internet;

  SectionFiles({
    required this.companyName,
    required this.user_id,
    required this.projectName,
    required this.branchName,
    required this.sectionName,
    required this.has_internet,
  });

  @override
  State<SectionFiles> createState() => _SectionFilesState();
}

class _SectionFilesState extends State<SectionFiles> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).docs,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user_id)
              .collection('documents')
              .where('coName', isEqualTo: widget.companyName)
              .where('projectName', isEqualTo: widget.projectName)
              .where('branchName', isEqualTo: widget.branchName)
              .where('sectionName', isEqualTo: widget.sectionName)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(translation(context).conectError));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.size == 0) {
              return Center(child: Text(translation(context).noDocsAdd));
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        child: Container(
                          height: 70,
                          width: 5,
                          color: (data['expireDateTime'] as Timestamp)
                                  .toDate()
                                  .isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      Container(
                        width: width,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        child: MaterialButton(
                          splashColor: const Color.fromARGB(57, 49, 144, 245),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowFile(
                                  fileName: data['docName'],
                                  coName: data['coName'],
                                  projectName: data['projectName'],
                                  branchName: data['branchName'],
                                  sectionName: data['sectionName'],
                                  fileInfo: data['docInfo'],
                                  fileType: data['fileType'],
                                  addDateTime: data['addDateTime'].toString(),
                                  exDateTime: data['expireDateTime'],
                                  folderPath: data['folderName'],
                                  userId: widget.user_id,
                                  fileLink: data['fileType'] == 'Image'
                                      ? 'No'
                                      : data['fileUrl'],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                data['fileType'] == 'pdf'
                                    ? Icons.picture_as_pdf
                                    : data['fileType'] == 'Image'
                                        ? Icons.image
                                        : Icons.file_copy,
                                size: width * 0.10,
                                color: const Color(0xff3191f5),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['docName'],
                                      style: TextStyle(
                                        fontSize: width * 0.050,
                                      ),
                                    ),
                                    Text(
                                      '${data['coName']} > ${data['projectName']}',
                                      style: TextStyle(
                                        fontSize: width * 0.030,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (DateFormat('yyyy-MM-dd').format(
                                              (data['addDateTime'] as Timestamp)
                                                  .toDate()))
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.green.withOpacity(0.5),
                                        fontSize: width * 0.030,
                                      ),
                                    ),
                                    Text(
                                      (DateFormat('yyyy-MM-dd').format(
                                              (data['expireDateTime']
                                                      as Timestamp)
                                                  .toDate()))
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.red.withOpacity(0.5),
                                        fontSize: width * 0.030,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
